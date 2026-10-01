# The Collection

The design system behind Paul Sola-Eniolawun's portfolio. The site is hung like a Roman gallery: visitors walk through numbered rooms, each artwork sits in a gilt frame under a picture light, and every piece has a museum placard. Roman royal blue and Tyrian purple carry the walls, gilt is kept for frames and small ornament, and Montserrat Alternates is the voice.

Reference design: the "Portfolio Gallery Redesign" canvas in Claude Design (public site and Admin CMS pages).

## Content fundamentals

- **Rooms, not pages.** Each section is a room with a Roman numeral: I Foyer, II Selected Works, III Chronicle, IV Certificates, V About, VI Journal, VII The Collection, VIII Correspondence. Admin is the Curator's office.
- **Epigraphs.** A room may open with one short Stoic line (Marcus Aurelius, Seneca, Epictetus) with its source in a mono label. One per room, never decorative filler.
- **Placard voice.** Labels read like museum wall text: an inventory line (`Inv. PSE–2025–01`), a title, then medium and date. "Medium: Next.js, Node.js, Flutter" instead of "Tech stack".
- **Plain, first person, short sentences.** "Letters are read by me, not a bot." No hype, no em-dash asides.
- **Placeholders** for unknown facts are bracketed: `[YEAR]`, `[Metric]`. Never invent numbers.

## Visual foundations

**Walls.** `ground` for the deepest surface, `wall` for most rooms, `wall-salon` for The Collection and the menu's painting side. The imperial blend (135°: `royal` → `#1E1752` → `#341552`) is reserved for the Foyer, the 404 room and the admin entrance, always with a warm radial picture light at about 10% opacity. Long reading (Chronicle, Journal) moves to the day palette: `wall`/`ground` in the day theme.

**Frames.** Border 14px `frame-moulding` (10px small), a 1px `frame-fillet` outline inset 9px (7px small), padding 18px of `matte`, `shadow-frame`. Hover lifts 6px to `shadow-frame-hover`. Square corners (`radius-none`).

**Picture lamp.** A `gilt` bar 7px tall, `radius-lamp`, with `shadow-lamp`, centred 22px above a hero frame. It flickers on once on load.

**Placards.** `placard` ground, `placard-ink` text, `shadow-placard`, padding `space-3`. Line 1 is a mono `placard-label` in `tyrian`; line 2 the title in `placard-title`; line 3 `small` in `placard-muted`. A placard sits off the frame's lower-right corner and never covers the art.

**Plates.** Work without imagery is shown as a plate inside the frame: a 22px blueprint grid of `royal` at 10% on `#EFEAF6`, or the dark plate (`#0E0C26` with `royal-light` at 12%). The title is set in Alternates in `royal`.

**Type.** Montserrat Alternates for display and headings only; plain Montserrat for anything longer than two lines; JetBrains Mono uppercase at 12px with 0.16em tracking for labels, numerals and metadata. Body measure 60–70 characters.

**Colour rules.**
- Primary action: `royal-action` with white text. Sending or sealing (contact, visitor book): `tyrian-action`.
- Outline action: 1px `tyrian-light` border, `ink` text.
- Accent text on walls: `royal-light`; labels and numerals: `gilt-light`.
- Gilt (`gilt`) never carries body text. The only coloured shadow is `shadow-lamp`.
- No left-border accent cards, no gradient washes outside the imperial blend, no emoji.

**Spacing.** Rooms pad `space-7` top, gutters `space-5` desktop and `space-3` mobile, header-to-content `space-6`.

## Iconography

Inline stroke SVG at 1.8 stroke width, `currentColor`, 16–20px. Arrows (→), envelope, download, moon/sun, close. No icon fonts and no emoji. The PSE seal (a `tyrian` disc with a 1.5px `gilt` ring and Alternates initials) replaces any avatar or logo.

## Art

Only public-domain works (Wikimedia Commons, Met Open Access, Rijksmuseum, National Gallery of Art). Credit each piece's title, artist and year on its placard and in ART_CREDITS.md. The current menu images have a perspective skew baked in, so frames crop them with `object-fit: cover` and scale 1.32; replace them with clean, unskewed scans when possible. The Paintings asset group holds the current set; Portraits holds Paul's portrait for the About room and author cards.

## Motion

- Picture lamp flickers on: 1.6s once.
- Frames and text rise in: 900ms, `cubic-bezier(.2,.7,.1,1)`, 80ms stagger.
- Gilt rules draw in from the left: 1.2s.
- Paintings drift (slow Ken Burns): 26s loop, scale 1.32 → 1.38.
- Hero painting tilts with the cursor: up to ±4°.
- Menu paintings crossfade: 900ms.
- Hover: 180ms; frames lift 500ms.
- `prefers-reduced-motion: reduce` stops all of it; content is fully visible at rest.

## Accessibility

Text meets 4.5:1 on its own wall in both themes (checked pairs are noted on each token). Touch targets are at least 44px. Every form control has a label; icon buttons have `aria-label`. Focus rings are 2px `royal-action`.
