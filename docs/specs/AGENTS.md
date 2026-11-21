# docs/specs: what the system must do

The single source of truth for behaviour. [system.md](system.md) holds what applies to
the whole product: problem, users, principles and constraints (P, C, Q) and scope by
phase. Each capability has its own file, implemented by one pack. Criterion texts live
in [requirements.yml](../requirements.yml); each capability file lists the ids it owns.

| File | Capability | Pack | Criteria |
|---|---|---|---|
| [system.md](system.md) | the whole product | all | P1 to P4, C1 to C3, Q1 |
| [scoring.md](scoring.md) | automation scoring of process steps | `packs/scoring` | IH-1 to IH-8 |

## Rules
- Ids are unique across this folder (P1, C2, Q1, IH-n). Cite the id, not the file or
  section, so moving text never breaks a reference.
- What must hold, never how. The how goes to a change's `design.md` or to an ADR.
- These files change only in step 4 of a change ([docs/changes/AGENTS.md](../changes/AGENTS.md)),
  by copying its approved delta word for word. Nobody edits them directly.
- No ADRs exist yet. They come in step 3 of a change, never before: each answers one
  item here on its `Answers:` line, and the item's "Decided in" cell links back.
- New capability files are copied from [docs/_templates/specs/capability.md](../_templates/specs/capability.md).
- A file stays reviewable in one sitting (about 300 lines); past that, split the capability.
