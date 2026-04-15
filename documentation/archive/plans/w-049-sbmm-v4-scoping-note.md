---
tags:
  - work-item-note
  - scoping
date: 2026-04-15
status: current
session: 217
work-item: W-049
---
# W-049 — Service Business Meta Modelling v4: Scoping Note

> `= this.file.path`

**Date:** 15 April 2026 (Session 217)
**Workstream:** [[ontara-ref-work-item-tracker|W-049]] (Foundations papers full refresh)
**Subject:** [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling v3.1]] → v4
**Purpose:** Scope the v4 refresh of Service Business Meta Modelling against the strengthened [[principle-two-meta-model-distinction|A4]] committed in [[ontara-architecture-platform-principles|Architecture Principles v5]] and the modelling-strategy reframings committed in [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy v5]]. Identify per-section workflow assignment ([[ontara-ref-work-item-tracker|OW-211-5]]), run Test 3 of the five-principle unification hypothesis ([[ontara-ref-work-item-tracker|OW-77]]) section by section, and identify the new content v4 must add — most substantially the General/Tailored detailed treatment ([[ontara-ref-work-item-tracker|OW-87]]) deferred to SBMM v4 by both upstream papers.
**Status:** Working scoping document. The output of the scoping session, not the v4 draft itself. Drafting decision taken at planning step.

---

## Contents

- [[#1. Scoping Frame|§1. Scoping Frame]]
- [[#2. Per-Section Workflow Assignment|§2. Per-Section Workflow Assignment]]
- [[#3. Test 3 of the Five-Principle Unification Hypothesis|§3. Test 3 of the Five-Principle Unification Hypothesis]]
- [[#4. New Content SBMM v4 Must Add|§4. New Content SBMM v4 Must Add]]
- [[#5. Standing Disciplines for Drafting|§5. Standing Disciplines for Drafting]]
- [[#6. Drafting Sequence Recommendation|§6. Drafting Sequence Recommendation]]
- [[#7. Critique|§7. Critique]]
- [[#8. Open Questions for Ella|§8. Open Questions for Ella]]
- [[#9. Critique Observations and Watchpoints|§9. Critique Observations and Watchpoints]]

---

## 1. Scoping Frame

SBMM v3.1 was a light touch-up of v3 (S170). Its conceptual content predates: the strengthened [[principle-two-meta-model-distinction|A4]] (six strata, two sides, ten architectural loci, [[ontara-architecture-platform-principles|Architecture Principles v5]] §3); the binding promotion of [[concept-knowledge-graph|B22]] (KG-canonical, v5 §5.6); the binding promotion of [[principle-coordinate-framework|A12]] to T1 (v5 §5.1); the BS → SR rename ([[ontara-ref-work-item-tracker|OW-85]]); the four-level distinction registered as [[ontara-ref-master-register|B40]] from S199; the constraint-hierarchy-as-spine finding (S207 D28, v5 §7.3); the [[ontara-ref-work-item-tracker|W-053]] DPA workstream; the surface architecture work ([[ontara-ref-master-register|B41]]–[[ontara-ref-master-register|B44]], [[ontara-ref-master-register|J15]], v5 §5.9); the Stage 8 portal closure (S185); the Ears clinical domain intake (S160–168); and the Platform Modelling Strategy v5 reframings (S216, particularly the inverted KG-canonical treatment of the two formalisms).

The v4 refresh therefore lands as a structural reframing of SBMM rather than a content addition. The substantive BMM vocabulary content of v3.1 (the 50 elements, the six concerns, the cross-domain validation findings, the comprehension architecture metadata) is highly durable and survives. What changes is the structural framing within which the BMM is described: BMM is metamodel-stratum content on the business side of the strengthened A4's six-stratum × two-side grid, with the General/Tailored distinction internal to the Metamodel stratum. The most substantial new content is the General/Tailored detailed treatment in §9, which both Architecture Principles v5 (§5.5) and PMS v5 (§5.2, §5.6, §9.3) explicitly defer to SBMM v4 ([[ontara-ref-work-item-tracker|OW-87]]).

The scoping note follows the methodological positions recorded as [[ontara-ref-work-item-tracker|OW-211-5]] (full-rewrite vs targeted edits per section) and [[ontara-ref-work-item-tracker|OW-212-1]] (full-rewrite over targeted-edits for sections with dense conceptual change), and the cross-paper consistency principle that comprehension trumps strict cross-reference economy: where restating sharpens or where the alternative imposes excessive document-switching cost on the reader, restate.

---

## 2. Per-Section Workflow Assignment

| § | v3.1 title | Workflow | Rationale |
|---|---|---|---|
| 1 | Purpose and Intent | Targeted edits | Three goals durable; small reframing for strengthened-A4 orientation (BMM as metamodel-stratum business-side content), four-level vocabulary touch-ups, A13 binding T1 reference unchanged. Domain identity reference current |
| 2.1 | Six Concerns of a Service Business | Targeted edits | All six concerns (ServiceConcept, ActivityModel, ResourcePlanning, FinancialPlanning, GovernanceMapping, StakeholderModel) and their descriptions durable. Add locus-naming where natural — particularly that GovernanceMapping vocabulary is metamodel content with deontic governance vocabulary as an SMM-side cross-cutting extension |
| 2.2 | Relationships Between Concerns | Targeted edits | Stable; HardConstraint reference and A12 coordinate-space reference small reframing for A12 binding T1 status |
| 2.3 | Modularity Principle | Targeted edits | Stable |
| 2.4 | Activity Awareness — Cross-Cutting Foundation | Targeted edits | Activity taxonomy, progressive elaboration, stakeholder-relationships-as-activity-generators — all durable |
| 3 | The BMM Vocabulary | Targeted edits, substantive | §3.1–§3.4 element tables stable; status notes refreshed (Ears intake complete; weighted relationships count and OWL representation consistent with current state). Significant content in tables but no structural changes; numbers verified against current model |
| 4 | Comprehension Architecture and the BMM | Targeted edits, substantive | §4.1 self-describing elements (six annotation types, 34/34 coverage) durable; §4.2 weighted relationships durable; §4.3 three-register model — sharpen the inferential register description against v5 §2.1 framing (inferential register is reasoning-realising-component output written into the SRS); §4.4 console views durable |
| 5 | Cross-Domain Validation | Targeted edits | §5.1 strategy durable; §5.2 demonstrators table — Ears row updated to "analytical intake complete" (already done in v3.1; verify currency); §5.3 validation findings — all six findings durable; first finding ("All General vocabulary has proved sufficient") becomes the entry point for §9 |
| 6 | Package Structure | Targeted edits | File and package layout stable; cross-references stable; §6.3 BMM-Operations division stable. Small touch-up for current state |
| 7 | Mapping to Existing System Model | Targeted edits | §7.1 strong coverage durable, with status updates; §7.2 remaining gaps — the SMM extraction gap (O2) stays, but its framing sharpens under v5: the SMM situation has been substantially clarified by Stage 9 work (BMM/SMM as parallel metamodel-stratum content; SMM has grown via deontic governance, domain identity, reasoning metamodel, architectural sections; explicit promotion to a named navigable structure remains the gap) |
| 8 | Business Model Variants and Scenario Modelling | Targeted edits | Three variants (Lean Clinical, Full Platform, Consultancy + Licence) durable; projection mechanics durable; §8.3 operational steering durable, with the parallel to the five-layer SystemStateAssessment now reframed as SRS behaviour per v5 §5.7.4 |
| **9** | **The Two Meta Models** | **Full rewrite** | **Principal new content section.** Reframed against v5 §3 (the strengthened A4) and v5 §5.5 (Metamodel-stratum General/Tailored sub-structuring). Holds the General/Tailored detailed treatment per [[ontara-ref-work-item-tracker|OW-87]] at full depth: criteria for promotion between General and Tailored, hook-in mechanics for Tailored extensions, sub-band structural detail, audit of every existing BMM element against the criteria (per Ella S217 direction). SMM situation under v5 stated. Test 3 derivations land here. Substantial new section |
| 10 | Simulation | **Targeted edits, substantial** | Reframed as natural behaviour of SRS per v5 §5.7.4. L5–L9 are not five separate capabilities; they are aspects of SRS homogeneity. The §10 narrative survives but its structural framing changes — operational simulation is the system-side runtime producing SR content; reflective simulation reads SRS content and writes more SRS content via reasoning realising components; coordinate-space snapshots (L8) is the SRS's epistemic tagging mechanism; goal-seeking computation (L9) is search over SRS content. Worth a deliberate paragraph reframing. The v3.1 §10 substantive content is absorbed; the v4 §10 is shorter and more structurally honest |
| **11** | **The BMM in the Knowledge Graph** | **Full rewrite** | KG-canonical inversion expressed in BMM-specific terms (per Ella S217 direction — restating in service of self-sufficiency for the BMM-curious reader). The canonical BMM is the OWL classes, object properties, weighted-relationship reified individuals, and hand-authored axioms in the Knowledge Graph; the SysML projection is the engineering projection of selected BMM content; the round-trip diff verifies projection fidelity. `@BfoType` annotations are Formalism-Boundary-stratum content. Hand-authored `ontara-bmm-axioms.ttl` is first-class canonical content with no SysML projection. §11.2 governance extensions reframed under v5 §7 (constraint hierarchy as architectural spine, deontic obligations as HardConstraints). §11.3 QA — three layers stated against current state |
| **12** | **Forward Direction** | **Full rewrite** | §12.1 (B20 IG/cybersecurity) durable with cross-references updated; §12.2 (SMM extraction) reframed against v5 SMM situation (gap is explicit promotion to a named navigable package structure, not "SMM does not exist"); §12.3 (Tailored StakeholderModel extensions) becomes a worked example for §9's General/Tailored treatment rather than a forward direction (or is restructured to feed §9 and leave forward references in §12); §12.4 (Ears) becomes "Ears closure" — moved or reframed since Ears intake completed S168; §12.5 (governance activation tier) stable; §12.6 (reasoning metamodel) substantially reduced — Stage 7 closure is now stated context, not forward direction. New forward direction items added: surface architecture for BMM-side surfaces (band 1 customer surfaces, band 5 operations surfaces — both render BM content); GSL instantiation as the next major BMM exercise; DPA workstream as the principal v5 architectural concern affecting BMM (per-tenant BM is exactly what DPA exports) |
| Related Documents | Targeted edits | Regenerate list — v5 papers (Architecture Principles v5, PMS v5), Stage 9 foundation papers, surface architecture papers, S207/S208 papers, DPA tracking, Stage 8 portal, Ears intake artefacts |

**Counts.** Full rewrite: §§9, 11, 12 — three sections. Substantial targeted edit: §10. Targeted edits with substantive content updates: §§3, 4. Targeted edits: §§1, 2, 5, 6, 7, 8, Related Documents.

**Implication for drafting workflow.** As with PMS v5, the v4 draft should be produced as a single full-rewrite container artifact (per [[ontara-ref-work-item-tracker|OW-212-1]]) — the structural reframing in §§9 and 11 propagates wording into the targeted-edit sections enough that two-pass drafting would create scaffolding-vs-content awkwardness. The full-rewrite share is smaller than PMS v5 but the §9 substantive new content makes the total drafting effort comparable.

The total drafting effort is comparable to PMS v5 — lighter conceptually (§§3–8 are durable) but with substantial new prose in §9 (deep General/Tailored treatment with element-by-element audit) and a substantive §11 rewrite (KG-canonical in BMM-specific terms).

---

## 3. Test 3 of the Five-Principle Unification Hypothesis

[[ontara-ref-work-item-tracker|OW-77]] tests whether [[principle-self-describing-system|A2]], [[principle-intrinsic-self-knowledge|A10]], [[principle-unity-principle|A11]], [[principle-coordinate-framework|A12]], and [[concept-coordinate-space-snapshots|L8]] can be derived from the strengthened A4 (SRS as the homogeneous queryable stratum) without introducing new content. Test 1 passed for [[ontara-architecture-platform-principles|Architecture Principles v5]] §2.4. Test 2 passed for [[ontara-architecture-platform-modelling-strategy|PMS v5]] §2.5. Test 3 is whether SBMM v4 sections that reference these principles can derive them in the same way.

| Principle | v3.1 sections referencing | Derivation in v4 SBMM | Test 3 verdict |
|---|---|---|---|
| A2 (self-describing) | §1 (intended benefits — "completeness checking", "modular exploration", "communicability"); §4 (self-describing elements) | "BMM elements are self-describing because their authored content (Register 1) lives at the Metamodel stratum, their structural content (Register 2) is dynamically computed from SRS queries against BM and BR content instantiating them, and their inferential content (Register 2+) is reasoning-realising-component output written into the SRS. Self-description is the BMM being queryable in the same vocabulary as its instances." Already close to v3.1 wording; v4 makes the SRS locus explicit | **Pass expected** |
| A10 (intrinsic self-knowledge) | §4.3 (three-register model — "if the model changes and no human edits a description, does the explanation become wrong?") | "Authored BMM content (purposive descriptions on metamodel elements) lives at the Metamodel stratum; intrinsic content is dynamically computed from live BM and BR content via the comprehension metadata traversal schemas. The Metamodel/Configured-Model boundary protects authored content from being silently invalidated by configured-model changes; the Configured-Model/SRS boundary ensures intrinsic content reflects the live SRS state." Sharpens v3.1's "intrinsic" framing to the strata-respecting structural property | **Pass expected** |
| A11 (unity) | §2.2 (HardConstraints, A12 reference); §4.2 (weighted relationships and unity principle); §4.3 (S147-D7 convergence reference); §11.2 (governance-reasoning alignment) | "One canonical BMM, one canonical weighted-relationship model, one query vocabulary across BMM elements and BR instance content. The 96 weighted relationships are at the Metamodel stratum; every subsystem that uses them is a realising component reading them through bindings into the same SRS. Two empirical anchors: comprehension–reasoning convergence (S147-D7) at the reasoning level; constraint hierarchy as architectural spine (S207 D28) at the surface level." Tightens v3.1 §4.2's existing framing | **Pass expected** |
| A12 (coordinate framework) | §2.2 (NormativeRegion boundaries); §11.2 (HardConstraints define NormativeRegion boundaries) | "BMM elements occupy positions in the platform's coordinate space; BM configuration selects positions; BR snapshots record trajectories through the configured space. The BMM concerns (six orthogonal-but-interconnected concerns) are themselves a coordinate-framework expression at the metamodel level — six axes against which any service business can be located. v5 §5.1 Region taxonomy applies: NormativeRegions correspond to GovernanceMapping HardConstraints; ScalarFields to weighted relationships and SoftConstraints; trajectories to BR snapshot sequences." A12's binding T1 promotion (v5 §5.1) is referenced; new derivation in BMM terms | **Pass expected** |
| L8 (coordinate-space snapshots) | Implicit only in v3.1 (referenced via simulation §10) | "BR snapshots are SRS content tagged `current/actual`; non-current BR-related snapshots (historical/goal/hypothetical/projected/counterfactual) are SRS content carrying the same BM vocabulary with different epistemic tags. L8's six epistemic types are the SRS tagging mechanism applied to BMM-instance content." Small added prose; derivable | **Pass expected** |

**Test 3 result expected: passes for SBMM v4, contingent on the rewrites in §§9, 10, 11 being done with strengthened-A4 framing and with §4.3 inferential-register reframing applied.** No new content is required that is not already derivable from [[ontara-architecture-platform-principles|Architecture Principles v5]] §3, §5 (particularly §5.5), and §7.3 plus [[ontara-architecture-platform-modelling-strategy|PMS v5]] §3 and §5 — but Test 3 leans on Architecture Principles v5 §5.5 (Metamodel-stratum General/Tailored sub-structuring) more heavily than Tests 1 or 2 did, anticipated by [[ontara-ref-work-item-tracker|OW-215-1]] and [[ontara-ref-work-item-tracker|OW-216-2]].

**Cross-reference to [[ontara-ref-work-item-tracker|OW-89]].** OW-89 records that Test 1 derivations leaned on additional v5 §3 commitments beyond the strengthened A4 statement itself. OW-216-2 records that Test 2 derivations leaned on the same v5 §3 commitments plus v5 §5.6 and §5.1. Test 3 derivations in SBMM v4 will lean on:
- v5 §3.1 (Stratum 5 — SRS) for A2, A10, L8
- v5 §3.4 (prohibition 1 — no PRS writes to Metamodel-stratum content) for A10
- v5 §5.5 (Metamodel-stratum General/Tailored sub-structuring) for the framing within which BMM-specific A11 and A12 derivations sit
- v5 §5.7 (SRS) for L8 and the snapshot vocabulary
- v5 §5.1 (A12 binding T1) for the coordinate-framework derivation
- v5 §7.3 (constraint hierarchy as architectural spine) for the second empirical anchor of A11

This is a fair test — SBMM v4 is downstream of Architecture Principles v5 by design — but the dependency on v5 §5.5 specifically is the new thing for Test 3, and the result will sharpen the unification hypothesis's dependency profile.

**Cumulative result so far.** Test 1 passed cleanly for Architecture Principles v5. Test 2 passed for PMS v5. Test 3 expected to pass for SBMM v4 contingent on the rewrites being done with the strengthened-A4 framing and with v5 §5.5 properly anchoring the General/Tailored treatment in §9. **If Test 3 strains, the strain will most likely surface at A11 or A12** — both are the principles whose operational reading depends on cross-side and cross-stratum claims that the BMM-only framing of SBMM may find harder to make compactly than the platform-wide framings of Architecture Principles v5 and PMS v5 did.

---

## 4. New Content SBMM v4 Must Add

The substantive new content SBMM v4 must add (not in v3.1):

1. **General/Tailored detailed treatment ([[ontara-ref-work-item-tracker|OW-87]]) at depth** — the principal new substantive content, in §9. Per Ella S217 direction, the treatment goes deep:
   - **Criteria for what makes content General vs Tailored** — sector-agnosticism vs sector-specificity is the headline criterion, but it is not the only one. Candidate criteria to be worked out: (a) cross-domain applicability (the empirical test that has held all 50 elements as General); (b) ontological grounding (General content draws from CCO/IAO directly; Tailored content draws from sector-specific Foundation content like OGMS); (c) substitutability (a Tailored element is replaceable when a tenant's sector changes; a General element is not); (d) authority (Tailored content can be authored by sector experts; General content is platform-level).
   - **Hook-in mechanics for Tailored extensions** — the SysML mechanism (`:>>` redefinition per [[concept-general-tailored-decomposition|B11]]); the OWL mechanism (subclassing, with property restrictions); the implications for the round-trip diff and the canonical KG content; the consequences for naming, versioning, and discovery.
   - **Sub-band structural detail** — General and Tailored as two horizontal sub-bands within the Metamodel stratum (per v5 §5.5); the relationship between the sub-bands and the canonical KG namespacing; the discovery mechanism (how a tenant's BM finds the relevant Tailored content for its sector); the loading mechanism (how Tailored modules are activated).
   - **Element-by-element audit** of every existing BMM element against the General/Tailored criteria, confirming or qualifying each one's current classification. The 50 BMM elements (34 core + 2 domain identity + 11 scenarios + 3 strategy) are all currently General; the audit verifies this against the worked-out criteria and identifies any that are borderline. The audit also surfaces candidate Tailored extensions for the healthcare sector (the StakeholderModel extensions named in v3.1 §12.3 — `SharedCareProtocol`, `ClinicalReferralPathway`, `PatientAdvocacyRelationship` — and any others).
   - **Worked example** of one Tailored extension at full detail — most naturally one of the StakeholderModel healthcare extensions, fully worked through SysML, OWL, hook-in to the General core, KG namespace, discovery, activation, BM consumption, and BR rendering.
   - **The empirical observation** that all 50 BMM elements remain General after four cross-domain validations is itself stated as a substantive finding — the BMM's generality is empirical, not assumed, and the criteria for moving an element to Tailored are clear.

2. **Strengthened A4 orientation throughout** — short statement in §1 that BMM is metamodel-stratum content on the business side of the strengthened A4's six-stratum × two-side grid; locus-naming discipline applied throughout §§2–8 where natural.

3. **Four-level vocabulary ([[ontara-ref-master-register|B40]])** rigorously throughout — BMM is the metamodel; per-tenant configuration is the BM (configured model); runtime instance content is BR (SRS content); BFO/CCO/IAO are Foundation-stratum content the BMM is grounded in. Consistent terminological discipline; no "BMM runtime state" or "SMM runtime state" phrasings.

4. **SR rename** ([[ontara-ref-work-item-tracker|OW-85]]) committed throughout. v3.1 contains some references to "BS" or system-side runtime state in passing — all to be normalised to SR.

5. **KG-canonical reframing in §11 in BMM-specific terms** — the canonical BMM is the OWL classes, object properties, weighted-relationship reified individuals, and hand-authored axioms in the Knowledge Graph; the SysML projection is the engineering projection used for human authoring of selected BMM content; the round-trip diff verifies projection fidelity; `@BfoType` annotations are Formalism-Boundary-stratum content; `ontara-bmm-axioms.ttl` is first-class canonical content with no SysML projection. Restated in BMM terms (per Ella S217 direction) rather than strict cross-reference to PMS v5 §11. Differences in emphasis between PMS v5 §11 and SBMM v4 §11 are accepted as productive.

6. **Test 3 result** in §9 (analogous to PMS v5 §2.5 location, integrated with the General/Tailored treatment because §9 is the section where Test 3's main strain — the v5 §5.5 dependency — lands).

7. **Five category errors referenced** where appropriate (§9, §11) — SBMM v4 references [[ontara-architecture-platform-principles|Architecture Principles v5]] §3.4 rather than restating, with the metamodel-runtime-confusion error (prohibition 5 / constraint 12) deserving explicit naming in §9 because the BMM is the principal site where "BMM runtime state" phrasing has historically lived.

8. **DPA-informed writing discipline ([[ontara-ref-work-item-tracker|OW-83]])** held throughout. Particularly relevant in §1 (multi-tenancy reference), §3 (BM as per-tenant content), §9 (Tailored extensions are part of what DPA must export), §11 (KG content boundaries), §12 (DPA as forward-direction architectural concern). No SBMM v4 paragraph forecloses the DPA. Cross-reference to W-053.

9. **Constraint hierarchy as spine (S207 D28)** in §4.3 (inferential register), §11.2 (governance-reasoning alignment), and §12 (forward-direction surface architecture for BMM-side surfaces) — short cross-references to [[ontara-architecture-platform-principles|Architecture Principles v5]] §7.3.

10. **Stage 8 portal closure** referenced in §12.1 current state (replacing v3.1's stale "Stage 7" framing).

11. **Stage 9 architectural foundation work** referenced in §12 — the Stage 9 foundation papers (S192, S195, S196, S197, S198/S200, S199) and the strengthened A4 work (S208, S209) are now context for SBMM v4's framing, not forward direction.

12. **Surface architecture acknowledgement for BMM-side surfaces** in §12 forward direction — band 1 customer surfaces and band 5 operations surfaces both render BM content (each through its band-appropriate experience-API contract per v5 §5.9). The B41–B44 surface vocabulary is referenced; SBMM v4 does not need to recapitulate the surface architecture but should acknowledge that BMM content surfaces through the Stage 9 surface family pattern.

13. **GSL instantiation as the next major BMM exercise** in §12 — the next BMM workstream after W-049 closes is GSL as production tenant; this anticipates the BMM's content-currency requirements going forward.

14. **SBMM-specific sharpening of OW-216-3** — the engineering authoring-parity asymmetry as it applies to BMM specifically (BMM has both SysML projection and canonical OWL; how they relate under KG-canonical; the round-trip diff's role in keeping them faithful).

The substantive new content SBMM v4 must **not** add (boundary discipline):

- **Two-formalism general treatment** — belongs in PMS v5 §11. SBMM v4 §11 restates the KG-canonical framing in BMM-specific terms (per Ella direction) but does not duplicate the modelling-strategy general treatment of how the two formalisms relate.
- **Reasoning metamodel detailed evolution** — belongs in [[ontara-discussion-institutionalised-reasoning-2026-04-05|Stage 7 institutionalised reasoning paper]] and [[ontara-architecture-platform-principles|Architecture Principles v5]] §2.3. SBMM v4 §11.2 references the reasoning metamodel's role in evaluating BMM-side governance constraints but does not redo the cataloguing.
- **Surface architecture detailed treatment** — §12 acknowledges; the substantive treatment lives in [[ontara-architecture-platform-principles|Architecture Principles v5]] §5.9 and the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198]], [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]], S207 papers.
- **DPA design** — W-053; SBMM v4 holds writing discipline against it but does not design it.
- **SMM detailed treatment** — §7.2 and §9 reference the SMM situation under v5 (parallel metamodel-stratum content; explicit promotion to a named navigable structure remains the gap) but the SMM itself is the subject of separate forward work, not SBMM v4 content.
- **Six-stratum frame restated at length** — the frame belongs in [[ontara-architecture-platform-principles|Architecture Principles v5]] §3; SBMM v4 references it and uses the vocabulary, with at most a one-paragraph orientation in §1 or §9.

---

## 5. Standing Disciplines for Drafting

These apply throughout v4 drafting:

- **DPA-informed writing discipline ([[ontara-ref-work-item-tracker|OW-83]]).** No paragraph forecloses the DPA. Particularly active in §9 (Tailored extensions and the DPA's export semantics) and §11 (KG content boundaries).
- **Four-level vocabulary** ([[ontara-ref-master-register|B40]]) used rigorously: metamodel / configured model / runtime instance / realising component. Catch and rewrite any "BMM runtime state" or "SMM runtime state" phrasing as a category error (v5 prohibition 5 / constraint 12). The BMM is the principal historical site of this regression.
- **SR rename** ([[ontara-ref-work-item-tracker|OW-85]]) committed throughout. No residual BS phrasings.
- **Wikilinks only** for vault references; escaped pipes `\|` inside table cells; Obsidian-native contents index format `[[#heading|display text]]`, never GFM.
- **Six-stratum × two-side locus naming** as a discipline — when introducing a BMM element or relationship, name its locus where natural (BMM is metamodel-stratum business-side; BM is configured-model-stratum business-side; BR is SRS-stratum business-side).
- **Cross-reference, but with comprehension priority.** [[ontara-architecture-platform-principles|Architecture Principles v5]] §3 (six strata), §3.4 (five category errors), §5.1 (coordinate framework), §5.5 (Metamodel General/Tailored), §5.7 (SRS), §5.7.4 (simulation as SRS behaviour), §7.3 (constraint hierarchy as spine), and [[ontara-architecture-platform-modelling-strategy|PMS v5]] §3 (canonical formalism), §5 (package architecture), §11 (two formalisms) — SBMM v4 cross-references these, but where a reader's comprehension is materially served by restatement in BMM terms, restate. Differences of emphasis between papers are productive, not problematic.
- **Capture observations and watchpoints** as they arise during drafting — surface as Critique Observations and Watchpoints section in the v4 paper, deposit in the OW register at C2 with work type assignments. New OW items expected: at least one on the General/Tailored criteria robustness once the §9 audit has been worked through; possibly more on the Tailored extension hook-in mechanics under KG-canonical; a sharpening of [[ontara-ref-work-item-tracker|OW-78]] as it applies to BMM specifically.

---

## 6. Drafting Sequence Recommendation

Recommended drafting order for the dedicated v4 drafting session(s):

1. **§9 first.** The principal new content section. The General/Tailored criteria, hook-in mechanics, sub-band structure, and element-by-element audit set vocabulary and structural commitments that §§3, 4, 7, 11, 12 inherit. Test 3 derivations land alongside the General/Tailored treatment.
2. **§11 second.** The KG-canonical reframing in BMM-specific terms. Vocabulary established in §9 (canonical BMM, hand-authored axioms, projection scope) is consumed.
3. **§10 third.** The simulation reframing as SRS behaviour. Cross-references to v5 §5.7.4 and to §11's KG-canonical treatment.
4. **§12** — current state (refresh against S217 reality: Stage 8 closed, Stage 9 foundation papers in place, Architecture Principles v5 and PMS v5 done, Ears intake complete) and forward direction (DPA, surface architecture for BMM-side surfaces, GSL instantiation, SMM extraction).
5. **§§1, 2, 3, 4, 5, 6, 7, 8** — targeted-edit sections absorbed into the rewrite. §3 substantive numerical updates; §4.3 inferential-register reframing.
6. **Related Documents** regenerated against current vault state — v5 papers, Stage 9 foundation papers, surface architecture papers, S207/S208 papers, DPA tracking, Stage 8 portal, Ears intake artefacts.
7. **End-to-end read-through** before deposit. Verify zero TBDs, consistent strengthened-A4 vocabulary, escaped pipes in tables, Obsidian-native contents index, no residual BS phrasings, no metamodel-runtime-confusion regression, no DPA foreclosure, four-level vocabulary held throughout.

**Estimated drafting effort.** Comparable to PMS v5 — lighter conceptually because the BMM vocabulary content is highly durable and the KG-canonical inversion was largely worked out for PMS v5, but with substantial new prose in §9 (deep General/Tailored treatment with element-by-element audit) and a substantive §11 rewrite. Plausibly one session for §9 and §11 (the structural new content), and a second for §§10, 12, the targeted-edit sections, and the read-through.

**Decision on combined scoping + drafting at S217.** Given Ella's S217 direction to go deep on §9 (option (c) — full criteria, hook-in mechanics, audit, worked example) and to restate the KG-canonical content in BMM terms in §11 (option (b) for §11), the substantive new content is large enough that **scoping at S217 + drafting at S218+ is the recommended path**. Scoping in this session has now been completed; drafting should be a fresh session with the scoping note in working context. The S216 precedent of producing PMS v5 in one session was possible because the §9 equivalent there (the canonical-formalism reframing, §11 of PMS) was conceptually contained; SBMM v4 §9 is more substantive new content than PMS v5 §11 was, plus the §11 BMM-specific KG-canonical content.

---

## 7. Critique

Workflow guide §2.2 milestone critique. Five categories:

**(a) Logical coherence.** The scoping holds together internally. Per-section workflow assignment, Test 3, and new-content identification reinforce each other. The recommended drafting sequence (§9 first, then §11, then §10, then §12, then targeted-edit sections) reflects the dependency direction: §9 establishes vocabulary that §§3, 4, 7, 11, 12 inherit. **No genuine concerns.**

**(b) Significant omissions.** Three potential omissions worth raising:

1. The scoping is silent on whether SBMM v4 should adopt section-ordering changes. v3.1 has §9 (Two Meta Models) sitting late after §§7 (Mapping) and §8 (Variants), but under v4 framing §9 is the principal new-content section and arguably the most foundational for understanding the BMM's place in the strengthened A4. **Question for Ella in §8 below.**
2. The scoping does not address whether the §9 element-by-element audit produces a separate artefact (a table or appendix listing all 50 elements with their General/Tailored classification, criteria-by-criteria) or is absorbed into §9 prose. The audit is substantive enough that an appendix would be defensible. **Question for Ella in §8 below.**
3. The scoping does not surface the question of how the §9 worked example (the healthcare-specific Tailored extension worked through in detail) interacts with the v3.1 §12.3 forward-direction note about Tailored StakeholderModel extensions. If §9 worked example covers `SharedCareProtocol`, `ClinicalReferralPathway`, or `PatientAdvocacyRelationship` at full detail, the §12.3 forward-direction note becomes substantively pre-empted. This is fine if the worked example is treated as an exemplar (not as the GSL instantiation itself) but warrants explicit handling. **Recorded as a watchpoint for §9 drafting.**

**(c) Alternative approaches.** The principal alternative considered and rejected: **light General/Tailored treatment in §9** (option (a) from the S217 scoping conversation — name the distinction, state the empirical observation, defer detailed work). Rejected per Ella S217 direction in favour of the deep treatment (option (c)). The case for (c) is that OW-87 has been deferred to SBMM v4 by both upstream papers; treating it lightly here would defer it further, with no obvious next home; the General/Tailored content is the load-bearing extension mechanism for sector-specific BMM growth and warrants a thorough treatment now while the v5 work is fresh.

**(d) Untested assumptions.** Four assumptions worth naming:
1. Test 3 is **expected** to pass; it has not been **performed** at drafting density. The scoping presents the derivations at orientation level; the actual Test 3 result will land at v4 completion, as Tests 1 and 2 did. The expected strain point (A11 or A12) is identified but not tested.
2. The General/Tailored criteria worked out in §9 will hold against the element-by-element audit. The audit is the test; the criteria may need iteration as the audit proceeds. This is the kind of in-session iteration that scoping cannot pre-empt; the scoping note flags it as expected.
3. The judgement that SBMM v4 drafting is "comparable to PMS v5" rests on §9 fitting one drafting session and §11 fitting another. If §9 turns out to require more than one session — e.g. the element-by-element audit surfaces classification ambiguities that need design work — the schedule extends.
4. The judgement that restating KG-canonical in BMM terms in §11 (option (b) for §11) is a productive use of cross-paper space (rather than a violation of cross-reference discipline) rests on Ella's S217 direction that comprehension priority trumps strict cross-reference economy. If the restatement turns out to drift from PMS v5 §11 in ways that impair rather than aid comprehension, the cross-paper consistency discipline applies via [[ontara-ref-work-item-tracker|OW-216-5]] and the touch-up is in the next session.

**(e) Risks of the chosen direction.** Three risks:

1. **§9 General/Tailored treatment becomes a sub-paper in its own right.** Risk that the deep treatment expands beyond what SBMM v4 can hold without overshadowing the rest of the paper. Mitigation: the worked example is one extension at full detail (not multiple); the audit is structured as a table with concise per-element rationales (not prose per element); the criteria are stated with examples but not exhausted with edge cases.
2. **§11 KG-canonical restatement drifts from PMS v5 §11.** Risk that two parallel canonical-formalism statements diverge subtly. Mitigation: drafting sequence has §11 done after §9 with PMS v5 §11 in working context for cross-checking; the v4 §11 is BMM-specific (not a general two-formalism restatement) so its scope is clearly bounded; differences of emphasis are accepted as productive per Ella's standing direction.
3. **§9 element-by-element audit surfaces a classification ambiguity that requires upstream design work.** Risk that one of the 50 BMM elements turns out to be borderline General/Tailored in a way that needs more thought than v4 drafting can absorb. Mitigation: borderline cases are explicitly flagged in §9 with a brief discussion of the borderline question; if the question is substantive, it becomes a deferred item or a forward-direction note rather than holding up v4.

---

## 8. Open Questions for Ella

Three genuine scoping questions for Ella before drafting begins:

1. **Section ordering.** Should §9 (the principal new-content section under v4 framing) move earlier in v4 to reflect its now-foundational role, or stay in its v3.1 position after §§7 (Mapping) and §8 (Variants)? Argument for moving: under the strengthened A4, the BMM's place in the metamodel stratum and the General/Tailored sub-structuring are arguably more foundational than the mapping or variants content; moving §9 earlier would reflect that. Argument for staying: the v3.1 §1–§12 progression (purpose → conceptual framework → vocabulary → comprehension → cross-domain → packaging → mapping → variants → two meta models → simulation → KG → forward) tells a story that has been stable across v2/v2.1/v2.2/v3/v3.1; breaking it for one substantive reframing may cost more than it gains. The scoping note has assumed §9 stays where it is; happy to move it if you would prefer.

2. **§9 audit format.** Should the element-by-element audit of all 50 BMM elements against the General/Tailored criteria be (a) a table appendix with criteria as columns and elements as rows, (b) absorbed into §9 prose with elements grouped by concern, or (c) both — table for at-a-glance reference plus prose for the substantive observations? Argument for (a): table is scannable, easy to reference, easy to update; arguably the right form for a 50-element audit. Argument for (b): prose embeds the criteria in their application context, makes the audit feel like part of §9 rather than an appendix afterthought. Argument for (c): table for navigation, prose for substance — closest match to how PMS v5 handles multi-element content.

3. **Worked Tailored example choice.** §9 will include one worked example of a Tailored extension at full detail. The natural candidates from v3.1 §12.3 are the healthcare-specific StakeholderModel extensions: `SharedCareProtocol`, `ClinicalReferralPathway`, `PatientAdvocacyRelationship`. Of these, `SharedCareProtocol` is probably the richest (it touches multiple BMM concerns — StakeholderModel, GovernanceMapping, ActivityModel — and has clear NHS/specialist provider context). `ClinicalReferralPathway` is simpler but more directly maps to the existing ReferralPathway General element. `PatientAdvocacyRelationship` is the cleanest StakeholderModel-internal extension. My read is `SharedCareProtocol` for the cross-cutting richness; `ClinicalReferralPathway` if a tighter, more pedagogically clean example is preferred. Or another extension entirely if you have one in mind.

---

## 9. Critique Observations and Watchpoints

| ID | Summary | Work Type | Notes |
|---|---|---|---|
| S217-O1 | Test 3 derivations in SBMM v4 will lean on [[ontara-architecture-platform-principles|Architecture Principles v5]] §3.1, §3.4, §5.5, §5.7, §5.1, and §7.3 — the dependency on §5.5 (Metamodel-stratum General/Tailored sub-structuring) is the new thing for Test 3, anticipated by [[ontara-ref-work-item-tracker|OW-215-1]] and [[ontara-ref-work-item-tracker|OW-216-2]]. Cumulative dependency real; the unification hypothesis remains a derivation hypothesis | GOV, ARC | Cross-reference to OW-89, OW-216-2; not a defect, a fair recording. Test 3 will sharpen the unification hypothesis's dependency profile |
| S217-O2 | The expected Test 3 strain point (A11 or A12) reflects the BMM-only framing: A11 and A12 are the principles whose operational reading depends on cross-side and cross-stratum claims that the BMM-only framing of SBMM may find harder to make compactly than the platform-wide framings of Architecture Principles v5 and PMS v5 did. If Test 3 strains, the strain itself is informative | GOV, ARC | Watchpoint for v4 §9 drafting. Strain is acceptable — it identifies which principle has content less compactly derivable from a per-stratum perspective |
| S217-O3 | The §9 worked Tailored example interacts with the v3.1 §12.3 forward-direction note about Tailored StakeholderModel extensions. If the §9 worked example covers the same extension at full detail, §12.3 becomes substantively pre-empted. Treatment as exemplar (not as GSL instantiation) preserves the forward-direction status, but warrants explicit handling | ARC, GOV | Watchpoint for §9 and §12 drafting. Resolution: §9 worked example explicitly framed as exemplar; §12 forward-direction note refocused on the GSL instantiation as the next major BMM exercise rather than on the Tailored extensions themselves |
| S217-O4 | The General/Tailored criteria worked out in §9 may need iteration as the element-by-element audit proceeds. If the audit surfaces a classification ambiguity that the criteria don't cleanly resolve, the criteria need refinement. This is in-session iteration, not a defect — but the scoping note flags it as expected | METHOD | Watchpoint for §9 drafting. Borderline cases explicitly flagged in §9 with brief discussion |
| S217-O5 | The §11 KG-canonical restatement in BMM terms (per Ella S217 direction) accepts differences of emphasis between PMS v5 §11 and SBMM v4 §11 as productive. If the differences turn out to impair rather than aid comprehension, the cross-paper consistency discipline applies via [[ontara-ref-work-item-tracker|OW-216-5]] and the touch-up is in the next session. Standing standing principle: comprehension priority trumps strict cross-reference economy in a project at risk of sprawl | GOV, METHOD | New methodological position, Ella S217. Applies beyond SBMM v4 to all cross-paper relationships in a large project |
| S217-O6 | Engineering authoring-parity asymmetry as it applies to BMM specifically (a sharpening of [[ontara-ref-work-item-tracker|OW-78]] and [[ontara-ref-work-item-tracker|OW-216-3]]). BMM has both SysML projection and canonical OWL; under KG-canonical the OWL is canonical and the SysML is the engineering projection of the projectable parts; the round-trip diff verifies projection fidelity. The asymmetry is acceptable while the SysML projection is the primary authoring surface for BMM elements but will become uncomfortable as canonical KG growth makes direct OWL authoring routine. To be stated in §11 as a known concern | CON, KGO | Watchpoint for §11 drafting. BMM-specific aspect of OW-78/OW-216-3 |

---

## Related Documents

- [[ontara-architecture-business-meta-modelling|Service Business Meta Modelling v3.1]] — the source paper this scoping note targets
- [[ontara-architecture-platform-principles|Architecture Principles v5]] — the upstream foundations paper SBMM v4 derives from (especially §3, §5.5, §5.7, §5.1, §7.3)
- [[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy v5]] — the second foundations paper SBMM v4 derives from (especially §3, §5, §11)
- [[w-049-pms-v5-scoping-note|W-049 PMS v5 scoping note]] — the methodological precedent for this scoping note's structure
- [[ontara-ref-work-item-tracker|Work item tracker]] — W-049 status, OW items referenced throughout (especially OW-77, OW-83, OW-85, OW-87, OW-89, OW-211-5, OW-212-1, OW-215-1, OW-216-2, OW-216-3, OW-216-5)
- [[ontara-workflow-guide|Development Workflow Guide]] — §2.2 (critique), §7.4 (full-rewrite-over-targeted-edits)
- [[session-217-preparation-note|Session 217 preparation note]] — carries the prior-session handover into this scoping
- Stage 9 architectural foundation papers (S192, S195, S196, S197, S198/S200, S199) and S208/S209 strengthened A4 work — context for SBMM v4's framing

---

*W-049 SBMM v4 scoping note. Session 217, 15 April 2026. Drafting recommended for the next session(s) given the §9 deep treatment and §11 BMM-specific KG-canonical restatement scope agreed at S217.*

*GenderSense Limited.*
