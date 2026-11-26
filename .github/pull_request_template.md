<!--
Which kind of PR is this?
- Work PR (feat/fix/chore/docs/ci -> dev): fill "Commits Included" and "Changes". Skip "PRs Included".
- Promotion PR (dev -> qa, qa -> main): fill "PRs Included" and "Changes" (summary level). Skip "Commits Included".
Delete, with their heading, the sections that do not apply or have nothing to say.
Never leave a section with only "N/A" or "None".
In the sections with options (Module, Type of change, Impact) keep ONLY the
selected option(s) and delete the rest.
Before opening the PR, see the self-review recommendations in CONTRIBUTING.md, section 5.
-->

## Summary

<!-- One or two sentences: what this PR does and why. The PR title follows Conventional Commits in English: type(scope): description -->

---

## Jira task

Closes: MPC-

<!-- Key of the Jira task. It must also be in the branch name (type/MPC-NN-...), which is what links this PR to the task in Jira. Promotion PRs: list the tasks included, e.g. MPC-80, MPC-83. -->

---

## Module

<!-- Module that owns the change (see DOC-GES-08, section 2). Keep only the selected option (several only in promotions or shared changes) and delete the others. -->

- [ ] **A**
- [ ] **B**
- [ ] **C**
- [ ] Shared (infrastructure, CI, Helm chart, libs, repository structure)

---

## Type of change

<!-- Keep only the selected option and delete the others. -->

- [ ] `feat`: new functionality
- [ ] `fix`: bug fix
- [ ] `refactor` / `perf`: no change in behavior (or faster)
- [ ] `test`: tests only
- [ ] `docs`: documentation only
- [ ] `build` / `ci` / `chore`: build, pipeline, tooling or repository structure
- [ ] Promotion (`dev` -> `qa` or `qa` -> `main`)

---

## Commits Included

<!-- Required in work PRs; delete this section in promotion PRs. One row per commit of the branch (merge commits are not listed). Last column: the subtask of the "Refs:" footer or, without it, the key of the task. CONTRIBUTING.md, section 4, has the command that prints the rows. Update the table if you push more commits. -->

| Commit | Title | Author | Jira subtask or task |
| --- | --- | --- | --- |
|        |       |        | MPC- |
|        |       |        | MPC- |

---

## PRs Included From Development or QA

<!-- Required in promotion PRs; delete this section in work PRs. One row per PR merged since the last promotion. -->

| PR | Title | Author | Jira | Service or area |
| --- | --- | --- | --- | --- |
| #  |       |        | MPC- |                 |
| #  |       |        | MPC- |                 |

---

## Changes

<!-- Required. Describe the changes that were applied, not only the title or the commit list. Use bullet lists, subheadings (for example one per service or subtask), paragraphs or a mix, whatever explains them best. -->

- 
- 
- 

---

## Important Breaking / Behavioral Changes (optional)

<!-- Only if something changes for other people or systems: removed or renamed API fields, new required configuration or environment variables, changed defaults, migrations that need to run in order, different behavior for users. Describe what changes and how to adapt. Delete this section otherwise. -->

- [ ] Breaking change (`!` in the title and `BREAKING CHANGE:` in the commit footer)

**What changes:**

**How to adapt:**

---

## Impact

<!-- Keep only the selected options and delete the others. If nothing applies, delete this section. -->

- [ ] Changes an API or event contract (OpenAPI, Avro, gRPC): contract updated and backward compatibility verified
- [ ] Changes a database schema or migration: migration is reversible (or expand/contract)
- [ ] Touches personal data: none in logs, metrics or traces, and access is audited
- [ ] Changes infrastructure, pipeline or Helm chart

---

## How it was tested

<!-- Tests added or run, commands, and manual checks. Example: ./gradlew :services:grading-service:test -->

- 

---

## Rollback plan

<!-- How to undo this change if it fails: revert the merge commit, disable the feature flag, roll back the migration... -->

---

## Screenshots or evidence (optional)

<!-- Only if there is a visible change. Remove personal data, secrets and tokens first: this repository is public. -->

---

## Notes for the reviewer (optional)

<!-- What to look at first, known limitations, follow-up work. -->
