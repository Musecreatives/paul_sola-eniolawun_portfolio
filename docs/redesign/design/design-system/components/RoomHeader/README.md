# RoomHeader

The opening of every room: Roman-numeral eyebrow, room title, a gilt rule that draws in, and an optional Stoic epigraph.

- Eyebrow: mono `placard-label` in `gilt-light`, e.g. "Room II".
- Title: `room-title` in `ink` (or `royal` on day walls).
- Rule: 120×2px `gilt`, draws in from the left over 1.2s.
- Epigraph: italic `small`/`body` in `ink-muted`, source in a mono label. One line, one per room.
- Pairs with the room map on the right edge, which highlights the current numeral.
- The consumer provides the numeral, title and the epigraph with its source.
