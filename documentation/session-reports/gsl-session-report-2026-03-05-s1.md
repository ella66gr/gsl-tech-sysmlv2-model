# GenderSense SysML v2 Modelling — Session Report

## 5 March 2026

**Purpose:** Comprehensive progress report for continuity into the next chat session, where we will begin modelling the first clinical pathway (Hormone Therapy Initiation).

---

## 1. Session Objectives and Outcomes

This session established the complete GenderSense SysML v2 package hierarchy, verified critical syntax patterns in Syside Modeler 0.8.5, split the model into a multi-file structure, and evaluated Syside Automator as a replacement for the regex-based generators.

All objectives were met. The model is committed to GitHub and ready for clinical pathway elaboration.

---

## 2. Repository and File Structure

### Repository

- **GitHub:** `ella66gr/gsl-tech-sysmlv2-model`
- **Local path:** `~/Developer/gsl-tech/gsl-sysml-model/`
- **VS Code workspace root:** `~/Developer/gsl-tech/` (contains `gsl-sysml-model`, `coffeeshop-demonstrator`, `coffeeshop-exercise`, `sysml-metadata-lib`)

### Current File Structure

```
gsl-sysml-model/
├── model/
│   ├── gendersense.sysml         — Root package: package GenderSense { imports all }
│   ├── enterprise.sysml          — package Enterprise { Organisation, Regulation, Strategy, Risk }
│   ├── knowledge.sysml           — package Knowledge { CDS, ConstraintLibrary, Logic, Decisions, Outcomes, Learning, Analytics }
│   ├── service-delivery.sysml    — package ServiceDelivery { PatientJourney, ClinicalPathways, Consent, Coaching, Governance, Entities }
│   ├── platform.sysml            — package Platform { Portal, Booking, EHR, Forms, Messaging, Video, Labs, Prescribing, Payments, Docs, Identity, Orchestration, Integration }
│   ├── operations.sysml          — package Operations { Finance, People, Marketing, CRM, Reporting }
│   └── foundation.sysml          — package Foundation { MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline }
├── scripts/
│   └── evaluate_automator.py     — Syside Automator evaluation (10 tests, all passed)
├── documentation/
│   ├── sysml-v2-syntax-reference-v3.1-2026-03-05.md  — Living syntax reference
│   └── gendersense-package-hierarchy.sysml.archive    — Original single-file version
├── .gitignore
└── README.md
```

### Multi-File Architecture (Key Finding)

Syside Modeler does **NOT** merge same-named packages across files. The working pattern is:

- Each `.sysml` file declares its own standalone top-level package (e.g. `package Enterprise { }`)
- The root file `gendersense.sysml` declares `package GenderSense` and uses `private import Enterprise::*;` etc. to assemble the full model
- Cross-file imports resolve correctly: e.g. `private import Enterprise::Regulation::*;` in `knowledge.sysml` resolves requirement defs declared in `enterprise.sysml`
- Attempting `package GenderSense { package Enterprise { ... } }` in multiple files triggers `global-namespace-distinguishability` errors

---

## 3. Verified Syntax Patterns (New in This Session)

All patterns verified in Syside Modeler 0.8.5 (released 1 March 2026).

### 3.1 use case def

- First-class SysML v2 language element, parses correctly in Syside 0.8.5
- 64 use case definitions across the package hierarchy, all with `doc /* */` blocks
- Tom Sawyer SysML v2 Viewer v1.3 renders use case diagrams from the model (verified for PatientJourney package)
- `include use case`, `extend use case`, `subject`, `actor` — not yet tested

### 3.2 requirement def with subject

- `requirement def BloodMonitoringRequired { subject patient : Patient; attribute monitoringIntervalWeeks : Integer; }` — parses correctly
- Cross-package type references in `subject` declarations work (e.g. `Patient` imported from `ServiceDelivery::ClinicalEntities`)

### 3.3 satisfy relationships

**Working syntax:**
```sysml
package ConstraintLibrary {
    private import Enterprise::Regulation::*;   // import requirements into scope

    constraint def BloodMonitoringIntervalConstraint {
        in weeksSinceLastTest : Integer;
        in requiredIntervalWeeks : Integer;
        weeksSinceLastTest <= requiredIntervalWeeks
    }

    // Usage (feature) typed by the constraint def
    constraint bloodMonitoringCheck : BloodMonitoringIntervalConstraint;

    // Traceability: this constraint satisfies that requirement
    satisfy requirement BloodMonitoringRequired
        by bloodMonitoringCheck;
}
```

**Critical syntax traps discovered through iterative testing:**

| Trap | Error | Fix |
|---|---|---|
| `satisfy requirement R by MyConstraintDef;` (def, not usage) | `feature-reference-expression-referent-is-feature` | Create a constraint usage: `constraint c : MyConstraintDef;` then `by c;` |
| `satisfy requirement GenderSense::Enterprise::Regulation::R by c;` (fully qualified from root) | `namespace-distinguishability` | Use `private import Enterprise::Regulation::*;` then reference by simple name |
| `satisfy requirement Enterprise::Regulation::R by c;` (path from sibling package) | `reference-error` | Must import, not navigate — sibling packages aren't directly reachable |

### 3.4 Multi-file model split

See Section 2 above. Verified that cross-file imports resolve correctly. Syside LSP shows transient errors during file operations but they clear automatically.

---

## 4. Syside Modeler 0.8.5 Update

Updated from 0.8.4 to 0.8.5 (released 1 March 2026). Key changes relevant to GenderSense:

- **Tom Sawyer SysML v2 Viewer v1.3:** Use case diagrams, sequence diagrams, colour rendering, edge crossing visualisation
- **SysML v2 `view` element support:** Scoped diagram generation from view elements, including across multiple files
- **Modeler CLI:** Headless diagram generation via `viz` command, enabling CI/CD integration
- **Python runtime bundled:** No external Python dependency for Modeler
- **Syside Automator 0.8.5:** `Compiler.evaluate_filter` for metadata-based queries, `Compiler.evaluate_feature` for user-defined calculations
- **VS Code "Preview" badge:** This is a Marketplace pre-release designation, not a functional limitation. Syside v1.0.0 targeted for Q1 2026
- **Sensmetry claim full SysML v2.0 support** (October 2025 announcement). OMG conformance test suite not yet completed industry-wide

---

## 5. Syside Automator Evaluation

### Result: All 10 tests passed — confirmed as regex generator replacement

The evaluation script (`scripts/evaluate_automator.py`) loaded the full 7-file GenderSense model and successfully queried every element type that generators need.

### Element Counts from Evaluation

| Element Type | Count | Generator Relevance |
|---|---|---|
| Packages | 50 | All generators (namespace traversal) |
| Part definitions | 16 | `gen_typescript_types.py` |
| Enum definitions | 5 | `gen_typescript_types.py` |
| Use case definitions | 64 | New for GenderSense |
| Requirement definitions | 2 | Governance traceability |
| Constraint definitions | 2 | Governance traceability |
| Satisfy relationships | 2 | Governance traceability |
| State definitions | 1 | `gen_state_machines.py` |
| Metadata definitions | 6 | `gen_temporal_workflow.py` |

### Key API Findings

- `syside.load_model([list_of_files])` loads multi-file models with cross-file import resolution
- `model.elements(syside.PartDefinition)` etc. enumerates all elements of a type
- `owned_members.collect()` returns typed children: `AttributeUsage`, `ReferenceUsage`, `StateUsage`, `TransitionUsage` etc.
- Documentation accessible via `documentation` property and `body` attribute
- Satisfy relationships represented as `SatisfyRequirementUsage` with traversable references
- Constraint expressions visible as `OperatorExpression` and `FeatureReferenceExpression`

### Comparison with Regex Generators

| Capability | Regex Generators | Syside Automator |
|---|---|---|
| Parse single file | Yes | Yes |
| Parse multi-file model | No | Yes |
| Distinguish `attribute` from `ref` | Regex pattern matching | Typed API: `AttributeUsage` vs `ReferenceUsage` |
| Read metadata annotations | Regex inside action bodies | `model.elements(syside.MetadataDefinition)` |
| Traverse satisfy relationships | Not possible | `model.elements(syside.SatisfyRequirementUsage)` |
| Read constraint expressions | Not possible | `OperatorExpression` with structured operands |
| Cross-package type resolution | Not possible | Automatic via semantic model |
| Fragility | Breaks if formatting changes | Semantic — formatting-independent |

### Conclusion

Syside Automator provides complete semantic access to everything the regex generators scrape textually, plus capabilities they cannot reach. The migration path is clear: rewrite each generator to use `syside.load_model()` and `model.elements()`, producing the same output files. This can be done incrementally, one generator at a time.

### Setup Notes

- **Installation:** `pip install syside` (in `~/Developer/gsl-tech/.venv/`)
- **License:** `SYSIDE_LICENSE_KEY` environment variable required. Key: stored in macOS Keychain via `keyring` (or set via `export SYSIDE_LICENSE_KEY="..."` per session)
- **Syside version:** 0.8.5, Python 3.12, macOS arm64

---

## 6. Syntax Reference Status

The syntax reference has been updated to **v3.1** and relocated to `gsl-sysml-model/documentation/sysml-v2-syntax-reference-v3.1-2026-03-05.md` (moved from `coffeeshop-demonstrator/documentation/`).

### Changes in v3.1

- Environment section updated from Syside 0.8.4 to 0.8.5 with full capabilities
- Added KerML 1.0 and formal spec publication dates
- New section: **GenderSense Package Hierarchy: Use Case Definitions** (verified)
- New section: **Multi-file split** with working pattern and syntax traps
- New section: **Satisfy Traceability: Requirements to Constraints** (verified with syntax traps)
- TODO list updated: `use case def` (basic), `satisfy`, and Automator marked as done
- `verify` relationships, advanced use case syntax, `view`/`viewpoint`, CLI `viz`, and `decide`/`merge`/`fork`/`join` remain on TODO

---

## 7. Git History

Three commits made during this session:

### Commit 1: Initial skeleton
```
Establish package hierarchy and verify satisfy traceability

- Complete GenderSense SysML v2 package hierarchy (6 top-level
  packages, ~40 sub-packages) with doc comments, use case defs,
  part defs, enum defs, state patterns, and clinical metadata defs
- Verify requirement def with subject, constraint def with evaluable
  body, and satisfy relationship syntax in Syside Modeler 0.8.5
- Key syntax findings: satisfy 'by' target must be a usage not a
  definition; cross-package references need explicit import, not
  path navigation from sibling packages
- Project structure: model/ for .sysml files, documentation/ for
  companion docs
- All verified clean in Syside Modeler 0.8.5 (zero parse errors)
```

### Commit 2: Multi-file split
```
Split hierarchy into per-domain files, verify multi-file resolution

- Split monolithic package hierarchy into 7 files: root gendersense.sysml
  plus enterprise, knowledge, service-delivery, platform, operations,
  foundation — each declaring a standalone top-level package
- Syside does NOT merge same-named packages across files; working
  pattern is standalone packages assembled by root import
- Cross-file imports verified: Enterprise::Regulation::* resolves
  from knowledge.sysml, ServiceDelivery::ClinicalEntities::* from
  enterprise.sysml
- Moved syntax reference (v3.1) into this repo under documentation/
  to consolidate working documentation in the active project
- Archive original single-file version in documentation/
```

### Commit 3: Automator evaluation
```
Evaluate Syside Automator as regex generator replacement

- Add scripts/evaluate_automator.py: 10-test evaluation covering
  multi-file model loading, all element types (part def, enum def,
  use case def, requirement def, constraint def, state def, metadata
  def), satisfy relationship traversal, and attribute/reference access
- All tests pass: Automator 0.8.5 provides full semantic API access
  to everything the regex generators parse textually, plus cross-file
  resolution and typed element relationships
- Conclusion: Automator confirmed as ready replacement for regex
  generators; migration can proceed incrementally per-generator
- Update syntax reference TODO with evaluation results
- Add .gitignore (exclude .env, .venv, __pycache__)
```

---

## 8. Companion Documents (Uploaded to This Session)

These documents were provided as context and should be available to the next session:

1. **`gendersense-architecture-principles.md`** — Separation principle (representation vs execution layers), openEHR CDR integration, governance audit patterns, clinical decision support tiers, external service integration, guiding constraints
2. **`gendersense-sysml-modelling-strategy.md`** — Comprehensive modelling rationale, three-tier reasoning stack, concentric rings of modelling rigour, package structure with purpose descriptions, legacy artefact mapping (BPMN/UML → SysML v2), recommended next steps
3. **`gendersense-package-hierarchy-proposal.md`** — Tree diagram of the package hierarchy that the `.sysml` files implement
4. **`sysml-v2-syntax-reference-v3_0-2026-03-03.md`** — Syntax reference as uploaded (now updated to v3.1 in the repo)
5. **Perplexity research output** — SysML v2 spec links, Syside conformance status, OMG ratification details

---

## 9. Next Steps for the New Session

### 9.1 Primary: Model Hormone Therapy Initiation Pathway

This is the first clinical pathway to model end to end, as recommended in the modelling strategy (section 9.1.3). It exercises:

- **Long-running waits:** Lab results (days to weeks), specialist referrals
- **Multiple participants:** Patient, GP, endocrinologist, phlebotomy
- **Governance requirements:** Consent, clinical review intervals, monitoring schedules
- **Two-layer action flow pattern:** Domain layer (for governance) and orchestration layer (for runtime generation)
- **Entity lifecycles:** Patient, Episode, Prescription, LabResult state machines
- **Decision logic:** Eligibility criteria, prescribing protocols, safety constraints
- **Cross-package references:** To ClinicalEntities, ConstraintLibrary, MetadataLibrary

The pathway goes in `service-delivery.sysml` under `ServiceDelivery::ClinicalPathways::HormoneTherapy`.

### 9.2 Supporting Tasks

- **Verify `verify` relationship syntax** — The counterpart to `satisfy`; links verification cases to requirements
- **Elaborate ClinicalEntities lifecycle state machines** — Patient, Episode, Prescription, LabResult each need state defs specialising the StandardLifecycle pattern
- **Use SysML v2 `view` elements** — For scoped diagrams of the pathway, entity lifecycles, and governance traceability
- **Begin thinking about openEHR archetype mapping** — How clinical data from the pathway maps to CDR compositions

### 9.3 Deferred

- Generator migration to Syside Automator (confirmed ready, but not blocking pathway modelling)
- Coffee shop CDR extension exercise (openEHR validation)
- `decide`/`merge`, `fork`/`join` syntax verification
- Syside CLI diagram export

---

## 10. Working Practices Reminder

- **Syntax reference first:** Always check `documentation/sysml-v2-syntax-reference-v3.1-2026-03-05.md` before writing new `.sysml` code
- **Verify in Syside:** All new patterns should be tested in Syside Modeler and results captured in the syntax reference
- **Phase exit criteria:** Document what was verified, what traps were found, and update the TODO list
- **Git tags at checkpoints:** Tag when model + verification are known-good
- **MCP filesystem access:** Claude has access to `~/Developer/gsl-tech/` and can read/write files directly. Ella runs shell commands and pastes output back
- **Syside Modeler version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Development environment:** macOS (MacBook Pro), Python 3.12, VS Code

---

*Report generated at end of session, 5 March 2026. For use as context in subsequent chat session.*
