# Build brief: The Collection

Approved redesign of Paul Sola-Eniolawun's portfolio. Build it in the existing Flutter Web app on branch `redesign/renaissance`. Paul signed off on the design on 2026-10-01.

## Sources of truth

- `docs/redesign/design/*.dc.html` are the approved screens. Each is a self-contained HTML mockup; open it in a browser to see it (layout, copy, colours, spacing). `assets/gallery.css` holds the shared classes and motion keyframes. `canvas.json` lists every screen with its title.
- `docs/redesign/design/design-system/` is the design system: `README.md` (rules), `tokens.json` (every colour, type style, spacing, radius, shadow), and component guidelines.
- `docs/redesign/AUDIT.md` lists bugs in the current site. Fix all of them as part of the rebuild.
- Paul's CV facts are already in the mockups (Chronicle, Works, Certificates). Anything in `[brackets]` is unknown: keep a visible placeholder and add `// TODO(paul): ...`.

## Decisions already made

- **Stay on Flutter Web.** No framework migration.
- **Keep Montserrat Alternates** for display and headings; Montserrat for body; JetBrains Mono for labels. Bundle the font files in `assets/fonts/` and turn off google_fonts runtime fetching.
- **Palette:** Roman royal blue + Tyrian purple, gilt for frames only (see tokens).
- **CMS: PocketBase**, self-hosted next to the site in Docker. The Flutter app talks to it with the `pocketbase` Dart package.
- **Deployment:** Paul's own server with Docker Compose.

## Screens to build (routes)

Use `go_router` with path URLs (`usePathUrlStrategy`) so every page has a shareable link and refresh keeps you on the page.

| Route | Screen file | Notes |
| --- | --- | --- |
| `/` | Hero.dc.html, MobileHero.dc.html | Foyer. Cursor tilt on painting, Now placard, room map, day/night toggle |
| menu overlay | Menu.dc.html | Hover/focus crossfades paintings. Fix the hamburger hit area (audit) |
| `/works` | Works.dc.html | Featured work + grid of plates |
| `/works/:slug` | CaseStudy.dc.html | Case study template |
| `/chronicle` | Chronicle.dc.html | Experience timeline, education, instruments, volunteering. Download CV must link to a real PDF |
| `/certificates` | Certificates.dc.html | Lightbox preview (prev/next/close, Esc, focus trap), In-progress section |
| `/about` | About.dc.html | New portrait (`assets/paul_portrait.jpg`, resize to ~1600px and WebP) |
| `/journal` | Journal.dc.html | Index, category filter, subscribe strip |
| `/journal/:slug` | JournalPost.dc.html | Markdown rendering, TOC, marginalia, code blocks, `SelectionArea` |
| `/collection` | Collection.dc.html | Tastes, salon hang |
| `/correspondence` | Correspondence.dc.html | Contact form that really sends + visitor book |
| `*` | NotFound.dc.html | 404 |
| `/admin` | AdminLogin.dc.html | Curator's entrance |
| `/admin/overview` | AdminOverview.dc.html | Counts, recent writing, letters, quick add |
| `/admin/journal/:id` | AdminEditor.dc.html | Markdown editor + live preview + cover painting picker |
| `/admin/:collection` | AdminCollections.dc.html | Table + edit drawer, drag to reorder. Same pattern for works, roles, certificates, collection items, visitor notes, letters |

Load the admin with deferred imports so visitors never download it.

## CMS (PocketBase)

Collections (all with `created`/`updated`):

| Collection | Fields | Public rules |
| --- | --- | --- |
| `posts` | title, slug (unique), body (markdown), excerpt, category (select), tags (json), cover (file or painting key), status (draft/scheduled/published), publish_at | list/view where status = published and publish_at <= now |
| `works` | title, slug, numeral, summary, body, medium, role, year, platforms, links (json), images (files), featured (bool), order | list/view where visible |
| `roles` | role, org, location, start, end, current (bool), highlights (json), linked_work (relation), order, visible | list/view where visible |
| `certificates` | title, issuer, year, image (file), verify_url, status (earned/in_progress), progress (0-100), target, order | list/view |
| `collection_items` | kind (book/record/chess/art/sport/game), title, subtitle, image (file), note, order | list/view |
| `now` | building, reading (single record) | view |
| `letters` | name, email, purpose, message | create only (no list/view). Honeypot field + rate limit |
| `visitor_notes` | name, city, note (max 140), approved (bool) | create; list/view where approved = true |
| `subscribers` | email (unique) | create only |

Admin auth: a `curators` auth collection with Paul's single account; every write rule requires `@request.auth.collectionName = "curators"`. Ship schema as `pb_migrations/`, a `pb_hooks/` JS hook that emails Paul on each new letter (SMTP from env), and `seed/` data plus a seed script that loads the content currently shown in the mockups.

The app must still render if the API is down: keep the current content as bundled JSON and use it as the fallback in the repository layer.

## Motion

Follow the Motion section of the design system README exactly: lamp flicker-on, staggered rise-in on scroll (visibility_detector), gilt rules drawing in, slow painting drift, ±4° cursor tilt on the hero painting, 900ms menu crossfade, 6px frame lift on hover. When `MediaQuery.disableAnimations` is true, show everything at rest with no motion. Keep 60fps; no shaders.

## Docker and deployment

- `Dockerfile`, multi-stage: build with a Flutter image (`flutter build web --release`), serve with `nginx:alpine`. Nginx: SPA fallback (`try_files $uri /index.html`), gzip, long cache for hashed assets and `no-cache` for `index.html`/`flutter_service_worker.js`, security headers, and proxy `/api/` and `/_/` to `pocketbase:8090`.
- `docker-compose.yml`: `web` (this Dockerfile) and `pocketbase` (pinned version, volumes for `pb_data`, `pb_migrations`, `pb_hooks`, healthcheck). An optional `caddy` service behind a `tls` profile for automatic HTTPS from a `DOMAIN` env var.
- `.env.example` with every variable (DOMAIN, SMTP host/user/pass/from, PAUL_EMAIL). Never commit real secrets.
- `docs/DEPLOY.md`: first deploy (`docker compose up -d --build`), creating the curator account, running the seed, backups of `pb_data`, updating.
- A GitHub Actions workflow that runs `flutter analyze`, `flutter test` and `docker build` on pull requests (no image push).

## Also fix

Everything in AUDIT.md, notably: the contact form that pretends to send, the example.com CV link, placeholder social links, menu items falling back to Roboto, the hamburger hit area, missing labels and focus states, mobile overflows, and the missing `paul_avatar.png`. Add page titles and Open Graph tags in `web/index.html`, and `ART_CREDITS.md` for every artwork.

## Order of work

One commit (or small series) per step, pushed to `redesign/renaissance` after each:

1. Tokens: a `ThemeExtension` from `tokens.json`, night/day themes, bundled fonts. Delete the old `constant_color.dart`/`constant_sizes.dart` usage.
2. App shell: go_router, nav bar, menu overlay, room map, day/night toggle, 404.
3. Public rooms, one per commit, matching the mockups.
4. PocketBase: migrations, rules, hooks, seed; Dart repository with JSON fallback; wire the rooms to it.
5. Admin screens.
6. Motion pass.
7. Docker, Compose, nginx, CI, DEPLOY.md.
8. Verify: `flutter analyze` clean, `flutter test` green, `flutter build web --release` succeeds, `docker compose build` succeeds if Docker is available, screenshots of every route at 375/768/1280/1440 compared against the mockups, saved to `docs/redesign/build-screenshots/`.

Finish with a draft pull request into `main` (or, if no GitHub CLI is available, the compare URL) summarising what shipped, what differs from the mockups and why, and the open `TODO(paul)` list.
