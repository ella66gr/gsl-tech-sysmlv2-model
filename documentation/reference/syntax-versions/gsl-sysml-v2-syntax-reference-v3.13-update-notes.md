# Syntax Reference v3.13 — Update Notes

**For:** `gsl-sysml-v2-syntax-reference-v3.12-2026-03-15.md` → rename to `v3.13`
**Session:** 31

## Changes to apply

### Header update

Change version line to:
```
> **Version:** 3.13 — 15 March 2026
```

Add to "What's new" line:
```
> **What's new in v3.13:** Session 31 Knowledge Graph Enhancement. `ref :>> fieldName = (targetA, targetB);` tuple redefinition between peer part usages verified — single target, multi-valued tuple, circular refs, cross-type refs, and forward references all work. This is the syntax used for the PatternCatalogue semantic relationship layer (~43 typed ref links).
```

### Section 2 — add after "References with multiplicity" subsection

Add new subsection:

```markdown
### ref :>> redefinition with tuple syntax (verified v3.13)

Inside a part usage, `ref :>>` can redefine a multi-valued ref field with a parenthesised tuple of peer part usages:

\`\`\`sysml
part def Pattern {
    ref dependsOn : Pattern[0..*];
    ref motivatedBy : ArchitecturalPrinciple[0..*];
}

part patternA : Pattern {
    ref :>> dependsOn = (patternB, patternC);           // multi-valued tuple ✅
    ref :>> motivatedBy = (principleAlpha);               // single-target tuple ✅
}

part patternB : Pattern {
    ref :>> dependsOn = (patternA);                       // circular ref ✅
}
\`\`\`

**Verified (Session 31):**
- Single-target tuple: `ref :>> field = (target);` ✅
- Multi-valued tuple: `ref :>> field = (targetA, targetB);` ✅
- Circular refs between peer parts ✅ (no ownership cycle — refs are not containment)
- Cross-type tuple: Pattern instance referencing ArchitecturalPrinciple peer parts ✅
- Forward references: referencing a part declared later in the same package ✅
```

### TODO section — update

Mark as done:
```
- [x] Multi-valued enum `:>>` redefinition with tuple syntax on instances — **N/A for enum; verified for ref :>> with tuple syntax (v3.13)**
```

Add to confirmed patterns:
```
- [x] `ref :>> fieldName = (peerPartA, peerPartB);` — tuple redefinition between peer part usages (v3.13)
```

### Version history table — add row

```
| 3.13 | 15 Mar 2026 | `ref :>>` tuple redefinition verified (single, multi-valued, circular, cross-type, forward reference). PatternCatalogue knowledge graph: 43 typed ref links across 20 patterns. |
```
