# PocketBase backend

Pinned to **PocketBase v0.40.4** (JS migrations and hooks, v0.23+ API).

```sh
./pocketbase serve --migrationsDir pb_migrations --hooksDir pb_hooks
```

- `1790812800_init_schema.js`: all collections and their API rules.
- `1790812801_rate_limits.js`: turns on the built-in rate limiter. Guests get 5 creates per 60s per IP on `letters`, `visitor_notes` and `subscribers`; PocketBase's default rules apply elsewhere.
- `1790812802_trusted_proxy.js`: trusts nginx's `X-Real-IP` header so rate limits and logs see real visitor IPs. Only safe while port 8090 stays private.

## Rules in short

Every write needs a `curators` account (`@request.auth.collectionName = "curators"`); curators can also read everything.

| Collection | Public |
| --- | --- |
| posts | list/view when `published` (and `publish_at` empty or past), or `scheduled` with `publish_at` past |
| works, roles | list/view when `visible = true` |
| certificates, collection_items, now | list/view |
| letters | create only. Rejected if the `website` honeypot is filled or `read` is set |
| visitor_notes | create (cannot set `approved`); list/view when `approved = true` |
| subscribers | create only (email unique, case-insensitive) |

## Environment (`pb_hooks/`)

| Var | Used for |
| --- | --- |
| `PAUL_EMAIL` | where new letters are emailed |
| `SMTP_HOST`, `SMTP_PORT` (default 587), `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM` | SMTP. Without `SMTP_HOST`/`SMTP_FROM` a warning is logged and letters are saved without an email |
| `SMTP_TLS` | `true` for implicit TLS. Defaults to true on port 465, STARTTLS otherwise |
| `SITE_URL` | links in the RSS feed (`GET /api/journal/rss.xml`). Falls back to the request host |

SMTP settings are applied in memory from env on boot and before each letter email; they are never written to the database.
