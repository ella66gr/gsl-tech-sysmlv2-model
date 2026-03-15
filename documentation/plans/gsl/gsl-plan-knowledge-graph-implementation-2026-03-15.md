# Implementation Plan: Knowledge Graph — SysML-Native Semantic Relationships

**Workstream:** Concept Graph Enhancement — Knowledge Graph
**Date:** 15 March 2026 (Session 31)
**Status:** Implementation plan — ready for execution
**Source:** `gsl-discussion-knowledge-graph-architecture-2026-03-15.md`
**Prerequisites:** PatternCatalogue SysML package operational (22 patterns, 33 domain instantiations). Typed `ref` to `metadata def` and `enum def` verified (Session 30). Obsidian concept graph vault with 17 pattern notes, principle notes, and templates.
**Estimated effort:** 6 stages across 1–2 sessions

---

## Goal

Extend the PatternCatalogue with typed semantic relationships between patterns and architectural principles, all modelled in SysML. Build a generator that reads the SysML model and produces Mermaid visualisations and Obsidian note content. The result: the model describes its own patterns *and how they relate*, and human-consumable views are generated from it.

### What this plan delivers

1. **Syntax verification** — confirm multi-valued `ref :>>` redefinition with tuple syntax between peer part usages.
2. **Extended `Pattern` part def** — typed `ref` fields for the semantic relationship vocabulary (dependsOn, enables, motivatedBy, generalises, constrains, extends, validatedBy, composedWith).
3. **`ArchitecturalPrinciple` part def** — with 8 principle instances representing the foundational architectural commitments.
4. **Populated relationships** — all ~50 relationships from the YAML scaffold encoded as SysML `ref` redefinitions on the 22 pattern instances.
5. **Updated generator** — `gen_concept_graph.py` refactored to read SysML `ref` fields directly (no YAML dependency). Emits 6 Mermaid views.
6. **Updated Obsidian vault** — Concept Graph Index, pattern notes, and templates aligned with the two-layer architecture (SysML + Obsidian, generators between).

### What this plan does not do

- Does not model cross-domain analogues as typed `ref` links (these connect domain concepts, not patterns — handled separately).
- Does not require Hookmark setup (separate spike).
- Does not investigate Tom Sawyer (horizon item).
- Does not modify any SysML packages other than PatternCatalogue.

---

## Risk Assessment

### R1: Multi-valued `ref :>>` redefinition with tuple syntax

**Risk:** The pattern `ref :>> dependsOn = (patternA, patternB);` may not be supported by Syside 0.8.5. Session 30 verified `ref` to `metadata def` and `enum def` (singular and multi-valued declarations on the part def), but did not test `ref :>>` redefinition with a tuple of peer part usages on a part instance.

**Resolution:** Stage 1 syntax test. If tuple syntax fails, fallback options:
- (a) One `ref` per relationship: `ref dep1 : Pattern = patternA; ref dep2 : Pattern = patternB;` — verbose but known-safe.
- (b) Nested relationship parts: `part rel1 : PatternRelationship { ref :>> target = patternA; attribute :>> kind = RelationshipKind::dependsOn; }` — structured but heavy.
- (c) String-based fallback for multi-valued only: `attribute dependsOnRefs : String = "patternA, patternB";` — loses type safety but is the existing pattern.

The fallback hierarchy is (a) > (b) > (c). Option (a) is the most likely needed fallback.

### R2: File size growth

**Risk:** Adding `ref` fields to the part def and redefinitions to all 22 patterns could push `pattern-catalogue.sysml` from ~600 lines to ~900–1,000 lines.

**Resolution:** This is manageable. The file is already the largest in the model. If it exceeds ~1,200 lines, consider splitting into `pattern-catalogue-types.sysml` (defs, enums, principles) and `pattern-catalogue-instances.sysml` (pattern usages with relationships). This follows the precedent of splitting `business-model.sysml` when it grew large. Evaluate after Stage 3.

### R3: Circular references

**Risk:** Some relationships are structurally circular: A enables B, B depends on A. SysML `ref` should handle this (refs are not containment — no ownership cycle), but verify in Stage 1.

**Resolution:** Test a circular `ref` pair in the syntax test file.

### R4: Generator parser complexity

**Risk:** Extracting `ref :>>` redefinitions with tuple syntax from SysML requires more complex regex than the current attribute parser.

**Resolution:** The parser already handles `attribute :>> x = PatternMaturity::validated;` and `attribute :>> x = "string";`. Adding `ref :>> x = (name1, name2);` is a regex extension, not a rewrite. Test in Stage 4.

---

## Stages

### Stage 1: Syntax Verification

**Goal:** Confirm the SysML syntax for multi-valued `ref :>>` redefinition between peer part usages. Resolve R1 and R3 before writing production SysML.

**Time estimate:** 20 minutes

**Work:**

1. **Read the syntax reference** — check for any existing guidance on `ref :>>` tuple redefinition.

2. **Create syntax test file:** `model/syntax-tests/test-ref-redefinition-tuple.sysml`

   ```sysml
   package SyntaxTestRefTuple {
       private import ScalarValues::*;

       part def Thing {
           attribute thingName : String;
           ref relatedThings : Thing[0..*];
       }

       part thingA : Thing {
           attribute :>> thingName = "A";
       }

       part thingB : Thing {
           attribute :>> thingName = "B";
       }

       part thingC : Thing {
           attribute :>> thingName = "C";
           ref :>> relatedThings = (thingA, thingB);  // KEY TEST
       }

       // Test circular ref
       part thingD : Thing {
           attribute :>> thingName = "D";
           ref :>> relatedThings = (thingC);
       }
       // Then update thingC to also ref thingD? 
       // Or test via a second ref field.
   }
   ```

3. **Test in Syside.** Record results.

4. **If tuple syntax fails**, test fallback (a): separate named refs.

   ```sysml
   part thingC : Thing {
       attribute :>> thingName = "C";
       ref dep1 : Thing = thingA;
       ref dep2 : Thing = thingB;
   }
   ```

5. **Document findings** in the syntax reference (v3.13 update).

**Decision gate:** The syntax test result determines the representation strategy for Stages 2–3. Tuple syntax is preferred; named separate refs is the fallback.

**Commit:**
```bash
git add model/syntax-tests/test-ref-redefinition-tuple.sysml*
git commit -m "Syntax test: ref :>> tuple redefinition between peer part usages (Session 31, Stage 1)"
```

---

### Stage 2: Extend PatternCatalogue Type System

**Goal:** Add the relationship vocabulary and `ArchitecturalPrinciple` part def to the PatternCatalogue.

**Time estimate:** 30 minutes

**Work:**

1. **Add `RelationshipKind` enum def** (for future use if individual relationship parts are needed):

   ```sysml
   enum def RelationshipKind {
       doc /* Semantic relationship types between patterns. */
       dependsOn;
       enables;
       motivatedBy;
       generalises;
       specialises;
       constrains;
       extends;
       validatedBy;
       composedWith;
   }
   ```

2. **Add `ArchitecturalPrinciple` part def:**

   ```sysml
   part def ArchitecturalPrinciple {
       doc /* A foundational architectural commitment that motivates
            * one or more patterns. Cross-cutting — principles span
            * both business and system meta models.
            *
            * Business system meta model concept — describes the
            * reasoning behind how the system is structured. */
       attribute principleName : String;
       attribute description : String;
       attribute sourceDocument : String;
   }
   ```

3. **Extend `Pattern` part def** with typed `ref` fields (using syntax confirmed in Stage 1):

   ```sysml
   part def Pattern {
       // ... existing attributes ...
       
       // Semantic relationships
       ref dependsOn : Pattern[0..*];
       ref enables : Pattern[0..*];
       ref motivatedBy : ArchitecturalPrinciple[0..*];
       ref generalises : Pattern[0..*];
       ref constrains : Pattern[0..*];
       ref extends : Pattern[0..*];
       ref validatedBy : Pattern[0..*];
       ref composedWith : Pattern[0..*];
   }
   ```

4. **Add architectural principle instances** (8 principles from §5 of the discussion paper).

5. **Verify in Syside** — ensure the extended part def and principle instances parse cleanly.

**Commit:**
```bash
git add model/pattern-catalogue.sysml
git commit -m "PatternCatalogue: ArchitecturalPrinciple part def, relationship ref fields, 8 principles (Session 31, Stage 2)"
```

---

### Stage 3: Populate Semantic Relationships

**Goal:** Add `ref :>>` redefinitions to all 22 pattern instances, encoding the ~50 relationships from the YAML scaffold.

**Time estimate:** 45–60 minutes

**Work:**

1. **Use the YAML scaffold as specification.** The file `concept-graph/concept-graph-relationships.yaml` contains the complete set of relationships to encode. Work through it systematically, pattern by pattern.

2. **For each pattern**, add the appropriate `ref :>>` redefinitions. Example:

   ```sysml
   part catalogueAsUiContract : Pattern {
       // ... existing attributes ...
       ref :>> dependsOn = (fourLayerItemModel);
   }

   part twoLayerActionFlow : Pattern {
       // ... existing attributes ...
       ref :>> motivatedBy = (clinicalGovernanceAsFirstClass);
   }

   part sysmlAsSingleSourceOfTruth : Pattern {
       // ... existing attributes ...
       ref :>> enables = (metadataDrivenGeneration);
       ref :>> motivatedBy = (separationOfRepresentationAndExecution,
                              modelGeneratesEverything);
   }
   ```

   (Exact syntax depends on Stage 1 findings.)

3. **Cross-check:** Every relationship in the YAML should appear as a `ref :>>` on either the subject or the object pattern (depending on the predicate direction). Not every predicate needs to be encoded on both sides — the generator can infer inverses.

4. **Convention decision:** Which side carries the ref?
   - `dependsOn` — on the dependent pattern (the one that needs the other)
   - `enables` — on the enabling pattern (the one that makes the other possible)
   - `motivatedBy` — on the motivated pattern (the one that fulfils the principle)
   - `generalises` — on the general pattern (the one that is more abstract)
   - `extends` — on the extending pattern (the one that adds capability)
   - `validatedBy` — on the validated pattern (the one that was proven)
   - `composedWith` — on either side (symmetric)
   - `constrains` — on the constraining pattern

5. **Verify in Syside** after every 5–6 patterns to catch errors early.

6. **Evaluate file size.** If `pattern-catalogue.sysml` exceeds ~1,000 lines, note it but do not split yet — splitting is Stage 3 follow-up work if needed.

**Commit:**
```bash
git add model/pattern-catalogue.sysml
git commit -m "PatternCatalogue: semantic relationships — ~50 typed ref links across 22 patterns (Session 31, Stage 3)"
```

---

### Stage 4: Update Generator to Read SysML

**Goal:** Refactor `gen_concept_graph.py` to read `ref :>>` redefinitions from the SysML file, eliminating the YAML dependency for the primary generation pipeline.

**Time estimate:** 30–40 minutes

**Work:**

1. **Extend the SysML parser** to extract `ref :>>` redefinitions. The regex needs to handle:
   - `ref :>> dependsOn = (patternA);` — single target
   - `ref :>> dependsOn = (patternA, patternB);` — multi-valued tuple
   - `ref :>> motivatedBy = (principleName);` — ref to ArchitecturalPrinciple

2. **Extract principle instances** — parse `part x : ArchitecturalPrinciple { ... }` the same way patterns are parsed.

3. **Build relationship graph in memory** — from the parsed refs, construct the adjacency lists that the Mermaid generators need.

4. **Retain the YAML reader as a fallback/alternative input** — useful if someone wants to generate views without the full SysML model, or for testing. But make SysML the default source.

5. **Update CLI:** Default to reading SysML. Add `--source=yaml` flag for fallback.

6. **Test all 6 views** — overview, dependencies, motivation, analogues, maturity, impact.

7. **The analogues view** currently reads from the YAML's cross-domain analogue section. Since analogues are not modelled as `ref` links on patterns (they connect domain concepts, not patterns), this view either:
   - (a) Continues to read from a small YAML section for analogues only, or
   - (b) Reads from a new `DomainAnalogue` part def in SysML, or
   - (c) Is generated from the `DomainInstantiation` usages (two instantiations of the same pattern in different domains are implicit analogues).
   
   Decision: option (c) is the most architecturally clean. The generator infers analogues from shared pattern parentage. Explicit cross-domain concept mappings (MenuItem ↔ Medication) remain in Obsidian notes for now.

**Commit:**
```bash
git add scripts/gen_concept_graph.py
git commit -m "gen_concept_graph: read SysML ref relationships, 6 Mermaid views (Session 31, Stage 4)"
```

---

### Stage 5: Update Obsidian Vault

**Goal:** Align the Obsidian vault with the two-layer architecture (SysML + Obsidian, generators between). Update the Concept Graph Index and remaining pattern notes.

**Time estimate:** 30 minutes

**Work:**

1. **Update Concept Graph Index** — revise to reflect the two-layer architecture:
   - SysML is the source of truth (patterns, relationships, principles)
   - Obsidian is the discursive navigation layer
   - Generators produce Mermaid views and can produce Obsidian note stubs
   - Remove references to YAML as a maintained layer

2. **Update remaining pattern notes** with Semantic Relationships sections derived from the SysML relationships. Use the exemplar (`pattern-two-layer-action-flow.md`) as the template.

3. **Verify Obsidian graph view** — open the vault, check that backlinks between patterns (via the `[[pattern-...]]` links in the Semantic Relationships sections) create a navigable graph.

4. **Note for future:** A generator that emits Obsidian note stubs from the SysML model would eliminate manual synchronisation. Not in scope for this stage but recorded in the plan.

**No commit** — Obsidian vault is not in the sysml-model git repo.

---

### Stage 6: Cleanup, Documentation, and Completion

**Goal:** Final documentation. YAML scaffold disposition. Workstream complete.

**Time estimate:** 20 minutes

**Work:**

1. **YAML scaffold disposition.** The `concept-graph/concept-graph-relationships.yaml` file has served its purpose as a specification. Options:
   - (a) Delete it. The relationships are now in SysML.
   - (b) Move it to `archive/` with a note that it was the scaffold for the SysML implementation.
   - (c) Keep it as a generated artefact — add a `--emit-yaml` flag to the generator that produces it from SysML for interchange purposes.

   Decision at execution time. Lean towards (b) — archival preserves the history without maintaining a parallel source.

2. **Update `gsl-plan-next-steps-and-deferred-items.md`:**
   - Record the Knowledge Graph Enhancement as completed
   - Add the horizon items (Tom Sawyer, D2/Graphviz/Structurizr, Hookmark spike) to §3 candidates
   - Note the generator → Obsidian automation as a future enhancement
   - Update syntax reference TODOs with Stage 1 findings

3. **Update repo conventions** if Stage 1 establishes new syntax patterns.

4. **Syntax reference v3.13** — incorporate Stage 1 findings.

5. **Session report.**

**Commit:**
```bash
git add -A
git commit -m "Knowledge Graph Enhancement: documentation, cleanup, completion (Session 31, Stage 6)"
```

---

## Summary of Deliverables

| Stage | Deliverable | Effort |
|---|---|---|
| 1 | Syntax test: `ref :>>` tuple redefinition | 20 min |
| 2 | Extended type system: `ArchitecturalPrinciple`, relationship `ref` fields, 8 principles | 30 min |
| 3 | Populated relationships: ~50 typed `ref` links across 22 patterns | 45–60 min |
| 4 | Updated generator: reads SysML, emits 6 Mermaid views | 30–40 min |
| 5 | Updated Obsidian vault: index, pattern notes, graph verification | 30 min |
| 6 | Cleanup, documentation, completion | 20 min |
| **Total** | | **~2.5–3 hours** |

---

## Git Commits

| # | Message | Stage |
|---|---|---|
| 1 | `Syntax test: ref :>> tuple redefinition between peer part usages (Session 31, Stage 1)` | 1 |
| 2 | `PatternCatalogue: ArchitecturalPrinciple part def, relationship ref fields, 8 principles (Session 31, Stage 2)` | 2 |
| 3 | `PatternCatalogue: semantic relationships — ~50 typed ref links across 22 patterns (Session 31, Stage 3)` | 3 |
| 4 | `gen_concept_graph: read SysML ref relationships, 6 Mermaid views (Session 31, Stage 4)` | 4 |
| 5 | `Knowledge Graph Enhancement: documentation, cleanup, completion (Session 31, Stage 6)` | 6 |

---

## Design Decisions Summary

| Decision | Resolution | Source |
|---|---|---|
| Source of truth for relationships | SysML-native `ref` fields on `Pattern` | Session 31 discussion |
| YAML scaffold | Temporary specification → archive after implementation | Session 31 discussion |
| Relationship vocabulary | 10 predicates as `ref` fields; `RelationshipKind` enum for future use | Discussion paper §4 |
| Principles | New `ArchitecturalPrinciple` part def, 8 instances | Discussion paper §5 |
| Cross-domain analogues | Inferred from shared `DomainInstantiation` parentage, not modelled as `ref` | Stage 4 design |
| Per-relationship annotations | In Obsidian, not in SysML | Session 31 discussion |
| Generator source | SysML by default, YAML as fallback flag | Stage 4 design |

---

## What Comes After

The knowledge graph workstream produces the semantic layer. Future enrichment:

- **New relationships** are added as `ref :>>` redefinitions when patterns are created or when new connections are identified.
- **New principles** are added as `ArchitecturalPrinciple` instances as they are articulated.
- **Generator → Obsidian automation** — a future generator emits Obsidian note stubs from SysML, eliminating manual synchronisation.
- **Hookmark spike** — separate from this workstream, whenever Ella has time.
- **Tom Sawyer investigation** — when stakeholder communication justifies it.
- **Graph database** — if query complexity exceeds what the Python generator can handle.

---

*Implementation plan prepared 15 March 2026 (Session 31).*
