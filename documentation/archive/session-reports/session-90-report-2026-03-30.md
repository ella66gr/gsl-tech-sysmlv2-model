---
tags:
  - session-report
date: 2026-03-30
status: current
session: 90
---
# Session 90 Report — 30 March 2026
> `= this.file.path`

**Session type:** Mixed (planning/verification + implementation)
**Date:** 30 March 2026

---

## Summary

Session 90 addressed two priorities: closing the carried-forward [[ontara-service-business-meta-modelling|SBMM]] revision item and replacing the 2D [[concept-weighted-relationships|weighted relationship]] graph with an interactive 3D WebGL visualisation.

### 1. Service Business Meta Modelling — Verification and Minor Additions

The carried-forward item "SBMM v2 needs a sixth section for [[concept-stakeholder-model|StakeholderModel]]" was resolved by systematic verification. The [[session-82-report-2026-03-28|Session 82]] revision had already incorporated StakeholderModel thoroughly across all relevant sections of the [[ontara-service-business-meta-modelling|Service Business Meta Modelling]] paper. A section-by-section audit confirmed coverage in §2.1 (concern description), §2.2 (relationships), §3.1 (element table with enums and typed refs), §4 (comprehension coverage), §5.3 (cross-domain validation findings), §6.2 (cross-package refs), §7.7 (mapping), §9 (mapping tree), and §11.5 (Tailored extensions).

Two minor gaps were identified and addressed via targeted additions:

- **§2.4 ([[concept-activity-awareness|Activity Awareness]]):** New paragraph "Stakeholder relationships as activity generators" — notes that [[concept-stakeholder-model|StakeholderModel]] generates governance, service-enabling, and development activity that should be visible through the [[pattern-activity-taxonomy|activity taxonomy]].
- **§10 (Simulation):** New §10.6 "Stakeholder dynamics in simulation" — notes referral pathway volume modelling, external dependency disruption scenarios, and cooperative arrangement performance as simulation-relevant dynamics.

Frontmatter session number updated from 82 to 90. **This item is now closed.**

### 2. 3D Weighted Relationship Graph

The 2D SVG force-directed graph (D3.js, built [[session-72-report-2026-03-25|Session 72]]) was replaced with a fully interactive 3D WebGL graph using the `3d-force-graph` library (vasturiano).

**New dependencies installed:**
- `3d-force-graph@1.79.1`
- `three@0.183.2`
- `three-spritetext@1.10.0`
- `@types/three@0.183.1` (dev)

**New component:** `console/src/lib/components/RelationshipGraph3D.svelte` — replaces `RelationshipGraph.svelte` (old component preserved).

**Features working:**
- 34 nodes as lit Phong-material spheres with specular 3D shading (three-point lighting + point light)
- 96 edges with concern-coloured lines and directional arrow cones
- Bidirectional edge separation via `linkCurvature` + `linkCurveRotation` at perpendicular planes (0 and π/2). Critical finding: `linkWidth > 0` switches to cylinder geometry which silently ignores curvature — must remain at 0.
- Directional flowing particles indicating relationship strength: strong (10 particles, size 4), moderate (6, size 2.5), weak (2, size 1.5)
- HTML overlay labels projected from 3D to 2D screen coordinates via `requestAnimationFrame` loop
- Live springy physics (`d3AlphaDecay: 0.01`, `d3VelocityDecay: 0.3`)
- Orbit rotation, scroll zoom, node drag with pinning (double-click to unpin)
- Shift+drag / right-drag panning
- Node hover tooltips (name, connection count, concern)
- Edge hover tooltips (source → target, strength, rationale)
- Node click triggers side panel with comprehension content
- Reset View button with smooth camera transition
- Dark background (`#0f172a`)

**Key technical findings:**
- `controlType` is a constructor config option (`new ForceGraph3D(el, { controlType: 'orbit' })`), not a chainable method. Using `.controlType('orbit')` in the method chain breaks the entire chain silently.
- `linkWidth > 0` switches the renderer from line geometry to cylinder geometry, which silently ignores `linkCurvature`. Lines must remain thin (width 0) for curvature to work. Thick curved edges require custom `linkThreeObject` geometry (future work).
- SpriteText labels from `three-spritetext` failed to render visibly; HTML overlay labels projected via `requestAnimationFrame` are the reliable alternative.
- Dynamic `import('three')` required `@vite-ignore` or direct installation as a dependency (not just transitive) to work with Vite/Rolldown's import analysis.

**StakeholderModel colour:** Added to `CONCERN_COLOURS` in `colours.ts` as cyan (`#06b6d4`).

**Outstanding from this session:**
- Filtering by concern/strength/search: Code instructions provided and Code has reportedly fixed the issue. Ella to verify in next session.
- Edge line thickness: cannot be increased without breaking curvature (library limitation). Custom `linkThreeObject` + `linkPositionUpdate` with manual Bézier geometry needed — future work.
- Further visual refinements: force tuning, label sizing at different zoom levels, edge visual weight differentiation.

---

## Register Concepts Exercised

- **[[principle-model-generates-everything|A3]] (Model generates everything):** Graph data sourced from `model-introspection.json`, generated from SysML.
- **[[principle-intrinsic-self-knowledge|A10]] (Intrinsic self-knowledge):** Comprehension content displayed in the side panel on node click.
- **[[principle-unity-principle|A11]] (Unity principle):** [[concept-weighted-relationships|Weighted relationships]] rendered as the primary visual — same weights that inform the Glossary and future reasoning.
- **[[concept-co-evolution|J2]] (Co-evolution):** Tooling (3D graph) advanced alongside the model (96 relationships across 34 elements).
- **[[concept-weighted-relationships|B14]] (Weighted relationships):** The entire graph visualises the weighted relationship topology.
- **[[pattern-metadata-driven-generation|D9]] (Metadata-driven generation):** Graph data generated from `@WeightedRelationship` annotations.
- **I12 (Console as architect's tool):** The 3D graph is a tool for the architect to explore and understand the BMM's structural topology.

No new register concepts introduced.

---

## Emergent Ideas

No new emergent ideas captured this session.

---

## Tier 1 Principles Relevant to This Session

| Principle | How honoured |
|---|---|
| [[principle-model-generates-everything\|A3]] (Model generates everything) | Graph data from generated `model-introspection.json` |
| [[principle-discipline-as-load-bearing-structure\|A9]] (Discipline as load-bearing structure) | [[ontara-workflow-development-guide\|Workflow guide]] followed; SBMM verification done systematically before declaring item closed |
| [[principle-intrinsic-self-knowledge\|A10]] (Intrinsic self-knowledge) | Comprehension content in side panel; purposive descriptions accessible via hover |
| [[principle-unity-principle\|A11]] (Unity principle) | Same [[concept-weighted-relationships\|weighted relationships]] rendered visually as inform all other subsystems |
| [[concept-co-evolution\|J2]] (Co-evolution) | New visualisation capability built alongside existing model content |

---

*Session 90 report. 30 March 2026.*
