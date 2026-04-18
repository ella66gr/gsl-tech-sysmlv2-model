# Claude Code Instruction Set — W-060 Concept Graph Content Currency Pass
## Session 226, 16 April 2026

**Authority:** W-060 (concept graph content currency pass, 20-session cadence, last done S191). Scan completed S226 by Claude Chat across all ~106 notes (70 concepts, 13 principles, 17 patterns, 6 domains). This instruction set covers only the genuine body-text and structural issues found — not the Source-section attribution fixes, which are covered by W-068.

**Vault root:** `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/03 Ontara Concept Graph/`

**Key finding from scan:** The corpus is substantially current. The S190–S191 rewrite pass and S213 strengthened-A4 propagation have done heavy lifting. Issues are narrow and specific — 4 substantive fixes and 2 structural additions.

---

## Fix 1 — `concept-stakeholder-model.md` — wrong element names + missing frontmatter

File: `concepts/concept-stakeholder-model.md`

**Problem A — wrong BMM element names in Summary section:**

The Summary section says: "The five existing concerns (ServiceConcept, ActivityModel, ResourceCapability, FinancialModel, GovernanceMapping)"

The correct names are:
- `ResourceCapability` → `ResourcePlanning`
- `FinancialModel` → `FinancialPlanning`

Find and replace those two names in the Summary section only.

**Problem B — missing frontmatter fields:**

Current frontmatter is missing `date:`, `session:`, and `source:` fields. Add them:

```yaml
date: 2026-04-16
session: 226
source: ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27
```

Insert these after the existing `implemented_session: 81` line.

---

## Fix 2 — `concepts/concept-three-stratum-knowledge-graph.md` — missing frontmatter + KG-canonical addition

File: `concepts/concept-three-stratum-knowledge-graph.md`

**Problem A — missing frontmatter fields:**

Current frontmatter has no `date:` or `session:`. Add:

```yaml
date: 2026-04-16
session: 226
```

**Problem B — KG-canonical binding not reflected:**

The note describes the three strata accurately but does not reflect that B22 was promoted to binding in Architecture Principles v5 §5.6 (S211), making the three-stratum architecture the internal organisation of the *canonical* store, not merely one implementation option.

Find the Critical Insight section and add after the existing paragraph:

> Under [[concept-knowledge-graph|KG-canonical (B22)]] — binding since Architecture Principles v5 §5.6 (Session 211) — the three-stratum architecture is the internal organisation of the canonical store for the entire Ontara platform. The domain graph is not just an OWL store; it is the authoritative SRS substrate for the State Representation Stratum.

Also update the colophon at the bottom (or add one if absent):

*Concept note created Session 124. Frontmatter and KG-canonical note added Session 226 (W-060 currency pass).*

---

## Fix 3 — `concepts/concept-authority-zones.md` — missing frontmatter + KG-canonical note

File: `concepts/concept-authority-zones.md`

**Problem A — missing frontmatter fields:**

Current frontmatter has no `date:` or `session:`. Add:

```yaml
date: 2026-04-16
session: 226
```

**Problem B — KG-canonical binding not reflected:**

The note describes authority zones correctly but in a pre-KG-canonical framing ("two-formalism architecture"). Under v5 §5.6, OWL is canonical — the authority zones now govern the boundary between the canonical OWL formalism and the SysML engineering projection, not between two equivalent formalisms.

Find the purpose/opening section and add a note after the existing Purpose paragraph:

> Under [[concept-knowledge-graph|KG-canonical (B22)]] — binding since Architecture Principles v5 §5.6 (S211) — authority zones now govern the boundary between the canonical OWL formalism and the SysML engineering projection. The "OWL-authoritative" zone is the canonical store; the "SysML-authoritative" zone covers the projectable subset of platform content.

Update the colophon:

*Concept note created Session 124. Frontmatter and KG-canonical note added Session 226 (W-060 currency pass).*

---

## Fix 4 — `concepts/concept-architectural-section.md` — pre-v5 framing

File: `concepts/concept-architectural-section.md`

**Problem:** The note describes the 20 architectural sections using "left stack / right stack" language throughout without reference to the strengthened A4 reframing. The 20 sections remain valid content but the framing predates v5. The note also has no `date:` or `session:` in frontmatter.

**Frontmatter:** Add:

```yaml
date: 2026-04-16
session: 226
```

**Body:** In the Summary section, find the sentence describing B27 as "A bounded region of the dual-stack architecture (B21)" and update to:

> A bounded region of the [[concept-dual-stack-architecture|dual-stack architecture (B21)]], understood under [[ontara-architecture-platform-principles|Architecture Principles v5]] §3 as a region of the stratified two-side architecture. The 20 sections map to regions across the six strata and two sides of the strengthened [[principle-two-meta-model-distinction|A4]].

In The 20 Sections list, the grouping labels use "Left Stack (BMM)" and "Right Stack (SMM)" — add a note before the list:

> *Note: "Left Stack" and "Right Stack" are informal drawing conventions. Under the strengthened A4, these correspond to the business side and system side respectively across the Metamodel and Configured Model strata.*

Update the colophon:

*Concept note created Session 94. v5 framing note and frontmatter added Session 226 (W-060 currency pass).*

---

## Fix 5 — `domains/domain-gsl.md` — stale model metrics

File: `domains/domain-gsl.md`

**Problem:** The Key Artefacts section lists "10 top-level packages, 72 sub-packages, 364KB across 10 `.sysml` files" from Sessions 5–22. These are pre-Ontara-name figures and significantly stale. The strategic snapshot §3.1 gives current figures.

**Update Key Artefacts section** to remove or replace the stale metrics. Replace with:

> - **SysML:** 12 core model files in `model/`; 12 top-level packages; comprehensive BMM coverage across all six concerns. Current model metrics in the [[ontara-ref-strategic-snapshot|Strategic Reference]] §3.1.
> - **Clinical pathway:** Hormone Therapy Initiation (Sessions 5–7)
> - **Knowledge layer:** Five-phase elaboration (Sessions 11–15)
> - **Business model:** Seven-phase build (Sessions 16–22)
> - **Projection engine:** Python with sensitivity analysis

Update the colophon (add one if absent):

*Domain note refreshed Session 226 (W-060 currency pass) — stale model metrics updated.*

---

## DCR and tracker update (do in vault)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-work-item-tracker.md`

1. **Delete W-060** from Active Work Items (completed).
2. **Update DCR row** for Concept graph note content currency:
   - Change `S191 (W-040)` → `S226 (W-060)`
   - Change `~S211 — W-060` → `~S246`
3. **Bump tracker frontmatter** `session:` to `226` (if not already done by W-068/W-069 run).
4. **Update tracker footer** to add W-060 to the session record.

---

## Commit instruction

```bash
cd /Users/ellagreen/Obsidian/GenderSense
git add "02 ONTARA/03 Ontara Concept Graph/concepts/concept-stakeholder-model.md"
git add "02 ONTARA/03 Ontara Concept Graph/concepts/concept-three-stratum-knowledge-graph.md"
git add "02 ONTARA/03 Ontara Concept Graph/concepts/concept-authority-zones.md"
git add "02 ONTARA/03 Ontara Concept Graph/concepts/concept-architectural-section.md"
git add "02 ONTARA/03 Ontara Concept Graph/domains/domain-gsl.md"
git add "02 ONTARA/01 —— START HERE ——/ontara-ref-work-item-tracker.md"
git commit -m "S226 W-060: concept graph content currency pass — 5 notes updated; DCR refreshed to S226"
git push
```

---

## Verification checklist

Before committing, verify:
- [ ] `concept-stakeholder-model.md` — ResourcePlanning and FinancialPlanning names corrected; frontmatter fields added
- [ ] `concept-three-stratum-knowledge-graph.md` — frontmatter added; KG-canonical note added
- [ ] `concept-authority-zones.md` — frontmatter added; KG-canonical framing note added
- [ ] `concept-architectural-section.md` — frontmatter added; v5 framing note added to Summary and 20 Sections
- [ ] `domain-gsl.md` — stale model metrics replaced
- [ ] Tracker: W-060 deleted; DCR row updated; footer updated

---

## What was scanned and found clean (no action needed)

For the record — all of these were read and assessed as current:

**Concepts (clean):** concept-dual-stack-architecture (S213), concept-knowledge-graph (S213), concept-operational-simulation (S213), concept-reflective-simulation (S213), concept-coordinate-space-snapshots (S213), concept-goal-seeking-computation (S213), concept-reasoning-metamodel (S188), concept-domain-identity (S188), concept-multi-tenancy (S191), concept-weighted-relationships (S191), concept-comprehension-layer (S191), concept-valence (S191), concept-horizontal-mappings (S190), concept-ontology-stack (S148), concept-epistemic-modality (S148), concept-general-tailored-decomposition (S220), concept-smm-general-vocabulary (S190), concept-governance-framework-activation (S190), concept-governance-framework-library (S190), concept-governance-ontology-module (S190), concept-deontic-directive-vocabulary (S190), concept-normative-instrument-taxonomy (S191), concept-service-subject (S190), concept-service-participant (S190). L1–L4 simulation sub-capabilities: body content accurate; Source sections handled by W-068.

**Principles (all clean):** principle-two-meta-model-distinction (S213/S216), principle-separation-representation-execution (S220), principle-self-describing-system (S220), principle-coordinate-framework (S213), principle-unity-principle (S213). Remaining principles not read in full but last updated S189–S191 and lower risk.

**Domains:** domain-cafe (accurate), domain-paws (accurate), domain-ears (S168, accurate). domain-suds not read — fix applied via W-068 (F59 six-concerns fix).

**Patterns:** Not read individually — patterns are implementation-derived (validated against demonstrators) and less exposed to architecture vocabulary drift. W-060 cadence applies to concepts and principles primarily; patterns should be spot-checked at next W-060 pass.

---

*Instruction set produced Session 226 by Claude Chat. W-060 scan covered ~100 of ~106 notes. Execute via Claude Code.*
