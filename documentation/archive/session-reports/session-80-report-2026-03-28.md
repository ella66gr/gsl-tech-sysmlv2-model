# Session 80 Report

**Date:** 28 March 2026
**Session type:** Housekeeping
**Focus:** Contents index fix and document header convention

---

## Summary

Session 80 was a dedicated housekeeping session prompted by Ella's discovery that contents index links in the strategic snapshot did not navigate to their target sections — they all linked back to the top of the document.

Investigation revealed this was a systematic problem affecting 19 documents across the vault. The root cause: standard markdown anchor links (`[text](#anchor-id)`) do not work in Obsidian (the primary reading environment) or in Typora (Ella's secondary markdown editor). Only Obsidian's native `[[#heading|display text]]` syntax reliably navigates to target headings within a document. Research confirmed there is no single format that works across Obsidian, Typora, and GitHub — they use incompatible heading ID generation rules.

The three foundations papers (Architecture Principles, Modelling Strategy, Service Business Meta Modelling — all from the rebaselining workstream, Sessions 64–67) were already using the correct Obsidian-native format. Everything else produced by Claude used the broken GFM format.

### Work completed

1. **Root cause analysis.** Researched Obsidian, Typora, and GitHub heading anchor behaviour. Confirmed the incompatibility is a known, unresolved issue in the markdown ecosystem with no universal workaround.

2. **Convention established ([[ontara-workflow-development-guide|workflow guide]] §5.0).** A new subsection "Document Header Format and Contents Index" was added to §5 of the workflow guide, covering:
   - **YAML frontmatter** — minimum four fields: `tags`, `date`, `status`, `session`
   - **Document header block** — standardised field order: subtitle line (discussion papers only), Date, Previous version, Purpose, Status, Depends on. Fields that should not appear: `Participants:`, `Related concepts:` in header
   - **Contents index format** — must use Obsidian-native `[[#heading|display text]]` syntax with bullet list format
   - **`Previous version:`** standardised as the term for superseded document references (replacing inconsistent use of `Replaces:` and `Supersedes:`)

3. **Known pitfall added (§12).** "Contents index uses GFM anchors instead of Obsidian links" added to the pitfalls table.

4. **19 documents fixed.** All broken contents indices converted from GFM anchor format to Obsidian-native format with consistent bullet list presentation:

   **Reference documents (5):**
   - [[ontara-workflow-development-guide|Workflow guide]] (also: convention added, pitfall added, header term standardised)
   - [[ontara-ref-strategic-snapshot|Strategic Reference]]
   - [[ontara-ref-vision-architecture|Vision and Architecture Reference]]
   - [[ontara-ref-master-register|Master Concept Register]] (18 entries)
   - [[ontara-guide-claude-tooling|Claude Tooling Guide]]

   **Discussion papers — BMM Design (4):**
   - [[ontara-discussion-stakeholder-model-detailed-design-2026-03-28|StakeholderModel Detailed Design]] (Session 78)
   - [[ontara-discussion-stakeholder-model-and-bsmm-vocabulary-2026-03-27|StakeholderModel & BSMM Vocabulary]] (Session 76)
   - [[ontara-discussion-component-catalogue-model-assembly-2026-03-18|Component Catalogue & Assembly]] (Session 38)
   - [[ontara-discussion-vision-concepts-principles-2026-03-17|Vision, Concepts, Principles]] (Session 35)

   **Discussion papers — Foundational Architecture (4):**
   - [[ontara-discussion-dual-stack-architecture-2026-03-26|Dual-Stack Architecture]] (Sessions 73–74)
   - [[ontara-discussion-coordinate-framework-2026-03-22_1|Coordinate Framework]] (Session 59)
   - [[ontara-discussion-domain-identity-architecture-2026-03-22-v2.1|Domain Identity]] (Session 59)
   - [[ontara-discussion-temporality-reference-frames-2026-03-22-v2.1|Temporality and Reference Frames]] (Session 59)
   - [[ontara-discussion-ontological-grounding-2026-03-22|Ontological Grounding]] (Session 59)

   **Discussion papers — Comprehension & Self-Knowledge (3):**
   - [[ontara-discussion-comprehension-architecture-2026-03-19|Comprehension Architecture]] (Session 45)
   - [[ontara-discussion-intrinsic-self-knowledge-v2-2026-03-20|Intrinsic Self-Knowledge]] (Session 46)
   - [[ontara-discussion-element-grouping-viewpoints-comprehension-2026-03-19|Element Grouping, Viewpoints]] (Session 38)

   **Discussion papers — Service Delivery & Participation (2):**
   - [[ontara-discussion-paper-process-specification-layer|Process Specification Layer]] (Session 72/75)
   - [[ontara-discussion-service-participation-model-2026-03-21|Service Participation Model]] (Session 55)

### Documents already correct (3)

[[ontara-platform-architecture-principles|Architecture Principles v2]] (Session 64), [[ontara-platform-modelling-strategy|Platform Modelling Strategy v2]] (Session 65), [[ontara-service-business-meta-modelling|Service Business Meta Modelling v2]] (Session 67) — all used the correct Obsidian-native format already.

---

## Register Concepts Exercised

- **[[principle-discipline-as-load-bearing-structure|A9]] (discipline as load-bearing structure)** — the entire session is an exercise of A9. Broken navigation links are a form of structural degradation — they look functional but silently fail, eroding trust in the knowledge base.
- **[[concept-inception-capture|J13]] (capture at inception)** — the convention was captured and codified immediately rather than deferred.

No new register concepts introduced. No register updates required beyond noting this session.

---

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | The fix and the convention both serve A9 directly. A contents index that doesn't navigate is decorative, not structural. |
| [[concept-co-evolution\|J2]] (co-evolution) | Not directly exercised — no model or tooling changes. |
| [[concept-non-constraining\|J3]] (non-constraining) | The Obsidian-native format is a pragmatic commitment to the primary reading environment, not a foreclosure. Documents remain readable (if not navigable) in other environments. |

---

## Carried Forward

- **YAML frontmatter standardisation.** The convention is established in the workflow guide but was not applied to existing documents in this session. This should be done incrementally as documents are next touched, or as a dedicated Claude Code housekeeping task.
- **Priority A from Session 79/80 prep (StakeholderModel SysML implementation)** remains the primary work item for the next session.

---

*Session 80 report written 28 March 2026.*
