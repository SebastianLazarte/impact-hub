# Intake Hub: system specification

Status: **Approved** (2026-11-20)

## 1. Problem
A small software team gets requests from many departments at once (sales, warehouse,
marketing, service). Someone has to understand each request, estimate how much time
it costs, decide what can be automated and with how much human control, and rank it
against everything else. Today that judgement lives in conversations and nobody can
check it afterwards.

Intake Hub makes that judgement explicit, computed by rules, and reviewable.

## 2. Users
| Who | Needs |
|---|---|
| Requester (any department) | Describe a process step by step without technical words |
| Software builder | See hours, automation score, method and required control per step; understand why |
| Team lead | A ranked backlog across departments; approve or reject with a recorded reason |

Personas and scenarios behind these users (assumptions until observed): [product/](../product/personas.md).

## 3. Principles and constraints
What must hold, not how. Each item says how it is checked. ADRs come later, in step 3
of a change: each answers one item here, and the item's "Decided in" cell then links
to it. Until then it reads "—".

### 3.1 Hard rules
| Id | Rule | Checked by | Decided in |
|---|---|---|---|
| P1 | **Code computes every number** (hours, scores). An LLM may only interpret text. | IH-1, IH-3 to IH-5 tests | — |
| P2 | **The LLM may raise a human control, never lower it.** | IH-5 test; phase 4 criteria | — |
| P3 | **A person approves** every item before it reaches the backlog (phase 5). | phase 5 criteria | — |
| P4 | **Hours are BigDecimal.** Unknown stays `nil` with a reason, never `0`. | IH-1, IH-2 tests | — |

### 3.2 Constraints
| Id | Constraint | Why | Checked by | Decided in |
|---|---|---|---|---|
| C1 | Ruby 3.4, Rails 8.1, PostgreSQL 17; pages in React + TypeScript served by Rails, with no separate JSON API | Routing, controllers and validation stay in Rails while pages are typed, with one app to deploy | IH-8 test; `bin/ci` | — |
| C2 | One deployable app in modules with enforced boundaries; the rules module depends on nothing | Rules stay testable alone and cannot reach a database, network or LLM | IH-7; `bin/packwerk check` | — |
| C3 | Every behaviour change is proposed, specified and approved by a person before code; every criterion is proven by one named test | Changes stay reviewable; nothing is built without a criterion | `test/traceability_test.rb`; review | — |

### 3.3 Quality requirements
| Id | Requirement | Checked by | Decided in |
|---|---|---|---|
| Q1 | **Scores follow the current rules until a person decides.** While a request is open, its scores follow the current rules; once a person approves or rejects it (phase 5), the scores that decision was based on never change. | IH-8 test; phase 5 criteria | — |

## 4. Scope by phase
| # | Delivers | Done when |
|---|---|---|
| 0 | WSL2 Ubuntu, Ruby 3.4, Rails 8.1, PostgreSQL 17, Node 22 | `rails -v` and `psql` work |
| 1 | Rails app, Inertia + React + TS + Vite, Packwerk, CI, AGENTS.md | A React page renders through Inertia; CI is green |
| 2 | `scoring` pack ([scoring.md](scoring.md)), test first | IH-1 to IH-8 green |
| 3 | `intake` pack: requests and steps CRUD in React | A request can be created and scored |
| 4 | `ai_assist` pack: fake LLM provider, Reconciler, Solid Queue job | The suggestion is shown and cannot lower a control |
| 5 | `triage` pack: ranked board, approve/reject with reason | Every decision recorded |

**This iteration: phases 0 to 2.** Out of scope now: authentication, a real LLM, deploy.

## 5. Acceptance criteria
The ids and texts live in [`requirements.yml`](../requirements.yml); each capability file
lists the ids it owns ([index](AGENTS.md)). Each test names the criterion it proves
(`test "IH-3: ..."`), and `test/traceability_test.rb` fails if a criterion has no test
or a test names an unknown criterion.

## 6. Open questions for review
None for the whole product. Questions about a capability live in its file.
