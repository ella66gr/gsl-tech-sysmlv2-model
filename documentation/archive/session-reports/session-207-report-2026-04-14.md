---
tags:
  - session-report
date: 2026-04-14
status: current
session: 207
---
# Session 207 Report

> `= this.file.path`

**Date:** 14 April 2026
**Session type:** Discussion (cross-domain walk-through) + governance (partial W-043 register additions)
**Workstream:** [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families]] §8 cross-domain validation against [[domain-suds|Suds]]; partial [[ontara-ref-work-item-tracker|W-043]] master register additions (S199/S207 concepts only)

---

## Summary

Session 207 had two components. The first was the [[domain-suds|Suds]] cross-domain walk-through deferred from [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 §8]] — a structured test of the seven-user-band framing, the headless five-layer architecture, and the state placement discipline against a batch-processing service business with specific regulatory governance (COSHH). The walk-through was folded into the [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 paper]] as §8 in place, mirroring the [[session-206-report-2026-04-14|S206]] treatment of §7 ([[domain-paws|Paws]]). The second was a **partial [[ontara-ref-work-item-tracker|W-043]]** — master register additions for the S199/S207 concepts most clearly in view, while deferring the larger [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197]] / [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198]] substrate-side and surface-side concept set to a dedicated W-043 follow-up session.

The substantive new architectural finding of the session is that **the three-way constraint hierarchy (HardConstraint / SoftConstraint / GradedRule) maps cleanly to three distinct UI affordance types at multiple bands with band-appropriate vocabulary** — at band 3, prevention / suggestion / ranking; at band 5, gates / warnings / scoring. The same canonical constraint state surfaces at two different bands with no per-surface re-implementation. This validates the constraint hierarchy's portability ([[ontara-discussion-institutionalised-reasoning-2026-04-05|S146 reasoning metamodel]]), validates the headless framing's central claim, and clarifies a substantive role for the experience-API layer beyond simple translation.

The seven-band cut held against Suds. Combined with Cafe (immediate retail) and Paws (appointment-based with subject/participant split), the seven bands have now been tested against three structurally different demonstrators and have not had to change. [[ontara-ref-work-item-tracker|OW-54]] (band cuts as empirical hypotheses) and [[ontara-ref-work-item-tracker|OW-69]] (governance dashboard pattern domain-posture-independent) are both marked satisfied.

Five new OW items were deposited (OW-71 through OW-75). Eight new master register entries were added (B40, B41, B42, B43, B44, J15, D28, D29) plus an additive amendment note to A4 and a J3 cross-cutting touchpoint extension. Master register concept count: ~214 → ~222.

---

## Component 1 — Suds Cross-Domain Walk-Through

### Purpose

To test whether the [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families]] seven-band framing, the headless five-layer architecture, and the state placement discipline hold up against [[domain-suds|Suds]] — a structurally different domain from both the [[domain-cafe|Cafe]] ([[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 §6]]) and [[domain-paws|Paws]] ([[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 §7]], walked [[session-206-report-2026-04-14|S206]]). Key structural differences driving the test: batch processing where a single batch contains items from multiple orders; specific regulatory compliance (COSHH) rather than general duty of care; concurrent rather than sequential band sharing; and asynchronous hand-off with synchronous transactions at both ends.

### Method

The Suds SysML model was loaded in full (`exercises/suds-demonstrator/model/suds.sysml`) — three packages (`SudsBusinessModel`, `SudsResourceFinancial`, `SudsGovernance`, `SudsStakeholderModel`) covering ~600 lines of model content including the constraint hierarchy artefacts (`CoshhStorageConstraint`, `CoshhTrainingConstraint`) and the four `AuditEvidenceRecord` types. The S199 paper's §3 (gradient), §2 (four-level vocabulary), and §7 (the precedent Paws shape) were used as the authoritative reference for the framing and the band cuts. Each of the seven bands was walked against realistic Suds scenarios at the level of "what does this band's surface need to do, what does it consume from the experience-API layer, what happens in the substrate." The prep note's three explicit questions (band 3 prominence in batch processing, COSHH content at bands 4–5, constraint hierarchy → UI affordances) were held as the central tests.

The walk-through was conducted with deliberate attention to falsification per [[ontara-workflow-guide|workflow guide]] §1 commitment 5: where the framing held, the qualifications and observations were recorded; where the framing might have been challenged, the candidates were tested explicitly rather than glossed.

### What makes Suds a useful test

Four ways in which Suds is structurally different from both Cafe and Paws (recorded in §8.1 of the paper):

1. **Batch processing where a batch contains items from multiple orders.** Cafe is per-customer immediate; Paws is per-appointment over hours; Suds runs items from several customers through the same machine cycle, then re-tags them back to their orders for return. The operator must hold both order-level state and batch-level state simultaneously.
2. **Specific regulatory compliance, not general duty.** COSHH is testable predicates over discrete facts (current SDS for every chemical, staff trained within interval, ventilated and locked storage), encoded directly as `constraint def`s with a satisfy chain to four `AuditEvidenceRecord` types. Qualitatively different from Paws's Animal Welfare Act general duty of care.
3. **Concurrent rather than sequential band sharing.** Paws sole-trader compression is sequential over a day (OW-70). Suds operator does band 2 work and band 3 work concurrently within the same continuous shift, switching as customers arrive or machine timers go.
4. **Asynchronous hand-off with synchronous transactions at both ends.** Drop-off is synchronous (with weighing and pricing); wait is asynchronous; collection is synchronous. Two distinct band-1 moments.

### Band-by-band findings

**Band 1 — Customer.** The band character holds, but Suds reveals something not seen in Cafe or Paws: **a single band 1 deployment is often a *cluster of surface artefacts*, not a single canonical screen.** A fully-equipped Suds business is likely to offer the customer all of the following together — a customer mobile or web app (the persistent locus, used for browsing, pre-booking, payment, loyalty, tracking, account management), an in-person drop-off moment with a printed ticket (operator-mediated because the weighing must happen on the shop's calibrated scale and only the operator can do it), and SMS or push notifications across the asynchronous wait. The three artefacts together constitute the customer's experience of the band over time. They are *one* band 1 surface family, not three: they share the same canonical truth and stay consistent through their shared experience-API contracts. This is a generalisation of the band, not a violation. The band is defined by audience and interaction shape, not by rendering technology. **OW-71 captures this finding** (sharpened from "surfaces don't have to be screens" to the cluster framing during conversation with Ella, who pointed out that Suds would in practice have the mobile app the customer carries with them).

**Band 2 — Front-line operational staff (the operator at the counter).** This is the moment when the operator is receiving a customer or returning a finished order. Familiar EPOS-like UI grammar with weight-scale integration (the receive flow waits for a scale reading before prompting for wash type and printing the ticket; the collection flow scans a ticket barcode). The hardware integration is a real architectural point — band 1/2 surfaces may need to consume input from peripheral devices, not just keyboard and touch. **OW-74 captures this** as an open Stage 9 design concern for the experience-API layer.

Critically: **the operator's band 2 terminal is the same physical device as their band 3 terminal**, and the application surface itself routes between modes based on what is happening. When a customer walks in mid-batch-load, the operator presses "receive customer" to pre-empt the band 3 view; when the customer leaves, they return. This is the first concrete example of two bands sharing a single physical surface *concurrently*, distinct from the Paws sole-trader case of bands 2–5 being held by one person *sequentially* over a day. The architectural implication is that the experience-API layer must support a composite surface consuming from a band 2 contract and a band 3 contract simultaneously with mode-switching inside one application — and the contracts themselves do not change. Generalises to any small business where the same person operates equipment and serves customers (small bakery, dry cleaner, print shop, auto repair). **OW-72 captures this** as a sibling pattern to OW-70 but architecturally distinct.

**Band 3 — Back-office / supporting staff (the operator at the machines).** This is where the Suds operator spends most of their wall-clock time — concretely confirming the prep note's first question. The Cafe ratio is reversed: in Cafe, band 2 dominates and band 3 is intermittent; in Suds, band 3 (machine operation, sorting, monitoring, finishing) dominates and band 2 (counter receive and return) is intermittent. The interaction shape is batch-oriented and two-layered: the operator must hold an order-level mental model (today's orders and where each is in the cycle) and a batch-level mental model (which machine is running what and when it finishes) simultaneously. Familiar UI grammar is a *batch console*: an order kanban (Received → Sorted → Washing → Drying → Finishing → Ready) coordinated with a machine status panel.

**The substantive new architectural finding emerges at this band.** The Suds SysML model's `sortAndLoad` constraints map exactly onto the three layers of the constraint hierarchy from [[ontara-discussion-institutionalised-reasoning-2026-04-05|S146]]'s reasoning metamodel:

- **HardConstraints** ("delicates and standard cottons cannot share a machine") become **prevented actions** at the surface — refuses the action with an explanatory message.
- **SoftConstraints** ("minimise machine starts by combining same-temperature loads") become **suggestions** at the surface — non-binding nudges with cost displayed.
- **GradedRules** ("high-priority express orders should not wait for a full batch") become **prioritisation hints** at the surface — composite urgency rankings the operator can override.

This is a clean three-way mapping from constraint hierarchy to UI affordance type. **OW-73 captures this**, and the pattern is registered in the master register as **D28** (Section D candidate). It directly answers the prep note's third question: yes, the constraint hierarchy translates cleanly into surface-level UI affordances.

**Band 4 — Operational manager.** In a sole-trader Suds business this is compressed onto the same person as bands 2–3 and 5. In a multi-operator business the dashboard is structurally identical to the Cafe band 4 dashboard, with two domain-specific differences: headline metrics are weight (kg) rather than count (orders), and machine utilisation is a more prominent metric. **The COSHH content surfaces here as a single status tile**, not as model content — *"COSHH compliance: All current. Last storage inspection 3 days ago. Next staff training due in 14 days."* with a click-through to detail. The constraint evaluator (running against the audit evidence record state in BR) computes the green/amber/red status; the dashboard renders it. **The same surface grammar handles both general duty (Animal Welfare Act, Paws) and specific regulatory compliance (COSHH, Suds) without modification.** This concretely confirms [[ontara-ref-work-item-tracker|OW-69]] (governance dashboard pattern domain-posture-independent) at a meaningfully harder test than Paws.

**Band 5 — Tenant admin / business owner.** For COSHH specifically, band 5 is where the meaningful governance work happens — SDS register management, staff training scheduling, monthly storage inspection, annual risk assessment review, response to HSE inspections. These are concrete data entry and document upload tasks against runtime instances of `AuditEvidenceRecord` in BR. The portal's governance section needs surfaces for each — SDS register manager, training record manager, inspection log, risk assessment editor — each a familiar form-and-list UI grammar liftable from any compliance management SaaS. **The crucial finding is that none of these surfaces require model awareness.** The owner doesn't need to know what a `GovernanceRequirement`, `constraint def`, `satisfy`, or `ExternalReference` is; they need to know which chemicals are on file, when training is due, when the next inspection is due. The experience-API layer maps the model concepts onto the everyday questions.

**The constraint hierarchy is also visible at band 5**, but in a different shape than at band 3:
- HardConstraints surface as **compliance gates** (the promotion wizard refuses to advance until SDS for new substances is on file)
- SoftConstraints surface as **warnings** (non-blocking notes in configuration views)
- GradedRules surface as **scoring** (percentage indicators with visual fills)

The same three-layer constraint distinction renders at two different bands using band-appropriate UI grammars, drawn from the same underlying model content. This is the second leg of the OW-73 finding and validates both the constraint hierarchy's portability and the headless framing's central claim that one canonical store serves many surfaces without per-surface logic re-implementation.

**Band 6 — Tenant architect-analyst.** Per [[ontara-ref-work-item-tracker|OW-68]] (band 6 is the band least sensitive to domain differences), no domain-specific findings from Suds. The architect navigates the Suds SM and BM, edits constraint definitions and audit evidence record templates as needed, with the same interaction grammar as Cafe and Paws.

**Band 7 — Ontara platform engineer.** No change. Always at the meta level regardless of which tenant model is in view.

### Assessment

**The seven-band framing holds against Suds.** The gradient, headless composition over one substrate, and state placement discipline are all confirmed valid against a batch-processing service business with specific regulatory governance. Three qualifications and one substantive new finding emerge:

- **Qualification 1 — Band 1 surfaces are clusters of artefacts, not single screens.** Generalisation of the band, not a violation: defined by audience and interaction shape, not by rendering technology. (OW-71)
- **Qualification 2 — Concurrent band sharing is a distinct deployment pattern from sequential band compression.** Paws established the sequential case (OW-70); Suds establishes the concurrent case (OW-72). The architectural implication is that the experience-API layer must support a composite surface consuming from multiple band contracts simultaneously with mode-switching inside one application, with the contracts themselves unchanged.
- **Qualification 3 — Hardware peripheral integration is a real concern at bands 1 and 2.** Weight scales, payment terminals, barcode scanners, medical devices, signature pads — the experience-API layer's contract shapes must accommodate peripheral input, not just keyboard and touch. (OW-74)
- **Substantive new finding — the constraint hierarchy maps cleanly to UI affordances at multiple bands.** Three-way distinction renders at two different bands with band-appropriate vocabulary. The experience-API layer is the locus of the assembly. (OW-73, registered as D28)

**The seven-band cut is not challenged.** No band requires splitting or merging. Combined with the Cafe and Paws walk-throughs, the seven-band working classification has now been tested against three structurally different demonstrators and the cuts have not had to change. **OW-54 marked satisfied** in the work item tracker — the cross-domain test the OW item asked for has been performed and passed. The bands remain revisable per [[concept-non-constraining|J3]] (the non-constraining stance is now a J3 cross-cutting touchpoint in the master register), but no revision is warranted now.

**OW-69 marked satisfied.** The governance dashboard pattern handles both general duty (Paws) and specific regulatory compliance (Suds) without surface grammar modification. **OW-75 deposited** as the maturation of OW-69 — the pattern is now a Section D candidate, registered as **D29**.

### Honest notes on the analytical work

Per [[ontara-workflow-guide|workflow guide]] §1 commitment 5, two interpretive choices were made during the walk-through that another reasonable analyst might call differently:

1. **The walk-in band 1 case was treated as a generalisation of the band (cluster of artefacts) rather than a problem with the band cut.** The judgement is that the band is defined by audience and interaction shape, not by rendering technology. The cluster framing was sharpened mid-session in conversation with Ella, who pointed out that Suds would in practice offer customers a mobile app for tracking, payment, loyalty, etc. — making the cluster (mobile app + printed ticket + SMS) the natural framing and strengthening the OW from "not a screen" to "a cluster unified by shared contracts."
2. **Concurrent band sharing was treated as a new phenomenon distinct from sequential band compression.** The architectural implications differ — sequential compression needs mode-switching across time, concurrent sharing needs mode-switching across moments within the same workflow — so it became a new OW (OW-72) rather than a note on OW-70.

Both choices are recorded explicitly in §8.2 and §8.3 of the paper.

### S199 paper updates

The walk-through was folded into S199 §8 in place, mirroring the S206 treatment of §7. The status block was updated (Suds walk-through complete, S207). The closing trailer was updated to reflect three structurally different demonstrators walked, OW-54 and OW-69 satisfied, and OW-73 as the substantive new finding. No frontmatter changes (the dual-dating convention applies to the trailer, not the frontmatter).

---

## Component 2 — Partial W-043 Master Register Additions

### Scope agreed

After the Suds walk-through completed cleanly and the substantive findings were captured, the second priority was [[ontara-ref-work-item-tracker|W-043]]. The full W-043 scope spans concepts from [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197]] (substrate-side: BR, BS, bindings, observational binding, etc.), [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198]] (surface-side: operator workspace, action class, capability matrix, etc.), and [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] (surface families: gradient, surface family, headless composition, etc.) — substantial enough to be a dedicated session in its own right. Three options were considered: do the whole thing, defer the whole thing, or do a partial covering the concepts most clearly in view from S199 and S207. **Option 3 was chosen** — capture the freshest material while it's most clearly in view, defer the S197/S198 substrate and surface concepts to a dedicated W-043 follow-up session.

Two structural questions were resolved before proceeding:

1. **A4 amendment treatment:** additive approach — register the four-level distinction as a new T2 entry in Section B and add a brief note to A4 pointing to the new B entry as the deeper articulation. A4's identity preserved; the four levels made explicit and findable.
2. **State placement discipline placement:** Section J (Development Methodology and Process Concepts) rather than Section A. Reasoning: it's a discipline applied during design and implementation, parallel in role to A9, sitting naturally in the methodology register.

### Master register additions

Eight new entries plus one amendment plus one cross-cutting touchpoint extension:

| ID | Title | Tier | Section | Source |
|---|---|---|---|---|
| **A4 amendment** | Note pointing to B40 as the deeper articulation | T1 | A | S199 §2 |
| B40 | Four-level distinction (metamodel / configured model / runtime instance / realising component) | T2 | B | S199 §2 |
| B41 | Sophistication gradient (user bands) | T2 | B | S199 §3, cross-domain validated S206–S207 |
| B42 | Surface family | T2 | B | S199 §3.2 / §4.5, cross-domain validated S206–S207 |
| B43 | Experience API / BFF layer | T2 | B | S199 §4.4 |
| B44 | Headless five-layer architecture | T2 | B | S199 §4 |
| J15 | State placement discipline | T2 | J | S199 §5 |
| D28 | Constraint hierarchy → UI affordance mapping | T4 (discussion) | D | S207 §8 |
| D29 | Governance dashboard pattern | T4 (discussion) | D | Cross-domain validated S206/S207 |
| **J3 touchpoint** | Extended with non-constraining bands stance | T1 | A (cross-cutting table) | S199 §3.4 |

Tier counts updated: T2 ~54 → ~60 (six new T2 entries: B40–B44, J15). T4 ~30 → ~32 (D28, D29). Overall concept count: ~214 → ~222.

### Master register S207 history entry

A full register history entry was added to the master register recording the Suds walk-through, the OW deposits, the OW-54 and OW-69 status changes, and the partial W-043 additions. The header date was updated from "13 April 2026 (Session 204)" to "14 April 2026 (Session 207)". The Tier Structure table counts were updated to reflect T2 ~60 and T4 ~32.

### Deferred to a dedicated W-043 follow-up session

The substantial S197 substrate-side concepts and S198 surface-side concepts remain to be added. Specifically:

**From S197:**
- BR (business runtime instances stratum)
- BS (system runtime instances stratum)
- Bindings (typed projection mechanisms)
- Observational binding (binding type for read-only observation)
- KG-as-substrate amendment to B22
- Horizontal mapping rules (S197 §5)
- Substrate boundary pattern

**From S198:**
- Operator workspace (band 6, retitled per OW-55)
- Three-layer interaction model (Ask / Plan / Simulate / Act framework)
- Bounded agency
- Capability matrix
- Action class as binding-derived
- Approval artefact as first-class
- Plan/verify pattern
- Mode-aware agent interaction
- A9 amendment for "agent guided by model truth, not by prompt cleverness"

These should be addressed in a dedicated session with the S197 and S198 papers, the new master register entries (B40–B44, J15), and the W-043 tracker row in view. The dedicated session will likely add another ~12 register entries, bringing the total to ~234.

### Tracker updates

W-043 row updated: status `open` → `in-progress`, notes prepended with the partial completion record listing what was added in S207 and what remains for the dedicated follow-up. OW-54 row: `active` → `satisfied`, session `S199` → `S199→S207`, notes rewritten with the three-domain validation summary. OW-69 row: `active` → `satisfied`, session `S206` → `S206→S207`, notes rewritten with the two-test confirmation. Five new OW rows appended (OW-71 through OW-75). Tracker frontmatter session 206 → 207.

---

## Concepts exercised

[[principle-two-meta-model-distinction|A4]] (deepened via the four-level distinction registered as B40); [[principle-discipline-as-load-bearing-structure|A9]] (state placement discipline registered as J15 is an application of A9); [[concept-non-constraining|J3]] (cross-cutting touchpoint extended with the non-constraining bands stance); [[concept-co-evolution|J2]] (the surface families framing requires both substrate work and surface-family tooling to evolve together); [[principle-self-describing-system|A2]] (the substrate is the canonical truth that all surfaces read from); [[concept-knowledge-graph|B22]] (the substrate is the KG-resident BR/BS); [[concept-dual-stack-architecture|B21]] (the headless five-layer architecture sits on top of the dual-stack BMM/SMM foundation); [[principle-model-generates-everything|A3]] (the experience-API contracts should eventually be derivable from the model); [[principle-unity-principle|A11]] (one substrate, one set of canonical truths, many surfaces — the load-bearing commitment that makes headless composition possible); [[principle-validate-in-toy-domains-first|A5]] (the cross-domain walk-through is the toy-domain validation pattern at work).

---

## Governance actions this session

- **S199 paper:** §8 (Suds cross-domain check) folded in place; status block and closing trailer updated to record S207 completion, three-domain validation, and OW-54/OW-69 satisfaction.
- **Master register:** A4 amendment note added; B40, B41, B42, B43, B44, J15, D28, D29 entries added; J3 cross-cutting touchpoint extended; Tier Structure counts updated (T2 ~54 → ~60, T4 ~30 → ~32); header date updated to 14 April 2026 (Session 207); S207 register history entry added; concept count ~214 → ~222.
- **Work item tracker:** W-043 status `open` → `in-progress` with detailed partial-completion notes; OW-54 status `active` → `satisfied`; OW-69 status `active` → `satisfied`; OW-71 through OW-75 deposited as new rows; frontmatter session 206 → 207.
- **[[ontara-ref-strategic-snapshot|Strategic snapshot]]:** not refreshed — at S203, threshold 7 sessions, currently 4 sessions in. Next refresh due ~S210.
- **Document Currency Register:** no updates needed — S199 is a working discussion paper, not a standing reference document; the [[ontara-ref-master-register|master register]] is "updated every session" per [[ontara-workflow-guide|workflow guide]] §7.1 and is not on the Currency Register.

---

## Findings

**S207-F1 — The constraint hierarchy → UI affordance mapping is a substantive new finding with implementation consequences.** The mapping is concrete enough to support Stage 9 design work directly: the experience-API layer (B43) must be able to assemble constraint evaluator outputs into band-appropriate affordance shapes (gates/warnings/scores at band 5, refusals/nudges/rankings at band 3) from the same underlying constraint state in BR. This is more than a register entry — it's a contract design requirement that should appear in any Stage 9 planning document for the experience-API layer. Tracked as OW-73 / D28.

**S207-F2 — The seven-band cut is now strongly empirically supported.** Three structurally different demonstrators (immediate retail, appointment-based with subject/participant split, batch processing with regulatory governance) walked, no band requiring splitting or merging in any of them. The bands remain revisable per J3 — but the cross-domain test the OW item asked for has been performed and passed, and any future revision now needs to clear a higher evidential bar than the original cuts did. OW-54 marked satisfied.

**S207-F3 — The governance dashboard pattern is robust across governance postures.** Animal Welfare Act general duty (Paws) and COSHH specific regulatory compliance (Suds) both render in the same surface grammar without modification. The pattern (status tile at band 4, evidence-record checklist at band 5, both rendered from constraint evaluator outputs against `AuditEvidenceRecord` runtime instances in BR) is now a Section D candidate. OW-69 marked satisfied; OW-75 / D29 capture the pattern candidate.

**S207-F4 — Band 1 should be modelled as a cluster of artefacts unified by shared contracts.** Sharpened mid-session from "surfaces don't have to be screens" after Ella pointed out that Suds would in practice offer customers a mobile app alongside the printed ticket and SMS. The cluster framing is a stronger and more useful observation than the original — it tells Stage 9 surface designers what to build (a coordinated set of consistent artefacts with a persistent locus and bridge artefacts) rather than just what *not* to assume. OW-71 captures this.

**S207-F5 — Concurrent band sharing in operator-shop businesses is a distinct deployment pattern from sole-trader sequential compression.** The two patterns share the property that one person holds multiple bands but differ in how the surface mediates the transitions: concurrent needs mode-switching within one workflow (Suds), sequential needs mode-switching across a working day (Paws). Both require the experience-API layer to support composite surfaces consuming from multiple band contracts simultaneously, with the contracts themselves unchanged. OW-72 captures this.

**S207-F6 — Hardware peripheral integration is a real Stage 9 design concern.** Weight scales (Suds drop-off), payment terminals (Cafe), barcode scanners (Suds collection, Paws check-in), medical devices (GSL), signature pads — all of these are inputs to band 1/2 surfaces that the experience-API contract shapes must accommodate. The contracts cannot assume keyboard and touch as the only input modalities. Should be flagged in the Stage 9 plan's design questions list when that plan is produced. OW-74 captures this.

---

## Outstanding work

- **Dedicated W-043 follow-up session** (Priority A for next session) — substrate-side concepts (BR, BS, bindings, observational binding, B22 amendment, horizontal mapping rules, substrate boundary pattern) and surface-side concepts (operator workspace, three-layer interaction model, bounded agency, capability matrix, action class, approval artefact, plan/verify pattern, mode-aware agent interaction, A9 amendment). Best done with S197, S198 (revised), and the new master register entries B40–B44/J15 in view. Estimated ~12 new register entries.
- **W-045** (Architecture diagram revision + Campus Walk II) — depends on W-048 (done S200) and the S197 substrate framing being in the diagram. After W-043 follow-up.
- **W-049** (Foundations papers §12 targeted refresh) — dedicated housekeeping session.
- **[[ontara-ref-strategic-snapshot|Strategic snapshot]] refresh** approaching at ~S210 (currently at S203, 4 sessions in, threshold 7).

---

## Documents updated this session

- [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families]] — §8 folded in, status block and trailer updated
- [[ontara-ref-master-register|Master register]] — A4 amendment, B40–B44, D28–D29, J15, J3 touchpoint, Tier counts, header date, S207 register history entry
- [[ontara-ref-work-item-tracker|Work item tracker]] — W-043 in-progress, OW-54 satisfied, OW-69 satisfied, OW-71–OW-75 deposited, frontmatter session

---

## Closing note

Session 207 closes the cross-domain validation of the S199 Surface Families framing across all three demonstrators. The three-demonstrator empirical foundation is now in place. The substantive new finding (constraint hierarchy → UI affordance mapping) gives Stage 9 a concrete contract design requirement to work toward. The partial W-043 captures the freshest material; the dedicated follow-up will complete the substrate and surface-side concept registration. The Stage 9 conceptual landscape is now substantially more legible than it was at the start of the session.

GenderSense Limited.
