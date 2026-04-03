---
tags:
  - session-report
date: 2026-04-03
status: current
session: 115
---
# Session 115 Report — 3 April 2026

**Session type:** Implementation (Code)
**Follows:** [[session-114-report-2026-04-03|Session 114]] (Steps 1–3 complete — axiomatic foundation laid)
**Plan reference:** [[session-111-stage5-phase2-plan|Stage 5 Phase 2]], Step 4 (HermiT/Pellet integration via Robot)

---

## Summary

Session 115 completed Step 4 of the [[session-111-stage5-phase2-plan|Stage 5 Phase 2 plan]]: integrating a full [[concept-ontology-stack|OWL 2 DL]] reasoner into the Ontara project tooling. Robot v1.9.8 (wrapping [[concept-ontology-stack|HermiT]]) was downloaded, installed, and wrapped in a Python script that reasons over the complete ontology stack. Both the happy-path consistency check and a deliberate violation test passed cleanly.

This is the first time the full Ontara ontology stack — [[concept-ontology-stack|BFO 2020]], IAO, CCO, the pipeline-generated BMM ontology, and the hand-authored axiom file — has been reasoned over by a full OWL 2 DL reasoner in a single automated pass. The reasoner confirms that all 34 [[ontara-service-business-meta-modelling|BMM]] classes, 6 union classes, 1 AllDisjointClasses declaration, 13 object properties, and 9 cardinality restrictions are logically consistent.

---

## What Was Built

### Robot installation

Robot v1.9.8 (the latest release) was downloaded as a standalone JAR into a new `tools/` directory at the repo root. Robot is a command-line OWL tool maintained by the OBO community that wraps HermiT for full OWL 2 DL reasoning. It requires Java 11+; Ella's machine has Java 25 (Temurin LTS), which works with harmless `sun.misc.Unsafe` deprecation warnings.

### `scripts/reason_kg.py`

A Python wrapper script (~280 lines) that:

1. Runs pre-flight checks: Java available, Robot JAR present, all 5 ontology files exist (with sizes reported).
2. Merges the full ontology stack via Robot's `merge` command with `--collapse-import-closure true` — this prevents Robot from trying to fetch remote import IRIs over the network.
3. Chains into `reason --reasoner hermit --annotate-inferred-axioms true --exclude-tautologies structural`.
4. Reports: consistency (pass/fail), unsatisfiable classes (if any), full error output on failure.
5. `--test-violation` flag: creates a temporary Turtle file that asserts `ValueProposition rdfs:subClassOf ActivityModelElement` (contradicting the AllDisjointClasses axiom between ServiceConceptElement and ActivityModelElement), merges it with the full stack, and confirms HermiT catches the contradiction.
6. `--output` flag: optionally saves the inferred ontology.
7. `--verbose` flag: shows Robot command lines and full stdout/stderr.
8. Exit code 0 on pass, 1 on fail — CI-compatible.

The script sits alongside [[session-106-report-2026-04-02|`validate_kg.py`]] in the scripts directory. The two scripts are complementary: `validate_kg.py` handles SPARQL validation against GraphDB; `reason_kg.py` handles [[concept-ontology-stack|OWL 2 DL]] reasoning via HermiT. Together they cover both the graph-query and formal-reasoning dimensions of [[concept-knowledge-graph|knowledge graph]] validation.

### Supporting changes

- **`tools/README.md`** — installation instructions for Robot.
- **`.gitignore`** — `tools/*.jar` added (each developer downloads their own copy).
- **`README.md`** — updated with Step 4 status, `reason_kg.py` in the repo structure tree, Robot in the technology stack table, new key commands section entries.

---

## Test Results

### Consistency check (happy path)

The full ontology stack (~2 MB across 5 files: BFO 98 KB, IAO 590 KB, CCO 1.27 MB, BMM 21 KB, axioms 20 KB) merged and reasoned over successfully. HermiT confirmed consistency with no unsatisfiable classes. Processing time was notable (several minutes) due to the size of the CCO merged ontology, but well within acceptable limits for an offline validation tool.

### Violation test

Injecting `ValueProposition rdfs:subClassOf ActivityModelElement` correctly caused HermiT to identify ValueProposition as unsatisfiable. The reasoning chain: ValueProposition is a member of ServiceConceptElement (via the union class equivalence), and ServiceConceptElement is disjoint with ActivityModelElement (via AllDisjointClasses). Making ValueProposition a subclass of ActivityModelElement creates a class that must be a member of two disjoint groups simultaneously — a logical contradiction.

This confirms that the disjointness axioms (Step 1), the union class structure, and the reasoner integration are all working correctly together.

### Risk register update

R2 (performance risk — "BFO + CCO + IAO combined ontology may be too large for HermiT to reason over efficiently") is now confirmed as a non-issue. The full stack reasons successfully. ELK fallback is available if needed in future but not currently required.

---

## Design Decisions

**S111-D5 confirmed:** Robot (wrapping HermiT) as the reasoner tool. Resolved. Rationale: single JAR, command-line interface, widely used in the BFO/CCO community (which is our ontology stack), wraps HermiT which handles full OWL 2 DL.

---

## Register Concepts Exercised

- **[[principle-model-generates-everything|A3]]** (model generates everything) — the pipeline-generated `ontara-bmm.ttl` is one of the five files in the reasoning stack
- **[[principle-deterministic-over-probabilistic|A6]]** (deterministic/auditable reasoning) — HermiT provides deterministic, formally grounded consistency checking
- **[[principle-discipline-as-load-bearing-structure|A9]]** (discipline as load-bearing structure) — automated reasoning integrated into the validation workflow
- **[[concept-co-evolution|J2]]** (co-evolution) — reasoning tooling built alongside the axiom content it validates
- **B23** ([[concept-ontology-stack|OWL 2 DL]] as ontological formalism) — full OWL 2 DL reasoner now operational against the Ontara ontology
- **B28** ([[concept-knowledge-graph|three-stratum KG architecture]]) — the domain graph content is what the reasoner validates
- **B29** (authority zones) — axioms are OWL-authoritative; the reasoner validates the OWL-authoritative content

No new register concepts introduced.

---

## Emergent Ideas

No new emergent ideas captured this session. The work was focused implementation of a planned step.

---

## Open Questions

None from this session.

---

## Tier 1 Principles

| Principle | How honoured |
|---|---|
| [[principle-model-generates-everything\|A3]] (model generates everything) | Pipeline-generated ontology validated by the reasoner |
| [[principle-deterministic-over-probabilistic\|A6]] (deterministic/auditable reasoning) | HermiT is a deterministic, formally grounded reasoner |
| [[principle-discipline-as-load-bearing-structure\|A9]] (discipline) | Automated validation tool integrated into the project workflow |
| [[concept-co-evolution\|J2]] (co-evolution) | Reasoning tooling built to exercise the axiom content |
| [[concept-non-constraining\|J3]] (non-constraining) | Robot supports multiple reasoners (HermiT, ELK, JFact, Whelk); the script can be adapted |

---

*Session 115 report written 3 April 2026.*
