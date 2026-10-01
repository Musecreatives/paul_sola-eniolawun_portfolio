# Art credits

Every artwork hung on the site. The Flutter source of truth is `lib/data/paintings.dart`; keep this file in step with it. The design system only allows public-domain works (Wikimedia Commons, Met Open Access, Rijksmuseum, National Gallery of Art).

The current image files came from the previous version of the site (`menu_image_1.png` to `menu_image6.png`), converted to WebP in `assets/img/`. Nobody recorded where those scans or photographs were downloaded from, so the **Image source** column is unknown for every piece. The underlying works below are old enough to be public domain, but a photograph or reproduction can carry its own licence, so each source still needs checking.

TODO(paul): for each row, find the original file (for example on Wikimedia Commons or the museum's open-access site), record its URL and licence here, and ideally swap in a clean, unskewed scan at 1600px or more.

| Key | Title | Artist | Date | Medium | Where the work is | Image source | Used in |
|---|---|---|---|---|---|---|---|
| `school_of_athens` | The School of Athens | Raphael | 1509–1511 | Fresco | Apostolic Palace, Vatican City | Unknown. TODO(paul) | Foyer hero, menu (Room III), The Collection, journal cover, link previews (`og:image`) |
| `death_of_socrates` | The Death of Socrates | Jacques-Louis David | 1787 | Oil on canvas | The Metropolitan Museum of Art, New York | Unknown. TODO(paul) | Menu (Room IV), default journal cover |
| `boxer_at_rest` | Boxer at Rest | Unknown Hellenistic sculptor | c. 330–50 BC | Bronze | Museo Nazionale Romano, Rome | Unknown photograph. TODO(paul) | Menu (Room II), The Collection (sport), journal cover |
| `aurelius_fragment` | Marcus Aurelius, fragment | Unknown Roman sculptor | [Date unknown] | Marble | [Collection unknown] | Unknown photograph. TODO(paul) | Menu (Room V), Chronicle, 404 |
| `meditations` | Meditations | Marcus Aurelius bust, studio print | [Date unknown] | Print: bust with a red bar and a gold line from the *Meditations* on a dark grid | n/a | Unknown. TODO(paul): this is a designed print, not a museum piece. Confirm who made it and whether it may be used | Menu (Room VI), journal cover |
| `think_outside` | Think Outside the Box | [Unknown] | [Unknown] | Typographic print | n/a | Unknown. TODO(paul): not an artwork; confirm its source or replace it with a public-domain piece | Menu (Room I) |

Rooms VII (The Collection) and VIII (Correspondence) reuse *The School of Athens* and the Marcus Aurelius fragment in the menu as placeholders. TODO(paul): choose public-domain pieces for them and add them here.

## Other images (not artworks)

These are Paul's own and need no art credit:

- `assets/img/paul_portrait.webp` and `assets/img/paul_avatar.webp` (cut from the portrait): photograph of Paul. TODO(paul): credit the photographer if you want one.
- `assets/img/cert_digital_garage.webp`, `cert_ict_diploma.webp`, `cert_hngx_finalist.webp`: scans of Paul's certificates.
