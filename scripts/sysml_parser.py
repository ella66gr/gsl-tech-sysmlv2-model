#!/usr/bin/env python3
"""
Ontara SysML v2 Parser — Shared Module
========================================

Reusable SysML v2 text parser extracted from gen_model_introspection.py.
Used by:
  - gen_model_introspection.py (console data generation)
  - gen_owl_pipeline.py (OWL/RDF generation — Session 105)

Extracts: part defs, part usages, enum defs, metadata defs,
requirement defs, constraint defs, satisfy relationships,
and all prefix metadata annotations (@CatalogueTag, @UserFacing,
@PurposiveDescription, @Comprehension, @WeightedRelationship,
@BfoType, @ArchitecturalLocation, and any future annotations).

No external dependencies — pure Python standard library.

Source: Extracted Session 104 (Stage 5 Phase 1 Step 3).
"""

import re
from typing import Optional


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
        self.meta_model_layer = ""    # "bmm", "smm", "domain", "unknown"
        # Stage 2 Phase 2: metadata annotation data
        self.catalogue_tag = {}       # {"bmmConcern": "...", "classification": "..."}
        self.user_facing = {}         # {"friendlyName": "...", "shortDescription": "..."}
        self.purposive_description = {}  # {"description": "..."}
        self.comprehension = {}       # {"surfaceEnumValues": True, ...}
        self.weighted_relationships = []  # [{"target": "...", "strength": "...", "rationale": "..."}]
        self.annotations = []         # all prefix annotations for future extensibility
        self.bfo_type = {}            # {"bfoClass": "...", "midLevelClass": "...", "midLevelOntology": "..."}

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
        if self.bfo_type:
            d["bfoType"] = self.bfo_type
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


def parse_sysml_file(filepath, domain_key, repo_root=None):
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

    if repo_root is not None:
        rel_path = str(filepath.relative_to(repo_root))
    else:
        rel_path = str(filepath)

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
            elif a_name == "BfoType":
                elem.bfo_type = dict(a_attrs)
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
