#!/usr/bin/env python3
"""
Ontara Package Hierarchy Generator
========================================

Reads the SysML v2 model files and generates package hierarchy views.

Quick view (default — the nice terminal tree):
    python scripts/gen_package_hierarchy.py

Export formats:
    python scripts/gen_package_hierarchy.py --save              Save all formats
    python scripts/gen_package_hierarchy.py --save=markdown      Markdown only
    python scripts/gen_package_hierarchy.py --save=opml          OPML outline
    python scripts/gen_package_hierarchy.py --save=html          Interactive HTML mindmap
    python scripts/gen_package_hierarchy.py --save=all           All formats

Other:
    python scripts/gen_package_hierarchy.py --diff               Compare model vs proposal

No dependencies — pure Python standard library.
"""

import argparse
import pathlib
import re
import sys
import datetime
import xml.etree.ElementTree as ET
from xml.dom import minidom

# ---------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
MODEL_DIR = REPO_ROOT / "model"
LIBRARY_DIR = REPO_ROOT / "libraries"
DOCS_DIR = REPO_ROOT / "documentation"
GENERATED_DIR = DOCS_DIR / "generated"
PROPOSAL_PATH = DOCS_DIR / "architecture" / "gsl-platform-package-hierarchy-proposal.md"

OUTPUT_PATHS = {
    "markdown": GENERATED_DIR / "ontara-generated-package-hierarchy.md",
    "opml":     GENERATED_DIR / "ontara-generated-package-hierarchy.opml",
    "html":     GENERATED_DIR / "ontara-generated-package-hierarchy.html",
    "oo":       GENERATED_DIR / "ontara-generated-package-hierarchy.txt",
}


# ---------------------------------------------------------------
# Data model
# ---------------------------------------------------------------

class SysmlPackage:
    """A package extracted from a .sysml file."""
    def __init__(self, name, doc="", depth=0, source_file="", line_number=0):
        self.name = name
        self.doc = doc.strip()
        self.depth = depth
        self.source_file = source_file
        self.line_number = line_number
        self.children = []
        self.element_counts = {
            "part_def": 0, "use_case_def": 0, "enum_def": 0,
            "constraint_def": 0, "requirement_def": 0, "state_def": 0,
            "metadata_def": 0, "action_def": 0,
        }

    def summary_line(self):
        """One-line description from the first sentence of the doc block."""
        if not self.doc:
            return ""
        for line in self.doc.split("\n"):
            line = line.strip().lstrip("*").strip()
            if line and not line.startswith("@") and not line.startswith("Updated"):
                if ". " in line and line.index(". ") < 100:
                    return line[:line.index(". ") + 1]
                return line[:100]
        return ""

    def element_summary(self):
        """Short summary of contained elements."""
        parts = []
        labels = {
            "part_def": "parts", "use_case_def": "use cases",
            "enum_def": "enums", "constraint_def": "constraints",
            "requirement_def": "requirements", "state_def": "states",
            "metadata_def": "metadata", "action_def": "actions",
        }
        for key, label in labels.items():
            if self.element_counts[key] > 0:
                parts.append(f"{self.element_counts[key]} {label}")
        return ", ".join(parts) if parts else ""


# ---------------------------------------------------------------
# Parser
# ---------------------------------------------------------------

def parse_sysml_file(filepath):
    """Parse a .sysml file and extract package hierarchy with element counts."""
    text = filepath.read_text(encoding="utf-8")
    filename = filepath.name
    packages = []
    brace_depth = 0
    package_at_depth = {}
    lines = text.split("\n")
    i = 0

    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        open_braces = line.count("{")
        close_braces = line.count("}")

        pkg_match = re.match(r'\s*package\s+(\w+)\s*\{', line)
        if pkg_match:
            pkg_name = pkg_match.group(1)
            doc_text = ""
            j = i + 1
            while j < len(lines):
                next_line = lines[j].strip()
                if next_line.startswith("doc /*"):
                    doc_lines = [next_line]
                    if "*/" not in next_line:
                        j += 1
                        while j < len(lines):
                            doc_lines.append(lines[j].strip())
                            if "*/" in lines[j]:
                                break
                            j += 1
                    doc_text = "\n".join(doc_lines)
                    doc_text = doc_text.replace("doc /*", "").replace("*/", "").strip()
                    break
                elif next_line.startswith("private import") or next_line == "":
                    j += 1
                    continue
                else:
                    break

            pkg = SysmlPackage(name=pkg_name, doc=doc_text, depth=brace_depth,
                               source_file=filename, line_number=i + 1)

            if brace_depth > 0 and (brace_depth - 1) in package_at_depth:
                package_at_depth[brace_depth - 1].children.append(pkg)
            else:
                packages.append(pkg)
            package_at_depth[brace_depth] = pkg

        # Count elements
        current_pkg = None
        for d in range(brace_depth - 1, -1, -1):
            if d in package_at_depth:
                current_pkg = package_at_depth[d]
                break
        if current_pkg:
            for pattern, key in [
                (r'\s*part\s+def\s+\w+', "part_def"),
                (r'\s*use\s+case\s+def\s+\w+', "use_case_def"),
                (r'\s*enum\s+def\s+\w+', "enum_def"),
                (r'\s*constraint\s+def\s+\w+', "constraint_def"),
                (r'\s*requirement\s+def\s+\w+', "requirement_def"),
                (r'\s*state\s+def\s+\w+', "state_def"),
                (r'\s*metadata\s+def\s+\w+', "metadata_def"),
                (r'\s*action\s+def\s+\w+', "action_def"),
            ]:
                if re.match(pattern, stripped):
                    current_pkg.element_counts[key] += 1
                    break

        brace_depth += open_braces - close_braces
        for d in [d for d in package_at_depth if d >= brace_depth]:
            del package_at_depth[d]
        i += 1

    return packages


def parse_all_model_files():
    """Parse all .sysml files and reassemble the logical hierarchy."""
    all_packages = []

    for filepath in sorted(MODEL_DIR.glob("*.sysml")):
        all_packages.extend(parse_sysml_file(filepath))

    for filepath in sorted(LIBRARY_DIR.rglob("*.sysml")):
        packages = parse_sysml_file(filepath)
        for pkg in packages:
            pkg.source_file = f"libraries/{filepath.relative_to(LIBRARY_DIR)}"
        all_packages.extend(packages)

    # Reassemble: domain packages imported by gendersense.sysml become
    # children of the GenderSense root.
    root = None
    for pkg in all_packages:
        if pkg.name == "GenderSense":
            root = pkg
            break

    if root:
        root_file = MODEL_DIR / "gendersense.sysml"
        imported_names = set()
        if root_file.exists():
            text = root_file.read_text(encoding="utf-8")
            for match in re.finditer(r'private\s+import\s+(\w+)::\*', text):
                name = match.group(1)
                if name != "ScalarValues":
                    imported_names.add(name)

        to_reparent = []
        remaining = []
        for pkg in all_packages:
            if pkg.name in imported_names and pkg is not root:
                to_reparent.append(pkg)
            else:
                remaining.append(pkg)

        display_order = ["Enterprise", "Foundation", "Knowledge",
                         "Operations", "Platform", "ServiceDelivery"]
        to_reparent.sort(key=lambda p: (
            display_order.index(p.name) if p.name in display_order
            else len(display_order)
        ))
        root.children = to_reparent
        all_packages = remaining

    return all_packages


def get_root_and_libraries(packages):
    root = None
    libraries = []
    for pkg in packages:
        if pkg.name == "GenderSense":
            root = pkg
        elif "libraries" in str(pkg.source_file):
            libraries.append(pkg)
    return root, libraries


def count_all_packages(pkgs):
    total = len(pkgs)
    for p in pkgs:
        total += count_all_packages(p.children)
    return total


# ---------------------------------------------------------------
# Terminal view (the nice one)
# ---------------------------------------------------------------

DESC_COLUMN = 24  # description starts this many chars after the indent


def measure_max_name_width(packages, indent=0):
    """Find the widest package name at each indent level and below."""
    max_w = 0
    for pkg in packages:
        w = indent + 4 + len(pkg.name)  # 4 = len("├── ")
        if w > max_w:
            max_w = w
        child_w = measure_max_name_width(pkg.children, indent + 4)
        if child_w > max_w:
            max_w = child_w
    return max_w


def render_tree_line(pkg, prefix="", is_last=True, desc_col=40):
    """Render one line of the tree with aligned description column."""
    connector = "└── " if is_last else "├── "
    name_part = f"{prefix}{connector}{pkg.name}"

    summary = pkg.summary_line()
    elements = pkg.element_summary()

    desc_parts = []
    if summary:
        desc_parts.append(summary)
    if elements:
        desc_parts.append(f"[{elements}]")

    desc = " — ".join(desc_parts) if desc_parts else ""

    if desc:
        pad = max(2, desc_col - len(name_part))
        return f"{name_part}{' ' * pad}{desc}"
    return name_part


def render_tree(packages, prefix="", depth=0, desc_col=40):
    """Recursively render the package tree."""
    lines = []
    for i, pkg in enumerate(packages):
        is_last = (i == len(packages) - 1)
        lines.append(render_tree_line(pkg, prefix=prefix, is_last=is_last, desc_col=desc_col))
        child_prefix = prefix + ("    " if is_last else "│   ")
        if pkg.children:
            lines.extend(render_tree(pkg.children, prefix=child_prefix, depth=depth + 1, desc_col=desc_col))
        # Blank line between top-level domain packages for readability
        if depth == 0 and not is_last:
            lines.append(prefix + "│")
    return lines


def generate_terminal_view(packages):
    """Generate the terminal tree view — the primary everyday output."""
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    root, libraries = get_root_and_libraries(packages)
    all_pkgs = root.children if root else []
    total = count_all_packages(all_pkgs) + len(libraries)

    # Compute the description column: widest name + padding
    children = root.children if root else []
    max_name = measure_max_name_width(children, indent=0)
    desc_col = max_name + 3  # 3 chars gap between longest name and description

    lines = [
        f"Ontara Package Hierarchy",
        f"Generated {now} from model/*.sysml ({total} packages)",
        "",
        "GenderSense",
    ]

    if root and root.children:
        lines.extend(render_tree(root.children, desc_col=desc_col))

    if libraries:
        lines.extend(["", "Libraries (separate from main model):"])
        for lib in libraries:
            s = lib.summary_line()
            e = lib.element_summary()
            dp = []
            if s: dp.append(s)
            if e: dp.append(f"[{e}]")
            d = " — ".join(dp)
            lines.append(f"  {lib.name} ({lib.source_file}){' — ' + d if d else ''}")

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------
# Format: Markdown
# ---------------------------------------------------------------

def generate_markdown(packages):
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    root, libraries = get_root_and_libraries(packages)
    all_pkgs = root.children if root else []
    total = count_all_packages(all_pkgs) + len(libraries)

    lines = [
        "# Ontara Package Hierarchy (Generated)",
        "",
        f"**Generated:** {now}  ",
        f"**Source:** `model/*.sysml`, `libraries/**/*.sysml`  ",
        f"**Total packages:** {total} (excluding root)  ",
        f"**Generator:** `scripts/gen_package_hierarchy.py --save=markdown`",
        "",
        "This document is generated from the SysML model. Do not edit manually.",
        "",
        "---",
        "",
        "```",
    ]

    # Reuse the terminal view inside a code fence for consistent rendering
    lines.append(generate_terminal_view(packages).rstrip())
    lines.extend([
        "```",
        "",
        "---",
        "",
        f"*Generated {now} by `gen_package_hierarchy.py`.*",
    ])

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------
# Format: OPML
# ---------------------------------------------------------------

def generate_opml(packages):
    """Generate OPML with descriptions visible in the outline text."""
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    root_pkg, libraries = get_root_and_libraries(packages)

    opml = ET.Element("opml", version="2.0")
    head = ET.SubElement(opml, "head")
    ET.SubElement(head, "title").text = "Ontara Package Hierarchy"
    ET.SubElement(head, "dateCreated").text = now
    body = ET.SubElement(opml, "body")

    def add_outline(parent_elem, pkg):
        # Put description in the visible text, not hidden in _note
        summary = pkg.summary_line()
        elements = pkg.element_summary()
        desc_parts = [pkg.name]
        if summary:
            desc_parts.append(f"— {summary}")
        if elements:
            desc_parts.append(f"[{elements}]")
        text = "  ".join(desc_parts)

        attribs = {"text": text}
        # Source location in _note for reference
        if pkg.source_file:
            attribs["_note"] = f"{pkg.source_file}:{pkg.line_number}"

        outline = ET.SubElement(parent_elem, "outline", **attribs)
        for child in pkg.children:
            add_outline(outline, child)
        return outline

    root_outline = ET.SubElement(body, "outline",
                                  text="Ontara — Model-driven service system development and delivery platform")

    if root_pkg:
        for child in root_pkg.children:
            add_outline(root_outline, child)

    if libraries:
        lib_outline = ET.SubElement(body, "outline", text="Libraries (separate from main model)")
        for lib in libraries:
            add_outline(lib_outline, lib)

    rough = ET.tostring(opml, encoding="unicode", xml_declaration=True)
    parsed = minidom.parseString(rough)
    return parsed.toprettyxml(indent="  ", encoding=None)


# ---------------------------------------------------------------
# Format: HTML mindmap
# ---------------------------------------------------------------

def generate_html(packages):
    """Generate a self-contained HTML mindmap with light theme and descriptions."""
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
    root_pkg, libraries = get_root_and_libraries(packages)

    def render_md(pkg, depth=1):
        prefix = "#" * min(depth, 6)
        summary = pkg.summary_line()
        elements = pkg.element_summary()
        parts = [pkg.name]
        if summary:
            parts.append(f"— {summary}")
        if elements:
            parts.append(f"*[{elements}]*")
        label = " ".join(parts)
        result = [f"{prefix} {label}"]
        for child in pkg.children:
            result.extend(render_md(child, depth + 1))
        return result

    md_lines = ["# Ontara"]
    if root_pkg:
        for child in root_pkg.children:
            md_lines.extend(render_md(child, depth=2))
    if libraries:
        md_lines.append("## Libraries")
        for lib in libraries:
            md_lines.extend(render_md(lib, depth=3))

    md_content = "\n".join(md_lines)
    md_escaped = md_content.replace("\\", "\\\\").replace("`", "\\`").replace("$", "\\$")

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ontara Package Hierarchy</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f8f9fa;
            color: #1a1a2e;
        }}
        #banner {{
            background: #fff;
            padding: 12px 24px;
            font-size: 13px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e2e8f0;
            position: sticky;
            top: 0;
            z-index: 10;
        }}
        #banner .title {{
            font-weight: 600;
            font-size: 15px;
            color: #1e293b;
        }}
        #banner .meta {{
            color: #64748b;
            font-size: 12px;
        }}
        svg#mindmap {{
            width: 100vw;
            height: calc(100vh - 48px);
            display: block;
        }}
    </style>
</head>
<body>
    <div id="banner">
        <span class="title">Ontara — Package Hierarchy</span>
        <span class="meta">Generated {now} &nbsp;|&nbsp;
              Scroll to zoom &nbsp;|&nbsp; Drag to pan &nbsp;|&nbsp;
              Click nodes to collapse</span>
    </div>
    <svg id="mindmap"></svg>

    <script src="https://cdn.jsdelivr.net/npm/d3@7"></script>
    <script src="https://cdn.jsdelivr.net/npm/markmap-view@0.15.4/dist/browser/index.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/markmap-lib@0.15.4/dist/browser/index.js"></script>
    <script>
        const md = `{md_escaped}`;
        try {{
            const transformer = new window.markmap.Transformer();
            const {{ root, features }} = transformer.transform(md);
            const {{ styles, scripts }} = transformer.getUsedAssets(features);
            const {{ Markmap, loadCSS, loadJS }} = window.markmap;
            if (styles) loadCSS(styles);
            if (scripts) loadJS(scripts, {{ getMarkmap: () => window.markmap }});
            Markmap.create('#mindmap', {{
                colorFreezeLevel: 2,
                initialExpandLevel: 2,
                maxWidth: 400,
                paddingX: 20,
                spacingVertical: 8,
                spacingHorizontal: 100,
            }}, root);
        }} catch(e) {{
            document.getElementById('mindmap').outerHTML =
                '<p style="padding:40px;color:#666;">Markmap failed to load. Check internet connection.</p>';
        }}
    </script>
</body>
</html>"""


# ---------------------------------------------------------------
# Format: Tab-delimited for OmniOutliner multi-column import
# ---------------------------------------------------------------

def generate_omnioutliner(packages):
    """Generate tab-delimited text that OmniOutliner imports as a multi-column outline.

    Column 1: Package name (hierarchy via tab indentation)
    Column 2: Description (from doc block)
    Column 3: Elements (counts of contained definitions)
    Column 4: Source file and line number

    Open with: open -a 'OmniOutliner' documentation/gsl-generated-package-hierarchy.txt
    OmniOutliner will import it as a multi-column outline. Save as .ooutline to keep.
    """
    root_pkg, libraries = get_root_and_libraries(packages)

    # Header row — OmniOutliner uses the first row as column titles
    lines = ["Package\tDescription\tElements\tSource"]

    def add_rows(pkg, depth=0):
        indent = "\t" * depth
        name = f"{indent}{pkg.name}"
        summary = pkg.summary_line()
        elements = pkg.element_summary()
        source = f"{pkg.source_file}:{pkg.line_number}" if pkg.source_file else ""
        lines.append(f"{name}\t{summary}\t{elements}\t{source}")
        for child in pkg.children:
            add_rows(child, depth + 1)

    # Root
    lines.append(f"Ontara\tModel-driven service system development and delivery platform\t\t")
    if root_pkg:
        for child in root_pkg.children:
            add_rows(child, depth=1)

    if libraries:
        lines.append(f"Libraries\tSeparate from main model\t\t")
        for lib in libraries:
            add_rows(lib, depth=1)

    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------
# Diff mode
# ---------------------------------------------------------------

def extract_proposal_names(proposal_path):
    if not proposal_path.exists():
        return set()
    text = proposal_path.read_text(encoding="utf-8")
    names = set()
    for match in re.finditer(r'[├└│─\s]+([\w+]+)\s+[—\-]', text):
        names.add(match.group(1))
    return names


def extract_model_names(packages):
    names = set()
    for pkg in packages:
        names.add(pkg.name)
        names.update(extract_model_names(pkg.children))
    return names


def find_package_by_name(packages, name):
    for pkg in packages:
        if pkg.name == name:
            return pkg
        found = find_package_by_name(pkg.children, name)
        if found:
            return found
    return None


def diff_report(packages):
    model_names = extract_model_names(packages)
    proposal_names = extract_proposal_names(PROPOSAL_PATH)
    model_names.discard("GenderSense")

    in_model_only = model_names - proposal_names
    in_proposal_only = proposal_names - model_names
    in_both = model_names & proposal_names

    lines = [
        "Package Hierarchy — Model vs Proposal Diff",
        "",
        f"  Model:    {len(model_names)} packages",
        f"  Proposal: {len(proposal_names)} packages",
        f"  Aligned:  {len(in_both)}",
        "",
    ]

    if not in_model_only and not in_proposal_only:
        lines.append("✓ Model and proposal are fully aligned.")
        return "\n".join(lines)

    if in_model_only:
        lines.append(f"In model but not in proposal ({len(in_model_only)}):")
        for name in sorted(in_model_only):
            pkg = find_package_by_name(packages, name)
            loc = f"  {pkg.source_file}:{pkg.line_number}" if pkg else ""
            lines.append(f"  + {name}{loc}")
        lines.append("")

    if in_proposal_only:
        lines.append(f"In proposal but not in model ({len(in_proposal_only)}):")
        lines.append("  Add to the appropriate .sysml file:")
        lines.append("")
        for name in sorted(in_proposal_only):
            lines.append(f"  - {name}")
            lines.append(f'    package {name} {{')
            lines.append(f'        private import ScalarValues::*;')
            lines.append(f'        doc /* TODO: description for {name}. */')
            lines.append(f'    }}')
            lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

SAVE_GENERATORS = {
    "markdown": generate_markdown,
    "opml":     generate_opml,
    "html":     generate_html,
    "oo":       generate_omnioutliner,
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate package hierarchy from SysML model.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Quick view (default):
  %(prog)s                        Print tree to terminal

Save to file:
  %(prog)s --save                 Save all formats
  %(prog)s --save=markdown        Markdown only
  %(prog)s --save=opml            OPML outline
  %(prog)s --save=html            Interactive HTML mindmap
  %(prog)s --save=oo              Tab-delimited for OmniOutliner (multi-column)

Check alignment:
  %(prog)s --diff                 Compare model vs proposal
        """)
    parser.add_argument("--save", nargs="?", const="all", default=None,
                        choices=["all", "markdown", "opml", "html", "oo"],
                        help="Save to file(s). No argument = all formats. 'oo' = OmniOutliner.")
    parser.add_argument("--diff", action="store_true",
                        help="Compare model against proposal")

    args = parser.parse_args()

    packages = parse_all_model_files()

    if args.diff:
        print(diff_report(packages))
        return

    if args.save:
        # Save mode: write file(s)
        formats = list(SAVE_GENERATORS.keys()) if args.save == "all" else [args.save]
        for fmt in formats:
            content = SAVE_GENERATORS[fmt](packages)
            path = OUTPUT_PATHS[fmt]
            path.write_text(content, encoding="utf-8")
            print(f"  {fmt:10s} → {path}")
        print()
        if "oo" in formats:
            print(f"  OmniOutliner:  open -a 'OmniOutliner' {OUTPUT_PATHS['oo']}")
        if "html" in formats:
            print(f"  HTML mindmap:  open {OUTPUT_PATHS['html']}")
        if "opml" in formats:
            print(f"  OPML outline:  open {OUTPUT_PATHS['opml']}")
    else:
        # Default: print the terminal tree
        print(generate_terminal_view(packages))


if __name__ == "__main__":
    main()
