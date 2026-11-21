# <Product>: system specification

Status: Draft
<!-- What holds for the whole product. Capability files beside this one hold the domain
     rules of each module. After the first approval this file changes only by merging a
     change's spec delta (step 4). What must hold, never how. -->

## 1. Problem
<!-- Who has the problem, what it costs them today, what the product makes possible.
     Link the vision, personas and scenarios in ../product/. -->

## 2. Users
| Who | Needs |
|---|---|

## 3. Principles and constraints
<!-- What must hold, not how. Every item has an id, unique across docs/specs/, and says
     how it is checked. ADRs come later, in step 3 of a change: each answers one item
     here, and the item's "Decided in" cell then links to it. Until then it reads "—". -->

### 3.1 Hazards
<!-- The worst outcomes the product could cause if it is wrong: who is harmed, and what
     would cause it. The hard rules come from here. -->
| Id | Hazard | Harm | Causes |
|---|---|---|---|
| H1 | | | |

### 3.2 Hard rules
<!-- One "never" or "always" rule per serious cause above. A hard rule protects against a
     serious harm, holds for every feature, can be checked, and says what must hold:
     never a type, a library or a tool. No change may break one without its own
     approved change. -->
| Id | Rule | Prevents | Checked by | Decided in |
|---|---|---|---|---|
| P1 | | H1 | | — |

### 3.3 Constraints
<!-- Organisational (stack, process, standards) or external (law, privacy, interop). -->
| Id | Constraint | Why | Checked by | Decided in |
|---|---|---|---|---|
| C1 | | | | — |

### 3.4 Quality requirements
<!-- Product qualities: reliability, maintainability, usability, performance, security.
     Measurable where possible. -->
| Id | Requirement | Checked by | Decided in |
|---|---|---|---|
| Q1 | | | — |

## 4. Scope by phase
| # | Delivers | Done when |
|---|---|---|

## 5. Acceptance criteria
The ids and texts live in [`requirements.yml`](../requirements.yml); each capability file lists the ids it owns.
Each test names the criterion it proves, and `test/traceability_test.rb` fails if a criterion
has no test or a test names an unknown criterion.

## 6. Open questions for review
<!-- Questions about the whole product. Questions about one capability live in its file. -->
