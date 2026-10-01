# Button

Square-cornered actions in three weights: royal primary, Tyrian "seal & send", and an outline secondary.

- Primary: `royal-action` fill, white text, Alternates 600 16px, min-height 52px, padding 0 28px. Hover lifts 2px.
- Seal: `tyrian-action` fill for sending things (contact letter, visitor book).
- Outline: transparent with 1px `tyrian-light` border and `ink` text.
- Text link: mono label in `royal-light` whose underline draws in on hover.
- One primary per view. Trailing arrow icons are inline 1.8-stroke SVG.
- The consumer provides the label and an href or handler; use `<a>` for navigation and `<button>` for actions.
