#!/usr/bin/env python3
"""
State machine generator (platform-general): XState machine, lifecycle
guard and next-action map.

For every ``state def`` in the tenant model folder (or the one named with
``--state-def``) it writes two files:

1. ``<state-def>-machine.ts``  an XState v5 machine with every transition.
2. ``<state-def>-guard.ts``    the lifecycle guard and next-action map, with
                               no imports, so any runtime can use it: the
                               transition table, ``next<StateDef>State``
                               (null when the lifecycle refuses an event),
                               the legal-transition check, and for each
                               state the actions its outgoing transitions
                               offer.

What it reads from the model:

- states (``state x;``) and transitions
  (``transition t first a accept E then b;``) of the state def;
- the initial state: the first state when the body has ``initial;``, or
  the target of ``entry; then x;``;
- events: the ``attribute def``s in the state def's own package;
- each event's action label: ``@UserFacing { friendlyName = "..."; }``
  inside the event's ``attribute def`` body. A transition whose event has
  no label is an error, because labels come from the model, never from
  the generator;
- the signal that raises an event: an ``action`` step carrying both
  ``@TemporalSignal { signalName }`` and
  ``@StateTransitionTrigger { eventName }``;
- the type names: the ``part def`` that ``exhibit state``s the state def
  gives the prefix of ``<Part>Event`` and ``<Part>State``.

Usage (from the repository root):
    python3 -m generation.state_machine --model <tenant model folder> --out <folder> \\
        [--state-def <name>] [--model-name <name>]
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from generation.output import base_parser, header, write
from generation.sysml_text import (
    Found,
    ModelError,
    ModelFile,
    braced_body,
    enclosing_packages,
    find_all,
    find_one,
    kebab,
    load_model,
    lower_first,
    mask_comments,
    metadata,
    remove_doc_blocks,
    top_level_members,
)


@dataclass
class Transition:
    name: str
    source: str
    event: str
    target: str


@dataclass
class Lifecycle:
    """A parsed state def and everything the generators need from it."""

    found: Found
    name: str
    states: list[str]
    initial: str
    transitions: list[Transition]
    events: list[str]
    labels: dict[str, str]  # event -> label
    signals: dict[str, str]  # event -> signal name
    type_prefix: str  # e.g. the exhibiting part def's name
    sources: list[str] = field(default_factory=list)  # header sources

    @property
    def terminal_states(self) -> list[str]:
        out = {t.source for t in self.transitions}
        return [s for s in self.states if s not in out]

    @property
    def ident(self) -> str:
        """Lower-camel identifier stem, e.g. ``orderLifecycle``."""
        return lower_first(self.name)

    @property
    def guard_module(self) -> str:
        return f"{kebab(self.name)}-guard"

    @property
    def machine_module(self) -> str:
        return f"{kebab(self.name)}-machine"

    def next_state(self, state: str, event: str) -> str | None:
        for t in self.transitions:
            if t.source == state and t.event == event:
                return t.target
        return None


def _package_body(files: list[ModelFile], found: Found) -> tuple[Found | None, str]:
    """The package directly enclosing ``found``, and its body."""
    parts = found.qualified.split("::")
    if len(parts) < 2:
        return None, ""
    pkg = find_one(files, r"package", parts[-2], "package")
    return pkg, pkg.body


def _action_steps(files: list[ModelFile]) -> list[tuple[str, str, str]]:
    """Every ``action <name> { ... }`` usage (not ``action def``).

    Returns (header source of its package, step name, body).
    """
    steps = []
    for f in files:
        text = mask_comments(f.text)
        for m in re.finditer(r"\baction\s+(?!def\b)(\w+)\s*\{", text):
            _, close = braced_body(text, m.end() - 1)
            body = f.text[m.end() : close]
            pkgs = enclosing_packages(text, m.start())
            steps.append((f"{f.rel} ({'::'.join(pkgs)})", m.group(1), body))
    return steps


def parse_lifecycle(files: list[ModelFile], found: Found) -> Lifecycle:
    body = mask_comments(found.body)
    flat = top_level_members(remove_doc_blocks(body))

    states = re.findall(r"(?:^|;)\s*state\s+(\w+)\s*(?=;)", flat)
    if not states:
        raise ModelError(f"state def {found.name!r} declares no states")

    initial = None
    m = re.search(r"(?:^|;)\s*entry\s*;\s*then\s+(\w+)\s*;", flat + ";")
    if m:
        initial = m.group(1)
    elif re.search(r"(?:^|;)\s*initial\s*(?=;)", flat):
        initial = states[0]
    if initial is None:
        raise ModelError(f"state def {found.name!r} has no initial state (`initial;` or `entry; then x;`)")
    if initial not in states:
        raise ModelError(f"initial state {initial!r} is not a state of {found.name!r}")

    transitions = []
    for t in re.finditer(r"\btransition\s+(\w+)\s+first\s+(\w+)\s+accept\s+(\w+)\s+then\s+(\w+)", flat):
        tr = Transition(*t.groups())
        for end in (tr.source, tr.target):
            if end not in states:
                raise ModelError(f"transition {tr.name!r} names unknown state {end!r}")
        transitions.append(tr)

    pkg, pkg_body = _package_body(files, found)
    pkg_text = mask_comments(pkg_body)
    events: list[str] = []
    labels: dict[str, str] = {}
    for e in re.finditer(r"\battribute\s+def\s+(\w+)\s*(;|\{)", pkg_text):
        events.append(e.group(1))
        if e.group(2) == "{":
            ebody, _ = braced_body(pkg_text, e.end() - 1)
            uf = metadata(ebody, "UserFacing")
            if uf and uf.get("friendlyName"):
                labels[e.group(1)] = uf["friendlyName"]
    for tr in transitions:
        if tr.event not in events:
            raise ModelError(
                f"transition {tr.name!r} accepts {tr.event!r}, which is not an attribute def "
                f"in the package of {found.name!r}"
            )
    missing = sorted({tr.event for tr in transitions if tr.event not in labels})
    if missing:
        raise ModelError(
            "no action label for event(s) " + ", ".join(missing)
            + ': add @UserFacing { friendlyName = "..."; } inside each event\'s attribute def'
        )

    signals: dict[str, str] = {}
    event_set = set(events)
    signal_sources: list[str] = []
    for ssrc, _name, sbody in _action_steps(files):
        trig = metadata(sbody, "StateTransitionTrigger")
        sig = metadata(sbody, "TemporalSignal")
        if not trig or not sig or trig.get("eventName") not in event_set:
            continue
        ev, sn = trig["eventName"], sig.get("signalName", "")
        if ev in signals and signals[ev] != sn:
            raise ModelError(f"event {ev!r} is raised by two signals: {signals[ev]!r} and {sn!r}")
        signals[ev] = sn
        if ssrc not in signal_sources:
            signal_sources.append(ssrc)

    prefix = found.name
    exhibitors = []
    for part in find_all(files, r"part\s+def"):
        if re.search(rf"\bexhibit\s+state\s+\w+\s*:\s*{re.escape(found.name)}\b", mask_comments(part.body)):
            exhibitors.append(part)
    sources = [found.source]
    if len(exhibitors) == 1:
        prefix = exhibitors[0].name
        sources.append(exhibitors[0].source)
    sources.extend(signal_sources)
    return Lifecycle(
        found=found,
        name=found.name,
        states=states,
        initial=initial,
        transitions=transitions,
        events=events,
        labels=labels,
        signals=signals,
        type_prefix=prefix,
        sources=sources,
    )


def lifecycles(files: list[ModelFile], only: str | None = None) -> list[Lifecycle]:
    found = find_all(files, r"state\s+def", only)
    if only and not found:
        raise ModelError(f"state def {only!r} not found in the model folder")
    return [parse_lifecycle(files, f) for f in found]


# -- Rendering ----------------------------------------------------------


def _q(s: str) -> str:
    return json.dumps(s, ensure_ascii=False)


def render_machine(lc: Lifecycle, head: str) -> str:
    p = lc.type_prefix
    lines = [head.rstrip("\n"), "", 'import { setup } from "xstate";', ""]
    lines.append(f"// Event types: the attribute defs beside {lc.name}")
    lines.append(f"export type {p}Event =")
    if not lc.events:
        lines.append("  never;")
    for i, ev in enumerate(lc.events):
        prefix = "  | " if i > 0 else "  "
        end = ";" if i == len(lc.events) - 1 else ""
        lines.append(f"{prefix}{{ type: {_q(ev)} }}{end}")
    lines.append("")
    lines.append(f"export type {p}State = {' | '.join(_q(s) for s in lc.states)};")
    lines.append("")
    lines.append(f"export const {lc.ident}Machine = setup({{")
    lines.append("  types: {")
    lines.append(f"    events: {{}} as {p}Event,")
    lines.append("  },")
    lines.append("}).createMachine({")
    lines.append(f"  id: {_q(lc.name)},")
    lines.append(f"  initial: {_q(lc.initial)},")
    lines.append("  states: {")
    terminal = set(lc.terminal_states)
    for s in lc.states:
        lines.append(f"    {s}: {{")
        if s in terminal:
            lines.append('      type: "final",')
        else:
            lines.append("      on: {")
            for t in lc.transitions:
                if t.source == s:
                    lines.append(f"        {t.event}: {_q(t.target)},")
            lines.append("      },")
        lines.append("    },")
    lines.append("  },")
    lines.append("});")
    lines.append("")
    return "\n".join(lines)


def render_guard(lc: Lifecycle, head: str) -> str:
    n, i = lc.name, lc.ident
    S, E = f"{n}State", f"{n}Event"
    lines = [head.rstrip("\n"), ""]
    lines.append(f"// Lifecycle guard and next-action map for {n}.")
    lines.append("// No imports: usable from any runtime, including a Temporal workflow sandbox.")
    lines.append("")
    lines.append(f"/** States of {n}, in model order. */")
    lines.append(f"export const {i}States = [{', '.join(_q(s) for s in lc.states)}] as const;")
    lines.append(f"export type {S} = (typeof {i}States)[number];")
    lines.append("")
    lines.append(f"/** Events declared beside {n}, in model order. */")
    lines.append(f"export const {i}Events = [{', '.join(_q(e) for e in lc.events)}] as const;")
    lines.append(f"export type {E} = (typeof {i}Events)[number];")
    lines.append("")
    lines.append(f"export const {i}InitialState: {S} = {_q(lc.initial)};")
    lines.append(f"export const {i}TerminalStates: readonly {S}[] = [{', '.join(_q(s) for s in lc.terminal_states)}];")
    lines.append("")
    lines.append(f"export interface {n}Transition {{")
    lines.append("  readonly name: string;")
    lines.append(f"  readonly source: {S};")
    lines.append(f"  readonly event: {E};")
    lines.append(f"  readonly target: {S};")
    lines.append("}")
    lines.append("")
    lines.append(f"/** Every transition of {n}, in model order. */")
    lines.append(f"export const {i}Transitions: readonly {n}Transition[] = [")
    for t in lc.transitions:
        lines.append(
            f"  {{ name: {_q(t.name)}, source: {_q(t.source)}, event: {_q(t.event)}, target: {_q(t.target)} }},"
        )
    lines.append("];")
    lines.append("")
    lines.append("/**")
    lines.append(f" * The state that `event` moves `state` to, or null when {n} refuses it:")
    lines.append(" * no transition from that state accepts that event (terminal states accept none).")
    lines.append(" */")
    lines.append(f"export function next{n}State(state: string, event: string): {S} | null {{")
    lines.append(f"  for (const t of {i}Transitions) {{")
    lines.append("    if (t.source === state && t.event === event) return t.target;")
    lines.append("  }")
    lines.append("  return null;")
    lines.append("}")
    lines.append("")
    lines.append(f"/** True when {n} has a transition from `source` to `target`. */")
    lines.append(f"export function is{n}TransitionLegal(source: string, target: string): boolean {{")
    lines.append(f"  return {i}Transitions.some((t) => t.source === source && t.target === target);")
    lines.append("}")
    lines.append("")
    lines.append(f"/** True when `state` is a terminal state of {n}. */")
    lines.append(f"export function is{n}Terminal(state: string): boolean {{")
    lines.append(f"  return {i}TerminalStates.some((s) => s === state);")
    lines.append("}")
    lines.append("")
    lines.append(f"export interface {n}NextAction {{")
    lines.append("  /** The event the action raises. */")
    lines.append(f"  readonly event: {E};")
    lines.append("  /** The state the action leads to. */")
    lines.append(f"  readonly target: {S};")
    lines.append("  /** The model transition behind the action. */")
    lines.append("  readonly transition: string;")
    lines.append("  /** The event's @UserFacing friendlyName in the model. */")
    lines.append("  readonly label: string;")
    lines.append("  /** The workflow signal that raises the event, or null when no workflow step does. */")
    lines.append("  readonly signal: string | null;")
    lines.append("}")
    lines.append("")
    lines.append(f"/** For each state, the actions its outgoing transitions offer, in model order. */")
    lines.append(f"export const {i}NextActions: Readonly<Record<{S}, readonly {n}NextAction[]>> = {{")
    for s in lc.states:
        outgoing = [t for t in lc.transitions if t.source == s]
        if not outgoing:
            lines.append(f"  {s}: [],")
            continue
        lines.append(f"  {s}: [")
        for t in outgoing:
            sig = _q(lc.signals[t.event]) if t.event in lc.signals else "null"
            lines.append(
                f"    {{ event: {_q(t.event)}, target: {_q(t.target)}, transition: {_q(t.name)}, "
                f"label: {_q(lc.labels[t.event])}, signal: {sig} }},"
            )
        lines.append("  ],")
    lines.append("};")
    lines.append("")
    return "\n".join(lines)


def generate(model: Path, out: Path, root: Path, state_def: str | None, model_name: str | None) -> list[Path]:
    files = load_model(model, root)
    lcs = lifecycles(files, state_def)
    if not lcs:
        raise ModelError("no state def found in the model folder")
    written = []
    for lc in lcs:
        head = header(__file__, lc.sources, model_name)
        written.append(write(out, f"{lc.machine_module}.ts", render_machine(lc, head)))
        written.append(write(out, f"{lc.guard_module}.ts", render_guard(lc, head)))
        unused = [e for e in lc.events if all(t.event != e for t in lc.transitions)]
        print(
            f"wrote {lc.machine_module}.ts and {lc.guard_module}.ts: {len(lc.states)} states, "
            f"{len(lc.transitions)} transitions, initial {lc.initial}"
            + (f"; events no transition accepts: {', '.join(unused)}" if unused else "")
        )
    return written


def main(argv: list[str] | None = None) -> int:
    p = base_parser("Generate XState machines, lifecycle guards and next-action maps from state defs.")
    p.add_argument("--state-def", default=None, help="generate only this state def (default: every state def)")
    a = p.parse_args(argv)
    try:
        generate(a.model, a.out, a.root, a.state_def, a.model_name)
    except ModelError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
