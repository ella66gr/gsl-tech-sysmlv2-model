---
abbreviation: S240 report
date: 2026-04-21
session: 240
status: current
tags:
- session-report
version: v1
---

# Session 240 — Report

**Date:** 21 April 2026
**Session type:** Architecture / design — exceptional scope
**Length note:** This report exceeds the usual 600-word architecture/design limit by explicit Ella direction, because the session surfaced a major posture shift for the project and substantial prior-art findings that must be preserved in detail.

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Scope pivot — from W-081 to bottom-up user-band work|§2. Scope pivot — from W-081 to bottom-up user-band work]]
- [[#3. Methodological reset — elicitation failure and course correction|§3. Methodological reset — elicitation failure and course correction]]
- [[#4. Corpus sweep — prior art relevant to bands 1–3|§4. Corpus sweep — prior art relevant to bands 1–3]]
- [[#5. Posture shift — landing and contraction|§5. Posture shift — landing and contraction]]
- [[#6. V1 acceptance criteria|§6. V1 acceptance criteria]]
- [[#7. Work item package|§7. Work item package]]
- [[#8. Master register additions accumulated|§8. Master register additions accumulated]]
- [[#9. Observations and watchpoints surfaced|§9. Observations and watchpoints surfaced]]
- [[#10. Documents produced|§10. Documents produced]]
- [[#11. Priority for next session|§11. Priority for next session]]

---

## 1. Summary

Session 240 was planned as the opening of work on [[ontara-ref-work-item-tracker|W-081]] (the experience-API / BFF discussion paper). Early in the work phase Ella redirected the session twice: first from W-081 as originally scoped to an interactive shaping discussion, then from that interactive discussion to a more fundamental question about user bands and the relative neglect of bands 1–3 in the project's work to date.

The session ultimately produced:
- A scope pivot to a new discussion paper (W-084) on cafe bands 1–3 as the next concrete piece of work, with [[ontara-ref-work-item-tracker|W-081]] parked pending the band work.
- A substantial corpus sweep identifying prior art bearing on the new scope, most significantly the S199 Surface Families paper's existing cafe walk-through of all seven bands including §§6.1–6.3 on bands 1, 2, and 3.
- A major posture shift for the project overall: from expansion through consolidation into contraction, with holistic integration discipline as the governing stance from this point forward.
- A concrete v1 acceptance specification: a locally-hosted platform running four tenant services (cafe, Paws, Suds, Ears) each with simulation capability, band 1–5 surfaces, and queryable performance.
- A package of new work items (W-084 through W-090) and candidate reference documents (v1 acceptance spec; stratum-by-stratum landing register; tenant-by-tenant landing register) to structure the contraction phase.

The session also included a methodological reset midway through, in which Ella identified that Claude had been running ahead with closed elicitation prompts rather than engaging in genuine discussion. The course correction is captured below because the lesson generalises beyond this session.

---

## 2. Scope pivot — from W-081 to bottom-up user-band work

Ella's original direction was W-081 (experience-API / BFF discussion paper). After loading the substrate (the [[ontara-discussion-brl-and-experience-api-2026-04-17|S234 BRL and experience-API paper]], the [[ontara-workshop-brl-binding-class-specifications|S236 binding class specifications]], the [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families paper]] in part) and several rounds of interactive shaping, Ella redirected the session substantively.

The redirection rested on three observations:

1. **The technical business of the experience-API is not a mystery.** Well-established industry patterns exist (Microsoft and others got there first). What is genuinely novel and under-developed in Ontara is not the experience-API layer itself but how the platform meets the actual users at the bands that carry the service — bands 1 (customer), 2 (front-of-house), and 3 (core operator/practitioner).

2. **After 240 sessions, the platform is now closer to the surface than at any previous point**, because the BRL and experience-API framing have brought the backend up against where users actually are. This creates an opportunity and a risk: it would be easy to jump straight into experience-API wiring as the obvious next architectural step, but that would be backend-led surface design — designing the experience-API from what the substrate can offer rather than from what users actually need.

3. **Some bottom-up work on bands 1–3 is required before the experience-API paper is written properly.** Not to replace W-081, but to produce the concrete surface-side material that W-081 will eventually have to contract against. The prior work on bands 4–5 (the business-service-manager prototyping that became the Stage 8 portal, per [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|S174]]) established one band's worth of surface thinking; bands 1–3, which are in many ways the most important for any service business, had received almost none.

Two framing simplifications were agreed:

- **Ears will be the clinical demonstrator, not GSL.** GSL is the production target; Ears is already analytically intaken (Sessions 161–168), has BMM coverage, and is the right regulated-care test domain without the complication of being the live production service.
- **Digital-first interaction assumption.** Cafe, Paws, Suds, and Ears will be modelled assuming digital interaction — web viewports on mobile, desktop, and kiosk devices. Staff-mediated analogue interactions (phone, paper, in-person) are accommodated through how staff use their digital tools to record encounters; the architecture does not need to model telephones, desks, or waiting rooms directly. This is the **modelling-site simplification**: digital surfaces are where Ontara sees and records service activity, regardless of the physical modality of the underlying encounter.

The order of demonstrator work for the contraction phase was confirmed: **Cafe → Paws → Suds → Ears**. Cafe is the first target of the bottom-up bands 1–3 work.

---

## 3. Methodological reset — elicitation failure and course correction

Midway through the session Ella identified that Claude had been producing successive blocks of closed elicitation questions — `ask_user_input_v0` tool calls with predefined option sets — rather than engaging in genuine interactive discussion. The pattern amounted to Claude pre-solving the design space and asking Ella to rubber-stamp choices Claude had already made, despite Ella having explicitly asked for interactive shaping.

Ella's direction: stop using the elicitation tool as a default for shaping discussions. Closed questions with predefined options are appropriate for narrow decisions where the option space is genuinely bounded and well-understood by both parties, but they are the wrong tool for open architectural shaping, where the right move is to let Ella speak first and then respond to what she actually says.

The lesson generalises: **the elicitation tool is efficient for narrow decisions, inefficient for shaping discussions**. Using it reflexively produces the appearance of interactivity without its substance, and it risks Claude monopolising the conversation through the structure of its own questions. This should be recorded as a standing methodological observation (see [[#9. Observations and watchpoints surfaced|§9]]).

After the reset, the session proceeded conversationally. The quality of the subsequent work — the corpus sweep, the posture shift articulation, the v1 acceptance criteria — was visibly better than the pre-reset portion.

---

## 4. Corpus sweep — prior art relevant to bands 1–3

Ella asked for a full sweep of the intellectual knowledge base across the vault to ensure that everything done so far that contributes to the bands 1–3 work was taken into account. The sweep surfaced substantially more relevant prior art than Claude had initially recognised — including one finding that materially changed the shape of the proposed W-084 paper.

### 4.1 Major finding — S199 Surface Families §§6.1–6.3 already exists

The [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199 Surface Families paper]] (Sessions 199, 206, 207) contains a detailed cafe walk-through of all seven user bands, including bands 1, 2, and 3. Specifically:

- **§6.1** — Band 1 customer at kiosk (Sara orders an oat flat white). Full treatment of UI character ("kiosk app" grammar), familiar design idiom pointers, illustrative experience-API contract sketches (`GET /experience/cafe/kiosk/menu/categories`, `POST /experience/cafe/kiosk/order`, etc.), and the substrate/orchestration flow behind each user action.
- **§6.2** — Band 2 barista at the counter (Marcus). EPOS/kanban grammar, contract sketches for queue management and transition dispatch, the state-propagation path from Marcus's tap to all watching surfaces.
- **§6.3** — Band 3 kitchen prep (Elena). Back-office console grammar, inventory adjustment scenario with a constraint re-evaluation chain and alert closure.
- **§§6.4–6.7** — Bands 4, 5, 6, 7 with the same level of detail.
- **§7** — Paws cross-domain walk-through (full, Session 206) — introduces OW-66 (ServiceSubject/Participant propagation), OW-67 (band 1 two-moment in appointment-based businesses), OW-70 (sequential band compression).
- **§8** — Suds cross-domain walk-through (full, Session 207) — introduces OW-71 (band 1 as artefact-family), OW-72 (concurrent band sharing), OW-73 (constraint-hierarchy-to-UI-affordance mapping), OW-74 (hardware peripherals), OW-75 (governance dashboard pattern).

This content is detailed, grounded, and coherent. **The earlier framing that "bands 1–3 have had almost no surface work" was wrong**: there has been substantial surface-thinking work in S199. What has not happened is:
- Translation of the architectural categories S199 established into concrete surface specifications.
- Audit of the existing cafe SvelteKit implementation against the band framing.
- PRS-diagram-level naming of the band 1–3 surface cells.
- Any build work on bands 1–3 in any tenant.

The reframing of W-084 follows: it is not a first-pass bottom-up treatment; it is a **concrete continuation of S199 §§6.1–6.3 for cafe**, bridging from architectural category to engineering specification.

### 4.2 The cafe SvelteKit frontend — substantial mixed-band prior art

The cafe demonstrator has 9 running SvelteKit pages that span bands 2–5 in mixed form: Counter (band 2), Order Board (band 3), Management / Catalogue (bands 4–5), Records (bands 4–5), Audit Dashboard (band 4), Customer Voice (band 1-adjacent feedback surface), Pathway (band 6), System Status (bands 4–7), Order Detail. Plus 19 SvelteKit API routes, Temporal FulfilDrink workflow with XState OrderLifecycle, EHRbase CDR with three archetypes, and a PostgreSQL database with four tables.

These pages are flagged as mixed-band legacy per [[ontara-ref-work-item-tracker|OW-57]]. They embed design thinking about cafe surfaces that predates the band framing. W-084's §7 (audit of existing pages) is the right place to catalogue what survives, what needs reframing, and what is genuinely new.

### 4.3 The Portal paper (S174) — band 4–5 prior art

The [[ontara-discussion-portal-state-driven-operator-experience-2026-04-08|S174 Portal paper]] is the substantive prior art for band 4–5 surfaces. This is the "business-service-manager prototyping" Ella referred to. Its framing is substantial:
- **State as organising principle** (not task menus, not feature menus).
- **State vs status** distinction — status as a dimensionally-reduced comprehension projection over state.
- **Modules as lifecycle containers** — composable, connectable, nestable; not hard-bordered boxes.
- **Three module roles** — business instance / analytical / generative — as a working empirical classification.
- **Lifecycle states** — Available → Installed → Edit mode → Activated → Paused → Stopped → Reset → Deleted.
- **Progressive governance** — exploratory / advisory / enforced as a settable property.

The Ontara Customer Portal (OCP) cell in the v3.2.0 diagram refers to the Stage 8 portal developed against S174. In practice that portal has served band 4–5 (tenant admin / business owner / operational manager), not band 1 (customer). **The name "OCP" is therefore probably wrong**, which is [[#7. Work item package|W-086]].

### 4.4 Validated patterns directly relevant to bands 1–3

- **[[pattern-four-layer-item-model|D1 — Four-layer item model]]** — the basis for catalogue-driven kiosk/counter surfaces. Customer sees catalogue, not MenuItem internals.
- **[[pattern-catalogue-as-ui-contract|D11 — Catalogue-as-UI-contract]]** — the model drives UI shape. The kiosk reads model structure and renders accordingly. This is the practical realisation of [[principle-model-generates-everything|A3]] at the frontend layer.
- **[[pattern-two-layer-action-flow|D6 — Two-layer pathway modelling]]** — domain layer (clinical/operational description) vs orchestration layer (XState/Temporal). The barista sees the domain layer, not the Temporal signals.
- **[[pattern-kanban-as-process-dashboard|D12 — Kanban-as-process-dashboard]]** — XState lifecycle states map to kanban columns. Marcus's counter surface in S199 §6.2 is exactly this pattern.
- **D14 — Category-conditional form fields** — what the kiosk shows varies by category selection (drink vs food).
- **D15 — Cross-page data consistency** — same entity visible on multiple pages without divergence.
- **[[pattern-audit-as-timeline|D16 — Audit-as-timeline data source]]** — the audit trail as first-class content for band 4 dashboards.

### 4.5 ServiceSubject / ServiceParticipant distinction (C1.6 / C1.7)

The [[concept-service-subject|ServiceSubject]] / [[concept-service-participant|ServiceParticipant]] distinction is fundamental for the Cafe → Paws → Suds → Ears progression. The four-way unfolding:

- **[[domain-cafe|Cafe]]** — trivial case, customer = subject = participant.
- **[[domain-paws|Paws]]** — subject ≠ participant (dog vs owner), same person holds multiple participant roles (customer / payer / decision-maker).
- **[[domain-suds|Suds]]** — subject = items, participant = customer. Items have material properties (fabric type, stain type) that determine service parameters.
- **[[domain-ears|Ears]]** — rich participant landscape (patient as self-referrer, GP as referrer, NHS commissioner). Clinical governance obligations bind to the subject independently of who commissioned or paid.

Any band 1/2 contract design must hold both entities as first-class from the start, even when they collapse (as in cafe) — otherwise the surface work does not generalise.

### 4.6 Candidate patterns from OW register

Several OWs surfaced by S199 / S206 / S207 are patterns that exist in the architectural record but have not yet been promoted to Section D of the register:

- **OW-71** — band 1 as cluster of surface artefacts (app + ticket + SMS + kiosk), not a single canonical screen.
- **OW-73** — constraint hierarchy (HardConstraint/SoftConstraint/GradedRule) maps cleanly to three distinct UI affordance types at multiple bands; at operator bands as prevention/suggestion/ranking, at admin bands as gates/warnings/scoring. **Substantive cross-domain finding**, confirmed at Suds, anticipated at Paws and Ears.
- **OW-75** — governance dashboard pattern as a band 4–5 feature rendered from `AuditEvidenceRecord` state, domain-posture-independent.

These are ripe for promotion as W-084 exercises them concretely. They should not be promoted ahead of the concrete exercise; they should be promoted as part of it.

### 4.7 Enabling Architecture (H1) and four-level discipline

- **[[concept-enabling-architecture|H1 — Enabling architecture, not fixed model]]** — platform supports successive generations of self-service without architectural redesign. Matters for band 1: customer autonomy varies across tenants and over time. Cafe has minimal autonomy requirement; Paws has booking self-service; Ears has [[principle-patient-autonomy|patient autonomy]] questions that are politically contested.
- **Four-level terminological discipline** (metamodel / configured model / runtime instance / realising component), from [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] §2. Customers and staff touch only runtime instances. Managers touch projections. Tenant admins touch configured models. Architects touch configured models with meta-aware tooling. Platform engineers touch metamodels. This discipline must be honoured in every surface specification — a customer surface that exposes BMM vocabulary is a category error.

### 4.8 Other relevant prior art noted

- **[[concept-form-generation-from-model|M4 — Form generation from model]]** — horizon concept for generating forms directly from SysML. Bears on band 1–3 surface generation as a long-term direction.
- **[[concept-progressive-automation|Progressive automation]]** — Temporal workflows that orchestrate sequences of human tasks, progressively upgrading to automated tasks as the business is ready. Bears on how band 3 surfaces handle tasks that are currently human but may eventually automate.
- **[[concept-two-phase-construction|Two-phase construction model]]** — Phase 1 (classification and population) vs Phase 2 (relation binding). Not directly a band 1–3 concern but bears on how the platform is populated for any new tenant.

---

## 5. Posture shift — landing and contraction

Ella named an important change of stance for the project from this point forward. This is the most consequential content of the session.

### 5.1 The observation

To date, production work has tended to focus on pieces of functionality in their own right, while checking what [[ontara-ref-master-register|Tier 1 and Tier 2]] principles apply. This is local coherence with principle compliance. It is insufficient.

From now on, every piece of work must be **integrative of the whole corpus** of knowledge, previous work, and design. It must be constantly pulling in the threads of what the Ontara platform is meant to be. This is not a ban on further exploration — there is plenty more to explore around global platform features and other possibilities — but the primary motion of the project changes.

### 5.2 The phase sequence

The project's arc is:

- **Expansion phase** (Sessions ~1–~200). Scoping out the platform. Adding concepts, papers, principles, architectural elements. The primary motion was outward.
- **Consolidation phase** (Sessions ~200–~240). Architectural foundations landing — [[ontara-architecture-platform-principles|AP v5.1]], [[ontara-discussion-brl-and-experience-api-2026-04-17|BRL and experience-API]], [[ontara-discussion-bs-substrate-and-bindings-2026-04-12|substrate]], [[ontara-discussion-surface-families-headless-composition-2026-04-13|surface families]], the eight-stratum architecture. The primary motion was organisational.
- **Contraction phase** (from Session 241 onward). Gradually move from scoping to building the first working version of the platform. The primary motion is landing.

### 5.3 The two disciplines

The posture shift has two parts that are distinct but coupled:

**Holistic integration discipline.** Every piece of new work must be integrative of the corpus, actively pulling threads together. This is not [[ontara-ref-master-register|Tier 1 / 2]] compliance checking alone — that catches principle violations, but it does not catch the slow drift where a paper uses terminology another paper retired, or proposes a pattern another paper already established, or introduces a boundary that contradicts one set elsewhere.

The concrete discipline: **at the start of every substantive work, sweep the corpus for what is already there.** Not just "what principles apply" but "what has been said, what is current, what is superseded, what is ripe for promotion, what is languishing and needs picking up or retiring." The sweep performed today for W-084 is the shape of this, to be done routinely for everything from now on.

Anything that surfaces as languishing — out of date, not integrated, partially superseded — must be picked up rather than left. Either refreshed into alignment, formally retired, or promoted to current. The middle ground where something exists-but-is-not-current is the drift state that corrodes the corpus.

**Contraction discipline.** The default changes. In expansion, the default was "if a new possibility is discovered, explore it." In contraction, the default is "if a new possibility is discovered, capture it in the [[ontara-workflow (eil) emergent-ideas-log|EIL]] and note it against the register, but do not divert the landing of what we already have." New features are no longer the primary work; landing the existing scope is the primary work.

This is a real discipline, because the temptation during contraction is strong. Every bit of implementation work surfaces new possibilities — that is almost definitional. The discipline is to **capture** those possibilities without **enacting** them. Most will become post-v1 work; some will be recognised as genuinely blocking and pulled in; the decision is explicit rather than default.

### 5.4 Operational implications

- **Work item posture shifts.** New W-items are heavily biased toward landing existing material. Items that open genuinely new territory need to be justified against "does this block landing?" rather than "is this architecturally interesting?"
- **The DCR becomes load-bearing, not housekeeping.** A stale reference document in expansion is an inconvenience; in contraction with holistic discipline it is actively dangerous — it will mislead integrative work. Currency is now load-bearing.
- **The systematic review cadence matters more.** Vault-wide reviews every 15 sessions and systematic documentation reviews every ~15 sessions become essential rather than valuable. Findings are no longer "interesting observations for later" but live integration debt.
- **Session scoping changes.** Less "what shall we explore?" and more "what is the next piece of landing work, and what cross-corpus integration does it require?" The integration axis becomes primary.
- **Sessions may become longer** because cross-corpus sweeps cost time. The alternative is to skip the sweep and accumulate drift. The sweep cost is the right cost.
- **Consolidation-only sessions become a legitimate type.** Sometimes the right move is no new work, just integration of things that have drifted apart. The governance / housekeeping session type already exists but has been underused.

### 5.5 What contraction does not mean

Contraction does not mean every gap must be filled before landing. It means every gap must be **known** — either being closed or explicitly deferred with rationale. Some deferrals will be correct: "this piece is architecturally clean and we know how to come back to it post-v1" is a legitimate position. The discipline is that the deferral is named, not inferred by neglect.

Contraction also does not mean stopping thought. The [[ontara-workflow (eil) emergent-ideas-log|EIL]] remains the capture mechanism for emergent ideas; the [[ontara-ref-master-register|register]] remains the capture mechanism for candidate concepts. What stops is the default escalation of emergent ideas into active workstreams.

### 5.6 The reframing of ambition

A reflective observation: the v1 specification Ella named (see [[#6. V1 acceptance criteria|§6]]) is not a minimum viable product in the startup sense. It is a **genuine instantiation of the platform's full architectural commitment across four structurally different domains**. A single-domain v1 would be a demonstrator; a multi-domain v1 is the platform.

This framing makes the contraction concrete: we are not scaling back our ambitions to get to v1; we are **landing our actual ambitions**, which means stopping the addition of new ambition. The discipline is to make the existing scope real rather than to keep enlarging it.

The cafe customer, the pet owner, the laundry customer, and the ear-care patient are waiting. That is the picture.

---

## 6. V1 acceptance criteria

Ella named concrete markers for what version 1 of the Ontara platform looks like:

> In the version 1 working prototype of the Ontara platform, we will have a locally-hosted platform that is running four tenant services, one in each of the existing demonstrator domains. Each will be able to run a simulation of a period of operation using synthetic data. Each will have client / customer / staff / manager, etc. user interface and each will be queryable about its performance.

Unpacked, this acceptance spec has four parts:

### 6.1 Locally-hosted platform running four tenant services

A single locally-hosted Ontara instance with four concurrent tenants, one in each of the existing demonstrator domains: Cafe, Paws, Suds, Ears. Each tenant is a full instantiation, not a stub — configured model (DBM + DSM), substrate content (DBR + DSR), reasoning, bindings, surfaces. The locally-hosted form may be single-machine dev deployment, Docker Compose stack, or local Kubernetes — choice deferred to implementation planning.

### 6.2 Simulation of a period of operation using synthetic data

Each tenant can run a simulation. This exercises:
- The Synthetic Generated Binding (SGB) class of the BRL.
- The Ontara Simulation Runner (OSR) producing events from Scenario Specification Records (SSRs).
- SSRs authored at band 6 (the architect workspace).
- The Reasoning stratum — RSR, PSR, GSR — reasoning over simulation outputs.
- The indistinguishability constraint: real-mode and simulated-mode runs produce structurally identical DSR content modulo epistemic tag. This is [[ontara-discussion-brl-and-experience-api-2026-04-17|S234]]'s Stage 9 falsifiable milestone made actual for all four tenants.

The "period of operation" is tenant-specific: a day of cafe service, a week of Paws bookings, a fortnight of Suds batches, a month of Ears clinic sessions. Concrete durations emerge from scenario-authoring work.

### 6.3 Client / customer / staff / manager user interfaces

Each tenant presents band-appropriate surfaces for at minimum bands 1–5 (and probably 6, since the architect needs to author the tenant's configured model):

- **Cafe**: customer ordering surface, counter surface, operator surface, manager surface, owner surface.
- **Paws**: owner booking surface, groomer surface, operator surface, owner schedule surface.
- **Suds**: customer surface (mobile app + drop-off ticket + SMS notifications), counter/operator surface, owner surface.
- **Ears**: patient surface, clinician surface, operational manager surface, clinical lead surface.

These surfaces must work against the substrate through experience-API contracts. They are tenant-scoped instantiations of common surface-family grammars, not bespoke applications.

### 6.4 Queryable about performance

The [[concept-comprehension-layer|comprehension architecture]] reaches the surface. Each tenant's user, at whichever band, can ask the tenant how it is doing and receive a substantively grounded answer drawn from the substrate. This exercises [[principle-self-describing-system|A2]] (self-describing system) and [[principle-intrinsic-self-knowledge|A10]] (intrinsic self-knowledge) in the production of concrete value.

The v1 bar is minimal viable — the surface can show dashboards and the reasoners can produce meaningful projections. Natural-language querying via an agent would be a richer post-v1 target; the v1 architecture supports it.

### 6.5 What v1 requires at each stratum

Tracing backwards from the spec:

- **Stratum 1 (Foundation)** — already realised via the ontology stack (BFO 2020, CCO, IAO, PROV-O, OGMS). No v1 gap.
- **Stratum 2 (Domain Ontologies)** — BDO and SOC realised to the degree each tenant needs. Cafe, Paws, Suds have some content; Ears requires clinical BDO extension.
- **Stratum 3 (Metamodels)** — BMG (General) and SMG (General) realised; BMD (Domain) and SMD (Domain) realised for each of four sectors (hospitality, veterinary, laundry, healthcare).
- **Stratum 4 (Configured Models)** — DBM and DSM realised for each of four tenants. Cafe DBM largely present; cafe DSM partial. Paws, Suds, Ears DBMs present at BMM level only; DSMs essentially absent.
- **Stratum 5 (SRS)** — DBR and DSR functioning. KGR running locally. Every tenant's runtime instances living there properly.
- **Stratum 6 (Reasoning)** — RSR, PSR, GSR realised. SSRs authored and stored. Scenario execution working.
- **Stratum 7 (Binding Layer)** — BRL realised. At minimum ESB, HMB, SGB, MRB for all tenants. APB, WRB, IGB where tenants need them (Ears likely needs WRB for payment providers; clinical services may need APB for legacy systems).
- **Stratum 8 (PRS)** — GraphDB, EHRbase (for Ears at minimum), OCP (or its successor), ODC, TIC, OSR, TWE all running locally. **Bands 1–5 surface cells for each tenant implemented.**

### 6.6 What v1 does not require

Explicit deferrals that are legitimate:

- **Domain Portability Architecture ([[ontara-ref-work-item-tracker|W-053]])** — portability is expensive and all four tenants run locally on the same platform. The DPA survival test ([[ontara-ref-work-item-tracker|OW-83]]) remains active during landing; the DPA itself is post-v1.
- **Full S198 architect workspace** — the full seven-canvas workspace with Agent Studio, Impact & Diff, approval drawer is more than v1 requires. V1 needs enough architect surface to author and maintain the four tenants.
- **Contract-derived-from-SysML experience-API contracts** — ambitious; the v1 form may be contracts hand-authored against the existing SysML model. Contract derivation is post-v1.
- **Real hardware peripherals** — real payment terminals, real scales, real medical devices. V1 requires the binding classes to exist and function against synthetic or stubbed realising components where the physical world would intrude.
- **Natural-language querying via agents** — v1 needs dashboard-based performance querying; agent-mediated querying is post-v1.

### 6.7 What v1 leaves open

Legitimately open for later decision:

- Concrete "period of operation" durations per tenant.
- Richness of the "queryable about performance" capability beyond the minimal viable form.
- Whether tenants are developed sequentially (almost certainly yes during build) but verified to work concurrently at v1 acceptance.
- Specific technology choice for local deployment (single-machine, Docker Compose, local k8s).
- How much of the Stage 8 portal survives versus is replaced.

---

## 7. Work item package

The session's outputs map to a set of new work items. These are proposed; they are added to the [[ontara-ref-work-item-tracker|tracker]] at close.

### 7.1 New W-items

- **W-084** — Cafe bands 1–3 discussion paper. Concrete continuation of [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] §§6.1–6.3. Audit of existing cafe SvelteKit pages. PRS cell proposal. Contract shopping-list for W-081. Cross-domain forward-look to Paws/Suds/Ears. Priority B. Estimated 2 sessions.
- **W-085** — PRS diagram extension: band 1/2/3 surface cells. Coupled to W-084; some cells can only be named once W-084 has done its work. Priority B.
- **W-086** — OCP clarification. Audit what OCP actually is (band 4–5 service-manager surface per S174) versus what the name implies (band 1 customer surface). To be handled inline within W-084. Priority C; inline.
- **W-087** — Posture shift to landing and contraction. Capture the shift formally. Workflow guide amendment (§1 commitment on holistic integration; note on contraction phase in session-scoping guidance). Addition of landing-phase reference documents as a new DCR class. Priority A; partially handled by producing this session report and the S241 prep note; completion in S241.
- **W-088** — v1 acceptance spec reference document. Short, standing, load-bearing. Candidate path `02 ONTARA/01 —— START HERE ——/ontara-ref-v1-acceptance.md`. Priority A; to produce in S241.
- **W-089** — Stratum-by-stratum landing status register. New reference document; eight strata × status-per-stratum. Candidate path `02 ONTARA/01 —— START HERE ——/ontara-ref-landing-strata.md`. Priority A to skeleton; detailed fill-out is subsequent work.
- **W-090** — Tenant-by-tenant landing status register. New reference document; four tenants × eight strata grid. Candidate path `02 ONTARA/01 —— START HERE ——/ontara-ref-landing-tenants.md`. Priority A to skeleton; detailed fill-out is subsequent work.

### 7.2 W-items reshaped by the session

- **W-081** (experience-API / BFF discussion paper) — parked pending bands 1–3 work. The substrate audit for W-081 was done in this session and is preserved in this report. W-081 picks up after W-084 lands, with the bands 1–3 material as concrete input. Remains Priority B.
- **W-082** (terminology propagation from S236 diagram evolution) — continues in parallel; not affected by posture shift directly but its currency implications become more important under landing discipline.
- **W-083** (ongoing architecture diagram work beyond S239 connector pass) — continues; W-085 sits naturally under this umbrella.

### 7.3 W-items whose status the session touches

- **W-053** (Domain Portability Architecture) — explicitly deferred to post-v1 per [[#6.6 What v1 does not require|§6.6]]. OW-83 DPA survival test remains active during landing.
- **OW-33** (horizontal runtime mappings) — must be resolved before v1. The MRB placement question ([[ontara-workshop-brl-binding-class-specifications|Q-MRB-1]]) has to be decided. Surfaces as a concrete contraction task.
- **W-071** (Non-Technical Overview refresh) — deferred per existing state; still deferred; revisit post-v1.

---

## 8. Master register additions accumulated

The sweep surfaced that several candidate concepts have accumulated from [[ontara-discussion-surface-families-headless-composition-2026-04-13|S199]] §9.7, [[ontara-discussion-brl-and-experience-api-2026-04-17|S234]] §13, and [[ontara-workshop-brl-binding-class-specifications|S236]] without being added to the master register yet. They should be addressed as a register-pass W-item rather than inline — producing them properly requires a dedicated session and is not appropriate as a side activity of W-084.

### 8.1 From S199

- **Sophistication gradient** (B or J).
- **Surface family** (B).
- **Headless composition** (D, candidate once realised in implementation).
- **Experience-API / BFF layer** (B).
- **State placement discipline** (A or J).
- **Band locality** (D).
- **Four-level distinction** — metamodel / configured model / runtime instance / realising component (A or B; possibly A4 amendment).
- **Non-constraining bands stance** (J).

### 8.2 From S234

- **Binding Realisation Layer (BRL)** — B, likely T2.
- **Experience-API / BFF layer** — B, likely T2. [Overlaps with S199 candidate.]
- **Canonical edge contract** — B, likely T3.
- **Realiser family** (taxonomy of realiser classes) — D or B.
- **Synthetic-generator realiser** — B or D. [Now named SGB in S236.]
- **Indistinguishability constraint** — N or amendment to A11.

### 8.3 From S236 binding class specifications

All seven binding classes — ESB, APB, WRB, HMB, IGB, SGB, MRB — at concept level. Section B entries likely.

### 8.4 From S240 (this session) surfaced candidates

- **Band 1 as artefact-family pattern** (from OW-71) — D candidate once realised.
- **Constraint-hierarchy-to-UI-affordance mapping** (from OW-73) — D candidate, already cross-domain validated at Suds, anticipated for Paws and Ears.
- **Governance dashboard pattern** (from OW-75) — D candidate, already cross-domain validated.
- **Landing-phase reference documents as a DCR class** — workflow guide addition; N entry candidate.
- **Holistic integration discipline** — A or J; governing stance from S240 onward.
- **Contraction phase default** — A or J; phase-specific governing stance.

### 8.5 Handling

These should not be promoted individually ahead of the concrete work that exercises them. The right handling:

1. Record the candidate list in this session report (done, above).
2. Open a dedicated W-item for the register-additions pass. Candidate: **W-091 — master register additions from S199/S234/S236/S240**. Not opening now; to be opened in S241 if scope permits.
3. As concrete work exercises specific candidates (W-084 will exercise the bands 1–3 candidates; future BRL work will exercise the binding-class candidates), promote those candidates at the C2 of the session that exercises them.

---

## 9. Observations and watchpoints surfaced

New OW items to deposit at C2:

- **OW-S240-1** — Posture shift to landing and contraction phase is now the governing stance. Every session must exercise holistic integration discipline and honour contraction defaults. Action: apply from S241 onward; capture in workflow guide v4.
- **OW-S240-2** — Landing-phase reference documents (v1 acceptance; stratum register; tenant register) are a new class of reference document and should be added to O2 currency checking. Action: add to DCR when landing references are created in S241.
- **OW-S240-3** — The S199 Surface Families paper's cafe walk-through (§§6.1–6.3) and the Paws (§7) and Suds (§8) walk-throughs are load-bearing prior art for any future surface work for bands 1–3 in any tenant. Action: reference before starting fresh.
- **OW-S240-4** — The existing cafe SvelteKit frontend (9 pages, 19 API routes) is mixed-band prior art per [[ontara-ref-work-item-tracker|OW-57]]; W-084 must audit it against the band framing rather than replace without audit. Action: applies in W-084 §7.
- **OW-S240-5** — Master register additions have accumulated from S199 / S234 / S236 / S240 without being landed. Sweep surfaced substantial list (see [[#8. Master register additions accumulated|§8]]). Action: open W-091 as a dedicated register-pass item in S241.
- **OW-S240-6** — The elicitation tool (`ask_user_input_v0`) is efficient for narrow decisions with bounded well-understood option space. It is inefficient for shaping discussions and should not be the default for open architectural shaping. Using it reflexively produces the appearance of interactivity without its substance and risks the assistant monopolising the conversation. Action: standing methodological discipline; apply to all future shaping work.
- **OW-S240-7** — The modelling-site simplification — digital surfaces are where Ontara sees and records service activity regardless of the physical modality of the underlying encounter — is a first-class simplification that does not foreclose analogue interactions (which are accommodated through how staff use digital tools to record encounters). Action: record in v1 acceptance spec and carry through to W-084.
- **OW-S240-8** — Ears, not GSL, is the clinical demonstrator for the landing phase. GSL remains the production target post-v1. Action: reflect in v1 acceptance spec and in all subsequent references to the clinical demonstrator.
- **OW-S240-9** — OCP naming is probably wrong; the portal as built serves bands 4–5, not band 1. W-086 handles inline with W-084 §8. Action: resolve in W-084.

---

## 10. Documents produced

- [[session-240-report-2026-04-21|Session 240 report]] (this document) — comprehensive session record preserving all detail surfaced, exceeding usual 600-word limit by Ella direction.
- [[session-241-preparation-note|Session 241 preparation note]] — rich bridge document carrying forward the session's decisions, sweep findings, work-item package, master register candidates, OWs, and priority sequence.
- [[ontara-ref-work-item-tracker|Work item tracker]] — updated with W-084 through W-090; W-081 status note updated; existing items unchanged.

### Deferred to S241

- **v1 acceptance spec** (candidate `ontara-ref-v1-acceptance.md`) — to produce in full.
- **Workflow guide v4** — to produce with posture-shift amendments.
- **Stratum-by-stratum landing register** (candidate `ontara-ref-landing-strata.md`) — to skeleton.
- **Tenant-by-tenant landing register** (candidate `ontara-ref-landing-tenants.md`) — to skeleton.

### Deferred beyond S241

- W-084 full paper (target S242–S243).
- W-091 master register additions pass (target TBC in S241).

---

## 11. Priority for next session

**Priority A for S241** — landing-phase reference infrastructure:
- Produce v1 acceptance spec (W-088).
- Produce workflow guide v4 with posture-shift amendments (W-087).
- Skeleton stratum register (W-089).
- Skeleton tenant register (W-090).
- Open W-091 for master register additions pass if scope permits.

**Priority B carry-forward**:
- W-084 (cafe bands 1–3) — begins S242 or later, depending on S241 capacity.
- W-085 (PRS diagram extension) — sits under W-083; progresses with W-084.
- W-083 (ongoing architecture diagram work) — continues.
- W-082 (terminology propagation) — continues.
- W-080 (BRL discussion paper) — paused pending landing-phase work; remains queued.
- W-081 (experience-API / BFF discussion paper) — paused pending W-084; substrate audit preserved in this report.

**Governance consequence of deferrals**: None significant. No Priority A items are being dropped. The posture shift reframes what "Priority A" means going forward — landing-phase items now take precedence over expansion-phase items regardless of their order of arrival in the tracker.

---

*Session 240 conducted 21 April 2026. The session's exceptional nature — a major posture shift for the project plus a substantive corpus sweep — warranted exceeding the usual 600-word limit for architecture/design session reports. All detail surfaced has been preserved here or in the accompanying preparation note. GenderSense Limited.*
