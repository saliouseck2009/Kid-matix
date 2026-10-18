# Features

One folder per feature, named in the singular. Each feature is created with
the lot that delivers it; nothing is scaffolded ahead of time.

| Feature          | Lot      | Purpose                                      |
| ---------------- | -------- | -------------------------------------------- |
| `profile`        | F1, F20  | Local players, active player, backup file    |
| `multiplication` | F2       | The multiplication learning domain           |
| `quiz`           | F3       | Quiz session, timer, answers, results        |
| `mastery`        | F4       | Per-fact mastery and spaced repetition       |
| `learning_path`  | F5, F6   | Map of tables, stages, stars, boss fight     |
| `reward`         | F7       | XP, levels, streak, daily goal, badges       |
| `mascot`         | F8       | The mascot that grows with the player        |
| `challenge`      | F9, F12+ | Free training, time attack and other modes   |
| `setting`        | F10, F18 | Sounds, vibrations and the daily reminder    |
| `shop`           | F21      | Coins, avatars and color themes to unlock    |
| `speech`         | F23      | Reads texts aloud with the phone's voice     |
| `numbers`        | F24      | The numbers up to 100 learning domain        |

Layout of a feature:

```
<feature>/
├── data/          datasources/  models/  repositories/
├── domain/        entities/  repositories/  usecases/
├── presentation/  bloc/  pages/  widgets/
└── injection.dart
```

A feature never imports another feature. See `CLAUDE.md` at the project root.
