#!/usr/bin/env python3
"""
GenderSense System Model Manifest Generator
=============================================

Reads all .sysml files in the model and produces a comprehensive JSON
manifest capturing the structural content of the SysML model. This is
the Layer 1 (structural self-knowledge) artefact described in the
architecture decision document, Section 2.

Output:
    generated/system-manifest.json

The manifest enables the running system to answer questions like:
"what pathways exist?", "what constraints apply to hormone therapy?",
"what requirements does this constraint satisfy?"

Usage:
    cd ~/Developer/gsl-tech/gsl-sysml-model
    python3 scripts/gen_system_manifest.py

No dependencies — pure Python standard library.

Phase 5, Stage 4 of Knowledge Layer Elaboration.
"""

import json
import pathlib
import re
import sys
import datetime

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
LIBRARY_DIR = REPO_ROOT / "libraries"
GENERATED_DIR = REPO_ROOT / "generated"


# ---------------------------------------------------------------
# Generic parsers
# ---------------------------------------------------------------

def find_package_block(text, package_name):
    """Find the content of a named package block. Returns (start_pos, body) or None."""
    pattern = rf'\bpackage\s+{re.escape(package_name)}\s*\{{'
    match = re.search(pattern, text)
    if not match:
        return None

    start = match.end()
    depth = 1
    i = start
    while i < len(text) and depth > 0:
        if text[i] == '{':
            depth += 1
        elif text[i] == '}':
            depth -= 1
        i += 1

    return text[start:i - 1]


def extract_doc_block(text):
    """Extract the first doc block from a text fragment. Returns cleaned text."""
    doc_match = re.search(r'doc\s*/\*(.+?)\*/', text, re.DOTALL)
    if not doc_match:
        return ""
    raw = doc_match.group(1)
    lines = []
    for line in raw.split('\n'):
        cleaned = line.strip().lstrip('*').strip()
        if cleaned:
            lines.append(cleaned)
    return ' '.join(lines)


def first_sentence(text):
    """Extract the first sentence (up to first period-space or first 120 chars)."""
    if not text:
        return ""
    # Find first ". " or end
    idx = text.find('. ')
    if idx >= 0 and idx < 120:
        return text[:idx + 1]
    return text[:120]


def extract_blocks(text, keyword):
    """Extract all blocks of a given type (e.g. 'constraint def', 'part def').

    Returns a list of dicts: {name, body, doc}
    """
    blocks = []
    pattern = rf'{re.escape(keyword)}\s+(\w+)\s*(?::>\s*\w+\s*)?\{{'
    for match in re.finditer(pattern, text):
        name = match.group(1)
        start = match.end()
        depth = 1
        i = start
        while i < len(text) and depth > 0:
            if text[i] == '{':
                depth += 1
            elif text[i] == '}':
                depth -= 1
            i += 1
        body = text[start:i - 1]
        doc = extract_doc_block(body)
        blocks.append({'name': name, 'body': body, 'doc': doc})
    return blocks


# ---------------------------------------------------------------
# Inventory extractors
# ---------------------------------------------------------------

def extract_constraint_inventory(knowledge_text):
    """Extract constraint defs from ConstraintLibrary."""
    lib_text = find_package_block(knowledge_text, "ConstraintLibrary")
    if not lib_text:
        return []

    constraints = []
    for block in extract_blocks(lib_text, "constraint def"):
        # Extract inputs
        inputs = []
        for inp_match in re.finditer(r'\bin\s+(\w+)\s*:\s*(\w+)\s*;', block['body']):
            inputs.append({'name': inp_match.group(1), 'type': inp_match.group(2)})

        # Extract satisfy target
        satisfies = None

        constraints.append({
            'name': block['name'],
            'package': 'Knowledge::ConstraintLibrary',
            'inputs': inputs,
            'description': first_sentence(block['doc']),
        })

    # Find satisfy relationships
    usage_to_def = {}
    for usage_match in re.finditer(r'constraint\s+(\w+)\s*:\s*(\w+)\s*;', lib_text):
        usage_to_def[usage_match.group(1)] = usage_match.group(2)

    for sat_match in re.finditer(r'satisfy\s+requirement\s+([\w:]+)\s*\n\s*by\s+(\w+)\s*;', lib_text):
        req_name = sat_match.group(1).split('::')[-1]
        usage_name = sat_match.group(2)
        def_name = usage_to_def.get(usage_name)
        if def_name:
            for c in constraints:
                if c['name'] == def_name:
                    c['satisfies'] = req_name
                    break

    # Cross-reference with evaluation specs for severity
    cds_text = find_package_block(knowledge_text, "ClinicalDecisionSupport")
    if cds_text:
        for match in re.finditer(
            r'part\s+(\w+)\s*:\s*ConstraintEvaluationSpec\s*\{',
            cds_text
        ):
            start = match.end()
            depth = 1
            i = start
            while i < len(cds_text) and depth > 0:
                if cds_text[i] == '{': depth += 1
                elif cds_text[i] == '}': depth -= 1
                i += 1
            body = cds_text[start:i - 1]

            cn_match = re.search(r'attribute\s+:>>\s+constraintName\s*=\s*"([^"]+)"', body)
            sev_match = re.search(r'attribute\s+:>>\s+severity\s*=\s*\w+::(\w+)', body)
            if cn_match and sev_match:
                for c in constraints:
                    if c['name'] == cn_match.group(1):
                        c['severity'] = sev_match.group(1)
                        c['evaluationSpec'] = match.group(1)
                        break

    return constraints


def extract_requirement_inventory(enterprise_text):
    """Extract requirement defs from Enterprise::Regulation."""
    reg_text = find_package_block(enterprise_text, "Regulation")
    if not reg_text:
        return []

    requirements = []
    for block in extract_blocks(reg_text, "requirement def"):
        requirements.append({
            'name': block['name'],
            'package': 'Enterprise::Regulation',
            'description': first_sentence(block['doc']),
        })
    return requirements


def extract_entity_lifecycle_inventory(sd_text):
    """Extract state defs from ServiceDelivery::ClinicalEntities."""
    entities_text = find_package_block(sd_text, "ClinicalEntities")
    if not entities_text:
        return []

    lifecycles = []
    for block in extract_blocks(entities_text, "state def"):
        # Extract states
        states = []
        for state_match in re.finditer(r'(?<!initial\s)\bstate\s+(\w+)\s*;', block['body']):
            states.append(state_match.group(1))

        # Extract transitions to identify terminal states
        sources = set()
        for trans_match in re.finditer(
            r'transition\s+\w+\s+first\s+(\w+)\s+accept\s+\w+\s+then\s+\w+\s*;',
            block['body']
        ):
            sources.add(trans_match.group(1))

        terminal_states = [s for s in states if s not in sources]

        lifecycles.append({
            'name': block['name'],
            'package': 'ServiceDelivery::ClinicalEntities',
            'states': states,
            'terminalStates': terminal_states,
        })
    return lifecycles


def extract_pathway_inventory(sd_text):
    """Extract action defs from ServiceDelivery::ClinicalPathways."""
    pathways_text = find_package_block(sd_text, "ClinicalPathways")
    if not pathways_text:
        return []

    # Also check sub-packages
    pathways = []

    for block in extract_blocks(pathways_text, "action def"):
        # Count action steps (action name; or action name { ... })
        step_count = len(re.findall(r'\baction\s+\w+', block['body']))

        # Find metadata annotations
        annotations = set()
        for ann_match in re.finditer(r'@(\w+)\s*\{', block['body']):
            annotations.add(f"@{ann_match.group(1)}")

        # Determine type from naming convention
        action_type = 'domain'
        if 'Orchestration' in block['name']:
            action_type = 'orchestration'

        pathways.append({
            'name': block['name'],
            'package': 'ServiceDelivery::ClinicalPathways',
            'type': action_type,
            'stepCount': step_count,
            'metadataAnnotations': sorted(annotations),
            'description': first_sentence(block['doc']),
        })

    return pathways


def extract_outcome_inventory(knowledge_text):
    """Extract outcome definitions from Knowledge::OutcomeFramework."""
    of_text = find_package_block(knowledge_text, "OutcomeFramework")
    if not of_text:
        return []

    outcomes = []

    # Find part usages of type OutcomeDefinition with :>> redefinitions
    for match in re.finditer(r'part\s+(\w+)\s*:\s*OutcomeDefinition\s*\{', of_text):
        usage_name = match.group(1)
        start = match.end()
        depth = 1
        i = start
        while i < len(of_text) and depth > 0:
            if of_text[i] == '{': depth += 1
            elif of_text[i] == '}': depth -= 1
            i += 1
        body = of_text[start:i - 1]

        outcome = {'usageName': usage_name, 'package': 'Knowledge::OutcomeFramework'}

        # Extract :>> string values
        for sv_match in re.finditer(r'attribute\s+:>>\s+(\w+)\s*=\s*"([^"]+)"', body):
            outcome[sv_match.group(1)] = sv_match.group(2)

        # Extract :>> enum values
        for ev_match in re.finditer(r'attribute\s+:>>\s+(\w+)\s*=\s*\w+::(\w+)', body):
            outcome[ev_match.group(1)] = ev_match.group(2)

        outcomes.append(outcome)

    return outcomes


def extract_metadata_inventory(foundation_text, library_texts):
    """Extract metadata defs from MetadataLibrary and TemporalMetadata."""
    metadata = []

    # Foundation::MetadataLibrary
    ml_text = find_package_block(foundation_text, "MetadataLibrary")
    if ml_text:
        for block in extract_blocks(ml_text, "metadata def"):
            attrs = []
            for attr_match in re.finditer(r'attribute\s+(\w+)\s*:\s*(\w+)\s*;', block['body']):
                attrs.append(attr_match.group(1))
            metadata.append({
                'name': block['name'],
                'package': 'Foundation::MetadataLibrary',
                'attributes': attrs,
            })

    # TemporalMetadata library
    for lib_text in library_texts:
        tm_text = find_package_block(lib_text, "TemporalMetadata")
        if tm_text:
            for block in extract_blocks(tm_text, "metadata def"):
                attrs = []
                for attr_match in re.finditer(r'attribute\s+(\w+)\s*:\s*(\w+)\s*;', block['body']):
                    attrs.append(attr_match.group(1))
                metadata.append({
                    'name': block['name'],
                    'package': 'TemporalMetadata',
                    'attributes': attrs,
                })

    return metadata


def extract_use_case_inventory(all_texts):
    """Extract all use case defs across all model files."""
    use_cases = []
    for filename, text in all_texts.items():
        for match in re.finditer(r'use\s+case\s+def\s+(\w+)\s*\{', text):
            name = match.group(1)
            start = match.end()
            depth = 1
            i = start
            while i < len(text) and depth > 0:
                if text[i] == '{': depth += 1
                elif text[i] == '}': depth -= 1
                i += 1
            body = text[start:i - 1]
            doc = extract_doc_block(body)

            use_cases.append({
                'name': name,
                'source': filename,
                'description': first_sentence(doc),
            })
    return use_cases


def extract_decision_table_inventory(knowledge_text):
    """Extract decision table metadata from DecisionModels."""
    dm_text = find_package_block(knowledge_text, "DecisionModels")
    if not dm_text:
        return []

    tables = []
    for match in re.finditer(r'part\s+def\s+(\w+)\s*:>\s*DecisionTableDef\s*\{', dm_text):
        table_name = match.group(1)
        start = match.end()
        depth = 1
        i = start
        while i < len(dm_text) and depth > 0:
            if dm_text[i] == '{': depth += 1
            elif dm_text[i] == '}': depth -= 1
            i += 1
        body = dm_text[start:i - 1]

        tn_match = re.search(r'attribute\s+:>>\s+tableName\s*=\s*"([^"]+)"', body)
        hp_match = re.search(r'attribute\s+:>>\s+hitPolicy\s*=\s*\w+::(\w+)', body)

        # Count rows
        row_count = len(re.findall(r'part\s+row\d+\s*:', body))

        tables.append({
            'defName': table_name,
            'tableName': tn_match.group(1) if tn_match else table_name,
            'hitPolicy': hp_match.group(1) if hp_match else 'unknown',
            'rowCount': row_count,
            'package': 'Knowledge::DecisionModels',
        })

    return tables


# ---------------------------------------------------------------
# Package hierarchy (simplified from gen_package_hierarchy.py)
# ---------------------------------------------------------------

def build_package_hierarchy(all_texts):
    """Build a simplified package hierarchy with element counts."""

    def count_elements(text):
        """Count element definitions in a text block."""
        counts = {}
        for pattern, key in [
            (r'\bpart\s+def\s+\w+', 'partDefs'),
            (r'\buse\s+case\s+def\s+\w+', 'useCases'),
            (r'\benum\s+def\s+\w+', 'enums'),
            (r'\bconstraint\s+def\s+\w+', 'constraints'),
            (r'\brequirement\s+def\s+\w+', 'requirements'),
            (r'\bstate\s+def\s+\w+', 'states'),
            (r'\bmetadata\s+def\s+\w+', 'metadata'),
            (r'\baction\s+def\s+\w+', 'actions'),
        ]:
            c = len(re.findall(pattern, text))
            if c > 0:
                counts[key] = c
        return counts

    def parse_packages(text, filename):
        """Parse package hierarchy from a single file."""
        packages = []
        lines = text.split('\n')
        brace_depth = 0
        stack = []  # stack of (depth, package_dict)

        for line in lines:
            stripped = line.strip()
            open_b = line.count('{')
            close_b = line.count('}')

            pkg_match = re.match(r'\s*package\s+(\w+)\s*\{', line)
            if pkg_match:
                pkg = {
                    'name': pkg_match.group(1),
                    'children': [],
                    'elements': {},
                }
                # Attach to parent or root
                if stack:
                    stack[-1][1]['children'].append(pkg)
                else:
                    packages.append(pkg)
                stack.append((brace_depth, pkg))

            brace_depth += open_b - close_b

            # Pop finished packages
            while stack and brace_depth <= stack[-1][0]:
                stack.pop()

        return packages

    # Parse each model file
    all_packages = {}
    for filename, text in all_texts.items():
        pkgs = parse_packages(text, filename)
        for pkg in pkgs:
            all_packages[pkg['name']] = pkg

    return all_packages


# ---------------------------------------------------------------
# Assemble manifest
# ---------------------------------------------------------------

def count_packages_recursive(pkg):
    """Count packages in a hierarchy."""
    count = 1
    for child in pkg.get('children', []):
        count += count_packages_recursive(child)
    return count


def main():
    # Read all model files
    all_texts = {}
    source_files = []

    for filepath in sorted(MODEL_DIR.glob("*.sysml")):
        all_texts[filepath.name] = filepath.read_text(encoding="utf-8")
        source_files.append(f"model/{filepath.name}")

    library_texts = []
    for filepath in sorted(LIBRARY_DIR.rglob("*.sysml")):
        text = filepath.read_text(encoding="utf-8")
        rel = filepath.relative_to(REPO_ROOT)
        all_texts[str(rel)] = text
        library_texts.append(text)
        source_files.append(str(rel))

    if not all_texts:
        print("ERROR: No .sysml files found.", file=sys.stderr)
        sys.exit(1)

    print(f"Read {len(all_texts)} .sysml files")

    # Extract inventories
    knowledge_text = all_texts.get("knowledge.sysml", "")
    enterprise_text = all_texts.get("enterprise.sysml", "")
    foundation_text = all_texts.get("foundation.sysml", "")
    sd_text = all_texts.get("service-delivery.sysml", "")

    constraints = extract_constraint_inventory(knowledge_text)
    requirements = extract_requirement_inventory(enterprise_text)
    lifecycles = extract_entity_lifecycle_inventory(sd_text)
    pathways = extract_pathway_inventory(sd_text)
    outcomes = extract_outcome_inventory(knowledge_text)
    metadata = extract_metadata_inventory(foundation_text, library_texts)
    use_cases = extract_use_case_inventory(all_texts)
    decision_tables = extract_decision_table_inventory(knowledge_text)

    # Report
    print(f"\nInventory:")
    print(f"  Constraints:       {len(constraints)}")
    print(f"  Requirements:      {len(requirements)}")
    print(f"  Entity lifecycles: {len(lifecycles)}")
    print(f"  Pathways:          {len(pathways)}")
    print(f"  Outcomes:          {len(outcomes)}")
    print(f"  Decision tables:   {len(decision_tables)}")
    print(f"  Metadata defs:     {len(metadata)}")
    print(f"  Use cases:         {len(use_cases)}")

    # Assemble manifest
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    model_version = datetime.date.today().isoformat()

    manifest = {
        "modelVersion": model_version,
        "generatedAt": timestamp,
        "generator": "scripts/gen_system_manifest.py",
        "sourceFiles": source_files,

        "constraints": {
            "count": len(constraints),
            "items": constraints,
        },

        "requirements": {
            "count": len(requirements),
            "items": requirements,
        },

        "entityLifecycles": {
            "count": len(lifecycles),
            "items": lifecycles,
        },

        "pathways": {
            "count": len(pathways),
            "items": pathways,
        },

        "outcomes": {
            "count": len(outcomes),
            "items": outcomes,
        },

        "decisionTables": {
            "count": len(decision_tables),
            "items": decision_tables,
        },

        "metadata": {
            "count": len(metadata),
            "items": metadata,
        },

        "useCases": {
            "count": len(use_cases),
            "items": use_cases,
        },
    }

    # Write
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    output_path = GENERATED_DIR / "system-manifest.json"
    output_path.write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8"
    )

    print(f"\nGenerated:")
    print(f"  {output_path.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
