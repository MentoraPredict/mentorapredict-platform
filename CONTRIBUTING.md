# Contributing guide

This guide summarizes how to work in `mentorapredict-services` and `mentorapredict-clients` (the rules are the same in both).

**Language:** commit messages, pull request titles and branch descriptions are written **in English**.

## 1. Workflow at a glance

1. Start from an up-to-date `dev`.
2. Create a work branch.
3. Make small commits that follow Conventional Commits.
4. Open a pull request (PR) to `dev` and fill in the template.
5. Review your own PR and merge it with a merge commit.
6. Promotion `dev` → `qa` → `main` is done by PR; the step to `main` is approved by the instructor.

## 2. Branches

Permanent branches: `dev` (development and integration), `qa` (release candidate) and `main` (production). They are protected: nobody pushes directly.

Work branches start from `dev`, live less than 2 days and use this format:

```text
<type>/<JIRA>-<cod>-<description>
```

- `type`: `feat`, `fix`, `chore`, `docs` or `ci`.
- `JIRA`: the key of the Jira task (for example `MPC-123`), when there is one. **It is what links the branch and the PR to the task.**
- `cod`: code of the service or area (`grd`, `idn`, `infra`, `web`...).
- `description`: in English, lowercase and hyphenated.

Examples:

```text
feat/MPC-123-grd-quarter-closing
fix/MPC-124-att-late-justification
chore/MPC-80-infra-base-structure
docs/MPC-86-docs-readme-contributing-guide
```

```bash
git checkout dev
git pull
git checkout -b feat/MPC-123-grd-quarter-closing
```

The branch `release/<cod>-<MAJOR.MINOR>` exists only to fix an already published version.

## 3. Commits

Conventional Commits format:

```text
type(scope): description
```

- **type:** `feat`, `fix`, `perf`, `refactor`, `test`, `docs`, `build`, `ci`, `chore` or `revert`.
- **scope:** the service code (`grd`, `idn`...) or `web`, `mobile`, `desktop`, `contracts`, `platform`, `infra`, `gitops`, `docs`.
- **description:** in English, imperative mood, at most 72 characters and no final period.
- The body, if any, is also in English.
- The Jira key does **not** go in the commit: it is enough that it is in the branch name.

Examples:

```text
feat(grd): calculate the weighted average of the quarter
fix(att): allow late justification
chore(infra): create base monorepo structure
docs(docs): write README and contributing guide
```

Because every merge is a merge commit, all the commits of the branch are kept. So **every commit** must follow the format (`commitlint` validates it), not only the PR title.

A breaking change adds `!` after the scope (`feat(grd)!: ...`) and `BREAKING CHANGE:` in the commit footer.

## 4. Pull requests

- **Title:** in English and with the same format as a commit: `type(scope): description`. The titles feed the automatic release notes.
- **Target:** `dev`. Promotions go from `dev` to `qa` and from `qa` to `main`.
- **Size:** 400 changed lines or fewer; if it is larger, justify the size.
- **Template:** fill it in completely. In the sections with options (Module, Type of change, Impact) keep only the selected option and delete the rest. In the self-review checklist keep every item.
- **Task:** write the key in "Closes: MPC-NN".
- **Public repository:** do not push secrets, AWS account IDs or real student data.

## 5. Review and merge

| Target | Approvals | Who merges |
| --- | --- | --- |
| `dev` | 0 | The author, after reviewing their own code |
| `qa` | 0 | The author |
| `main` | 1, from the course instructor | The author, once approved |

- There is no cross review and no first-review deadline between developers: **each person reviews their own code** with the self-review checklist of the template.
- Merge method: always merge commit. No squash and no rebase, so `dev`, `qa` and `main` do not diverge.
- If continuous integration fails, do not merge.

## 6. Promotion between environments

1. PR from `dev` to `qa`, titled `chore(release): promote dev to qa`.
2. PR from `qa` to `main`, titled `chore(release): promote qa to main`; the instructor approves it.
3. In both PRs, fill in the table "PRs Included From Development or QA" with the PRs merged since the last promotion.

## 7. If something goes wrong

- **You merged something wrong:** do not rewrite history. Open a revert PR with `git revert`, titled `revert: ...`.
- **Your branch is out of date:** bring `dev` into your branch with `git merge origin/dev` and solve the conflicts before opening the PR.
- **Doubts about a rule:** ask the owner of your module.
