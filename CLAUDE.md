# Kid Matix — instructions for coding sessions

Kid Matix is a gamified Flutter app that helps children master maths facts,
starting with the multiplication tables (1 to 12, up to x10). It is offline
first: version 1.0 has no backend and no network call.

## Read before writing any code

The owner's coding rules are binding. Read them at the start of every session:

- `docs/rules/flutter-architecture.md` — feature-first Clean Architecture,
  BLoC, GetIt, go_router, storage, UI, widgets, performance, accessibility.
- `docs/rules/dart-guidelines.md` — Dart conventions, naming, functions,
  classes, error handling, testing, serialization.
- `docs/rules/code-examples.md` — reference snippets for every pattern.

When these rules conflict with the product documents, the rules win.

## Project decisions that refine the rules

- Constants use `lowerCamelCase`, as the Dart lints require. The
  `SCREAMING_SNAKE_CASE` rule is dropped for this project.
- Game-rule values (boss hit points, XP per answer...) are named constants in
  the domain of the feature that owns them. They move to `core/constants/`
  only when a second feature needs them.
- Crash reporting goes through `core/services/CrashReporter`. Version 1.0
  uses the local `LogCrashReporter`; a remote service comes with online mode.
- Local persistence is `sqflite`; light preferences are `shared_preferences`.
- Networking and secure-storage rules apply only once online mode exists.
- All code, comments and documentation are in English. User-facing text is
  French and lives in `lib/l10n/app_fr.arb`.

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
`learning_path`, `reward`, `mascot`, `challenge`, `setting`.

Hard constraints, enforced by `test/architecture/architecture_test.dart`:

- `domain/` imports only `dart:` libraries, `package:meta`, pure-Dart parts of
  `core/` and its own feature's `domain/`.
- A feature never imports another feature. Shared entities go to
  `core/entities/`; shared capabilities go through an interface in
  `core/services/`, implemented by the owning feature.
- `presentation/` never imports `data/`.
- `core/` imports features only from `core/di/` and `core/router/`.

## Workflow

Work follows the task breakdown, one lot at a time (F0, F1, F2...). Inside a
lot: domain, then data, then presentation, then tests.

- First-time setup: `bash tool/setup.sh` (fonts and packages).
- After every change: `bash tool/check.sh`. It runs code generation, the
  formatter, `flutter analyze` and all tests, and writes the full output to
  `tool/logs/check.log`. A lot is done only when every step is OK.

## Product documents

- Specifications:
  https://claude.ai/code/artifact/930d8c2c-f367-4566-b936-df96c5873480
- Task breakdown (lots F0 to F21):
  https://claude.ai/code/artifact/7b5a98b9-745b-4527-b32c-c90647248333
- Design, first six screens:
  https://claude.ai/artifact/MDoGGS2uwsFLqTK7nKnUYL
- Design, remaining screens:
  https://claude.ai/artifact/3obJHG47Yvgy8nTEXTx2tG
