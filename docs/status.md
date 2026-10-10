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
| F4 · Mastery and spaced repetition | **Done** (closed 2026-10-10) |
| F5 · Learning path | **Done** (closed 2026-10-10) |
| F6 · Boss fight | **Done** (closed 2026-10-10) |
| F7 · Rewards | **Done** (closed 2026-10-10) |
| F8 · Growing mascot | **Done** (closed 2026-10-10) |
| F9 · Free training and Against the clock | **Done** (closed 2026-10-10) |
| F10 · Profile and settings | **Next** |
| F11 – F21 | Not started |

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

## F4 closure

- `bash tool/check.sh`: every step OK (355 tests); CI green on #27 to #32.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: installed over the F3 version, the database upgraded from
  version 2 to 3 and kept the players. Three quizzes on the table of 5:
  the boxes moved (a new fact answered right to box 2, picked answers
  capped at box 3, a fact reached box 5 through typed answers); the facts
  missed in the second quiz (5 x 8, 5 x 2) came back in the third. The
  mirror reminder showed after each mistake and the help card from the
  second mistake on a fact.

Known gaps left on purpose, to handle in the lot named:

- `GetDueFactsUseCase` and `GetMasteryGridUseCase` have no screen yet:
  the daily review comes with F12, the mastery grid with F10 (mockup 12).
- The second chance in a quiz is drawn among every allowed type, not by
  box.
- Waiting for the owner's confirmation: box 1 kept for missed facts (a
  new fact answered right goes to box 2) and missed facts asked first;
  the draw weights; the texts "Retiens aussi : 8 × 7 = 56", "Fiche
  d'aide · Table de 7", "7 rangées de 8 points" and the help card layout
  (no mockup).

## What F4 delivered

- `features/mastery/`: `ItemProgressEntity`, `MasteryPolicy` (boxes,
  review days, status), `QuizItemPlanner` (missed facts first, weighted
  draw, format by box), the `item_progress` repository, the use cases
  `RecordAnswer`, `PlanQuiz`, `GetDueFacts`, `GetMasteryGrid`, and
  `registerMasteryFeature()`.
- `core/services/mastery_service.dart` with `ItemAnswer`,
  `QuizPlanRequest` and `QuizItemPlan` in `core/quiz/`: the quiz plans its
  questions and records each answer through it.
- `core/storage/migrations/migration_003_create_item_progress_table.dart`.
- `LearningDomain` gained `drawWeightOf`, `mirrorOf` and `helpOf`
  (`ItemHelp`, `DotGrid`); `QuestionGenerator.generatePlanned`.
- Quiz: `questionCount` on the request (free training: 10 questions),
  answers recorded at once, `QuizHelpCard`, the mirror reminder.

## F5 closure

- `bash tool/check.sh`: every step OK (419 tests); CI green on #34 to #37.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: installed over the F4 version, the database upgraded from
  version 3 to 5. A player without path progress played stages 1 to 3 of
  the table of 1 (Discovery showed the table and its tip first, 3 stars
  each); "Continuer" brought back the table detail with the Speed stage
  highlighted; the map showed the table of 2 open and current. Fixed on
  the way: the Android back button closed the app from the table detail.

Known gaps left on purpose, to handle in the lot named:

- The header band of the map (player, streak, crowns, daily goal) arrives
  with F7; the crowns on the map with F6.
- Stage 5 (boss) stays locked with "Bientôt disponible" until F6.
- The review node has no mockup: a small yellow round node.
- Waiting for the owner's confirmation: the 12 table tips, the stars
  under a table on the map (average of the stages played), and whether
  the equations of the tips need no-break spaces.

## What F5 delivered

- `features/learning_path/`: `StageKind`, `StageDefinition`,
  `StageSource` (source key `path:mul:5:training`), `StarPolicy`,
  `LearningPathBuilder` (unlocking, reviews, boss coming soon, "Tout
  débloquer"), `StageQuizSpecs`, `GetLearningPath`, the `stage_progress`
  storage written by `StageProgressSessionHook`, `LearningPathService`,
  `LearningPathBloc`, the map, the table detail and the Discovery page,
  `LearningPathPages`.
- `core/quiz/`: `QuizSpec`, `QuizSelection`, `QuizMode` (moved, `path`).
- `core/storage/`: `SessionSavedHook`s run inside the transaction saving
  a session; migrations 4 (`quiz_session.source_key`) and 5
  (`stage_progress`).
- `core/services/learning_path_service.dart`; `PlayerSettingsService`
  reads "Tout débloquer".
- `core/router/play_routes.dart`: `/table/:unitKey`, `/view`,
  `/discovery`, `/play/:sourceKey`; the provisional quiz button is gone.
- Results: "Étape terminée !", stage name and stars; "Continuer" goes
  back to the table detail.
- Core widgets: `StarRow`, `BackToParent`; locked colors in the palette;
  `PromptReading` moved to `core/extensions/`.

## F6 closure

- `bash tool/check.sh`: every step OK (440 tests); CI green on #39 to #41.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: the database upgraded to version 6; on the table of 1 the
  Speed stage then the boss were played; the boss was defeated (12 right
  answers out of 13, outcome `defeated`, 2 stars), the map showed the
  crown on the table of 1 ("Table de 1, terminée, 2 étoiles, couronne"),
  and the table joined the defeated monsters. The fight screen matches
  mockup 08.

Known gaps left on purpose, to handle in the lot named:

- The collection of defeated monsters has no screen yet
  (`LearningPathEntity.defeatedBosses`): the Profile screen (F10) and "Mes
  monstres" (F13) show it.
- The blow animations follow the system's reduced motion; the player
  setting comes with F10.
- The 12 monsters are provisional drawings.
- Texts proposed without a mockup, waiting for the owner: "Touché ! −1",
  "Riposte !", "Vaincu !", "Il s'enfuit !", "Boss vaincu !", "Le monstre
  s'est enfui"; still from F5: the 12 table tips.

## What F6 delivered

- Quiz: `BossFight` (12 hit points, critical hit, flight after 20
  questions), `BossOutcome`, follow-up questions drawn by the mastery
  engine, boss mode of `QuizBloc` (`bossBlow`), the boss fight screen
  (`BossHeader`, `BossArena`, `BossMonster`), boss result titles.
- `core/storage/migrations/migration_006_add_quiz_session_boss_outcome.dart`.
- Learning path: stage 5 opens, boss quiz spec, `StarPolicy.starsForStage`
  (a defeated boss earns at least 1 star), `TableCrown` and the crowns on
  the map, `defeatedBosses`.
- `MasteryService.readMasteredItems` for the golden crown.
- Theme: `AppTheme.boss`; core widgets `MonsterIllustration`, `CrownMark`.

## F7 closure

- `bash tool/check.sh`: every step OK (491 tests); CI green on #43 to #45.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: the database upgraded to version 7; the Discovery stage of
  the table of 2 completed at 10 / 10 opened the celebrations "Niveau 2 !",
  "Premier pas" and "Sans-faute"; the results showed +175 XP and the level
  card; the map header showed the player at level 2, a 1-day streak,
  1 crown and the daily goal at 175 / 20 XP. Fixed there: the scroll to
  the current table hid the header, which now stays above the map.

Known gaps left on purpose, to handle in the lot named:

- The Sprinter badge comes with F9, Survivant with F12.
- The badges have no screen of their own yet: the Profile screen (F10)
  lists them.
- The mascot of the results and celebrations is the static drawing; F8
  makes it grow.
- Waiting for the owner: the celebration texts, the badge hints,
  "Touche l'écran pour continuer", "Combo de 3 !", "Pas de série"; still
  the 12 table tips, the boss texts and the no-break spaces in the tips.

## What F7 delivered

- `features/reward/`: `XpPolicy` (version 1), `LevelPolicy`,
  `StreakPolicy` with its weekly joker, `BadgeEvaluator` and `BadgeKey`,
  `SessionRewardCalculator`, the reward storage written by
  `RewardSessionHook`, the use cases `GetStreak`, `GetBadges`,
  `GetPlayerLevel`, `GetDailyGoal`, `GetSessionRewards`,
  `WatchRewardChanges`, the reward widgets and celebrations, `RewardPages`.
- `core/storage/`: hooks prepare before the session transaction; migration
  7 (`session_reward`, `streak`, `badge_unlock`, `reward_stats`).
- `LearningPathService.isStage` / `crownedUnitOf`,
  `PlayerSettingsService.readDailyGoalXp`.
- Quiz: `QuizCombo`, the combo pill and its milestones; results slots for
  the rewards. Map header (player, streak, crowns, daily goal); streak on
  the cards of "Qui joue ?".

## F8 closure

- `bash tool/check.sh`: every step OK (532 tests); CI green on #47 to #49.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: the database upgraded to version 8; Awa played the table of 2
  with its boss and the Discovery of the table of 10 and went from level
  2 to level 5; back on the map, "Lim a grandi ! · Stade 2 sur 5" showed
  and the mascot grew ears; on the mascot screen the cap earned with the
  first crown was put on, stored (`mascot` row) and worn on every screen.
  Fixed there: a stage reached during a quiz was never celebrated; the
  map now checks it as soon as it shows.

Known gaps left on purpose, to handle in the lot named:

- The 5 stages and the 15 accessories are provisional drawings.
- The mascot screen has no mockup; F10 builds the full Profile screen
  around the mascot card.
- Waiting for the owner: the mascot messages, "Lim a grandi !", the names
  of the 15 accessories and their screen-reader texts; still the 12 table
  tips, the boss and reward texts and the no-break spaces in the tips.

## What F8 delivered

- `features/mascot/`: `MascotRules` (stages at levels 1, 5, 10, 20, 30;
  name "Lim", 12 characters at most), the `mascot` storage, the use cases
  `GetMascot`, `UpdateMascot` (name, accessory worn, stage celebrated),
  `WatchMascotChanges`, `MascotCubit`, the mascot card of the Profile
  tab, the mascot screen, the map mascot with the daily goal reminder,
  the growth celebration, `MascotPages`.
- `core/entities/`: `MascotAccessory` (catalog of 15), `AccessorySlot`,
  `MascotLook`, `MascotMood`.
- `core/widgets/`: `MascotPainter` (5 stages, 3 moods),
  `MascotAccessoryPainter`, `MascotIllustration`, `MascotLookScope`,
  `SpeechBubble`.
- `core/services/`: `CrownService` (learning path) and `RewardService`
  (reward): the mascot reads the crowns, the level and the badges.
- `core/storage/migrations/migration_008_create_mascot_table.dart`.
- Quiz: the mascot reacts to each answer and to the combo milestones.

## F9 closure

- `bash tool/check.sh`: every step OK (582 tests); CI green on #51 to #54.
- Checked on the Android emulator (API 36, release build), the lot's
  "done when" included: a free training on the tables of 2 and 5
  (10 / 10, "Continuer" back to the training tab with the choice kept);
  a first time attack at 5 right answers ("Ton premier record", the card
  shows "Record 5"), then a second at 14 ("Ancien record : 5"). The
  replaced question and the end at 60 seconds are covered by Bloc tests
  with a fake ticker.

Known gaps left on purpose, to handle in the lot named:

- The other challenges of the Défis screen (daily review, survival,
  monsters, duel, code) come with F12 to F19.
- Training and time attack have no "Défier un ami" yet (F19).
- Waiting for the owner: the time attack quiz screen and the new record
  card (no mockup), "Choisis au moins une table", the Sprinter hint and
  the capital of "Contre-la-montre" inside a sentence; still the texts
  of the earlier lots.

## What F9 delivered

- Quiz: a total time on the spec (`totalTimeLimit`): the Bloc counts the
  played time during the feedback too, goes on by itself, replaces the
  question shown after the background, ends and saves when the time is
  up; every answer counts, no second chance. `ClockHeader` (time bar,
  live score). `keepsTimer`: the timer chosen for a quiz wins over the
  setting "off".
- `core/`: `QuizMode.timeAttack`, `SavedQuizSession.mode`,
  `OpenUnitsService` (implemented by the learning path); migration 9
  (`record`).
- `features/challenge/`: `TrainingSource` and `TimeAttackSource` (source
  keys), `ChallengeRules`, `ChallengeQuizSpecs`, `RecordEntity`,
  `RecordPolicy`, `RecordSessionHook`, the last training kept in the
  preferences, the use cases, the training and challenges tabs, the new
  record card of the results, `ChallengePages`.
- Rewards: the Sprinter badge.
- `ComingSoonPage` is gone: every tab has its screen.

## Starting F10

Tasks F10-01 to F10-12 in `docs/product/task-breakdown.md`; mockups `12`
(profile) and `13` (settings).

- The Profile tab today is the F1 version plus the mascot card; F10
  builds mockup 12 around it: level, streak, crowns, badges, mastery
  grid (`GetMasteryGridUseCase` of F4), defeated monsters
  (`LearningPathEntity.defeatedBosses`).
- `features/setting/` is created: sounds, vibrations, timer mode, daily
  goal, "Tout débloquer", reduced motion; `audioplayers` is added.
