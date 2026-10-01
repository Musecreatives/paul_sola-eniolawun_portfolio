# Portfolio audit: pre-redesign baseline

Branch audited: `redesign/renaissance` at its base, which is `wip/local-redesign` (`dcd0a47`) plus one build fix (`f0d3348`).
How: `flutter build web --release`, served locally, driven with Playwright at **1440x900** (desktop) and **375x812** (mobile). Screenshots are in [`audit/`](audit/). Each page was captured as a sequence of viewport-height scroll steps (`-01`, `-02`, ...).

> Note: the hero on this branch is Paul's WIP rewrite. It is no longer "Developer + Computer Scientist" as a static line. It now reads "Developer + {Designer | Prototyper | Computer Scientist | Innovator}" with the role changing every 3 s, floating "Flutter Web" / "Product UI" tags and a scroll cue. The featured section is also the WIP version: a staggered image column on the left and `ProjectItem` cards on the right.

Severity: **P0** broken or blocking, **P1** hurts the core impression or fails accessibility, **P2** noticeable polish problem, **P3** nice to fix.

---

## 0. Blocker found before the audit could start

| Sev | Issue | Status |
|---|---|---|
| P0 | `flutter build web` **failed** on the current Flutter (3.44 / Dart 3.12): `font_awesome_flutter 10.x` extends `IconData`, which is now a `final` class. | **Fixed** in `f0d3348`: bumped to `^11.0.0` and changed the FA usages to `FaIcon`. No visual change. |

---

## 1. Fonts in use today (keep as the brand typeface)

| Where | Family | How it's loaded | Weights actually used |
|---|---|---|---|
| Whole app (`ThemeData.textTheme`) | **Montserrat Alternates** | `GoogleFonts.montserratAlternatesTextTheme(...)` in `lib/main.dart` (google_fonts 8.2.1, fetched at runtime from fonts.gstatic.com) | 400 (default body), 500, 600, 700, 800 (featured titles, menu), 900 (hero role line) |
| Menu page items + numbers | **Falls back to Roboto** (unintended) | `AnimatedDefaultTextStyle` in `menu_page.dart` gets a fresh `TextStyle` with no `fontFamily`, so it *replaces* the inherited Montserrat Alternates style instead of merging with it | 700 / 800 |
| `widgets/menu_item.dart` (dead code) | `'Montserrat'` (not bundled, never loaded) | `fontFamily: 'Montserrat'` | 400 / 700 |
| Certificate images | (raster text baked into the images) | n/a | n/a |

Findings:
- **P2** The menu, which Paul calls the best part of the site, renders in Roboto, unlike every other page. Compare `desktop-menu-hover-*.png` with any other page.
- **P2** Fonts load at runtime from Google's CDN. That means a flash of fallback text on first paint, and the site depends on a third party. Bundling the TTFs (`google_fonts` supports asset fallback) would fix both.
- **P3** There's no type scale. Sizes are hard-coded per widget: 12, 13, 14, 15, 16, 18, 20, 22, 24, 28, 30, 32, 34, 36, 48, 60, 64, 72, 96, 100.

## 2. Art and image asset inventory

### Menu artworks (`assets/images/`, all 639x357 PNG)

The perspective skew is **baked into the PNGs**: each has white trapezoid corners. It is not a Flutter transform.

| File | Shown for | Subject | Notes |
|---|---|---|---|
| `menu_image_1.png` (8 KB) | 01 Home | "THINK OUTSIDE THE BOX" typographic box | Not an artwork |
| `menu_image2.png` (96 KB) | 02 My Projects | *Boxer at Rest* (Hellenistic bronze, c. 330-50 BC, Museo Nazionale Romano) | Classical, not Renaissance |
| `menu_image3.png` (478 KB) | 03 My Experience | Raphael, *The School of Athens* (1509-11) | Renaissance |
| `menu_image4.png` (360 KB) | 04 Certificates | Jacques-Louis David, *The Death of Socrates* (1787, the Met) | Neoclassical, not Renaissance |
| `menu_image5.png` (22 KB) | 05 About | Marcus Aurelius marble fragment on black | Stoic, fits the theme |
| `menu_image6.png` (263 KB) | 06 Contact Me | Marcus Aurelius bust, red censor bar, gold Meditations quote on a dark grid | Stoic and "techy", closest to the target mood |

Findings:
- **P1** At 639x357 the images get upscaled on the desktop menu (shown at up to 600x600 logical px, so about 1200 px on 2x screens). They look soft.
- **P2** The baked-in white skew corners only blend into an off-white panel. They show on any other background, and the skew can't be animated or refined in code.
- **P3** File naming is inconsistent (`menu_image_1` vs `menu_image2`), and `pubspec.yaml` lists 5 of the 6 explicitly while `assets/images/` already includes them all.

### Project and portrait imagery

| File | Size | Used by | Notes |
|---|---|---|---|
| `work-1/2/3.png` | ~630x260 | Featured section (home) | Blue rounded panel, "01/02/03" and a round logo baked into one raster. Logos are visibly **blurry** (upscaled). |
| `rapidrobo.png`, `ncrs.png`, `moveables_logo.png` | 190-214 px | unused | Duplicated in `icons/project_logo_1/2/3` (also unused) |
| `paul_photo.png` | 498x601, 568 KB | About (desktop at 700 px tall, so upscaled) | The only real photo. Heavy PNG for a photo; should be WebP/JPEG. |
| `paul-icon-1.png` | 49x49 | Navbar avatar (40 px) | Cartoon avatar; blurry on 2x screens |
| `paul_avatar.png` | **missing** | About (mobile) | **P1: 404.** It leaves an empty 140 px gap under "Hey, there" (`mobile-about-01.png`). |
| `hngx_finalist-cert_1.png`, `diploma_edobits_cert_2.png`, `digital_garage_edobits.png` | ~640x370 | Certificates | The diploma image is reused for the "Google Digital Garage" card, so it shows twice (**P1 content bug**). |
| `navbar-mobile-responsive.png`, `ellipse.svg` | | unused | Design leftovers |

### Icons (`assets/icons/`)
- 36 small PNGs (16-72 px). 16 are used: the skill logos on Experience, the folder/brain emoji on Projects, the timeline icons. The others (`cross.png`, `bxs_up-arrow.png`, `Rectangle 34.png`, `Group 2.png`, the social PNGs, ...) are unused.
- Icon fonts in use: Material Icons, **Font Awesome** (socials), and **atlas_icons** (footer mail/phone, CV download). Three icon systems with three visual weights. atlas_icons alone ships about 40 icon fonts (see the tree-shake log).

---

## 3. Findings by category

### Hierarchy and composition
- **P1 Home, featured works:** the image column and the text column aren't linked. The "01/02/03" panels sit on the left and the titles and buttons sit on the right, with nothing tying them together. Images are offset (row 2 is shifted 70 px), so the rows drift out of alignment (`desktop-home-02/03.png`). On mobile the images become a horizontal strip that is mostly flat blue with a clipped logo (`mobile-home-02.png`).
- **P1 Projects page:** each project is one solid-blue slab. Title, summary, then four equal-weight columns (Technologies / Platforms / Goals / Links) in 12 px white70 text. Nothing leads, nothing is scannable, and every project looks identical (`desktop-projects-01.png`). On mobile the four columns become a hidden horizontal scroller, so Goals and Links sit off-screen and nothing hints that they're there (`mobile-projects-01.png`).
- **P1 Experience:** the page opens with 12 equal white "skill" cards (Trello, Slack, Google Meet get the same weight as Flutter). The actual career timeline comes second, below a fold-height block. Timeline cards are full-width white slabs on black, all the same shape.
- **P2 Hero:** the signature split (black/off-white) is strong, but there are too many unrelated decorations: two outline circles, a spinning orange "+", a rotating orange line, a pulsing blue ring, two floating tags, a blue centre rule and a scroll cue. The blue role word straddles the split, so half of it sits on black and half on paper.
- **P2 Quote band:** a 400 px tall flat-blue band holding one centred line, with the author pushed to the bottom-right corner, far from the quote.
- **P2 Contact:** "Get in Touch" is centred on mobile while the title under it is left-aligned (`mobile-contact-01.png`). The desktop social icons float at the far right edge, disconnected from the form.
- **P3 Footer:** fine structurally. "Let's work together!" is the right closer.

### Typography
- **P1** The hero role word wraps **mid-word** on mobile: "Innov / ator" at 375 px. I saw it during capture, but the roles cycle every 3 s so the committed `mobile-home-01.png` caught "Computer Scientist" instead, which wraps onto two lines across the split.
- **P2** The menu font falls back to Roboto (see section 1).
- **P2** Body copy on Projects is 12 px at 2.3:1 contrast, too small and too faint.
- **P3** Mixed case conventions for headings ("Browse my projects", "My featured works", "Schedule an Appointment", "Hey, there").

### Color
- **P1** Three near-identical blues hard-coded in 15+ places: `#3695E5`, `#3993E8` (quote band), `#3DA9FC` (theme primary). `AppColors` defines a palette (green accent, warning, error...) that is mostly unused. There's also an orange `#FF6B4A` used only in the hero.
- **P1** Blue is used as a *surface* (project cards, quote band, featured panels, CTA fills) as well as for text and accents, so nothing stands out.
- **P2** Light and dark pages alternate with no logic: Home is paper, Projects/Experience/About are black, Contact/Certificates are white. Moving between pages feels like changing sites.
- **P3** `constant_sizes.dart` is **entirely unused**. The `AppColors` usages are inconsistent (`kblack` vs `Colors.black` vs `Color(0xFF000000)`).

### Spacing and layout
- **P2** Spacing values are arbitrary per widget (6, 8, 10, 12, 14, 16, 18, 22, 24, 26, 28, 30, 32, 34, 40, 44, 60, 70, 80, 84, 112, 160). There's no scale.
- **P2** Page gutters jump between 16, 24, 70, 80 and 160 px depending on the page.
- **P2** Experience uses fixed `_DashedHorizontalLine` (width 1500) and `_DashedVerticalLine` (height 500) sizes. They work at 1440 by luck.
- **P3** Certificates is just a raw thumbnail grid with no title, issuer or date under each image. The details only appear in the lightbox.

### Responsiveness (375 / 1440 checked; 768 / 1280 are predicted from the code breakpoints)
- **P1** `ctaButton` "View Project" **overflows** its box on mobile: the label is clipped to "View Proje" and the arrow spills outside (`mobile-home-02.png`). Both offset-outline buttons scale by a fixed factor rather than sizing to their content.
- **P1** Projects detail columns are hidden in a horizontal scroller on mobile (see above).
- **P2** Breakpoints are inconsistent across files: 600/1024 (hero, quotes, about), 700 (ProjectItem), 800 (projects, contact, footer, experience), 900 (featured), 1024 (menu). At 768 some sections are "tablet" and others are "mobile".
- **P2** The mobile hero is `max(680, 0.94 * vh)`, so a strip of the next section shows under the split at 812 px tall.

### Accessibility
- **P1 Contrast** (WCAG 2.x, computed from the code colors):

  | Pair | Ratio | Verdict |
  |---|---|---|
  | white on `#3695E5` (buttons, project cards) | 3.19:1 | fails AA for body text |
  | white70 on blue (project summaries, quote author) | 2.31-2.34:1 | fails |
  | `#3695E5` role text on paper `#F4F4EF` | 2.89:1 | fails, even as large text |
  | blue subtitle on white cards (Experience) | 3.19:1 | fails for 14 px |
  | black54 body on paper | 4.50:1 | just passes |
  | blue on black | 6.59:1 | passes |

- **P1 Hit target:** the hamburger is a `Column` of two 4 px bars with an empty `SizedBox` between them inside an `InkWell`. Only the bars themselves take taps, so **taps in the gap between them fall through**. During this audit the menu could only be opened reliably through the semantics tree. On mobile the effective target is about 55x4 px.
- **P1 Semantics:** the menu toggle, the navbar avatar ("home") and every social `IconButton` have **no label or tooltip**. Screen readers announce "button". The menu rows aren't exposed as buttons at all. They are plain `GestureDetector`s and read as text.
- **P1 Focus:** custom buttons (`ctaButton`, `PopButton`, menu rows, hamburger) are `GestureDetector`/`MouseRegion` with no `Focus`, so they can't be reached by keyboard and show no focus ring. Only the form fields and Material buttons are keyboard-reachable.
- **P1 Reduced motion:** nothing checks `MediaQuery.disableAnimations`. The hero has an endless 12 s ambient loop (spinning +, rotating line, floating tags) and a 3 s role carousel. The quote band auto-advances every 8 s with no pause. That fails WCAG 2.2.2 (Pause, Stop, Hide).
- **P2** `web/index.html` still has `<title>muse_creatives_portfolio</title>` and `description="A new Flutter project."`. These are what search engines and link previews show.
- **P2** There's no URL routing. Every page is pushed with `Navigator.push`, so refresh always returns to Home, no page can be deep-linked or shared, and browser Back walks back through the menu overlay.

### Motion
- **P2** Motion is decorative rather than purposeful: perpetual hero loops, `Curves.elasticOut` on menu hover, 1.05-1.2x hover scale on almost everything (buttons, icons, images, menu toggle).
- **P2** Route transitions are a fade + 8% slide + 0.98 scale everywhere, including the menu. It's OK, but nothing distinguishes the menu as an overlay.
- **P3** The featured section's staggered reveal (VisibilityDetector, 1.2 s) is good in spirit. Keep the pattern and tighten it.
- **P3** The menu painting swap is fade + 0.94-1.0 scale. Pleasant, but the baked-in skew means the paintings themselves never move.

### Content and copy
- **P1 Outdated:** Experience lists only the BSc, RapidRobo and Innovated Digital. Missing: Synkkafrica (VP Eng, 2025 to present), ProxyLogic, NCRS, RobyHub, GIZ, SEDIN-GIZ, iConcept, Shaddai.
- **P1 Outdated:** About says "I lead the development team at Moveables" and "co-founded Orderlit". Neither matches the 2026 CV.
- **P1 Typo:** "**hether** sketching flows" should be "Whether" (About, desktop).
- **P1 Misleading form:** Contact's submit only shows a "Appointment scheduled!" snackbar. **No email is sent.** `lib/api/email_service.dart` is an **empty file**. The Netlify SendGrid function sits in `lib/api/netlify/functions/` (Netlify won't find it there) and has placeholder addresses (`you@yourdomain.com`).
- **P1** "Download CV" points at `https://example.com/your_cv.pdf`.
- **P1** Mobile Contact and mobile About social links point at **placeholders** (`twitter.com/yourhandle`, `linkedin.com/in/yourprofile`, ...). The desktop About sidebar icons have `onPressed: () {}` and do nothing. Figma/LinkedIn URLs differ between pages. Twitter and GitHub URLs have trailing spaces.
- **P2** All three "View Project" buttons open the same generic Projects page, not the project.
- **P2** Featured copy is thin and has errors ("Rapidrobo is a trading bot product that helps newbies.", "Moveables Apps").
- **P2** Experience: "CGPA: --" placeholder. RapidRobo dates say Feb-Mar 2025 (CV: Feb-Apr 2025).
- **P2** Certificates: "Google Digital Garage" reuses the EdoBits diploma image. Dates are in DD-MM-YYYY.
- **P3** Quotes are generic (Jobs, Kay, FDR, Schweitzer). The FDR line is the one in Paul's screenshots.

### Code health (affects how safely the redesign can proceed)
- `flutter analyze`: 15 issues (1 warning: unused `_ExperienceEntry` model; 14 infos: private types in public API, `ctaButton` naming, file names `hireMe_Button.dart` / `projectItem.dart`, deprecated `withOpacity`).
- Dead files: `widgets/menu_item.dart`, `data/models/featured_works.dart`, `data/models/experience.dart`, `configs/config.dart` (empty), `routes/routes.dart` (empty), `configs/constant_sizes.dart` (unused).
- Two copy-pasted offset-outline buttons (`cta_button.dart`, `hireMe_Button.dart`). `PopButton` takes required `width`/`height` arguments and ignores them.
- `Breakpoint` enum declared three times (hero, quotes, cta/pop as `_Breakpoint`).
- Content is hard-coded inside widgets (project lists in `project_page.dart`, experience in `experience_page.dart`, certificates in `certificates_page.dart`). The models in `lib/data/models` exist but are only partly used.
- `test/widget_test.dart` is the default counter test and would fail against this app.
- The navbar avatar pushes a *new* `HomePage` onto the stack on every tap, so the stack grows without bound.

---

## 4. Worth keeping

1. **The menu concept.** A full-height list on the left and a hover-swapped classical image on the right. It's the most distinctive thing on the site. Keep the six artworks and the hover-to-reveal behaviour. Fix the font fallback, the low-res assets and the baked-in skew.
2. **The artwork choices themselves.** Marcus Aurelius (x2), *School of Athens*, *Death of Socrates* and *Boxer at Rest* already point at a Stoic/classical voice. `menu_image6` (bust + censor bar + gold quote on a grid) is the closest existing asset to a "mature, techy classical" mood.
3. **Montserrat Alternates** as the brand face. It's distinctive and recognisably Paul's. It just needs a scale and consistent application, including the menu.
4. **The hero's split-field idea.** A strong two-tone composition with type crossing the seam. The decorations around it are what need cutting, not the idea.
5. **Staggered entrance pattern** with `visibility_detector` in the featured section and the menu stagger. Right mechanism, needs restraint and reduced-motion support.
6. **"Let's work together!" footer closer** and the email + socials block.
7. **The about portrait.** A good real photo. Needs a better crop/format and framing.
8. **Form validation** on Contact (required fields, email regex). Keep it and wire it to a real send.

---

## 5. Screenshot index (`docs/redesign/audit/`)

| Page | Desktop 1440x900 | Mobile 375x812 |
|---|---|---|
| Home (hero, featured, quote, footer) | `desktop-home-01..04` | `mobile-home-01..04` |
| Menu (hover state per item) | `desktop-menu-hover-{projects,experience,certificates,about,contact}` | `mobile-menu-hover-{...}` |
| Projects | `desktop-projects-01..02` | `mobile-projects-01..03` |
| Experience | `desktop-experience-01..02` | `mobile-experience-01..03` |
| Certificates | `desktop-certificates-01..02` | `mobile-certificates-01..02` |
| About | `desktop-about-01` | `mobile-about-01..02` |
| Contact | `desktop-contact-01` | `mobile-contact-01` |

Capture caveat: Flutter scrolls inside a canvas, so captures are viewport steps, not full-page images. Very long pages may have one step cut short where the scroll position didn't change between steps.
