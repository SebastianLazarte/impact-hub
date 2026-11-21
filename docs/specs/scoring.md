# Scoring: specification

Status: **Approved** (2026-11-20)
Pack: `packs/scoring`, pure Ruby, depends on nothing (C2, IH-7)
Criteria: IH-1 to IH-8

## 1. Purpose
Turn the facts of one process step into hours per month, an automation score, a method
and the human control it needs, so a software builder can see what to automate and why.
Every number is computed by code (P1), and a control can only be raised (P2).

## 2. Step
A **step** has:
| Field | Type | Unknown allowed |
|---|---|---|
| `minutes_per_run` | decimal >= 0 | yes |
| `runs_per_month` | decimal >= 0 | yes |
| `input_type` | `structured` / `semi` / `unstructured` | no |
| `rule_clarity` | `clear` / `partial` / `judgement` | no |
| `exception_rate` | decimal 0..1 | yes |
| `sensitive_data` | boolean | no |

Invalid values are rejected when the step is built (IH-6).

## 3. Hours per month (IH-1, IH-2)
`minutes_per_run x runs_per_month / 60`, BigDecimal, 2 places, rounded half up.
Missing minutes or runs gives unknown with a reason (P4).

## 4. Automation score 0..100 (IH-3)
| Factor | Points |
|---|---|
| input type | structured 50, semi 30, unstructured 10 |
| rule clarity | clear 50, partial 25, judgement 0 |
| exceptions | minus `exception_rate x 50`, rounded half up |

The result is clamped to 0..100. Missing exception rate gives unknown with a reason.
More exceptions never raise the score.

## 5. Method (IH-4)
| Condition (first match wins) | Method |
|---|---|
| rule clarity is `judgement` | `human` |
| `structured` and `clear` | `rules` |
| anything else | `ai_assisted` |

## 6. Required control (IH-5)
Controls are ordered `none < review < approve`.
| Method | Base control |
|---|---|
| `rules` | `none` |
| `ai_assisted` | `review` |
| `human` | `approve` |

Sensitive data raises the control to at least `approve`. A rule can only raise a
control (through `Scoring::Levels.stricter`), never lower it (P2).

## 7. Showing scores (IH-8)
The home page shows sample steps with the scores computed by these rules, hours as
decimal text and every unknown with its reason.

## 8. Open questions for review
- Are the decision-table points (section 4) reasonable, or should exceptions weigh more?
- Should `semi` + `clear` be `rules` instead of `ai_assisted`?
- Should a high exception rate (for example > 0.3) raise the control to `review` even for `rules`?
