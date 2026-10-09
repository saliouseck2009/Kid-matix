# Git workflow

Binding for every change, by the owner or by a coding session. Every change
reaches `main` through a GitHub pull request. The hooks in `.githooks/`
enforce the branch, commit and push rules locally; `tool/setup.sh`
installs them (`git config core.hooksPath .githooks`) and
`tool/hooks_test.sh` (run by `tool/check.sh`) tests them. On GitHub, the
`CI` workflow runs the same `tool/check.sh` on every pull request.

## Branches

- `main` always builds and passes `bash tool/check.sh`. Nobody commits or
  pushes on it directly: the `pre-commit` hook refuses a commit on `main` and
  the `pre-push` hook refuses a push to `main`. It only moves when a pull
  request is merged.
- One branch per task of `docs/product/task-breakdown.md`, or per
  self-contained change outside the breakdown (a fix, a dependency bump, a
  docs update). Never two tasks on one branch.
- A branch starts from an up-to-date `main` and lives a short time.
- Name: `<type>/<slug>`, all lowercase, words joined by `-`. When the branch
  delivers a task, the slug starts with the task id:

  | Example | For |
  | --- | --- |
  | `feat/f1-03-profile-repository` | Task F1-03 |
  | `test/f2-07-question-generator` | A task that only adds tests |
  | `fix/f0-tab-bar-height` | A bug found in lot F0 |
  | `chore/bump-go-router` | Maintenance outside the breakdown |
  | `docs/f1-close` | Closing a lot (status, ticks, decisions) |

  Types are the commit types below. The `pre-commit` hook refuses any other
  name.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/),
checked by the `commit-msg` hook:

```
<type>(<scope>): <subject>

<body: why the change, what it does not do, wrapped at 72 columns>

Refs: F1-03
```

- **Type**: `feat` (new behavior for the player), `fix` (bug), `refactor`
  (no behavior change), `test`, `docs`, `chore` (tooling, generated files,
  dependencies), `build`, `ci`, `perf`, `style` (formatting only),
  `revert`. Add `!` after the scope for a breaking change (a schema or
  storage format change, for example).
- **Scope**: optional, lowercase kebab-case: a feature name (`profile`,
  `quiz`, `learning-path`...), `core`, `l10n`, `deps`, `theme`, `router`,
  `storage`.
- **Subject**: imperative mood, lowercase first letter, no final period,
  header of 72 characters at most. "add the nickname check", not "Added"
  or "Adds".
- **Body**: optional, separated by a blank line; explains why, not how.
  Lines of 100 characters at most (72 recommended).
- **Footer**: `Refs: F1-03` when the commit belongs to a task;
  `Co-Authored-By:` trailers when relevant.

One commit is one coherent step that leaves the project green: it builds,
`bash tool/check.sh` passes, and it can be reverted on its own. Do not mix a
refactor, a formatting pass and a feature in one commit. Tick a task in
`task-breakdown.md` in the commit that completes it.

## Life of a task

```bash
git switch main
git pull --ff-only
git switch -c feat/f1-03-profile-repository
# code, then:
bash tool/check.sh
git add -p
git commit
# when the task is done and check.sh is green:
git push -u origin HEAD
gh pr create --fill --base main
```

Then on GitHub (or with `gh`):

1. The pull request title follows the commit header format
   (`feat(profile): add the profile repository`); the description says what
   the task delivers, how it was checked (`tool/check.sh`, device or
   emulator) and ends with the task id (`Refs: F1-03`).
2. The `CI / check` status must be green (see "Continuous integration").
   A red run is fixed with new commits on the branch, never by merging
   anyway.
3. The owner reviews and merges with **"Create a merge commit"**, so
   `git log --first-parent main` reads as the list of delivered tasks. No
   squash, no rebase merge.
4. The branch is deleted after the merge (`gh pr merge --merge
   --delete-branch`).
5. Locally: `git switch main && git pull --ff-only && git branch -d <branch>`.

One pull request per task. A pull request that grows beyond one task is
split. Fixes asked in review are new commits on the same branch.

Never rewrite history that is already on `origin` (`push --force` on `main`
is forbidden). On your own branch, before the pull request is reviewed,
`git commit --fixup` and `git rebase -i --autosquash main` are fine to tidy
commits; push them with `git push --force-with-lease`.

## Continuous integration

`.github/workflows/ci.yml` runs on every pull request, on every push to
`main` and on demand. Its single job, `check`, installs Flutter 3.47.6 (the
version of `FLUTTER_VERSION` in the workflow) on Ubuntu and runs
`bash tool/check.sh`. With `CI=true`, the script rewrites nothing:

- the format step fails if `dart format` would change a file;
- the "generated files committed" step fails if `gen-l10n` or
  `build_runner` produce a file that differs from the committed one, so
  generated code (`lib/l10n/app_localizations*.dart`, `*.g.dart`) is always
  committed with its source.

When the run fails, the `check-log` artifact holds `tool/logs/check.log`.
Reproduce locally with `bash tool/check.sh` (or `CI=true bash
tool/check.sh` on a clean tree for the exact CI behavior).

Upgrading Flutter is its own change on its own branch (`chore/bump-flutter`):
update `FLUTTER_VERSION` in the workflow and the version in
`docs/status.md` together, and run the full check.

## Protection on GitHub

The hooks are local and `--no-verify` skips them. To make the rules hold on
the server, protect `main` in the repository settings (Settings, Branches,
or Rules):

- require a pull request before merging;
- require the status check `check` to pass, with the branch up to date;
- block force pushes and deletion.
