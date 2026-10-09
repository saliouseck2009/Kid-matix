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
| Game-rule values (boss hit points, XP per answer, timer durations...) are named constants in the domain of the feature that owns them; they move to `core/constants/` only when a second feature needs them | The rules reserve `core/` for code used by at least two features |
| A new player's settings: normal timer, daily goal of 20 XP, sounds and vibrations on, reduced motion and "unlock everything" off | Owner chose 20 XP: reached in one short session, so a child succeeds on the first day; it can be raised in the settings (F10) |
| Crash reporting goes through the `CrashReporter` interface; 1.0 uses the local `LogCrashReporter` | The rules ask for Crashlytics or Sentry, but 1.0 has no network and no third-party SDK |
| No `app/` folder: router, theme, DI and shared widgets live in `core/` | Structure of the owner's rules |
| `DataState<T>` (`DataSuccess` / `DataFailed`) and typed `AppException` with an `AppErrorCode` replace the `Result` type of the first specs | Owner's rules |
| No `equatable`: entities write `==` and `hashCode` by hand, with `@immutable` and `copyWith` | Owner's rules |
| `uuid` stays out of `domain/`: ids come from the `IdGenerator` interface | `domain/` is pure Dart |
| `Clock`, `RandomSource` (seedable) and `Ticker` are injected interfaces | Reproducible tests; the challenge code (F19) needs a seeded draw |
| The active player is `ProfileSessionService`, an interface in `core/services/` implemented by the `profile` feature; the router listens to it (`refreshListenable`) and redirects to "Qui joue ?" | Features never import each other; guards belong in `redirect`. Replaces the `ActiveProfileCubit` of the first specs |
| Quiz engine contracts (`LearningDomain`, `QuestionType`, `Question`) live in `core/` | Quiz, learning path and challenges all use them |
| At the end of a session, mastery, learning path and rewards are notified through interfaces of `core/services/`, inside one database transaction | No feature-to-feature import; all-or-nothing write |
| The Results page receives only the session id and loads the session with its own Cubit | Only primitive ids go through routes |
| sqflite exposes no streams: repositories call `TableChangeBus.notifyChanged` after each write and Blocs reload on `watchTable` | Keeps the map, profile and leaderboard fresh |
| One migration class per schema version, run by `MigrationRunner`; the database opens lazily and only once a first migration exists (F1) | Rules: `version` + `onUpgrade`, one migration per version |
| Migrations live in `core/storage/migrations/` (`migration_NNN_xxx.dart`), with their SQL written out in full rather than built from the data layer's column constants | The schema version is global to the app, `core/` may not import features, and a released migration must never change when a constant is renamed later |
| Feature folders are not scaffolded ahead of time; each is created by its lot | No empty folders or dead code |
| Models use `json_serializable`; `tool/check.sh` runs `build_runner` only when `@JsonSerializable` appears in `lib/` | Keeps the check fast until F1 |
| `audioplayers` is added in F10, `flutter_local_notifications` in F18 — not before | No unused dependency |
| Fredoka and Nunito are bundled as variable fonts; weight is set through the `wght` axis | Offline app: no `google_fonts` download at runtime |
| An `i18n-guardian` subagent (`.claude/agents/`) audits every feature before its pull request: hard-coded user-facing strings, ARB descriptions, placeholders, plurals | Owner's request. Prepares the extra languages of F21 |
| Generated localizations live in `lib/l10n/` (`nullable-getter: false`), read with `context.l10n` | Texts only through `AppLocalizations` |
| One branch per task (`<type>/<slug>`, task id first), Conventional Commits, one GitHub pull request per task merged with a merge commit; no commit or push on `main`. Rules in `docs/git-workflow.md`, enforced by the hooks of `.githooks/` | Owner's request: each feature on its own branch, clean commits, pull requests. Local hooks because there is no CI yet |
| CI is GitHub Actions running `tool/check.sh` on Ubuntu with Flutter 3.47.6 (pinned in the workflow); with `CI=true` the script fails on unformatted code and on stale generated files instead of rewriting them. Generated code is committed | Owner's request. One script for local and CI keeps both identical; committed generated code builds without a generation step |
| Verification is one command: `bash tool/check.sh` (pub get, gen-l10n, build_runner if needed, format, analyze, test) | A lot is done only when every step is OK |

## Open points

Ask the owner when the lot that needs the answer starts.

| Point | Needed by |
| --- | --- |
| Final app name, icon and splash screen | F11-07 |
| Animation tool for the mascot: Rive, Lottie or hand-animated vector drawing | Start of F8 |
| Final illustrations for the mascot, the 12 monsters and the 12 avatars (current drawings are provisional) | Any time; code must not depend on the drawings |
| Screens not drawn yet (see `docs/design/README.md`) | F3, F4, F12, F14 |
| Which tables a guest without a profile gets in a duel | F14-02 |
| How coins are earned for the shop | F21-03 |
| List of additional languages | F21-01 |
| Unconfirmed defaults of section 16 of the specifications (table order, no profile code, Android and iOS released together...) | Treated as valid until the owner says otherwise |
| Online mode: backend choice, parental consent, leaderboard scope, anti-cheat | After 1.2 |
