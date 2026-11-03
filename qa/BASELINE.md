# QA baseline: after S0.5 Pass A

**Date:** 2026-11-03 (Session 525, Plan B Stage 0, S0.5 Pass B step 0: Pass A's close-out)
**Measured on:** `main` at `28f0d6b` (Pass A's A7) with the close-out's changes, which are committed with this file
**Machine-readable form:** `qa/baseline.json`
**Re-run:** `make qa` from the repository root, with GraphDB Desktop running and `ontara-dev` answering on `http://localhost:7200`.

This replaces the S517 baseline (66 queries, Q26 = 45), which Pass A outgrew. Pass A's A7 made the QA knowledge graph the same on every run, so these counts were taken from two consecutive `make qa` runs: every count was identical across the two, and neither run changed a tracked file beyond the one expected change below. Pass B's checks compare against these figures.

## Result

| Layer | Target | Result | Headline |
|---|---|---|---|
| OWL pipeline | `make qa-pipeline` | pass | 807 elements from 5 domains: 39 DomainClass, 766 StructuralOnly, 2 TenantRuntimeType; 14 object properties, 108 weights |
| SPARQL validation | `make qa-validate` | pass | 68 of 68 queries |
| HermiT consistency | `make qa-reason` | pass | consistent on the 16-file stack `reason_kg.py` assembles, no unsatisfiable classes |
| Round-trip diff | `make qa-diff` | pass | 324 units, 0 added, 0 removed, 0 modified |

## The knowledge graph, counted

Counted by SPARQL against `ontara-dev` after each run, explicit statements only (GraphDB's inferred statements sit in its default graph and are not counted):

| Measure | Run 1 | Run 2 |
|---|---|---|
| Domain graph (`https://ontara.dev/graph/domain`) | 24,041 | 24,041 |
| Correspondence graph (`https://ontara.dev/graph/correspondence`) | 1,400 | 1,400 |
| Explicit total | 25,441 | 25,441 |
| Explicit triples outside any named graph | 0 | 0 |
| `owl:AllDisjointClasses` nodes in the domain graph | 17 | 17 |
| Q26: those whose members are all BMM classes | 2 | 2 |

## Commands

| Target | Runs |
|---|---|
| `qa-pipeline` | `.venv/bin/python scripts/gen_owl_pipeline.py --save` (regenerates `generated/ontology/`; the OpenSysML venv since S0.5 Pass A3) |
| `qa-validate` | `python3 scripts/validate_kg.py --load` (clears and reloads the domain and correspondence graphs whole, then validates) |
| `qa-reason` | `python3 scripts/reason_kg.py --save-summary` (HermiT via Robot; no GraphDB) |
| `qa-diff` | `python3 scripts/diff_kg.py --json-only` (report in `generated/ontara/diff-report.json`) |
| `qa` | the four above in order, carrying on past a failing layer |

Tools: python3 with rdflib 7.6.0, the OpenSysML 0.11.0 venv for the pipeline, OpenJDK 25.0.2, Robot 1.9.8, GraphDB Desktop.

## 1. OWL pipeline

Stage 1 read 807 elements from 5 domains through OpenSysML's resolved model. Stage 2 classified 39 DomainClass, 766 StructuralOnly and 2 TenantRuntimeType (`Order`, `OrderLine`). Stage 3 generated 39 OWL classes (200 triples), 14 object properties (99 triples), 108 reified weight individuals (786 triples), the tenant types graph (15 triples) and a correspondence graph of 1,400 triples. Two properties are deferred because their targets are not in the DomainClass set: `ObjectiveCapabilityMapping.strategicObjective → StrategicObjective` and `FinancialProjection.scenario → ScenarioDefinition`. A re-run changes no generated file.

## 2. SPARQL validation

`validate_kg.py --load` loaded 17 files: the three foundation imports (BFO, CCO, IAO), the five pipeline outputs (BMM, properties, weights, tenant types, correspondence), the BMM axioms, the PROV-O core subset, the record module, the governance vocabulary, the CQC Regulation 12 individuals, the domain identity and reasoning vocabularies, and the Ears and Cafe reasoning instances.

68 queries ran and 68 passed:

| Category | Passed |
|---|---|
| Structural | 4/4 |
| Correspondence | 5/5 |
| Inference | 2/2 |
| Graph-level | 1/1 |
| Governance | 6/6 |
| Governance-MVP | 7/7 |
| Properties | 2/2 |
| Axioms | 2/2 |
| Weights | 2/2 |
| Domain-Identity | 6/6 |
| Reasoning | 21/21 |
| Ears Instances | 10/10 |

The per-query counts and expectations are in `qa/baseline.json` under `layers.validate.queries`.

**Q26 (changed at S525).** It counted every `owl:AllDisjointClasses` node in the store against "at least 9": 17, from BFO (5), CCO (5, its merged file carrying its own copy of BFO's five), the BMM axioms (2), the record module (2) and governance (3). It now counts only the nodes whose `owl:members` are all BMM classes and expects exactly 2: the six concern groups, and the axis family (`AxisPrecondition`, `AxisTransition`, `CanonicalRuntimeType`, `StatusAxis`, `ValueSpace`), both in `ontology/axioms/ontara-bmm-axioms.ttl`.

## 3. HermiT consistency

`reason_kg.py` reasons over 16 files, **consistent with no unsatisfiable classes**:

1. `ontology/imports/bfo-core.owl`
2. `ontology/imports/iao.owl`
3. `ontology/imports/CommonCoreOntologiesMerged.ttl`
4. `ontology/imports/prov-core.ttl`
5. `ontology/record/ontara-record.ttl`
6. `generated/ontology/ontara-bmm.ttl`
7. `generated/ontology/ontara-tenant-types.ttl`
8. `ontology/axioms/ontara-bmm-axioms.ttl`
9. `generated/ontology/ontara-bmm-properties.ttl`
10. `generated/ontology/ontara-bmm-weights.ttl`
11. `ontology/governance/ontara-governance.ttl`
12. `ontology/governance/cqc-reg12-individuals.ttl` (instance content)
13. `ontology/domain/ontara-domain.ttl`
14. `ontology/reasoning/ontara-reasoning.ttl`
15. `ontology/reasoning/ears-reasoning-instances.ttl` (Ears tenant instances)
16. `ontology/reasoning/cafe-reasoning-instances.ttl` (Cafe tenant instances)

The General-only stack (H-0320) was not re-measured at S525. It was last measured at S517: 12 files, consistent, by a direct Robot chain, because `reason_kg.py` has no option to select files.

`generated/ontara/reasoning-summary.json` records `sparqlQueryCount: 68`. Until S525 `reason_kg.count_sparql_queries()` counted the text `"name":` in `validate_kg.py`, load entries included, and reported 82; it now counts the entries of `VALIDATION_QUERIES` from the file's syntax tree.

## 4. Round-trip diff

324 semantic units compared, generated OWL against the live store: 39 ClassDeclaration, 14 PropertyDeclaration, 108 WeightIndividual and 163 MappingRecord. None were added, removed or modified.

## Findings carried

**F1 (S517), resolved.** Q28 and Q29 expected 96 weighted relationships against 98 in the model; raised to 98 at S517, and to 108 with S0.4's axis family at S518.

## Observations (not failures)

- Q8 returns 39 BMM continuants against an ideal of 34 (threshold 30, passes; diagnostic).
- Q11 counts rows, one per inferred parent, rather than distinct classes; it passes on threshold.
- `ontology/joins/ontara-joins-axioms.ttl` and `ontara-joins-shapes.ttl` (W-161, dormant) are loaded by neither `reason_kg.py` nor `validate_kg.py`.

## Comparing a re-run

Run `make qa` and compare these with `qa/baseline.json`:

- the validation summary's `OVERALL` line (68/68, with no failing query ids);
- the `REASONING SUMMARY` block (16 files, consistency PASS);
- `generated/ontara/diff-report.json` `summary` (324 unchanged, 0 otherwise);
- the knowledge-graph counts above, by SPARQL against `ontara-dev` (`FROM <http://www.ontotext.com/explicit>` for the explicit total).

`generated/ontara/reasoning-summary.json` is stamped with `modelDigest`, a SHA-256 over the model files, not with a run time (S518). A re-run on an unchanged model leaves the tree clean.
