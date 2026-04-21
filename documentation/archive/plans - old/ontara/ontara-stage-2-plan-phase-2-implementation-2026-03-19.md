# Ontara — Stage 2 Phase 2: Generator Extension — Detailed Implementation Plan

**Date:** 19 March 2026 (Session 39)
**Prepared by:** Claude, in discussion with Ella Green
**Status:** For review and agreement before implementation
**Parent plan:** [[ontara-stage-2-plan-phase-1-implementation-2026-03-19|Stage 2 Detailed Implementation Plan]]
**Phase:** 2 of 6 — Generator Extension (Catalogue JSON)
**Depends on:** Phase 1 (complete — `@CatalogueTag` and `@UserFacing` metadata in SysML, committed as `c1ea305`)

---

## 1. Objective

Extend `gen_model_introspection.py` to extract `@CatalogueTag` and `@UserFacing` metadata annotations from the SysML model and produce catalogue-ready JSON. The output must include per-element tag and user-facing data, a top-level facet summary with counts per dimension value, and enriched coverage matrix entries — everything the Phase 4 catalogue view needs to render multi-axis grouping and the comprehension layer.

---

## 2. Current State of the Generator

**File:** `scripts/gen_model_introspection.py` (413 lines, pure Python standard library, no external dependencies).

**What it does now:**

- Scans `.sysml` files across three domain sources (core, csw, suds).
- Extracts elements by kind: `part_def`, `part` (usage), `enum_def`, `metadata_def`, `requirement`.
- For each element: name, parent package, specialisation, doc block (truncated to 300 chars), attributes, source file, source domain, line number.
- Classifies each element into a meta model layer (`bmm`, `bsmm`, `domain`, `unknown`) using doc block keywords, package membership, and type-name lookup.
- Builds a coverage matrix: which BMM/BSMM `part def`s are instantiated in which domains.
- Outputs JSON with: `generatedAt`, `generator`, `domains`, `summary`, `coverageMatrix`, `elements`.

**What it does NOT do:**

- Does not recognise `@CatalogueTag` or `@UserFacing` annotations.
- Does not associate prefix metadata annotations with the element they annotate.
- Does not produce facet summaries.
- Does not include tag or user-facing data in element records or coverage matrix entries.

---

## 3. Annotation Patterns in the Model

From inspection of `business-model.sysml` (Phase 1 output), annotations follow Position A (prefix) convention. Two patterns exist:

### Pattern 1: `@CatalogueTag` (single line)

```
        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        part def CustomerSegment {
```

All on one line. Attributes are `bmmConcern` (String) and `classification` (String). Always immediately precedes the `part def` line (possibly with a `@UserFacing` block between them).

### Pattern 2: `@UserFacing` (multi-line)

```
        @UserFacing {
            friendlyName = "Customer Segment";
            shortDescription = "A defined group of customers with shared needs and willingness to pay.";
        }
        part def CustomerSegment {
```

Multi-line block. Attributes are `friendlyName` (String) and `shortDescription` (String). Appears between `@CatalogueTag` and `part def` when both are present.

### Combined pattern

```
        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        @UserFacing {
            friendlyName = "Customer Segment";
            shortDescription = "A defined group of customers with shared needs and willingness to pay.";
        }
        part def CustomerSegment {
```

### CatalogueTag only (no UserFacing)

```
        @CatalogueTag { bmmConcern = "ServiceConcept"; classification = "General"; }
        part def Channel {
```

13 of the 24 BMM `part def`s have `@CatalogueTag` only; 11 have both `@CatalogueTag` and `@UserFacing`.

### Key observations for regex design

1. `@CatalogueTag` is always a single line with `{ key = "value"; key = "value"; }` syntax.
2. `@UserFacing` spans multiple lines with one attribute assignment per line.
3. Both annotations appear as prefix to the element, at the same indentation level as the `part def`.
4. There may be zero, one, or two annotations before a `part def`.
5. Attribute values are always double-quoted strings.
6. The attribute names within `@CatalogueTag` are currently `bmmConcern` and `classification`, but the parser should be **generic** — extract all `key = "value"` pairs from any `@MetadataName { ... }` block, so that future dimension attributes are automatically picked up without code changes.

---

## 4. Implementation Steps

### Step 1: Add annotation extraction to the line-scanning parser

**Approach:** Modify the main `while i < len(lines)` loop in `parse_sysml_file()` to detect `@Name { ... }` annotation patterns. When detected, store them in a "pending annotations" buffer. When the next `part def` (or other element) is encountered, attach the pending annotations to that element.

**New data on `SysmlElement`:**

```python
self.catalogue_tag = {}      # {"bmmConcern": "...", "classification": "..."}
self.user_facing = {}         # {"friendlyName": "...", "shortDescription": "..."}
self.raw_annotations = []     # all prefix annotations, for future extensibility
```

**Regex patterns needed:**

```python
# Single-line annotation: @Name { key = "value"; key2 = "value2"; }
single_line_annotation = re.compile(
    r'^\s*@(\w+)\s*\{([^}]+)\}\s*$'
)

# Multi-line annotation start: @Name {
multi_line_annotation_start = re.compile(
    r'^\s*@(\w+)\s*\{\s*$'
)

# Attribute assignment inside annotation: key = "value";
annotation_attr = re.compile(
    r'(\w+)\s*=\s*"([^"]*)"\s*;'
)

# Multi-line annotation end: }
annotation_end = re.compile(
    r'^\s*\}\s*$'
)
```

**Logic:**

```
pending_annotations = []
in_annotation = False
annotation_name = ""
annotation_attrs = {}

for each line:
    if in_annotation:
        if annotation_end matches:
            pending_annotations.append((annotation_name, annotation_attrs))
            in_annotation = False
            continue
        else:
            extract key="value" pairs, add to annotation_attrs
            continue

    if single_line_annotation matches:
        extract all key="value" pairs from the inline content
        pending_annotations.append((name, {k: v for pairs}))
        continue

    if multi_line_annotation_start matches:
        in_annotation = True
        annotation_name = matched name
        annotation_attrs = {}
        continue

    if part_def matches (or other element):
        create element as before
        attach pending_annotations to element
        clear pending_annotations
```

**Edge cases to handle:**

- Annotations before elements other than `part def` (currently none in the model, but the parser should not break if they appear — attach them and move on).
- Multiple annotations of different types before one element (the current pattern: `@CatalogueTag` then `@UserFacing` then `part def`).
- Lines between annotations and the element (comments, blank lines) — the pending buffer should survive these.
- An annotation that is never followed by an element before end-of-file — discard gracefully.

**Scope boundary:** The parser only needs to handle `@CatalogueTag` and `@UserFacing` semantically (mapping to specific fields on `SysmlElement`). All other annotations go into `raw_annotations` for future use. The semantic mapping is:

```python
for ann_name, ann_attrs in pending_annotations:
    if ann_name == "CatalogueTag":
        elem.catalogue_tag = ann_attrs
    elif ann_name == "UserFacing":
        elem.user_facing = ann_attrs
    elem.raw_annotations.append({"name": ann_name, "attrs": ann_attrs})
```

### Step 2: Extend `SysmlElement.to_dict()` to include annotation data

Add to the element's JSON representation:

```python
def to_dict(self):
    d = { ... existing fields ... }
    if self.catalogue_tag:
        d["catalogueTag"] = self.catalogue_tag
    if self.user_facing:
        d["userFacing"] = self.user_facing
    if self.raw_annotations:
        d["annotations"] = self.raw_annotations
    return d
```

This means every element in the `elements` array that has metadata annotations will carry them in the JSON. Elements without annotations are unaffected.

### Step 3: Enrich the coverage matrix with tag and user-facing data

Currently `build_coverage_matrix()` builds entries for each meta `part def` with `name`, `layer`, `package`, `doc`, and `domains`. Extend each entry to include:

```python
meta_defs[elem.name] = {
    "name": elem.name,
    "layer": elem.meta_model_layer,
    "package": elem.parent_package,
    "doc": elem.doc[:200] if elem.doc else "",
    "catalogueTag": elem.catalogue_tag,       # NEW
    "userFacing": elem.user_facing,           # NEW
    "domains": {},
}
```

This means the coverage matrix — already used by the `/coverage` console page — gains tag and user-facing data without breaking its existing structure. The console can progressively adopt the new fields.

### Step 4: Build the facet summary

Add a new function `build_facet_summary()` that scans all elements with `catalogue_tag` data and produces a facet index:

```python
def build_facet_summary(all_elements):
    """Build a summary of all tag dimensions and their value distributions."""
    facets = {}
    for elem in all_elements:
        if not elem.catalogue_tag:
            continue
        for dimension, value in elem.catalogue_tag.items():
            if dimension not in facets:
                facets[dimension] = {"values": set(), "counts": defaultdict(int)}
            facets[dimension]["values"].add(value)
            facets[dimension]["counts"][value] += 1

    # Convert sets to sorted lists for JSON serialisation
    return {
        dim: {
            "values": sorted(info["values"]),
            "counts": dict(info["counts"]),
            "total": sum(info["counts"].values()),
        }
        for dim, info in sorted(facets.items())
    }
```

This produces a structure like:

```json
{
  "facets": {
    "bmmConcern": {
      "values": ["ActivityModel", "FinancialModel", "ResourceCapability", "ServiceConcept"],
      "counts": {"ServiceConcept": 7, "ActivityModel": 5, "ResourceCapability": 7, "FinancialModel": 5},
      "total": 24
    },
    "classification": {
      "values": ["General"],
      "counts": {"General": 24},
      "total": 24
    }
  }
}
```

The catalogue view (Phase 4) reads this to dynamically build "group by" controls — it doesn't need to know what dimensions exist in advance.

### Step 5: Add a comprehension summary

Add a summary of user-facing metadata coverage:

```python
def build_comprehension_summary(all_elements):
    """Summarise @UserFacing metadata coverage."""
    tagged_elements = [e for e in all_elements if e.catalogue_tag]
    with_user_facing = [e for e in tagged_elements if e.user_facing]
    return {
        "catalogueTaggedCount": len(tagged_elements),
        "userFacingCount": len(with_user_facing),
        "coveragePercent": round(len(with_user_facing) / len(tagged_elements) * 100, 1)
            if tagged_elements else 0,
        "missingUserFacing": [
            {"name": e.name, "package": e.parent_package}
            for e in tagged_elements if not e.user_facing
        ],
    }
```

This tells the console (and us) which elements still need friendly names and descriptions — supporting incremental comprehension layer build-out.

### Step 6: Extend the output JSON structure

The `output` dict in `main()` gains two new top-level keys:

```python
output = {
    "generatedAt": ...,
    "generator": "gen_model_introspection.py",
    "domains": ...,
    "summary": ...,
    "facets": build_facet_summary(all_elements),           # NEW
    "comprehension": build_comprehension_summary(all_elements),  # NEW
    "coverageMatrix": coverage,   # now enriched with catalogueTag + userFacing
    "elements": ...,              # now includes catalogueTag + userFacing per element
}
```

**Backward compatibility:** The existing `domains`, `summary`, `coverageMatrix`, and `elements` keys retain their structure. New fields are additive. The existing `/coverage` and `/packages` console pages will not break.

### Step 7: Update stderr diagnostic output

Extend the summary printed to stderr to include:

- Count of elements with `@CatalogueTag`
- Count of elements with `@UserFacing`
- Facet dimension summary (dimensions and value counts)
- List of tagged elements missing `@UserFacing`

This provides immediate validation feedback when Ella runs the generator.

### Step 8: Re-run generator, inspect output, copy to console

```bash
cd ~/Developer/gsl-tech/gsl-sysml-model
python scripts/gen_model_introspection.py --save --pretty
# Inspect generated/ontara/model-introspection.json
# Verify: 24 elements have catalogueTag, 11 have userFacing
# Verify: facets contain bmmConcern (4 values) and classification (1 value)
cp generated/ontara/model-introspection.json console/static/data/
```

### Step 9: Validate existing console pages still work

Open the console (`cd console && npm run dev`) and verify:

- `/coverage` renders correctly (the enriched coverage matrix should not break anything)
- `/packages` renders correctly
- No console errors

---

## 5. Expected JSON Output Shape (Illustrative)

After Phase 2, the generated JSON will look like this (abridged):

```json
{
  "generatedAt": "2026-03-19T...",
  "generator": "gen_model_introspection.py",
  "domains": { ... unchanged ... },
  "summary": { ... unchanged ... },
  "facets": {
    "bmmConcern": {
      "values": ["ActivityModel", "FinancialModel", "ResourceCapability", "ServiceConcept"],
      "counts": {"ServiceConcept": 7, "ActivityModel": 5, "ResourceCapability": 7, "FinancialModel": 5},
      "total": 24
    },
    "classification": {
      "values": ["General"],
      "counts": {"General": 24},
      "total": 24
    }
  },
  "comprehension": {
    "catalogueTaggedCount": 24,
    "userFacingCount": 11,
    "coveragePercent": 45.8,
    "missingUserFacing": [
      {"name": "Channel", "package": "ServiceConcept"},
      {"name": "DifferentiationClaim", "package": "ServiceConcept"},
      ...
    ]
  },
  "coverageMatrix": {
    "CustomerSegment": {
      "name": "CustomerSegment",
      "layer": "bmm",
      "package": "ServiceConcept",
      "doc": "...",
      "catalogueTag": {"bmmConcern": "ServiceConcept", "classification": "General"},
      "userFacing": {
        "friendlyName": "Customer Segment",
        "shortDescription": "A defined group of customers with shared needs and willingness to pay."
      },
      "domains": { ... unchanged ... }
    },
    "Channel": {
      "name": "Channel",
      "layer": "bmm",
      "package": "ServiceConcept",
      "doc": "...",
      "catalogueTag": {"bmmConcern": "ServiceConcept", "classification": "General"},
      "userFacing": {},
      "domains": { ... }
    },
    ...
  },
  "elements": [
    {
      "kind": "part_def",
      "name": "CustomerSegment",
      "parentPackage": "ServiceConcept",
      "doc": "...",
      "catalogueTag": {"bmmConcern": "ServiceConcept", "classification": "General"},
      "userFacing": {
        "friendlyName": "Customer Segment",
        "shortDescription": "A defined group of customers with shared needs and willingness to pay."
      },
      "sourceFile": "model/business-model.sysml",
      "sourceDomain": "core",
      "metaModelLayer": "bmm",
      "lineNumber": 72,
      "attributes": [...]
    },
    ...
  ]
}
```

---

## 6. Verification Checklist

After implementation, verify:

- [ ] Generator runs without errors on the current model
- [ ] 24 elements have `catalogueTag` data (matching the 24 BMM `part def`s tagged in Phase 1)
- [ ] 11 elements have `userFacing` data (matching the 11 `@UserFacing`-annotated `part def`s)
- [ ] Facet summary contains exactly 2 dimensions: `bmmConcern` (4 values) and `classification` (1 value: "General")
- [ ] `bmmConcern` counts sum to 24: ServiceConcept 7, ActivityModel 5, ResourceCapability 7, FinancialModel 5
- [ ] `comprehension.missingUserFacing` lists exactly 13 elements
- [ ] Coverage matrix entries for tagged `part def`s include `catalogueTag` and `userFacing`
- [ ] Elements without annotations have no `catalogueTag`, `userFacing`, or `annotations` keys (clean output)
- [ ] Existing console pages (`/coverage`, `/packages`) render without errors
- [ ] JSON file size is reasonable (existing is ~170KB; should grow modestly)

---

## 7. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| **Regex fails on edge-case annotation formatting** | Test against actual model content. The patterns are very regular — Phase 1 was mechanical application by Claude, so formatting is consistent. |
| **Multi-line `@UserFacing` not correctly associated with following `part def`** | The pending-annotations buffer handles this — annotations are held until an element line is reached. Blank lines and comments between annotations and element do not clear the buffer. |
| **Future annotation types break the parser** | Generic extraction (any `@Name { attrs }`) with semantic mapping only for known types. Unknown annotation types land in `raw_annotations` and are carried through without special handling. |
| **Annotation on non-`part def` elements** | The buffer-attach mechanism works for any element type the parser recognises. If an annotation precedes a `part` usage, `enum def`, or `requirement`, it attaches correctly. |
| **Existing console code expects old JSON shape** | All changes are additive — no existing keys are removed or restructured. New keys (`facets`, `comprehension`, `catalogueTag`, `userFacing`) are added alongside existing structure. |

---

## 8. Execution Assignment

| Step | Assigned to | Notes |
|---|---|---|
| Steps 1–7 (generator code changes) | **Claude Chat** (this session) | Builds on the existing generator which Claude wrote in Session 37. Interactive development with review. |
| Step 8 (run generator, inspect output) | **Ella** | Claude cannot run Python on the local filesystem. Ella runs `python scripts/gen_model_introspection.py --save --pretty` and shares the stderr output for validation. |
| Step 9 (verify console pages) | **Ella** | Opens the console, checks existing pages render. |

**Claude Code suitability:** Steps 1–7 could in principle be done by Claude Code, but the generator modifications involve design judgement (regex patterns, buffer logic, JSON structure) that benefits from interactive discussion. The implementation is a single file of moderate complexity — better suited to Claude Chat working through it with Ella.

**Estimated effort:** Approximately 1 session. Steps 1–7 are the bulk of the work; Steps 8–9 are quick verification.

---

## 9. What This Unblocks

Phase 2 completion unblocks:

- **Phase 4 (Component Catalogue view):** The catalogue page needs facet summaries for "group by" controls, per-element tag data for grouping logic, and user-facing metadata for the comprehension layer. All of this is produced by Phase 2.
- **Incremental enrichment:** Once the generator extracts annotations generically, adding new `@CatalogueTag` dimensions (e.g., to Suds elements in Phase 3) or new `@UserFacing` entries automatically flows through to the JSON without further generator changes.

---

## 10. Master Register Concepts Exercised

| Concept | How |
|---|---|
| A3 (model generates everything) | Metadata annotations in SysML → generated JSON → console rendering |
| D9 (metadata-driven generation) | Generator extended to read and interpret metadata annotations |
| E6–E8 (generator pipeline) | `gen_model_introspection.py` extended — single generator, richer output |
| J2 (co-evolution) | Model metadata (Phase 1) and generator extraction (Phase 2) advance together |
| I10 (tagging system) | `@CatalogueTag` data flows from model to JSON for the first time |
| I14/I14a (comprehension layer) | `@UserFacing` data flows from model to JSON, comprehension coverage tracked |

---

*Phase 2 implementation plan prepared 19 March 2026. For review and agreement before implementation begins.*
