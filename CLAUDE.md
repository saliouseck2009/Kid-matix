# Kid Matix — instructions for coding sessions

Kid Matix is a gamified, Duolingo-inspired Flutter app that helps children
master maths facts, starting with the multiplication tables (1 to 12, up to
x10). Several children share one phone, each with a nickname. It is offline
first: version 1.0 has no backend and no network call.

The owner is French-speaking: **talk to the owner in French**. Code, comments,
commit messages and technical docs stay in English.

## Start of every session

1. Read `docs/status.md` — where the project stands and what comes next.
2. Read the owner's coding rules; they are binding:
   - `docs/rules/flutter-architecture.md` — feature-first Clean Architecture,
     BLoC, GetIt, go_router, storage, UI, widgets, performance, accessibility.
   - `docs/rules/dart-guidelines.md` — Dart conventions, naming, functions,
     classes, error handling, testing, serialization.
   - `docs/rules/code-examples.md` — reference snippets for every pattern.
3. Read the tasks of the current lot in `docs/product/task-breakdown.md`, the
   matching sections of `docs/product/specifications.md`, and open the mockups
   of the lot in `docs/design/screens/`.

## Project documents

| File | Content |
| --- | --- |
| `docs/status.md` | Current state, pending checks, what the next lot must wire |
| `docs/product/task-breakdown.md` | Lots F0 to F21, every task with a checkbox, "done when" per lot (French) |
| `docs/product/specifications.md` | Product rules: profiles, learning path, question formats, mastery engine, gamification, data, online roadmap (French) |
| `docs/design/README.md` | Design tokens, components, index of mockups by lot |
| `docs/design/screens/*.png` | One capture per screen |
| `docs/design/source/*.dc.html` | Markup of each mockup: exact sizes, colors, SVG paths |
| `docs/decisions.md` | Decisions already taken and open points |
| `docs/rules/*.md` | The owner's coding rules |

Priority when documents disagree: `docs/rules/` > this file and
`docs/decisions.md` > task breakdown > specifications.

The repo copies are the reference from now on. The original online documents
are kept for history only: [specifications][specs], [breakdown][tasks],
design canvases [one][design1] and [two][design2].

[specs]: https://claude.ai/code/artifact/930d8c2c-f367-4566-b936-df96c5873480
[tasks]: https://claude.ai/code/artifact/7b5a98b9-745b-4527-b32c-c90647248333
[design1]: https://claude.ai/artifact/MDoGGS2uwsFLqTK7nKnUYL
[design2]: https://claude.ai/artifact/3obJHG47Yvgy8nTEXTx2tG

## Project decisions that refine the rules

Full list with reasons in `docs/decisions.md`. The ones that affect every
file:

- Constants use `lowerCamelCase`, as the Dart lints require. The
  `SCREAMING_SNAKE_CASE` rule is dropped for this project.
- Constructors assign private fields with initializing formals
  (`required this._repository`), as the `prefer_initializing_formals` lint of
  this SDK requires; callers still pass the public name (`repository:`).
- Game-rule values (boss hit points, XP per answer...) are named constants in
  the domain of the feature that owns them. They move to `core/constants/`
  only when a second feature needs them.
- Crash reporting goes through `core/services/CrashReporter`. Version 1.0
  uses the local `LogCrashReporter`; a remote service comes with online mode.
- Local persistence is `sqflite`; light preferences are `shared_preferences`.
- Networking and secure-storage rules apply only once online mode exists.
- No `equatable`; no `google_fonts` (fonts are bundled); no package added
  before the lot that needs it.
- All code, comments and documentation are in English. User-facing text is
  French and lives in `lib/l10n/app_fr.arb`; widgets read it with
  `context.l10n`.

## Structure

```
lib/
├── core/        constants, di, entities, error, extensions, router,
│                services, storage, theme, usecases, utils, widgets
├── features/    one folder per feature, singular name:
│                data/ domain/ presentation/ injection.dart
├── l10n/        ARB files and generated AppLocalizations
└── main.dart
```

Feature names: `profile`, `multiplication`, `quiz`, `mastery`,
`learning_path`, `reward`, `mascot`, `challenge`, `setting`
(see `lib/features/README.md`). A feature folder is created by the lot that
delivers it, never ahead of time.

Hard constraints, enforced by `test/architecture/architecture_test.dart`:

- `domain/` imports only `dart:` libraries, `package:meta`, pure-Dart parts of
  `core/` and its own feature's `domain/`.
- A feature never imports another feature. Shared entities go to
  `core/entities/`; shared capabilities go through an interface in
  `core/services/`, implemented by the owning feature.
- `presentation/` never imports `data/`.
- `core/` imports features only from `core/di/` and `core/router/`.

Building blocks that already exist in `core/` — use them, do not duplicate:
`DataState` / `AppException` / `AppErrorCode`, `UseCase` / `NoParamUseCase`,
`Clock`, `RandomSource`, `Ticker`, `IdGenerator`, `CrashReporter`,
`AppDatabase` + `DatabaseMigration` + `appMigrations`, `CommonColumns`,
`TableChangeBus`, `LocalStorage`, `AppRoutes`, `AppTheme` / `AppPalette` /
`AppSizes`, `DepthButton`, `AppCard`, `AppProgressBar`, `AppPill`,
`AppIconButton`, `AppTabBar`.

## Workflow

Work follows the task breakdown, one lot at a time, in order (F0, F1, F2...).
Inside a lot: domain, then data, then presentation, then tests.

- First-time setup on a new machine: `bash tool/setup.sh` (fonts and
  packages).
- After every change: `bash tool/check.sh`. It runs `pub get`, `gen-l10n`,
  `build_runner` (once a `@JsonSerializable` model exists), the formatter,
  `flutter analyze` and all tests, and writes the full output to
  `tool/logs/check.log`. Run it yourself and fix what it reports.
- A lot is done only when every step is OK, its tasks are ticked in
  `docs/product/task-breakdown.md`, its "Terminé quand" criterion has been
  checked on a device or emulator, and `docs/status.md` is updated.
- Tick a task (`- [ ]` to `- [x]`) in the same commit as the code that
  completes it.
- Every schema change is a new numbered migration with its test.
- When a product rule is missing or ambiguous, or a screen has no mockup, ask
  the owner instead of guessing; record the answer in `docs/decisions.md`.
- Commit at the end of each coherent step, with conventional messages
  (`feat(profile): ...`, `test(quiz): ...`, `chore: ...`).
