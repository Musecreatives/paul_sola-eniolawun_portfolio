# The Sola-Eniolawun Collection

The portfolio of **Paul Sola-Eniolawun**, laid out like a Roman gallery. Each section of the site is a "room" (the Foyer, the Works, the Chronicle, the Journal and more), hung with public-domain paintings. A small CMS behind it lets Paul update everything from his own admin page, the "Curator's office", without touching code.

This README covers what was built in the 2026 redesign and the technologies behind it. To put the site on a server, see **[docs/DEPLOY.md](docs/DEPLOY.md)**.

---

## What was built

The old site was a single-page Flutter portfolio with hard-coded content and a Netlify function for the contact form. The redesign (merged in PR #1, branch `redesign/renaissance`) replaced it in eight steps:

1. **Design system**: colour tokens with night and day palettes, a type scale, spacing and shadows (`lib/theme/tokens.dart`). Fonts are bundled locally (Montserrat Alternates, Montserrat, JetBrains Mono), so the site loads nothing from Google Fonts.
2. **App shell**: URL routing with real paths (`/works`, `/journal/my-post`), a nav bar, a full-screen menu, a room map pinned to the right on wide screens, a day/night toggle and a custom 404 room.
3. **Eleven public rooms**, each checked against its design mockup at 1440px and 375px:
   - **Foyer**: the home page
   - **Works**: the project gallery, with a case-study page for each project
   - **Chronicle**: career timeline
   - **Certificates**
   - **About**
   - **Journal**: blog, with filters, a table of contents and RSS
   - **Collection**: Paul's tastes, hung salon-style
   - **Correspondence**: contact form and visitor book
   - **Not found**: the 404 room
4. **CMS backend on PocketBase**: database schema and access rules as migrations, rate limits against spam, server hooks that email new letters and serve the journal's RSS feed, and a seed script that loads the starting content. If the CMS is unreachable, the site falls back to a bundled copy of the content, so it never shows up empty.
5. **Admin, the "Curator's office"** at `/admin`: sign in, an overview with unread letters, managers for the journal, works, chronicle, certificates, collection, Now placard and visitor book (drag to reorder), a Markdown editor with preview and scheduled publishing, and the inbox for letters and subscribers. It's split into a separate download that only `/admin` loads, so ordinary visitors never fetch it.
6. **Motion**: lamp flicker, rise-in on scroll, gilt rules that draw in, slow drift on the paintings and a hero tilt. All of it turns off when the visitor's system asks for reduced motion.
7. **Deployment**: Dockerfiles, Docker Compose, nginx with a strict Content-Security-Policy and tuned caching, optional HTTPS through Caddy or a Cloudflare Tunnel, and GitHub Actions CI.
8. **Verification**: `flutter analyze` reported no issues, 65 widget and integration tests passed, every route loaded without errors at four screen widths in Chromium, and the full Docker stack was brought up and checked.

It also added SEO and social-preview tags, a generated CV PDF, image credits for every painting ([ART_CREDITS.md](ART_CREDITS.md)), and WebP versions of all images. The old code was moved to `legacy/` instead of being deleted.

The full build log is in [docs/redesign/PROGRESS.md](docs/redesign/PROGRESS.md). Design mockups and before/after screenshots are in [docs/redesign/](docs/redesign/).

---

## Technologies

| Area | Technology |
| --- | --- |
| Front end | **Flutter 3.47 / Dart 3.13**, compiled for the web (CanvasKit) |
| Routing | `go_router` with path URLs and deferred loading for the admin |
| Content | `markdown` (GFM plus custom margin-note and sample blocks), `visibility_detector` for scroll-triggered motion |
| Backend / CMS | **PocketBase 0.40** (Go + SQLite): auth, REST API, realtime, file storage, JS hooks and migrations |
| Client SDK | `pocketbase` Dart package, `http` |
| Web server | **nginx**: static files, gzip, cache headers, CSP, same-origin proxy to PocketBase |
| HTTPS / edge | **Cloudflare Tunnel** (`cloudflared`) or **Caddy** (automatic Let's Encrypt) |
| Containers | **Docker** multi-stage builds, **Docker Compose** |
| CI | **GitHub Actions**: analyze, test, Docker build |
| Testing | `flutter_test` widget tests at 375/768/1280/1440, a mocked PocketBase, Playwright/Chromium for end-to-end checks |
| Tooling | Node.js seed script, Netlify for preview deploys |

---

## Project layout

```
lib/
  theme/       design tokens and type styles
  widgets/     gallery frames, placards, buttons, icons, Markdown, motion
  shell/       page frame, nav, menu, room map
  rooms/       one file per public room
  admin/       the Curator's office (deferred)
  data/        models, content store, PocketBase client
assets/        images (WebP), fonts, bundled content.json
web/           index.html, manifest, CV, Netlify redirects
pb_migrations/ PocketBase schema, rules, settings
pb_hooks/      letter emails, RSS feed
seed/          content seed script
deploy/        nginx and Caddy config
docs/          DEPLOY.md and redesign notes
```

---

## Run it locally

```sh
flutter pub get
flutter run -d chrome                     # uses the bundled content
```

To work against a local PocketBase, start the Docker stack (`docker compose up -d --build`) and run:

```sh
flutter run -d chrome --dart-define=PB_URL=http://127.0.0.1:8080
```

Checks:

```sh
flutter analyze
flutter test
```

## Deploy

Docker Compose runs the whole stack: nginx with the app, and PocketBase. Cloudflare Tunnel puts it on your domain without opening any ports. Step by step, including accounts, seeding, email, backups and Cloudflare settings: **[docs/DEPLOY.md](docs/DEPLOY.md)**.

```sh
cp .env.example .env    # set TUNNEL_TOKEN, SITE_URL, SMTP...
docker compose --profile tunnel up -d --build
```

> **Note on Netlify previews:** Netlify serves only the static app. It has no PocketBase, so the admin page opens there but can't sign in, and the contact form doesn't send. Use the Docker deployment for the full site.
