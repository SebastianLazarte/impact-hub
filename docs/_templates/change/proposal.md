# NNN. <Change title>

Status: Draft
Track: full
Owner: <name>
<!-- Status: Draft -> Approved (YYYY-MM-DD, by <name>) -> Done (YYYY-MM-DD), or
     Abandoned (YYYY-MM-DD, reason) at any point. One line, edited in place.
     Track: full | light. Light: keep Why (problem statement only), Scope, Criteria delta,
     Validation; delete the other sections. -->

## Why

### Problem statement
<!-- Define: <persona> needs <need> because <insight>. Link the persona and scenario. -->

### Stories
<!-- One per goal: As a <persona>, I want <goal> so that <value>. -->
- As a <persona>, I want <goal> so that <value>.

### Success measure
<!-- What we will observe after release that shows this worked, and when step 7 checks it. -->

## Options considered
<!-- Ideate: at least two, including "do nothing" when it is honest. -->
| Option | For | Against |
|---|---|---|

## Scope
- In:
- Out:

## Spec delta
<!-- Every spec file this change adds or rewrites lives in specs/ beside this proposal,
     complete, exactly as it will appear in docs/specs/: a reviewer diffs it against the
     current file. Behaviour goes in capability files; hard rules, constraints and
     quality requirements in system.md section 3, each with an id and how it is checked.
     What, never how: the how goes to design.md, or to an ADR that answers one of these
     items in step 3. Links inside specs/ are written relative to docs/specs/. -->
| File | Change | What and why |
|---|---|---|
| [specs/system.md](specs/system.md) | MODIFIED: section N | |
| [specs/<capability>.md](specs/<capability>.md) | ADDED | |
| `<capability>.md` | REMOVED | |

## Criteria delta
<!-- One observable behaviour per id, in EARS. Next free id: highest existing + 1.
       Ubiquitous  The system shall <response>.
       Event       When <trigger>, the system shall <response>.
       State       While <state>, the system shall <response>.
       Unwanted    If <condition>, then the system shall <response>.
       Optional    Where <feature is included>, the system shall <response>.
     Non-functional criteria start with their kind: (product), (organisational), (external). -->

ADDED:
```yaml
IH-n: >-
  When <trigger>, the system shall <response>.
```

MODIFIED: IH-n, old text -> new text, and why.

REMOVED: IH-n, and why. The tests that name it are removed in the same change.

## Decisions
<!-- Step 3, after the spec delta is approved: until then, list only the items that
     will need an answer. Then one line per ADR: the item it answers and its link
     (Status: Proposed). Or "none". -->

## Validation
<!-- Ticked by the author, checked by the approver, before Status: Approved. -->
- [ ] Validity: every story serves a persona need from the product folder.
- [ ] Consistency: no criterion conflicts with another, the spec or its principles.
- [ ] Section 3: every constraint and quality requirement says how it is checked, and
  states a need, not a solution.
- [ ] Completeness: every story has criteria, including the unwanted case (If ... then).
- [ ] Realism: buildable with the current stack inside this change.
- [ ] Verifiability: every criterion can be proven by one named test.

## Open questions
<!-- Each must be answered before Status: Approved. -->
