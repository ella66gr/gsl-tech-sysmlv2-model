# Session 122 Report — Architecture Map Dark/Light Mode Colour Refresh

**Date:** 3 April 2026 (Session 122)
**Type:** Housekeeping (Console UI)
**Plan:** None (iterative design refinement)

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Work Completed|§2. Work Completed]]
- [[#3. Register Concepts Exercised|§3. Register Concepts Exercised]]
- [[#4. Emergent Ideas|§4. Emergent Ideas]]
- [[#5. Tier 1 Principles Honoured|§5. Tier 1 Principles Honoured]]
- [[#6. Open Items and Deferred Work|§6. Open Items and Deferred Work]]

---

## 1. Summary

Session 122 was a focused housekeeping session that refreshed the colour palette for the Platform Architecture map page in the [[ontara-ref-vision-architecture|Ontara Console]]. Both dark mode and light mode received new colour schemes supplied by Ella, replacing the original terracotta/blue/stone/pink palette with cohesive, purpose-chosen palettes. Badge colours were also intensified across both modes, and several contrast issues were identified and resolved through iterative review.

All changes were made to a single file: `console/src/routes/architecture/map/+page.svelte`.

## 2. Work Completed

### 2.1 Dark Mode Panel Colours

The original dark mode panel backgrounds used very low-alpha RGBA values (0.08–0.12), making panels nearly transparent against the dark background. The panels represent sections of the [[concept-dual-stack-architecture|dual-stack architecture]]. Ella supplied a six-colour forest green palette (`#091008`, `#1F2F22`, `#3E563E`, `#93A889`, `#7993A0`, `#CED9DF`) which was applied as solid hex values across all panel types:

| Section | Background | Border | Heading |
|---|---|---|---|
| BFO (foundation) | `#7993A0` blue-grey | `#93aab5` | `#ffffff` |
| Left stack (business) | `#1F2F22` dark forest | `#3E563E` | `#CED9DF` |
| Right stack (system) | `#3E563E` moss | `#5a7a5a` | `#CED9DF` |
| Reflective simulation | `#93A889` sage | `#adbfa5` | `#ffffff` |
| Green container | `#151f16` near-black | `#3E563E` | `#93A889` |
| Infrastructure | `#1a2520` dark green | `#3E563E` | `#CED9DF` |
| Operator | `#091008` near-black green | `#1F2F22` | `#CED9DF` |

### 2.2 Light Mode Panel Colours

Ella supplied a six-colour warm palette (`#FFCDB2`, `#FFB4A2`, `#E5989B`, `#B5838D`, `#917681`, `#6D6875`) — peach through dusty rose to cool mauve. Applied as:

| Section | Background | Border | Heading |
|---|---|---|---|
| BFO (foundation) | `#FFCDB2` pale peach | `#E5989B` | `#3a1a0e` |
| Left stack (business) | `#FFB4A2` salmon | `#E5989B` | `#4a2020` |
| Right stack (system) | `#E5989B` dusty rose | `#B5838D` | `#3d1a2a` |
| Reflective simulation | `#B5838D` mauve | `#917681` | `#2a0e18` |
| Green container | `#f5ebe8` warm off-white | `#917681` | `#4a3040` |
| Infrastructure | `#ebe4e1` warm grey | `#917681` | `#3d2e35` |
| Operator | `#917681` muted plum | `#6D6875` | `#ffffff` |

### 2.3 Badge Colour Intensification

All five badge types received more saturated light mode overrides (replacing Flowbite's pastel defaults):

| Badge | Colour | Hex |
|---|---|---|
| OWL 2 DL | Vivid violet | `#7c3aed` |
| SysML v2 | Strong blue | `#2563eb` |
| Implemented / Runtime | Rich green | `#16a34a` |
| Mixed / Referenced | Deep gold | `#ca8a04` |
| Designed | Burnt orange | `#ea580c` |

Dark mode badge overrides for Designed (`#5c4033`) and Referenced (`#3d3c1e`) were also established to distinguish them clearly.

### 2.4 Contrast Fixes

Several iterative contrast fixes were made during the session:

- Reflective simulation and Operator panels in light mode: heading and description text initially set to dark, then white, then settled on dark (`#2a0e18`) with white description text overrides for these two darker panels.
- Reflective chips: background adjusted to `rgba(255,255,255,0.45)` with dark text in light mode; `rgba(147,168,137,0.25)` in dark mode.
- BFO and Reflective headings in dark mode: pushed to `#ffffff` for legibility against the medium-toned backgrounds.
- General description text: light mode `#4a3040`, dark mode `#dce4e8`.
- Shimmer animation on Reflective chips removed (it was reducing contrast).

### 2.5 HMR Clarification

Ella confirmed that HMR works for Svelte file edits via MCP — the previous [[ontara-workflow-emergent-ideas-log|E018]] note about needing to restart the dev server is no longer accurate for most cases. The [[ontara-workflow-development-guide|workflow guide]] §12 and the [[ontara-guide-claude-tooling|Claude Tooling Guide]] §7 already note the corrected finding from Session 107.

## 3. Register Concepts Exercised

| Concept | How exercised |
|---|---|
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Iterative design refinement with systematic attention to contrast and readability |
| [[concept-co-evolution\|J2]] (co-evolution) | Console visual design refined alongside the architectural content it displays |

## 4. Emergent Ideas

No new emergent ideas captured this session.

## 5. Tier 1 Principles Honoured

| Principle | How honoured |
|---|---|
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Systematic attention to visual clarity; iterative refinement until satisfactory |
| [[concept-co-evolution\|J2]] (co-evolution) | Console presentation quality kept current with architectural content |

## 6. Open Items and Deferred Work

1. **Delete `DUPLICATE-TO-DELETE-ontara - index-exploratory-discussion-papers.md`** from `04 Ontara Architecture` — Ella to delete from Obsidian. Carried forward from Session 121.
2. **Run `reason_kg.py --save-summary`** — replace mock `reasoning-summary.json` with live version. Carried forward from Session 120.
3. **Continue governance workstream.** Resolve open questions S121-Q1 through Q7. Produce detailed OWL class design. Develop MVP implementation plan. Register six new concepts from the discussion paper §17.2.
4. **Stage 5 Phase 3 scoping** — second priority workstream.
5. **E021 design session** — third priority workstream.
6. **Systematic documentation review** — due ~Session 123.
7. **Repo README.md currency check** — due ~Session 124.
8. **Console data source currency check** — due ~Session 128.
9. **F3 (DISPLAY_OVERRIDES cleanup)** — low priority, carried forward.

---

*Session 122 report produced 3 April 2026.*
