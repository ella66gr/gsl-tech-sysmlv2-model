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

What it reads from the model:

- ``@TemporalWorkflow { workflowName; taskQueue; }`` on the action def;
- the action def's ``in item <name> : <Type>;`` as the workflow input;
- each ``action`` step in source order, which must agree with its ``then``
  successions: ``@TemporalActivity { activityName }`` gives an activity
  call, ``@TemporalSignal { signalName; timeoutMinutes }`` a signal wait
  with a durable timer of ``timeoutMinutes``;
- ``@StateTransitionTrigger { eventName }`` on a step: after the step, the
  workflow raises that event on the lifecycle that declares it, through
  the generated lifecycle guard (see generation.state_machine).

The timer in the workflow and the expected minutes in the step table come
from the same ``timeoutMinutes`` annotation, in the same run.

Checks made at generation time (each is an error):
- a trigger names an event no lifecycle declares, or events from two
  lifecycles;
- walking the steps from the lifecycle's initial state, a trigger has no
  transition from the state the order is in at that step. An event that
  enters the initial state is not a transition and must not be a trigger;
- a step has no Temporal annotation, or the steps break their succession.

Usage (from the repository root):
    python3 -m generation.temporal_workflow --model <tenant model folder> --out <folder> \\
        [--workflow <workflowName>] [--activities-import ./activities.js] \\
        [--input-type <type exported by the activities module>] \\
        [--lifecycle-import <module specifier of the generated guard>] [--model-name <name>]

Timer expiry: the model declares the timeout but not what expiry means, so
the workflow logs the expiry and keeps waiting for the signal. Nothing is
invented beyond that.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation.state_machine import Lifecycle, lifecycles
from generation.sysml_text import (
    Found,
    ModelError,
    braced_body,
    find_all,
    kebab,
    load_model,
    lower_first,
    metadata,
    mask_comments,
    upper_first,
)

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
    found: Found
    workflow_name: str
    task_queue: str
    input_name: str
    input_type: str
    steps: list[Step]
    lifecycle: Lifecycle | None


def _parse_steps(found: Found) -> list[Step]:
    body = mask_comments(found.body)
    steps: list[Step] = []
    pos = 0
    order: list[str] = []
    bare = re.findall(r"\baction\s+(?!def\b)(\w+)\s*;", body)
    if bare:
        raise ModelError(
            f"workflow {found.name!r}: step(s) {', '.join(bare)} have no body, so carry no Temporal annotation"
        )
    for m in re.finditer(r"\baction\s+(?!def\b)(\w+)\s*\{", body):
        if m.start() < pos:
            continue  # nested inside the previous step
        sbody, close = braced_body(body, m.end() - 1)
        pos = close
        name = m.group(1)
        order.append(name)
        act = metadata(sbody, "TemporalActivity")
        sig = metadata(sbody, "TemporalSignal")
        trig = metadata(sbody, "StateTransitionTrigger")
        event = trig.get("eventName") if trig else None
        if act and sig:
            raise ModelError(f"step {name!r} carries both @TemporalActivity and @TemporalSignal")
        if act:
            steps.append(Step(name, "activity", act.get("activityName", name), None, event))
        elif sig:
            minutes = int(sig.get("timeoutMinutes", "0"))
            steps.append(Step(name, "signal", sig.get("signalName", name), minutes or None, event))
        else:
            raise ModelError(f"step {name!r} of {found.name!r} has no @TemporalActivity or @TemporalSignal")
    # The successions must follow source order, because the workflow runs the steps in sequence.
    succ = re.findall(r"\bthen\s+(\w+)\s*;", _without_nested(body))
    expected = order[1:]
    if succ and succ != expected:
        raise ModelError(
            f"workflow {found.name!r}: successions {succ} do not follow the step order {order}"
        )
    return steps


def _without_nested(body: str) -> str:
    out, depth = [], 0
    for c in body:
        if c == "{":
            depth += 1
            continue
        if c == "}":
            depth -= 1
            continue
        if depth == 0:
            out.append(c)
    return "".join(out)


def _lifecycle_for(steps: list[Step], lcs: list[Lifecycle], wf_name: str) -> Lifecycle | None:
    events = [s.event for s in steps if s.event]
    if not events:
        return None
    owners = []
    for ev in events:
        hits = [lc for lc in lcs if ev in lc.events]
        if not hits:
            raise ModelError(f"workflow {wf_name!r}: trigger {ev!r} is not an event of any state def")
        if len(hits) > 1:
            raise ModelError(f"workflow {wf_name!r}: trigger {ev!r} is declared beside more than one state def")
        if hits[0] not in owners:
            owners.append(hits[0])
    if len(owners) > 1:
        raise ModelError(f"workflow {wf_name!r}: triggers raise events of more than one lifecycle")
    return owners[0]


def check_trigger_path(wf: Workflow) -> None:
    """Walk the steps from the initial state; every trigger must be a legal transition."""
    lc = wf.lifecycle
    if lc is None:
        return
    state = lc.initial
    for s in wf.steps:
        if not s.event:
            continue
        nxt = lc.next_state(state, s.event)
        if nxt is None:
            hint = ""
            if state == lc.initial and all(t.event != s.event for t in lc.transitions):
                hint = (
                    f" {s.event!r} has no transition at all; if it is the event that enters the "
                    f"initial state {lc.initial!r}, it is not a transition and the trigger should go"
                )
            raise ModelError(
                f"step {s.name!r} triggers {s.event!r}, but {lc.name} has no transition on it from "
                f"{state!r}.{hint}"
            )
        state = nxt


def parse_workflows(files, only: str | None) -> list[Workflow]:
    lcs = lifecycles(files)
    out = []
    for found in find_all(files, r"action\s+def"):
        wf_meta = metadata(found.body, "TemporalWorkflow")
        if not wf_meta:
            continue
        name = wf_meta.get("workflowName", lower_first(found.name))
        if only and name != only:
            continue
        m = re.search(r"\bin\s+item\s+(\w+)\s*:\s*(\w+)\s*;", found.body)
        if not m:
            raise ModelError(f"workflow {found.name!r} has no `in item <name> : <Type>;` input")
        steps = _parse_steps(found)
        wf = Workflow(
            found=found,
            workflow_name=name,
            task_queue=wf_meta.get("taskQueue", "default"),
            input_name=m.group(1),
            input_type=m.group(2),
            steps=steps,
            lifecycle=_lifecycle_for(steps, lcs, name),
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
    lc = wf.lifecycle
    acts = []
    for s in wf.steps:
        if s.kind == "activity" and s.temporal_name not in acts:
            acts.append(s.temporal_name)
    sigs = [s for s in wf.steps if s.kind == "signal"]

    wf_imports = ["condition", "defineSignal", "log", "proxyActivities", "setHandler", "workflowInfo"]
    if lc:
        wf_imports += ["ApplicationFailure", "defineQuery"]
    wf_imports.sort(key=str.lower)

    L = [head.rstrip("\n"), ""]
    L.append("import {")
    L += [f"  {n}," for n in wf_imports]
    L.append("} from '@temporalio/workflow';")
    L.append("")
    L.append(f"import type * as activities from {_s(activities_import)};")
    if lc:
        L.append(
            f"import {{ next{lc.name}State, {lc.ident}InitialState, type {lc.name}State }} "
            f"from {_s(lifecycle_import)};"
        )
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
    if lc:
        query = f"{lower_first(lc.type_prefix)}State"
        L.append(f"// -- Query: the current {lc.name} state --")
        L.append("")
        L.append(f"export const {query}Query = defineQuery<string>({_s(query)});")
        L.append("")
    L.append("// -- Workflow function --")
    L.append("")
    L.append(
        f"export async function {wf.workflow_name}({wf.input_name}: activities.{input_type}): Promise<string> {{"
    )
    L.append("  const ids = { workflowId: workflowInfo().workflowId };")
    if lc:
        L.append(f"  let state: {lc.name}State = {lc.ident}InitialState;")
        L.append("")
        L.append(f"  // Raise a lifecycle event. The guard refuses an event {lc.name} has no transition for.")
        L.append("  const raise = (event: string): void => {")
        L.append(f"    const next = next{lc.name}State(state, event);")
        L.append("    if (next === null) {")
        L.append("      throw ApplicationFailure.nonRetryable(")
        L.append(f"        `{lc.name} refuses ${{event}} in state ${{state}}`,")
        L.append(f"        {_s('IllegalLifecycleTransition')},")
        L.append("      );")
        L.append("    }")
        L.append("    log.info('Lifecycle transition', { ...ids, event, from: state, to: next });")
        L.append("    state = next;")
        L.append("  };")
        L.append("")
        L.append(f"  setHandler({lower_first(lc.type_prefix)}StateQuery, () => state);")
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
    if wf.lifecycle:
        L.append(f"export const {p}StateQuery = {_s(lower_first(wf.lifecycle.type_prefix) + 'State')};")
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
    L.append("  /** The lifecycle event the step raises (@StateTransitionTrigger), or null. */")
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
    files = load_model(model, root)
    wfs = parse_workflows(files, workflow)
    if not wfs:
        raise ModelError("no @TemporalWorkflow action def found in the model folder")
    written = []
    for wf in wfs:
        sources = [wf.found.source]
        if wf.lifecycle:
            for src in wf.lifecycle.sources:
                if all(src.split(" (")[0] != have.split(" (")[0] for have in sources):
                    sources.append(src)
        head = header(__file__, sources, model_name)
        stem = kebab(wf.workflow_name)
        guard = lifecycle_import or (f"./{wf.lifecycle.guard_module}.js" if wf.lifecycle else "")
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
        help="module specifier of the generated lifecycle guard (default: ./<state-def>-guard.js)",
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
