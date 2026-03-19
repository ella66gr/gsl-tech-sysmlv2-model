# Session 44 Report — Stage 3 Phase 1: Paws Domain Model

**Date:** 19 March 2026
**Session type:** Implementation
**Duration:** Standard session
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session completed the primary implementation work for Stage 3 Phase 1: the Paws dog grooming demonstrator domain model. The model was written, validated in Syside (clean parse), and a design note produced. Additionally, the SysML syntax reference was reorganised with a stable filename convention to resolve a recurring findability problem.

**Key result:** Three structurally different service businesses (Cafe, Suds, Paws) are now modelled using exclusively General BMM vocabulary. The cross-domain validation threshold ([[concept-cross-domain-validation|J1]]) is met for confident generalisation of the BMM.

---

## 2. Context

Stage 2 was formally completed in Session 43 (13/13 exit criteria met). This session begins Stage 3, whose first phase is the Paws demonstrator — the third domain for cross-domain validation.

---

## 3. Work Completed

### 3.1 Syntax Reference Reorganisation

The syntax reference file had a recurring findability problem: the version-stamped filename (`gsl-sysml-v2-syntax-reference-v3.13-2026-03-15.md`) changed with each update, and Claude repeatedly failed to locate it at session start.

**Resolution:**
- Renamed the current file (actually containing v3.15 content) to a stable name: `gsl-sysml-v2-syntax-reference.md`
- Version number lives inside the document header, not in the filename
- Versioned snapshots preserved in `documentation/reference/syntax-versions/`
- Session preparation note updated with the stable path
- Memory edit added for cross-session continuity

Committed and pushed: `936557c Session 44: reorganise syntax reference — stable filename, version in header not filename`

### 3.2 Paws Domain Model

**Detailed implementation plan** produced and agreed before building (per [[ontara-development-workflow-guide-2026-03-17|workflow guide]] §4.2).

**Design decisions agreed:**

| # | Decision | Choice |
|---|---|---|
| P1-D1 | BMM accommodates appointment-based services | Yes, without strain |
| P1-D2 | Client/pet relationship | Cross-domain observation, not new part def |
| P1-D3 | Governance posture | General professional duty of care |
| P1-D4 | New Tailored part defs | No — all General vocabulary |

**Model file:** `exercises/paws-demonstrator/model/paws.sysml` — 51 elements across 3 packages:

| Package | Elements | Coverage |
|---|---|---|
| PawsBusinessModel | 28 | ServiceConcept (13) + ActivityModel (15) |
| PawsResourceFinancial | 18 | ResourcePlanning (8) + FinancialPlanning (10) |
| PawsGovernance | 5 | GovernanceMapping (4) + ExternalReference (1) |

**Syside validation:** Clean parse. All cross-project imports resolve. Enum usage (`ActivityCategory`, `GranularityLevel`, `PricingType`) resolves. Cross-package requirement usage (`requirement animalWelfareDutyOfCare : GovernanceRequirement`) resolves.

### 3.3 Design Note

Paws design note produced with:
- Structural comparison table (Cafe vs Suds vs Paws)
- General/Tailored classification (all 51 elements General)
- Four cross-domain observations (§4.1–§4.4)
- BMM vocabulary adequacy assessment: **adequate**

### 3.4 Regulatory Tier Classification

Informed by Perplexity research, the three demonstrators were mapped to a four-tier regulatory classification:

| Domain | Tier | Notes |
|---|---|---|
| Cafe | Generally governed | Generic business framework only |
| Paws | Lightly regulated | Animal Welfare Act 2006 — domain-specific beyond general framework |
| Suds | Lightly regulated | COSHH Regulations 2002 — more prescriptive than Animal Welfare Act |
| GSL (future) | Sector-regulated | CQC-regulated clinical service |

This maps well onto the governance posture spectrum in the design note (§4.2): the governance vocabulary handles all levels from minimal through to full satisfy chain.

---

## 4. Design Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| S44-D1 | Syntax reference filename convention | Stable name, version in header | Resolve recurring findability problem |
| P1-D1 | BMM accommodates appointments | Yes | `ServiceOffering`, `ActivityType` handle variable-duration scheduled services |
| P1-D2 | Client ≠ service recipient | Observation, not new part def | Parallels GSL patient; premature to abstract now |
| P1-D3 | Governance posture | General duty of care | No specific regulation; exercises vocabulary at lighter depth |
| P1-D4 | No new Tailored defs | Agreed | Stronger validation result if General suffices |

---

## 5. Documents Produced

- [[ontara-stage-3-phase-1-implementation-plan-2026-03-19|Phase 1 Implementation Plan]] (container artifact)
- [[paws-design-note-2026-03-19|Paws Design Note]] (container artifact → Obsidian `Demonstrators/Paws (Dog Grooming)/`)
- This session report (container artifact → Obsidian `Session Reports, Prep & Handover/`)
- Next session preparation note (container artifact → Obsidian `Session Reports, Prep & Handover/`)

---

## 6. Master Register Updates

| Entry | Change |
|---|---|
| **O13** | Paws domain created (Session 44). 3 packages, 51 elements, all General vocabulary. Three-domain cross-domain validation threshold (J1) met. Service subject ≠ customer observation captured. |

**Concepts exercised:** [[concept-cross-domain-validation|J1]] (three domains), [[principle-coffeeshop-first|A5]] (validate in toy domains), C1–C6 (five concerns), [[concept-general-tailored|B11]] (all General), [[concept-governance-toy-domains|J8]] (general professional governance), [[pattern-metadata-driven-generation|D9]] (metadata-driven generation — pending generator re-run), [[concept-co-evolution|J2]] (model + tooling — pending console verification).

---

## 7. Remaining Phase 1 Exit Criteria

- [x] `paws.sysml` exists and parses clean
- [x] Three packages, ~51 elements, all five BMM concerns
- [x] Design note written
- [ ] Generator re-run with three-domain coverage
- [ ] Console coverage matrix shows Cafe/Suds/Paws
- [x] Master register updated
- [x] Service subject observation captured

The generator re-run and console verification are mechanical steps for Session 45 (or Ella to complete independently).

---

## 8. Next Steps

1. **Ella:** Download and place design note in Obsidian `Demonstrators/Paws (Dog Grooming)/`
2. **Ella:** Download and place implementation plan in Obsidian `Plans/`
3. **Ella:** Download and place session report and prep note in Obsidian `Session Reports, Prep & Handover/`
4. **Ella / Claude Code:** Run generator (`python scripts/gen_model_introspection.py`) and verify three-domain coverage in console
5. **Ella:** Commit Paws model file to Git (command provided below)
6. **Session 45:** Begin Stage 3 Phase 2 (Glossary view) — or complete Phase 1 exit criteria first if generator/console not yet verified
7. **Separate discussion (queued):** Service subject ≠ customer — meta model implications, shoulder injection analogy

---

## 9. Git Commands

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
git add exercises/paws-demonstrator/
git commit -m "Session 44: Stage 3 Phase 1 — Paws dog grooming demonstrator (51 elements, 3 packages, all General BMM vocabulary)"
git push origin main
```

---

*Session report prepared 19 March 2026. Session 44.*
