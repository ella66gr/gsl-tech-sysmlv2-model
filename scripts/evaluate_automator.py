"""
Syside Automator Evaluation Script
===================================

Evaluates whether Syside Automator can replace the regex-based generators
used in the coffee shop demonstrator. Loads the GenderSense model and
performs the kinds of queries that generators need.

Evaluation criteria:
1. Can it load a multi-file model?
2. Can it enumerate element types (part defs, enum defs, use case defs)?
3. Can it read attributes, references, and doc comments?
4. Can it traverse package hierarchy?
5. Can it find requirement/constraint/satisfy relationships?

Prerequisites:
    pip install syside
    # License key must be set — see https://docs.sensmetry.com/automator/install.html
    # Set SYSIDE_LICENSE_KEY env var or use keyring

Usage:
    cd ~/Developer/gsl-tech/gsl-sysml-model
    python scripts/evaluate_automator.py
"""

import pathlib
import sys

try:
    import syside
except ImportError:
    print("ERROR: syside not installed. Run: pip install syside")
    sys.exit(1)

MODEL_DIR = pathlib.Path(__file__).parent.parent / "model"


def load_model():
    """Test 1: Load multi-file model."""
    print("=" * 60)
    print("TEST 1: Load multi-file GenderSense model")
    print("=" * 60)

    sysml_files = sorted(MODEL_DIR.glob("*.sysml"))
    print(f"Found {len(sysml_files)} .sysml files:")
    for f in sysml_files:
        print(f"  {f.name}")

    model, diagnostics = syside.load_model(sysml_files)

    # Diagnostics object — inspect its attributes
    print(f"\nModel loaded successfully.")
    print(f"  Diagnostics type: {type(diagnostics).__name__}")
    print(f"  Diagnostics attrs: {[a for a in dir(diagnostics) if not a.startswith('_')]}")
    try:
        if hasattr(diagnostics, 'diagnostics'):
            diag_list = list(diagnostics.diagnostics)
            print(f"  Messages: {len(diag_list)}")
            for d in diag_list[:10]:
                print(f"    {d}")
        elif hasattr(diagnostics, 'errors'):
            print(f"  Errors: {diagnostics.errors}")
    except Exception as e:
        print(f"  Could not read diagnostics: {e}")

    return model, diagnostics


def enumerate_packages(model):
    """Test 2: Enumerate packages and their hierarchy."""
    print("\n" + "=" * 60)
    print("TEST 2: Enumerate packages")
    print("=" * 60)

    packages = list(model.elements(syside.Package))
    print(f"Total packages: {len(packages)}")
    for pkg in packages:
        if pkg.name:
            # Try to get parent package name for hierarchy context
            parent_name = ""
            if hasattr(pkg, 'parent') and pkg.parent and hasattr(pkg.parent, 'name'):
                parent_name = f" (parent: {pkg.parent.name})" if pkg.parent.name else ""
            print(f"  {pkg.name}{parent_name}")


def enumerate_part_definitions(model):
    """Test 3: Enumerate part definitions with their attributes — this is what gen_typescript_types.py does."""
    print("\n" + "=" * 60)
    print("TEST 3: Enumerate part definitions (generator replacement test)")
    print("=" * 60)

    part_defs = list(model.elements(syside.PartDefinition))
    print(f"Total part definitions: {len(part_defs)}")

    for pd in part_defs:
        print(f"\n  part def {pd.name}:")

        # Try to access documentation
        if hasattr(pd, 'documentation') and pd.documentation:
            for doc in pd.documentation.collect():
                body = doc.body if hasattr(doc, 'body') else str(doc)
                print(f"    doc: {str(body)[:80]}...")

        # Try to access owned members (attributes, refs, etc.)
        for member in pd.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def enumerate_enum_definitions(model):
    """Test 4: Enumerate enum definitions — needed for type generation."""
    print("\n" + "=" * 60)
    print("TEST 4: Enumerate enum definitions")
    print("=" * 60)

    enum_defs = list(model.elements(syside.EnumerationDefinition))
    print(f"Total enum definitions: {len(enum_defs)}")

    for ed in enum_defs:
        print(f"\n  enum def {ed.name}:")
        for member in ed.owned_members.collect():
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_name}")


def enumerate_use_case_definitions(model):
    """Test 5: Enumerate use case definitions — new element type for GenderSense."""
    print("\n" + "=" * 60)
    print("TEST 5: Enumerate use case definitions")
    print("=" * 60)

    uc_defs = list(model.elements(syside.UseCaseDefinition))
    print(f"Total use case definitions: {len(uc_defs)}")

    for uc in uc_defs[:10]:  # Show first 10 only
        parent_name = ""
        if hasattr(uc, 'parent') and uc.parent and hasattr(uc.parent, 'name'):
            parent_name = f" in {uc.parent.name}" if uc.parent.name else ""
        print(f"  {uc.name}{parent_name}")

    if len(uc_defs) > 10:
        print(f"  ... and {len(uc_defs) - 10} more")


def enumerate_requirement_definitions(model):
    """Test 6: Enumerate requirement definitions."""
    print("\n" + "=" * 60)
    print("TEST 6: Enumerate requirement definitions")
    print("=" * 60)

    req_defs = list(model.elements(syside.RequirementDefinition))
    print(f"Total requirement definitions: {len(req_defs)}")

    for rd in req_defs:
        print(f"\n  requirement def {rd.name}:")
        for member in rd.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def enumerate_constraint_definitions(model):
    """Test 7: Enumerate constraint definitions."""
    print("\n" + "=" * 60)
    print("TEST 7: Enumerate constraint definitions")
    print("=" * 60)

    constraint_defs = list(model.elements(syside.ConstraintDefinition))
    print(f"Total constraint definitions: {len(constraint_defs)}")

    for cd in constraint_defs:
        print(f"\n  constraint def {cd.name}:")
        for member in cd.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def enumerate_satisfy_relationships(model):
    """Test 8: Find satisfy relationships — governance traceability chain."""
    print("\n" + "=" * 60)
    print("TEST 8: Enumerate satisfy relationships")
    print("=" * 60)

    satisfactions = list(model.elements(syside.SatisfyRequirementUsage))
    print(f"Total satisfy relationships: {len(satisfactions)}")

    for sat in satisfactions:
        sat_name = sat.name if hasattr(sat, 'name') and sat.name else "<unnamed>"
        print(f"\n  satisfy: {sat_name}")
        print(f"    type: {type(sat).__name__}")
        for member in sat.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def enumerate_state_definitions(model):
    """Test 9: Enumerate state definitions — needed for state machine generation."""
    print("\n" + "=" * 60)
    print("TEST 9: Enumerate state definitions")
    print("=" * 60)

    state_defs = list(model.elements(syside.StateDefinition))
    print(f"Total state definitions: {len(state_defs)}")

    for sd in state_defs:
        print(f"\n  state def {sd.name}:")
        for member in sd.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def enumerate_metadata_definitions(model):
    """Test 10: Enumerate metadata definitions."""
    print("\n" + "=" * 60)
    print("TEST 10: Enumerate metadata definitions")
    print("=" * 60)

    metadata_defs = list(model.elements(syside.MetadataDefinition))
    print(f"Total metadata definitions: {len(metadata_defs)}")

    for md in metadata_defs:
        print(f"\n  metadata def {md.name}:")
        for member in md.owned_members.collect():
            member_type = type(member).__name__
            member_name = member.name if hasattr(member, 'name') and member.name else "<unnamed>"
            print(f"    {member_type}: {member_name}")


def main():
    print(f"Syside Automator version: {syside.__version__}")
    print(f"Model directory: {MODEL_DIR}")
    print()

    result = load_model()
    if result is None:
        print("\nModel failed to load. Cannot proceed.")
        sys.exit(1)
    model, diagnostics = result

    enumerate_packages(model)
    enumerate_part_definitions(model)
    enumerate_enum_definitions(model)
    enumerate_use_case_definitions(model)
    enumerate_requirement_definitions(model)
    enumerate_constraint_definitions(model)
    enumerate_satisfy_relationships(model)
    enumerate_state_definitions(model)
    enumerate_metadata_definitions(model)

    print("\n" + "=" * 60)
    print("EVALUATION SUMMARY")
    print("=" * 60)
    print(f"Syside version:        {syside.__version__}")
    print(f"Files loaded:          {len(list(MODEL_DIR.glob('*.sysml')))}")
    print(f"Packages:              {len(list(model.elements(syside.Package)))}")
    print(f"Part definitions:      {len(list(model.elements(syside.PartDefinition)))}")
    print(f"Enum definitions:      {len(list(model.elements(syside.EnumerationDefinition)))}")
    print(f"Use case definitions:  {len(list(model.elements(syside.UseCaseDefinition)))}")
    print(f"Requirement defs:      {len(list(model.elements(syside.RequirementDefinition)))}")
    print(f"Constraint defs:       {len(list(model.elements(syside.ConstraintDefinition)))}")
    print(f"Satisfy relationships: {len(list(model.elements(syside.SatisfyRequirementUsage)))}")
    print(f"State definitions:     {len(list(model.elements(syside.StateDefinition)))}")
    print(f"Metadata definitions:  {len(list(model.elements(syside.MetadataDefinition)))}")


if __name__ == "__main__":
    main()
