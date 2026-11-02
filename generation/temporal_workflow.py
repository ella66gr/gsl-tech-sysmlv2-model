#!/usr/bin/env python3
"""
Temporal workflow generator (platform-general).

For every ``action def`` carrying ``@TemporalWorkflow`` in the tenant model
folder it writes two files, named from the workflow's ``workflowName``:

1. ``<workflow>.ts``        the TypeScript workflow function.
2. ``<workflow>-steps.ts``  the workflow's identity (name, task queue,
                            signals, state query) and its step table with
                            each step's expected duration: the audit
                            expectations. No imports.

What it reads from the model, through OpenSysML's resolved model
(generation.resolved, S0.5 Pass A4; annotations are those written inside
the element they describe):

- ``@TemporalWorkflow { workflowName; taskQueue; }`` on the action def;
- the action def's ``in item <name> : <Type>;`` as the workflow input;
- each ``action`` step in source order, which must agree with its ``then``
  successions: ``@TemporalActivity { activityName }`` gives an activity
  call, ``@TemporalSignal { signalName; timeoutMinutes }`` a signal wait
  with a durable timer of ``timeoutMinutes``;
- ``@StateTransitionTrigger { eventName }`` on a step: after the step, the
  workflow raises that event on the status axis whose move carries it as
  its ``triggerEvent`` (an axis of the input type, see
  generation.status_axes), through the generated guard's trace function
  (see generation.state_machine). The workflow tracks the axis value in its
  own state, which is private realiser storage: the stored axis is
  authoritative, and the workflow writes no axis, so no authority is
  checked. A trace the guard refuses fails the workflow, non-retryably.

The timer in the workflow and the expected minutes in the step table come
from the same ``timeoutMinutes`` annotation, in the same run.

Checks made at generation time (each is an error):
- a trigger names an event that no move on the input type's axes carries,
  or the triggers name events of two axes;
- walking the steps from the axis's default value, a trigger has no move
  from the value the axis holds at that step;
- a step has no Temporal annotation, or the steps break their succession.

Usage (from the repository root):
    python3 -m generation.temporal_workflow --model <tenant model folder> --out <folder> \\
        [--workflow <workflowName>] [--activities-import ./activities.js] \\
        [--input-type <type exported by the activities module>] \\
        [--lifecycle-import <module specifier of the generated axis guard>] [--model-name <name>]

Timer expiry: the model declares the timeout but not what expiry means, so
the workflow logs the expiry and keeps waiting for the signal. Nothing is
invented beyond that.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation.state_machine import GUARD_FILE
from generation import resolved
from generation.status_axes import Axis, AxisType
from generation.common import ModelError, kebab, lower_first, upper_first

# Platform defaults for activity calls. The model has no annotation for them yet.
ACTIVITY_START_TO_CLOSE = "1 minute"
ACTIVITY_MAX_ATTEMPTS = 3


@dataclass
class Step:
    name: str
    kind: str  # "activity" | "signal"
    temporal_name: str  # activityName or signalName
    timeout_minutes: int | None  # signals only; None when absent or 0
    event: str | None  # @StateTransitionTrigger eventName


@dataclass
class Workflow:
    def_name: str  # the action def's name
    source: str  # ``path (Qualified::Name)``, for the header
    workflow_name: str
    task_queue: str
    input_name: str
    input_type: str
    steps: list[Step]
    axis: Axis | None


def _bare_steps(graph: resolved.ElementGraph, e: dict) -> list[str]:
    """Named action usages anywhere inside ``e`` that have no body, in source order."""
    out = []
    for m in graph.member_list(e):
        if m["@type"] == "ActionUsage" and m.get("declaredName"):
            if not m.get("sysx:hasBody"):
                out.append(m["declaredName"])
            out += _bare_steps(graph, m)
    return out


def _parse_steps(graph: resolved.ElementGraph, wf_def: dict) -> list[Step]:
    def_name = wf_def["declaredName"]
    bare = _bare_steps(graph, wf_def)
    if bare:
        raise ModelError(
            f"workflow {def_name!r}: step(s) {', '.join(bare)} have no body, so carry no Temporal annotation"
        )
    steps: list[Step] = []
    order: list[str] = []
    succ: list[str] = []
    for m in graph.member_list(wf_def):
        if m["@type"] == "SuccessionAsUsage":
            succ += [x.get("declaredName") or "" for x in graph.get(m, "targetFeature")]
            continue
        if m["@type"] != "ActionUsage" or not m.get("declaredName"):
            continue
        name = m["declaredName"]
        order.append(name)
        act = graph.metadata(m, "TemporalActivity")
        sig = graph.metadata(m, "TemporalSignal")
        trig = graph.metadata(m, "StateTransitionTrigger")
        event = trig.get("eventName") if trig else None
        if act and sig:
            raise ModelError(f"step {name!r} carries both @TemporalActivity and @TemporalSignal")
        if act:
            steps.append(Step(name, "activity", act.get("activityName", name), None, event))
        elif sig:
            minutes = int(sig.get("timeoutMinutes", 0) or 0)
            steps.append(Step(name, "signal", sig.get("signalName", name), minutes or None, event))
        else:
            raise ModelError(f"step {name!r} of {def_name!r} has no @TemporalActivity or @TemporalSignal")
    # The successions must follow source order, because the workflow runs the steps in sequence.
    expected = order[1:]
    if succ and succ != expected:
        raise ModelError(
            f"workflow {def_name!r}: successions {succ} do not follow the step order {order}"
        )
    return steps


def _input(graph: resolved.ElementGraph, wf_def: dict) -> tuple[str, str] | None:
    """The first ``in item <name> : <Type>;`` of the action def: (name, type name)."""
    for m in graph.member_list(wf_def):
        if m["@type"] == "ItemUsage" and m.get("direction") == "in" and m.get("declaredName"):
            types = graph.get(m, "type")
            if types and types[0].get("declaredName"):
                return m["declaredName"], types[0]["declaredName"]
    return None


def _axis_for(steps: list[Step], types: list[AxisType], input_type: str, wf_name: str) -> Axis | None:
    events = [s.event for s in steps if s.event]
    if not events:
        return None
    own = [t for t in types if t.name == input_type]
    pool = [a for t in (own or types) for a in t.axes]
    where = f"a status axis of {input_type}" if own else "any status axis"
    owners: list[Axis] = []
    for ev in events:
        hits = [a for a in pool if any(m.event_name == ev for m in a.moves)]
        if not hits:
            raise ModelError(f"workflow {wf_name!r}: trigger {ev!r} is not the triggerEvent of a move on {where}")
        if len(hits) > 1:
            raise ModelError(f"workflow {wf_name!r}: trigger {ev!r} is carried by more than one axis")
        if hits[0] not in owners:
            owners.append(hits[0])
    if len(owners) > 1:
        raise ModelError(f"workflow {wf_name!r}: triggers raise events of more than one axis")
    return owners[0]


def check_trigger_path(wf: Workflow) -> None:
    """Walk the steps from the axis default; every trigger must be a permitted move."""
    ax = wf.axis
    if ax is None:
        return
    value = ax.default
    for s in wf.steps:
        if not s.event:
            continue
        move = next((m for m in ax.moves if m.source == value and m.event_name == s.event), None)
        if move is None:
            raise ModelError(
                f"step {s.name!r} triggers {s.event!r}, but {ax.type_name} {ax.name} has no move on it from "
                f"{value!r}"
            )
        value = move.target


def parse_workflows(graph: resolved.ElementGraph, types: list[AxisType], only: str | None) -> list[Workflow]:
    out = []
    for wf_def in graph.definitions("ActionDefinition"):
        wf_meta = graph.metadata(wf_def, "TemporalWorkflow")
        if not wf_meta:
            continue
        def_name = wf_def["declaredName"]
        name = wf_meta.get("workflowName", lower_first(def_name))
        if only and name != only:
            continue
        inp = _input(graph, wf_def)
        if not inp:
            raise ModelError(f"workflow {def_name!r} has no `in item <name> : <Type>;` input")
        steps = _parse_steps(graph, wf_def)
        wf = Workflow(
            def_name=def_name,
            source=graph.source(wf_def),
            workflow_name=name,
            task_queue=wf_meta.get("taskQueue", "default"),
            input_name=inp[0],
            input_type=inp[1],
            steps=steps,
            axis=_axis_for(steps, types, inp[1], name),
        )
        check_trigger_path(wf)
        out.append(wf)
    if only and not out:
        raise ModelError(f"no @TemporalWorkflow with workflowName {only!r}")
    return out


# -- Rendering ----------------------------------------------------------


def _s(text: str) -> str:
    """A single-quoted TypeScript string literal."""
    return "'" + text.replace("\\", "\\\\").replace("'", "\\'") + "'"


def render_workflow(wf: Workflow, head: str, activities_import: str, input_type: str, lifecycle_import: str) -> str:
    ax = wf.axis
    acts = []
    for s in wf.steps:
        if s.kind == "activity" and s.temporal_name not in acts:
            acts.append(s.temporal_name)
    sigs = [s for s in wf.steps if s.kind == "signal"]

    wf_imports = ["condition", "defineSignal", "log", "proxyActivities", "setHandler", "workflowInfo"]
    if ax:
        wf_imports += ["ApplicationFailure", "defineQuery"]
    wf_imports.sort(key=str.lower)

    L = [head.rstrip("\n"), ""]
    L.append("import {")
    L += [f"  {n}," for n in wf_imports]
    L.append("} from '@temporalio/workflow';")
    L.append("")
    L.append(f"import type * as activities from {_s(activities_import)};")
    if ax:
        L.append(f"import {{ trace{ax.ident}Move, {ax.lower_ident}Default }} from {_s(lifecycle_import)};")
    L.append("")
    if acts:
        L.append("// -- Activity proxy (platform defaults: the model sets no activity timeout) --")
        L.append("")
        L.append("const {")
        L += [f"  {a}," for a in acts]
        L.append("} = proxyActivities<typeof activities>({")
        L.append(f"  startToCloseTimeout: {_s(ACTIVITY_START_TO_CLOSE)},")
        L.append("  retry: {")
        L.append(f"    maximumAttempts: {ACTIVITY_MAX_ATTEMPTS},")
        L.append("  },")
        L.append("});")
        L.append("")
    if sigs:
        L.append("// -- Signals: one per @TemporalSignal step --")
        L.append("")
        for s in sigs:
            L.append(f"export const {s.temporal_name}Signal = defineSignal({_s(s.temporal_name)});")
        L.append("")
    if ax:
        query = f"{ax.lower_ident}State"
        L.append(f"// -- Query: the {ax.type_name} {ax.name} value the workflow has reached --")
        L.append("")
        L.append(f"export const {query}Query = defineQuery<string>({_s(query)});")
        L.append("")
    L.append("// -- Workflow function --")
    L.append("")
    L.append(
        f"export async function {wf.workflow_name}({wf.input_name}: activities.{input_type}): Promise<string> {{"
    )
    L.append("  const ids = { workflowId: workflowInfo().workflowId };")
    if ax:
        L.append(f"  let state: string = {ax.lower_ident}Default;")
        L.append("")
        L.append(f"  // Raise an event on {ax.type_name} {ax.name}. The guard refuses a move the axis does not permit.")
        L.append("  const raise = (event: string): void => {")
        L.append(f"    const r = trace{ax.ident}Move(state, event);")
        L.append("    if (!r.ok) {")
        L.append(f"      throw ApplicationFailure.nonRetryable(r.reason, {_s('AxisMoveRejected')}, r);")
        L.append("    }")
        L.append("    log.info('Axis move', { ...ids, axis: r.axis, event, from: r.from, to: r.to });")
        L.append("    state = r.to;")
        L.append("  };")
        L.append("")
        L.append(f"  setHandler({ax.lower_ident}StateQuery, () => state);")
    if sigs:
        L.append("")
        L.append("  // Set by the signal handlers.")
        for s in sigs:
            L.append(f"  let {s.temporal_name} = false;")
        L.append("")
        for s in sigs:
            L.append(f"  setHandler({s.temporal_name}Signal, () => {{")
            L.append(f"    log.info({_s('Signal received: ' + s.temporal_name)}, ids);")
            L.append(f"    {s.temporal_name} = true;")
            L.append("  });")
    L.append("")
    L.append(f"  log.info({_s('Workflow started: ' + wf.workflow_name)}, ids);")
    for n, s in enumerate(wf.steps, start=1):
        L.append("")
        if s.kind == "activity":
            L.append(f"  // -- Step {n}: {s.name} (activity {s.temporal_name}) --")
            L.append(f"  await {s.temporal_name}({wf.input_name});")
            L.append(f"  log.info({_s('Activity completed: ' + s.temporal_name)}, ids);")
        else:
            timer = f", timer {s.timeout_minutes} minutes" if s.timeout_minutes else ""
            L.append(f"  // -- Step {n}: {s.name} (signal {s.temporal_name}{timer}) --")
            L.append(f"  log.info({_s('Waiting for signal: ' + s.temporal_name)}, ids);")
            if s.timeout_minutes:
                L.append(
                    f"  if (!(await condition(() => {s.temporal_name}, {_s(f'{s.timeout_minutes} minutes')}))) {{"
                )
                L.append(
                    f"    log.warn({_s(f'Timer expired: {s.name}, {s.timeout_minutes} minutes without {s.temporal_name}')}, ids);"
                )
                L.append(f"    await condition(() => {s.temporal_name});")
                L.append("  }")
            else:
                L.append(f"  await condition(() => {s.temporal_name});")
        if s.event:
            L.append(f"  raise({_s(s.event)});")
    L.append("")
    L.append(f"  return {_s(wf.workflow_name + ' completed')};")
    L.append("}")
    L.append("")
    return "\n".join(L)


def render_steps(wf: Workflow, head: str) -> str:
    p, P = lower_first(wf.workflow_name), upper_first(wf.workflow_name)
    sigs = [s.temporal_name for s in wf.steps if s.kind == "signal"]
    L = [head.rstrip("\n"), ""]
    L.append(f"// Identity and step table of the {wf.workflow_name} workflow. Each step's expectedMinutes")
    L.append("// is its @TemporalSignal timeoutMinutes, the same value the workflow's timer uses:")
    L.append("// these are the audit expectations. No imports.")
    L.append("")
    L.append(f"export const {p}WorkflowName = {_s(wf.workflow_name)};")
    L.append(f"export const {p}TaskQueue = {_s(wf.task_queue)};")
    if wf.axis:
        L.append(f"export const {p}StateQuery = {_s(wf.axis.lower_ident + 'State')};")
    L.append("")
    L.append(f"export const {p}Signals = [{', '.join(_s(s) for s in sigs)}] as const;")
    L.append(f"export type {P}Signal = (typeof {p}Signals)[number];")
    L.append("")
    L.append(f"export const {p}StepIds = [{', '.join(_s(s.name) for s in wf.steps)}] as const;")
    L.append(f"export type {P}StepId = (typeof {p}StepIds)[number];")
    L.append("")
    L.append(f"export interface {P}Step {{")
    L.append(f"  readonly stepId: {P}StepId;")
    L.append("  readonly type: 'activity' | 'signal';")
    L.append("  /** The activityName or signalName, as it appears in the Temporal event history. */")
    L.append("  readonly temporalName: string;")
    L.append("  /** @TemporalSignal timeoutMinutes; null where the model declares no timeout. */")
    L.append("  readonly expectedMinutes: number | null;")
    L.append("  /** The axis event the step raises (@StateTransitionTrigger), or null. */")
    L.append("  readonly stateEvent: string | null;")
    L.append("}")
    L.append("")
    L.append(f"export const {p}Steps: readonly {P}Step[] = [")
    for s in wf.steps:
        minutes = str(s.timeout_minutes) if s.timeout_minutes else "null"
        event = _s(s.event) if s.event else "null"
        L.append(
            f"  {{ stepId: {_s(s.name)}, type: {_s(s.kind)}, temporalName: {_s(s.temporal_name)}, "
            f"expectedMinutes: {minutes}, stateEvent: {event} }},"
        )
    L.append("];")
    L.append("")
    return "\n".join(L)


def generate(
    model: Path,
    out: Path,
    root: Path,
    workflow: str | None,
    activities_import: str,
    input_type: str | None,
    lifecycle_import: str | None,
    model_name: str | None,
) -> list[Path]:
    rm = resolved.load(model, root)
    types = rm.axis_types()
    wfs = parse_workflows(rm.elements(), types, workflow)
    if not wfs:
        raise ModelError("no @TemporalWorkflow action def found in the model folder")
    written = []
    for wf in wfs:
        sources = [wf.source]
        if wf.axis:
            src = next(t.source for t in types if t.name == wf.axis.type_name)
            sources.append(src)
        head = header(__file__, sources, model_name)
        stem = kebab(wf.workflow_name)
        guard = lifecycle_import or (f"./{GUARD_FILE[:-3]}.js" if wf.axis else "")
        written.append(
            write(out, f"{stem}.ts", render_workflow(wf, head, activities_import, input_type or wf.input_type, guard))
        )
        written.append(write(out, f"{stem}-steps.ts", render_steps(wf, head)))
        timers = [f"{s.name} {s.timeout_minutes} min" for s in wf.steps if s.timeout_minutes]
        events = [s.event for s in wf.steps if s.event]
        print(
            f"wrote {stem}.ts and {stem}-steps.ts: {len(wf.steps)} steps; timers: {', '.join(timers) or 'none'}; "
            f"events: {', '.join(events) or 'none'}"
        )
    return written


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate Temporal workflows and their step tables from @TemporalWorkflow action defs.")
    p.add_argument("--workflow", default=None, help="generate only this workflowName (default: every workflow)")
    p.add_argument("--activities-import", default="./activities.js", help="module specifier of the activities")
    p.add_argument(
        "--input-type",
        default=None,
        help="input type exported by the activities module (default: the model's `in item` type)",
    )
    p.add_argument(
        "--lifecycle-import",
        default=None,
        help="module specifier of the generated axis guard (default: ./axis-guard.js)",
    )
    a = p.parse_args(argv)
    try:
        generate(
            a.model, a.out, a.root, a.workflow, a.activities_import, a.input_type, a.lifecycle_import, a.model_name
        )
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
