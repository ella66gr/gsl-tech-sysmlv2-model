# Session 47 Report — Structured Project Review: Tiered Register and Governance Strengthening

**Date:** 20 March 2026
**Session type:** Project review and governance restructuring
**Participants:** Ella Green, Claude (Opus 4.6)

---

## 1. Summary

This session executed the structured project review identified as necessary at the close of Session 46. The primary deliverable is a **tiered restructure of the master register**, introducing four tiers of influence (Governing Principles, Structural Commitments, Design Decisions, Future Directions) and integrating seven new concepts from Sessions 45–46. No code was written. The session also assessed the currency of governing documents and formalised the discussion paper pipeline convention.

**Key results:**
- **Tiered master register produced** — all ~160 concepts assigned to one of four tiers, with criteria, cross-cutting touchpoints for Tier 1, and a quick-reference section for session-start review.
- **10 Tier 1 Governing Principles established** — A1, A2, A3, A4, A6, A9, A10 (intrinsic self-knowledge), A11 (unity principle), J2 (co-evolution), J3 (non-constraining). Small enough to check every session, comprehensive enough to catch architectural violations.
- **7 new concepts integrated** from Sessions 45–46: A10, A11, B14 (weighted relationships), I16 (comprehension traversal schema), I17 (authored/intrinsic distinction), I18 (inferential comprehension), M7 (reasoning formalisms research).
- **Governing document currency assessed** — strategic snapshot (Session 31/34) is significantly out of date; vision reference (Session 35/45) is partially current but missing comprehension architecture depth. Both need refreshing in a subsequent session.
- **Discussion paper pipeline formalised** — convention established: when a discussion paper introduces binding concepts, the session report identifies them and the register update adds them at the appropriate tier.
- **Tier 2 cross-cutting tracing** agreed as lightweight — done at implementation planning time rather than pre-computed for all ~35 items.
- **A3 one-line test refined by Ella** — now reads "SysML v2 is the single source of truth for all generated artefacts and canonical structure / function / semantics."

---

## 2. Context

Session 46 was a rich design discussion that introduced foundational concepts (intrinsic self-knowledge, unity principle, weighted relationships, inferential comprehension) with implications across the entire platform. The session concluded with a decision to undertake a structured project review before proceeding with Phase 3 implementation, having identified four gaps in the project's governance structure:

1. The register was flat where the architecture is layered
2. Governing documents didn't reflect current depth
3. Cross-cutting concerns weren't explicitly traced
4. The discussion paper → binding commitment pipeline was informal

---

## 3. Work Performed

### 3.1 Tier criteria established

Four tiers defined by influence level, check frequency, and violation standard:

| Tier | Name | When checked | Violation standard |
|---|---|---|---|
| T1 | Governing Principles (~10) | Every session start | Only with explicit justification |
| T2 | Structural Commitments (~35) | Starting workstreams/phases | Ignoring produces structurally unsound work |
| T3 | Design Decisions and Conventions (~85) | Working in their domain | Revisable within architectural constraints |
| T4 | Future Directions and Horizon Items (~30) | Periodic review | Current work must not foreclose |

### 3.2 Systematic tier assignment

Every section (A–O) of the register was reviewed systematically, with each concept assigned a tier based on the criteria. Key judgement calls discussed and agreed:

- **A5 (validate in toy domains) at Tier 2** — important methodology but about how we develop, not what the architecture is.
- **A7 (patient autonomy) and A8 (clinical governance) at Tier 2** — critical for clinical work but not universal across all domains.
- **J2 (co-evolution) and J3 (non-constraining) at Tier 1** — these govern every session's work, not just specific workstreams. Violating either is architecturally wrong regardless of context.
- **C1–C6 (five concerns) at Tier 2** — define the BMM's structure but are about what a service business is, not what every decision must respect.
- **I14 (comprehension layer) at Tier 2** — structural realisation of the comprehension capability. The *principle* (A10, intrinsic self-knowledge) is at Tier 1; the *structural mechanism* is at Tier 2.

### 3.3 New concepts integrated

Seven new concepts from Sessions 45–46 added at appropriate tiers:

| # | Concept | Tier | Source |
|---|---|---|---|
| A10 | Intrinsic self-knowledge | T1 | Session 46 |
| A11 | Unity principle | T1 | Session 46 |
| B14 | Weighted relationships | T2 | Session 46 |
| I16 | Comprehension traversal schema | T3 | Session 46 |
| I17 | Authored/intrinsic content distinction | T3 | Session 46 |
| I18 | Inferential comprehension (Register 2+) | T2 | Sessions 45–46 |
| M7 | Reasoning formalisms research | T4 | Session 46 |

### 3.4 Cross-cutting touchpoints for Tier 1

For each of the 10 Tier 1 principles, active touchpoints documented — which current and planned workstreams exercise or are constrained by each principle. This makes cross-cutting influence visible at session start.

### 3.5 Discussion paper pipeline formalised

Convention added to the register's "How to use this document" section: discussion papers remain working documents, but their implications are explicitly identified in session reports and traced into the register at the appropriate tier before the session closes.

### 3.6 Governing document currency assessment

| Document | Last updated | Assessment |
|---|---|---|
| Strategic Snapshot | Session 31/34 (15 March) | **Significantly out of date.** Predates Ontara naming, Suds/Paws domains, component catalogue, comprehension architecture, intrinsic self-knowledge, unity principle, weighted relationships, tiered register. Needs full replacement. |
| Vision & Architecture Reference | Session 35/45 (17–19 March) | **Partially current.** Captures Ontara naming, six-layer architecture, console vision, demonstrator strategy. Missing: comprehension architecture depth, A10/A11, weighted relationships, current console state, tiered governance, A9. Needs targeted revision. |

Both refreshes scoped as Session 48 work.

### 3.7 A3 refinement

Ella refined the A3 one-line test in the tiered register from "SysML v2 is the single source of truth for all generated artefacts" to "SysML v2 is the single source of truth for all generated artefacts and canonical structure / function / semantics." This broadens A3 beyond generated output to cover the canonical representation of the system's structure, function, and meaning.

---

## 4. Decisions

| # | Decision | Choice | Rationale |
|---|---|---|---|
| S47-D1 | Tier structure | Four tiers (Governing Principles, Structural Commitments, Design Decisions, Future Directions) | Distinguishes influence levels without over-complicating. T1 small enough for session-start review (~10 items). |
| S47-D2 | J2 and J3 at Tier 1 | Promoted from methodology to governing principles | Both govern every session's work. Violating either is architecturally wrong regardless of context. |
| S47-D3 | Tier 2 cross-cutting tracing | Lightweight, at implementation planning time | Pre-computing touchpoints for ~35 items is diminishing returns. Discovered naturally when producing implementation plans. |
| S47-D4 | Governing document refresh | Scoped for Session 48, not squeezed into this session | Both documents need thoughtful revision, not rushed work. Assessment documented; brief prepared. |
| S47-D5 | Register format | Restructured version, not companion document | One document with tier column added. Avoids parallel documents that need sync. |
| S47-D6 | Discussion paper pipeline | Formalised as register convention | Session reports identify binding concepts from discussion papers; register updates add them at appropriate tier. |

---

## 5. Documents Produced

1. **Tiered master register** — `ontara-master-register-design-concepts-tiered-2026-03-20.md` — full register restructured with four tiers, Tier 1 quick reference, cross-cutting touchpoints, 7 new concepts, discussion paper pipeline convention. Now placed in Obsidian by Ella, replacing the previous flat register.

2. This session report — container artifact for Ella to download.

3. Session 48 preparation note — container artifact for Ella to download.

---

## 6. Concepts Exercised

- **J5** (periodic project reviews) — this session *is* the review
- **J11** (bottom-up meets top-down) — the review is the top-down framing catching up with what bottom-up development revealed in Sessions 45–46
- **J10** (retrospective bootstrapping) — the tiered structure is a process improvement prompted by recognising governance gaps
- **A9** (discipline as load-bearing structure) — strengthening the governance structure is structural reinforcement of the development process
- **J6** (LLM prose smuggling) — systematic review of every concept reduces the risk of fuzzy equivalences propagating

---

## 7. Master Register — Updated This Session

The register was restructured rather than incrementally updated. The tiered version (`ontara-master-register-design-concepts-tiered-2026-03-20.md`) is now the canonical version, replacing the previous flat register. All updates are incorporated in the new document.

---

## 8. Gaps Addressed by This Review

| Gap (from Session 46) | Status |
|---|---|
| 1. Register flat where architecture is layered | **Addressed.** Four-tier structure established. |
| 2. Governing documents don't reflect current depth | **Assessed.** Refresh scoped for Session 48. |
| 3. Cross-cutting concerns not explicitly traced | **Partially addressed.** Tier 1 touchpoints documented. Tier 2 tracing agreed as lightweight/on-demand. |
| 4. Discussion paper → binding commitment pipeline informal | **Addressed.** Convention formalised in register. |

---

## 9. Git Commands

No code changes this session. No commit needed.

---

## 10. Documents for Repo Archive

The tiered register should be archived to `documentation/archive/strategic/` after Ella has reviewed and confirmed the final version:

```bash
cp "/Users/ellagreen/Obsidian/GenderSense/02 ARCHITECTURE & MODELLING/Ontara/Vision, Strategy & Development Reference/ontara-master-register-design-concepts-tiered-2026-03-20.md" ~/Developer/gsl-tech/gsl-sysml-model/documentation/archive/strategic/

cd ~/Developer/gsl-tech/gsl-sysml-model
git add documentation/archive/strategic/ontara-master-register-design-concepts-tiered-2026-03-20.md
git commit -m "S47: Tiered master register — structured project review

- Four-tier influence structure (Governing Principles / Structural Commitments / Design Decisions / Future Directions)
- 10 Tier 1 principles with cross-cutting touchpoints
- 7 new concepts from Sessions 45-46 (A10 intrinsic self-knowledge, A11 unity principle, B14 weighted relationships, I16-I18 comprehension, M7 reasoning formalisms)
- Discussion paper pipeline convention formalised
- A3 refined: canonical structure/function/semantics
- Governing document currency assessed (refresh scoped for S48)"
```

---

## 11. Next Steps

1. **Session 48: Governing document refresh.** Produce updated strategic snapshot and revise the vision reference to reflect current architectural depth. The strategic snapshot is the priority — it's the document a new Claude instance reads first.
2. **Session 49+: Phase 3 implementation.** Produce detailed implementation plan reflecting the tiered register and the intrinsic self-knowledge / unity principle commitments. Then build.
3. **Queued discussion (carried forward):** Service subject ≠ customer — meta model implications.
4. **Review 26 draft descriptions** — Ella to review at leisure; iterate in a future session if needed.

---

*Session report prepared 20 March 2026. Session 47.*
