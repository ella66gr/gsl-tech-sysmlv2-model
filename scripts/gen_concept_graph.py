#!/usr/bin/env python3
"""
Concept Graph → Mermaid Generator
===================================

Reads the PatternCatalogue from pattern-catalogue.sysml — including
ArchitecturalPrinciple instances, Pattern instances with typed ref
relationships, and DomainInstantiation instances — then generates
Mermaid diagrams for different views of the concept graph.

Views:
    --view=overview       Full pattern dependency graph (default)
    --view=dependencies   Dependency chains only (dependsOn)
    --view=motivation     Patterns → Architectural Principles
    --view=analogues      Cross-domain analogue map
    --view=maturity       Patterns coloured by maturity
    --view=impact PATTERN Impact analysis: what depends on PATTERN

Source:
    Default: SysML (pattern-catalogue.sysml ref :>> relationships)
    --source=yaml         Fallback to concept-graph-relationships.yaml

Output:
    --output=terminal     Print to stdout (default)
    --save                Save to generated/concept-graph/
    --save-all            Save all views
    --update-obsidian     Embed per-pattern Mermaid subgraphs in Obsidian notes

No dependencies beyond PyYAML (pip install pyyaml) — only needed for
--source=yaml fallback.

Source: Session 31, Concept Graph Enhancement.
"""

import argparse
import pathlib
import re
import sys

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
CONCEPT_GRAPH_DIR = REPO_ROOT / "concept-graph"
GENERATED_DIR = REPO_ROOT / "generated" / "concept-graph"
PATTERN_CATALOGUE_FILE = MODEL_DIR / "pattern-catalogue.sysml"
RELATIONSHIPS_FILE = CONCEPT_GRAPH_DIR / "concept-graph-relationships.yaml"

# Obsidian vault — concept graph pattern notes
OBSIDIAN_PATTERNS_DIR = pathlib.Path.home() / "Obsidian" / "GenderSense" / "02 ARCHITECTURE & MODELLING" / "Concept Graph" / "patterns"

# Relationship predicates that are ref fields on Pattern
REF_PREDICATES = (
    "dependsOn", "enables", "motivatedBy", "generalises",
    "constrains", "extends", "validatedBy", "composedWith",
)

# Markers for generated content in Obsidian notes
GENERATED_BEGIN = "<!-- GENERATED:SUBGRAPH:BEGIN -->"
GENERATED_END = "<!-- GENERATED:SUBGRAPH:END -->"

# camelCase pattern name → kebab-case Obsidian filename
def pattern_to_obsidian_filename(name):
    """Convert camelCase pattern name to pattern-kebab-case.md filename."""
    # Insert hyphens before uppercase letters
    kebab = re.sub(r'([a-z])([A-Z])', r'\1-\2', name).lower()
    return f"pattern-{kebab}.md"


# ---------------------------------------------------------------
# SysML parser — extract patterns, principles, instantiations,
#                and ref :>> relationships
# ---------------------------------------------------------------

def parse_pattern_catalogue(filepath):
    """Parse pattern-catalogue.sysml and extract pattern instances."""
    text = filepath.read_text(encoding="utf-8")
    patterns = {}
    principles = {}
    instantiations = {}

    # Match ArchitecturalPrinciple instances
    principle_re = re.compile(
        r'part\s+(\w+)\s*:\s*ArchitecturalPrinciple\s*\{(.*?)\n    \}',
        re.DOTALL
    )
    for m in principle_re.finditer(text):
        name = m.group(1)
        body = m.group(2)
        attrs = parse_attributes(body)
        principles[name] = attrs

    # Match pattern instances: part <n> : Pattern { ... }
    pattern_re = re.compile(
        r'part\s+(\w+)\s*:\s*Pattern\s*\{(.*?)\n    \}',
        re.DOTALL
    )
    for m in pattern_re.finditer(text):
        name = m.group(1)
        body = m.group(2)
        attrs = parse_attributes(body)
        attrs["_refs"] = parse_ref_redefinitions(body)
        patterns[name] = attrs

    # Match domain instantiations: part <n> : DomainInstantiation { ... }
    inst_re = re.compile(
        r'part\s+(\w+)\s*:\s*DomainInstantiation\s*\{(.*?)\n    \}',
        re.DOTALL
    )
    for m in inst_re.finditer(text):
        name = m.group(1)
        body = m.group(2)
        attrs = parse_attributes(body)
        instantiations[name] = attrs

    return patterns, principles, instantiations


def parse_attributes(body):
    """Extract :>> attribute redefinitions from a part body."""
    attrs = {}
    attr_re = re.compile(
        r'attribute\s+:>>\s+(\w+)\s*=\s*(?:PatternMaturity::(\w+)|MetaModelHome::(\w+)|PatternKind::(\w+)|"([^"]*)")'
    )
    for m in attr_re.finditer(body):
        key = m.group(1)
        value = m.group(2) or m.group(3) or m.group(4) or m.group(5)
        attrs[key] = value
    return attrs


def parse_ref_redefinitions(body):
    """Extract ref :>> field = (target1, target2); from a part body.

    Handles single-target, multi-target, and multi-line tuples.
    Returns a dict mapping predicate name to list of target names.
    """
    refs = {}
    # Match ref :>> fieldName = (contents);
    # The contents may span multiple lines
    ref_re = re.compile(
        r'ref\s+:>>\s+(\w+)\s*=\s*\(([^)]+)\)\s*;',
        re.DOTALL
    )
    for m in ref_re.finditer(body):
        predicate = m.group(1)
        targets_str = m.group(2)
        # Split on commas, strip whitespace/newlines
        targets = [t.strip() for t in targets_str.split(",") if t.strip()]
        refs[predicate] = targets
    return refs


# ---------------------------------------------------------------
# Build relationship graph from SysML refs
# ---------------------------------------------------------------

def build_relationships_from_sysml(patterns, principles, instantiations):
    """Build a YAML-compatible data dict from parsed SysML refs."""
    relationships = []

    for pattern_name, attrs in patterns.items():
        refs = attrs.get("_refs", {})
        for predicate, targets in refs.items():
            for target in targets:
                rel = {
                    "subject": pattern_name,
                    "predicate": predicate,
                    "object": target,
                }
                relationships.append(rel)

    # Build principles list for motivation view
    principle_list = []
    for name, attrs in principles.items():
        principle_list.append({
            "id": name,
            "label": attrs.get("principleName", camel_to_title(name)),
        })

    # Infer cross-domain analogues from DomainInstantiation naming
    analogues = infer_analogues(instantiations)

    return {
        "relationships": relationships,
        "principles": principle_list,
        "analogues": analogues,
    }


def infer_analogues(instantiations):
    """Infer cross-domain analogue pairs from DomainInstantiation names."""
    domain_prefixes = {"csw": "CSW", "gsl": "GSL"}
    by_pattern = {}

    for inst_name, attrs in instantiations.items():
        domain = attrs.get("domain", "")
        for prefix, domain_label in domain_prefixes.items():
            if inst_name.startswith(prefix) and inst_name[len(prefix):len(prefix)+1].isupper():
                suffix = inst_name[len(prefix):]
                pattern_key = suffix[0].lower() + suffix[1:]
                if pattern_key not in by_pattern:
                    by_pattern[pattern_key] = {}
                by_pattern[pattern_key][domain_label] = inst_name
                break

    analogues = []
    for pattern_key, domains in sorted(by_pattern.items()):
        if "CSW" in domains and "GSL" in domains:
            analogues.append({
                "pattern": pattern_key,
                "csw": domains["CSW"],
                "gsl": domains["GSL"],
            })

    return analogues


# ---------------------------------------------------------------
# YAML parser — load semantic relationships (fallback)
# ---------------------------------------------------------------

def load_relationships_yaml(filepath):
    """Load relationships from YAML (fallback source)."""
    try:
        import yaml
    except ImportError:
        print("ERROR: PyYAML required for --source=yaml. Install with: pip install pyyaml --break-system-packages")
        sys.exit(1)
    with open(filepath, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data


# ---------------------------------------------------------------
# Label helpers
# ---------------------------------------------------------------

def pattern_label(name, patterns):
    """Get a display label for a pattern."""
    if name in patterns and "patternName" in patterns[name]:
        return patterns[name]["patternName"]
    return camel_to_title(name)


def principle_label(name, principles):
    """Get a display label for a principle."""
    if name in principles and "principleName" in principles[name]:
        return principles[name]["principleName"]
    return camel_to_title(name)


def camel_to_title(s):
    """Convert camelCase to Title Case."""
    s = re.sub(r'([a-z])([A-Z])', r'\1 \2', s)
    return s.title()


def safe_id(s):
    """Make a string safe for Mermaid node IDs."""
    return re.sub(r'[^a-zA-Z0-9_]', '_', s)


# ---------------------------------------------------------------
# Maturity → colour/style mapping
# ---------------------------------------------------------------

MATURITY_COLOURS = {
    "validated":   "#2d6a4f",
    "implemented": "#40916c",
    "designed":    "#e9c46a",
    "discussion":  "#e76f51",
}


# ---------------------------------------------------------------
# Per-pattern subgraph generator
# ---------------------------------------------------------------

def generate_pattern_subgraph(target, patterns, principles, data):
    """Generate a Mermaid subgraph showing a pattern's immediate relationships.

    The target pattern is the focal node. All directly connected patterns
    and principles are shown with labelled edges.
    """
    rels = data.get("relationships", [])
    principle_map = {p["id"]: p["label"] for p in data.get("principles", [])}

    # Collect all edges involving this pattern (outgoing and incoming)
    outgoing = []  # (predicate, target_name)
    incoming = []  # (predicate, source_name)

    for r in rels:
        subj = r.get("subject", "")
        obj = r.get("object", "")
        pred = r.get("predicate", "")

        if subj == target:
            outgoing.append((pred, obj))
        elif obj == target:
            incoming.append((pred, subj))

    # Collect all referenced nodes
    connected_patterns = set()
    connected_principles = set()

    for pred, name in outgoing:
        if pred == "motivatedBy":
            connected_principles.add(name)
        elif name in patterns:
            connected_patterns.add(name)

    for pred, name in incoming:
        if name in patterns:
            connected_patterns.add(name)

    # If no connections, return empty
    if not connected_patterns and not connected_principles:
        return None

    lines = ["graph LR"]
    lines.append("")

    # Focal pattern node — styled distinctly
    target_label = pattern_label(target, patterns)
    target_mat = patterns[target].get("maturity", "discussion")
    lines.append(f"    {safe_id(target)}[[\"{target_label}\"]]:::focal")

    # Connected pattern nodes
    for name in sorted(connected_patterns):
        label = pattern_label(name, patterns)
        mat = patterns[name].get("maturity", "discussion")
        lines.append(f"    {safe_id(name)}[\"{label}\"]:::{mat}")

    # Principle nodes (stadium/pill shape — avoids Mermaid hexagon brace escaping)
    for name in sorted(connected_principles):
        label = principle_map.get(name, camel_to_title(name))
        # Truncate long labels for diagram readability
        if len(label) > 35:
            label = label[:32] + "..."
        node_id = safe_id(name)
        lines.append("    " + node_id + '(["' + label + '"]):::principle')

    lines.append("")

    # Outgoing edges
    PRED_LABELS = {
        "dependsOn": "depends on",
        "enables": "enables",
        "motivatedBy": "motivated by",
        "generalises": "generalises",
        "constrains": "constrains",
        "extends": "extends",
        "validatedBy": "validates",
        "composedWith": "composed with",
    }
    PRED_STYLES = {
        "dependsOn": "-->",
        "enables": "-.->",
        "motivatedBy": "-->",
        "generalises": "-->",
        "constrains": "-->",
        "extends": "-->",
        "validatedBy": "-.->",
        "composedWith": "<-->",
    }

    for pred, name in outgoing:
        edge = PRED_STYLES.get(pred, "-->")
        label = PRED_LABELS.get(pred, pred)
        lines.append(f"    {safe_id(target)} {edge}|{label}| {safe_id(name)}")

    # Incoming edges (reverse direction — other pattern → this pattern)
    INVERSE_LABELS = {
        "dependsOn": "needs",
        "enables": "enabled by",
        "motivatedBy": "motivates",
        "generalises": "generalised by",
        "constrains": "constrained by",
        "extends": "extends",
        "validatedBy": "validated by",
        "composedWith": "with",
    }

    for pred, name in incoming:
        label = INVERSE_LABELS.get(pred, pred)
        lines.append(f"    {safe_id(name)} -.->|{label}| {safe_id(target)}")

    # Style classes
    lines.append("")
    lines.append("    classDef focal fill:#1d3557,color:#fff,stroke:#0d1b2a,stroke-width:3px")
    lines.append("    classDef principle fill:#e8daef,stroke:#7d3c98")
    lines.append("    classDef validated fill:#2d6a4f,color:#fff,stroke:#1b4332")
    lines.append("    classDef implemented fill:#40916c,color:#fff,stroke:#2d6a4f")
    lines.append("    classDef designed fill:#e9c46a,color:#000,stroke:#f4a261")
    lines.append("    classDef discussion fill:#e76f51,color:#fff,stroke:#e63946")

    return "\n".join(lines)


# ---------------------------------------------------------------
# Obsidian note updater
# ---------------------------------------------------------------

def update_obsidian_notes(patterns, principles, data):
    """Embed per-pattern Mermaid subgraphs into Obsidian pattern notes.

    Inserts or replaces content between GENERATED:SUBGRAPH:BEGIN/END
    markers. Places the block after the ## Semantic Relationships heading.
    """
    if not OBSIDIAN_PATTERNS_DIR.exists():
        print(f"  WARNING: Obsidian patterns directory not found: {OBSIDIAN_PATTERNS_DIR}")
        return 0

    updated = 0
    skipped = 0

    for pattern_name in sorted(patterns.keys()):
        filename = pattern_to_obsidian_filename(pattern_name)
        filepath = OBSIDIAN_PATTERNS_DIR / filename

        if not filepath.exists():
            # Try common variations
            skipped += 1
            continue

        mermaid = generate_pattern_subgraph(pattern_name, patterns, principles, data)
        if mermaid is None:
            continue  # No connections — skip

        # Build the generated block
        generated_block = "\n".join([
            GENERATED_BEGIN,
            "",
            "```mermaid",
            mermaid,
            "```",
            "",
            f"*Generated from `pattern-catalogue.sysml` — do not edit manually.*",
            "",
            GENERATED_END,
        ])

        content = filepath.read_text(encoding="utf-8")

        # Check if markers already exist — replace
        if GENERATED_BEGIN in content and GENERATED_END in content:
            before = content[:content.index(GENERATED_BEGIN)]
            after = content[content.index(GENERATED_END) + len(GENERATED_END):]
            new_content = before + generated_block + after
        else:
            # Insert after ## Semantic Relationships heading
            sem_heading = "## Semantic Relationships"
            if sem_heading in content:
                idx = content.index(sem_heading)
                # Find end of the heading line
                newline_after = content.index("\n", idx)
                before = content[:newline_after + 1]
                after = content[newline_after + 1:]
                new_content = before + "\n" + generated_block + "\n" + after
            else:
                # No semantic relationships section — insert before ## Cross-Domain
                # or ## Domain Instantiations or at end of file
                for fallback_heading in ["## Cross-Domain", "## Domain Instantiations", "## Related Patterns", "## Source"]:
                    if fallback_heading in content:
                        idx = content.index(fallback_heading)
                        before = content[:idx]
                        after = content[idx:]
                        new_content = before + "## Relationship Graph\n\n" + generated_block + "\n\n" + after
                        break
                else:
                    # Append at end
                    new_content = content.rstrip() + "\n\n## Relationship Graph\n\n" + generated_block + "\n"

        filepath.write_text(new_content, encoding="utf-8")
        updated += 1

    return updated, skipped


# ---------------------------------------------------------------
# Mermaid generators — one per view
# ---------------------------------------------------------------

def generate_overview(patterns, relationships, data):
    """Full pattern graph with dependency and enabling edges."""
    lines = ["graph TD"]
    lines.append("")

    business = []
    system = []
    cross = []
    deferred = []

    for name, attrs in patterns.items():
        mm = attrs.get("metaModelClassification", "")
        mat = attrs.get("maturity", "")
        if mat in ("discussion", "designed"):
            deferred.append(name)
        elif mm == "business":
            business.append(name)
        elif mm == "businessSystem":
            system.append(name)
        else:
            cross.append(name)

    lines.append("    subgraph BM[\"Business Meta Model\"]")
    lines.append("        direction TB")
    for name in business:
        label = pattern_label(name, patterns)
        lines.append(f"        {safe_id(name)}[\"{label}\"]")
    lines.append("    end")
    lines.append("")

    lines.append("    subgraph BSM[\"Business System Meta Model\"]")
    lines.append("        direction TB")
    for name in system:
        label = pattern_label(name, patterns)
        lines.append(f"        {safe_id(name)}[\"{label}\"]")
    lines.append("    end")
    lines.append("")

    if cross:
        lines.append("    subgraph CC[\"Cross-Cutting\"]")
        lines.append("        direction TB")
        for name in cross:
            label = pattern_label(name, patterns)
            lines.append(f"        {safe_id(name)}[\"{label}\"]")
        lines.append("    end")
        lines.append("")

    if deferred:
        lines.append("    subgraph DEF[\"Deferred / Conceptual\"]")
        lines.append("        direction TB")
        for name in deferred:
            label = pattern_label(name, patterns)
            lines.append(f"        {safe_id(name)}[\"{label}\"]:::deferred")
        lines.append("    end")
        lines.append("")

    rels = data.get("relationships", [])
    for rel in rels:
        subj = rel.get("subject", "")
        obj = rel.get("object", "")
        pred = rel.get("predicate", "")

        if "::" in subj or "::" in obj:
            continue
        if subj not in patterns or obj not in patterns:
            continue

        if pred == "dependsOn":
            lines.append(f"    {safe_id(subj)} -->|depends on| {safe_id(obj)}")
        elif pred == "enables":
            lines.append(f"    {safe_id(subj)} -.->|enables| {safe_id(obj)}")
        elif pred == "extends":
            lines.append(f"    {safe_id(subj)} -->|extends| {safe_id(obj)}")
        elif pred == "composedWith":
            lines.append(f"    {safe_id(subj)} <-->|composed| {safe_id(obj)}")
        elif pred == "generalises":
            lines.append(f"    {safe_id(subj)} -->|generalises| {safe_id(obj)}")
        elif pred == "validatedBy":
            lines.append(f"    {safe_id(subj)} -.->|validates| {safe_id(obj)}")

    lines.append("")
    lines.append("    classDef deferred stroke-dasharray: 5 5,fill:#fce4ec")

    return "\n".join(lines)


def generate_motivation(patterns, relationships, data):
    """Patterns → Principles motivation graph."""
    lines = ["graph LR"]
    lines.append("")

    principle_list = data.get("principles", [])
    rels = data.get("relationships", [])

    motiv_rels = [r for r in rels if r.get("predicate") == "motivatedBy"]

    referenced_principles = set()
    for r in motiv_rels:
        referenced_principles.add(r["object"])

    lines.append("    subgraph PRIN[\"Architectural Principles\"]")
    lines.append("        direction TB")
    for p in principle_list:
        if p["id"] in referenced_principles:
            lines.append(f"        {safe_id(p['id'])}[[\"{p['label']}\"]]:::principle")
    lines.append("    end")
    lines.append("")

    motivated_patterns = set()
    for r in motiv_rels:
        motivated_patterns.add(r["subject"])

    lines.append("    subgraph PAT[\"Patterns\"]")
    lines.append("        direction TB")
    for name in motivated_patterns:
        if name in patterns:
            label = pattern_label(name, patterns)
            lines.append(f"        {safe_id(name)}[\"{label}\"]")
    lines.append("    end")
    lines.append("")

    for r in motiv_rels:
        subj = r["subject"]
        obj = r["object"]
        if subj in patterns:
            lines.append(f"    {safe_id(subj)} -->|motivated by| {safe_id(obj)}")

    lines.append("")
    lines.append("    classDef principle fill:#e8daef,stroke:#7d3c98")

    return "\n".join(lines)


def generate_analogues(patterns, relationships, data):
    """Cross-domain analogue map."""
    lines = ["graph LR"]
    lines.append("")

    analogues = data.get("analogues", [])

    if not analogues:
        rels = data.get("relationships", [])
        analogue_rels = [r for r in rels if r.get("predicate") == "analogueTo"]
        csw_items = set()
        gsl_items = set()
        for r in analogue_rels:
            csw_items.add(r["subject"])
            gsl_items.add(r["object"])

        lines.append("    subgraph CSW[\"Coffee Shop (CSW)\"]")
        lines.append("        direction TB")
        for item in sorted(csw_items):
            short = item.split("::")[-1] if "::" in item else item
            lines.append(f"        {safe_id(item)}[\"{short}\"]:::csw")
        lines.append("    end")
        lines.append("")
        lines.append("    subgraph GSL[\"Gender-Affirming Care (GSL)\"]")
        lines.append("        direction TB")
        for item in sorted(gsl_items):
            short = item.split("::")[-1] if "::" in item else item
            lines.append(f"        {safe_id(item)}[\"{short}\"]:::gsl")
        lines.append("    end")
        lines.append("")
        for r in analogue_rels:
            note = r.get("note", "")
            lines.append(f"    {safe_id(r['subject'])} <-.->|{note}| {safe_id(r['object'])}")
    else:
        lines.append("    subgraph CSW[\"Coffee Shop (CSW)\"]")
        lines.append("        direction TB")
        for a in analogues:
            csw_label = camel_to_title(a["csw"])
            lines.append(f"        {safe_id(a['csw'])}[\"{csw_label}\"]:::csw")
        lines.append("    end")
        lines.append("")
        lines.append("    subgraph GSL[\"Gender-Affirming Care (GSL)\"]")
        lines.append("        direction TB")
        for a in analogues:
            gsl_label = camel_to_title(a["gsl"])
            lines.append(f"        {safe_id(a['gsl'])}[\"{gsl_label}\"]:::gsl")
        lines.append("    end")
        lines.append("")
        for a in analogues:
            pattern_label_str = camel_to_title(a["pattern"])
            lines.append(f"    {safe_id(a['csw'])} <-.->|{pattern_label_str}| {safe_id(a['gsl'])}")

    lines.append("")
    lines.append("    classDef csw fill:#d4edda,stroke:#28a745")
    lines.append("    classDef gsl fill:#cce5ff,stroke:#007bff")

    return "\n".join(lines)


def generate_maturity(patterns, relationships, data):
    """Patterns coloured by maturity level."""
    lines = ["graph TD"]
    lines.append("")

    for name, attrs in patterns.items():
        label = pattern_label(name, patterns)
        mat = attrs.get("maturity", "discussion")
        lines.append(f"    {safe_id(name)}[\"{label}\"]:::{mat}")

    lines.append("")
    lines.append("    classDef validated fill:#2d6a4f,color:#fff,stroke:#1b4332")
    lines.append("    classDef implemented fill:#40916c,color:#fff,stroke:#2d6a4f")
    lines.append("    classDef designed fill:#e9c46a,color:#000,stroke:#f4a261")
    lines.append("    classDef discussion fill:#e76f51,color:#fff,stroke:#e63946")

    return "\n".join(lines)


def generate_impact(patterns, relationships, data, target_pattern):
    """Impact analysis: what depends on a given pattern?"""
    lines = ["graph TD"]
    lines.append("")

    rels = data.get("relationships", [])

    dependents = set()
    frontier = {target_pattern}
    visited = set()

    while frontier:
        current = frontier.pop()
        if current in visited:
            continue
        visited.add(current)
        for r in rels:
            if r.get("predicate") == "dependsOn" and r.get("object") == current:
                dep = r["subject"]
                if dep in patterns:
                    dependents.add(dep)
                    frontier.add(dep)

    target_label = pattern_label(target_pattern, patterns)
    lines.append(f"    {safe_id(target_pattern)}[\"{target_label}\"]:::target")

    for dep in dependents:
        dep_label = pattern_label(dep, patterns)
        lines.append(f"    {safe_id(dep)}[\"{dep_label}\"]:::impacted")

    for r in rels:
        if r.get("predicate") == "dependsOn":
            subj = r["subject"]
            obj = r["object"]
            if (subj in dependents or subj == target_pattern) and (obj in dependents or obj == target_pattern):
                lines.append(f"    {safe_id(subj)} -->|depends on| {safe_id(obj)}")

    lines.append("")
    lines.append(f"    classDef target fill:#e63946,color:#fff,stroke:#d00000")
    lines.append(f"    classDef impacted fill:#ffc8dd,stroke:#e63946")

    return "\n".join(lines)


def generate_dependencies(patterns, relationships, data):
    """Dependency-only view — just dependsOn edges."""
    lines = ["graph TD"]
    lines.append("")

    rels = data.get("relationships", [])
    dep_rels = [r for r in rels if r.get("predicate") == "dependsOn"
                and r.get("subject") in patterns and r.get("object") in patterns]

    referenced = set()
    for r in dep_rels:
        referenced.add(r["subject"])
        referenced.add(r["object"])

    for name in referenced:
        label = pattern_label(name, patterns)
        mat = patterns[name].get("maturity", "discussion")
        lines.append(f"    {safe_id(name)}[\"{label}\"]:::{mat}")

    lines.append("")
    for r in dep_rels:
        lines.append(f"    {safe_id(r['subject'])} --> {safe_id(r['object'])}")

    lines.append("")
    lines.append("    classDef validated fill:#2d6a4f,color:#fff,stroke:#1b4332")
    lines.append("    classDef implemented fill:#40916c,color:#fff,stroke:#2d6a4f")
    lines.append("    classDef designed fill:#e9c46a,color:#000,stroke:#f4a261")
    lines.append("    classDef discussion fill:#e76f51,color:#fff,stroke:#e63946")

    return "\n".join(lines)


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

VIEWS = {
    "overview": generate_overview,
    "dependencies": generate_dependencies,
    "motivation": generate_motivation,
    "analogues": generate_analogues,
    "maturity": generate_maturity,
}


def main():
    parser = argparse.ArgumentParser(
        description="Concept Graph → Mermaid Generator"
    )
    parser.add_argument(
        "--view", default="overview",
        help="View to generate: overview, dependencies, motivation, analogues, maturity, impact"
    )
    parser.add_argument(
        "--impact-target",
        help="Pattern name for impact analysis (used with --view=impact)"
    )
    parser.add_argument(
        "--source", default="sysml", choices=["sysml", "yaml"],
        help="Relationship source: sysml (default) or yaml (fallback)"
    )
    parser.add_argument(
        "--save", action="store_true",
        help="Save to generated/concept-graph/ directory"
    )
    parser.add_argument(
        "--save-all", action="store_true",
        help="Save all views to generated/concept-graph/"
    )
    parser.add_argument(
        "--update-obsidian", action="store_true",
        help="Embed per-pattern Mermaid subgraphs into Obsidian pattern notes"
    )
    args = parser.parse_args()

    # Parse SysML catalogue
    if not PATTERN_CATALOGUE_FILE.exists():
        print(f"ERROR: {PATTERN_CATALOGUE_FILE} not found")
        sys.exit(1)

    patterns, principles, instantiations = parse_pattern_catalogue(PATTERN_CATALOGUE_FILE)

    # Load relationships from chosen source
    if args.source == "yaml":
        if not RELATIONSHIPS_FILE.exists():
            print(f"ERROR: {RELATIONSHIPS_FILE} not found")
            sys.exit(1)
        data = load_relationships_yaml(RELATIONSHIPS_FILE)
        rel_count = len(data.get("relationships", []))
        source_desc = "YAML"
    else:
        data = build_relationships_from_sysml(patterns, principles, instantiations)
        rel_count = len(data.get("relationships", []))
        source_desc = "SysML"

    rels = data.get("relationships", [])

    print(f"Loaded {len(patterns)} patterns, {len(principles)} principles, "
          f"{len(instantiations)} domain instantiations, "
          f"{rel_count} relationships (from {source_desc})")

    analogue_count = len(data.get("analogues", []))
    if analogue_count:
        print(f"  Inferred {analogue_count} cross-domain analogue pairs")

    # Handle --update-obsidian
    if args.update_obsidian:
        updated, skipped = update_obsidian_notes(patterns, principles, data)
        print(f"  Updated {updated} Obsidian pattern notes ({skipped} not found)")
        return

    if args.save_all:
        GENERATED_DIR.mkdir(parents=True, exist_ok=True)
        for view_name, gen_fn in VIEWS.items():
            mermaid = gen_fn(patterns, rels, data)
            outpath = GENERATED_DIR / f"concept-graph-{view_name}.mmd"
            outpath.write_text(mermaid, encoding="utf-8")
            print(f"  Saved: {outpath}")

        md_lines = [
            "# Concept Graph — Generated Views",
            "",
            f"*Generated from `pattern-catalogue.sysml` ({len(patterns)} patterns, "
            f"{rel_count} relationships from {source_desc}).*",
            "",
        ]
        for view_name, gen_fn in VIEWS.items():
            mermaid = gen_fn(patterns, rels, data)
            title = camel_to_title(view_name.replace("_", " "))
            md_lines.append(f"## {title}")
            md_lines.append("")
            md_lines.append("```mermaid")
            md_lines.append(mermaid)
            md_lines.append("```")
            md_lines.append("")

        md_path = GENERATED_DIR / "concept-graph-views.md"
        md_path.write_text("\n".join(md_lines), encoding="utf-8")
        print(f"  Saved: {md_path}")
        return

    # Single view
    if args.view == "impact":
        if not args.impact_target:
            print("ERROR: --impact-target required for impact view")
            sys.exit(1)
        if args.impact_target not in patterns:
            print(f"ERROR: Pattern '{args.impact_target}' not found in catalogue")
            print(f"  Available: {', '.join(sorted(patterns.keys()))}")
            sys.exit(1)
        mermaid = generate_impact(patterns, rels, data, args.impact_target)
    elif args.view in VIEWS:
        mermaid = VIEWS[args.view](patterns, rels, data)
    else:
        print(f"ERROR: Unknown view '{args.view}'")
        print(f"  Available: {', '.join(VIEWS.keys())}, impact")
        sys.exit(1)

    if args.save:
        GENERATED_DIR.mkdir(parents=True, exist_ok=True)
        outpath = GENERATED_DIR / f"concept-graph-{args.view}.mmd"
        outpath.write_text(mermaid, encoding="utf-8")
        print(f"Saved: {outpath}")
    else:
        print("")
        print(mermaid)


if __name__ == "__main__":
    main()
