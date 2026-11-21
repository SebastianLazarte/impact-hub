# Intake Hub

A small Rails 8 app that turns departmental requests ("can software help with this?")
into scored, reviewable backlog items. It applies the approach of my
[AI Process Discovery](https://github.com/SebastianLazarte/ai-process-discovery)
project to a Rails 8 + Inertia + React stack.

- **Rules compute every number.** Hours per month, automation score, method and the
  required human control come from plain Ruby rules, never from an LLM.
- **The LLM may raise a control, never lower it** (phase 4).
- **A person approves** every item before it reaches the backlog (phase 5).

## Stack
Rails 8.1 · Ruby 3.4 · PostgreSQL 17 · Inertia.js + React 19 + TypeScript + Vite ·
Tailwind · Packwerk · Solid Queue · Minitest · GitHub Actions

## Structure
```
packs/scoring/      pure rules, depends on nothing (Packwerk strict)
app/                Rails controllers + Inertia pages (app/frontend/pages)
docs/specs/         what the app must do: system.md + one file per capability
docs/requirements.yml  acceptance criteria IH-n, each proven by a named test
```

## Quality gates
- Every acceptance criterion has a test and every test names a criterion (`test/traceability_test.rb`).
- Decision tables are tested exhaustively, not by a few examples.
- Packwerk enforces pack boundaries; `test/boundaries_test.rb` keeps Rails, the database and LLMs out of `scoring`.
- RuboCop, Brakeman, bundler-audit and TypeScript run in CI (`bin/ci` runs the same steps locally).

## Run it
```bash
bin/setup          # gems, npm packages, database
bin/dev            # Rails + Vite on http://localhost:3000
bin/ci             # every CI gate locally
```

## Roadmap
| Phase | Delivers | Status |
|---|---|---|
| 0-1 | Environment, Rails + Inertia + React, Packwerk, CI, docs | done |
| 2 | `scoring` pack, test first | done |
| 3 | `intake`: requests and steps CRUD | next |
| 4 | `ai_assist`: fake LLM provider, Reconciler, Solid Queue job | planned |
| 5 | `triage`: ranked board, approve/reject with a reason | planned |
