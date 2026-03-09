#!/usr/bin/env python3
"""
GenderSense Decision Table Evaluator Generator
================================================

Reads decision table definitions from Knowledge::DecisionModels
in the SysML v2 model and generates:

1. generated/decision-table-evaluators.ts — row data + lookup functions

Usage:
    cd ~/Developer/gsl-tech/gsl-sysml-model
    python3 scripts/gen_decision_table_evaluator.py

No dependencies — pure Python standard library.

Phase 5, Stage 3 of Knowledge Layer Elaboration.
"""

import pathlib
import re
import sys
import datetime

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
KNOWLEDGE_FILE = MODEL_DIR / "knowledge.sysml"
GENERATED_DIR = REPO_ROOT / "generated"

HEADER_TEMPLATE = """\
// ============================================================
// DO NOT EDIT — Generated from GenderSense SysML v2 model
// Source: {source}
// Generated: {timestamp}
// Generator: scripts/gen_decision_table_evaluator.py
// ============================================================
"""

# SysML → TypeScript type mapping
TYPE_MAP = {
    "String": "string",
    "Boolean": "boolean",
    "Integer": "number",
    "Real": "number",
}


# ---------------------------------------------------------------
# Parsers
# ---------------------------------------------------------------

def find_package_block(text, package_name):
    """Find the content of a named package block within the text."""
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


def find_block(text, pattern_str):
    """Find the content of a block starting with the given pattern.
    Returns (match_object, block_body) or None.
    """
    match = re.search(pattern_str, text)
    if not match:
        return None

    start = match.end()
    # The pattern should end at the opening {, so we start at depth 1
    # But let's find the { first
    brace_pos = text.find('{', match.start())
    if brace_pos < 0:
        return None

    start = brace_pos + 1
    depth = 1
    i = start
    while i < len(text) and depth > 0:
        if text[i] == '{':
            depth += 1
        elif text[i] == '}':
            depth -= 1
        i += 1

    return (match, text[start:i - 1])


def parse_row_def(dm_text, row_def_name):
    """Parse a decision table row part def to extract its attribute names and types.

    Returns a list of dicts: {name, type, tsType, isInput}
    The input/output split is determined by a comment containing '--- Outputs ---'
    """
    result = find_block(dm_text, rf'part\s+def\s+{re.escape(row_def_name)}\s*\{{')
    if not result:
        return []

    _, body = result

    attributes = []
    in_outputs = False

    for line in body.split('\n'):
        stripped = line.strip()

        # Check for the outputs marker
        # Model uses: // --- Outputs (recommendations) --- or // --- Outputs ---
        if re.search(r'---\s*Outputs\b', stripped, re.IGNORECASE):
            in_outputs = True
            continue

        # Parse attribute declarations
        attr_match = re.match(r'attribute\s+(\w+)\s*:\s*([\w:]+)\s*;', stripped)
        if attr_match:
            attr_name = attr_match.group(1)
            attr_type = attr_match.group(2)

            # Handle qualified types like HormoneLevel (just use the last segment)
            simple_type = attr_type.split('::')[-1] if '::' in attr_type else attr_type
            ts_type = TYPE_MAP.get(simple_type, simple_type)

            attributes.append({
                'name': attr_name,
                'type': simple_type,
                'tsType': ts_type,
                'isInput': not in_outputs,
            })

    return attributes


def parse_table_def(dm_text, table_def_name):
    """Parse a decision table def (e.g. RegimenSelectionTable) to extract
    its :>> redefined metadata attributes.

    Returns a dict: {tableName, hitPolicy, description}
    """
    result = find_block(dm_text, rf'part\s+def\s+{re.escape(table_def_name)}\s*:>\s*DecisionTableDef\s*\{{')
    if not result:
        return None

    _, body = result

    table_name = ""
    hit_policy = ""
    description = ""

    tn_match = re.search(r'attribute\s+:>>\s+tableName\s*=\s*"([^"]+)"', body)
    if tn_match:
        table_name = tn_match.group(1)

    hp_match = re.search(r'attribute\s+:>>\s+hitPolicy\s*=\s*(\w+)::(\w+)', body)
    if hp_match:
        hit_policy = hp_match.group(2)

    desc_match = re.search(r'attribute\s+:>>\s+tableDescription\s*=\s*"([^"]+)"', body)
    if desc_match:
        description = desc_match.group(1)

    return {
        'tableName': table_name,
        'hitPolicy': hit_policy,
        'description': description,
    }


def parse_row_usages(table_body, row_def_name):
    """Parse all part row usages within a table def body.

    Returns a list of dicts, each with:
    - usageName: e.g. 'row01'
    - doc: doc block text
    - values: dict of attribute name → value string
    - valueTypes: dict of attribute name → 'string' | 'enum' | 'integer'
    """
    rows = []

    # Find each part rowNN : RowDefName { ... }
    for match in re.finditer(
        rf'part\s+(\w+)\s*:\s*{re.escape(row_def_name)}\s*\{{',
        table_body
    ):
        usage_name = match.group(1)
        start = match.end()

        # Find the closing brace
        depth = 1
        i = start
        while i < len(table_body) and depth > 0:
            if table_body[i] == '{':
                depth += 1
            elif table_body[i] == '}':
                depth -= 1
            i += 1
        body = table_body[start:i - 1]

        # Extract doc block
        doc_text = ""
        doc_match = re.search(r'doc\s*/\*(.+?)\*/', body, re.DOTALL)
        if doc_match:
            raw = doc_match.group(1)
            lines = []
            for line in raw.split('\n'):
                cleaned = line.strip().lstrip('*').strip()
                if cleaned:
                    lines.append(cleaned)
            doc_text = ' '.join(lines)

        # Extract :>> redefinitions
        values = {}
        value_types = {}

        # String values: attribute :>> name = "value";
        for sv_match in re.finditer(
            r'attribute\s+:>>\s+(\w+)\s*=\s*"([^"]+)"\s*;',
            body
        ):
            values[sv_match.group(1)] = sv_match.group(2)
            value_types[sv_match.group(1)] = 'string'

        # Enum values: attribute :>> name = EnumType::value;
        for ev_match in re.finditer(
            r'attribute\s+:>>\s+(\w+)\s*=\s*(\w+)::(\w+)\s*;',
            body
        ):
            values[ev_match.group(1)] = ev_match.group(3)
            value_types[ev_match.group(1)] = 'enum'

        # Integer values: attribute :>> name = 42;
        for iv_match in re.finditer(
            r'attribute\s+:>>\s+(\w+)\s*=\s*(\d+)\s*;',
            body
        ):
            attr_name = iv_match.group(1)
            # Don't overwrite if already matched as enum (enum values don't start with digits, so no conflict)
            if attr_name not in values:
                values[attr_name] = int(iv_match.group(2))
                value_types[attr_name] = 'integer'

        rows.append({
            'usageName': usage_name,
            'doc': doc_text,
            'values': values,
            'valueTypes': value_types,
        })

    return rows


def discover_tables(dm_text):
    """Discover all decision tables in the DecisionModels package.

    A table is identified by:
    - A part def that specialises DecisionTableDef (the table container)
    - A part def that defines the row structure (named *Row)
    - Row usages inside the table container

    Returns a list of table descriptors.
    """
    tables = []

    # Find all table defs (part def XTable :> DecisionTableDef)
    for match in re.finditer(
        r'part\s+def\s+(\w+)\s*:>\s*DecisionTableDef\s*\{',
        dm_text
    ):
        table_def_name = match.group(1)

        # Find the table body
        start = match.end()
        depth = 1
        i = start
        while i < len(dm_text) and depth > 0:
            if dm_text[i] == '{':
                depth += 1
            elif dm_text[i] == '}':
                depth -= 1
            i += 1
        table_body = dm_text[start:i - 1]

        # Infer the row def name from the first row usage
        row_match = re.search(r'part\s+\w+\s*:\s*(\w+Row)\s*\{', table_body)
        if not row_match:
            print(f"  WARNING: No row usages found in {table_def_name}", file=sys.stderr)
            continue
        row_def_name = row_match.group(1)

        # Parse the table metadata
        table_meta = parse_table_def(dm_text, table_def_name)
        if not table_meta:
            table_meta = {'tableName': table_def_name, 'hitPolicy': 'unknown', 'description': ''}

        # Parse the row structure
        row_attrs = parse_row_def(dm_text, row_def_name)

        # Parse the row usages
        rows = parse_row_usages(table_body, row_def_name)

        tables.append({
            'tableDefName': table_def_name,
            'rowDefName': row_def_name,
            'meta': table_meta,
            'attributes': row_attrs,
            'rows': rows,
        })

    return tables


# ---------------------------------------------------------------
# TypeScript emitter
# ---------------------------------------------------------------

def to_camel_case(name):
    """Convert PascalCase or snake_case to camelCase."""
    if not name:
        return name
    return name[0].lower() + name[1:]


def emit_decision_table_evaluators(tables, timestamp):
    """Generate decision-table-evaluators.ts."""
    header = HEADER_TEMPLATE.format(
        source="model/knowledge.sysml (Knowledge::DecisionModels)",
        timestamp=timestamp,
    )

    lines = [header]
    lines.append("import type { EvaluationResult, EvaluationOutcome } from './evaluation-types';")
    lines.append("")

    for table in tables:
        meta = table['meta']
        attrs = table['attributes']
        rows = table['rows']
        table_name = meta['tableName']
        row_def = table['rowDefName']

        input_attrs = [a for a in attrs if a['isInput']]
        output_attrs = [a for a in attrs if not a['isInput']]

        # Emit TypeScript types for this table
        pascal_name = table_name[0].upper() + table_name[1:]

        lines.append(f"// ---------------------------------------------------------------")
        lines.append(f"// {pascal_name} Decision Table")
        lines.append(f"//")
        lines.append(f"// {meta['description']}")
        lines.append(f"// Hit policy: {meta['hitPolicy']}")
        lines.append(f"// Rows: {len(rows)}")
        lines.append(f"// ---------------------------------------------------------------")
        lines.append(f"")

        # Input interface
        lines.append(f"export interface {pascal_name}Input {{")
        for attr in input_attrs:
            lines.append(f"  {attr['name']}: {attr['tsType']};")
        lines.append(f"}}")
        lines.append(f"")

        # Output interface
        lines.append(f"export interface {pascal_name}Output {{")
        for attr in output_attrs:
            lines.append(f"  {attr['name']}: {attr['tsType']};")
        lines.append(f"}}")
        lines.append(f"")

        # Row type
        lines.append(f"export type {pascal_name}Row = {pascal_name}Input & {pascal_name}Output;")
        lines.append(f"")

        # Row data array
        lines.append(f"const {to_camel_case(table_name)}Rows: {pascal_name}Row[] = [")
        for row in rows:
            doc_short = row['doc'][:80] + '...' if len(row['doc']) > 80 else row['doc']
            lines.append(f"  // {row['usageName']}: {doc_short}")
            lines.append(f"  {{")
            for attr in attrs:
                name = attr['name']
                if name in row['values']:
                    val = row['values'][name]
                    vtype = row['valueTypes'].get(name, 'string')
                    if vtype == 'integer':
                        lines.append(f"    {name}: {val},")
                    elif vtype == 'enum':
                        lines.append(f"    {name}: '{val}',")
                    else:
                        lines.append(f"    {name}: '{val}',")
                else:
                    lines.append(f"    {name}: undefined as any,  // WARNING: not found in model")
            lines.append(f"  }},")
        lines.append(f"];")
        lines.append(f"")

        # Lookup function
        lines.append(f"/**")
        lines.append(f" * Look up the {table_name} decision table.")
        lines.append(f" *")
        lines.append(f" * Hit policy: {meta['hitPolicy']}.")
        if meta['hitPolicy'] == 'unique':
            lines.append(f" * Returns the single matching row's outputs, or null if no match.")
        else:
            lines.append(f" * Returns the first matching row's outputs, or null if no match.")
        lines.append(f" */")
        lines.append(f"export function lookup{pascal_name}(")
        lines.append(f"  input: {pascal_name}Input")
        lines.append(f"): {pascal_name}Output | null {{")

        # Build the match condition
        # For enum/string inputs: equality check
        # For integer inputs: the row value is a minimum threshold (>= check)
        match_conditions = []
        for attr in input_attrs:
            name = attr['name']
            # Check if any row has an integer value for this attr
            has_integer = any(
                r['valueTypes'].get(name) == 'integer'
                for r in rows
            )
            if has_integer:
                match_conditions.append(f"input.{name} >= row.{name}")
            else:
                match_conditions.append(f"row.{name} === input.{name}")

        lines.append(f"  const match = {to_camel_case(table_name)}Rows.find(")
        lines.append(f"    row =>")
        for i, cond in enumerate(match_conditions):
            sep = " &&" if i < len(match_conditions) - 1 else ""
            prefix = "      " if i > 0 else "      "
            lines.append(f"{prefix}{cond}{sep}")
        lines.append(f"  );")
        lines.append(f"")
        lines.append(f"  if (!match) return null;")
        lines.append(f"")
        lines.append(f"  return {{")
        for attr in output_attrs:
            lines.append(f"    {attr['name']}: match.{attr['name']},")
        lines.append(f"  }};")
        lines.append(f"}}")
        lines.append(f"")

        # Evaluator wrapper that produces EvaluationResult
        lines.append(f"/**")
        lines.append(f" * Evaluate the {table_name} decision table and produce an EvaluationResult.")
        lines.append(f" */")
        lines.append(f"export function evaluate{pascal_name}(")
        lines.append(f"  input: {pascal_name}Input")
        lines.append(f"): EvaluationResult {{")
        lines.append(f"  const result = lookup{pascal_name}(input);")
        lines.append(f"  const outcome: EvaluationOutcome = result ? 'pass' : 'indeterminate';")
        lines.append(f"")
        lines.append(f"  return {{")
        lines.append(f"    constraintName: '{table_name}',")
        lines.append(f"    outcome,")
        lines.append(f"    severity: 'informational',")
        lines.append(f"    satisfies: '',")
        lines.append(f"    explanation: {{")
        lines.append(f"      ruleExpression: '{table_name} table lookup',")
        lines.append(f"      humanExplanation: result")
        lines.append(f"        ? `Matched {table_name} table row.`")
        lines.append(f"        : `No matching row found in {table_name} table.`,")
        lines.append(f"      evaluatedInputs: [")
        for attr in input_attrs:
            lines.append(f"        {{")
            lines.append(f"          name: '{attr['name']}',")
            lines.append(f"          value: input.{attr['name']},")
            lines.append(f"          source: 'derived',")
            lines.append(f"          derivedAt: new Date().toISOString(),")
            lines.append(f"        }},")
        lines.append(f"      ],")
        lines.append(f"    }},")
        lines.append(f"    evaluatedAt: new Date().toISOString(),")
        lines.append(f"    subEvaluations: [],")
        lines.append(f"  }};")
        lines.append(f"}}")
        lines.append(f"")

    # Registry of all table evaluators
    lines.append(f"// ---------------------------------------------------------------")
    lines.append(f"// Decision table evaluator registry")
    lines.append(f"// ---------------------------------------------------------------")
    lines.append(f"")
    lines.append(f"export const decisionTableEvaluators: Record<string, (input: any) => EvaluationResult> = {{")
    for table in tables:
        tn = table['meta']['tableName']
        pascal = tn[0].upper() + tn[1:]
        lines.append(f"  '{tn}': evaluate{pascal},")
    lines.append(f"}};")
    lines.append(f"")

    return "\n".join(lines)


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    if not KNOWLEDGE_FILE.exists():
        print(f"ERROR: {KNOWLEDGE_FILE} not found.", file=sys.stderr)
        print(f"Run from the repository root: cd ~/Developer/gsl-tech/gsl-sysml-model", file=sys.stderr)
        sys.exit(1)

    text = KNOWLEDGE_FILE.read_text(encoding="utf-8")

    dm_text = find_package_block(text, "DecisionModels")
    if not dm_text:
        print("ERROR: Could not find DecisionModels package.", file=sys.stderr)
        sys.exit(1)

    tables = discover_tables(dm_text)

    # Report
    print(f"Discovered {len(tables)} decision tables in DecisionModels:")
    for table in tables:
        meta = table['meta']
        attrs = table['attributes']
        rows = table['rows']
        input_attrs = [a for a in attrs if a['isInput']]
        output_attrs = [a for a in attrs if not a['isInput']]

        print(f"\n  {meta['tableName']} ({table['tableDefName']})")
        print(f"    Hit policy: {meta['hitPolicy']}")
        print(f"    Row def: {table['rowDefName']}")
        print(f"    Inputs:  {', '.join(f'{a['name']}: {a['type']}' for a in input_attrs)}")
        print(f"    Outputs: {', '.join(f'{a['name']}: {a['type']}' for a in output_attrs)}")
        print(f"    Rows: {len(rows)}")
        for row in rows:
            vals = ', '.join(f"{k}={v}" for k, v in row['values'].items())
            print(f"      {row['usageName']}: {vals}")

    # Generate
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    content = emit_decision_table_evaluators(tables, timestamp)
    output_path = GENERATED_DIR / "decision-table-evaluators.ts"
    output_path.write_text(content, encoding="utf-8")

    print(f"\nGenerated:")
    print(f"  {output_path.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
