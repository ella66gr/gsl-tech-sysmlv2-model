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
  - Requirement defs and requirement usages
  - Constraint defs and constraint usages (Phase 6)
  - Satisfy relationships (Phase 6)
  - Cross-domain coverage matrix (which domains instantiate which defs)
  - @CatalogueTag and @UserFacing metadata annotations (Stage 2 Phase 2)
  - Facet summaries for dynamic catalogue grouping
  - Comprehension layer coverage tracking
  - Governance traceability (requirement → constraint → satisfy → evidence) (Phase 6)

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
    "cafe": {
        "label": "Cafe",
        "model_dirs": [EXERCISES_DIR / "coffeeshop-demonstrator" / "model"],
        "description": "Cafe demonstrator — reference validation domain",
    },
    "suds": {
        "label": "Suds",
        "model_dirs": [EXERCISES_DIR / "suds-demonstrator" / "model"],
        "description": "Laundry service demonstrator \u2014 cross-domain validation",
    },
    "paws": {
        "label": "Paws",
        "model_dirs": [EXERCISES_DIR / "paws-demonstrator" / "model"],
        "description": "Dog grooming demonstrator \u2014 appointment-based service validation",
    },
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
    "GovernanceMapping",
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
    "PawsBusinessModel", "PawsResourceFinancial", "PawsGovernance",
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
        self.purposive_description = {}  # {"description": "..."}
        self.comprehension = {}       # {"surfaceEnumValues": True, ...}
        self.weighted_relationships = []  # [{"target": "...", "strength": "...", "rationale": "..."}]
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
        if self.purposive_description:
            d["purposiveDescription"] = self.purposive_description
        if self.comprehension:
            d["comprehension"] = self.comprehension
        if self.weighted_relationships:
            d["weightedRelationships"] = self.weighted_relationships
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
    # Phase 6: governance traceability patterns
    requirement_def_pattern = re.compile(
        r'^(\s*)requirement\s+def\s+(\w+)(?:\s*\{)?'
    )
    constraint_def_pattern = re.compile(
        r'^(\s*)constraint\s+def\s+(\w+)(?:\s*\{)?'
    )
    constraint_usage_pattern = re.compile(
        r'^(\s*)constraint\s+(\w+)\s*:\s*(\w+(?:::\w+)*)'
    )
    satisfy_pattern = re.compile(
        r'^(\s*)satisfy\s+requirement\s+(\w+)\s*:\s*(\w+(?:::\w+)*)'
    )
    satisfy_by_pattern = re.compile(
        r'^\s*by\s+(\w+)\s*;'
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
    # Boolean attribute inside annotation: key = true; or key = false;
    ann_bool_pattern = re.compile(
        r'(\w+)\s*=\s*(true|false)\s*;'
    )
    # Enum literal attribute inside annotation: key = EnumDef::literal;
    ann_enum_pattern = re.compile(
        r'(\w+)\s*=\s*(\w+)::(\w+)\s*;'
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
            elif a_name == "PurposiveDescription":
                elem.purposive_description = dict(a_attrs)
            elif a_name == "Comprehension":
                # Convert string "true"/"false" to Python booleans
                elem.comprehension = {
                    k: (v if isinstance(v, bool) else str(v).lower() == "true")
                    for k, v in a_attrs.items()
                }
            elif a_name == "WeightedRelationship":
                # Accumulate — multiple annotations of this metaclass per element
                elem.weighted_relationships.append(dict(a_attrs))
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
                # Extract key = "value"; pairs (string attributes)
                for m_attr in ann_attr_pattern.finditer(stripped):
                    ann_attrs[m_attr.group(1)] = m_attr.group(2)
                # Extract key = true/false; pairs (boolean attributes)
                for m_bool in ann_bool_pattern.finditer(stripped):
                    if m_bool.group(1) not in ann_attrs:  # don't override string match
                        ann_attrs[m_bool.group(1)] = m_bool.group(2) == "true"
                # Extract key = EnumDef::literal; pairs (enum attributes)
                for m_enum in ann_enum_pattern.finditer(stripped):
                    if m_enum.group(1) not in ann_attrs:  # don't override string/bool match
                        ann_attrs[m_enum.group(1)] = m_enum.group(3)  # store the literal value
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
            for m_bool in ann_bool_pattern.finditer(a_body):
                if m_bool.group(1) not in a_attrs:
                    a_attrs[m_bool.group(1)] = m_bool.group(2) == "true"
            for m_enum in ann_enum_pattern.finditer(a_body):
                if m_enum.group(1) not in a_attrs:
                    a_attrs[m_enum.group(1)] = m_enum.group(3)
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
                # Strip inline comments (e.g. "serviceDelivery     // description")
                if "//" in val_line:
                    val_line = val_line[:val_line.index("//")].strip()
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
        
        # Phase 6: Requirement def
        m = requirement_def_pattern.match(line)
        if m:
            name = m.group(2)
            doc = extract_doc_block(lines, i)
            
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="requirement_def",
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
        
        # Phase 6: Constraint def
        m = constraint_def_pattern.match(line)
        if m:
            name = m.group(2)
            doc = extract_doc_block(lines, i)
            
            block_end = i
            if '{' in line:
                block_end = find_block_end(lines, i)
            attrs = parse_attributes(lines, i + 1, block_end)
            
            elem = SysmlElement(
                kind="constraint_def",
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
        
        # Phase 6: Constraint usage
        m = constraint_usage_pattern.match(line)
        if m:
            name = m.group(2)
            type_ref = m.group(3)
            
            elem = SysmlElement(
                kind="constraint",
                name=name,
                parent_package=current_package,
                specialises=type_ref,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            elements.append(elem)
            i += 1
            continue
        
        # Phase 6: Satisfy relationship
        m = satisfy_pattern.match(line)
        if m:
            satisfy_name = m.group(2)
            req_def = m.group(3)
            # Look ahead for "by constraintUsage;" on next non-blank line
            by_target = ""
            for j in range(i + 1, min(i + 5, len(lines))):
                by_m = satisfy_by_pattern.match(lines[j])
                if by_m:
                    by_target = by_m.group(1)
                    break
                elif lines[j].strip() and not lines[j].strip().startswith("//"):
                    break
            
            elem = SysmlElement(
                kind="satisfy",
                name=satisfy_name,
                parent_package=current_package,
                specialises=req_def,
                source_file=rel_path,
                source_domain=domain_key,
                line_number=i + 1,
            )
            # Store the by-target in attributes for downstream use
            if by_target:
                elem.attributes = [{"name": "byTarget", "value": by_target}]
            elements.append(elem)
            pending_annotations = []  # satisfy doesn't take annotations
            i += 1
            continue
        
        # Requirement usage (typed)
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
            "AuditEvidenceRecord", "ActivityCostAllocation",
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
    
    # Find all part defs and requirement defs from BMM and BSMM
    meta_defs = {}
    for elem in all_elements:
        if elem.kind in ("part_def", "requirement_def") and elem.meta_model_layer in ("bmm", "bsmm"):
            meta_defs[elem.name] = {
                "name": elem.name,
                "layer": elem.meta_model_layer,
                "package": elem.parent_package,
                "doc": elem.doc[:200] if elem.doc else "",
                # Stage 2 Phase 2: include annotation data in coverage matrix
                "catalogueTag": elem.catalogue_tag if elem.catalogue_tag else {},
                "userFacing": elem.user_facing if elem.user_facing else {},
                "purposiveDescription": elem.purposive_description if elem.purposive_description else {},
                "comprehension": elem.comprehension if elem.comprehension else {},
                "weightedRelationships": elem.weighted_relationships if elem.weighted_relationships else [],
                "domains": {},
            }
    
    # Find all part usages and requirement usages, map to their type's meta def
    for elem in all_elements:
        if elem.kind in ("part", "requirement") and elem.specialises:
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
    with_purposive = [e for e in tagged_elements if e.purposive_description]
    with_comprehension = [e for e in tagged_elements if e.comprehension]
    return {
        "catalogueTaggedCount": len(tagged_elements),
        "userFacingCount": len(with_user_facing),
        "purposiveDescriptionCount": len(with_purposive),
        "comprehensionAnnotationCount": len(with_comprehension),
        "coveragePercent": round(
            len(with_user_facing) / len(tagged_elements) * 100, 1
        ) if tagged_elements else 0,
        "purposiveCoveragePercent": round(
            len(with_purposive) / len(tagged_elements) * 100, 1
        ) if tagged_elements else 0,
        "missingUserFacing": [
            {"name": e.name, "package": e.parent_package}
            for e in tagged_elements if not e.user_facing
        ],
        "missingPurposiveDescription": [
            {"name": e.name, "package": e.parent_package}
            for e in tagged_elements if not e.purposive_description
        ],
    }


# ---------------------------------------------------------------
# Stage 3 Phase 3: Comprehension traversal discovery
# ---------------------------------------------------------------

def build_comprehension_content(all_elements, coverage_matrix):
    """Build dynamically assembled comprehension content for annotated elements.
    
    For each element with a @Comprehension annotation, executes the traversal
    instructions declared by the boolean flags and produces structured content
    from live model state.
    
    Stage 3 Phase 3 Step 3 — intrinsic self-knowledge (A10).
    3b approach: declarative flags with smart generator (S49-D4).
    """
    # Build lookup indices
    enum_index = {}     # enum_def name -> list of value names
    package_index = defaultdict(list)  # package name -> list of (kind, name, user_facing)
    
    for elem in all_elements:
        if elem.kind == "enum_def":
            enum_index[elem.name] = [
                v["name"] for v in elem.attributes
                if isinstance(v, dict) and "name" in v
            ]
        if elem.kind in ("part_def", "requirement_def") and elem.catalogue_tag:
            package_index[elem.parent_package].append({
                "name": elem.name,
                "kind": elem.kind,
                "friendlyName": elem.user_facing.get("friendlyName", "") if elem.user_facing else "",
                "layer": elem.meta_model_layer,
            })
    
    content = {}
    
    for elem in all_elements:
        if not elem.comprehension:
            continue
        
        flags = elem.comprehension
        entry = {"flags": flags}
        
        # --- surfaceEnumValues ---
        if flags.get("surfaceEnumValues"):
            enum_values = []
            seen_enums = set()  # Deduplicate by enum def name
            for attr in elem.attributes:
                if not isinstance(attr, dict):
                    continue
                attr_type = attr.get("type", "")
                if attr_type in enum_index and attr_type not in seen_enums:
                    seen_enums.add(attr_type)
                    enum_values.append({
                        "enumName": attr_type,
                        "attributeName": attr.get("name", ""),
                        "values": enum_index[attr_type],
                    })
            if enum_values:
                entry["enumValues"] = enum_values
        
        # --- surfaceDomainInstantiations ---
        if flags.get("surfaceDomainInstantiations"):
            cov = coverage_matrix.get(elem.name, {})
            domains_data = cov.get("domains", {})
            domain_surface = {}
            for dk, instances in domains_data.items():
                domain_surface[dk] = {
                    "count": len(instances),
                    "instances": [inst["name"] for inst in instances],
                }
            if domain_surface:
                entry["domainInstantiations"] = domain_surface
        
        # --- surfaceRelatedConcepts ---
        if flags.get("surfaceRelatedConcepts"):
            # Build weight lookup from @WeightedRelationship annotations
            weight_lookup = {}
            for wr in elem.weighted_relationships:
                target_name = wr.get("target", "")
                weight_lookup[target_name] = {
                    "strength": wr.get("strength", ""),
                    "rationale": wr.get("rationale", ""),
                }
            
            siblings = []
            for sib in package_index.get(elem.parent_package, []):
                if sib["name"] != elem.name and sib["layer"] == elem.meta_model_layer:
                    sib_entry = {
                        "name": sib["name"],
                        "friendlyName": sib["friendlyName"],
                    }
                    # Merge weight data if available
                    if sib["name"] in weight_lookup:
                        sib_entry["strength"] = weight_lookup[sib["name"]]["strength"]
                        sib_entry["rationale"] = weight_lookup[sib["name"]]["rationale"]
                    siblings.append(sib_entry)
            
            # Sort by weight: strong first, then moderate, then weak, then contextual, then unweighted
            strength_order = {"strong": 0, "moderate": 1, "weak": 2, "contextual": 3}
            siblings.sort(key=lambda s: strength_order.get(s.get("strength", ""), 99))
            
            if siblings:
                entry["relatedConcepts"] = siblings
        
        # --- surfaceAttributes ---
        if flags.get("surfaceAttributes"):
            attr_surface = [
                {
                    "name": attr.get("name", ""),
                    "type": attr.get("type", "String"),
                }
                for attr in elem.attributes
                if isinstance(attr, dict) and "type" in attr
            ]
            if attr_surface:
                entry["attributes"] = attr_surface
        
        content[elem.name] = entry
    
    return content


# ---------------------------------------------------------------
# Stage 4 Phase 1: Weighted relationship graph
# ---------------------------------------------------------------

def build_weighted_relationship_graph(all_elements, coverage_matrix):
    """Build a dedicated graph data structure from all @WeightedRelationship annotations.

    Produces a nodes/edges/stats structure suitable for D3.js force-directed
    graph rendering in the console Relationships view.

    Stage 4 Phase 1 — Session 72.
    """
    # Build a lookup of catalogue-tagged elements by name
    catalogue_elements = {}
    for elem in all_elements:
        if elem.catalogue_tag and elem.kind in ("part_def", "requirement_def"):
            catalogue_elements[elem.name] = elem

    # Collect all edges from weighted_relationships
    edges = []
    target_names = set()
    source_names = set()
    for elem in all_elements:
        if not elem.weighted_relationships:
            continue
        if not elem.catalogue_tag:
            continue
        source_names.add(elem.name)
        for wr in elem.weighted_relationships:
            target = wr.get("target", "")
            if target:
                edges.append({
                    "source": elem.name,
                    "target": target,
                    "strength": wr.get("strength", ""),
                    "rationale": wr.get("rationale", ""),
                })
                target_names.add(target)

    # Nodes: all catalogue elements that are sources OR targets
    node_names = source_names | (target_names & set(catalogue_elements.keys()))
    nodes = []
    for name in sorted(node_names):
        elem = catalogue_elements.get(name)
        if not elem:
            continue
        # Get short description from user_facing
        short_desc = ""
        if elem.user_facing:
            short_desc = elem.user_facing.get("shortDescription", "")
        nodes.append({
            "id": elem.name,
            "friendlyName": elem.user_facing.get("friendlyName", elem.name) if elem.user_facing else elem.name,
            "bmmConcern": elem.catalogue_tag.get("bmmConcern", ""),
            "classification": elem.catalogue_tag.get("classification", ""),
            "package": elem.parent_package,
            "shortDescription": short_desc,
        })

    # Compute stats
    strength_counts = {"strong": 0, "moderate": 0, "weak": 0}
    for edge in edges:
        s = edge["strength"]
        if s in strength_counts:
            strength_counts[s] += 1

    # Count bidirectional pairs
    edge_set = set()
    for edge in edges:
        edge_set.add((edge["source"], edge["target"]))
    bidirectional_count = 0
    counted = set()
    for (s, t) in edge_set:
        pair = tuple(sorted([s, t]))
        if pair not in counted and (t, s) in edge_set:
            bidirectional_count += 1
            counted.add(pair)

    return {
        "nodes": nodes,
        "edges": edges,
        "stats": {
            "nodeCount": len(nodes),
            "edgeCount": len(edges),
            "strongCount": strength_counts["strong"],
            "moderateCount": strength_counts["moderate"],
            "weakCount": strength_counts["weak"],
            "bidirectionalPairCount": bidirectional_count,
        },
    }


# ---------------------------------------------------------------
# Session 88: Architectural sections
# ---------------------------------------------------------------

def build_architectural_sections(all_elements):
    """Build the architecturalSections array from ArchitecturalSection part usages.

    Extracts structural attributes and metadata annotations from the 20
    architectural section instances, producing the JSON structure for the
    console's Architecture view.

    Session 88 — B27 (architectural section), J2 (co-evolution).
    """
    sections = []

    for elem in all_elements:
        if elem.kind != "part":
            continue
        # Match ArchitecturalSection type (with or without package prefix)
        type_name = elem.specialises.split("::")[-1] if elem.specialises else ""
        if type_name != "ArchitecturalSection":
            continue

        # Extract redefined attribute values
        attr_values = {}
        for attr in elem.attributes:
            if isinstance(attr, dict) and attr.get("isRedefinition"):
                attr_values[attr["name"]] = attr["value"]

        # Extract @PurposiveDescription
        purposive_desc = ""
        if elem.purposive_description:
            purposive_desc = elem.purposive_description.get("description", "")

        # Extract @ArchitecturalLocation from annotations list
        arch_location = {}
        for ann in elem.annotations:
            if ann.get("name") == "ArchitecturalLocation":
                arch_location = ann.get("attrs", {})
                break

        # Extract @UserFacing
        friendly_name = ""
        short_desc = ""
        if elem.user_facing:
            friendly_name = elem.user_facing.get("friendlyName", "")
            short_desc = elem.user_facing.get("shortDescription", "")

        # Parse presentationOrder as integer
        try:
            order = int(attr_values.get("presentationOrder", "0"))
        except (ValueError, TypeError):
            order = 0

        section = {
            "name": attr_values.get("name", elem.name),
            "displayName": attr_values.get("displayName", friendly_name or elem.name),
            "group": attr_values.get("group", ""),
            "presentationOrder": order,
            "primaryFormalism": attr_values.get("primaryFormalism", ""),
            "persistenceMechanism": attr_values.get("persistenceMechanism", ""),
            "implementationStatus": attr_values.get("implementationStatus", ""),
            "purposiveDescription": purposive_desc,
            "friendlyName": friendly_name,
            "shortDescription": short_desc,
            "representationalModalitySummary": arch_location.get("representationalModalitySummary", ""),
            "persistenceSummary": arch_location.get("persistenceSummary", ""),
            "interfacesSummary": arch_location.get("interfacesSummary", ""),
            "domainIllustrationSummary": arch_location.get("domainIllustrationSummary", ""),
            "docKey": attr_values.get("docKey", ""),
        }
        sections.append(section)

    # Sort by presentationOrder
    sections.sort(key=lambda s: s["presentationOrder"])
    return sections


# ---------------------------------------------------------------
# Stage 2 Phase 6: Governance traceability
# ---------------------------------------------------------------

def build_governance_traceability(all_elements):
    """Build the governance traceability structure from extracted elements.
    
    Assembles requirement defs, constraint defs, satisfy chains,
    requirement instances, and audit evidence instances into a
    structure the console can use for the governance traceability view.
    """
    requirement_defs = []
    constraint_defs = []
    satisfy_chains = []
    requirement_instances = []
    audit_evidence_instances = []
    
    for elem in all_elements:
        if elem.kind == "requirement_def":
            requirement_defs.append({
                "name": elem.name,
                "package": elem.parent_package,
                "layer": elem.meta_model_layer,
                "doc": elem.doc[:300] if elem.doc else "",
                "attributes": elem.attributes,
                "catalogueTag": elem.catalogue_tag if elem.catalogue_tag else {},
                "userFacing": elem.user_facing if elem.user_facing else {},
                "purposiveDescription": elem.purposive_description if elem.purposive_description else {},
            })
        
        elif elem.kind == "constraint_def":
            constraint_defs.append({
                "name": elem.name,
                "package": elem.parent_package,
                "sourceDomain": elem.source_domain,
                "doc": elem.doc[:300] if elem.doc else "",
                "attributes": elem.attributes,
            })
        
        elif elem.kind == "satisfy":
            by_target = ""
            if elem.attributes:
                for attr in elem.attributes:
                    if attr.get("name") == "byTarget":
                        by_target = attr.get("value", "")
            
            # Resolve the constraint def from the by-target
            constraint_def_name = ""
            for other in all_elements:
                if other.kind == "constraint" and other.name == by_target:
                    constraint_def_name = other.specialises.split("::")[-1] if other.specialises else ""
                    break
            
            satisfy_chains.append({
                "satisfyName": elem.name,
                "requirementDef": elem.specialises.split("::")[-1] if elem.specialises else "",
                "constraintUsage": by_target,
                "constraintDef": constraint_def_name,
                "sourceDomain": elem.source_domain,
                "package": elem.parent_package,
            })
        
        elif elem.kind == "requirement" and elem.specialises:
            type_name = elem.specialises.split("::")[-1]
            requirement_instances.append({
                "name": elem.name,
                "typedBy": type_name,
                "sourceDomain": elem.source_domain,
                "package": elem.parent_package,
                "doc": elem.doc[:300] if elem.doc else "",
                "attributes": elem.attributes,
            })
        
        elif elem.kind == "part" and elem.specialises:
            type_name = elem.specialises.split("::")[-1]
            if type_name == "AuditEvidenceRecord":
                audit_evidence_instances.append({
                    "name": elem.name,
                    "typedBy": type_name,
                    "sourceDomain": elem.source_domain,
                    "package": elem.parent_package,
                    "doc": elem.doc[:300] if elem.doc else "",
                    "attributes": elem.attributes,
                })
    
    return {
        "requirementDefs": requirement_defs,
        "constraintDefs": constraint_defs,
        "satisfyChains": satisfy_chains,
        "requirementInstances": requirement_instances,
        "auditEvidenceInstances": audit_evidence_instances,
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
    
    # Stage 3 Phase 3: build comprehension content from traversal discovery
    comprehension_content = build_comprehension_content(all_elements, coverage)
    
    # Stage 2 Phase 6: build governance traceability
    governance = build_governance_traceability(all_elements)

    # Stage 4 Phase 1: build weighted relationship graph
    relationship_graph = build_weighted_relationship_graph(all_elements, coverage)

    # Session 88: build architectural sections
    architectural_sections = build_architectural_sections(all_elements)

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
    print(f"Elements with @PurposiveDescription: {comprehension['purposiveDescriptionCount']}",
          file=sys.stderr)
    print(f"@UserFacing coverage: {comprehension['coveragePercent']}%",
          file=sys.stderr)
    print(f"@PurposiveDescription coverage: {comprehension['purposiveCoveragePercent']}%",
          file=sys.stderr)
    if facets:
        print(f"Facet dimensions:", file=sys.stderr)
        for dim, info in sorted(facets.items()):
            values_str = ", ".join(
                f"{v}:{info['counts'][v]}" for v in info["values"]
            )
            print(f"  {dim}: {values_str} (total: {info['total']})",
                  file=sys.stderr)
    print(f"Elements with @Comprehension: {comprehension['comprehensionAnnotationCount']}",
          file=sys.stderr)
    if comprehension_content:
        print(f"Comprehension content generated for: {', '.join(sorted(comprehension_content.keys()))}",
              file=sys.stderr)
    
    # Weight diagnostics
    weighted_elements = [e for e in all_elements if e.weighted_relationships]
    total_weights = sum(len(e.weighted_relationships) for e in weighted_elements)
    if weighted_elements:
        print(f"Elements with @WeightedRelationship: {len(weighted_elements)} ({total_weights} relationships)",
              file=sys.stderr)
        for elem in weighted_elements:
            for wr in elem.weighted_relationships:
                print(f"  {elem.name} -> {wr.get('target', '?')}: {wr.get('strength', '?')}",
                      file=sys.stderr)
    if comprehension["missingUserFacing"]:
        print(f"Missing @UserFacing ({len(comprehension['missingUserFacing'])}):",
              file=sys.stderr)
        for item in comprehension["missingUserFacing"]:
            print(f"  {item['package']}::{item['name']}", file=sys.stderr)
    
    # Phase 6: governance traceability diagnostics
    print(f"\n--- Governance Traceability ---", file=sys.stderr)
    print(f"Requirement defs: {len(governance['requirementDefs'])}", file=sys.stderr)
    print(f"Constraint defs: {len(governance['constraintDefs'])}", file=sys.stderr)
    print(f"Satisfy chains: {len(governance['satisfyChains'])}", file=sys.stderr)
    print(f"Requirement instances: {len(governance['requirementInstances'])}", file=sys.stderr)
    print(f"Audit evidence instances: {len(governance['auditEvidenceInstances'])}", file=sys.stderr)
    for chain in governance['satisfyChains']:
        print(f"  {chain['satisfyName']}: {chain['requirementDef']} -> {chain['constraintUsage']} ({chain['constraintDef']})",
              file=sys.stderr)
    
    # Stage 4 Phase 1: relationship graph diagnostics
    rg_stats = relationship_graph["stats"]
    print(f"\n--- Weighted Relationship Graph ---", file=sys.stderr)
    print(f"Nodes: {rg_stats['nodeCount']}, Edges: {rg_stats['edgeCount']}", file=sys.stderr)
    print(f"Strong: {rg_stats['strongCount']}, Moderate: {rg_stats['moderateCount']}, Weak: {rg_stats['weakCount']}", file=sys.stderr)
    print(f"Bidirectional pairs: {rg_stats['bidirectionalPairCount']}", file=sys.stderr)

    # Session 88: architectural sections diagnostics
    print(f"\n--- Architectural Sections ---", file=sys.stderr)
    print(f"Sections found: {len(architectural_sections)}", file=sys.stderr)
    for section in architectural_sections:
        print(f"  {section['presentationOrder']:2d}. {section['displayName']} [{section['group']}] ({section['implementationStatus']})",
              file=sys.stderr)

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
        "governanceTraceability": governance,
        "coverageMatrix": coverage,
        "comprehensionContent": comprehension_content,
        "weightedRelationshipGraph": relationship_graph,
        "architecturalSections": architectural_sections,  # NEW — Session 88
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
