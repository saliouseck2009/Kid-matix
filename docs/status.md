# Project status

Update this file at the end of every lot (and whenever work stops in the
middle of one). Last update: 2026-10-09.

## Where we are

| Lot | State |
| --- | --- |
| F0 · Foundation | **Done** (closed 2026-10-09) |
| F1 · Profiles ("Qui joue ?") | **Next** |
| F2 – F21 | Not started |

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

Known gaps left on purpose, to handle in the lot named:

- Portrait is locked at runtime only (`SystemChrome` in `main.dart`).
  `ios/Runner/Info.plist` and `AndroidManifest.xml` still allow landscape —
  restrict them by F11 at the latest.
- `appMigrations` is empty and nothing opens the database yet — F1-05.
- The router has no `redirect`; the four tabs show `ComingSoonPage`
  placeholders — F1-09 for the redirect, then each lot replaces its tab.
- `configureDependencies()` registers only core services — each lot adds its
  `registerXxxFeature()`.

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

## Starting F1

Tasks F1-01 to F1-18 in `docs/product/task-breakdown.md`; rules in section 3
of `docs/product/specifications.md`; mockups `01-who-is-playing` and
`02-profile-creation` in `docs/design/screens/`.
Each task gets its own branch from `main`, for example
`feat/f1-01-profile-entity`, and its own pull request once `tool/check.sh` is green.

What F1 must wire in addition to its own feature folder:

- First migration (version 1): tables `profile` and `profile_settings`, with
  the common columns, a unique index on the normalized nickname and the empty
  remote-account column. Register it in `appMigrations`; from then on the
  database opens.
- `ProfileSessionService` interface in `core/services/`, implemented in
  `features/profile/`, exposed as a `Listenable` so `createAppRouter()` can
  use it as `refreshListenable` and `redirect` to "Qui joue ?" when no player
  is active. New routes go in `AppRoutes`.
- `registerProfileFeature()` in `features/profile/injection.dart`, called
  from `configureDependencies()`.
- First `@JsonSerializable` models: `tool/check.sh` then starts running
  `build_runner` by itself.
- Shared entities other features will need (the profile summary read by the
  shell, for instance) go to `core/entities/`, not to the feature.
- Colors to add to the theme for these screens: see "To add with F1" in
  `docs/design/README.md`.
- The streak pill on profile cards arrives with F7-15; until then the card
  shows avatar, nickname and level.
