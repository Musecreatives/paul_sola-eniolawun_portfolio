# Frame

A gilt museum frame with matte, picture lamp and an optional placard; every artwork, project plate and portrait hangs in one.

- Border 14px `frame-moulding` (10px for small frames), 1px `frame-fillet` outline inset 9px (7px small), 18px `matte` padding, `shadow-frame`.
- Optional picture lamp: 7px `gilt` bar, `radius-lamp`, `shadow-lamp`, centred 22px above the frame. Use on hero pieces only.
- The image fills a window with `overflow: hidden`; paintings use `object-fit: cover`, portraits anchor at 50% 12%.
- Hover lifts the frame 6px and deepens to `shadow-frame-hover`.
- The consumer provides the image (or a plate), its alt text and the aspect ratio (16/10 hero, 4/3 grid, 3/4 portrait).
