# Kid Matix — instructions for Codex and other coding agents

`CLAUDE.md` holds the project instructions for every coding agent, not only
Claude: **read it first and follow it.** This file only adds what an agent
started from the terminal needs.

## Read before writing code

1. `CLAUDE.md` — project, structure, architecture constraints, workflow.
2. `docs/status.md` — where the project stands.
3. `docs/rules/flutter-architecture.md`, `docs/rules/dart-guidelines.md`,
   `docs/rules/code-examples.md` — the owner's coding rules, binding.
4. `docs/git-workflow.md` — branches, commits, pull requests.
5. `docs/parallel-plan.md` — rules when several agents work at the same
   time (migration numbers, shared files, what goes in your report).
6. Your tasks in `docs/product/task-breakdown.md`, and the sections of
   `docs/product/specifications.md` and `docs/decisions.md` they refer to.

## Commands

- Setup in a new worktree: `flutter pub get` (`bash tool/setup.sh` on a
  new machine).
- Check after every change: `bash tool/check.sh` — format, analyze, tests;
  full log in `tool/logs/check.log`. It must be OK before a pull request.
- Builds, before a pull request that touches `android/`, `ios/`,
  `pubspec.yaml` or plugins: `bash tool/check.sh build`.

## Rules that matter most

- Work only in your own git worktree and on the tasks you were given.
- One branch and one pull request per task (`feat/f26-01-division-domain`),
  Conventional Commits with `Refs: F26-01`, never a commit on `main`, never
  a merge. The hooks in `.githooks/` check branch and commit names.
- Tick your task in `docs/product/task-breakdown.md` in the commit that
  completes it. Never edit `docs/status.md` or `docs/decisions.md`.
- Use only the migration number you were given.
- No hard-coded user-facing text: every text in `lib/l10n/app_fr.arb`,
  `app_en.arb` and `app_es.arb`, with its description; apply the checklist
  of `.claude/agents/i18n-guardian.md`.
- Never write Wolof or another local language: the owner does.
- All code, comments and documentation in English.

## Final message

End with the report described for `lot-implementer` in
`.claude/agents/lot-implementer.md` ("Final report"): tasks and pull
requests in merge order, migration, packages, ARB keys, what needs the
owner's validation, lines for `docs/status.md` and `docs/decisions.md`,
check result.
