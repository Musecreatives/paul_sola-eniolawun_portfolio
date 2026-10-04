# Build progress: The Collection

Where the HANDOFF.md build stands. Branch `redesign/renaissance`. Last updated 2026-10-01 (cloud session).

## Steps from HANDOFF.md

| # | Step | Status |
|---|---|---|
| 1 | Tokens, themes, bundled fonts | **Done** (`1342fc5`) |
| 2 | App shell: go_router, nav bar, menu, room map, day/night, 404 | **Done** (`3c5ac2b`) |
| 3 | Public rooms, one per commit | **Done**, visual review against every mockup at 1440 and 375 finished (11 fix commits after `04cdd2c`; comparisons in `docs/redesign/build-screenshots/`) |
| 4 | PocketBase: migrations, rules, hooks, seed, repository, wiring | **Done** (`a6c024f`, `04cdd2c`, `cb004d8`) |
| 5 | Admin screens | **Done** (`e111433`, `7e6e212`), deferred-loaded |
| 6 | Motion pass | **Done** |
| 7 | Docker, Compose, nginx, CI, DEPLOY.md | **Done** (`43eff83`) |
| 8 | Verify | **Done**, results below |

## Verification observed (2026-10-01, Flutter 3.47.5 / Dart 3.13.4)

- `flutter analyze`: no issues.
- `flutter test`: 65 passed (rooms at 375/768/1280/1440, 404, menu, CMS repository and fallback, admin screens with a mocked PocketBase, motion and reduced motion).
- `flutter build web --release --no-web-resources-cdn --csp`: succeeded (~70s). The admin is a separate deferred chunk (`main.dart.js_1.part.js`, ~136 KB) that only `/admin` downloads; checked in Chromium.
- Chromium (Playwright), release build: all 12 routes at 375/768/1280/1440 load with no page or console errors. The site picks up live CMS content (edited the Now placard in PocketBase, saw it on `/`). Admin login, overview, Chronicle manager, letters and the journal editor were exercised against a real seeded PocketBase v0.40.4.
- `docker compose build`: **fails as-is in this sandbox** because its egress proxy re-signs TLS (PocketBase download: `certificate verify failed`). With the Dockerfiles' optional `ca_bundle` build secret and the proxy passed as build args, both images build. `docker compose up --wait`: both services healthy; `/healthz`, `/`, `/works`, `/admin`, `/api/health`, `/api/journal/rss.xml`, `/_/` all 200; CSP and cache headers present; a letter posted through nginx is saved and the hook logs that `PAUL_EMAIL` is unset. Docker Hub rate-limited this machine earlier, so base images came from `mirror.gcr.io`; nothing committed references the mirror.
- Screenshots of every route at four widths were taken and reviewed but not committed (size); the eight 1440 mockup-vs-build pairs are committed.

## What changed in this session (beyond the steps)

- `web/locale_guard.js`: headless Chromium in a POSIX-locale container reports `en-US@posix`, which made Flutter throw before the first frame. The guard swaps in a valid tag. Real browsers aren't affected.
- `web/index.html`: title, description, Open Graph, Twitter card, theme colour, noscript. `web/manifest.json`: real name and colours. `ART_CREDITS.md` added.
- `pb_migrations/1790812802_trusted_proxy.js`: PocketBase trusts nginx's `X-Real-IP`, so rate limits are per visitor. Port 8090 must stay private (it is, in Compose).
- `letters` has a `read` flag for the admin's unread count; the public can't set it.
- The Flutter Docker build downloads the official Flutter 3.47.5 tarball (sha256 pinned) because no `cirruslabs/flutter` image newer than 3.44.0 exists and the lockfile needs 3.47.5. Bump `FLUTTER_VERSION`/`FLUTTER_SHA256` and CI's `flutter-version` together.

## Differences from the mockups (deliberate)

- Nav bar and a "Next room" tour footer on every room; fixed room map on wide screens; journal TOC from `##` headings; Chronicle/Journal on the day palette (decisions from the first session).
- Admin sidebar adds **Subscribers**. **Media library** and **Settings** open the PocketBase dashboard (`/_/`), since uploads and server settings live there.
- Admin editor: "Preview" switches to a full-width preview; there is no autosave (Ctrl/Cmd+S saves). Publish turns into Schedule when "Publish on" is in the future. The admin login has no prefilled email.
- Our bundled Montserrat Alternates is wider than the mockups' fallback font, so a few lines wrap differently.

## Code map

- `lib/theme/tokens.dart`: `GalleryColors` ThemeExtension (night/day), `Palette`, `Space`, `Shadows`, `T` type styles, breakpoints (`compact < 720`, `wide >= 1100`).
- `lib/widgets/`: `gallery.dart` (frame, placard, plate, lamp, seal, buttons, text link, room header, `AutoGrid`, `TwoUp`), `pressable.dart` (one primitive for everything clickable, with focus ring, Enter/Space, link semantics via url_launcher `Link`), `icons.dart` (stroke icons drawn as paths, so no icon font), `markdown.dart` (GFM renderer plus `:::margin` and `:::sample` directives), `forms.dart`, `motion.dart`.
- `lib/shell/`: `page.dart` (`GalleryPage` with sections, nav bar, room map, tour footer), `menu.dart`, `rooms.dart` (Room enum).
- `lib/rooms/`: one file per room.
- `lib/data/api.dart`: PocketBase client (same origin on the web, `--dart-define=PB_URL` for dev) and `GalleryApi`, which maps records to the content.json shape. `store.dart` swaps in each collection that loads and keeps the bundled copy for any that fail.
- `lib/admin/`: the Curator's office (`kit.dart` shell, `login`, `overview`, `editor`, `manager` + `specs`), loaded through `lib/admin_gate.dart`.
- `lib/data/`: `models.dart` (field names match the planned PocketBase schema), `store.dart` (`ContentStore`, an InheritedNotifier, boots from `assets/content/content.json`), `site.dart` (email, socials, CV URL), `paintings.dart`.
- `assets/content/content.json`: the bundled fallback. It is meant to double as the seed for `seed/seed.mjs` in step 4.

## Decisions made

- **Old code is moved, not deleted.** The old presentation layer, unused icons, the dead Netlify/SendGrid function and the old PNGs were `git mv`'d to `legacy/`, which is excluded from the analyzer and the build. Deleting files was blocked in this environment, so Paul can remove `legacy/` himself.
- Fonts are bundled through pubspec `fonts:` as static TTFs (Montserrat Alternates 400/500/600, Montserrat 400/400i/500/600, JetBrains Mono 400/500, with OFL licences). `google_fonts`, `atlas_icons`, `font_awesome_flutter` and `dotted_border` were removed. The SDK floor is now `^3.10.0` (null-aware elements). The Docker image must use Flutter 3.44 or newer.
- Images were converted to WebP in `assets/img/`. The portrait is 1600px, and `paul_avatar.webp` is cut from the portrait.
- The home page `/` is the Foyer followed by Room II, so the "Scroll to enter Room II" cue is literal. `/works` also stands alone.
- Every room gets the nav bar at the top of its first wall and a "Next room" tour footer with email and socials. The mockups show the header only on the Foyer and have no footers. Added for navigation; note this in the PR.
- The room map is fixed to the viewport's right edge on wide screens (>= 1100px). In the Works mockup it scrolls with the page.
- Chronicle and Journal force the day palette. The other rooms follow the day/night toggle, except the imperial and salon walls, which stay fixed. The toggle isn't persisted across reloads.
- Menu rooms are buttons that pop the overlay and then `go()`. They aren't links, which avoids a double navigation.
- The journal TOC is built from the post's `##` headings, so the sample post shows two entries where the mockup shows three. The drop cap only applies when the first paragraph is plain text.
- The visitor book form has name and note only, as in the mockup. `city` exists in the model for the admin to fill in.
- **CV:** no CV PDF existed, so `web/cv/paul-sola-eniolawun-cv.pdf` was generated from `tool/cv/cv.html`, which uses site facts only (no referees, no phone number). The regenerate command is in the HTML comment. `TODO(paul)`: replace it with his own redacted CV if he prefers.
- Social URLs: the old code had conflicting LinkedIn and Figma URLs. The ones used twice were chosen, with a `TODO(paul)` in `lib/data/site.dart`.
- The PocketBase server is v0.40.4 (latest release). The Dart SDK `pocketbase` package is ^0.25.1. Windows binary was downloaded to the gitignored `.scratch/pb/` for local testing in step 4 (not done yet).
- The RSS link in the subscribe strip points at `/api/journal/rss.xml`. A `pb_hooks` route to serve it is planned for step 4 and **does not exist yet**.

## Motion

`lib/widgets/motion.dart` implements the README's Motion section: `LampFlicker` (1.6s lighton keyframes), `Rise` (28px, 900ms, 80ms stagger, starts when scrolled into view), `FadeIn`, `DrawIn` (1.2s from the left), `Drift` (26s, 1.32 → 1.38, only while on screen), `Tilt` (±4°, 1400px perspective). With `MediaQuery.disableAnimations` all of them render at rest, with no tickers.

## Open TODO(paul) so far

Search with `grep -rn "TODO(paul)" lib tool`:
- CV PDF (replace if wanted); social URLs to confirm; Now placard "reading"; public-domain art for menu rooms VII and VIII; case-study content per work; live URL for Synkkafrica; certificate scans, verify URLs and the three in-progress placeholders; usual reply time.
- Sources and licences for every painting in `ART_CREDITS.md`; portrait photographer credit.
- Plus every `[bracketed]` value in `assets/content/content.json` (best edited in the admin after seeding).

## Environment notes for whoever continues

- Flutter 3.47.5 stable was installed at `/opt/flutter` in the cloud container; Docker needed `dockerd` started by hand.
- `legacy/` is untouched; Paul deletes it himself.
