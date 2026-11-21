# 0004. Compute results each time a page is shown, and store none of them

Status: Accepted (2026-11-21)
Answers: Q1

## Context
Q1 and IH-25: while a survey is open, its values follow the current rules and catalog,
not those in force when it was saved. Once a specification is issued (phase 5), P5
freezes it. In 001 nothing is issued, so every survey is open.

## Decision
- `Surveys::AssessSurvey` runs the rules every time a survey page is requested.
- No table stores an energy, a verdict, an outcome or a recommendation, and no cache
  holds them.
- Phase 5 will store an issued specification as a frozen snapshot in its own tables,
  with the rules and catalog versions (P5). Open surveys never get one.

**Options considered:**
- Store results when saving, and recompute when the catalog or the rules change: this
  needs change tracking, and the day it misses a change, open surveys show stale
  barriers. That is the failure IH-25 rules out.
- A cache keyed by catalog version and rules version: premature for one page that does
  a few multiplications per point.

## Consequences
- IH-25 holds by construction.
- Each page view costs one query for the points, one for the barriers, and the rules in
  memory.
- Nothing has to be invalidated when the seed changes.
- Phase 5 must add versions for the rules and the catalog before it can freeze anything.
