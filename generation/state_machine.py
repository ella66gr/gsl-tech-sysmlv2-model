#!/usr/bin/env python3
"""
State machine generator (platform-general): axis guard, next-action map
and XState machines, from status axis declarations.

Since S0.4 the generator reads ``StatusAxis`` declarations (see
generation.status_axes), not state definitions, and since S0.5 Pass A4 it
reads everything, axes and signals, through OpenSysML's resolved model
(generation.resolved): the axis declaration is
the single source of each lifecycle. For every ``part def`` in the tenant
model folder that declares status axes it writes, into two files:

1. ``axis-guard.ts``    the guard, with no imports, so any runtime can use
                        it. For each axis: its values, default, terminal
                        values and permitted moves (``<axis>Axis``), a
                        ``check<Type><Axis>Move`` guard, a
                        ``trace<Type><Axis>Move`` lookup for a realiser that
                        tracks the axis privately, and the next-action map
                        ``<type><Axis>NextActions``. Also ``axisSpecs``, every
                        axis by type and axis name.
2. ``axis-machine.ts``  an XState v5 machine per type, with one parallel
                        region per axis.

The guard's result. ``check...Move({ from, to | event, authority })``
returns ``{ ok: true, ... }`` for a permitted move, or a structured
rejection ``{ ok: false, code, type, axis, from, to, event, authority,
reason, permitted }``. It never returns the unchanged value as if the move
had happened. The codes:

- ``unknownValue``       ``from`` or ``to`` is not a value of the axis;
- ``fromTerminalValue``  ``from`` is terminal: no move leaves it;
- ``moveNotPermitted``   no declared move from ``from`` to ``to`` (or on
                         ``event``), including a move to the same value;
- ``authorityNotNamed``  the move exists, but ``authority`` is not one it
                         names (the move's ``requiredAuthority``, else the
                         axis's ``axisAuthority``).

``permitted`` lists the moves the axis does allow from ``from``. An accepted
move lists the names of its preconditions; the generated E6 evaluator
(generation.constraint_evaluator) evaluates them.

The next-action map offers, for each value, the moves an operator (the
``operatorSide`` authority: people at a surface) can make. Each action
carries the model's ``transitionLabel``, the event, and the workflow
signal that raises the event: an ``action`` step carrying both
``@TemporalSignal { signalName }`` and ``@StateTransitionTrigger
{ eventName }``. A move without a ``triggerEvent`` uses its usage name as
its event.

Usage (from the repository root):
    python3 -m generation.state_machine --model <tenant model folder> --out <folder> \\
        [--type <part def name>] [--model-name <name>]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation import resolved
from generation.status_axes import OPERATOR_AUTHORITY, AxisType
from generation.sysml_text import ModelError, lower_first

GUARD_FILE = "axis-guard.ts"
MACHINE_FILE = "axis-machine.ts"


def _q(s: str | None) -> str:
    return "null" if s is None else json.dumps(s, ensure_ascii=False)


def _list(items: list[str]) -> str:
    return "[" + ", ".join(_q(i) for i in items) + "]"


def signals(graph: resolved.ElementGraph) -> tuple[dict[str, str], list[str]]:
    """Event -> signal name, from action steps carrying @TemporalSignal and @StateTransitionTrigger.

    Read from the resolved model (S0.5 Pass A4): every named action usage in
    the tenant's documents, in source order, with the annotations written
    inside it. A source is the step's document and its enclosing packages.
    """
    out: dict[str, str] = {}
    sources: list[str] = []
    for step in graph.definitions("ActionUsage"):
        trig = graph.metadata(step, "StateTransitionTrigger")
        sig = graph.metadata(step, "TemporalSignal")
        if not trig or not sig or not trig.get("eventName"):
            continue
        ev, sn = trig["eventName"], sig.get("signalName", "")
        if ev in out and out[ev] != sn:
            raise ModelError(f"event {ev!r} is raised by two signals: {out[ev]!r} and {sn!r}")
        out[ev] = sn
        src = f"{graph.document(step)} ({'::'.join(graph.packages(step))})"
        if src not in sources:
            sources.append(src)
    return out, sources


# -- Rendering: guard ---------------------------------------------------

GUARD_PREAMBLE = '''// Status axis guards and next-action maps, from the StatusAxis declarations.
// No imports: usable from any runtime, including a Temporal workflow sandbox.

// -- The guard's result shape (the same for every axis) --------------

/** Why a move was refused. */
export type AxisMoveRejectionCode =
  | "unknownValue"
  | "fromTerminalValue"
  | "moveNotPermitted"
  | "authorityNotNamed";

/** One permitted move, as the model declares it. */
export interface AxisMoveSpec {
  /** The AxisTransition usage name. */
  readonly name: string;
  readonly from: string;
  readonly to: string;
  /** The move's triggerEvent, or its usage name when the model gives none. */
  readonly event: string;
  /** The model's transitionLabel. */
  readonly label: string;
  /** The authorities that may make the move. */
  readonly authorities: readonly string[];
  /** Names of the move's preconditions, evaluated by the generated E6 evaluator. */
  readonly preconditions: readonly string[];
}

/** One status axis, as the model declares it. */
export interface AxisSpec {
  readonly type: string;
  readonly axis: string;
  readonly values: readonly string[];
  readonly defaultValue: string;
  /** Values no move leaves. */
  readonly terminalValues: readonly string[];
  /** The axis's axisAuthority. */
  readonly authorities: readonly string[];
  readonly moves: readonly AxisMoveSpec[];
}

/** A requested move: name the target value or the event, and the writer's authority. */
export interface AxisMoveRequest {
  readonly from: string;
  readonly to?: string;
  readonly event?: string;
  readonly authority: string;
}

export interface AxisMoveAccepted {
  readonly ok: true;
  readonly type: string;
  readonly axis: string;
  readonly from: string;
  readonly to: string;
  readonly event: string;
  readonly transition: string;
  /** The writer's authority; null for a trace (no write). */
  readonly authority: string | null;
  /** Preconditions still to evaluate before the move is made. */
  readonly preconditions: readonly string[];
}

export interface AxisMoveRejection {
  readonly ok: false;
  readonly code: AxisMoveRejectionCode;
  readonly type: string;
  readonly axis: string;
  readonly from: string;
  readonly to: string | null;
  readonly event: string | null;
  readonly authority: string | null;
  /** A sentence saying why, built from the model's names. */
  readonly reason: string;
  /** The moves the axis permits from `from` (empty when `from` is terminal or unknown). */
  readonly permitted: readonly AxisMoveSpec[];
}

export type AxisMoveResult = AxisMoveAccepted | AxisMoveRejection;

/** One action a surface may offer: a move an operator can make. */
export interface AxisNextAction {
  readonly event: string;
  readonly target: string;
  readonly transition: string;
  /** The model's transitionLabel. */
  readonly label: string;
  /** The workflow signal that raises the event, or null when no workflow step does. */
  readonly signal: string | null;
  readonly preconditions: readonly string[];
}

function reject(
  spec: AxisSpec,
  code: AxisMoveRejectionCode,
  from: string,
  to: string | null,
  event: string | null,
  authority: string | null,
  reason: string,
): AxisMoveRejection {
  const permitted = spec.moves.filter((m) => m.from === from);
  return { ok: false, code, type: spec.type, axis: spec.axis, from, to, event, authority, reason, permitted };
}

function find(spec: AxisSpec, from: string, to: string | null, event: string | null): AxisMoveSpec | AxisMoveRejection {
  const what = `${spec.type} ${spec.axis}`;
  if (!spec.values.includes(from)) {
    return reject(spec, "unknownValue", from, to, event, null, `${what}: "${from}" is not a value of the axis.`);
  }
  if (to !== null && !spec.values.includes(to)) {
    return reject(spec, "unknownValue", from, to, event, null, `${what}: "${to}" is not a value of the axis.`);
  }
  if (to === null && event === null) {
    return reject(spec, "moveNotPermitted", from, to, event, null, `${what}: the request names neither a target value nor an event.`);
  }
  if (spec.terminalValues.includes(from)) {
    return reject(spec, "fromTerminalValue", from, to, event, null, `${what}: "${from}" is terminal; no move leaves it.`);
  }
  const move = spec.moves.find(
    (m) => m.from === from && (to === null || m.to === to) && (event === null || m.event === event),
  );
  if (move === undefined) {
    const asked = to !== null ? `to "${to}"` : `on ${event}`;
    const allowed = spec.moves.filter((m) => m.from === from).map((m) => `${m.to} (${m.event})`).join(", ");
    return reject(
      spec, "moveNotPermitted", from, to, event, null,
      `${what}: no permitted move from "${from}" ${asked}. Permitted from "${from}": ${allowed}.`,
    );
  }
  return move;
}

/** The guard: is this move, by this authority, permitted on the axis? */
export function checkAxisMove(spec: AxisSpec, request: AxisMoveRequest): AxisMoveResult {
  const to = request.to ?? null;
  const event = request.event ?? null;
  const found = find(spec, request.from, to, event);
  if ("ok" in found) return { ...found, authority: request.authority };
  if (!found.authorities.includes(request.authority)) {
    return reject(
      spec, "authorityNotNamed", request.from, to, event, request.authority,
      `${spec.type} ${spec.axis}: the move ${found.from} -> ${found.to} may be made by ` +
        `${found.authorities.join(" or ")}, not ${request.authority}.`,
    );
  }
  return {
    ok: true, type: spec.type, axis: spec.axis, from: found.from, to: found.to, event: found.event,
    transition: found.name, authority: request.authority, preconditions: found.preconditions,
  };
}

/**
 * The move `event` makes from `from`, for a realiser that tracks the axis in
 * its own private storage (it writes nothing, so no authority is checked).
 * Refuses exactly as the guard does for an unknown, terminal or undeclared move.
 */
export function traceAxisMove(spec: AxisSpec, from: string, event: string): AxisMoveResult {
  const found = find(spec, from, null, event);
  if ("ok" in found) return found;
  return {
    ok: true, type: spec.type, axis: spec.axis, from: found.from, to: found.to, event: found.event,
    transition: found.name, authority: null, preconditions: found.preconditions,
  };
}
'''


def render_guard(types: list[AxisType], sigs: dict[str, str], head: str) -> str:
    L = [head.rstrip("\n"), "", GUARD_PREAMBLE.rstrip("\n"), ""]
    for t in types:
        L.append(f"// -- {t.name} ({t.qualified}) --")
        L.append("")
        for ax in t.axes:
            i, I = ax.lower_ident, ax.ident
            L.append(f"type {I}Value = {' | '.join(_q(v) for v in ax.values)};")
            L.append("")
            L.append(f"/** {t.name} {ax.name} ({ax.usage}): values, default, terminal values and permitted moves. */")
            L.append(f"export const {i}Axis: AxisSpec = {{")
            L.append(f"  type: {_q(t.name)},")
            L.append(f"  axis: {_q(ax.name)},")
            L.append(f"  values: {_list(ax.values)},")
            L.append(f"  defaultValue: {_q(ax.default)},")
            L.append(f"  terminalValues: {_list(ax.terminal_values)},")
            L.append(f"  authorities: {_list(ax.authorities)},")
            L.append("  moves: [")
            for mv in ax.moves:
                L.append(
                    f"    {{ name: {_q(mv.name)}, from: {_q(mv.source)}, to: {_q(mv.target)}, "
                    f"event: {_q(mv.event_name)}, label: {_q(mv.label)}, authorities: {_list(mv.authorities)}, "
                    f"preconditions: {_list([p.name for p in mv.preconditions])} }},"
                )
            L.append("  ],")
            L.append("};")
            L.append("")
            L.append(f"export const {i}Default: {I}Value = {_q(ax.default)};")
            L.append("")
            L.append(f"/** The guard for {t.name} {ax.name}. */")
            L.append(f"export function check{I}Move(request: AxisMoveRequest): AxisMoveResult {{")
            L.append(f"  return checkAxisMove({i}Axis, request);")
            L.append("}")
            L.append("")
            L.append(f"/** The move `event` makes on {t.name} {ax.name}, for a realiser tracking it privately. */")
            L.append(f"export function trace{I}Move(from: string, event: string): AxisMoveResult {{")
            L.append(f"  return traceAxisMove({i}Axis, from, event);")
            L.append("}")
            L.append("")
            L.append(f"/** For each {ax.name} value, the moves an operator ({OPERATOR_AUTHORITY}) can make, in model order. */")
            L.append(f"export const {i}NextActions: Readonly<Record<{I}Value, readonly AxisNextAction[]>> = {{")
            for v in ax.values:
                offered = [m for m in ax.moves if m.source == v and OPERATOR_AUTHORITY in m.authorities]
                if not offered:
                    L.append(f"  {v}: [],")
                    continue
                L.append(f"  {v}: [")
                for m in offered:
                    L.append(
                        f"    {{ event: {_q(m.event_name)}, target: {_q(m.target)}, transition: {_q(m.name)}, "
                        f"label: {_q(m.label)}, signal: {_q(sigs.get(m.event_name))}, "
                        f"preconditions: {_list([p.name for p in m.preconditions])} }},"
                    )
                L.append("  ],")
            L.append("};")
            L.append("")
    L.append("/** Every axis, by type and axis name. */")
    L.append("export const axisSpecs: Readonly<Record<string, Readonly<Record<string, AxisSpec>>>> = {")
    for t in types:
        L.append(f"  {t.name}: {{")
        for ax in t.axes:
            L.append(f"    {_q(ax.name)}: {ax.lower_ident}Axis,")
        L.append("  },")
    L.append("};")
    L.append("")
    return "\n".join(L)


# -- Rendering: XState machines ----------------------------------------


def render_machine(types: list[AxisType], head: str) -> str:
    L = [head.rstrip("\n"), "", 'import { setup } from "xstate";', ""]
    L.append("// One XState machine per type, with one parallel region per status axis.")
    L.append("// The guard (axis-guard.ts) is the check; these machines are its picture.")
    for t in types:
        events: list[str] = []
        for ax in t.axes:
            for mv in ax.moves:
                if mv.event_name not in events:
                    events.append(mv.event_name)
        L.append("")
        L.append(f"export type {t.name}AxisEvent =")
        if not events:
            L.append("  never;")
        for n, ev in enumerate(events):
            lead = "  | " if n else "  "
            end = ";" if n == len(events) - 1 else ""
            L.append(f"{lead}{{ type: {_q(ev)} }}{end}")
        L.append("")
        L.append(f"export const {lower_first(t.name)}AxesMachine = setup({{")
        L.append("  types: {")
        L.append(f"    events: {{}} as {t.name}AxisEvent,")
        L.append("  },")
        L.append("}).createMachine({")
        L.append(f"  id: {_q(t.name)},")
        L.append('  type: "parallel",')
        L.append("  states: {")
        for ax in t.axes:
            terminal = set(ax.terminal_values)
            L.append(f"    {_q(ax.name)}: {{")
            L.append(f"      initial: {_q(ax.default)},")
            L.append("      states: {")
            for v in ax.values:
                L.append(f"        {v}: {{")
                if v in terminal:
                    L.append('          type: "final",')
                else:
                    L.append("          on: {")
                    for mv in ax.moves:
                        if mv.source == v:
                            L.append(f"            {_q(mv.event_name)}: {_q(mv.target)},")
                    L.append("          },")
                L.append("        },")
            L.append("      },")
            L.append("    },")
        L.append("  },")
        L.append("});")
    L.append("")
    return "\n".join(L)


def generate(model: Path, out: Path, root: Path, only_type: str | None, model_name: str | None) -> list[Path]:
    rm = resolved.load(model, root)
    types = rm.axis_types()
    if only_type:
        types = [t for t in types if t.name == only_type]
        if not types:
            raise ModelError(f"part def {only_type!r} declares no status axes")
    if not types:
        raise ModelError("no part def in the model folder declares a status axis (part x : StatusAxis)")
    sigs, sig_sources = signals(rm.elements())
    sources = [t.source for t in types]
    written = [
        write(out, GUARD_FILE, render_guard(types, sigs, header(__file__, sources + sig_sources, model_name))),
        write(out, MACHINE_FILE, render_machine(types, header(__file__, sources, model_name))),
    ]
    for t in types:
        desc = "; ".join(f"{a.name}: {len(a.values)} values, {len(a.moves)} moves, default {a.default}" for a in t.axes)
        print(f"{t.name}: {desc}")
    print(f"wrote {GUARD_FILE} and {MACHINE_FILE}: {len(types)} types, {sum(len(t.axes) for t in types)} axes")
    return written


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate axis guards, next-action maps and XState machines from StatusAxis declarations.")
    p.add_argument("--type", default=None, help="generate only this part def (default: every type with axes)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.type, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
