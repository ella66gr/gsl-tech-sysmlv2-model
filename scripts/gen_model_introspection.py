#!/usr/bin/env python3
"""
Ontara Model Introspection Generator
======================================

Reads the SysML v2 model files (main model + exercise domains) and
produces a structured JSON representation suitable for the Ontara
console frontend.

Extracts:
  - Part defs (with attributes, doc blocks, meta model classification)
  - Part usages (instantiations of part defs, per domain)
  - Enum defs
  - Metadata defs
  - Requirement defs
  - Cross-domain coverage matrix (which domains instantiate which defs)
  - @CatalogueTag and @UserFacing metadata annotations (Stage 2 Phase 2)
  - Facet summaries for dynamic catalogue grouping
  - Comprehension layer coverage tracking

Usage:
    python scripts/gen_model_introspection.py                  # Print summary
    python scripts/gen_model_introspection.py --save           # Save JSON
    python scripts/gen_model_introspection.py --save --pretty  # Pretty-print

Output: generated/ontara/model-introspection.json

No external dependencies — pure Python standard library.

Source: Ontara Console — Phase 1 model data foundation, Phase 2 catalogue metadata.
"""

import argparse
import json
import pathlib
import re
import sys
from collections import defaultdict
from typing import Optional

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
EXERCISES_DIR = REPO_ROOT / "exercises"
LIBRARIES_DIR = REPO_ROOT / "libraries"
GENERATED_DIR = REPO_ROOT / "generated" / "ontara"

# Files to exclude from scanning (test files, spikes, etc.)
EXCLUDE_PATTERNS = [
    "test-",
    "spike-",
]

# Domain directories — each exercise is a domain
DOMAIN_SOURCES = {
    "core": {
        "label": "Core Model",
        "model_dirs": [MODEL_DIR],
        "description": "The main GenderSense SysML model — meta models and GSL domain",
    },
    "csw": {
        "label": "Coffee Shop (CSW)",
        "model_dirs": [EXERCISES_DIR / "coffeeshop-demonstrator" / "model"],
        "description": "Coffee shop demonstrator — reference validation domain",
    },
    "suds": {
        "label": "Laundry (Suds)",
        "model_dirs": [EXERCISES_DIR / "suds-demonstrator" / "model"],
        "description": "Laundry service demonstrator \u2014 cross-domain validation",
    },
    # Paws will be added here when created
}

# Meta model classification keywords found in doc blocks
BMM_MARKERS = [
    "business meta model",
    "business model concept",
]
BSMM_MARKERS = [
    "business system meta model",
    "system meta model",
]

# Packages known to belong to the business meta model
BMM_PACKAGES = {
    "BusinessModel", "ServiceConcept", "ActivityModel",
    "ResourcePlanning", "FinancialPlanning",
    "BusinessScenarios", "BusinessStrategy",
}

# Packages known to belong to the system meta model
BSMM_PACKAGES = {
    "Foundation", "MetadataLibrary", "CommonTypes", "StatePatterns",
    "GenerationPipeline", "Knowledge", "ClinicalDecisionSupport",
    "ConstraintLibrary", "LogicEngine", "DecisionModels",
    "OutcomeFramework", "LearningCycles", "Analytics",
    "Platform", "PatientPortal", "EHR", "Booking", "Forms",
    "Orchestration", "Integration", "Identity",
    "ServiceDelivery", "ClinicalPathways", "PatternCatalogue",
}

# Domain-specific packages (not meta model — instances)
DOMAIN_PACKAGES = {
    "Enterprise", "Operations", "GenderSense",
    "Organisation", "Strategy", "Finance", "People",
    "EstatesAndFacilities", "Regulation", "ClinicalEntities",
    "CoffeeShop", "CoffeeShopBusinessModel",
    "CoffeeShopArchetypes", "CoffeeshopResourceFinancial",
    "CoffeeshopScenarios",
    "SudsBusinessModel", "SudsResourceFinancial", "SudsGovernance",
}


# ---------------------------------------------------------------
# SysML text parser
# ---------------------------------------------------------------

class SysmlElement:
    """An element extracted from a .sysml file."""
    def __init__(self, kind, name, parent_package="", specialises="",
                 doc="", attributes=None, source_file="",
                 source_domain="", line_number=0):
        self.kind = kind              # "part_def", "part", "enum_def", etc.
        self.name = name
        self.parent_package = parent_package
        self.specialises = specialises  # ":> SuperType" if present
        self.doc = doc.strip()
        self.attributes = attributes or []
        self.source_file = source_file
        self.source_domain = source_domain
        self.line_number = line_number
        self.meta_model_layer = ""    # "bmm", "bsmm", "domain", "unknown"
        # Stage 2 Phase 2: metadata annotation data
        self.catalogue_tag = {}       # {"bmmConcern": "...", "classification": "..."}
        self.user_facing = {}         # {"friendlyName": "...", "shortDescription": "..."}
        self.annotations = []         # all prefix annotations for future extensibility

    def to_dict(self):
        d = {
            "kind": self.kind,
            "name": self.name,
            "parentPackage": self.parent_package,
            "doc": self.doc[:300] if self.doc else "",
            "sourceFile": self.source_file,
            "sourceDomain": self.source_domain,
            "metaModelLayer": self.meta_model_layer,
            "lineNumber": self.line_number,
        }
        if self.specialises:
            d["specialises"] = self.specialises
        if self.attributes:
            d["attributes"] = self.attributes
        # Stage 2 Phase 2: include annotation data when present
        if self.catalogue_tag:
            d["catalogueTag"] = self.catalogue_tag
        if self.user_facing:
            d["userFacing"] = self.user_facing
        if self.annotations:
            d["annotations"] = self.annotations
        return d


def extract_doc_block(lines, start_idx):
    """Extract a doc block starting at or just before start_idx."""
    # Look backwards from start_idx for a doc block
    doc_lines = []
    i = start_idx
    # Check if the line itself or the next lines contain doc /*
    text = lines[i] if i < len(lines) else ""
    
    # Look ahead for doc block on next lines
    j = i + 1
    while j < len(lines) and j < i + 3:
        if "doc /*" in lines[j] or "doc /*" in lines[j].strip():
            # Found doc block, collect it
            doc_start = j
            in_doc = True
            for k in range(doc_start, min(len(lines), doc_start + 50)):
                line = lines[k]
                doc_lines.append(line)
                if "*/" in line:
                    break
            break
        elif lines[j].strip() and not lines[j].strip().startswith("//"):
            break
        j += 1

    if not doc_lines:
        # Check immediately preceding lines
        j = i - 1
        while j >= max(0, i - 3):
            stripped = lines[j].strip()
            if stripped.startswith("doc /*") or stripped.startswith("/*"):
                # Collect forward from here
                for k in range(j, min(len(lines), j + 50)):
                    doc_lines.append(lines[k])
                    if "*/" in lines[k]:
                        break
                break
            elif stripped and not stripped.startswith("//"):
                break
            j -= 1

    if doc_lines:
        text = "\n".join(doc_lines)
        # Clean up doc block syntax
        text = re.sub(r'doc\s*/\*', '', text)
        text = re.sub(r'\*/', '', text)
        text = re.sub(r'^\s*\*\s?', '', text, flags=re.MULTILINE)
        return text.strip()
    return ""


def parse_attributes(lines, start_idx, end_idx):
    """Extract attribute declarations from a block of lines."""
    attrs = []
    for i in range(start_idx, min(end_idx, len(lines))):
        line = lines[i].strip()
        
        # attribute :>> name = "value";
        m = re.match(r'attribute\s+:>>\s+(\w+)\s*=\s*(.+?)\s*;', line)
        if m:
            attrs.append({
                "name": m.group(1),
                "value": m.group(2).strip('"').strip("'"),
                "isRedefinition": True,
            })
            continue
        
        # attribute name : Type;
        m = re.match(r'attribute\s+(?::>>\s+)?(\w+)\s*:\s*(\S+)', line)
        if m:
            attrs.append({
                "name": m.group(1),
                "type": m.group(2).rstrip(";").strip(),
                "isRedefinition": False,
            })
            continue
        
        # ref name : Type
        m = re.match(r'ref\s+(?::>>\s+)?(\w+)\s*:\s*(\S+)', line)
        if m:
            attrs.append({
                "name": m.group(1),
                "type": m.group(2).rstrip(";").strip(),
                "isRef": True,
            })
    return attrs


def find_block_end(lines, start_idx):
    """Find the closing brace that matches the opening brace at start_idx."""
    depth = 0
    for i in range(start_idx, len(lines)):
        line = lines[i]
        # Count braces outside of strings and comments
        in_string = False
        for ch in line:
            if ch == '"' and not in_string:
                in_string = True
            elif ch == '"' and in_string:
                in_string = False
            elif not in_string:
                if ch == '{':
                    depth += 1
                elif ch == '}':
                    depth -= 1
                    if depth == 0:
                        return i
    return len(lines) - 1


def parse_sysml_file(filepath, domain_key):
    """Parse a single .sysml file and extract elements."""
    elements = []
    
    try:
        text = filepath.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return elements
    
    lines = text.split("\n")
    
    # Track package nesting
    package_stack = []
    
    # Patterns we look for
    pkg_pattern = re.compile(
        r'^(\s*)package\s+(\w+(?:::\w+)*)\s*\{'
    )
    part_def_pattern = re.compile(
        r'^(\s*)part\s+def\s+(\w+)(?:\s*:>\s*(\w+(?:::\w+)*))?'
    )
    part_usage_pattern = re.compile(
        r'^(\s*)part\s+(\w+)\s*:\s*(\w+(?:::\w+)*)(?:\s*\{)?'
    )
    enum_def_pattern = re.compile(
        r'^(\s*)enum\s+def\s+(\w+)\s*\{'
    )
    metadata_def_pattern = re.compile(
        r'^(\s*)metadata\s+def\s+(\w+)'
    )
    requirement_pattern = re.compile(
        r'^(\s*)requirement\s+(\w+)\s*:\s*(\w+(?:::\w+)*)'
    )
    
    # Stage 2 Phase 2: annotation patterns
    # Single-line: @Name { key = "value"; key2 = "value2"; }
    single_line_ann_pattern = re.compile(
        r'^\s*@(\w+)\s*\{([^}]+)\}\s*$'
    )
    # Multi-line start: @Name {
    multi_line_ann_start_pattern = re.compile(
        r'^\s*@(\w+)\s*\{\s*$'
    )
    # Attribute inside annotation: key = "value";
    ann_attr_pattern = re.compile(
        r'(\w+)\s*=\s*"([^"]*)"\s*;'
    )
    
    rel_path = str(filepath.relative_to(REPO_ROOT))
    
    # Pending annotations buffer — accumulated until the next element
    pending_annotations = []
    in_annotation = False
    ann_name = ""
    ann_attrs = {}
    
    def attach_annotations(elem):
        """Attach pending annotations to an element and clear the buffer."""
        nonlocal pending_annotations
        for a_name, a_attrs in pending_annotations:
            if a_name == "CatalogueTag":
                elem.catalogue_tag = dict(a_attrs)
            elif a_name == "UserFacing":
                elem.user_facing = dict(a_attrs)
            elem.annotations.append({"name": a_name, "attrs": dict(a_attrs)})
        pending_annotations = []
    
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        
        # --- Inside a multi-line annotation block ---
        if in_annotation:
            if stripped == "}":
                # End of multi-line annotation
                pending_annotations.append((ann_name, ann_attrs))
                in_annotation = False
                ann_name = ""
                ann_attrs = {}
                i += 1
                continue
            else:
                # Extract key = "value"; pairs
                for m_attr in ann_attr_pattern.finditer(stripped):
                    ann_attrs[m_attr.group(1)] = m_attr.group(2)
                i += 1
                continue
        
        # --- Check for annotation lines (before checking elements) ---
        # Single-line annotation: @Name { key = "value"; ... }
        m = single_line_ann_pattern.match(line)
        if m:
            a_name = m.group(1)
            a_body = m.group(2)
            a_attrs = {}
            for m_attr in ann_attr_pattern.finditer(a_body):
                a_attrs[m_attr.group(1)] = m_attr.group(2)
            pending_annotations.append((a_name, a_attrs))
            i += 1
            continue
        
        # Multi-line annotation start: @Name {
        m = multi_line_ann_start_pattern.match(line)
        if m:
            in_annotation = True
            ann_name = m.group(1)
            ann_attrs = {}
            i += 1
            continue
        
        # Skip comments (but don't clear pending annotations)
        if stripped.startswith("//"):
            i += 1
            continue
        
        # Skip blank lines (don't clear pending annotations)
        if not stripped:
            i += 1
            continue
        
        # Package
        m = pkg_pattern.match(line)
        if m:
            indent = len(m.group(1))
            pkg_name = m.group(2)
            # Adjust stack based on indent
            while package_stack and package_stack[-1][1] >= indent:
                package_stack.pop()
            package_stack.append((pkg_name, indent))
            # Package declarations don't consume pending annotations;
            # annotations are for the element that follows.
            i += 1
            continue
        
        current_package = package_stack[-1][0] if package_stack else ""
        
        # Part def
        m = part_def_pattern.match(line)
        if m:
            name = m.group(2)
            specialises = m.group(3) or ""
            doc = extract_doc_block(lines, i)
            
            # Find block end for attributes
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="part_def",
                name=name,
                parent_package=current_package,
                specialises=specialises,
                doc=doc,
                attributes=attrs,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            attach_annotations(elem)
            elements.append(elem)
            i += 1
            continue
        
        # Part usage (instantiation)
        m = part_usage_pattern.match(line)
        if m:
            name = m.group(2)
            type_ref = m.group(3)
            doc = extract_doc_block(lines, i)
            
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="part",
                name=name,
                parent_package=current_package,
                specialises=type_ref,
                doc=doc,
                attributes=attrs,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            attach_annotations(elem)
            elements.append(elem)
            i += 1
            continue
        
        # Enum def
        m = enum_def_pattern.match(line)
        if m:
            name = m.group(2)
            doc = extract_doc_block(lines, i)
            
            # Extract enum values
            block_end = find_block_end(lines, i) if '{' in line else i
            values = []
            for j in range(i + 1, block_end):
                val_line = lines[j].strip().rstrip(";")
                if val_line and not val_line.startswith("//") and not val_line.startswith("doc") and not val_line.startswith("*") and val_line != "}":
                    values.append({"name": val_line})
            
            elem = SysmlElement(
                kind="enum_def",
                name=name,
                parent_package=current_package,
                doc=doc,
                attributes=values,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            attach_annotations(elem)
            elements.append(elem)
            i += 1
            continue
        
        # Metadata def
        m = metadata_def_pattern.match(line)
        if m:
            name = m.group(2)
            doc = extract_doc_block(lines, i)
            
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="metadata_def",
                name=name,
                parent_package=current_package,
                doc=doc,
                attributes=attrs,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            attach_annotations(elem)
            elements.append(elem)
            i += 1
            continue
        
        # Requirement
        m = requirement_pattern.match(line)
        if m:
            name = m.group(2)
            type_ref = m.group(3)
            doc = extract_doc_block(lines, i)
            
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="requirement",
                name=name,
                parent_package=current_package,
                specialises=type_ref,
                doc=doc,
                attributes=attrs,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            attach_annotations(elem)
            elements.append(elem)
            i += 1
            continue
        
        # Unrecognised line — clear pending annotations to avoid
        # misattribution across unrelated content blocks
        if stripped and not stripped.startswith("doc") and not stripped.startswith("*"):
            pending_annotations = []
        
        i += 1
    
    return elements


# ---------------------------------------------------------------
# Meta model classification
# ---------------------------------------------------------------

def classify_meta_model_layer(elem):
    """Determine whether an element belongs to BMM, BSMM, domain, or unknown."""
    doc_lower = elem.doc.lower() if elem.doc else ""
    pkg = elem.parent_package
    
    # Check doc block markers first (most authoritative)
    for marker in BMM_MARKERS:
        if marker in doc_lower:
            return "bmm"
    for marker in BSMM_MARKERS:
        if marker in doc_lower:
            return "bsmm"
    
    # Check package membership
    if pkg in BMM_PACKAGES:
        return "bmm"
    if pkg in BSMM_PACKAGES:
        return "bsmm"
    if pkg in DOMAIN_PACKAGES:
        return "domain"
    
    # Part usages that instantiate a known meta model type
    if elem.kind == "part" and elem.specialises:
        type_name = elem.specialises.split("::")[-1]
        # These are BMM part defs
        bmm_types = {
            "CustomerSegment", "ServiceOffering", "Channel",
            "CatalogueEntry", "ActivityType", "ActivityGranularity",
            "ResourceType", "Capability", "CapacityModel",
            "ResourceConstraint", "RevenueStream", "CostDriver",
            "UnitEconomics", "PricingModel", "ScenarioDefinition",
            "ProjectionParameter", "GrowthAssumption", "ProjectionOutput",
            "ProjectionFormula", "BusinessModelVariant", "PivotScenario",
            "PeriodActuals", "VarianceAnalysis", "StrategicObjective",
            "ObjectiveCapabilityMapping", "ValueProposition",
            "DifferentiationClaim", "InventoryRecord", "ExternalReference",
        }
        # These are BSMM part defs
        bsmm_types = {
            "PersistencePolicy", "AgencyClassification",
            "GoalProjection", "Deficit",
            "Pattern", "ArchitecturalPrinciple", "DomainInstantiation",
        }
        if type_name in bmm_types:
            return "bmm_instance"
        if type_name in bsmm_types:
            return "bsmm_instance"
    
    return "unknown"


# ---------------------------------------------------------------
# Coverage matrix
# ---------------------------------------------------------------

def build_coverage_matrix(all_elements):
    """Build a matrix of which meta model defs are instantiated per domain."""
    
    # Find all part defs from BMM and BSMM
    meta_defs = {}
    for elem in all_elements:
        if elem.kind == "part_def" and elem.meta_model_layer in ("bmm", "bsmm"):
            meta_defs[elem.name] = {
                "name": elem.name,
                "layer": elem.meta_model_layer,
                "package": elem.parent_package,
                "doc": elem.doc[:200] if elem.doc else "",
                # Stage 2 Phase 2: include annotation data in coverage matrix
                "catalogueTag": elem.catalogue_tag if elem.catalogue_tag else {},
                "userFacing": elem.user_facing if elem.user_facing else {},
                "domains": {},
            }
    
    # Find all part usages and map them to their type's meta def
    for elem in all_elements:
        if elem.kind == "part" and elem.specialises:
            type_name = elem.specialises.split("::")[-1]
            if type_name in meta_defs:
                domain = elem.source_domain
                if domain not in meta_defs[type_name]["domains"]:
                    meta_defs[type_name]["domains"][domain] = []
                meta_defs[type_name]["domains"][domain].append({
                    "name": elem.name,
                    "package": elem.parent_package,
                })
    
    return meta_defs


# ---------------------------------------------------------------
# Stage 2 Phase 2: Facet and comprehension summaries
# ---------------------------------------------------------------

def build_facet_summary(all_elements):
    """Build a summary of all CatalogueTag dimensions and their value distributions.
    
    Scans all elements with catalogue_tag data and produces a facet index
    that the console can use to dynamically build 'group by' controls.
    """
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


def build_comprehension_summary(all_elements):
    """Summarise @UserFacing metadata coverage across catalogue-tagged elements.
    
    Reports how many tagged elements have friendly names and descriptions,
    and lists those that are missing — supporting incremental build-out
    of the comprehension layer.
    """
    tagged_elements = [e for e in all_elements if e.catalogue_tag]
    with_user_facing = [e for e in tagged_elements if e.user_facing]
    return {
        "catalogueTaggedCount": len(tagged_elements),
        "userFacingCount": len(with_user_facing),
        "coveragePercent": round(
            len(with_user_facing) / len(tagged_elements) * 100, 1
        ) if tagged_elements else 0,
        "missingUserFacing": [
            {"name": e.name, "package": e.parent_package}
            for e in tagged_elements if not e.user_facing
        ],
    }


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Ontara Model Introspection Generator")
    parser.add_argument("--save", action="store_true", help="Save JSON output")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON")
    args = parser.parse_args()
    
    all_elements = []
    
    # Parse all domains
    for domain_key, domain_info in DOMAIN_SOURCES.items():
        for model_dir in domain_info["model_dirs"]:
            if not model_dir.exists():
                print(f"  [skip] {model_dir} does not exist", file=sys.stderr)
                continue
            sysml_files = sorted(model_dir.rglob("*.sysml"))
            for f in sysml_files:
                # Skip test/spike files
                if any(pat in f.name for pat in EXCLUDE_PATTERNS):
                    print(f"  [skip] {f.name} (excluded)", file=sys.stderr)
                    continue
                elements = parse_sysml_file(f, domain_key)
                all_elements.extend(elements)
                if elements:
                    print(f"  [{domain_key}] {f.name}: {len(elements)} elements",
                          file=sys.stderr)
    
    # Classify meta model layer
    for elem in all_elements:
        elem.meta_model_layer = classify_meta_model_layer(elem)
    
    # Build coverage matrix
    coverage = build_coverage_matrix(all_elements)
    
    # Stage 2 Phase 2: build facet and comprehension summaries
    facets = build_facet_summary(all_elements)
    comprehension = build_comprehension_summary(all_elements)
    
    # Summary stats
    by_kind = defaultdict(int)
    by_layer = defaultdict(int)
    by_domain = defaultdict(int)
    for elem in all_elements:
        by_kind[elem.kind] += 1
        by_layer[elem.meta_model_layer] += 1
        by_domain[elem.source_domain] += 1
    
    print(f"\n=== Ontara Model Introspection ===", file=sys.stderr)
    print(f"Total elements: {len(all_elements)}", file=sys.stderr)
    print(f"By kind: {dict(by_kind)}", file=sys.stderr)
    print(f"By layer: {dict(by_layer)}", file=sys.stderr)
    print(f"By domain: {dict(by_domain)}", file=sys.stderr)
    print(f"Meta model defs in coverage: {len(coverage)}", file=sys.stderr)
    
    # Stage 2 Phase 2: annotation diagnostics
    print(f"\n--- Catalogue Metadata ---", file=sys.stderr)
    print(f"Elements with @CatalogueTag: {comprehension['catalogueTaggedCount']}",
          file=sys.stderr)
    print(f"Elements with @UserFacing: {comprehension['userFacingCount']}",
          file=sys.stderr)
    print(f"Comprehension coverage: {comprehension['coveragePercent']}%",
          file=sys.stderr)
    if facets:
        print(f"Facet dimensions:", file=sys.stderr)
        for dim, info in sorted(facets.items()):
            values_str = ", ".join(
                f"{v}:{info['counts'][v]}" for v in info["values"]
            )
            print(f"  {dim}: {values_str} (total: {info['total']})",
                  file=sys.stderr)
    if comprehension["missingUserFacing"]:
        print(f"Missing @UserFacing ({len(comprehension['missingUserFacing'])}):",
              file=sys.stderr)
        for item in comprehension["missingUserFacing"]:
            print(f"  {item['package']}::{item['name']}", file=sys.stderr)
    
    # Coverage summary
    print(f"\n--- Coverage Matrix ---", file=sys.stderr)
    for def_name, info in sorted(coverage.items()):
        domains = list(info["domains"].keys())
        counts = {d: len(info["domains"][d]) for d in domains}
        domain_str = ", ".join(f"{d}:{counts[d]}" for d in sorted(domains)) or "(no instances)"
        print(f"  {info['layer']:5s} {def_name:30s} {domain_str}", file=sys.stderr)
    
    # Build output JSON
    output = {
        "generatedAt": __import__("datetime").datetime.now().isoformat(),
        "generator": "gen_model_introspection.py",
        "domains": {
            key: {
                "label": info["label"],
                "description": info["description"],
                "elementCount": by_domain.get(key, 0),
            }
            for key, info in DOMAIN_SOURCES.items()
        },
        "summary": {
            "totalElements": len(all_elements),
            "byKind": dict(by_kind),
            "byLayer": dict(by_layer),
            "byDomain": dict(by_domain),
        },
        "facets": facets,
        "comprehension": comprehension,
        "coverageMatrix": coverage,
        "elements": [e.to_dict() for e in all_elements],
    }
    
    if args.save:
        GENERATED_DIR.mkdir(parents=True, exist_ok=True)
        out_path = GENERATED_DIR / "model-introspection.json"
        indent = 2 if args.pretty else None
        out_path.write_text(
            json.dumps(output, indent=indent, default=str),
            encoding="utf-8",
        )
        print(f"\nSaved: {out_path}", file=sys.stderr)
    else:
        # Print compact JSON to stdout
        print(json.dumps(output, indent=2, default=str))


if __name__ == "__main__":
    main()
