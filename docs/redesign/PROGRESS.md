# Build progress: The Collection

Where the HANDOFF.md build stands. Branch `redesign/renaissance`. Last updated 2026-10-01.

## Steps from HANDOFF.md

| # | Step | Status |
|---|---|---|
| 1 | Tokens, themes, bundled fonts | **Done** (`1342fc5`) |
| 2 | App shell: go_router, nav bar, menu, room map, day/night, 404 | **Done** (`3c5ac2b`) |
| 3 | Public rooms, one per commit | **Done, with visual review still owed** (`2ed246a`..`58badff`, see below) |
| 4 | PocketBase: migrations, rules, hooks, seed, repository, wiring | Not started |
| 5 | Admin screens | Not started |
| 6 | Motion pass | Not started (stubs only, see below) |
| 7 | Docker, Compose, nginx, CI, DEPLOY.md | Not started |
| 8 | Verify and screenshots | Not started |

### Step 3: what's done and what's owed

All public routes exist and render from the bundled content: `/`, `/works`, `/works/:slug`, `/chronicle`, `/certificates`, `/about`, `/journal`, `/journal/:slug`, `/collection`, `/correspondence`, and 404 for everything else.

Still owed for step 3:
- **Visual review against the mockups.** Only the Foyer was checked in a browser at 1440x900. It matched closely after two fixes: the hero words now scale down instead of breaking mid-word, and the Now strip runs full width. No other room has been looked at in a browser yet. They only pass the layout tests below.
- The contact form, visitor book and subscribe strip are wired to `ContentStore.sendLetter/signBook/subscribe`, which **throw `ContentOffline` until step 4**. The UI shows an honest failure message plus the email address. It never fakes success.

## Code map

- `lib/theme/tokens.dart`: `GalleryColors` ThemeExtension (night/day), `Palette`, `Space`, `Shadows`, `T` type styles, breakpoints (`compact < 720`, `wide >= 1100`).
- `lib/widgets/`: `gallery.dart` (frame, placard, plate, lamp, seal, buttons, text link, room header, `AutoGrid`, `TwoUp`), `pressable.dart` (one primitive for everything clickable, with focus ring, Enter/Space, link semantics via url_launcher `Link`), `icons.dart` (stroke icons drawn as paths, so no icon font), `markdown.dart` (GFM renderer plus `:::margin` and `:::sample` directives), `forms.dart`, `motion.dart`.
- `lib/shell/`: `page.dart` (`GalleryPage` with sections, nav bar, room map, tour footer), `menu.dart`, `rooms.dart` (Room enum).
- `lib/rooms/`: one file per room.
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

## Motion (step 6) state

`lib/widgets/motion.dart` holds the API the rooms already use: `Rise`, `FadeIn`, `DrawIn`, `LampFlicker`, `Drift`, `Tilt`. Right now these are pass-throughs, except that `Drift` applies the static 1.32 crop scale. Frame hover lift (6px, 500ms), button hover (180ms) and the menu crossfade (900ms) are implemented, and each checks `MediaQuery.disableAnimations`.

## Open TODO(paul) so far

Search with `grep -rn "TODO(paul)" lib tool`:
- CV PDF (replace if wanted); social URLs to confirm; Now placard "reading"; public-domain art for menu rooms VII and VIII; case-study content per work; live URL for Synkkafrica; certificate scans, verify URLs and the three in-progress placeholders; usual reply time.
- Plus every `[bracketed]` value in `assets/content/content.json`.

## Build and test status actually observed (2026-10-01, at commit `58badff`)

- `flutter analyze`: **No issues found.**
- `flutter test`: **48 passed.** Foyer, 404, menu open plus Esc close, and every public route at 375/768/1280/1440 with no layout exceptions.
- `flutter build web --release`: **succeeded** once, at the step 2 commit (about 117s). It has **not been re-run** since the later rooms were added.
- `docker compose build`: not applicable yet. There's no Dockerfile, and Docker isn't installed on this machine.
- The GitHub CLI isn't installed here. Push works over HTTPS.

## Environment notes for whoever continues

- `redesign/renaissance` is checked out in another worktree, so this work was done on a worktree branch and pushed with `git push origin HEAD:redesign/renaissance`.
- `.scratch/` (gitignored) has a Pillow venv, a PocketBase binary and `serve.py`, which serves `build/web` with SPA fallback and proxies `/api/` to `127.0.0.1:8090`.
