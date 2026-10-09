# Bundled fonts

The app works offline, so its two typefaces are bundled here instead of being
fetched at runtime. `tool/setup.sh` downloads them from the Google Fonts
repository:

- `Fredoka-Variable.ttf` — display face (titles, numbers, buttons).
- `Nunito-Variable.ttf` — body face (labels and running text).

Both are variable fonts; `lib/core/theme/app_text_theme.dart` selects the
weight through the `wght` axis. Check each font's licence on
https://fonts.google.com before publishing the app.
