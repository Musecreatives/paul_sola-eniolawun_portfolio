# Deploying

The site runs as two containers, plus an optional third for HTTPS:

| Service | What it is | Port |
| --- | --- | --- |
| `web` | nginx serving the Flutter web build. Proxies `/api/` and `/_/` to PocketBase on the same origin. | `${WEB_PORT:-8080}` on the host, 80 inside |
| `pocketbase` | PocketBase v0.40.4 with `pb_migrations/` and `pb_hooks/` mounted read-only. Data lives in the `pb_data` volume. | 8090, internal only |
| `caddy` (profile `tls`) | Automatic HTTPS for `$DOMAIN`, reverse proxy to `web`. Adds HSTS. | 80 and 443 |

Paths on the site:

- `/` and every app route (`/works`, `/journal/...`, `/admin`, ...): the Flutter app. nginx falls back to `index.html`.
- `/api/...`: the PocketBase API, including realtime (SSE) and file downloads.
- `/_/`: the PocketBase dashboard (superusers only).
- `/cv/paul-sola-eniolawun-cv.pdf`: the static CV.
- `/healthz`: returns `ok` from nginx.

## Prerequisites

- A Linux server (amd64 or arm64) with Docker Engine and the Compose plugin (`docker compose version`).
- About 2 GB of free RAM and 5 GB of disk for the first build. The Flutter SDK is downloaded inside the build stage.
- For HTTPS: a domain whose A/AAAA records point at the server, and ports 80 and 443 open.
- Node 18 or newer on any machine that can reach the site, for the seed script (or use the throwaway container below).

## First deploy

```sh
git clone <this repo> portfolio && cd portfolio
cp .env.example .env
$EDITOR .env          # every variable is described in the file
```

Plain HTTP (behind your own proxy, or to try it out):

```sh
docker compose up -d --build
docker compose ps     # both services should be "healthy"
curl -fsS http://127.0.0.1:8080/healthz
```

With automatic HTTPS (set `DOMAIN` and `SITE_URL=https://$DOMAIN` in `.env` first):

```sh
docker compose --profile tls up -d --build
```

Caddy gets the certificate on first start; `docker compose logs caddy` shows progress. With the `tls` profile only Caddy needs to be public, so set `WEB_PORT=127.0.0.1:8080` in `.env` (or firewall port 8080). Otherwise nginx is also reachable over plain HTTP on that port.

The first build takes several minutes (Flutter SDK download and web compile). Later builds reuse the cached layers.

## Accounts

### PocketBase superuser (for the dashboard at `/_/`)

```sh
docker compose exec pocketbase pocketbase superuser upsert you@example.com 'a-long-password' --dir=/pb_data
```

Always pass `--dir=/pb_data`. Without it the command writes to a different, empty data directory.

### Curator account (Paul's login for the site admin at `/admin` and for the seed)

Public sign-up is off. As superuser, open `/_/` → Collections → `curators` → New record, and set email, password and verified. `seed/README.md` also shows how to do it with the API.

### Trusted proxy (do this once)

PocketBase sees nginx as the client unless told to read the forwarded IP, and its rate limiter (5 letters / visitor notes / subscriptions per minute per IP) would then treat every visitor as one. In `/_/` → Settings → Application, set the trusted proxy header to `X-Real-IP`. nginx sets it to the real client address, taking Caddy's `X-Forwarded-For` into account when Caddy is in front.

## Seed the content

`seed/seed.mjs` loads `assets/content/content.json` and its images into PocketBase. It is idempotent, so it is safe to re-run. It reads `PB_URL`, `CURATOR_EMAIL` and `CURATOR_PASSWORD` (see `seed/README.md`).

From the server, through nginx:

```sh
set -a; . ./.env; set +a
PB_URL=http://127.0.0.1:8080 node seed/seed.mjs
```

Without Node on the host, run it in a throwaway container on the compose network:

```sh
docker run --rm --network portfolio_default \
  -v "$PWD":/app:ro -w /app \
  --env-file .env -e PB_URL=http://pocketbase:8090 \
  node:22-alpine node seed/seed.mjs
```

## Email for letters

The contact form saves a letter and emails it to `PAUL_EMAIL`. SMTP comes only from `.env` (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`, `SMTP_TLS`). It is applied in memory on boot and never written to the database, so leave the dashboard's mail settings alone.

- Port 587 uses STARTTLS (`SMTP_TLS=false` or empty). Port 465 uses implicit TLS (`SMTP_TLS=true`).
- `SMTP_FROM` must be an address your provider lets you send from.
- After changing `.env`, run `docker compose up -d` to recreate the container with the new values.
- On boot, `docker compose logs pocketbase` shows `[mail] SMTP configured from env (...)` or which variables are missing. Without SMTP, letters are still saved and can be read in `/admin`.

## Backups

All state is in the `portfolio_pb_data` volume: the SQLite database and uploaded files. `pb_migrations/` and `pb_hooks/` are in git.

### Without downtime: PocketBase backups

In `/_/` → Settings → Backups you can create a backup now, download or restore one, and turn on scheduled backups (a cron expression, how many to keep, optionally an S3 bucket). Backups are written to `/pb_data/backups` inside the volume. Copy them off the server, for example with a nightly cron entry on the host:

```cron
30 3 * * * cd /srv/portfolio && mkdir -p backups-copy && docker compose cp pocketbase:/pb_data/backups/. ./backups-copy/ && rsync -a ./backups-copy/ backup-host:portfolio/
```

Adjust the path and destination. A backup that stays on the same disk is not a backup.

### Cold copy of the whole volume

This stops PocketBase for a few seconds so SQLite is consistent:

```sh
mkdir -p backups
docker compose stop pocketbase
docker run --rm -v portfolio_pb_data:/data:ro -v "$PWD/backups":/backup alpine:3.24.2 \
  tar czf /backup/pb_data-$(date +%F).tgz -C /data .
docker compose start pocketbase
```

### Restore

Use the dashboard (Settings → Backups → restore), or from a cold copy:

```sh
docker compose stop pocketbase
docker run --rm -v portfolio_pb_data:/data -v "$PWD/backups":/backup alpine:3.24.2 \
  sh -c 'rm -rf /data/* && tar xzf /backup/pb_data-YYYY-MM-DD.tgz -C /data && chown -R 10001:10001 /data'
docker compose start pocketbase
```

PocketBase runs as uid 10001, hence the `chown`.

## Updating the site

```sh
git pull
docker compose up -d --build                 # add --profile tls if you use Caddy
docker image prune -f                        # optional: drop old image layers
```

New migrations in `pb_migrations/` run automatically when PocketBase restarts. The app shell (`index.html`, `main.dart.js`, `flutter_bootstrap.js`) is served with `Cache-Control: no-cache`, so visitors get the new version on their next load. Other static files are cached for up to a week.

## Upgrading PocketBase

1. Read the release notes between the current and target version: https://github.com/pocketbase/pocketbase/releases. Look for changes to the JS hooks API, migrations and settings.
2. Take a backup (above).
3. In `pocketbase/Dockerfile` set `PB_VERSION`, and copy the `linux_amd64` and `linux_arm64` sha256 values from that release's `checksums.txt` into `PB_SHA256_AMD64` and `PB_SHA256_ARM64`. Set the same version in `docker-compose.yml` (`PB_VERSION` build arg and image tag) and in `.github/workflows/ci.yml`.
4. `docker compose up -d --build pocketbase`, then check `docker compose logs pocketbase` and the site.

The Flutter SDK is pinned the same way (`FLUTTER_VERSION` and `FLUTTER_SHA256` in the root `Dockerfile`, `flutter-version` in CI). Keep it in step with the version that produced `pubspec.lock`.

## Logs and troubleshooting

```sh
docker compose ps                         # health of each service
docker compose logs -f web pocketbase     # add caddy with the tls profile
docker compose exec pocketbase wget -qO- http://127.0.0.1:8090/api/health
```

- **`web` never starts**: it waits for `pocketbase` to be healthy. Check `docker compose logs pocketbase`. A failing migration or hook shows up there.
- **502 on `/api/`**: PocketBase is down or restarting. nginx resolves it by name on each request, so it recovers on its own once PocketBase is back.
- **Caddy cannot get a certificate**: DNS for `DOMAIN` does not point at this server yet, or ports 80/443 are blocked. Fix it and run `docker compose restart caddy`.
- **Uploads fail with 413**: nginx accepts up to 20 MB (`client_max_body_size` in `deploy/nginx/default.conf`). PocketBase also enforces each file field's own max size.
- **Letters arrive but no email**: see the `[mail]` lines in the PocketBase log.
- **Blank page after a deploy**: hard-reload once. If it persists, open the browser console. The Content-Security-Policy lives in `deploy/nginx/csp.conf`.
- **Building behind a TLS-inspecting proxy**: pass the proxy's CA as a build secret, e.g. `docker build --secret id=ca_bundle,src=/path/ca.pem .` (same for `./pocketbase`). It is used only during the download steps and is not stored in the image.
