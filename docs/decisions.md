# Decision log

Decisions taken with the project owner before and during lot F0, with the
reason for each. They are settled: do not reopen them without asking the
owner. Add a line here whenever a new decision is taken.

## Product

| Decision | Reason |
| --- | --- |
| Maths only; first domain is multiplication, tables 1 to 12 up to x10 (120 facts) | Owner's scope. Other subjects were removed from the specs |
| No upper age limit; multiplication targets ages 6 to 11 | Later maths domains will serve older children |
| Several local profiles on one phone, identified by a nickname; no password, no e-mail | Owner's requirement: siblings share a phone |
| No parent area, no secondary user, no parental configuration | Owner removed them explicitly. Reset and delete are confirmed by retyping the nickname |
| Version 1.0 is fully offline: no backend, no account, no network call, no third-party SDK that communicates | Ship the learning loop first. Online mode (accounts, sync, online leaderboards) comes after 1.2 |
| The data model is prepared for online mode: UUIDs generated on the device, `updated_at` and `deleted_at` on every row, quiz sessions kept as an append-only log, empty remote-account column on the profile | Add a remote source later without rewriting domain or UI |
| The quiz engine is generic (`LearningDomain`, `QuestionType`); multiplication is the first registered domain | New domains (division first) and new question types plug in without touching quiz, timer, mastery or rewards |
| "Attractiveness" features adopted: boss fight ending each table, growing mascot, "Mes monstres", same-phone duel, challenge by code, local leaderboard | Owner accepted these proposals |
| Scope: 1.0 = F0–F11, 1.1 = F12–F18, 1.2 = F19–F21 | See `docs/product/task-breakdown.md` |
| App name "Kid Matix" is provisional (project folder `kid_matix`) | "Mathimo" and "Numi" were proposed; the owner has not chosen. Final name is task F11-07 |
| UI language is French only at launch; every string is in `lib/l10n/app_fr.arb` | Other languages come with F21 |

## Technical

| Decision | Reason |
| --- | --- |
| Flutter, BLoC, feature-first Clean Architecture, GetIt, go_router | Owner's stack and rules (`docs/rules/`) |
| The owner's coding rules win over the specifications and the breakdown | Owner's instruction. The repo copies of both documents were aligned |
| `sqflite` for the database, `shared_preferences` for device settings — not drift, Isar or Hive | Owner's choice |
| Constants are `lowerCamelCase`; the `SCREAMING_SNAKE_CASE` rule of `dart-guidelines.md` is dropped | It contradicts the default Dart lint. Owner: "laisse tomber cette règle" |
| Constructors use initializing formals for private fields (`required this._repository`) | The `prefer_initializing_formals` lint of this SDK requires it, and `flutter analyze` must stay clean. The rule examples show the older `: _x = x` form; the lint wins. Callers still pass the public name |
| Use cases (and helpers such as `NicknameChecker`) are plain `class`es; entities, models, data sources and repositories stay `final` | Blocs are tested with mocktail doubles of their use cases, and a `final` class cannot be mocked outside its library |
| Game-rule values (boss hit points, XP per answer, timer durations...) are named constants in the domain of the feature that owns them; they move to `core/constants/` only when a second feature needs them | The rules reserve `core/` for code used by at least two features |
| A new player's settings: normal timer, daily goal of 20 XP, sounds and vibrations on, reduced motion and "unlock everything" off | Owner chose 20 XP: reached in one short session, so a child succeeds on the first day; it can be raised in the settings (F10) |
| Crash reporting goes through the `CrashReporter` interface; 1.0 uses the local `LogCrashReporter` | The rules ask for Crashlytics or Sentry, but 1.0 has no network and no third-party SDK |
| No `app/` folder: router, theme, DI and shared widgets live in `core/` | Structure of the owner's rules |
| `DataState<T>` (`DataSuccess` / `DataFailed`) and typed `AppException` with an `AppErrorCode` replace the `Result` type of the first specs | Owner's rules |
| No `equatable`: entities write `==` and `hashCode` by hand, with `@immutable` and `copyWith` | Owner's rules |
| `uuid` stays out of `domain/`: ids come from the `IdGenerator` interface | `domain/` is pure Dart |
| `Clock`, `RandomSource` (seedable) and `Ticker` are injected interfaces | Reproducible tests; the challenge code (F19) needs a seeded draw |
| The active player is `ProfileSessionService`, an interface in `core/services/` implemented by the `profile` feature; the router listens to it (`refreshListenable`) and redirects to "Qui joue ?" | Features never import each other; guards belong in `redirect`. Replaces the `ActiveProfileCubit` of the first specs |
| Navigation around the active player is driven by the session only: with no active player the router allows "Qui joue ?" and the creation (the creation directly when no profile exists); with one it leaves them for the home. Choosing a player, creating or deleting one notifies the `profile` table on the `TableChangeBus`, which reloads the session | No page navigates after a selection; the guard stays in `redirect`. "Qui joue ?" is one Bloc (`ProfilesBloc`: list and selection); the creation form gets its own Bloc with the "nickname taken" and "limit reached" errors (F1-11) |
| Until lot F10 draws the full Profile screen (mockup 12), the Profile tab shows the active player with "Modifier mon profil" (the creation form, filled), "Changer de joueur" (forgets the active player, no data lost) and "Supprimer ce joueur" (the child types the nickname again, compared ignoring case and accents) | Owner's choice: the specifications put these actions in the Profile tab, and lot F1 must let three players be created and switched. F10 grows the tab around them |
| Quiz engine contracts (`LearningDomain`, `QuestionType`, `Question`) live in `core/` | Quiz, learning path and challenges all use them |
| The quiz engine contracts live in `core/quiz/`, pure Dart, listed by the architecture test among the folders a domain layer may import. A question prompt is a list of tokens (number, operator, equals, blank), never a sentence | Several features build or read questions; tokens keep every language-specific word out of the domain, the quiz screen renders them |
| At the end of a session, mastery, learning path and rewards are notified through interfaces of `core/services/`, inside one database transaction | No feature-to-feature import; all-or-nothing write |
| The Results page receives only the session id and loads the session with its own Cubit | Only primitive ids go through routes |
| A missed fact comes back 3 questions later (at the end when fewer are left), once per session, as a new question of an allowed type; this second chance does not count in the score. The per-question timer of free training lasts 10 s (15 s relaxed). A quiz left before its first answer saves nothing; otherwise it is saved as `abandoned` with its answers | Owner's choices for the second chance and the 10 s; a session is a journal entry, and an empty one has nothing to keep |
| Spaced repetition counts in days: an item answered at any time of the day is due from the start of the day its box names (box 1 the next day, then 2, 4, 7, 15 days). The second chance of a fact missed in the same quiz updates its statistics but never moves it up a box, so the fact still comes back the next day. "Maîtrisé" needs 5 recorded answer times with a median under 3 s; box 5 without it shows "Acquis" | A child playing in the evening finds yesterday's facts in the morning; the specifications say box 1 comes back "later in the session, then the next day" |
| Box 1 holds only the items to review: a new item answered right the first time goes straight to box 2 ("En cours"), a missed one to box 1. A quiz first asks once every item of box 1 among its items, then draws the rest; the order is shuffled | The lot's "done when": missed facts come back first at the next session. With box 0 → 1 on a right answer, a missed fact and a known one would be drawn alike. To confirm with the owner |
| The weighted draw takes items with replacement. An item's weight is its box weight (box 0 to 5: 4, 5, 4, 3, 2, 1) times its domain weight; multiplication gives the facts x 1 and x 10 half weight, except in the tables of 1 and 10 where they are the subject. Items of boxes 0 to 2 are asked with answers to pick (multiple choice, true or false), from box 3 with answers to write (keypad, missing number), falling back to every allowed type when none fits | Low boxes come out more often, and a picked answer cannot move a fact past box 3 anyway. The weights are tuning values, named in `QuizItemPlanner` |
| The help card (no mockup) is derived from the quiz screen: from the second mistake on a fact in a quiz, the white question card gives way, during the feedback, to "Fiche d'aide · Table de 7" with the 10 facts of the table, the missed one highlighted, and a grid of 7 rows of 8 dots with its caption. After every mistake on a fact that has a mirror, the red message adds "Retiens aussi : 8 × 7 = 56". The domain provides both (`LearningDomain.helpOf`, `mirrorOf`) | The breakdown asks to derive undrawn screens from the existing ones; the texts wait for the owner's confirmation |
| The review stage (15 questions after every group of 3 tables) is an optional node of the map: it opens once the 3rd table of its group has its stage 3 validated, earns stars, and never locks the next table. It draws its questions with the mastery engine among every table seen so far, all formats, no timer | Owner's choice |
| Stage 5 (boss) opens once stage 4 has a star, like every stage; the next table already opens with stage 3. The defeated monsters are the tables crowned on the path (`LearningPathEntity.defeatedBosses`), read from `stage_progress` without a new table | Owner's choice in F5 (locked until F6), opened by lot F6 |
| The 12 table tips of the Discovery stage are proposed by Claude in `app_fr.arb` and listed for the owner to validate | Owner's choice; the specifications give only the tip of the table of 5 |
| A stage quiz is a `QuizSpec` (core): its items, order (in order, shuffled or drawn by mastery), formats, timer and an opaque source key `path:mul:5:training` stored with the session. Discovery asks the 10 facts in order, training, writing and speed shuffle them once each; the player's timer mode applies to the speed stage | The quiz never knows stages; the learning path finds its stage from the session |
| On the map, the current table is the first open table whose stage 3 has no star (the last table once all are done); tables open by "Tout débloquer" and not started show as open; "Tout débloquer" also opens every stage except the boss | Mockup 03 shows done, current and locked tables |
| The end of a session reaches the other features through `SessionSavedHook`s (`core/storage/`): each feature adds its hook at startup, and the quiz runs them inside the transaction that saves the session, so the session and the stars of its stage are written all or nothing. The hooks return the tables they wrote, notified once the transaction is committed. The results screen reads the stars through `LearningPathService` (`core/services/`) | Replaces the transaction-wide interface planned in the breakdown: a transaction cannot cross a pure domain layer, while a data-layer hook can share it |
| The boss fight asks every format (owner's choice), on the dark screen of mockup 08. It runs in the quiz: 12 hit points, a right answer takes 1, a lightning one 2, a mistake costs nothing and the fact comes back 3 questions later as a scored question; the fight ends when the boss falls or after 20 questions (it flees). Every answer of a fight counts in its score | Specifications section 7; the second chance counts here because the fight is limited to 20 questions |
| A boss fight asks the 10 facts of its table shuffled, then up to 10 distinct facts drawn by the mastery engine among the tables already seen, or among the facts of the table itself for the first table of the path; 8 seconds each | Owner's choice for the first table: 10 facts alone cannot take 12 hit points without critical hits |
| Defeating the boss earns at least 1 star and the crown; a boss that flees earns 0 star. Otherwise the stars follow the usual 60 / 80 / 100 % of the questions played. The session stores `boss_outcome` (schema version 6) | Owner's choice: with critical hits a child can win with less than 60 % |
| The 12 monsters are provisional variants of the one-eyed boss of the design (color, horns, eyes, mouth), drawn by one widget driven by the table number | Owner's choice; the final illustrations replace them without touching the calling code |
| The boss fight screen is the quiz screen under a dark theme (`AppTheme.boss`): the answer buttons, the keypad and the feedback keep their widgets. The blow animations (hit, critical hit, strike back, defeat, flight) follow the system's reduced motion setting until the player setting of lot F10 exists | One quiz screen to maintain; mockup 08 |
| Levels: going from level N to N + 1 takes 100 × N XP (level 2 at 100 XP, 3 at 300, 4 at 600, 5 at 1,000) | Owner's choice |
| The +20 XP of a completed quiz and the +50 of a perfect one apply to every completed quiz (stages, free training, challenges); an abandoned quiz earns no XP. The Premier pas and Sans-faute badges stay tied to the stages of the learning path. `XpPolicy` carries a version number | Owner's choice; specifications section 8 for the abandoned quiz |
| The streak counts days by the phone's clock; a date that goes back changes nothing. One joker per week, from Monday to Sunday, saves the streak after a single missed day, used automatically and never stored up. The streak shown is 0 once it can no longer go on today; the best streak is kept | Owner's choice for the week |
| Badge keys are stable strings (`firstStep`, `perfect`, `lightning`, `regular`, `allFacts`, `tamer:mul:7`); a badge is unlocked once and kept | Stored with each unlock |
| A `SessionSavedHook` prepares before the transaction (reads through the services of other features) and returns the write to run inside it: reading the database while the transaction is open would wait forever | Lot F7: the rewards need the mastered facts and the stage of the quiz |
| The rewards keep their own data (schema version 7): `session_reward` (XP of each completed quiz, with the version of the XP rules), `streak`, `badge_unlock` (with the session that unlocked it) and `reward_stats` (lightning answers counted). The total XP is the sum of `session_reward`; the hook also copies the total and the level into the `profile` row, in the same transaction, for the profile screens. The daily goal sums the XP of the quizzes ended today | One source of truth for the XP; the profile columns of F1 stay in step |
| Only a completed quiz counts for the streak, the lightning counter and the badges | Same rule as the XP: an abandoned quiz earns nothing |
| Screens of one feature show widgets of another through slots filled by the router: the results take the XP tile, the level card and the rewards scope of the rewards; the map takes the player badge of the profile, the streak pill and the daily goal of the rewards; the cards of "Qui joue ?" take the streak pill | No feature imports another; each widget keeps its own Cubit |
| A new level and each new badge open a full-screen celebration over the results, closed by one tap; the end of a stage is celebrated by the results screen itself. The combo pill shows from 2 right answers in a row; "Combo de 3 / 5 / 10 !" replaces "Éclair !" at its milestones | Specifications section 7 ; texts to confirm with the owner |
| sqflite exposes no streams: repositories call `TableChangeBus.notifyChanged` after each write and Blocs reload on `watchTable` | Keeps the map, profile and leaderboard fresh |
| One migration class per schema version, run by `MigrationRunner`; the database opens lazily and only once a first migration exists (F1) | Rules: `version` + `onUpgrade`, one migration per version |
| Migrations live in `core/storage/migrations/` (`migration_NNN_xxx.dart`), with their SQL written out in full rather than built from the data layer's column constants | The schema version is global to the app, `core/` may not import features, and a released migration must never change when a constant is renamed later |
| Feature folders are not scaffolded ahead of time; each is created by its lot | No empty folders or dead code |
| Models use `json_serializable`; `tool/check.sh` runs `build_runner` only when `@JsonSerializable` appears in `lib/` | Keeps the check fast until F1 |
| `audioplayers` is added in F10, `flutter_local_notifications` in F18 — not before | No unused dependency |
| Fredoka and Nunito are bundled as variable fonts; weight is set through the `wght` axis | Offline app: no `google_fonts` download at runtime |
| An `i18n-guardian` subagent (`.claude/agents/`) audits every feature before its pull request: hard-coded user-facing strings, ARB descriptions, placeholders, plurals | Owner's request. Prepares the extra languages of F21 |
| Generated localizations live in `lib/l10n/` (`nullable-getter: false`), read with `context.l10n` | Texts only through `AppLocalizations` |
| French typography in user-facing texts: a no-break space (U+00A0) before `? ! : ;`, inside « » and between a number and its unit (`2,4 s`), straight apostrophe `'` | Owner. The sign never starts a line on its own; the apostrophe matches the mockups. Checked by the `i18n-guardian` agent |
| "Bientôt disponible" stays as the placeholder text of tabs not built yet | Owner. Each lot replaces its tab |
| One branch per task (`<type>/<slug>`, task id first), Conventional Commits, one GitHub pull request per task merged with a merge commit; no commit or push on `main`. Rules in `docs/git-workflow.md`, enforced by the hooks of `.githooks/` | Owner's request: each feature on its own branch, clean commits, pull requests. Local hooks keep mistakes from reaching the remote at all |
| CI is GitHub Actions with four parallel jobs — analyze, test (with coverage), debug Android build on Ubuntu, debug iOS build without signing on macOS — each running one group of `tool/check.sh` with Flutter 3.47.6 (pinned in the workflow); with `CI=true` the script fails on unformatted code and on stale generated files instead of rewriting them. Generated code is committed | Owner's request. One script for local and CI keeps both identical; committed generated code builds without a generation step |
| The launcher name is "Kid Matix" on Android and iOS until the final name is chosen (F11-07) | Owner. Android showed the package name `kid_matix` |
| Verification is one command: `bash tool/check.sh` (pub get, gen-l10n, build_runner if needed, format, analyze, test) | A lot is done only when every step is OK |

## Open points

Ask the owner when the lot that needs the answer starts.

| Point | Needed by |
| --- | --- |
| Final app name, icon and splash screen | F11-07 |
| Animation tool for the mascot: Rive, Lottie or hand-animated vector drawing | Start of F8 |
| Final illustrations for the mascot, the 12 monsters and the 12 avatars (current drawings are provisional) | Any time; code must not depend on the drawings |
| Screens not drawn yet (see `docs/design/README.md`) | F4, F12, F14 |
| Which tables a guest without a profile gets in a duel | F14-02 |
| How coins are earned for the shop | F21-03 |
| List of additional languages | F21-01 |
| Unconfirmed defaults of section 16 of the specifications (table order, no profile code, Android and iOS released together...) | Treated as valid until the owner says otherwise |
| Online mode: backend choice, parental consent, leaderboard scope, anti-cheat | After 1.2 |
