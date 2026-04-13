---
tags:
  - session-report
date: 2026-04-14
status: current
session: 206
---
# Session 206 Report

**Date:** 14 April 2026
**Session type:** Mixed — housekeeping check + discussion (cross-domain walk-through)
**Workstream:** `architectural-structure.sysml` + console data source currency check; Paws cross-domain walk-through against the S199 Surface Families seven-band framing

---

## Summary

Session 206 had two components. The first was the `architectural-structure.sysml` + console data source currency check, due at ~S206 per the [[ontara-ref-work-item-tracker|Document Currency Register]]. The second was the Paws cross-domain walk-through deferred from S199 §7 — a structured test of the seven-user-band framing, headless five-layer architecture, and state placement discipline against the [[domain-paws|Paws dog grooming demonstrator domain]].

---

## Component 1 — `architectural-structure.sysml` + Console Data Source Currency Check

### `implementationStatus` values (all 20 sections)

All 20 `implementationStatus` values confirmed current. No changes required. The Stage 8 portal workstream has not affected any dual-stack section's status. The model has not changed since S182.

| Sections confirmed correct | Status |
|---|---|
| `bfo`, `domain-ontologies`, `bmm-general-vocabulary`, `business-instance` | `implemented` ✅ |
| `operational-domains`, `business-process-patterns`, `bsmm-general-vocabulary`, `system-instance`, `system-domains`, `operational-simulation`, `reflective-simulation`, `rules-and-constraints`, `terminology-and-information-carriers` | `designed` ✅ |
| `system-ontological-categories` | `referenced` ✅ |
| `mapping-ontology`, `knowledge-graph`, `sysml-v2`, `openehr`, `temporal` | `implemented` ✅ |
| `operator` | `designed` ✅ |

### `@ArchitecturalLocation` summaries

Spot-checked the two sections most likely to have drifted: Knowledge Graph `persistenceSummary` (references 13-file stack and 66-query SPARQL suite) — correct. Mapping Ontology `persistenceSummary` (references `ontara-gov:` namespace) — correct. No changes required.

### Hardcoded console arrays (architecture map page)

All four arrays confirmed current:
- `DISPLAY_OVERRIDES` — one entry (`bsmm-general-vocabulary → 'SMM General Vocabulary'`). Correct.
- `HORIZONTAL_MAPPINGS` — five entries. No new horizontal mappings added; Stage 9 substrate work not yet implemented. Correct.
- `REFLECTIVE_CAPABILITIES` — eight items. No additions. Correct.
- `INFRA_SECTIONS` — six entries. No new infrastructure sections. Correct.

### JSON sync

`console/static/data/model-introspection.json` and `generated/ontara/model-introspection.json` share the same `generatedAt` timestamp (2026-04-07T23:18:19). In sync. ✅

**Verdict: all clear. No model or console changes required. [[ontara-ref-work-item-tracker|Document Currency Register]] row updated to S206 at C2.**

---

## Component 2 — Paws Cross-Domain Walk-Through

### Purpose

To test whether the [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families]] seven-band framing, the headless five-layer architecture, and the state placement discipline hold up against [[domain-paws|Paws]] — a structurally different domain from the [[domain-cafe|Cafe]]. Key structural differences driving the test: appointment-based interaction rhythm (not walk-in), ServiceSubject/ServiceParticipant split (dog ≠ owner), longer sequential one-at-a-time service delivery, pronounced small-business band compression, and a general professional governance posture (Animal Welfare Act 2006) rather than specific regulatory compliance (COSHH, as tested by [[domain-suds|Suds]]).

### Band-by-band findings

**Band 1 — Customer (Pet Owner, Booking Surface).** The band character holds — the owner interacts with a familiar online-booking-form UI grammar, touches only runtime instances (the appointment just created), and is insulated from the meta level. However, band 1 splits into two temporally distinct moments: the async pre-booking interaction (days ahead, online) and the day-of drop-off (in-person, brief). These require two distinct experience-API contract shapes. The booking contract must track both dog (ServiceSubject) and owner (ServiceParticipant) as distinct entities from the outset — a structural requirement not present in the Cafe's customer contract.

**Band 2 — Front-line operational staff (The Groomer).** The band holds but the interaction rhythm is profoundly different from Marcus the barista. The groomer (Sal) works with one dog for 60–120 minutes, progressing through sequential stages (Check-in → Bathe → Clip → Nails → Finish → Handover) with a stage-transition surface that also supports observation logging. The experience-API contract for band 2 must be dog-centric — the ServiceSubject (the dog's condition, health flags, temperament notes) is foregrounded; the ServiceParticipant's details (contact number, payment) are present but secondary. This is the band where the ServiceSubject/ServiceParticipant distinction most directly shapes the contract design.

**Band 3 — Back-office / supporting staff.** The band is real as a set of activities (booking management, supply ordering, equipment maintenance logging, end-of-day reconciliation) but does not map to a distinct person or a distinct surface in a small Paws business. This is the first concrete demonstration of band compression: the sole-trader groomer-owner does band 2 work, then band 3 work, then band 4 work, on the same device. The composite-surface approach is not merely a theoretical convenience for Paws — it is the only realistic deployment.

**Band 4 — Operational manager.** Compressed onto the same person as bands 2–3. The band 4 dashboard needs in Paws are much simpler than the Cafe equivalent: appointments completed, observations flagged, day's takings, comparison to week's average. A very simple operational summary card — not a multi-region dashboard. This suggests the experience-API design should allow lightweight band 4 contract shapes for small-business consumers.

**Band 5 — Tenant admin / business owner.** The portal's wizard-style configuration is appropriate for Paws. The governance surface at band 5 shows evidence records (insurance certificate status, incident log last entry, first aid kit inspection schedule) as a governance checklist — structurally the same surface grammar as would be expected for COSHH compliance (Suds), even though the governance posture is general professional duty rather than specific regulation. This confirms that the governance dashboard pattern generalises across governance postures.

**Band 6 — Architect-analyst.** The band is the least sensitive to domain differences. The architect surface navigates model elements regardless of domain size or character; Paws simply has fewer elements than Cafe. No new findings.

**Band 7 — Platform engineer.** No change from Cafe. Always Ella, always at the meta level.

### Is the seven-band cut itself challenged?

No. The Paws walk-through does not reveal any band requiring splitting or merging. The gradient holds; compression is a deployment and composite-surface design matter, not a taxonomy matter. OW-54 remains active but the Paws evidence does not warrant revision of the band cuts.

### Key findings

1. **The seven-band framing holds against Paws.** The gradient, headless composition over one substrate, and state placement discipline are all confirmed valid in a structurally different domain.
2. **Band compression (OW-59) is concretely confirmed.** In a sole-trader grooming business, bands 2–5 are one person. The composite-surface approach is the necessary deployment pattern, not an edge case.
3. **Band 1 has a temporal split in appointment-based businesses.** The booking moment and the day-of drop-off are distinct interactions requiring distinct experience-API contract shapes, though both remain band 1 in character.
4. **The ServiceSubject / ServiceParticipant distinction propagates into contract shapes.** Band 2 contracts are ServiceSubject-centric; band 1 contracts must hold both entities distinctly. This is a Stage 9 experience-API design requirement, and the pattern will recur in [[domain-gsl|GSL]] (patient as ServiceSubject).
5. **The governance dashboard pattern is domain-posture-independent.** Evidence-record status presented as a governance checklist at band 5 works whether the governance posture is general duty of care (Animal Welfare Act) or specific regulatory compliance (COSHH). Confirmed ahead of the Suds walk-through.
6. **Band 6 is domain-insensitive.** The architect surface's interaction grammar does not change across domains; only content density changes.

### OW-54 status

OW-54 (seven-band cuts are empirical and revisable) remains active. Paws does not require revision. One further cross-domain check (Suds) is planned before the framing can be considered stabilised for Stage 9 planning purposes.

---

## Register Concepts Exercised

- [[concept-non-constraining|J3]] — the non-constraining stance on band cuts confirmed as correct: the Paws case exercises compression and temporal splitting without requiring revision of the fundamental taxonomy.
- [[concept-co-evolution|J2]] — the surface family framing and experience-API layer design must co-evolve with the substrate; this walk-through surfaces concrete design requirements for both.
- [[principle-two-meta-model-distinction|A4]] — the four-level distinction (metamodel / configured model / runtime instance / realising component) confirmed visible in the Paws walk-through: owners and groomers touch runtime instances only; the meta level is not exposed.
- [[principle-self-describing-system|A2]] — each band's surface presents what the system knows about the business in the shape appropriate to that band; the walk-through validates this as achievable for Paws.
- [[concept-dual-stack-architecture|B21]] — the dual-stack substrate confirmed as the shared foundation across all seven bands in the Paws domain.

---

## Observations and Watchpoints

| Summary | Work type(s) | Source | Proposed OW status |
|---|---|---|---|
| The ServiceSubject / ServiceParticipant distinction must propagate into experience-API contract shapes — band 2 contracts are ServiceSubject-centric; band 1 contracts must hold both entities distinctly | ARC, CON | S206 Paws walk-through | active |
| Band compression in small Paws-style businesses collapses bands 2–5 onto one person; the composite-surface approach is necessary, not merely optional | ARC, CON | S206 Paws walk-through — confirms OW-59 | active (updating OW-59) |
| Band 1 in appointment-based businesses has two temporal moments (booking and day-of drop-off) requiring distinct experience-API contract shapes, though both remain band 1 in character | ARC, CON | S206 Paws walk-through | active |
| Band 6 is the band least sensitive to domain differences — the architect surface's interaction grammar does not change across domains | ARC | S206 Paws walk-through | active |
| The governance dashboard pattern (evidence-record checklist) is domain-posture-independent — confirmed by Paws before the Suds walk-through | ARC, GOV, XDV | S206 Paws walk-through | active |

---

## Emergent Ideas Captured

None captured this session.

---

## Open Questions and Deferred Items

- **Suds walk-through ([[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 §8]])** — still to be done. Next cross-domain check.
- **[[ontara-ref-work-item-tracker|W-043]]** — master register additions for S197/S198/S199 concepts — still open; the Paws walk-through adds further candidates (ServiceSubject/ServiceParticipant as experience-API contract design requirement; band compression as validated pattern). Best done after the Suds walk-through.
- **[[ontara-ref-work-item-tracker|W-049]]** — foundations papers §12 targeted refresh — still open; dedicated housekeeping session.

---

## Tier 1 Principles Relevant to This Session

| Principle | How honoured |
|---|---|
| [[principle-discipline-as-load-bearing-structure|A9]] | The currency check was done systematically against the Document Currency Register; the walk-through followed the S199 §7 deferred question structure. |
| [[concept-non-constraining|J3]] | The seven-band framing was applied without treating the band cuts as fundamental; compression and temporal splitting were accepted as domain-specific features, not failures. |
| [[concept-co-evolution|J2]] | The surface family analysis surfaces concrete experience-API design requirements — model and tooling implications held together. |
| [[principle-two-meta-model-distinction|A4]] | The four-level terminology (metamodel / configured model / runtime instance / realising component) was maintained throughout the walk-through. |

---

*Session 206 completed 14 April 2026. Currency check clean; Paws walk-through confirms seven-band framing and surfaces five new OW items. Suds walk-through remains outstanding.*
