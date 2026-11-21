# docs/changes: one folder per behaviour change

Method: product-sdlc, the process required by C3 in [docs/specs/system.md](../specs/system.md).

A change is a folder `NNN-slug/` (next free number, kebab-case slug) copied from
[docs/_templates/change/](../_templates/change/proposal.md), worked on a branch
`change/NNN-slug`. The folder states its status in the `Status:` line of its
`proposal.md`. Finished changes live in `archive/`, and so do abandoned ones:
`Status: Abandoned (date, reason)`, with their criteria never merged.

## Inputs
- Working: `docs/changes/NNN-slug/`.
- Reference: [docs/specs/](../specs/AGENTS.md) (system.md and the capability files the
  change touches), [docs/requirements.yml](../requirements.yml), `docs/adr/` once ADRs
  exist, [docs/product/](../product/personas.md) (vision, personas,
  scenarios), and the `AGENTS.md` of every pack the change touches.
- Do not load: other change folders, `archive/`, unrelated packs.

## Tracks
- **Full**: a new feature, new IH-n, a new pack. Steps 1 to 8.
- **Light**: a fix, a refactor, a criterion reworded with the same meaning. The proposal
  keeps Why (problem statement), Scope, Criteria delta and Validation. Steps 1, 2, 4, 5, 6, 8.

## Steps and checks
Each step stops at its check; nothing moves on until it passes. Steps 1 to 3 may loop.

| Step | Do | Check |
|---|---|---|
| 1. Define + propose | Problem statement, stories (persona, scenario), success measure, options, scope, owner. | A person sets `Status: Approved (date, by name)`. |
| 2. Specify | Complete spec files in `NNN-slug/specs/`, as they will appear in `docs/specs/` (behaviour, plus the hard rules, constraints and quality requirements of system.md section 3), listed in the proposal's Spec delta; criteria delta in EARS, in the proposal. No ADR yet. | Validation checklist ticked; open questions answered. |
| 3. Design | `design.md`: approach, packs, data, pages, low-fi sketch, scenario walk. Binding choices become ADRs with `Status: Proposed`, each naming on its `Answers:` line the spec item it meets. | A person approves the design and its ADRs. |
| 4. Merge spec | Copy `NNN-slug/specs/*` into `docs/specs/`, delete the files marked REMOVED, update the index, and copy the criteria delta into `docs/requirements.yml`, word for word. Fill `tasks.md`. | `bin/rails test test/traceability_test.rb` fails, naming exactly the new ids. |
| 5. Build | Per task: write `test "IH-n: ..."`, watch it fail, write the code. | `bin/ci` green. |
| 6. Review | Open a PR from [the template](../../.github/pull_request_template.md). | A person reviews the code against the proposal. |
| 7. Release + observe | Deploy; check the success measure; open new changes for what you learn. | Measure recorded in the proposal, or `N/A: <reason>` (deploy is out of scope in spec section 4). |
| 8. Archive | `Status: Done (date)`; move the folder to `archive/`. | Spec and `requirements.yml` contain the delta; tasks ticked. |

## Rules
- The proposal never becomes a second spec: after step 4 the spec is the truth.
- Links inside `NNN-slug/specs/` are written relative to `docs/specs/`; they resolve
  once the files are copied in step 4.
- Criteria describe observable behaviour. How it is built goes in `design.md` or an ADR.
- Spec first, then ADRs. An ADR answers an item of the spec or of the approved spec
  delta. A decision with no item behind it goes back to step 2; a choice no item needs
  stays in `design.md`. Product and scope choices live in the proposal, not in ADRs.
- A MODIFIED or REMOVED criterion needs its reason. Removing an IH-n removes the tests
  that name it in the same change.
- Never change a criterion during step 5 to make a test pass. Stop and reopen step 1.
- Scope found mid-change becomes a new change folder.
