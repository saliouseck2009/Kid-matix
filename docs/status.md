# Project status

Update this file at the end of every lot (and whenever work stops in the
middle of one). Last update: 2026-10-18.

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
| F10 · Profile and settings | **Done** (closed 2026-10-10) |
| F11 · Polish and release of 1.0 | **Done** (closed 2026-10-12), except F11-11: builds in the test channels |
| F12 · Daily review and Survival | **Done** (closed 2026-10-12) |
| F13 · My monsters | **Done** (closed 2026-10-12) |
| F14 · Duel on one phone | **Done** (closed 2026-10-12) |
| F15 · New question formats | **Done** (closed 2026-10-12) |
| F16 · Placement test | **Done** (closed 2026-10-12) |
| F17 · Local leaderboard | **Done** (closed 2026-10-12) |
| F18 · Daily reminder | **Done** (closed 2026-10-12), real-phone check by the owner pending |
| F19 · Challenge by code | **Done** (closed 2026-10-12) |
| F20 · File backup | **Done** (closed 2026-10-12) |
| F21 · Other languages and shop | **Done** (closed 2026-10-13), device check by the owner pending |
| F22 · Google Play Games services | F22-01 done (sign-in on Android); nothing else planned |
| F23 · Read aloud | **Done** (closed 2026-10-18, wave 1) |
| F24 · Numbers up to 100 | **Done** (closed 2026-10-18, wave 1) |
| F25 · + et − | **Done** (closed 2026-10-19, wave 2) |
| F26 · Division | **Done** (closed 2026-10-19, wave 2) |
| F28 · Math words | **Merged** (wave 1 #102, wave 2 #112 and #114); closes after the recordings, the device check and the validation of its screens (F28-12) |
| F27 · Placement by skill | **Done** (closed 2026-10-25, wave 3) |
| F29 · Class mode | **Done** (closed 2026-10-25, wave 3) |
| F30 – F32 · Version 2.0 "Kid Matix pour tous" | Not started (waves in `docs/parallel-plan.md`, tasks in `docs/product/task-breakdown.md`, vision in section 17 of the specifications) |

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

## F10 closure

- `bash tool/check.sh`: every step OK (607 tests); `tool/check.sh build`
  OK (Android and iOS, with `audioplayers`); CI green on #56 to #59.
- Checked on the Android emulator (API 36), the lot's "done when"
  included: after the Discovery stage of the table of 1, the Profile tab
  showed level 2, "1 jour de série", 2 badges and the table of 1 "En
  cours" in the grid; the timer set to "Sans" removed the timer bar from
  the next Speed stage and "Normal" brought it back; "Tout débloquer"
  opened the tables on the map at once. Muting the sounds is covered by
  unit tests (no audio on the emulator). Fixed there: the column marks of
  the grid were enlarged by `FittedBox`.

Known gaps left on purpose, to handle in the lot named:

- The leaderboard (F17), reminder (F18) and backup (F20) sections of the
  settings stay hidden until their lots.
- The sounds are synthesized placeholders (`tool/generate_sounds.py`).
- Waiting for the owner: the edit through the avatar and nickname of the
  header, "Ta progression est remise à zéro.", the reset dialog, the
  screen-reader texts of the badges, monsters and grid cells.

## What F10 delivered

- Profile tab (mockup 12): header, streak / crowns / badges tiles
  (`GetProfileStats`, `ProgressCubit`), mascot card, "Mes tables" mastery
  grid (mastery feature, `MasteryPages`), "Mes badges" (reward) and "Mes
  monstres" (learning path) given by the router.
- Settings screen (mockup 13) in the profile feature: `GetSettings`,
  `UpdateSettings`, `SettingsCubit`, reduced motion applied to the whole
  app (`ReducedMotionScope`), delete moved here.
- Reset: `ProgressResetHook` per feature run by `ProgressResetter`
  (`ProgressResetService`) in one transaction; `ResetProgressUseCase`;
  nickname confirmation shared with deletion (`NicknameConfirmDialog`).
- `features/setting/`: `GameFeedbackService` (core) with `audioplayers`
  and haptics; sounds in `assets/sounds/`.
- `RewardService.readStreak`, `PlayerSettingsService.readFeedback`,
  `ChoiceSegments` moved to `core/widgets`.

## F11 closure

- `bash tool/check.sh`: every step OK (671 tests); coverage at least 90 %
  on every `domain/` and 80 % on every `data/` (`tool/coverage_report.py`);
  CI green on #61 to #73.
- Accessibility, tablet layout, integration journey and edge cases are
  covered by tests (#62, #68, #69). Performance measured on a Galaxy A16:
  start in 1.8 to 2.3 s, 99 % of the quiz frames at 90 Hz
  (`docs/release/performance-1.0.md`).
- Release audit (`docs/release/audit-1.0.md`): no network call, no
  communicating SDK; system backup turned off.
- Signed and obfuscated builds: `bash tool/build_release.sh` with the
  upload key of `android/key.properties` (`docs/release/signing.md`).
- Privacy policy published on GitHub Pages in the three languages of the
  app (https://saliouseck2009.github.io/Kid-matix/store/privacy-policy.html,
  and the same address suffixed `-en.html` and `-es.html`), reached from
  the landing page of the site
  (https://saliouseck2009.github.io/Kid-matix/).
- Google Play: listing, content rating, target audience and data safety
  filled. App Store Connect: listing, iPhone and iPad screenshots, Kids
  category 6-8, age rating 4+, "Data Not Collected", free in every country.

Left open, done by the owner:

- **F11-11**: the Android bundle goes to internal testing; the iOS build
  (bundle id `sn.ckroot.kidmatix`) goes to TestFlight through Transporter.
  The lot's "done when" (both builds installed from the test channels, the
  journey played on a phone) is checked then.
- App Store Connect: the phone number of the review contact, and
  "Publish" in App Privacy.
- A new personal Play account may need a closed test (12 testers for 14
  days) before production.

## F12 closure

- `bash tool/check.sh`: every step OK (728 tests), coverage thresholds
  met; CI green on #75 to #78.
- Survival checked on the Android emulator (API 36): the game ends at the
  third mistake, a heart empties at each one, the question is replaced
  after the background, first record then "Nouveau record !", Survivant
  badge at 31 right answers, timer note when the setting is "Sans".
- Daily review: the choice of the facts (overdue first, then the lowest
  success rate, each once) is covered by tests with a fake clock,
  including a fact missed the day before; the card and the quiz were not
  played on a device yet.

Texts waiting for the owner's confirmation: "Joue d'abord une étape du
parcours", no pill when no fact is due, "Ici, le chrono reste actif.",
"{n} vies sur {total}" / "Plus de vie", "Survivant" and "30 bonnes
réponses en Survie.", the survival quiz screen (hearts, score, timer bar)
which has no mockup.

## F13 closure

- `bash tool/check.sh`: every step OK; coverage thresholds met; CI green
  on #80 to #82.
- Checked on the Android emulator with progress seeded through the use
  cases: 7 × 8 missed twice showed as a monster ("1 monstre à
  apprivoiser" on the Défis card); a first hunt asked each monster twice,
  never in a row; after a second hunt both monsters reached box 4 and
  "Apprivoisés" showed "2 monstres". The Profile link to the screen is
  covered by a widget test only (the emulator was overloaded).

Texts and choices waiting for the owner: "Aucun monstre pour l'instant",
the empty-screen text, "Voir mes petits monstres", the screen-reader
texts of the monsters, the progress bar at box / 4, dark horns, no
celebration when a monster is tamed (mastery keeps no history).

## F15 closure

- Two question types registered in the registry, no change to `QuizBloc`:
  "Trouver l'opération" (`findOperation`, `? = 24`, 4 operations, one
  right) and "Relier les paires" (`matchPairs`, 4 operations and their 4
  results). Both are recognized answers (box 3 cap). They join the speed
  stage, the boss fight and free training.
- The match-pairs interaction lives in its answer widget, which submits
  one `PairsAnswer` (the facts missed) through the existing
  `AnswerSubmitted` event. `SubmitAnswerUseCase` records each pair in the
  mastery; `QuizRun` doubles the time of a match-pairs question through
  the time factor of its type. Rules in `docs/decisions.md`.
- `bash tool/check.sh`: every step OK (805 tests); coverage thresholds
  met (`quiz/domain` 100 %, `multiplication/domain` 94.6 %).
- Checked on the Android emulator (API 36) in free training (same quiz
  screen as the stages; the test profile had no speed stage open): "Quelle
  multiplication donne 5" with four operations; then a match-pairs board
  of the table of 6, a wrong pair turned red with the operation still
  selected, the four pairs matched green and "Presque !" named 6 × 8 = 48.
  That both formats are drawn in the speed stage and the boss fight is
  covered by tests; to try on the phone.

Texts and choices waiting for the owner: "Quelle multiplication donne",
"Touche la bonne opération", "Relie chaque opération à son résultat",
"{n} paire(s) trouvée(s) sur 4", "Touche une opération, puis son
résultat", "Touche maintenant le résultat de 5 × 6", "Touche maintenant
l'opération qui donne 30"; the pairs drawn in the table of the fact
asked; the selection kept after a wrong pair; the 4 facts counted as
missed when the time runs out.

## F14 closure

- `bash tool/check.sh`: every step OK (815 tests); coverage thresholds
  met (`features/challenge/domain` 97 %, `features/reward/data` 98 %).
- Checked on the Android emulator (API 36, debug build), with the one
  profile of the emulator against a guest: the Duel card of Défis opens
  the player choice (active player at the bottom, guest at the top, a
  player already chosen greyed on the other half), the two halves head to
  tail as in mockup 15, a wrong answer showed red with a cross, the right
  one green with a check and "Oups ! Attends un peu…" for 2 seconds, then
  a new question; at 10 the end screen showed "Chasseur gagne !", "+120
  XP" and "Pas d'XP pour un invité"; back on the map the player had moved
  to level 2 and the daily goal read 120 / 20 XP, streak unchanged. Two
  profiles of different levels each receiving their XP is covered by the
  `DuelBloc` tests (the emulator holds one profile).
- `DuelBloc` tests (F14-07): two taps at the same time each scored on its
  own half, the 2-second block (19 ticks of 100 ms ignore a tap, the 20th
  frees it), victory at 10, XP for both profiles and none for a guest,
  restart, stop without XP; a test over the real database checks that a
  whole duel writes only `xp_award` and the profile's XP (no
  `item_progress`, no quiz session, no streak).
- Schema version 10: `xp_award` (XP earned outside a quiz).

Texts and choices waiting for the owner: the player choice (no mockup:
"Joueur du haut" / "Joueur du bas", "Invité" with "Toutes les tables, sans
XP", "Posez le téléphone à plat entre vous deux. Le joueur du haut lit à
l'envers.", "Choisissez deux joueurs différents.", "C'est parti !"), the
answers shown red and green during the 2-second block with "Oups ! Attends
un peu…", the pause dialog ("Duel en pause", "Si vous arrêtez maintenant,
personne ne gagne d'XP.", "Reprendre", "Arrêter le duel"), the end screen
(no mockup: trophy, "Awa gagne !", "+120 XP", "Pas d'XP pour un invité",
"Rejouer", "Quitter"). A level reached in a duel is not celebrated (the
celebrations belong to the quiz results).

## Version 2.0, wave 3: F27 and F29 closure

Run on 2026-10-20: two `lot-implementer` (Sonnet for F27, Opus for F29)
in their own worktrees after the owner answered F29-01 (#117); every pull
request reviewed and re-reviewed by `code-reviewer`. Merged: #118 (F27),
then #119, #120, #121 (F29, stacked, main merged in bottom-up).

- F27 · Placement by skill (#118): five ordered skills (numbers,
  addition, subtraction, multiplication, division), 3 typical questions
  each, acquired with 2 right, missed with 2 wrong, stop at the first
  skill missed (5 to 15 questions, under 5 minutes); one level per domain,
  acquired units opened through the `placement` stage, the start unit
  opened and made current, the recommended domain saved as the home
  domain; read aloud; retake from the Profile card « Mon niveau de
  départ »; migration 014 `placement_result` (one row per test and
  domain, dated, NULL level = domain not reached), in the F20 backup and
  erased by the progress reset. Multiplication and division are judged on
  3 tables (5, 9, 8), not 12 as in F16.
- F29 · Class mode (#119, #120, #121): feature `classroom`, migration 015
  (`classroom`, `assignment`, `class_session`, `class_answer`,
  `profile.classroom_id`, nickname unique among free players and within a
  class); teacher area behind a 4-digit code with « Code oublié ? »
  through the adult gate and a 30 s lockout after 5 wrong codes, locked
  after 60 s in the background; classes of up to 60 pupils created in one
  go (nicknames or numbers « 01 »…); classes first on « Qui joue ? »,
  « Qui es-tu ? » with an accent-insensitive search; homework (« Le
  devoir de la classe » banner, its unit opened for the pupils); dashboard
  per pupil and per item (« 8 élèves se trompent sur 7 × 8 »), level
  groups from the placement and mastery, weekly class challenge with a
  gauge and no individual ranking; class results in their own journal
  (`ClassroomSessionHook`), kept by a pupil's reset; pupils out of the
  leaderboard and the duel, without reset or delete (the teacher does
  both from « Gérer … »); transfer by `kidmatix-class` v1 files through
  the share sheet, delta by default (local sequence mark, 14 days
  resent), merge idempotent and pupil by pupil (« Moussa 2 » on a taken
  nickname). Pure rules for F31: `ItemStandingRule`,
  `ClassDashboardCalculator`, `LevelGroupRule`, `ClassChallengeRule`,
  `ClassItemCatalog`, over `PracticeSession` lists only.

Checked by the owner on 2026-10-25, both "done when" criteria OK: a
profile that counts but cannot add starts on « Additions jusqu'à 5 » with
its dated result on the Profile card; on a tablet, a class of 30 with
« Additions jusqu'à 20 » assigned, three pupils playing and the dashboard
showing who is stuck and on which facts. Both lots closed; the screens
built without a mockup (F29-11) and the texts are kept as built.

Known gaps: no class deletion; a removed pupil comes back from another
tablet's file (no tombstone); « Code oublié ? » makes the teacher area as
strong as the adult gate (« Code changé le … » warns the teacher); a
pupil's game progress stays on one tablet (owner: one tablet per pupil).

Next: wave 4 (F30 word problems with `problems.md` first, F31 progress
measurement with migration 017) and F28's recordings.

## Version 2.0, wave 2 (F25 and F26 closed, F28 pending)

Run on 2026-10-18 and 19: three `lot-implementer` (Sonnet) in their own
worktrees for F25, F26 (a Claude subagent instead of Codex, owner) and the
rest of F28; every pull request reviewed by `code-reviewer`, re-reviewed
after its fixes. Merged one after the other, each bringing `main` in:
#113 (F25), #111 (F26), #112 and #114 (F28).

- F25 · + et − (#113): 18 units, from sums up to 5 to carrying and
  borrowing; every addition a + b with 1 ≤ a, b ≤ 9 and both subtractions
  of its family taught exactly once (exhaustiveness test); keys `add:7+8`,
  `sub:15-7`, units `addsub:<slug>`, reviews `review:addition:1..6`;
  plausible wrong answers (never negative), fact families, help card with
  number line, gap to ten and bundles. Also the daily review across every
  domain (`MixedQuizPlanner`: due items first, over all domains at once)
  and twice the time for counting questions. Guard tests: every item fits
  a daily-review format; no item key shared by two domains.
- F26 · Division (#111): 120 facts from the multiplication facts, 12 units
  in the multiplication path order, keys `div:56/7`, units `div:7`; after a
  mistake « Retiens aussi : 7 × 8 = 56 » with no feature importing another;
  help card « 56 points partagés en 7 groupes : 8 dans chaque groupe »;
  the title « Trouve le nombre caché » for every missing-number question,
  in every domain.
- F28 · Mots des maths (#112, #114): `tool/process_audio.py` (needs
  ffmpeg) and `tool/build_math_words.py`, audio packs with a manifest
  (`assets/audio/<language>/`, the Wolof pack ships empty), migration 013
  (`profile_settings.help_audio_language`, NULL = first pack), the
  `math_words` domain (40 words `word:<key>`, six units), « Écoute et
  touche », « Mot et image », « Toucher pour comprendre » (discovery only),
  « Quelle opération ? » on the shared `MathOperator`, the Wolof buttons,
  words in the daily review. The domain switch scrolls from 4 domains.

To check on a device (owner), short:

- F25 and F26: checked by the owner on the phones on 2026-10-19, both
  "done when" criteria OK (additions up to 20, 7 + 8 recalling 8 + 7, the
  missed fact back the next day; the path « Diviser par 2 » with its
  multiplication reminder). Both lots closed.
- F28, once the recordings are delivered and processed: in airplane mode
  « il reste » heard in French then in Wolof, the right drawing touched,
  a missed word back the next day; « Quelle opération ? » on the table's
  statements. Until then the Wolof buttons and the « Aide audio » row stay
  hidden.

Waiting for the owner: the Wolof columns and glossary of `math-words.md`
and the 80 recordings (guide in `docs/product/audio-recording.md`, then
`python3 tool/process_audio.py <folder>`); the screens of F28 without a
mockup (F28-12 stays open); the new texts of F25, F26 and F28 (unit names
and tips, « + et − », « Mots des maths », activity titles) in fr, en and
es; the provisional monsters (round ears, wings, bubbles) and drawings.

Known gaps: `build_quiz_use_case.dart` (about 290 lines) and
`quiz_item_planner.dart` (216) are over the 200-line class limit, to split
in a `refactor(quiz)` pull request; challenges, little monsters, the
monster hunt, the duel and the placement test stay multiplication-only
(F27 brings placement by skill).

Next: F28 closes once the recordings are processed and checked on a
phone and its screens are validated; wave 3 (F27
with migration 014, F29 with migration 015 once the owner answers F29-01).

## Version 2.0, wave 1: F23 and F24 closure

Run on 2026-10-18 as planned in `docs/parallel-plan.md`: `lot-implementer`
(Sonnet) for F23, `lot-implementer` (Opus) for F24, `content-writer`
(Haiku) for the F28 content, each in its own worktree; every pull request
reviewed by `code-reviewer` (Opus). One pull request per lot (two stacked
for F24), targeted tests while coding, the full `tool/check.sh` before
each push, no emulator in the agents. Decisions of the wave are in
`docs/decisions.md` (owner's answers of 2026-10-18).

Merged:

- #102 (F28-01, guide part of F28-02): `docs/product/math-words.md` —
  40 words in six families with stable keys, meanings, image ideas and
  examples, empty Wolof columns, a consistency glossary and 20 « Quelle
  opération ? » statements for F28-09, many with a misleading word — and
  `docs/product/audio-recording.md`, the recording guide for the owner.
  The review asked for fixes (wrong meaning of « donner », notes pairing a
  word with an operation, OP-17 with two right answers, guide renaming
  `.mp3` to `.m4a`); applied before the merge. After it: two audio files
  per word and « acheter » instead of « manger » (owner).
- #103 and #105 (F24-01 to F24-08, F24-10): the `numbers` feature (seven
  units, 70 items, four question types with their drawings), the domain
  switch on the home and in the Profile, the numbers path with its bosses,
  tips and help cards, per-domain stars, crowns and mastery. No migration
  (013 unused; the reserved numbers of later waves shift down by one).
  Review: approve with nits. 1346 tests; an integration test covers the
  "done when" (numbers stars won, multiplication stars and mastery
  unchanged after a restart). Not checked on a device.

Then merged:

- #104 (F23-02 to F23-08), read aloud: `SpeechService` and the `speech`
  feature over `flutter_tts` (iOS now also uses CocoaPods), the « Écouter »
  button on every question surface, automatic reading, the timer that
  waits for the voice, readings of instructions, tips and mascot messages,
  the per-player setting (migration 012, schema 12). Two reviews: the
  timer stuck on a voice that never stops, overlapping readings and the
  creation offer in a second write were fixed; one spoken-text entry for
  every format, `QuizLabels.speakQuestion`, shared with F24.
- #107, F24 follow-up: final keys `num:compare:a:b` and `num:line:m:s`,
  folder `lib/features/number/`, names, tips and marks by unit slug
  (`DomainNames`, `DomainNaming`), one monster family per domain, guard
  tests (every unit named, every stage gives each item a format, no two
  domains share a monster family), numbers screens in the text-scale and
  guideline tests (a real overflow on the numbers boss was fixed),
  `number/domain` at 100 % coverage.
- #108, F23 follow-up: the typed `SpeechReading` stop handle, a voice
  check that fails is "no voice for now" (retried on resume, never holds
  a quiz back), the visible card label kept for screen readers, the boss
  prompt in a `Flexible`, the quiz timer moved into `QuizClock`
  (`QuizBloc` at the 200-line limit). A review caught a regression (a
  phone without a speech engine could not start a quiz) before the merge.

Recipe for a new domain (wave 2): a feature folder with a singular name
implementing `LearningDomain` (with `questionTypeIdsOf`), its id in
`LearningDomainIds` (no `:`, not a number), its registration after the
previous domains, a names file in `core/extensions/domain_names/` and one
line in `DomainNaming`, its ARB keys (domain name, unit names and tips by
slug), a `MonsterFamily` value and its provisional drawing, its keys
pinned by a test. The guard tests fail until each piece is there.

Checked on the phones by the owner (2026-10-18), both "done when"
criteria OK:

- F23: in airplane mode on a low-end Android phone and on an iPhone, a
  question is read in French by the offline voice and the timer waits for
  the end of the reading.
- F24: Accueil → « Nombres » → « Compter jusqu'à 10 », its stars won, then
  « Compter jusqu'à 20 »; back on « Multiplication », progress unchanged.

The owner closed both lots after the check: the screens built without a
mockup (F24-09) and the new texts of F23 and F24 are kept as built.

Waiting for the owner:

- The Wolof columns and glossary of `math-words.md`, then the 80
  recordings (`wo_<key>.m4a` and `wo_<key>_exemple.m4a`, guide in
  `docs/product/audio-recording.md`); the F28 keys, meanings and statements.
- Time limits of the speed and boss stages for counting up to 20 objects.

Known gaps: the placement test and the duel have no listen button (F27-04
plugs the test in); challenges, little monsters, the monster hunt, the
placement test and the daily review stay multiplication-only (F25 needs a
daily review per domain); `flutter_tts` applies the Kotlin Gradle plugin
(warning to revisit at the next Flutter bump); the privacy policy does not
mention the system voice yet.

Next: wave 2 (F25, F26, the rest of F28 with migration 013), as planned
in `docs/parallel-plan.md`.

## F21 closure

All lots, F0 to F21, are done. Left for the owner: the builds in the
test channels (F11-11), the check of the daily reminder on a real phone
(F18), the device check of the shop below, and the texts, prices and
translations to confirm.

- Languages (F21-01, F21-02): English and Spanish, chosen in the
  settings, delivered by their own pull request (`feat/f21-languages`).
- Coins (F21-03): 1 coin every 10 XP (quizzes and duels), 20 per crown,
  10 per badge, computed from the totals, minus the prices paid; no real
  money. Schema version 11: `shop_purchase` and `shop_choice` (new
  feature `shop`). Rules in `docs/decisions.md`.
- Catalog (F21-04): the 12 free avatars; 8 avatars to buy, 80 to 300
  coins, drawn in their own colors (`PremiumAvatarPainter`); 4 color
  themes, 150 to 250 coins (Océan, Forêt, Coucher de soleil, Nuit),
  Lavande free. A theme recolors the app for its player only
  (`AppTheme.of`, `ActiveThemeCubit` in `PlayerScope`).
- Shop screen (F21-05, mockup 22), opened from the « Boutique » card of
  the Profile tab: coins, tabs « Avatars » / « Thèmes », « Porté » /
  « Actif », « Choisir », price, greyed price; purchase confirmed in a
  dialog.
- The progress reset takes the purchases, the theme and the coins back
  and leaves the avatar worn; the backup carries the shop (`shop`
  section, format version 2, version 1 files still read).
- Tests (F21-06): coin rules (XP rest, crown, badge), the balance with a
  duel and a stage over the real wiring, purchase, insufficient coins,
  item owned, wearing and applying, reset, backup round trip of the shop
  rows and a version 1 file, migration 11, the screen and its Cubit, the
  theme scope, AA contrast of the five themes and the text contrast of
  every screen in each theme. The language tests come with the languages.
- `bash tool/check.sh`: every step OK (1204 tests). Coverage:
  `features/shop/domain` 97.7 %, `features/shop/data` 100 %, every other
  folder above its threshold.
- Not checked on a device: no Android emulator was running. To try:
  play a few quizzes (or a duel), Profil → « Boutique », buy the fox,
  « Choisir », then « Thèmes » → buy and apply « Nuit » and look at every
  tab; « Changer de joueur » goes back to lavender. Profil → Réglages →
  « Réinitialiser ma progression »: coins back to 0, the fox stays worn.

Texts and choices waiting for the owner: the 8 avatar names (Renard,
Panda, Robot, Extraterrestre, Licorne, Dragon, Ninja, Roi) and their
prices (80, 80, 120, 150, 180, 220, 250, 300), the theme names and
prices (Océan 150, Forêt 150, Coucher de soleil 200, Nuit 250),
« Actif » for the theme applied, the purchase dialog (« Acheter Renard ? »,
« Ça coûte 80 pièces. Il t'en restera 160. », « Acheter »), the messages
(« Bravo, Renard est à toi ! Touche « Choisir » pour l'utiliser. »,
« Il te manque 60 pièces. Joue encore pour les gagner ! »), the hint
under the grid and the card subtitle « Avatars et thèmes à débloquer ».

### Languages (F21-01, F21-02)

- F21-01 and F21-02 done: English and Spanish (`lib/l10n/app_en.arb`,
  `app_es.arb`, every key), chosen for the whole phone in the « Langue »
  section of the settings, the phone's language by default and French
  when the phone speaks neither. The app switches live; the reminder
  notification and its Android channel follow; the parental gate spells
  its number in the language shown (`core/utils/number_words.dart`).
- Tests: key and placeholder parity of the three ARB files
  (`test/l10n/arb_parity_test.dart`), the language kept and applied, the
  phone default and the French fallback, the app and the settings in
  English and Spanish, the text-scale test in the three languages.
- Translations to be proofread by the owner (choices listed in #92).
  Every new key needs its English and Spanish text: the parity test
  fails otherwise.

## F20 closure

- Settings, section « Sauvegarde » (mockup 13): « Exporter mon profil »
  writes the active player to `KidMatix-<nickname>-<day>.kidmatix` and
  opens the share sheet; « Importer un profil » opens the system picker.
  Both open behind the parental gate « Demande à un adulte »
  (`core/widgets/parental_gate.dart`: a number from 1,000 to 9,999 in
  French words, to type in digits). Format and rules in
  `docs/decisions.md`. No schema change, no Android or iOS setting.
- Each feature exports and imports its own tables through a
  `ProfileBackupPart` (`core/storage/`); the profile feature runs them in
  one transaction, with new ids for everything but a replaced player.
  The placement rows of `stage_progress` travel apart, the last free
  training (a preference) travels with the challenges.
- A nickname already on the phone asks « Remplacer » or « Renommer »;
  a damaged file or a file of a newer version is refused with its own
  message. New packages: `share_plus`, `file_selector`,
  `package_info_plus`. Privacy policy updated; the Play data-safety and
  App Store privacy answers do not change.
- Tests (F20-05): a round trip between two databases (every table of the
  player identical, links between rows kept, the other player left out),
  replace keeping the id, rename twice without collision, nickname taken,
  damaged JSON, malformed row and dangling row refused with nothing
  written, newer version refused, unknown keys and missing sections
  read; the codec, the use cases, the Cubit, the settings section with
  the gate, the gate and the French number spelling.
- `bash tool/check.sh`: every step OK (1041 tests); `bash tool/check.sh
  build` OK (Android and iOS). Coverage: `features/profile/domain`
  96.3 %, `features/profile/data` 91.1 %, every other folder above its
  threshold.
- Not checked on a device: the debug build installed on the shared
  Android emulator, but another session was playing a quiz on it, so the
  check stopped there. To try with two phones: on the first, Profil →
  Réglages → « Exporter mon profil », answer the gate, send the file
  (e-mail, messaging app, Drive); on the second, install the app, create
  any player, then « Importer un profil » and pick the file — with the
  same nickname, « Remplacer » brings back level, streak, stars and
  mastery grid.

Texts waiting for the owner: the gate (« Demande à un adulte », « Cette
action est réservée aux adultes. Écris ce nombre en chiffres : »,
« Nombre en chiffres », « Valider »), the conflict dialog (« Awa existe
déjà », its text, « Remplacer », « Renommer »), the rename dialog
(« Nouveau pseudo », « Choisis un autre pseudo pour le joueur
importé. », « Importer »), the messages after an export or an import and
the two refusals. Choices to confirm: 4-digit numbers for the gate, the
imported player not made active, a wrong gate answer going back silently.

## F19 closure

- A challenge code is 10 characters (`K7M2-QX9T-B4`, no 0, O, 1, I, L):
  tables, mode, question count, seed, score to beat, generator version
  and a check character (layout in `ChallengeCodeCodec` and
  `docs/decisions.md`). No schema change.
- `EncodeChallengeCodeUseCase` and `BuildQuizFromCodeUseCase` (challenge
  feature); a quiz with a `SeededDraw` is built by the frozen
  `FrozenQuestionGenerator` over `SeededRandomSource` (Mulberry32 written
  in Dart), without the mastery. Version 1: 6 formats in a coded free
  training, multiple choice in a coded time attack.
- « Défier un ami » on the results of a free training and a time attack;
  code screen (mockup 20) with copy and entry; « J'ai un code » on the
  Défis tab; comparison screen (mockup 21) in place of the results of a
  coded game, with « Renvoyer un défi » (same seed, new score).
- A coded game counts like a game of its mode: XP, mastery, streak,
  badges, time attack record.
- "Done when" proved by tests (F19-07): encode then decode for every mode,
  every single changed character and every swap refused, unknown version
  refused, a code made on one phone gives the same questions on a second
  (two separate registries and random sources), golden lists of version 1
  for a training and a time attack code, the quiz Bloc asking the seeded
  questions.
- `bash tool/check.sh`: every step OK (915 tests); coverage thresholds met
  (`features/challenge/domain` 97.2 %, `features/quiz/domain` 100 %).
- Not checked on a device: the shared Android emulator stayed on the
  loading indicator of the map and of the Défis tab after install (45 s
  to the first frame), screens this lot does not change. To try on the
  phone: a free training then « Défier un ami », copy the code, « J'ai un
  code » on a second phone (or player), play it, the comparison, then
  « Renvoyer un défi ».

Texts and choices waiting for the owner: the hint under the code
(« Donne ce code à un ami : même mode, mêmes tables, et ton score à
battre ! » instead of « exactement les mêmes questions que toi »: the
sender's own game was drawn by the mastery, the friend plays the code's
draw; both play the same questions from the first « Renvoyer un défi »),
« Code copié ! », the three error messages, « Pas cette fois ! » and
« Égalité ! », « Autant de bonnes réponses », the 6 formats drawn evenly
in a coded training (no mastery), back from the code screen to the Défis
tab.

## F18 closure

- One reminder for the whole phone, off by default, 17:00 by default, in
  the « Rappel » section of the settings (mockup 13); device preferences
  in `shared_preferences`, no migration. The notification permission is
  asked only when the switch goes on; a refusal puts it back off with a
  snack bar. Rules in `docs/decisions.md`.
- `flutter_local_notifications` (+ `timezone`) behind
  `NotificationScheduler` (`core/services/`), implemented in the setting
  feature. Each day is its own notification for the next 30 days, inexact
  on Android (no exact alarm permission); planned again at every launch,
  after every completed quiz (a `SessionSavedHook` keeps the day: no
  reminder that day) and on every settings change. Android: desugaring,
  boot receiver, `RECEIVE_BOOT_COMPLETED`, white `ic_notification`; iOS:
  the notification center delegate in `AppDelegate`.
- Tests (F18-05), with a fake notification scheduler and a fake clock:
  scheduling, cancelling, change of time, skip today after a session (also
  over the real wiring and after a restart), permission refused, broken
  plugin or preferences, the settings rows and the plugin calls (mocked
  plugin). `bash tool/check.sh all`: every step OK, Android and iOS builds
  included.
- "Done when" (a reminder set a few minutes ahead shows on a real Android
  phone and an iPhone): to be checked by the owner on the phones, steps in
  the pull request. Not run on an emulator.
- The privacy policy and the store notes now say the app asks for one
  permission, the notifications, only when the reminder is switched on.

Texts waiting for the owner: the notification (« Kid Matix » /
« C'est l'heure de tes tables ! »), the refusal message (« Les
notifications sont bloquées. Autorise-les dans les réglages du téléphone
pour recevoir le rappel. »), « Oups, le rappel n'a pas pu être réglé. »,
and the Android channel (« Rappel quotidien », « Te rappelle de jouer
chaque jour à l'heure choisie. »).

## F17 closure

- `bash tool/check.sh`: every step OK (895 tests); coverage thresholds
  met (`features/reward/domain` 97 %, `features/reward/data` 99 %).
- Checked on the Android emulator (API 36, debug build) with its two
  players: the "Classement" card at the bottom of the Profile tab opens the
  screen of mockup 19, Chasseur first on the podium with the 120 XP of
  today's duel, Placid second with 0 XP and "C'est toi", and the mascot
  saying "Encore 120 XP et tu rattrapes Chasseur !". The settings switch
  and the Monday reset were checked by the tests only (short session on
  purpose).
- Tests (F17-05): the week from Monday 00:00 with a fake clock (every day
  of the week, across a month, a year and a daylight saving change),
  Sunday 23:59:59 → Monday 00:00 starting again from zero (also over the
  real database), ties by nickname ignoring case, quiz and duel XP summed,
  deleted rows ignored, the setting kept on the device and hiding the
  Profile card, and the whole path Profil → Classement → Réglages.
- No schema change: the weekly XP are summed from `session_reward` and
  `xp_award` when read.

Texts and choices waiting for the owner: the "Classement" card at the
bottom of the Profile tab with "Qui a gagné le plus d'XP cette
semaine ?" (no mockup for the entry), the mascot messages other than the
mockup's "Encore 110 XP et tu rattrapes Moussa !" ("Tu es à égalité avec
Moussa !", "Tu es en tête cette semaine !", "Joue pour gagner tes premiers
XP de la semaine !"), and the frame plus "C'est toi" on the active player's
row under the podium.

## F16 closure

- Offered at the end of the profile creation (« Passer »); 12 typed
  questions, one per table; a right answer opens its table, stars still
  to win; mastery counts, no XP. Result screen of mockup 18. Rules in
  `docs/decisions.md`. No migration: placed tables are `stage_progress`
  rows with the stage `placement`.
- Tests (F16-05): right tables opened (1, 2 and 10 → exactly those),
  test passed, skipped and left midway (Bloc, page, router, real
  database). `bash tool/check.sh`: every step OK (893 tests);
  `learning_path` domain 99 %, data 100 %.
- Short check on the Android emulator (API 36, debug): after « C'est
  parti ! » the offer showed, then the keypad questions (1 × 7, 2 × 3).
  The rest of the run was cut short: another session reinstalled the
  app on the shared emulator. The result screen and the map are covered
  by tests; to try on the phone.

Texts waiting for the owner: the offer (no mockup: « Tu connais déjà des
tables ? », its text, « Faire le test »), « Je ne sais pas », the quit
dialog, the result with 0 table (« Tout est à découvrir ! », « Pas de
souci, tu vas les apprendre une par une. Ton parcours commence par la
table de 1. ») and with 1 table (« Elle est ouverte… Ses étoiles… »).
