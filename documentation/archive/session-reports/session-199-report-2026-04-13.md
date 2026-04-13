---
tags:
  - session-report
date: 2026-04-13
status: current
session: 199
---
# Session 199 — Report

> `= this.file.path`

**Date:** 13 April 2026
**Type:** Discussion ([[ontara-workflow-guide|workflow guide]] §3.2) with substantial document production
**Workstream:** Architecture (ARC) — surface family foundation for Stage 9
**Duration:** Full session

---

## Summary

Session 199 produced a third architectural foundation paper for Stage 9: [[ontara-discussion-surface-families-headless-composition-2026-04-13|Surface Families: Headless Composition Across the Sophistication Gradient]]. The paper sits alongside the [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|S197 substrate paper]] and the [[ontara-discussion-surface-architecture-and-bindings-2026-04-12|S198 surface architecture paper]] and completes the architectural foundation for Stage 9 plan production (pending the Paws and Suds cross-domain checks deferred to S200).

The session took **Option D** relative to the S199 prep note's A/B/C options. The prep note recommended Option A ([[ontara-ref-work-items|W-042]] editorial cleanup + [[ontara-ref-work-items|W-043]] master register additions) as a consolidation move. Ella identified, correctly, that consolidation was premature: the architectural foundation was not actually complete because the surface architecture had only been addressed at the architect-analyst band (S198) and had not been addressed at the customer, staff, and manager bands at all. What was missing was the full *surface family* picture, working from the customer end of the spectrum upward. The session therefore produced the third foundation paper instead, with [[ontara-ref-work-items|W-042]] / [[ontara-ref-work-items|W-043]] / [[ontara-ref-work-items|W-045]] remaining open and the prep note's recommended sequence sliding by one session.

### The paper

The paper is ~13,500 words across 12 sections. Its central commitments are:

1. **There is a sophistication gradient** — the people who interact with an Ontara-supported service business are not one audience or three audiences but a continuum of audiences whose needs differ along several dimensions simultaneously. The gradient is empirically cut into seven *working user bands* (customer, front-line operational staff, back-office staff, operational manager, tenant admin, tenant architect-analyst, Ontara platform engineer). The cuts are explicitly non-constraining per [[concept-non-constraining|J3]] — the architecture's commitment is to the *fact* of the gradient, not to the specific cuts.

2. **The architecture is headless** — capabilities, content, and process are exposed through stable, channel-neutral contracts. Each user band has its own surface family drawing on familiar UI patterns appropriate to that band. The five-layer mental model (canonical model → operational state and transaction services → process orchestration → experience API / BFF → surface families) makes this concrete. The experience-API / BFF layer is named as a **Stage 9 architectural addition** that Ontara does not currently have.

3. **State lives in the right places** — the platform is deeply state-aware in the substrate and deliberately stateless in the layers above. Properly stateful, properly stateless, and properly ephemeral state are distinguished and given homes.

The paper also establishes a **terminological discipline** in §2, naming the four-level distinction (metamodel → configured model → runtime instance → realising component) and committing the rest of the paper to the precise vocabulary. This corrects a category error ("BMM runtime state / SMM at runtime") that has accumulated across several recent papers.

### The Cafe walk-through (§6)

The meat of the paper is a complete walk-through of all seven user bands against the [[domain-cafe|Cafe demonstrator]], at three levels per band: (a) what the user sees and does, in familiar UI/UX terms; (b) what the surface reads and writes via the experience-API layer; (c) what happens in the substrate and orchestration. The walk-through is grounded in the actual cafe demonstrator (real pages, real API routes, real Temporal workflow, real archetypes) rather than invented content.

Walking seven bands × three levels surfaced several confirmations:

- **The substrate is genuinely shared across all bands.** The same BR/BS serves Sara's kiosk order, Marcus's counter transition, Elena's inventory adjustment, Jamie's shift offer, Helen's module installation, Dev's model edit, and Ella's metamodel edit. The S197 substrate paper is validated through use.
- **The experience-API layer is essential.** Without it, every surface family would either re-implement business logic or display raw substrate facts.
- **The familiar UI grammars are wildly different across bands.** Kiosk, counter terminal, back-office console, manager dashboard, admin portal, architect workspace, and IDE-plus-terminal are seven different design idioms. They share nothing visually and everything substratively.
- **The four levels of model are touched at different bands.** Bands 1–4 touch runtime instances only; band 5 touches configured models via wizards; band 6 touches configured models with metamodel-aware tooling; band 7 touches metamodels themselves.
- **The S198 architect surface is one of seven user bands.** Its content is correct for user band 6; its scope claim ("the operator surface") is wrong.

### The S198 relocation

The paper relocates S198 from "the operator surface architecture" to "the architect-analyst workspace (user band 6) architecture." This is a material walk-back of a paper finalised four days ago. The relocation strengthens rather than rejects S198 — all of S198's substantive commitments (bounded agents, four-mode interaction model, binding-grounded action class, capability matrix, structured approval primitive) survive intact within the larger framing. Only the scope claim changes. Ella confirmed explicitly that recency and substantial prior effort do not make a paper immune to revision: *"Just because the S.198 paper was recent and substantial does not make it holy. It was written by Claude under certain prompt circumstances with a particular focus and reach. Not everything was borne in mind. It now needs to be fully revised to make it accurate."*

The S198 revision is the agreed next-session work for S200 (Option Y).

### Editorial decisions captured in-session

Three substantive editorial decisions emerged during the session and are captured here so the next session can rely on them:

1. **"user band" not "band"** — Ella renamed throughout §3 onward during her read. The term distinguishes the project's concept from Agenda for Change staff bands and makes the relationship to RBAC clearer (akin to, not identical with). Standing convention going forward.

2. **"metamodel" as the preferred spelling** — Ella checked usage and observed that "meta model" is the oldest form and going out of use, "meta-model" is no longer current, and "metamodel" is the preferred form in engineering environments. Adopted as the standing convention. Formal artefact names ("Business Meta Model (BMM)", "System Meta Model (SMM)") were deliberately left alone because changing them would cascade across the register, foundations papers, wikilinks, and concept notes — that is a separate normalisation workstream deposited as a new work item ([[ontara-ref-work-items|W-047]]).

3. **Duration is not the criterion for workflow engine use** — Ella challenged the paper's initial framing of layer 3 as "long-running workflows." The revised §4.3 (with three new subsections 4.3.1, 4.3.2, 4.3.3) lays out the structural criteria for orchestration layer membership (multi-step state transition, durability, inspectable history, retry/timeout/compensation, signals, provenance) and names three distinct execution mechanisms (transactions, events, durable workflows) with structural fit rather than duration as the choice criterion. A 600-millisecond payment-plus-order-creation sequence is as much a workflow engine candidate as a multi-hour clinical pathway.

### In-session edits by Ella before the §4.3 rewrite

Ella placed the draft in the vault and edited:
- "band" → "user band" throughout §3 onward
- Added a clarifying paragraph to §3.1 distinguishing user bands from Agenda for Change staff bands and RBAC roles
- Added a BFF definition pullquote to §4
- Small editorial adjustments to §6.1 (Sara's kiosk flow) and §9.5 (cafe frontend)
- §2 heading updated to "Metamodels"

The §4.3 rewrite and the metamodel normalisation pass were then applied via MCP `edit_file` against the vault copy after Ella's edits were in place.

## Register concepts exercised, confirmed, or newly introduced

| Concept | Engagement |
|---|---|
| [[principle-separation-representation-execution\|A1]] | Exercised — every band's writes go through structured action invocations; reads come from the substrate via experience APIs |
| [[principle-self-describing-system\|A2]] | Exercised — each band's surface presents system state in a band-appropriate shape |
| [[principle-model-generates-everything\|A3]] | Exercised — the configured model generates the substrate's structure; experience-API contracts should eventually be model-derived |
| [[principle-two-meta-model-distinction\|A4]] | Extended — four-level distinction (metamodel → configured model → runtime instance → realising component) proposed as A4 amendment or new entry |
| [[principle-validate-in-toy-domains-first\|A5]] | Exercised — cafe walk-through is the first validation of the seven-band framing in a toy domain |
| [[principle-clinical-governance-first-class\|A8]] | Exercised — governance surfaces in user bands 4 and 5 in appropriate dashboard/wizard grammars |
| [[principle-discipline-as-load-bearing-structure\|A9]] | Exercised — state placement, terminological, and band-locality disciplines named explicitly |
| [[principle-intrinsic-self-knowledge\|A10]] | Exercised — surfaces present what they know and how they know it |
| [[principle-unity-principle\|A11]] | Exercised — one substrate, many surfaces, canonical truth unified |
| [[concept-multi-tenancy\|A13]] | Exercised — every surface family is tenant-scoped platform infrastructure |
| [[concept-co-evolution\|J2]] | Exercised — substrate, orchestration, experience APIs, and surface families must co-evolve |
| [[concept-non-constraining\|J3]] | Load-bearing — the seven-band cut is explicitly non-constraining; architecture commits to the gradient, not the cuts |

**Newly proposed register additions** (to be considered as part of W-043 expansion):

- Sophistication gradient (B or J)
- Surface family (B)
- Headless composition (D, once realised)
- Experience API / BFF layer (B)
- State placement discipline (A or J)
- Band locality (D)
- Four-level distinction — metamodel / configured model / runtime instance / realising component (A or B; possibly A4 amendment)
- Non-constraining user bands (J)

## Emergent ideas captured

None new to the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]. The thinking in this session went directly into the foundation paper rather than surfacing orphan ideas. EIL last entry remains E030 (S179).

## Observations and watchpoints table

The following were surfaced this session and are to be deposited in the OW register at C2.

| Summary | Work type | Source | Proposed status |
|---|---|---|---|
| The seven-user-band cut is empirical and revisable; subsequent surface design work should test whether the cuts hold under concrete content | ARC, CON | §3.4 / §6.8 | active |
| The S198 paper should be retitled to *The Architect-Analyst Workspace* and rescoped to user band 6 at full revision | ARC, GOV | §9.2 | active (addressed in S200 per Option Y) |
| The experience-API / BFF layer is a Stage 9 architectural addition; its design is open and substantial | ARC, CON | §4.4 / §10 Q1–Q2 | active |
| The cafe demonstrator's mixed-band SvelteKit frontend needs reframing as several band-clean surfaces during Stage 9 | CON | §9.5 | active |
| Terminological discipline (BMM/BM/runtime instance) must be enforced in every new document; W-042's scope is broader than originally tracked | GOV | §2 / §9.8 | active |
| Band compression in small businesses is a feature not a bug; experience-API contract stability enables small-business composite surfaces | ARC, CON | §3.5 / §10 Q6 | active |
| The four-level distinction may warrant its own register entry or an amendment to A4 | ARC, GOV | §2.1 / §9.7 / §11.2 | active |
| "metamodel" as the standing spelling convention; formal artefact names (BMM, SMM) require separate normalisation workstream | GOV | In-session decision | open as W-047 |
| Duration is not the criterion for workflow engine membership; three distinct execution mechanisms (transactions, events, durable workflows) distinguished by structural fit | ARC | §4.3 / Ella's challenge | resolved in-paper |
| S198 full revision is S200 work (Option Y) | ARC, GOV | In-session agreement | carried to prep note |

## Tier 1 principles honoured

- **[[principle-discipline-as-load-bearing-structure|A9]]**: Terminological discipline (§2), state placement discipline (§5), band-locality discipline (§6.8). Each is a load-bearing practice propagated through the paper.
- **[[concept-non-constraining|J3]]**: The seven-band cut is explicitly non-constraining (§3.4). The architecture's commitment is to the gradient and to headless composition, not to the band cuts.
- **[[principle-validate-in-toy-domains-first|A5]]**: The cafe walk-through grounds the framing in a complete toy domain before any clinical application.
- **[[concept-co-evolution|J2]]**: Substrate, orchestration, experience APIs, and surfaces must co-evolve; none of the layers is independently viable.
- **[[principle-model-generates-everything|A3]]**: The paper anticipates that experience-API contracts themselves should eventually be model-derived.

## Open questions and deferred items

- **Paws cross-domain check (§7)** — deferred to S200
- **Suds cross-domain check (§8)** — deferred to S200 or S201
- **S198 full revision** — S200, per Option Y agreement
- **Experience-API layer design** (Q1–Q2) — Stage 9 planning
- **Surface family build order** (Q3) — Stage 9 planning
- **Authentication and authorisation per band** (Q4) — Stage 9 planning
- **Relationship to existing cafe SvelteKit API routes** (Q5) — Stage 9 planning
- **Small-business composite surface pattern** (Q6) — Stage 9 planning, grounded by Paws walk-through
- **Contract-level test suite** (Q7) — Stage 9 planning
- **Offline operation for band 1 surfaces** (Q8) — Stage 9 planning
- **Metamodel terminology normalisation across existing documents** (W-047) — housekeeping workstream

## Relationship to other papers

- **S197 substrate paper**: reinforced; validated through cafe walk-through.
- **S198 surface architecture paper**: relocated to user band 6; full revision planned for S200.
- **Stage 8 portal (S174)**: located within user band 5; substrate replacement noted as Stage 9 work.
- **Ontara Console**: located within user bands 6–7.
- **Cafe demonstrator's SvelteKit frontend**: characterised as a mixed-band legacy surface requiring Stage 9 reframing.

## Governance actions this session

None in the C3 sense — no reference document refreshes, no currency checks performed. The session was a discussion session producing a foundation paper. Reference document updates ([[—— ARCHITECTURE INDEX ——|Architecture Papers Index]] needs adding the new paper) will be handled at C3.

## Next steps (captured in detail in the [[session-200-preparation-note|S200 preparation note]])

- **S200**: Option Y — full revision of S198 to dovetail with S197 and this paper. The revision retitles, rescopes, and aligns S198 as the user band 6 architectural paper within the surface family framing. Tracked as [[ontara-ref-work-items|W-048]].
- **S200 or S201**: [[domain-paws|Paws]] cross-domain check (§7) and possibly [[domain-suds|Suds]] (§8) — the deferred bottom-half of this paper.
- **Subsequent**: [[ontara-ref-work-items|W-042]] (terminology cleanup, broader scope), [[ontara-ref-work-items|W-043]] (master register additions, expanded), [[ontara-ref-work-items|W-045]] (Campus Walk II), eventually Stage 9 plan production.

---

*Session 199 closed 13 April 2026. Architectural foundation for Stage 9 is now substantively complete on all three sides: substrate (S197), architect-analyst surface (S198, to be formally relocated in S200), and full surface family over the sophistication gradient (this session). The Stage 9 plan remains downstream of S200 consolidation, but the foundation is in place.*
