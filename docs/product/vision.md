# Impact Hub: vision

Status: Draft
<!-- Step 0, Discover. No real users have been observed. Claims are Evidence: assumption,
     or public material when they come from docs/product/research.md (R1 to R8). -->

## Vision statement
For safety surveyors and engineers who must specify barriers that will stop real
vehicles on industrial sites, Impact Hub is a survey and specification tool that computes the
impact energy of every hazard point and recommends only barriers that cover it and fit.
Unlike a survey on paper or in a spreadsheet, every number has a rule behind it, every
unknown says what is missing, and no recommendation can be weaker than the hazard.

## Problem
A barrier specification depends on facts gathered on site: which vehicles pass, their
mass and load, their speed, the angle they could hit at, and the space behind the
barrier (research R2, R4). Today that judgement is easy to get wrong and hard to check
afterwards. A heavier load, a faster vehicle or a smaller gap changes the answer, and a
barrier chosen too weak fails at the moment it matters. Evidence: public material
(R2, R3, R4) plus assumption about how surveys are recorded.

## Outcomes
| Outcome | How we would measure it | Evidence |
|---|---|---|
| A surveyor turns a site walk into a justified specification without recalculating by hand | Time from first hazard point to a full recommendation in a walk-through | assumption |
| Anyone can check why a barrier was chosen | Every energy and every fit verdict traces to a rule in the spec (true by design) | assumption |
| No hazard gets a barrier weaker than its required energy | Rule tests; zero recommendations below the required energy | assumption |
| Points that no standard barrier covers reach an engineer | Share of points marked "engineering review" that an engineer confirms | assumption |

## Non-goals
- Replacing the PAS 13 standard or certifying compliance: the tool shows the
  calculation; a person signs the specification.
- Numbers produced by an LLM (P4).
- Using any real manufacturer's catalog, name or branding (spec constraint C4, change 001).
- Pricing, CAD drawings and ordering in the first change: they come later (system spec section 4).

## Assumptions to validate
| Assumption | How to validate | Status |
|---|---|---|
| Surveyors know vehicle mass, load and speed at survey time | Ask two surveyors which facts they most often have to estimate; count unknowns in a walk-through | open |
| The impact angle can be estimated per hazard point on site | Compare angles chosen by two people for the same layout | open |
| A conservative rule (rating at the smallest tested angle not below the hazard's) is acceptable to engineers | Review three recommendations with an engineer | open |
| The clearance behind a barrier is measured in surveys | Look at one real survey checklist | open |
