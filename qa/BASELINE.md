# QA baseline: after OP-132

**Date:** 2026-10-30 (Session 517, Plan B Stage 0, S0.1 pass 2)
**Measured at commit:** `7fb149324d1eab8421ddad3a80cd897ffdbdc504` (`main`)
**Machine-readable form:** `qa/baseline.json`
**Re-run:** `make qa` from the repository root, with GraphDB Desktop running and `ontara-dev` answering on `http://localhost:7200`.

This is the baseline that S0.3 and S0.4's Cafe content is checked against. The older figures (66 queries, 13 files, 288 units) were recorded before OP-132 and are not targets. The counts below are as found.

## Result

| Layer | Target | Result | Headline |
|---|---|---|---|
| OWL pipeline | `make qa-pipeline` | pass | 775 elements, 34 DomainClass, 14 object properties, 98 weights |
| SPARQL validation | `make qa-validate` | pass | 66 of 66 queries pass. Measured 64 of 66 at `7fb1493` (finding F1); F1 resolved in Session 517 and re-run 66 of 66 |
| HermiT consistency | `make qa-reason` | pass | consistent on the full 14-file stack and on the 12-file General-only stack |
| Round-trip diff | `make qa-diff` | pass | 292 units, 0 added, 0 removed, 0 modified |

As first measured, `make qa` exited non-zero solely because of F1. With F1 resolved (see Findings), every layer passes. All four layers ran in 11 minutes 32 seconds.

## Commands

| Target | Runs |
|---|---|
| `qa-pipeline` | `python3 scripts/gen_owl_pipeline.py --save` (regenerates `generated/ontology/`) |
| `qa-validate` | `python3 scripts/validate_kg.py --load` (reloads pipeline output into `ontara-dev`, then validates) |
| `qa-reason` | `python3 scripts/reason_kg.py --save-summary` (HermiT via Robot; no GraphDB) |
| `qa-diff` | `python3 scripts/diff_kg.py --json-only` (report in `generated/ontara/diff-report.json`) |
| `qa` | the four above in order, carrying on past a failing layer |

Tools: python3 with rdflib 7.6.0, OpenJDK 25.0.2, Robot 1.9.8, GraphDB Desktop.

## 1. OWL pipeline

Parsed 775 SysML elements from 5 domains: 34 DomainClass and 741 StructuralOnly. Generated 34 OWL classes (175 triples), 14 object properties (99 triples), 98 reified weight individuals (716 triples) and a correspondence graph of 1,398 triples. Two properties are deferred because their targets are not in the DomainClass set: `ObjectiveCapabilityMapping.strategicObjective → StrategicObjective` and `FinancialProjection.scenario → ScenarioDefinition`.

The regenerated files differ from the committed ones only in timestamps: 146 `dcterms:created` values in `ontara-correspondence.ttl` and `generated_at` in `mapping-ir.json`. The derived OWL was already current with the model.

## 2. SPARQL validation

`validate_kg.py --load` loaded 12 files: the four pipeline outputs, the BMM axioms, the PROV-O core subset, the record module, the governance vocabulary, the CQC Regulation 12 individuals, the domain identity and reasoning vocabularies, and the Ears reasoning instances. After loading, the domain graph held 30,099 triples and the correspondence graph 1,398.

66 queries ran and 64 passed:

| Category | Passed |
|---|---|
| Structural | 4/4 |
| Correspondence | 3/3 |
| Inference | 2/2 |
| Graph-level | 1/1 |
| Governance | 6/6 |
| Governance-MVP | 7/7 |
| Properties | 2/2 |
| Axioms | 2/2 |
| **Weights** | **0/2** |
| Domain-Identity | 6/6 |
| Reasoning | 21/21 |
| Ears Instances | 10/10 |

**Q7** (specific lookup: CustomerSegment), which OP-132 could not run, passes: 1 result, `CustomerSegment` at `model/business-metamodel-general.sysml` line 112.

The per-query counts and expectations are in `qa/baseline.json` under `layers.validate.queries`.

## 3. HermiT consistency

`reason_kg.py` assembles tenant and instance content as well as the General stack, so HermiT ran twice. Both runs are **consistent with no unsatisfiable classes**.

**Full stack, as `reason_kg.py` is configured (14 files):**

1. `ontology/imports/bfo-core.owl`
2. `ontology/imports/iao.owl`
3. `ontology/imports/CommonCoreOntologiesMerged.ttl`
4. `ontology/imports/prov-core.ttl`
5. `ontology/record/ontara-record.ttl`
6. `generated/ontology/ontara-bmm.ttl`
7. `ontology/axioms/ontara-bmm-axioms.ttl`
8. `generated/ontology/ontara-bmm-properties.ttl`
9. `generated/ontology/ontara-bmm-weights.ttl`
10. `ontology/governance/ontara-governance.ttl`
11. `ontology/governance/cqc-reg12-individuals.ttl` (instance content)
12. `ontology/domain/ontara-domain.ttl`
13. `ontology/reasoning/ontara-reasoning.ttl`
14. `ontology/reasoning/ears-reasoning-instances.ttl` (Ears tenant instances)

**General-only stack (H-0320, 12 files):** the 14 above without items 11 and 14. That leaves the imported upper and mid-level ontologies (1 to 4), the generated metamodel OWL (6, 8, 9) and the hand-authored PML and vocabulary modules (5, 7, 10, 12, 13). `reason_kg.py` has no option to select files, so this run used its own Robot chain directly (7 minutes 31 seconds):

```
java -jar tools/robot.jar merge --catalog ontology/catalog-v001.xml \
  --input <each of the 12 files> --collapse-import-closure true \
  reason --reasoner HermiT --annotate-inferred-axioms true --exclude-tautologies structural
```

## 4. Round-trip diff

292 semantic units compared, generated OWL against the live store: 34 ClassDeclaration, 14 PropertyDeclaration, 98 WeightIndividual and 146 MappingRecord. None were added, removed or modified.

## Findings

**F1: Q28 and Q29 expect 96 weighted relationships, and the model has 98.** Q28 (reified weighted relationship individuals) and Q29 (weighted relationship correspondence records) each return 98 rows against `expect_exactly: 96`, a figure set at S117. The two extra individuals are `weight-AuditEvidenceRecord-to-ActivityType` and `weight-AuditEvidenceRecord-to-GovernanceRequirement`, from the `AuditEvidenceRecord` part def's weighted relationships. They first appear in generated output at `cfa404a` (OP-132 S515 step 1 regeneration). The pipeline, the store and the round-trip diff all agree on 98, so this is a stale expectation in the suite rather than a defect in the generated OWL. `CLAUDE.md` also still says 96 weighted relationships. Under specification §2.8 item 5 it is fixed before S0.3's Cafe content is checked against this baseline. This pass does not fix it.

**F1 resolved (Session 517, at Ella's direction).** The two `AuditEvidenceRecord` weighted relationships were added to the SysML at S277 (`c98ebe2`); the generated OWL was not regenerated until `cfa404a`, so the S117 expectation had been stale since S277. Q28 and Q29 now expect 98 in `scripts/validate_kg.py`, and `CLAUDE.md` says 98. `make qa-validate` re-run: 66 of 66.

## Observations (not failures)

- Q8 returns 35 BMM continuants against an ideal of 34 (threshold 30). The 35th is `ontara-bmm:WeightedRelationship`, the reification class, which sits in the `bmm/` namespace.
- Q11 (156 against an ideal of 19) and Q26 (45 against an ideal of 9) pass on threshold. Both count rows, one per inferred parent or per pair, rather than distinct classes.
- `ontology/joins/ontara-joins-axioms.ttl` and `ontara-joins-shapes.ttl` (W-161, dormant) are loaded by neither `reason_kg.py` nor `validate_kg.py`.
- `reasoning-summary.json` reports `sparqlQueryCount: 78`; the suite ran 66 queries. The count in `reason_kg.py` matches every `"name":` string in `validate_kg.py`, including file-load entries.

## Comparing a re-run

Run `make qa` and compare these with `qa/baseline.json`:

- the validation summary's `OVERALL` line (66/66, with no failing query ids);
- the `REASONING SUMMARY` block (14 files, consistency PASS);
- `generated/ontara/diff-report.json` `summary` (292 unchanged, 0 otherwise).

`generated/ontara/reasoning-summary.json` is stamped with `modelDigest`, a SHA-256 over the model files, not with a run time (S518). A re-run on an unchanged model therefore leaves the tree clean.
