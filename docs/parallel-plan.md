# Parallel work plan — version 2.0

How several agents (Claude Code subagents, extra Claude Code sessions,
Codex) implement the lots F23 to F32 at the same time without stepping on
each other. The tasks are in `docs/product/task-breakdown.md`; this file
says who does what, in which wave, and with which shared resources.

## Roles and models

The model is chosen per role to spend tokens where they matter. Running
agents in parallel saves time, not tokens: each agent reads `CLAUDE.md`,
the rules and the code it needs.

| Role | Tool | Model | Does |
| --- | --- | --- | --- |
| Orchestrator | Main Claude Code session | Opus | Plans the wave, reserves migration numbers, launches the agents, reads their reports, runs the reviews, updates `docs/status.md` and `docs/decisions.md`, asks the owner |
| Lot implementer | Subagent `lot-implementer`, or an extra `claude --worktree` session | Sonnet; Opus for the lots that set a pattern others follow (F24, F29) | Codes a lot, one branch and one pull request per task |
| Content writer | Subagent `content-writer` | Haiku | Content tables, guides, translations; no app code |
| Second implementer | Codex (`codex exec`) in its own git worktree | The Codex model of your choice | A lot that touches no file of the other lots of the wave |
| Reviewer | Subagent `code-reviewer`, or Codex for lots written by Claude | Opus | Reviews the pull requests of a lot before the owner merges them |
| Text checker | Subagent `i18n-guardian` | Inherits | Run by the orchestrator on a branch when the reviewer flags texts |

Cross-review: a lot written by Claude is reviewed by Codex or by
`code-reviewer`; a lot written by Codex is reviewed by `code-reviewer`. An
agent never reviews its own work.

The owner merges every pull request, with a merge commit, in the order the
reports give.

## Shared resources

These are the files where parallel lots collide. The rules below hold for
every agent.

| Resource | Rule |
| --- | --- |
| Database migrations (`lib/core/storage/migrations/`, `appMigrations`) | The schema version is global. A lot may only use the number reserved for it below. Before merging a wave, the orchestrator checks that the numbers are consecutive in merge order; when a lot did not need its number, the lots after it are renumbered before merge (nothing of version 2.0 is released yet). |
| ARB files (`lib/l10n/app_*.arb`) | Keys go next to the keys of their feature, never at the end of the file, in the three languages. A conflict at merge is resolved by keeping both sides. Generated `app_localizations*.dart` are regenerated after the merge (`flutter gen-l10n`), never merged by hand. |
| `docs/product/task-breakdown.md` | Each agent ticks only its own tasks, in the commit that completes them (different sections, so no conflict). |
| `docs/status.md`, `docs/decisions.md` | Orchestrator only. Agents put what these files should say in their report. |
| `pubspec.yaml`, `pubspec.lock` | A lot adds a package only when its task needs it, and says so in its report; the orchestrator merges that lot first in the wave. |
| `core/` shared code (`core/services/`, `core/quiz/`, router, DI) | A lot that must change a shared interface says so in its report; when two lots of a wave change the same file, the orchestrator merges them one after the other and rebases the second. |

## Waves

A wave starts when the previous one is merged. Within a wave, lots run in
parallel.

The reserved numbers below were shifted down by one after wave 1, since
F24 needed no migration (rule of the shared resources above).
Wave 2 starts once F23 (#104) and the F24 follow-up
(`refactor/f24-domain-pattern`: final numbers keys, `number/` folder,
unit names by slug) are merged, so that F25, F26 and F28 copy the final
pattern. F25, F26 and F28 each add a domain, so they append lines to the
same shared places (`LearningDomainIds`, `DomainNaming`, `MonsterFamily`,
`injection_container.dart`, the ARB files, `math_operator.dart`,
`prompt_reading.dart`): merge them one after the other (F25, F26, F28),
each bringing `main` in before its merge.

| Wave | Lot | Agent | Reserved migration | Notes |
| --- | --- | --- | --- | --- |
| 1 | F23 · Read aloud | `lot-implementer` (Sonnet) | 012 (per-player read-aloud setting) | |
| 1 | F24 · Numbers up to 100 | `lot-implementer` (Opus) | none (013 was not used: the last domain is a preference) | Sets the multi-domain pattern (domain selector, `domainId` everywhere) for F25, F26, F28 |
| 1 | F28-01 and the guide of F28-02 | `content-writer` (Haiku) | none | The owner then fills the Wolof columns and records the audio |
| 2 | F25 · Addition and subtraction | `lot-implementer` (Sonnet) | none expected | Follows the pattern of F24; also extends the daily review to every domain and doubles the time of counting questions (owner) |
| 2 | F26 · Division | `lot-implementer` (Sonnet) | none expected | A new feature folder; the owner chose a Claude subagent over Codex (2026-10-18) |
| 2 | F28 · Math words, the rest (script of F28-02, F28-03 to F28-13) | `lot-implementer` (Sonnet) | 013 (per-player audio help setting) | Needs the content table filled by the owner for the end-to-end check |
| 3 | F27 · Placement by skill | `lot-implementer` (Sonnet) | 014 (dated placement results) | |
| 3 | F29 · Class mode | `lot-implementer` (Opus) | 015 (classes, students, assignments) | Starts only after the owner answers F29-01 (shared tablets or families' phones, class size) |
| 4 | F30 · Word problems | `content-writer` (Haiku) for F30-01, then `lot-implementer` (Sonnet) | 016 (only if needed) | The code starts once `problems.md` is written, so templates and content agree |
| 4 | F31 · Progress measurement | `lot-implementer` (Opus) | 017 | The owner chose a Claude subagent over Codex (2026-10-25); includes the teacher's own recordings (microphone) and QR codes (camera), both asked only from the teacher area |
| 5 | F32 · Other help languages | To decide with the partners | 019 (018 was taken by F31 for the pupil numbers) | F32-03 needs the owner's decision first |

## How to launch

### A. Subagents from the main session (recommended)

The agents are defined in `.claude/agents/`. In the main Claude Code
session, on an up-to-date `main`:

```
Lance la vague 1 de docs/parallel-plan.md : un sous-agent lot-implementer
pour F23 (migration 012), un sous-agent lot-implementer avec le modèle opus
pour F24 (migration 013 si besoin), et un sous-agent content-writer pour
F28-01 et la partie guide de F28-02. Quand ils ont fini, lance
code-reviewer sur les pull requests de chaque lot, puis donne-moi l'ordre
de fusion, les points à valider et mets à jour docs/status.md.
```

Each subagent runs in a temporary worktree (`isolation: worktree`) branched
from the default branch.

### B. Extra Claude Code sessions in terminals

```bash
cd kid_matix
claude --worktree f23-read-aloud --model sonnet
# in the session:
# Fais le lot F23 en suivant .claude/agents/lot-implementer.md (migration 012).
```

### C. Codex in its own git worktree

```bash
cd kid_matix
git fetch origin
git worktree add ../kid_matix-f26 -b feat/f26-01-division-domain origin/main
cd ../kid_matix-f26
flutter pub get
codex exec "Read AGENTS.md, then implement lot F26 of
docs/product/task-breakdown.md (tasks F26-01 to F26-05). No migration is
reserved for this lot. One branch and one pull request per task, stacked
when a task builds on the previous one. End with the final report of
AGENTS.md."
```

Pick the model with Codex's own option (`codex exec --help`). When the
lot is merged: `git worktree remove ../kid_matix-f26`.

## Orchestrator checklist

Before a wave:

- [ ] The previous wave is merged; `main` is up to date and green.
- [ ] The owner has answered the questions the wave needs (F29-01 for
      wave 3).
- [ ] Migration numbers are still free (`ls lib/core/storage/migrations`).

After each lot:

- [ ] Read the agent's report; run `code-reviewer` (or Codex) on its pull
      requests.
- [ ] Give the owner the merge order, the review verdicts and the points
      to validate (screens without mockup, texts, product choices).
- [ ] After the merges: migrations consecutive, `bash tool/check.sh` green
      on `main`, worktrees removed.
- [ ] Update `docs/status.md` (lot closure, what it delivered, known gaps)
      and `docs/decisions.md` from the reports, on a `docs/fxx-close`
      branch.
