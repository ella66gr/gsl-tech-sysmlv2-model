# Editing the GenderSense Package Hierarchy

A practical guide for adding, renaming, moving, or removing packages in the SysML model.

---

## The `gsl` toolkit

The `gsl` command gives you quick access to the package hierarchy from anywhere in your terminal. Set it up once as below.

Permissions:

```bash
chmod +x ~/Developer/gsl-tech/gsl-sysml-model/scripts/gsl
```

Add to `~/.zshrc`:

```bash
alias gsl='~/Developer/gsl-tech/gsl-sysml-model/scripts/gsl'
```

But a permanent saving would be useful, so instead use:

```bash
echo "alias gsl='~/Developer/gsl-tech/gsl-sysml-model/scripts/gsl'" >> ~/.zshrc
source ~/.zshrc
```

Then use:

| Command | What it does |
|---|---|
| `gsl` | Show the package hierarchy tree in your terminal — the everyday quick view |
| `gsl save` | Export all formats (markdown, OPML, HTML, OmniOutliner) |
| `gsl oo` | Export and open directly in OmniOutliner (multi-column outline) |
| `gsl html` | Export and open an interactive zoomable mindmap in your browser |
| `gsl diff` | Compare the model against the proposal — shows what's missing or extra |
| `gsl edit` | Open this guide |
| `gsl model` | Open the model repo in VS Code |
| `gsl files` | List model files and generated outputs |
| `gsl help` | Show all available commands |

The typical daily workflow: make changes in Syside → verify clean parse → run `gsl` to check the tree → run `gsl save` to regenerate exports → commit.

---

## Quick reference for edits

| I want to... | What to do |
|---|---|
| **Add a new package** | Find the parent package in the right `.sysml` file, add the `package` block inside it |
| **Rename a package** | Rename in the `.sysml` file, search for references in other files |
| **Move a package** | Cut from one location, paste into another (may be a different file) |
| **Remove a package** | Delete the `package` block, search for references |
| **Check everything is aligned** | Run `gsl diff` or `gsl` |

---

## Which file do I edit?

Each top-level domain has its own file:

| Domain | File | Contains |
|---|---|---|
| Enterprise | `model/enterprise.sysml` | Organisation, Regulation, Strategy, Risk |
| Foundation | `model/foundation.sysml` | MetadataLibrary, CommonTypes, StatePatterns, GenerationPipeline |
| Knowledge | `model/knowledge.sysml` | ClinicalDecisionSupport, ConstraintLibrary, LogicEngine, DecisionModels, OutcomeFramework, LearningCycles, Analytics |
| Operations | `model/operations.sysml` | Finance, People, Marketing, CRM, Reporting |
| Platform | `model/platform.sysml` | PatientPortal (and sub-packages), Education, Community, Booking, EHR, Forms, Messaging, VideoConsulting, LabInterface, PrescribingSystem, Payments, Documents, Identity, Orchestration, Integration |
| ServiceDelivery | `model/service-delivery.sysml` | PatientJourney, ClinicalPathways (and sub-packages), Consent, CoachingSupport, ClinicalGovernance, ClinicalEntities |

The root package is in `model/gendersense.sysml` — you rarely need to edit this unless adding a new top-level domain.

---

## Adding a new package

### Step 1: Decide where it belongs

Think about which domain package owns this new package. If it's a clinical concern, it probably goes in ServiceDelivery. If it's a technology subsystem, Platform. If it's a business rule or decision logic concern, Knowledge.

### Step 2: Open the right file

Open the `.sysml` file for that domain (see table above).

### Step 3: Find the parent package

Scroll to the package that should contain your new package. For example, if you're adding a new sub-package under Platform::PatientPortal, find the `package PatientPortal {` block.

### Step 4: Add the package

Insert inside the parent package's braces. The minimum viable package is:

```sysml
        package MyNewPackage {
            private import ScalarValues::*;

            doc /* Brief description of what this package covers.
                 * Keep it to one or two sentences for the first line —
                 * the hierarchy generator uses this as the summary. */
        }
```

### Step 5: Add content (optional at this stage)

If you know what use cases or structural elements belong here, add them:

```sysml
        package MyNewPackage {
            private import ScalarValues::*;

            doc /* Brief description of what this package covers. */

            use case def DoSomething {
                doc /* What this use case achieves. */
            }

            part def SomeEntity {
                doc /* What this entity represents. */
                attribute name : String;
            }
        }
```

### Step 6: Verify in Syside

Open the workspace in Syside Modeler. Check that the new package parses clean (no red underlines, no errors in the Problems panel).

### Step 7: Regenerate and check

```bash
gsl view          # check it appears in the right place
gsl save          # regenerate all outputs
```

---

## Renaming a package

### Step 1: Rename in the source file

Find the `package OldName {` line and change it to `package NewName {`.

### Step 2: Search for references

Other files may import or reference the old name. Search across all `.sysml` files:

```bash
grep -rn "OldName" model/ libraries/
```

Common places references appear:
- `private import OldName::*;` in other packages
- `ref someField : OldName::SomeType;` in part definitions
- `@SomeMetadata { ... }` annotations that reference elements by name

Update all references to the new name.

### Step 3: Verify and regenerate

```bash
# Verify in Syside (check for unresolved references)
gsl view
gsl diff          # check proposal alignment if relevant
```

---

## Moving a package to a different parent

### Step 1: Cut the entire package block

Select everything from `package TheName {` to its closing `}`, including all contents. Cut it.

### Step 2: Paste into the new parent

Open the target file (if different) and paste the package block inside the new parent package's braces.

### Step 3: Check imports

If the moved package imports types from its old siblings, those imports may need updating. For example, if the package used `private import SiblingPackage::SomeType;` and the sibling is no longer in the same file, the import path may need to be fully qualified.

### Step 4: Check references to the moved package

Other packages that referenced the moved package by its old qualified name need updating:

```bash
grep -rn "OldParent::MovedPackage" model/ libraries/
```

### Step 5: Verify and regenerate

---

## Removing a package

### Step 1: Check for references

Before deleting, check whether anything references the package:

```bash
grep -rn "PackageName" model/ libraries/
```

If other packages import from it or reference its types, you'll need to handle those first.

### Step 2: Delete the package block

Remove everything from `package PackageName {` to its closing `}`.

### Step 3: Verify and regenerate

---

## Adding a new top-level domain package

This is rare — you'd only do this if the six existing domains (Enterprise, Foundation, Knowledge, Operations, Platform, ServiceDelivery) don't cover a new concern.

### Step 1: Create a new file

Create `model/newdomain.sysml`:

```sysml
// =========================================================================
// NEWDOMAIN — Brief description
// =========================================================================

package NewDomain {
    private import ScalarValues::*;

    doc /* What this domain covers and why it exists
         * as a separate top-level concern. */
}
```

### Step 2: Add the import to gendersense.sysml

Open `model/gendersense.sysml` and add:

```sysml
    private import NewDomain::*;
```

alongside the other imports.

### Step 3: Update the doc block in gendersense.sysml

Add the new file to the file structure listing in the root doc block.

### Step 4: Verify and regenerate

The hierarchy generator reads the imports from `gendersense.sysml` to build the tree, so the new domain will appear automatically once the import is added.

---

## SysML syntax quick reference for packages

### Package with doc block (minimum)

```sysml
package Name {
    private import ScalarValues::*;

    doc /* Description. */
}
```

### Package with use cases

```sysml
package Name {
    private import ScalarValues::*;

    doc /* Description. */

    use case def VerbNoun {
        doc /* What this use case achieves. */
    }
}
```

### Package with part definitions

```sysml
package Name {
    private import ScalarValues::*;

    doc /* Description. */

    part def EntityName {
        doc /* What this entity represents. */
        attribute fieldName : String;
        attribute otherField : Integer;
        ref relatedEntity : OtherPackage::OtherEntity;
    }
}
```

### Package with nested sub-packages

```sysml
package Parent {
    private import ScalarValues::*;

    doc /* Parent description. */

    package ChildA {
        private import ScalarValues::*;

        doc /* Child A description. */
    }

    package ChildB {
        private import ScalarValues::*;

        doc /* Child B description. */
    }
}
```

---

## Common traps

**`private import ScalarValues::*;`** — include this in every package. Without it, basic types like `String` and `Integer` won't resolve.

**Doc block format** — must be `doc /* text */`. Not `// comment`. The hierarchy generator reads `doc` blocks for descriptions.

**First sentence matters** — the generator uses the first sentence of the doc block (up to the first period-space) as the one-line summary. Make it count.

**Reserved words** — don't use these as names: `ordered`, `accepted`, `comment`. They shadow SysML/KerML keywords.

**Case sensitivity** — package and element names are case-sensitive. `MyPackage` and `mypackage` are different things.

**Brace matching** — every `{` needs a `}`. If Syside shows parse errors after your edit, count braces. A common mistake is deleting a closing brace when removing content.

---

## The workflow in full

1. **Decide** what to change (add/rename/move/remove)
2. **Edit** the `.sysml` file(s)
3. **Verify** in Syside Modeler (clean parse, no red underlines)
4. **Regenerate** with `gsl view` then `gsl save`
5. **Review** the outputs (terminal tree, OmniOutliner, or mindmap)
6. **Commit** the model changes and regenerated files together

---

*Guide written 8 March 2026 (Session 7). Companion to gen_package_hierarchy.py and the gsl shell script.*
