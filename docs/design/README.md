# Design reference

Everything a coding session needs to build the screens: the visual tokens, the
shared components, and one mockup per screen.

- `screens/` — PNG capture of every mockup (390 x 844 pt, rendered at 2x).
  **Open the PNG of a screen before building it.**
- `source/` — the markup each capture was rendered from (same file name,
  `.dc.html`). Inline CSS and SVG give exact sizes, colors, radii and paths.
  These files are templates of the design tool: they do not render when opened
  directly in a browser (`{{holes}}`, `<sc-for>`, `<sc-if>` are filled by the
  small `Component.renderVals()` script at the bottom of each file), and the
  links between screens point to the tool's original file names.
- Online canvases (same content, browsable):
  [first six screens](https://claude.ai/artifact/MDoGGS2uwsFLqTK7nKnUYL),
  [remaining screens](https://claude.ai/artifact/3obJHG47Yvgy8nTEXTx2tG).

The mockups are the target for layout, hierarchy, color and wording. All
sample data in them (Awa, Moussa, Lina, scores, codes) is illustrative.

## Screens

| File prefix | Screen | Lot | Notes |
| --- | --- | --- | --- |
| `01-who-is-playing` | Qui joue ? | F1 | Streak pill arrives with F7 |
| `02-profile-creation` | Création de profil | F1 | 12 avatars, 6 background colors |
| `03-learning-path` | Parcours (home) | F5 | Header band (streak, crowns, daily goal) arrives with F7; crowns with F6 |
| `04-table-detail` | Détail d'une table | F5 | Five stages, done / current / locked |
| `05-discovery-stage` | Étape Découverte | F5 | Whole table plus its tip |
| `06-quiz-multiple-choice` | Quiz, waiting for an answer | F3 | Combo pill arrives with F7 |
| `06b-quiz-correct-answer` | Quiz, right answer feedback | F3 | |
| `06c-quiz-wrong-answer` | Quiz, wrong answer feedback | F3 | Shows the full operation |
| `07-quiz-true-false` | Quiz, true or false | F3 | |
| `08-boss-fight` | Combat de boss | F6 | Dark screen; also the reference for the numeric keypad (typed answer, F3) |
| `09-results` | Résultats | F3, F5, F7 | Stars with F5; XP, level, badges with F7 |
| `10-training` | S'entraîner | F9 | |
| `11-challenges` | Défis | F9, F12, F13, F14, F19 | 1.0 ships only the Contre-la-montre card and records |
| `12-profile` | Profil | F10 (mascot card F8) | Mastery grid 12 x 10 |
| `13-settings` | Réglages | F10 | Taller board (390 x 1100). Rappel: F18. Sauvegarde: F20. Classement toggle: F17 |
| `14-my-monsters` | Mes monstres | F13 | |
| `15-duel` | Duel | F14 | Top half is rotated 180° |
| `16-quiz-find-operation` | Quiz, find the operation | F15 | |
| `17-quiz-match-pairs` | Quiz, match the pairs | F15 | |
| `18-placement-test-result` | Bilan du test de départ | F16 | |
| `19-leaderboard` | Classement | F17 | |
| `20-challenge-code` | Défi par code | F19 | |
| `21-challenge-score` | Défi, comparaison des scores | F19 | |
| `22-shop` | Boutique | F21 | |

Not drawn yet — derive from the existing screens and have the owner validate
before the lot starts: fill-in-the-blank question (F3), help sheet after two
errors (F4), Survie in-quiz screen (F12), duel player picker (F14),
confirmation dialogs (quit quiz, reset, delete profile), celebration overlays
(level up, badge, mascot stage).

## Tokens

Already implemented in `lib/core/theme/` and `lib/core/constants/`. Widgets
never use raw colors: they read `Theme.of(context)`, `context.palette`
(`AppPalette`) and `AppSizes`. Add a color to `AppColors` and a role to
`AppPalette` when a lot needs one that is listed here but not yet in code.

### Colors

| Token | Hex | Use | In code |
| --- | --- | --- | --- |
| ground | `#F4F1FF` | Screen background | `AppColors.ground` |
| ink | `#221A4D` | Text; boss screen background | `AppColors.ink` |
| muted | `#5D567A` | Secondary text | `AppColors.muted` |
| white | `#FFFFFF` | Cards and controls | `AppColors.white` |
| violet | `#5B3DF5` | Main action | `AppColors.violet` |
| violet depth | `#3A22B8` | Raised edge under violet | `AppColors.violetDepth` |
| violet text | `#4A2FD6` | Violet text on light ground | `AppColors.violetText` |
| violet tint | `#E4DEFF` | Selected, highlighted | `AppColors.violetTint` |
| violet border | `#DDD6FF` | Outline and edge of white controls | `AppColors.violetBorder` |
| yellow | `#FFC531` | Rewards: stars, crowns, streak, mascot | `AppColors.yellow` |
| yellow depth | `#E0A100` | Raised edge under yellow | `AppColors.yellowDepth` |
| yellow tint | `#FFF3CF` | Background of reward elements | `AppColors.yellowTint` |
| green | `#137A4B` | Right answer | `AppColors.green` |
| green depth | `#0C5A36` | Raised edge under green | `AppColors.greenDepth` |
| green tint | `#DDF3E6` | Right-answer message | `AppColors.greenTint` |
| red | `#C8321F` | Wrong answer, destructive action | `AppColors.red` |
| red depth | `#8F2114` | Raised edge under red | `AppColors.redDepth` |
| red tint | `#FBE3DF` | Wrong-answer message | `AppColors.redTint` |
| dashed violet | `#C9BFFF`, `#A99BF0` | Dashed hint boxes, "new player" card | To add with F1 / F3 |
| neutral pill | `#ECE8FB` | "Pas de série" pill | To add with F1 |
| locked | `#E3DEF7`, edge `#CFC8EC` | Locked nodes and stages, empty star, "new" mastery cell | To add with F5 |
| toggle off | `#8A82A8` | Track of a switched-off toggle | To add with F10 |
| boss surface | `#3A2F73`, edge `#15103A` | Keypad and cards on the boss screen | To add with F6 |
| monster | `#8E78FF` | Boss body | To add with F6 |
| boss health | `#FF8A75` | Boss health bar fill | To add with F6 |
| mastery statuses | new `#E3DEF7`, to review `#E8604C`, in progress `#FFC531`, acquired `#A99BF0`, mastered `#4A2FD6` | Mastery grid cells | To add with F10 |
| avatar colors | `#5B3DF5`, `#137A4B`, `#FFC531`, `#D9482F`, `#1F6FD6`, `#B8328A` | Profile background choices (violet, green, yellow, red, blue, pink) | `AppPalette.avatarBackgrounds` |

Color never carries meaning alone: right and wrong answers also show a check
or a cross, mastery statuses also have a label.

### Typography

Both fonts are bundled as variable fonts in `assets/fonts/` (the app is
offline) and wired in `AppTextTheme`.

- **Fredoka**, weight 600 — display: titles, numbers, questions, button
  labels. Sizes used: 84 / 72 / 64 (big question and scores), 46, 36 (screen
  title, answer buttons), 32, 30, 28, 26, 24, 22, 20, 18.
- **Nunito**, weights 700 and 800 — body: descriptions, captions, pills.
  Sizes used: 18, 17, 16, 15, 14 (most common), 13, 12.

### Shape and spacing

- Spacing scale: 4, 8, 12, 16, 24 (`AppSizes.space*`). Screen gutter: 24
  (16 on dense screens).
- Radii: 14 small controls, 16–18 buttons, 20–24 cards, 999 pills
  (`AppSizes.radius*`).
- Borders: 2 px outline; the bottom edge is thicker (5–7 px) to give the
  raised "depth" look.
- Touch targets: 48 minimum, 56 for answer buttons (answer buttons in the
  mockups are 84 high).

## Components

| Component | Where | Status |
| --- | --- | --- |
| Depth button (primary violet, secondary white; later green, red, yellow) | every screen | `DepthButton` in `core/widgets/` — primary and secondary done |
| Card (white, radius 24) | every screen | `AppCard` |
| Progress bar (pill, violet or yellow fill) | quiz, results, profile | `AppProgressBar` |
| Pill (icon + short label) | streak, combo, records | `AppPill` |
| Round icon button with tooltip | back, close, settings | `AppIconButton` |
| Tab bar, 4 entries | shell | `AppTabBar` |
| Answer button (white, big number, turns green / red) | quiz | F3 |
| Numeric keypad (0–9, erase, validate) | typed answers, boss | F3 |
| Timer bar (yellow, empties, changes color in the last 3 s) | quiz | F3 |
| Segmented control | training, settings | F9 / F10 |
| Toggle row | settings | F10 |
| Path node (done with crown and stars, current, locked) | learning path | F5 |
| Stage row (done, current with "Jouer", locked) | table detail | F5 |
| Mastery grid cell | profile | F10 |
| Avatar (round face, 6 ear shapes x 2 mouths, any background color) | profiles, leaderboard, shop | F1 |
| Mascot (yellow character, 3 moods, 5 growth stages) | home, quiz, results, profile | F8 (simple static version from F1) |
| Monster (one-eyed violet boss; small colored monsters) | boss, my monsters | F6 / F13 |

Avatars, the mascot and the monsters are **provisional SVG drawings**. Build
them so final illustrations can replace them without touching the calling
code (one widget per character, driven by an id).
