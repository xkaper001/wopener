# Browser icons for the interactive picker preview

Drop browser icon **SVGs** here. They auto-populate the picker preview on the
home page (`PickerPreview.astro`) — no code change needed.

- One file per browser, e.g. `safari.svg`, `google-chrome.svg`, `arc.svg`,
  `firefox.svg`, `brave.svg`, `microsoft-edge.svg`.
- The tile **name** is derived from the filename: `-`/`_` become spaces and each
  word is capitalised (`google-chrome.svg` → "Google Chrome").
- Tiles are ordered **A–Z** and numbered `1`–`9` in that order (max 9 shown).
- Keep icons roughly square; they render inside a 36–40px box.

Until at least one `.svg` is present here, the preview shows monogram
placeholders.
