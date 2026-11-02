#!/usr/bin/env python3
"""
E6 constraint evaluator generator (platform-general)
====================================================

Reads a tenant model's constraint library package (``constraint def``
blocks and the ``satisfy`` relationships to them) and its evaluation-spec
package (``ConstraintEvaluationSpec`` and ``DecisionTableEvaluationSpec``
part usages), and writes three files to the output folder:

1. evaluation-types.ts      type definitions for the platform pattern
                            (SystemMetamodelGeneral::LogicEngine, ::EvaluationSpecs)
2. constraint-evaluators.ts one evaluation function per constraint def
3. constraint-specs.ts      the spec registry, one entry per spec usage

The two tenant package names are arguments; the generator names no tenant.
The pattern types are platform content, read from the platform model folder.

Axis preconditions (S0.4, OP-32 part b). When the tenant model declares
``AxisPrecondition`` usages on its status axes (see generation.status_axes),
it also writes

4. axis-preconditions.ts    one evaluator per declared precondition, and a
                            move-level evaluator that runs every
                            precondition of a move. No imports.

A precondition holds when the named axis, on the same instance or on the
instance its ``relatedVia`` reference names, holds one of its
``requiredValues``. A move whose precondition fails, or cannot be decided
because the value is missing, is rejected with the model's
``rejectionReason``: a structured rejection, never a silent pass. The
constraint and spec packages are optional when only axis preconditions are
wanted; a model with neither is an error.

Usage (from the repository root):
    python3 -m generation.constraint_evaluator \\
        --model <tenant model folder> --out <output folder> \\
        --constraint-package <package> --spec-package <package> \\
        [--platform-model model] [--model-name <name>]

Reading (S0.5 Pass A4): the model is read through OpenSysML's resolved model
(generation.resolved), loaded with the platform model folder. Each
constraint def's inputs are its ``in`` features; its expression is the result
expression OpenSysML parsed, taken in its written form from the source span
the resolved model gives (the translator below works on the notation); its
doc is its documentation. A constraint satisfies the requirement its
``satisfy`` names, through the constraint usage the ``satisfy`` gives as its
``by``. Spec values are the literal values of the spec usage's redefined
attributes.

Generalised at S0.2 (Plan B Stage 0) from scripts/gen_constraint_evaluator.py.
The parsers, the expression translator and the emitters are carried over
unchanged, so the output below the header block is byte-identical; the
header loses its generation timestamp and names this generator.
No dependencies: Python standard library only.
"""

import re
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header as make_header, write
from generation import resolved
from generation.common import ModelError, rel_path, upper_first

# Platform pattern packages the evaluation types reflect (SystemMetamodelGeneral).
PATTERN_PACKAGES = ("LogicEngine", "EvaluationSpecs")

# SysML → TypeScript type mapping
TYPE_MAP = {
    "String": "string",
    "Boolean": "boolean",
    "Integer": "number",
    "Real": "number",
}


# ---------------------------------------------------------------
# Readers (over the resolved model, S0.5 Pass A4)
# ---------------------------------------------------------------

def _clean_doc(body):
    """A documentation body as one line: each line stripped of whitespace and a leading ``*``."""
    lines = []
    for line in (body or "").split('\n'):
        cleaned = line.strip().lstrip('*').strip()
        if cleaned:
            lines.append(cleaned)
    return ' '.join(lines)


class Reader:
    """The constraint and spec packages, read from the resolved model."""

    def __init__(self, rm):
        self.rm = rm
        self.graph = rm.elements()
        self.texts = dict(rm.documents)

    def doc(self, e):
        d = next((m for m in self.graph.member_list(e) if m["@type"] == "Documentation"), None)
        return _clean_doc(d.get("body")) if d else ""

    def written(self, e):
        """The written form of ``e``, from its source span, as one line (lines stripped, joined by spaces)."""
        lines = self.texts[self.graph.document(e)].split('\n')
        l0, c0 = e["sysx:sourceLine"], e["sysx:sourceColumn"]
        l1, c1 = e["sysx:sourceEndLine"], e["sysx:sourceEndColumn"]
        if l0 == l1:
            span = [lines[l0 - 1][c0 - 1:c1 - 1]]
        else:
            span = [lines[l0 - 1][c0 - 1:]] + lines[l0:l1 - 1] + [lines[l1 - 1][:c1 - 1]]
        return ' '.join(s.strip() for s in span if s.strip())

    def type_name(self, f):
        types = self.graph.get(f, "type")
        if types:
            return types[0].get("declaredName") or ""
        sym = self.rm.sym(f["qualifiedName"])
        tf = sym.type_facts if sym is not None else None
        q = (tf.resolved_id or tf.declared or "") if tf else ""
        return q.split("::")[-1]

    def in_package(self, package_q, kind):
        return [
            e for e in self.graph.definitions(kind)
            if (e.get("qualifiedName") or "").startswith(package_q + "::")
        ]

    def value(self, usage, feature):
        """The literal value the usage's ``:>> feature = ...`` sets, or None."""
        for m in self.graph.member_list(usage):
            if any(r.get("declaredName") == feature for r in self.graph.get(m, "redefines")):
                return self.graph._value(m.get("value"))
        return None

    def typed_usages(self, package_q, type_name):
        return [
            e for e in self.in_package(package_q, "PartUsage")
            if e.get("sysx:hasBody") and any(t.get("declaredName") == type_name for t in self.graph.get(e, "type"))
        ]


def parse_constraint_defs(reader, package_q):
    """Constraint defs of the package, in source order.

    Returns a list of dicts with: name, inputs, expression, doc, satisfies (when a satisfy names it)
    """
    constraints = []
    for cd in reader.in_package(package_q, "ConstraintDefinition"):
        if not cd.get("sysx:hasBody"):
            continue
        inputs = []
        for m in reader.graph.member_list(cd):
            if m.get("direction") == "in" and m.get("declaredName") and m.get("ownedTyping"):
                inp_type = reader.type_name(m)
                inputs.append({"name": m["declaredName"], "type": inp_type, "tsType": TYPE_MAP.get(inp_type, inp_type)})
        expression = ""
        for r in reader.graph.get(cd, "ownedRelationship"):
            if r["@type"] == "ResultExpressionMembership":
                for x in reader.graph.get(r, "ownedRelatedElement"):
                    expression = reader.written(x)
        constraints.append({
            "name": cd["declaredName"],
            "inputs": inputs,
            "expression": expression,
            "doc": reader.doc(cd),
        })

    # A satisfy names the requirement and, through its `by`, a constraint usage typed by the def.
    for sat in reader.in_package(package_q, "SatisfyRequirementUsage"):
        req_name = sat.get("declaredName")
        if not req_name:
            refs = [x for r in reader.graph.get(sat, "ownedRelationship") for x in reader.graph.get(r, "referencedFeature")]
            req_name = refs[0].get("declaredName") if refs else None
        by = reader.graph.get(sat, "subject")
        if not req_name or not by:
            continue
        defs = reader.graph.get(by[0], "type")
        def_name = defs[0].get("declaredName") if defs else None
        if def_name:
            for c in constraints:
                if c["name"] == def_name:
                    c["satisfies"] = req_name.split('::')[-1]
                    break

    return constraints


def parse_evaluation_specs(reader, package_q):
    """ConstraintEvaluationSpec part usages of the package.

    Returns a list of dicts with: usageName, constraintName, requirementName, severity, doc
    """
    specs = []
    for u in reader.typed_usages(package_q, "ConstraintEvaluationSpec"):
        specs.append({
            "usageName": u["declaredName"],
            "constraintName": reader.value(u, "constraintName") or "",
            "requirementName": reader.value(u, "requirementName") or "",
            "severity": reader.value(u, "severity") or "",
            "doc": reader.doc(u),
        })
    return specs


def parse_decision_table_specs(reader, package_q):
    """DecisionTableEvaluationSpec part usages of the package.

    Returns a list of dicts with: usageName, tableName, description
    """
    specs = []
    for u in reader.typed_usages(package_q, "DecisionTableEvaluationSpec"):
        specs.append({
            "usageName": u["declaredName"],
            "tableName": reader.value(u, "tableName") or "",
            "description": reader.value(u, "description") or "",
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

def emit_types(header):
    """Generate evaluation-types.ts — shared type definitions."""

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


def emit_evaluators(constraints, header):
    """Generate constraint-evaluators.ts — one evaluation function per constraint."""

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


def emit_specs(constraint_specs, decision_table_specs, header):
    """Generate constraint-specs.ts — evaluation spec registry."""

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
# Model location (generalised at S0.2)
# ---------------------------------------------------------------

def locate_package(reader, package_name, documents=None):
    """Return (document name, qualified name) for the one document declaring the package.

    ``documents``: the documents to look in (default: the tenant's). A
    document that declares the package more than once counts once (its first).
    """
    allowed = set(reader.graph.tenant_documents if documents is None else documents)
    hits = {}
    for _, e in sorted(
        ((reader.graph.document(e) or "", e) for e in reader.graph.data
         if e["@type"] == "Package" and e.get("declaredName") == package_name),
        key=lambda x: (x[0], x[1].get("sysx:sourceLine", 0)),
    ):
        doc = reader.graph.document(e)
        if doc in allowed and doc not in hits:
            hits[doc] = e["qualifiedName"]
    if not hits:
        raise ModelError(f"package {package_name!r} not found in the model folder")
    if len(hits) > 1:
        raise ModelError(f"package {package_name!r} is declared in more than one file: " + ", ".join(sorted(hits)))
    return next(iter(hits.items()))


def pattern_source(reader, platform_documents):
    """Header source for evaluation-types.ts: the platform pattern packages."""
    located = [locate_package(reader, name, platform_documents) for name in PATTERN_PACKAGES]
    paths = {f for f, _ in located}
    if len(paths) != 1:
        raise ModelError("pattern packages are expected in one platform file: " + ", ".join(sorted(paths)))
    first_q = located[0][1]
    parent = first_q.rsplit("::", 1)[0]
    parts = [first_q]
    for _, q in located[1:]:
        parts.append("::" + q.rsplit("::", 1)[1] if q.rsplit("::", 1)[0] == parent else q)
    return f"{located[0][0]} ({', '.join(parts)})"


AXIS_PRECONDITIONS_FILE = "axis-preconditions.ts"

AXIS_PRECONDITION_PREAMBLE = """// Cross-axis precondition evaluators (E6), from the AxisPrecondition declarations.
// No imports: usable from any runtime. The guard (axis-guard.ts) decides whether a
// move is permitted at all; these decide whether its preconditions hold.

export type AxisPreconditionOutcome = 'pass' | 'fail' | 'indeterminate';

/**
 * The axis values an evaluator reads: the moving instance's own axis tuple,
 * and each related instance's axis tuple by the name of the reference to it.
 */
export interface AxisPreconditionContext {
  readonly self: Readonly<Record<string, string>>;
  readonly related?: Readonly<Record<string, Readonly<Record<string, string>> | null | undefined>>;
}

export interface AxisPreconditionResult {
  readonly precondition: string;
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  /** The reference to the related instance; null for the same instance. */
  readonly relatedVia: string | null;
  /** The type whose axis is read. */
  readonly relatedType: string;
  readonly requiredAxis: string;
  readonly requiredValues: readonly string[];
  /** The value found, or null when it was not supplied. */
  readonly actualValue: string | null;
  readonly outcome: AxisPreconditionOutcome;
  /** The model's rejectionReason when the outcome is not pass; null on pass. */
  readonly reason: string | null;
}

export interface AxisPreconditionRejection {
  readonly ok: false;
  readonly code: 'preconditionNotMet';
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  /** The rejectionReason of every precondition that did not pass. */
  readonly reasons: readonly string[];
  readonly results: readonly AxisPreconditionResult[];
}

export type AxisPreconditionVerdict =
  | { readonly ok: true; readonly type: string; readonly axis: string; readonly transition: string; readonly results: readonly AxisPreconditionResult[] }
  | AxisPreconditionRejection;

interface PreconditionDecl {
  readonly precondition: string;
  readonly type: string;
  readonly axis: string;
  readonly transition: string;
  readonly relatedVia: string | null;
  readonly relatedType: string;
  readonly requiredAxis: string;
  readonly requiredValues: readonly string[];
  readonly rejectionReason: string;
}

function evaluate(d: PreconditionDecl, ctx: AxisPreconditionContext): AxisPreconditionResult {
  const tuple = d.relatedVia === null ? ctx.self : ctx.related?.[d.relatedVia];
  const actual = tuple?.[d.requiredAxis];
  const actualValue = typeof actual === 'string' ? actual : null;
  const outcome: AxisPreconditionOutcome =
    actualValue === null ? 'indeterminate' : d.requiredValues.includes(actualValue) ? 'pass' : 'fail';
  const where = d.relatedVia === null ? d.requiredAxis : `${d.relatedVia}.${d.requiredAxis}`;
  const reason =
    outcome === 'pass'
      ? null
      : outcome === 'fail'
        ? d.rejectionReason
        : `${d.rejectionReason} (${where} was not supplied, so the precondition cannot be shown to hold.)`;
  return {
    precondition: d.precondition, type: d.type, axis: d.axis, transition: d.transition,
    relatedVia: d.relatedVia, relatedType: d.relatedType, requiredAxis: d.requiredAxis,
    requiredValues: d.requiredValues, actualValue, outcome, reason,
  };
}

function verdict(type: string, axis: string, transition: string, results: AxisPreconditionResult[]): AxisPreconditionVerdict {
  const failed = results.filter((r) => r.outcome !== 'pass');
  if (failed.length === 0) return { ok: true, type, axis, transition, results };
  return {
    ok: false, code: 'preconditionNotMet', type, axis, transition,
    reasons: failed.map((r) => r.reason ?? ''), results,
  };
}
"""


def _ts(s):
    return "null" if s is None else "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def emit_axis_preconditions(types, header):
    """Generate axis-preconditions.ts: one evaluator per declared AxisPrecondition."""
    L = [header.rstrip("\n"), "", AXIS_PRECONDITION_PREAMBLE.rstrip("\n"), ""]
    registry = []
    for t in types:
        for ax in t.axes:
            for mv in ax.moves:
                fns = []
                for p in mv.preconditions:
                    fn = f"evaluate{ax.ident}{upper_first(mv.name)}{upper_first(p.name)}"
                    fns.append(fn)
                    req = ", ".join(_ts(v) for v in p.required_values)
                    L.append(f"/** {t.name} {ax.name}, {mv.name} ({mv.source} -> {mv.target}): {p.name}. */")
                    L.append(f"export function {fn}(ctx: AxisPreconditionContext): AxisPreconditionResult {{")
                    L.append("  return evaluate(")
                    L.append("    {")
                    L.append(f"      precondition: {_ts(p.name)}, type: {_ts(t.name)}, axis: {_ts(ax.name)}, transition: {_ts(mv.name)},")
                    L.append(f"      relatedVia: {_ts(p.related_via)}, relatedType: {_ts(p.related_type)}, requiredAxis: {_ts(p.required_axis)},")
                    L.append(f"      requiredValues: [{req}],")
                    L.append(f"      rejectionReason: {_ts(p.rejection_reason)},")
                    L.append("    },")
                    L.append("    ctx,")
                    L.append("  );")
                    L.append("}")
                    L.append("")
                if fns:
                    registry.append((t.name, ax.name, mv.name, fns))
    L.append("/** The evaluators of each move that has preconditions, by type, axis and transition. */")
    L.append("export const axisPreconditionEvaluators: Readonly<Record<string, Readonly<Record<string, Readonly<Record<string, readonly ((ctx: AxisPreconditionContext) => AxisPreconditionResult)[]>>>>>> = {")
    by_type = {}
    for tname, aname, mname, fns in registry:
        by_type.setdefault(tname, {}).setdefault(aname, []).append((mname, fns))
    for tname, axes in by_type.items():
        L.append(f"  {tname}: {{")
        for aname, moves in axes.items():
            L.append(f"    {_ts(aname)}: {{")
            for mname, fns in moves:
                L.append(f"      {mname}: [{', '.join(fns)}],")
            L.append("    },")
        L.append("  },")
    L.append("};")
    L.append("")
    L.append("/**")
    L.append(" * Every precondition of a move, named as the guard's accepted result names it")
    L.append(" * (type, axis, transition). A move with no preconditions passes.")
    L.append(" */")
    L.append("export function evaluateAxisMovePreconditions(")
    L.append("  type: string,")
    L.append("  axis: string,")
    L.append("  transition: string,")
    L.append("  ctx: AxisPreconditionContext,")
    L.append("): AxisPreconditionVerdict {")
    L.append("  const fns = axisPreconditionEvaluators[type]?.[axis]?.[transition] ?? [];")
    L.append("  return verdict(type, axis, transition, fns.map((fn) => fn(ctx)));")
    L.append("}")
    L.append("")
    return "\n".join(L)


def generate(model_dir, out_dir, root, constraint_package, spec_package, platform_dir, model_name, verbose=True):
    if (constraint_package is None) != (spec_package is None):
        raise ModelError("pass both --constraint-package and --spec-package, or neither")
    rm = resolved.load(model_dir, root, also=(platform_dir,) if platform_dir is not None else ())
    written = []
    if constraint_package is not None:
        written += _generate_constraints(rm, out_dir, root, constraint_package, spec_package,
                                         platform_dir, model_name, verbose)
    types = [t for t in rm.axis_types() if any(mv.preconditions for ax in t.axes for mv in ax.moves)]
    if types:
        head = make_header(__file__, [t.source for t in types], model_name)
        written.append(write(out_dir, AXIS_PRECONDITIONS_FILE, emit_axis_preconditions(types, head)))
        if verbose:
            n = sum(len(mv.preconditions) for t in types for ax in t.axes for mv in ax.moves)
            print(f"  wrote {written[-1]} ({n} axis preconditions)")
    if not written:
        raise ModelError("nothing to generate: no constraint packages given and no AxisPrecondition declared")
    return written


def _generate_constraints(rm, out_dir, root, constraint_package, spec_package, platform_dir, model_name, verbose):
    reader = Reader(rm)
    platform_documents = set()
    for f in sorted(Path(platform_dir).resolve().rglob("*.sysml")):
        platform_documents |= {rel_path(f, root), rel_path(f, resolved.REPO)}

    lib_file, lib_q = locate_package(reader, constraint_package)
    spec_file, spec_q = locate_package(reader, spec_package)

    # Read
    constraints = parse_constraint_defs(reader, lib_q)
    constraint_specs = parse_evaluation_specs(reader, spec_q)
    dt_specs = parse_decision_table_specs(reader, spec_q)

    # Cross-reference: attach severity from specs to constraints
    spec_by_name = {s["constraintName"]: s for s in constraint_specs}
    for c in constraints:
        spec = spec_by_name.get(c["name"])
        if spec:
            c["severity"] = spec["severity"]
            c["specUsageName"] = spec["usageName"]

    if verbose:
        print(f"Parsed {len(constraints)} constraint defs from {lib_q}:")
        for c in constraints:
            inputs_str = ", ".join(f"{i['name']}: {i['type']}" for i in c["inputs"])
            _, ok = translate_expression(c.get("expression", ""), c["inputs"])
            status = "translated" if ok else "needs manual implementation"
            print(f"  {c['name']}({inputs_str}) -> satisfies {c.get('satisfies', '?')} [{status}]")
        print(f"Parsed {len(constraint_specs)} constraint evaluation specs and "
              f"{len(dt_specs)} decision table evaluation specs from {spec_q}")

    types_header = make_header(__file__, [pattern_source(reader, platform_documents)], model_name)
    evaluators_header = make_header(__file__, [f"{lib_file} ({lib_q})"], model_name)
    specs_header = make_header(__file__, [f"{spec_file} ({spec_q})"], model_name)

    written = [
        write(out_dir, "evaluation-types.ts", emit_types(types_header)),
        write(out_dir, "constraint-evaluators.ts", emit_evaluators(constraints, evaluators_header)),
        write(out_dir, "constraint-specs.ts", emit_specs(constraint_specs, dt_specs, specs_header)),
    ]
    if verbose:
        for p in written:
            print(f"  wrote {p}")
    return written


def main(argv=None):
    p = base_parser("Generate E6 constraint evaluators from a tenant model.")
    p.add_argument("--constraint-package", default=None, help="package holding the constraint defs")
    p.add_argument("--spec-package", default=None, help="package holding the evaluation spec usages")
    p.add_argument("--platform-model", type=Path, default=Path("model"),
                   help="platform model folder holding the pattern packages (default: model)")
    p.add_argument("--quiet", action="store_true")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.constraint_package, a.spec_package,
                 a.platform_model, a.model_name, verbose=not a.quiet)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
