#!/usr/bin/env python3
"""
GenderSense Constraint Evaluator Generator
============================================

Reads constraint definitions from Knowledge::ConstraintLibrary and
evaluation specifications from Knowledge::ClinicalDecisionSupport
in the SysML v2 model, and generates:

1. generated/evaluation-types.ts     — TypeScript type definitions
2. generated/constraint-evaluators.ts — evaluation functions (one per constraint)
3. generated/constraint-specs.ts     — spec registry (one entry per eval spec)

Usage:
    cd ~/Developer/gsl-tech/gsl-sysml-model
    python3 scripts/gen_constraint_evaluator.py

No dependencies — pure Python standard library.

Phase 5, Stage 2 of Knowledge Layer Elaboration.
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
// Generator: scripts/gen_constraint_evaluator.py
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
    """Find the content of a named package block within the text.

    Returns the text inside the package braces, or None if not found.
    Handles nested braces correctly.
    """
    # Find the package declaration
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


def parse_constraint_defs(constraint_lib_text):
    """Parse constraint def blocks from ConstraintLibrary text.

    Returns a list of dicts with: name, inputs, expression, doc, satisfy_target
    """
    constraints = []

    # Find each constraint def block
    for match in re.finditer(
        r'constraint\s+def\s+(\w+)\s*\{',
        constraint_lib_text
    ):
        name = match.group(1)
        start = match.end()

        # Find the matching closing brace
        depth = 1
        i = start
        while i < len(constraint_lib_text) and depth > 0:
            if constraint_lib_text[i] == '{':
                depth += 1
            elif constraint_lib_text[i] == '}':
                depth -= 1
            i += 1
        body = constraint_lib_text[start:i - 1]

        # Extract doc block
        doc_match = re.search(r'doc\s*/\*(.+?)\*/', body, re.DOTALL)
        doc_text = ""
        if doc_match:
            raw = doc_match.group(1)
            # Clean doc: remove leading * and whitespace from each line
            lines = []
            for line in raw.split('\n'):
                cleaned = line.strip().lstrip('*').strip()
                if cleaned:
                    lines.append(cleaned)
            doc_text = ' '.join(lines)

        # Extract input parameters (in name : Type;)
        inputs = []
        for inp_match in re.finditer(
            r'\bin\s+(\w+)\s*:\s*(\w+)\s*;',
            body
        ):
            inp_name = inp_match.group(1)
            inp_type = inp_match.group(2)
            inputs.append({
                "name": inp_name,
                "type": inp_type,
                "tsType": TYPE_MAP.get(inp_type, inp_type),
            })

        # Extract the constraint expression (the bare expression after inputs)
        # It's the text after the last input or doc block, before the closing brace
        expression = ""
        # Remove doc block and input lines to find the expression
        expr_body = body
        # Remove doc block
        expr_body = re.sub(r'doc\s*/\*.+?\*/', '', expr_body, flags=re.DOTALL)
        # Remove input declarations
        expr_body = re.sub(r'\bin\s+\w+\s*:\s*\w+\s*;', '', expr_body)
        # What's left (trimmed) should be the expression
        expr_lines = [l.strip() for l in expr_body.strip().split('\n') if l.strip()]
        if expr_lines:
            expression = ' '.join(expr_lines)

        constraints.append({
            "name": name,
            "inputs": inputs,
            "expression": expression,
            "doc": doc_text,
        })

    # Now find satisfy relationships
    # Pattern: satisfy requirement RequirementName\n            by constraintUsageName;
    # First find constraint usages: constraint usageName : ConstraintDefName;
    usage_to_def = {}
    for usage_match in re.finditer(
        r'constraint\s+(\w+)\s*:\s*(\w+)\s*;',
        constraint_lib_text
    ):
        usage_name = usage_match.group(1)
        def_name = usage_match.group(2)
        usage_to_def[usage_name] = def_name

    # Then find satisfy relationships
    for sat_match in re.finditer(
        r'satisfy\s+requirement\s+([\w:]+)\s*\n\s*by\s+(\w+)\s*;',
        constraint_lib_text
    ):
        req_name = sat_match.group(1).split('::')[-1]  # take last segment
        usage_name = sat_match.group(2)
        def_name = usage_to_def.get(usage_name)
        if def_name:
            for c in constraints:
                if c["name"] == def_name:
                    c["satisfies"] = req_name
                    break

    return constraints


def parse_evaluation_specs(cds_text):
    """Parse ConstraintEvaluationSpec part usages from CDS text.

    Returns a list of dicts with: usageName, constraintName, requirementName, severity, doc
    """
    specs = []

    for match in re.finditer(
        r'part\s+(\w+)\s*:\s*ConstraintEvaluationSpec\s*\{',
        cds_text
    ):
        usage_name = match.group(1)
        start = match.end()

        # Find closing brace
        depth = 1
        i = start
        while i < len(cds_text) and depth > 0:
            if cds_text[i] == '{':
                depth += 1
            elif cds_text[i] == '}':
                depth -= 1
            i += 1
        body = cds_text[start:i - 1]

        # Extract :>> redefined attributes
        constraint_name = ""
        requirement_name = ""
        severity = ""
        doc_text = ""

        cn_match = re.search(r'attribute\s+:>>\s+constraintName\s*=\s*"([^"]+)"', body)
        if cn_match:
            constraint_name = cn_match.group(1)

        rn_match = re.search(r'attribute\s+:>>\s+requirementName\s*=\s*"([^"]+)"', body)
        if rn_match:
            requirement_name = rn_match.group(1)

        sev_match = re.search(r'attribute\s+:>>\s+severity\s*=\s*(\w+)::(\w+)', body)
        if sev_match:
            severity = sev_match.group(2)

        doc_match = re.search(r'doc\s*/\*(.+?)\*/', body, re.DOTALL)
        if doc_match:
            raw = doc_match.group(1)
            lines = []
            for line in raw.split('\n'):
                cleaned = line.strip().lstrip('*').strip()
                if cleaned:
                    lines.append(cleaned)
            doc_text = ' '.join(lines)

        specs.append({
            "usageName": usage_name,
            "constraintName": constraint_name,
            "requirementName": requirement_name,
            "severity": severity,
            "doc": doc_text,
        })

    return specs


def parse_decision_table_specs(cds_text):
    """Parse DecisionTableEvaluationSpec part usages from CDS text.

    Returns a list of dicts with: usageName, tableName, description, doc
    """
    specs = []

    for match in re.finditer(
        r'part\s+(\w+)\s*:\s*DecisionTableEvaluationSpec\s*\{',
        cds_text
    ):
        usage_name = match.group(1)
        start = match.end()

        depth = 1
        i = start
        while i < len(cds_text) and depth > 0:
            if cds_text[i] == '{':
                depth += 1
            elif cds_text[i] == '}':
                depth -= 1
            i += 1
        body = cds_text[start:i - 1]

        table_name = ""
        description = ""

        tn_match = re.search(r'attribute\s+:>>\s+tableName\s*=\s*"([^"]+)"', body)
        if tn_match:
            table_name = tn_match.group(1)

        desc_match = re.search(r'attribute\s+:>>\s+description\s*=\s*"([^"]+)"', body)
        if desc_match:
            description = desc_match.group(1)

        specs.append({
            "usageName": usage_name,
            "tableName": table_name,
            "description": description,
        })

    return specs


# ---------------------------------------------------------------
# Expression translator: SysML constraint expr → TypeScript
# ---------------------------------------------------------------

def translate_expression(expression, inputs):
    """Translate a SysML constraint expression to TypeScript.

    Handles:
    - Single boolean input: `consentRecorded` → `inputs.consentRecorded`
    - AND: `a and b` → `inputs.a && inputs.b`
    - Comparison: `a <= b` → `inputs.a <= inputs.b`
    - Compound: `a and b and c` → `inputs.a && inputs.b && inputs.c`

    Returns (ts_expression, is_translatable) tuple.
    """
    if not expression:
        return ("true /* TODO: no expression found */", False)

    input_names = {inp["name"] for inp in inputs}
    expr = expression.strip()

    # Replace 'and' with '&&'
    expr = re.sub(r'\band\b', '&&', expr)

    # Replace 'or' with '||'
    expr = re.sub(r'\bor\b', '||', expr)

    # Replace 'not' with '!'
    expr = re.sub(r'\bnot\b', '!', expr)

    # Prefix input names with 'inputs.'
    for name in sorted(input_names, key=len, reverse=True):
        # Only replace whole words that aren't already prefixed
        expr = re.sub(rf'\b{re.escape(name)}\b', f'inputs.{name}', expr)

    # Check if the expression looks reasonable
    is_translatable = all(
        name in expr.replace('inputs.', '')
        for name in input_names
    ) if input_names else False

    return (expr, is_translatable)


# ---------------------------------------------------------------
# TypeScript emitters
# ---------------------------------------------------------------

def emit_types(timestamp):
    """Generate evaluation-types.ts — shared type definitions."""
    header = HEADER_TEMPLATE.format(
        source="model/knowledge.sysml, model/foundation.sysml",
        timestamp=timestamp,
    )

    return f"""{header}
// ---------------------------------------------------------------
// Enum types (from Foundation::CommonTypes)
// ---------------------------------------------------------------

export type EvaluationOutcome = 'pass' | 'fail' | 'indeterminate';
export type Severity = 'critical' | 'warning' | 'informational';
export type DataSourceType = 'cdr' | 'temporal' | 'platformService' | 'entityLifecycle';
export type AssessmentScope = 'patient' | 'pathway' | 'domain' | 'system';

// ---------------------------------------------------------------
// Evaluation result structures (from Knowledge::LogicEngine)
// ---------------------------------------------------------------

export interface EvaluatedInput {{
  /** Name of the input parameter. */
  name: string;
  /** The value used in evaluation (serialised). */
  value: unknown;
  /** Description of where this value came from. */
  source: string;
  /** ISO datetime when the value was derived. */
  derivedAt: string;
}}

export interface ExplanationTrace {{
  /** The rule expression as evaluated. */
  ruleExpression: string;
  /** Human-readable explanation of the outcome. */
  humanExplanation: string;
  /** All inputs used in the evaluation. */
  evaluatedInputs: EvaluatedInput[];
}}

export interface EvaluationResult {{
  /** Name of the constraint that was evaluated. */
  constraintName: string;
  /** Evaluation outcome. */
  outcome: EvaluationOutcome;
  /** Severity level of this constraint. */
  severity: Severity;
  /** Name of the requirement this constraint satisfies. */
  satisfies: string;
  /** Full explanation trace. */
  explanation: ExplanationTrace;
  /** ISO datetime when the evaluation was performed. */
  evaluatedAt: string;
  /** Sub-evaluations for compound constraints. */
  subEvaluations: EvaluationResult[];
}}

// ---------------------------------------------------------------
// Evaluation specification structures (from Knowledge::CDS)
// ---------------------------------------------------------------

export interface InputDerivation {{
  /** Name of the input to derive. */
  inputName: string;
  /** Type of data source (cdr, temporal, platformService, entityLifecycle). */
  sourceType: DataSourceType;
  /** Query to execute against the source (AQL, API call, etc.). */
  query: string;
  /** Computation to derive the typed input value from query results. */
  computation: string;
  /** Outcome if the query fails or returns no data. */
  fallbackOutcome: EvaluationOutcome;
  /** Reason for the fallback. */
  fallbackReason: string;
}}

export interface ConstraintEvaluationSpec {{
  /** Name of the constraint this spec binds to. */
  constraintName: string;
  /** Name of the requirement this constraint satisfies. */
  requirementName: string;
  /** Severity level. */
  severity: Severity;
  /** How to derive each input from authoritative sources. */
  inputDerivations: InputDerivation[];
}}
"""


def emit_evaluators(constraints, timestamp):
    """Generate constraint-evaluators.ts — one evaluation function per constraint."""
    header = HEADER_TEMPLATE.format(
        source="model/knowledge.sysml (Knowledge::ConstraintLibrary)",
        timestamp=timestamp,
    )

    lines = [header]
    lines.append("import type { EvaluationResult, EvaluationOutcome, Severity } from './evaluation-types';")
    lines.append("")

    for c in constraints:
        name = c["name"]
        inputs = c["inputs"]
        expression = c.get("expression", "")
        doc = c.get("doc", "")
        satisfies = c.get("satisfies", "unknown")

        # Find severity from linked spec (will be injected later)
        severity = c.get("severity", "warning")

        # Build TypeScript function name: remove trailing "Constraint" for brevity
        func_name = name
        if func_name.endswith("Constraint"):
            func_name = func_name[:-len("Constraint")]
        # camelCase: first letter lowercase
        func_name = "evaluate" + func_name

        # Build input type
        input_params = []
        for inp in inputs:
            input_params.append(f"    {inp['name']}: {inp['tsType']};")

        # Translate expression
        ts_expr, is_translatable = translate_expression(expression, inputs)

        lines.append(f"/**")
        lines.append(f" * {name}")
        lines.append(f" *")
        if doc:
            # Wrap doc at ~70 chars per line
            words = doc.split()
            doc_line = " *"
            for word in words:
                if len(doc_line) + len(word) + 1 > 75:
                    lines.append(doc_line)
                    doc_line = f" * {word}"
                else:
                    doc_line += f" {word}"
            if doc_line.strip() != "*":
                lines.append(doc_line)
        lines.append(f" *")
        lines.append(f" * Satisfies: {satisfies}")
        lines.append(f" * Severity: {severity}")
        lines.append(f" */")

        lines.append(f"export function {func_name}(")
        lines.append(f"  inputs: {{")
        for param in input_params:
            lines.append(param)
        lines.append(f"  }}")
        lines.append(f"): EvaluationResult {{")

        if is_translatable:
            lines.append(f"  const outcome: EvaluationOutcome =")
            lines.append(f"    ({ts_expr})")
            lines.append(f"      ? 'pass'")
            lines.append(f"      : 'fail';")
        else:
            lines.append(f"  // TODO: Complex expression — implement manually from doc block:")
            lines.append(f"  // \"{expression}\"")
            lines.append(f"  const outcome: EvaluationOutcome = 'indeterminate';")

        lines.append(f"")

        # Build evaluated inputs array
        lines.append(f"  return {{")
        lines.append(f"    constraintName: '{name}',")
        lines.append(f"    outcome,")
        lines.append(f"    severity: '{severity}',")
        lines.append(f"    satisfies: '{satisfies}',")
        lines.append(f"    explanation: {{")
        lines.append(f"      ruleExpression: `{expression}`,")
        lines.append(f"      humanExplanation: outcome === 'pass'")
        lines.append(f"        ? '{name} check passed.'")
        lines.append(f"        : '{name} check failed.',")
        lines.append(f"      evaluatedInputs: [")
        for inp in inputs:
            lines.append(f"        {{")
            lines.append(f"          name: '{inp['name']}',")
            lines.append(f"          value: inputs.{inp['name']},")
            lines.append(f"          source: 'derived',  // populated by evaluation engine at runtime")
            lines.append(f"          derivedAt: new Date().toISOString(),")
            lines.append(f"        }},")
        lines.append(f"      ],")
        lines.append(f"    }},")
        lines.append(f"    evaluatedAt: new Date().toISOString(),")
        lines.append(f"    subEvaluations: [],")
        lines.append(f"  }};")
        lines.append(f"}}")
        lines.append(f"")

    # Export a registry of all evaluator functions
    lines.append(f"// ---------------------------------------------------------------")
    lines.append(f"// Evaluator function registry")
    lines.append(f"// ---------------------------------------------------------------")
    lines.append(f"")
    lines.append(f"export const constraintEvaluators: Record<string, (inputs: any) => EvaluationResult> = {{")
    for c in constraints:
        name = c["name"]
        func_name = name
        if func_name.endswith("Constraint"):
            func_name = func_name[:-len("Constraint")]
        func_name = "evaluate" + func_name
        lines.append(f"  '{name}': {func_name},")
    lines.append(f"}};")
    lines.append(f"")

    return "\n".join(lines)


def emit_specs(constraint_specs, decision_table_specs, timestamp):
    """Generate constraint-specs.ts — evaluation spec registry."""
    header = HEADER_TEMPLATE.format(
        source="model/knowledge.sysml (Knowledge::ClinicalDecisionSupport)",
        timestamp=timestamp,
    )

    lines = [header]
    lines.append("import type { ConstraintEvaluationSpec, Severity } from './evaluation-types';")
    lines.append("")
    lines.append("// ---------------------------------------------------------------")
    lines.append("// Constraint evaluation spec registry")
    lines.append("//")
    lines.append("// One entry per ConstraintEvaluationSpec part usage in CDS.")
    lines.append("// Input derivation detail is in doc blocks — not yet")
    lines.append("// machine-parseable. inputDerivations arrays are placeholders.")
    lines.append("// ---------------------------------------------------------------")
    lines.append("")
    lines.append("export const constraintSpecs: Record<string, ConstraintEvaluationSpec> = {")

    for spec in constraint_specs:
        lines.append(f"  /** {spec['doc'][:80]}{'...' if len(spec.get('doc', '')) > 80 else ''} */")
        lines.append(f"  '{spec['constraintName']}': {{")
        lines.append(f"    constraintName: '{spec['constraintName']}',")
        lines.append(f"    requirementName: '{spec['requirementName']}',")
        lines.append(f"    severity: '{spec['severity']}',")
        lines.append(f"    inputDerivations: [],  // TODO: populate when nested :>> syntax is verified")
        lines.append(f"  }},")
        lines.append(f"")

    lines.append("};")
    lines.append("")

    # Also emit decision table specs for completeness
    if decision_table_specs:
        lines.append("// ---------------------------------------------------------------")
        lines.append("// Decision table evaluation spec registry")
        lines.append("// ---------------------------------------------------------------")
        lines.append("")
        lines.append("export interface DecisionTableEvaluationSpec {")
        lines.append("  tableName: string;")
        lines.append("  description: string;")
        lines.append("}")
        lines.append("")
        lines.append("export const decisionTableSpecs: Record<string, DecisionTableEvaluationSpec> = {")
        for spec in decision_table_specs:
            lines.append(f"  '{spec['tableName']}': {{")
            lines.append(f"    tableName: '{spec['tableName']}',")
            lines.append(f"    description: '{spec['description']}',")
            lines.append(f"  }},")
        lines.append("};")
        lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    if not KNOWLEDGE_FILE.exists():
        print(f"ERROR: {KNOWLEDGE_FILE} not found.", file=sys.stderr)
        print(f"Run from the repository root: cd ~/Developer/gsl-tech/gsl-sysml-model", file=sys.stderr)
        sys.exit(1)

    # Read the model file
    text = KNOWLEDGE_FILE.read_text(encoding="utf-8")

    # Extract package blocks
    constraint_lib_text = find_package_block(text, "ConstraintLibrary")
    cds_text = find_package_block(text, "ClinicalDecisionSupport")

    if not constraint_lib_text:
        print("ERROR: Could not find ConstraintLibrary package.", file=sys.stderr)
        sys.exit(1)
    if not cds_text:
        print("ERROR: Could not find ClinicalDecisionSupport package.", file=sys.stderr)
        sys.exit(1)

    # Parse
    constraints = parse_constraint_defs(constraint_lib_text)
    constraint_specs = parse_evaluation_specs(cds_text)
    dt_specs = parse_decision_table_specs(cds_text)

    # Cross-reference: attach severity from specs to constraints
    spec_by_name = {s["constraintName"]: s for s in constraint_specs}
    for c in constraints:
        spec = spec_by_name.get(c["name"])
        if spec:
            c["severity"] = spec["severity"]
            c["specUsageName"] = spec["usageName"]

    # Report
    print(f"Parsed {len(constraints)} constraint defs from ConstraintLibrary:")
    for c in constraints:
        inputs_str = ", ".join(f"{i['name']}: {i['type']}" for i in c["inputs"])
        print(f"  {c['name']}({inputs_str}) → satisfies {c.get('satisfies', '?')}")
        ts_expr, ok = translate_expression(c.get("expression", ""), c["inputs"])
        status = "✓" if ok else "⚠ needs manual implementation"
        print(f"    expression: {c.get('expression', '(none)')} → {status}")

    print(f"\nParsed {len(constraint_specs)} constraint evaluation specs from CDS:")
    for s in constraint_specs:
        print(f"  {s['usageName']}: {s['constraintName']} (severity: {s['severity']})")

    print(f"\nParsed {len(dt_specs)} decision table evaluation specs from CDS:")
    for s in dt_specs:
        print(f"  {s['usageName']}: {s['tableName']}")

    # Generate
    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    GENERATED_DIR.mkdir(parents=True, exist_ok=True)

    types_content = emit_types(timestamp)
    evaluators_content = emit_evaluators(constraints, timestamp)
    specs_content = emit_specs(constraint_specs, dt_specs, timestamp)

    types_path = GENERATED_DIR / "evaluation-types.ts"
    evaluators_path = GENERATED_DIR / "constraint-evaluators.ts"
    specs_path = GENERATED_DIR / "constraint-specs.ts"

    types_path.write_text(types_content, encoding="utf-8")
    evaluators_path.write_text(evaluators_content, encoding="utf-8")
    specs_path.write_text(specs_content, encoding="utf-8")

    print(f"\nGenerated:")
    print(f"  {types_path.relative_to(REPO_ROOT)}")
    print(f"  {evaluators_path.relative_to(REPO_ROOT)}")
    print(f"  {specs_path.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
