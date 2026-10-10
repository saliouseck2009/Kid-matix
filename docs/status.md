# Project status

Update this file at the end of every lot (and whenever work stops in the
middle of one). Last update: 2026-10-10.

## Where we are

| Lot | State |
| --- | --- |
| F0 · Foundation | **Done** (closed 2026-10-09) |
| F1 · Profiles ("Qui joue ?") | **Done** (closed 2026-10-09) |
| F2 · Quiz engine and multiplication domain | **Done** (closed 2026-10-09) |
| F3 · Quiz session and results | **Done** (closed 2026-10-10) |
| F4 · Mastery and spaced repetition | **Next** |
| F5 – F21 | Not started |

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

## F3 closure

- `bash tool/check.sh`: every step OK (279 tests); CI green on #22 to #25.
- Checked on the Android emulator (API 36, release build), the lot's
  "done when" included: from the provisional "Jouer à la table de 5"
  button, 10 questions of the table of 5 in the four formats (multiple
  choice, true or false, keypad, missing number) with the timer; a fact
  missed in question 1 came back in question 4 and was not scored; the
  results showed 9 / 10, the average time and the fact to review. The
  database upgraded from version 1 to 2 and kept the players.
- The accessibility tree reads the prompt as a sentence ("5 fois 7 égale
  combien").

Known gaps left on purpose, to handle in the lot named:

- The home tab shows a provisional "Jouer à la table de 5" button
  (`ProvisionalQuizLauncherPage`); F5 replaces it with the learning path.
- The quiz draws its facts at random from one table; F4 brings the
  weighted draw and the format chosen by the box.
- The stars of the results arrive with F5, the XP and the level with F7.
- Cold start takes 3.5 to 5 s on the emulator, even in release; to measure
  on a real phone (SM A166P).
- Texts proposed without a mockup, waiting for the owner's confirmation:
  "Temps écoulé !", "Éclair !", the quit dialog, "Partie terminée !",
  "Aucune erreur, bravo !", "Jouer à la table de 5".

## What F3 delivered

- `features/quiz/`: the session entities (`QuizRun`, `QuizTurn`,
  `QuizAnswerEntity`, `QuizSessionEntity`, `QuizResultEntity`), the use
  cases `BuildQuiz`, `SubmitAnswer` (lightning under 3 s, second chance 3
  questions later), `CompleteSession`, `AbandonSession`, `GetTimeLimit`,
  `GetQuizResult`, the `quiz_session` and `quiz_answer` journal,
  `QuizBloc` driven by the `Ticker`, `ResultsCubit`, the quiz and results
  screens, the keypad, the quit confirmation, `QuizPages` for the router,
  `registerQuizFeature()`.
- `core/storage/migrations/migration_002_create_quiz_session_tables.dart`.
- `core/services/player_settings_service.dart`: the quiz reads the timer
  mode of the active player; implemented by the profile feature.
- `core/entities/timer_mode.dart`, `core/storage/sqlite_bool_converter.dart`,
  the mascot drawing and the dashed border moved to `core/widgets/`.
- Theme: `AppFeedbackPalette` (right and wrong colors), success and danger
  `DepthButton` variants.
- Routes `/quiz/:unitKey` and `/results/:sessionId`.

## Starting F4

Tasks F4-01 to F4-15 in `docs/product/task-breakdown.md`; rules in section
6 of `docs/product/specifications.md`. The help card (F4-11) has no
mockup: it is derived from the existing screens.

- `features/mastery/` is created: `ItemProgress`, `MasteryPolicy`, the
  `item_progress` migration (version 3), the due facts and the mastery
  grid.
- Each answer updates the progress of its fact as soon as it is given, so
  an abandoned quiz loses nothing. The quiz reaches mastery through an
  interface of `core/services/`, never by importing it.
- The quiz uses the weighted draw and the format chosen by the box.
