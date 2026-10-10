# Project status

Update this file at the end of every lot (and whenever work stops in the
middle of one). Last update: 2026-10-09.

## Where we are

| Lot | State |
| --- | --- |
| F0 · Foundation | **Done** (closed 2026-10-09) |
| F1 · Profiles ("Qui joue ?") | **Done** (closed 2026-10-09) |
| F2 · Quiz engine and multiplication domain | **Done** (closed 2026-10-09) |
| F3 · Quiz session and results | **Next** |
| F4 – F21 | Not started |

Environment used so far: Flutter 3.47.6, Dart 3.13.5, macOS. CI
(`.github/workflows/ci.yml`) pins the same Flutter version.

## Git

Every change goes through its own branch, Conventional Commits and a GitHub
pull request merged with a merge commit — rules in `docs/git-workflow.md`,
enforced by `.githooks/`. On a new clone, `bash tool/setup.sh` installs the
hooks (`git config core.hooksPath .githooks`). `main` is on `origin`
(github.com/saliouseck2009/Kid-matix).

## F0 closure

- `bash tool/check.sh`: every step OK (format, analyze, 22 tests, git hook
  tests).
- Checked on the Android emulator (API 36): lavender ground, page title and
  "Bientôt disponible" in the middle, white tab bar with four tabs, the
  selected one highlighted; tapping "Défis" switches the page and the
  highlight.

## F1 closure

- `bash tool/check.sh`: every step OK (166 tests, git hook tests); CI green
  on every pull request (analyze, test, build android, build ios).
- Checked on the Android emulator (API 36), the lot's "done when" included:
  first launch opens the creation; three players created; one chosen; app
  killed and relaunched on the same player; rename from the Profile tab;
  deletion after retyping the nickname, back to "Qui joue ?".
- Coverage of `features/profile`: 98 % on `domain/` and on `data/`.

Known gaps left on purpose, to handle in the lot named:

- Portrait is locked at runtime only (`SystemChrome` in `main.dart`).
  `ios/Runner/Info.plist` and `AndroidManifest.xml` still allow landscape —
  restrict them by F11 at the latest.
- The Profile tab is the minimal F1 version (player, edit, switch, delete);
  F10 builds the full screen of mockup 12 around it.
- The streak pill of the player cards arrives with F7-15.
- The mascot of "Qui joue ?" is a static drawing in the profile feature;
  F8 replaces it with the growing mascot.
- The tabs Parcours, S'entraîner and Défis still show `ComingSoonPage`.
- Texts proposed without a mockup, waiting for the owner's confirmation:
  the nickname errors, the storage and generic errors, "Enregistrer",
  "Supprimer Awa ?", the deletion message and "Annuler".

## What F0 delivered

- `lib/core/error/` — `DataState<T>`, `AppException` hierarchy, `AppErrorCode`.
- `lib/core/usecases/` — `UseCase<Output, Input>`, `NoParamUseCase<Output>`.
- `lib/core/services/` — `Clock`, `RandomSource`, `Ticker`, `IdGenerator`,
  `CrashReporter` and their default implementations.
- `lib/core/storage/` — `AppDatabase` (lazy open, foreign keys on),
  `DatabaseMigration`, `MigrationRunner`, `appMigrations`, `CommonColumns`
  (`updated_at`, `deleted_at`), `TableChangeBus`, `LocalStorage` over
  `SharedPreferencesAsync`.
- `lib/core/di/injection_container.dart` — `sl`, `configureDependencies()`.
- `lib/core/router/` — `AppRoutes`, `createAppRouter()` (four-branch
  `StatefulShellRoute.indexedStack`), `AppShell`.
- `lib/core/theme/` — `AppColors`, `AppPalette`, `AppTextTheme`, `AppTheme`.
- `lib/core/widgets/` — `DepthButton`, `AppCard`, `AppProgressBar`, `AppPill`,
  `AppIconButton`, `AppTabBar`, `ComingSoonPage`.
- `lib/core/extensions/` — `context.l10n`, `context.palette`.
- `lib/core/utils/app_bloc_observer.dart`, `lib/main.dart`.
- `lib/l10n/app_fr.arb` and generated `AppLocalizations`.
- Tests: architecture rules, `DataState`, migrations on an in-memory
  database, `TableChangeBus`, seeded random source, `DepthButton`, app shell.
- `tool/setup.sh`, `tool/check.sh`, `analysis_options.yaml`.

## What F1 delivered

- `features/profile/`: entities (`ProfileEntity`, `ProfileSettingsEntity`,
  `NicknameRules`), repository and its use cases, sqflite and preferences
  data sources, `ProfilesBloc`, `ProfileCreationCubit`, `ProfileEditCubit`,
  `ProfileTabCubit`, the pages "Qui joue ?", creation, edit and the Profile
  tab, the 12 avatars (`ProfileAvatarPainter`), `ProfilePages` for the
  router, `registerProfileFeature()`.
- `core/storage/migrations/migration_001_create_profile_tables.dart`: the
  database now opens.
- `core/services/profile_session_service.dart` and
  `core/router/profile_session_redirect.dart`: the router guards the app
  with the active player.
- `core/error`: `AppErrorCode.limitReached` and `LimitReachedException`.
- Theme: avatar colors, `secondaryDepth`, `strongBorder`.

## F2 closure

- `bash tool/check.sh`: every step OK (190 tests); CI green on #18, #19 and
  #20.
- "Done when" checked: all tests pass and `core/quiz` and
  `features/multiplication` import no Flutter package.
- No screen in this lot, so no device check.

## What F2 delivered

- `core/quiz/`: `LearningDomain`, `LearningUnit`, `LearningItem`,
  `QuestionType` and `AnswerNature`, `Question` with a prompt made of
  tokens, `Answer` (number or true/false), `DomainRegistry`,
  `QuestionTypeRegistry`, `QuestionGenerator`, and the four question types
  of version 1.0 in `question_types/`.
- `features/multiplication/`: `MultiplicationFact` (key `mul:7x8`),
  `MultiplicationTable` (key `mul:7`), `MultiplicationTip`,
  `DistractorGenerator`, `MultiplicationDomain`, and
  `registerMultiplicationFeature()`.
- The app registers the question types and the domain at startup.
- Left for lot F5: the wording of the 12 table tips (the domain only names
  them; the specifications give one example, for the table of 5).

## Starting F3

Tasks F3-01 to F3-18 in `docs/product/task-breakdown.md`; rules in sections
5, 7 and 9 of `docs/product/specifications.md`; mockups `06`, `06b`, `06c`,
`07` and `09` in `docs/design/screens/`. The keypad of the typed answer and
the missing-number answer zone have no mockup: they are derived from the
existing screens.

- `features/quiz/` is created: session entity, use cases, the
  `quiz_session` migration (version 2), `QuizBloc` driven by the injected
  `Ticker`, the quiz and results screens.
- The quiz builds its questions with `QuestionGenerator` and the
  registries; it never imports `features/multiplication`.
- The timer mode comes from the player's `ProfileSettingsEntity`, owned by
  the profile feature: the quiz reads it through an interface of
  `core/services/`.
- The streak, XP and stars of the mockups arrive with F5 and F7.
