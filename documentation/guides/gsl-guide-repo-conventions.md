# Repository Conventions and Tooling

**Date:** 8 March 2026
**Context:** Conventions for the `gsl-sysml-model` repository and related projects.

**Companion documents:**
- `documentation/reference/gsl-sysml-v2-syntax-reference-v3.5-*.md` — SysML syntax lookup
- `documentation/architecture/gsl-validated-architectural-patterns.md` — integration patterns and design rationale
- `documentation/guides/gsl-guide-editing-package-hierarchy.md` — `gsl` toolkit and package editing workflow

---

## 1. Repository Structure

```
gsl-sysml-model/
├── model/                          SysML v2 model files
│   ├── gendersense.sysml          Root package (imports all domains)
│   ├── enterprise.sysml           Organisation, Regulation, Strategy, Risk
│   ├── foundation.sysml           MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline
│   ├── knowledge.sysml            CDS, ConstraintLibrary, LogicEngine, DecisionModels,
│   │                              OutcomeFramework, LearningCycles, Analytics
│   ├── operations.sysml           Finance, People, Marketing, CRM, Reporting
│   ├── platform.sysml             PatientPortal (+5), Education (+4), Community (+3), Booking,
│   │                              EHR, Forms, Messaging, Video, Labs, PrescribingSystem,
│   │                              Payments, Documents, Identity, Orchestration, Integration
│   ├── service-delivery.sysml     PatientJourney, ClinicalPathways (+4), Consent, Coaching,
│   │                              Governance, ClinicalEntities
│   ├── pattern-catalogue.sysml    PatternCatalogue: cross-domain concept registry
│   └── syntax-tests/              Isolated syntax verification files
├── libraries/
│   └── temporal-metadata/
│       └── temporal-metadata.sysml    Package: TemporalMetadata (shared across projects)
├── exercises/
│   └── coffeeshop-demonstrator/       Coffee shop CDR exercise and demonstrator
├── scripts/
│   ├── gsl                            Shell toolkit (see editing guide)
│   ├── gen_package_hierarchy.py       Multi-format hierarchy generator
│   └── evaluate_automator.py          Syside Automator evaluation script
├── documentation/
│   ├── architecture/                  Foundational thinking, decisions, patterns
│   ├── generated/                     Hierarchy generator output (md, OPML, HTML, OmniOutliner)
│   ├── guides/                        Practical how-to documents
│   ├── plans/                         Work plans for modelling phases
│   ├── reference/                     Syntax references (current + versions/)
│   └── session-reports/               Session continuity records
└── archive/
```

### Multi-file model pattern

Each `.sysml` file declares a standalone top-level package. `gendersense.sysml` assembles them:

```sysml
package GenderSense {
    private import Enterprise::*;
    private import Foundation::*;
    private import Knowledge::*;
    private import Operations::*;
    private import Platform::*;
    private import ServiceDelivery::*;
}
```

Syside resolves cross-file imports automatically within the VS Code workspace.

---

## 2. Coffee Shop Demonstrator Structure

```
coffeeshop-demonstrator/
├── model/domain/
│   └── fulfil-drink-orchestration.sysml
├── generators/
│   ├── gen_temporal_workflow.py
│   ├── gen_mermaid_pathway.py
│   ├── gen_typescript_types.py
│   └── gen_state_machines.py
├── generated/
│   ├── fulfil-drink.ts
│   ├── fulfil-drink-pathway.mmd
│   ├── order-lifecycle-machine.ts
│   └── types.ts
├── packages/
│   ├── shared/        @coffeeshop/shared — types, constants, generated machines
│   ├── temporal/      @coffeeshop/temporal — workflows, activities, workers
│   └── web/           @coffeeshop/web — SvelteKit UI + API routes
├── pnpm-workspace.yaml
└── package.json
```

TypeScript/SvelteKit monorepo with pnpm workspaces. `pnpm generate` runs all generators; `pnpm sync-generated` copies output to workspace packages.

---

## 3. Shared Metadata Library

```
sysml-metadata-lib/
└── temporal/
    └── temporal-metadata.sysml    Package: TemporalMetadata
```

Consuming projects import with `private import TemporalMetadata::*;`. Must be within the VS Code workspace folder tree.

---

## 4. Generation Commands

### Hierarchy generator

```bash
gsl              # terminal tree view
gsl save         # export all formats (markdown, OPML, HTML, OmniOutliner)
gsl oo           # export and open in OmniOutliner
gsl html         # export and open HTML mindmap
gsl diff         # compare model vs proposal
gsl edit         # open the editing guide
gsl model        # open repo in VS Code
gsl files        # list model and generated files
```

### Demonstrator generators

```bash
cd ~/Developer/gsl-tech/coffeeshop-demonstrator
pnpm generate           # all generators + sync
pnpm generate:types
pnpm generate:statemachine
pnpm generate:workflow
pnpm generate:pathway
pnpm sync-generated     # copy to workspace packages
```

---

## 5. Git Practices

- `.sysml` files are plain text — clean diffs, merge, blame all work
- **Atomic commits:** model change + regenerated artefacts + documentation together
- **Commit message pattern:** describe the modelling change, list syntax findings if any
- **Generated hierarchy files:** committed alongside model changes (regenerated via `gsl save`)
- **Tagging:** semver tags at known-good points (model + generators + implementation aligned)

### Workflow: edit → verify → regenerate → commit

1. Edit `.sysml` file(s)
2. Verify clean parse in Syside Modeler
3. Run `gsl save` to regenerate hierarchy outputs
4. Stage all changes (`git add -A`)
5. Commit with descriptive message

---

## 6. Syside Modeler Conventions

- **Version:** 0.8.5 (VS Code extension, 1 March 2026)
- **Workspace:** open `gsl-sysml-model/` as the VS Code workspace root. Libraries and exercises in sibling directories are included via workspace folders.
- **Standard import:** every `package` begins with `private import ScalarValues::*;`
- **Transient errors:** Syside LSP may show errors during file creation/rename — these clear when the file is opened or the workspace re-indexes
- **Syntax testing:** use `model/syntax-tests/` for isolated experiments before adding to production model files

---

## 7. Documentation Conventions

| Subdirectory | Content | Naming pattern |
|---|---|---|
| `architecture/` | Principles, strategies, decisions, patterns | `gsl-architecture-*` or `gsl-platform-*` |
| `generated/` | Hierarchy generator output | Generated by `gsl save` — do not edit |
| `guides/` | Practical how-to documents | `gsl-guide-*` |
| `plans/` | Work plans for phases and exercises | `gsl-plan-*-YYYY-MM-DD.md` |
| `reference/` | Syntax reference (current version) | `gsl-sysml-v2-syntax-reference-vN.N-YYYY-MM-DD.md` |
| `reference/versions/` | Previous syntax reference versions | Same naming, preserved for history |
| `session-reports/` | Session continuity records | `gsl-session-report-YYYY-MM-DD-sN.md` |

### Session reports

Written at the end of each modelling session. Purpose: provide full context for the next chat session. Include: objectives and outcomes, files created/modified, syntax findings, design decisions, repository state, recommended next steps.

---

## 8. MCP Filesystem Access

Claude reads and writes model files directly via MCP filesystem tools. Ella runs shell commands (git, gsl toolkit) and checks Syside for parse verification. This division of labour allows Claude to draft SysML code and documentation while Ella maintains the verification loop.

Allowed directories: `~/Desktop`, `~/Developer`, `~/Downloads`, `~/Obsidian/GenderSense`.

---

---

## 9. Import Collision Convention

**Convention (Session 30):** When a `.sysml` file imports both a domain package (e.g. `CoffeeShop::*`) and a meta model package (e.g. `BusinessModel::ServiceConcept::*`) via wildcards, and both export types with the same name, always use the fully qualified domain type for usages (e.g. `CoffeeShop::CatalogueEntry`, not bare `CatalogueEntry`).

Syside resolves ambiguous names silently — no warning at the import site. The error surfaces downstream as a type-mismatch on `:>>` redefinition, distant from the root cause.

**Known collision-prone names:** `CatalogueEntry`, `ExternalReference`, `InventoryRecord`. This list will grow as meta model concepts are added.

**When adding a new meta model `part def`:** check the name against all domain packages. If it shares a name with a domain type, add it to this list and add a comment to any domain business model file that imports both namespaces.

See `gsl-analysis-wildcard-import-collision-2026-03-15.md` for full analysis.

---

## 10. PatternCatalogue — Obsidian Cross-Reference Convention

**SysML layer:** `PatternCatalogue` package in `model/pattern-catalogue.sysml`. Contains `Pattern` and `DomainInstantiation` part defs with classification enums.

**Obsidian layer:** `02 ARCHITECTURE & MODELLING/Concept Graph/` in the GenderSense vault.

### Naming convention

| SysML element | Obsidian note | Rule |
|---|---|---|
| `part fourLayerItemModel : Pattern` | `patterns/pattern-four-layer-item-model.md` | camelCase → kebab-case, `pattern-` prefix |
| `part cswFourLayerItemModel : DomainInstantiation` | (included in the pattern note’s "Domain Instantiations" section) | Domain instantiations don’t get separate notes |
| `part def CatalogueEntry` (in BusinessModel) | `concepts/concept-catalogue-entry.md` | PascalCase → kebab-case, `concept-` prefix |
| Deferred item (no SysML element yet) | `deferred/deferred-composite-orders.md` | kebab-case, `deferred-` prefix |

### Frontmatter

Every Obsidian concept graph note has a `sysml_element` field in frontmatter linking to the fully qualified SysML path. Empty string if no SysML element exists yet.

### Tags

- Entity type: `#pattern`, `#concept`, `#deferred`
- Meta model: `#meta-model/business`, `#meta-model/system`, `#meta-model/cross-cutting`
- Domain: `#domain/csw`, `#domain/gsl`, `#domain/addictions`
- Maturity: `#maturity/discussion`, `#maturity/designed`, `#maturity/implemented`, `#maturity/validated`

### Source of truth

SysML is the source of truth for what patterns exist, their maturity, and their classification. Obsidian is the navigation and discursive layer. If a pattern exists in Obsidian but not in SysML, it’s a discussion topic. If it exists in SysML, it’s formalised.

---

## 11. Periodic Code and Model Reviews

The project conducts proactive reviews at workstream boundaries and after findings that reveal silent failure classes. See `gsl-plan-next-steps-and-deferred-items.md` §2 for full convention, scope, and triggers.

---

*Extracted from monolithic syntax reference 8 March 2026 (Session 8). Updated 15 March 2026 (Session 30: import collision convention, PatternCatalogue–Obsidian cross-reference, periodic reviews). See also the `gsl` toolkit guide in `documentation/guides/`.*
