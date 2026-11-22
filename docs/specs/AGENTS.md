# docs/specs: what the system must do

The single source of truth for behaviour. [system.md](system.md) holds what applies to
the whole product: problem, users, principles and constraints (P, C, Q) and scope by
phase. Each capability has its own file, implemented by one pack. Criterion texts live
in [requirements.yml](../requirements.yml); each capability file lists the ids it owns.

| File | Capability | Pack | Criteria |
|---|---|---|---|
| [system.md](system.md) | the whole product | all | P1 to P6, C1 to C4, Q1 to Q3 |
| [impact.md](impact.md) | required energy and barrier match | `packs/impact` | IH-7, IH-14 to IH-19, IH-23, IH-24 |
| [survey.md](survey.md) | a survey and its hazard points | `packs/surveys` | IH-20, IH-21, IH-25 |
| [catalog.md](catalog.md) | the barriers and their fictional data | `packs/catalog` | IH-22 |

## Rules
- Ids are unique across this folder (P1, C2, Q1, IH-n). Cite the id, not the file or
  section, so moving text never breaks a reference.
- What must hold, never how. The how goes to a change's `design.md` or to an ADR.
- These files change only in step 4 of a change ([docs/changes/AGENTS.md](../changes/AGENTS.md)),
  by copying its approved delta word for word. Nobody edits them directly.
- ADRs live in [docs/adr/](../adr/). Each answers one item here on its `Answers:` line,
  and the item's "Decided in" cell links back. They are written in step 3 of a change,
  never before.
- New capability files are copied from [docs/_templates/specs/capability.md](../_templates/specs/capability.md).
- A file stays reviewable in one sitting (about 300 lines); past that, split the capability.
