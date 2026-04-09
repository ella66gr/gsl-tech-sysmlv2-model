---
tags:
  - session-report
date: 2026-04-09
status: current
session: 183
---
# Session 183 Report — Phase 5 Step 5.1: Governance Data Model and Constraint Definitions

**Date:** 9 April 2026
**Session type:** Implementation
**Commit:** `bb08e94`

---

## Summary

Session 183 implemented Phase 5 Step 5.1 of [[ontara-stage8-plan-high-level-s.174-portal|Stage 8]] — the governance data model and constraint definitions. This is the foundational infrastructure for the final phase of the Ontara Portal. A Code Instruction Set A was produced during the Chat session and executed by Claude Code in a single pass across ten files.

### What was built

**Type system extensions** (`$lib/types.ts`). Five new types added: `GovernanceLevel` (exploratory | advisory | enforced), `ConstraintLevel` (hard | soft | graded), `GovernanceConstraint`, `ConstraintResult`, and `GovernanceAssessment`. Existing interfaces extended: `Domain.governanceLevel`, `DomainRow.governance_level`, `ModuleDefinition.governanceConstraints`. The `ModuleStateTransition.lifecycleType` union extended to include `'epistemic'` in preparation for Step 5.3 (promotion).

**Schema extensions** (`schema.sql`). Two columns added: `governance_level TEXT NOT NULL DEFAULT 'exploratory'` on `domains`; `governance_constraints TEXT NOT NULL DEFAULT '[]'` on `module_definitions`. Database reset required ([[ontara-ref-work-items|OW-21]] observed — all three SQLite files deleted).

**Seed data** (`seed.ts`). All 10 module definitions extended with governance constraints. 20 constraints total: 8 hard, 6 soft, 6 graded. The 6 business modules carry 2–3 constraints each (reflecting real business significance). The 2 generative and 2 analytical modules carry 1 each (they are tooling). INSERT statement updated to 11 columns.

**Domain data layer** (`domains.ts`). `mapDomain` extended to return `governanceLevel`. New `updateGovernanceLevel` function added.

**Module data layer** (`modules.ts`). `DefinitionRow` extended with `governance_constraints`. `mapDefinition` parses the JSON column. Both joined queries (`getInstancesForDomain` and `getInstanceById`) extended to select and pass through `md.governance_constraints as def_gc`.

**Governance evaluator engine** (`$lib/server/governance/`). Three new files:
- `evaluators.ts` — typed evaluator registry with 20 named evaluator functions. Each receives an `EvaluatorContext` (config values, domain, all installed modules) and returns `{ satisfied, explanation }`. Covers all constraint types: config presence checks, cross-field logic (e.g. VAT + currency), conditional checks (e.g. regulatory body required only for sector-regulated), cross-module checks (e.g. comparison mode + variant existence).
- `assess.ts` — `assessModule` runs all constraints for one module instance and returns a `GovernanceAssessment` with summary counts. `assessDomain` assesses all installed modules.
- `index.ts` — barrel exports.

**Settings page** (`settings/+page.server.ts`, `settings/+page.svelte`). New `updateGovernanceLevel` form action with super_admin guard and validation. UI card with three styled radio options matching the existing simulation fidelity pattern. Disabled for non-admins.

### Design decisions applied

- **S182-D1** (constraints as typed data objects): Implemented as `GovernanceConstraint` with evaluator key into a registry. Architecturally consistent with the three-way constraint hierarchy ([[concept-hard-constraint|HardConstraint]]/[[concept-soft-constraint|SoftConstraint]]/[[concept-graded-rule|GradedRule]]) but decoupled from OWL vocabulary.
- **S182-D2** (governance level as domain-wide setting): `exploratory` default for new domains. Independent of simulation fidelity.
- **S182-D6** (constraint evaluation server-side, computed on demand): Evaluators live in `$lib/server/governance/`. No separate results table — computed from live module config and domain state. Consistent with [[principle-intrinsic-self-knowledge|A10]].

---

## Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-separation-representation-execution|A1]] (Separation of representation and execution) | Governance constraints are representation (definitions in seed data); evaluation is execution (evaluator engine). The separation is clean |
| [[principle-self-describing-system|A2]] (Self-describing system) | Each constraint carries a human-readable description and each evaluation result carries an explanation |
| [[principle-deterministic-over-probabilistic|A6]] (Deterministic/auditable reasoning) | Every evaluator returns a deterministic result with an explanation — inspectable and auditable |
| [[principle-discipline-as-load-bearing-structure|A9]] (Discipline as load-bearing structure) | The three-level governance progression (exploratory → advisory → enforced) is itself a discipline structure for the operator |
| [[principle-intrinsic-self-knowledge|A10]] (Intrinsic self-knowledge) | Governance assessments are computed from live module state, not stored as static assessments |
| [[concept-non-constraining|J3]] (Non-constraining) | Constraint definitions are data objects with string evaluator keys — new constraint types and evaluators can be added without restructuring |

---

## OW Items Checked

| OW ID | Disposition |
|---|---|
| OW-19 | Honoured. Governance evaluator engine in `$lib/server/governance/` (server-only). Shared types in `$lib/types.ts`. No shared logic placed incorrectly |
| OW-20 | Not exercised this step (no client-only APIs added) |
| OW-21 | Honoured. DB reset instruction included in Code instruction set. All three files deleted before restart |
| OW-25 | Not exercised this step (no `{@const}` usage in settings page changes) |
| OW-17 | Foundational. The governance infrastructure built here is the prerequisite for the promotion path (Step 5.3). The three-way constraint hierarchy (hard/soft/graded) and the evaluator engine are the enforcement mechanism |

---

## Observations and Watchpoints

No new observations or watchpoints surfaced during this session. The implementation was a straightforward execution of the Phase 5 plan with no surprises or design tensions.

---

## Emergent Ideas

None captured this session.

---

## Tier 1 Principles Relevant to This Session

- **[[principle-separation-representation-execution|A1]]** — Governance constraint definitions (representation) are cleanly separated from evaluation (execution). The evaluator registry pattern keeps these independent.
- **[[principle-deterministic-over-probabilistic|A6]]** — Every governance evaluation is deterministic and produces an explanation string. No opaque pass/fail.
- **[[principle-discipline-as-load-bearing-structure|A9]]** — The governance level progression is a discipline structure for the operator, mirroring the platform's own commitment to discipline as load-bearing.
- **[[concept-non-constraining|J3]]** — The evaluator registry is keyed by string names, meaning new evaluators can be added without changing the type system or schema. Non-constraining.

---

## Currency Flags Noted at Open

- [[ontara-ref-vision-architecture|Vision & Architecture Reference]] is 14 sessions overdue (due ~S181, now S183). Work item W-038 added.
- [[—— ARCHITECTURE INDEX ——|Architecture Papers Index]] is at threshold (S171, due ~S183).
- [[ontara-ref-strategic-snapshot|Strategic snapshot]] approaches threshold next session (~S184).

These were noted but appropriately deferred from this implementation session.
