# Git workflow

Binding for every change, by the owner or by a coding session. The hooks in
`.githooks/` enforce the branch and commit rules locally; `tool/setup.sh`
installs them (`git config core.hooksPath .githooks`) and
`tool/hooks_test.sh` (run by `tool/check.sh`) tests them.

## Branches

- `main` always builds and passes `bash tool/check.sh`. Nobody commits on it
  directly: the `pre-commit` hook refuses it.
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
git switch main
git merge --no-ff feat/f1-03-profile-repository
git branch -d feat/f1-03-profile-repository
git push
```

Merging with `--no-ff` keeps one merge commit per task, so `git log
--first-parent main` reads as the list of delivered tasks. When the work goes
through GitHub pull requests instead, use "Create a merge commit" for the
same result; the branch rules do not change.

Never rewrite history that is already on `origin` (`push --force` on `main`
is forbidden). On your own unpushed branch, `git commit --fixup` and
`git rebase -i --autosquash main` are fine to tidy commits before merging.
