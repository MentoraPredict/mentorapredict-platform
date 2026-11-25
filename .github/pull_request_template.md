<!--
Which kind of PR is this?
- Work PR (feat/fix/chore/docs/ci -> dev): fill "Changes". Skip "PRs Included".
- Promotion PR (dev -> qa, qa -> main): fill "PRs Included" and "Changes" (summary level).
Delete the sections that do not apply, or write "N/A".
-->

## Summary

<!-- One or two sentences: what this PR does and why. The PR title follows Conventional Commits in English: type(scope): description -->

---

## Jira task

Closes: MPC-

<!-- Key of the Jira task. It must also be in the branch name (type/MPC-NN-...), which is what links this PR to the task in Jira. Promotion PRs: list the tasks included, e.g. MPC-80, MPC-83. -->

---

## Module

<!-- Module that owns the change (see DOC-GES-08, section 2). Check one; check several only in promotions or shared changes. -->

- [ ] **A**
- [ ] **B**
- [ ] **C**
- [ ] Shared (infrastructure, CI, Helm chart, libs, repository structure)

---

## Type of change

- [ ] `feat`: new functionality
- [ ] `fix`: bug fix
- [ ] `refactor` / `perf`: no change in behavior (or faster)
- [ ] `test`: tests only
- [ ] `docs`: documentation only
- [ ] `build` / `ci` / `chore`: build, pipeline, tooling or repository structure
- [ ] Promotion (`dev` -> `qa` or `qa` -> `main`)

---

## PRs Included From Development or QA

<!-- Required in promotion PRs. Leave "N/A" in work PRs. One row per PR merged since the last promotion. -->

| PR | Title | Author | Jira | Service or area |
| --- | --- | --- | --- | --- |
| #  |       |        | MPC- |                 |
| #  |       |        | MPC- |                 |

---

## Changes

<!-- One bullet per relevant change, grouped by service or folder if the PR touches several. -->

- 
- 
- 

---

## Important Breaking / Behavioral Changes (optional)

<!-- Only if something changes for other people or systems: removed or renamed API fields, new required configuration or environment variables, changed defaults, migrations that need to run in order, different behavior for users. Describe what changes and how to adapt. Write "None" otherwise. -->

- [ ] Breaking change (`!` in the title and `BREAKING CHANGE:` in the commit footer)

**What changes:**

**How to adapt:**

---

## Impact

- [ ] Changes an API or event contract (OpenAPI, Avro, gRPC): contract updated and backward compatibility verified
- [ ] Changes a database schema or migration: migration is reversible (or expand/contract)
- [ ] Touches personal data: none in logs, metrics or traces, and access is audited
- [ ] Changes infrastructure, pipeline or Helm chart
- [ ] None of the above

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

## Self-review checklist (DOC-CAL-06)

- [ ] **Code:** I reviewed the full diff myself; commits follow Conventional Commits in English
- [ ] **Size:** the PR is small (about 400 changed lines or fewer) or the size is justified (always true for promotions)
- [ ] **Tests:** unit tests of the domain and, if it touches another service, integration or contract tests; all pass
- [ ] **Contract:** if a route or event changes, the OpenAPI is updated
- [ ] **Security:** routes require session and role, there is a negative test, and no secrets, AWS account IDs or real data
- [ ] **Environment:** works with the single startup command and the seeds
- [ ] **Acceptance:** the acceptance criterion of the requirement (`RF-...`) was checked
- [ ] **Documentation:** if the behavior changes, the owner document was updated

---

## Notes for the reviewer (optional)

<!-- What to look at first, known limitations, follow-up work. -->
