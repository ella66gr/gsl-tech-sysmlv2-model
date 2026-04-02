# ================================================================
# ARCHIVED — Superseded by gen_owl_pipeline.py (Session 105)
# ================================================================
# Original: scripts/gen_ontara_bmm.py
# Produced: Session 102 (Stage 5 Phase 1 Step 2)
# Archived: Session 105 (2 April 2026)
# Verified against: GraphDB ontara-dev repository (Session 102)
# Commit at archive: 1e128f1 (Step 3 parser extraction)
#
# This is a known-good generator that produces ontara-bmm.ttl
# from hardcoded BMM data. It was the first OWL ontology generator
# and validated all 34 BMM classes in GraphDB. Retained as a
# reference implementation.
#
# The pipeline generator (gen_owl_pipeline.py) reads from
# SysML source files via the shared parser instead of hardcoded data.
# ================================================================
#!/usr/bin/env python3
"""
Ontara BMM Ontology Generator — gen_ontara_bmm.py
===================================================

Generates `ontara-bmm.ttl` — the Ontara Business Meta Model as an OWL
ontology. Declares all 34 BMM `part def`s as OWL classes, each positioned
under its BFO parent class as declared by its `@BfoType` annotation.

This is Stage 5 Phase 1 Step 2 of the Knowledge Graph implementation.

Design decisions (Session 102):
  1. IRI convention: https://ontara.dev/ontology/bmm/{ElementName}
  2. Mid-level positioning: subclass mid-level only where available;
     subclass BFO directly where no mid-level mapping exists
  3. Annotation properties: rdfs:label, rdfs:comment, skos:definition

BFO and IAO IRIs are hardcoded (stable OBO PURLs).
CCO IRIs use opaque numeric identifiers (cco:ont00001xxx) and must be
resolved from the loaded ontology via SPARQL. The lookup is stored in
`ontology/config/cco-iri-lookup.json` — populated by running this script
with `--resolve-cco` (requires GraphDB running on localhost:7200).

Usage:
    python scripts/gen_ontara_bmm.py                    # Generate ontology
    python scripts/gen_ontara_bmm.py --resolve-cco      # Populate CCO lookup from GraphDB
    python scripts/gen_ontara_bmm.py --save              # Generate and save to generated/ontology/
    python scripts/gen_ontara_bmm.py --verify            # Check CCO lookup is complete
    python scripts/gen_ontara_bmm.py --dry-run           # Print Turtle to stdout without saving

Source: Stage 5 Phase 1 — Step 2 (Session 102)
Depends on: @BfoType mapping (Session 98), KG implementation plan (Session 100)

Annotations extracted:
  @BfoType — BFO classification and mid-level parent
  @UserFacing — friendlyName → rdfs:label, shortDescription → rdfs:comment
  @PurposiveDescription — description → skos:definition
"""

import argparse
import json
import pathlib
import sys
import urllib.request
import urllib.error
import urllib.parse

# ---------------------------------------------------------------
# Paths
# ---------------------------------------------------------------

REPO_ROOT = pathlib.Path(__file__).parent.parent
CONFIG_DIR = REPO_ROOT / "ontology" / "config"
OUTPUT_DIR = REPO_ROOT / "generated" / "ontology"
CCO_LOOKUP_FILE = CONFIG_DIR / "cco-iri-lookup.json"

GRAPHDB_BASE = "http://localhost:7200"
REPO_ID = "ontara-dev"

# ---------------------------------------------------------------
# IRI Namespaces
# ---------------------------------------------------------------

ONTARA_BMM_NS = "https://ontara.dev/ontology/bmm/"
BFO_NS = "http://purl.obolibrary.org/obo/"
CCO_NS = "https://www.commoncoreontologies.org/"
IAO_NS = "http://purl.obolibrary.org/obo/"
OWL_NS = "http://www.w3.org/2002/07/owl#"
RDF_NS = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
RDFS_NS = "http://www.w3.org/2000/01/rdf-schema#"
SKOS_NS = "http://www.w3.org/2004/02/skos/core#"
XSD_NS = "http://www.w3.org/2001/XMLSchema#"
DCTERMS_NS = "http://purl.org/dc/terms/"

# ---------------------------------------------------------------
# BFO 2020 IRI Lookup (stable OBO PURLs — hardcoded)
# ---------------------------------------------------------------
# BFO uses numeric identifiers under http://purl.obolibrary.org/obo/
# These are from BFO 2020 (ISO/IEC 21838-2:2021).

BFO_IRI_LOOKUP = {
    # Top-level
    "Entity": f"{BFO_NS}BFO_0000001",
    "Continuant": f"{BFO_NS}BFO_0000002",
    "Occurrent": f"{BFO_NS}BFO_0000003",
    # Independent continuant
    "IndependentContinuant": f"{BFO_NS}BFO_0000004",
    "MaterialEntity": f"{BFO_NS}BFO_0000040",
    "ObjectAggregate": f"{BFO_NS}BFO_0000027",
    "FiatObjectPart": f"{BFO_NS}BFO_0000024",
    "Object": f"{BFO_NS}BFO_0000030",
    "Site": f"{BFO_NS}BFO_0000029",
    # Specifically dependent continuant
    "SpecificallyDependentContinuant": f"{BFO_NS}BFO_0000020",
    "Quality": f"{BFO_NS}BFO_0000019",
    "RealizableEntity": f"{BFO_NS}BFO_0000017",
    "Role": f"{BFO_NS}BFO_0000023",
    "Disposition": f"{BFO_NS}BFO_0000016",
    "Function": f"{BFO_NS}BFO_0000034",
    # Generically dependent continuant
    "GenericallyDependentContinuant": f"{BFO_NS}BFO_0000031",
    # Occurrents
    "Process": f"{BFO_NS}BFO_0000015",
    "ProcessBoundary": f"{BFO_NS}BFO_0000035",
    "TemporalRegion": f"{BFO_NS}BFO_0000008",
    # Spatial
    "SpatialRegion": f"{BFO_NS}BFO_0000006",
}

# ---------------------------------------------------------------
# IAO IRI Lookup (stable OBO PURLs — hardcoded)
# ---------------------------------------------------------------
# IAO uses numeric identifiers under http://purl.obolibrary.org/obo/

IAO_IRI_LOOKUP = {
    "IAO:InformationContentEntity": f"{IAO_NS}IAO_0000030",
    "IAO:PlanSpecification": f"{IAO_NS}IAO_0000104",
    "IAO:ObjectiveSpecification": f"{IAO_NS}IAO_0000005",
    "IAO:MeasurementDatum": f"{IAO_NS}IAO_0000109",
}

# ---------------------------------------------------------------
# CCO IRI Lookup (opaque numeric identifiers — loaded from file)
# ---------------------------------------------------------------
# CCO 2.0 uses IRIs like https://www.commoncoreontologies.org/ont00001xxx
# These must be resolved from the loaded ontology via SPARQL.
# The lookup maps our prefix:ClassName notation to actual IRIs.

# Expected CCO classes needed by the BMM mapping:
CCO_CLASSES_NEEDED = [
    "CCO:GroupOfAgents",
    "CCO:ArtifactFunction",
    "CCO:Agent",
]


def load_cco_lookup():
    """Load the CCO label→IRI lookup from the config file."""
    if not CCO_LOOKUP_FILE.exists():
        return {}
    with open(CCO_LOOKUP_FILE) as f:
        return json.load(f)


def save_cco_lookup(lookup):
    """Save the CCO label→IRI lookup to the config file."""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with open(CCO_LOOKUP_FILE, "w") as f:
        json.dump(lookup, f, indent=2)
    print(f"CCO lookup saved to {CCO_LOOKUP_FILE}")


# ---------------------------------------------------------------
# The 34 BMM Elements — Complete Mapping Data
# ---------------------------------------------------------------
# Source: @BfoType mapping discussion paper (Session 98) and
#         @UserFacing / @PurposiveDescription annotations on
#         model/business-model.sysml (Session 99).
#
# Each entry: (elementName, bfoClass, midLevelClass,
#              friendlyName, shortDescription, purposiveDescription)

BMM_ELEMENTS = [
    # ---- ServiceConcept (9 elements) ----
    (
        "CustomerSegment",
        "GenericallyDependentContinuant",
        "CCO:GroupOfAgents",
        "Customer Segment",
        "A defined group of customers with shared needs and willingness to pay.",
        "A group of people your service is designed for \u2014 people who share similar needs and reasons for choosing you. When you define your customer segments, the system uses them to connect your value propositions, pricing, and channels to the right audiences.",
    ),
    (
        "ValueProposition",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Value Proposition",
        "A promise of value to a customer segment \u2014 what they get and why it matters.",
        "The core promise your service makes to a particular group of customers \u2014 what they get from you and why they\u2019d choose you over the alternatives. When you define a value proposition, the system holds it as the anchor that your activities, resources, and pricing all exist to deliver.",
    ),
    (
        "ServiceOffering",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Service Offering",
        "A packaged unit of service that can be priced, resourced, and delivered to customers.",
        "A distinct service that your business offers \u2014 something a customer can choose, pay for, and receive. When you define a service offering, the system connects it to the activities required to deliver it, the resources it consumes, and the price the customer pays.",
    ),
    (
        "Channel",
        "Role",
        "CCO:ArtifactFunction",
        "Channel",
        "A way that customers find, reach, or receive your service.",
        "A way that customers find you, reach you, or receive your service \u2014 your website, a referral network, a walk-in counter, an app. When you define your channels, the system tracks which customer segments each channel serves and how your service offerings are delivered through them.",
    ),
    (
        "DifferentiationClaim",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Differentiation Claim",
        "An explicit, testable statement of how your service differs from alternatives.",
        "An explicit statement of how your service differs from the alternatives, from the customer\u2019s perspective. Each claim should be testable \u2014 something you can back up with evidence. When you define differentiation claims, the system records them as commitments your service is designed to fulfil.",
    ),
    (
        "ServiceSubject",
        "Role",
        "",
        "Service Subject",
        "The entity upon which a service is performed \u2014 a person, animal, object, or organisation that receives the service.",
        "The thing your service acts on \u2014 the dog being groomed, the patient receiving care, the garment being cleaned, the item being repaired. A service subject may have needs independent of whoever commissioned the service, and governance obligations may attach to the subject directly. When you identify your service subjects, the system tracks what is being served, in what condition, and with what independent requirements \u2014 separately from who is paying or making decisions.",
    ),
    (
        "ServiceParticipant",
        "Role",
        "",
        "Service Participant",
        "An entity involved in a service engagement in a defined role \u2014 customer, payer, commissioner, decision-maker, or any other role.",
        "Any person or organisation involved in a service engagement in a defined role. The person who pays, the organisation that commissions, the carer who makes decisions, the expert called in for assessment \u2014 any entity with influence on how the service proceeds. When you identify your service participants, the system tracks who is involved, in what capacity, and how their status affects the service workflow. The set of possible roles is open \u2014 the model does not constrain what kinds of participation your service may involve.",
    ),
    (
        "CatalogueEntry",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Catalogue Entry",
        "A record of something your business has decided to offer, with its price and status.",
        "A record of something your business has decided to offer \u2014 whether that\u2019s a menu item, a treatment, a course, or any other unit you sell or provide. The catalogue entry connects what the thing intrinsically is to how your business offers it: its price, availability, and status. When you add a catalogue entry, the system tracks it as part of your active offering.",
    ),
    (
        "ExternalReference",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "External Reference",
        "A link to authoritative knowledge that lives outside your system.",
        "A link to knowledge that lives outside your system \u2014 a supplier datasheet, a regulatory standard, a clinical guideline, an accreditation body. The system doesn\u2019t own this information; it points to it, so you always know where authoritative external knowledge sits in relation to your service.",
    ),
    # ---- ActivityModel (5 elements) ----
    (
        "ActivityType",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Activity Type",
        "A category of work that your service performs \u2014 a named, measurable kind of doing.",
        "A named, measurable kind of work that your service performs. Whether it\u2019s a consultation, a grooming session, a dry-cleaning cycle, or a training module \u2014 each activity type defines what is done, roughly how long it takes, and how frequently it occurs. When you define your activity types, the system uses them to connect your service delivery to resources, costs, and capacity.",
    ),
    (
        "ActivityRecord",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Activity Record",
        "A recorded instance of an activity \u2014 what happened, when, and the outcome.",
        "A recorded instance of an activity that actually happened \u2014 when it occurred, what was done, the outcome, and any notes. Activity records are how the system knows what your service has actually delivered, as opposed to what it planned to deliver. When the system records an activity, it connects to the activity type, the resources involved, and the cost allocation.",
    ),
    (
        "ActivityBudget",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Activity Budget",
        "A planned volume of activity over a time period \u2014 your forward-looking capacity commitment.",
        "A forward-looking plan of how much activity you expect to perform over a period. It connects an activity type to a target volume, a time period, and the assumptions behind the estimate. When you set an activity budget, the system uses it as a reference point for resource planning, cost projection, and variance analysis.",
    ),
    (
        "ActivityGranularity",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Activity Granularity",
        "A policy declaring how finely your service tracks its activities.",
        "A policy decision about how precisely your service tracks what it does \u2014 do you log every customer interaction, or just completed engagements? Do you distinguish between different types of consultation, or treat them as one? Activity granularity is a design choice, not a given. When you set it, the system calibrates its tracking and reporting to that level of detail.",
    ),
    (
        "ActivityCostAllocation",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Activity Cost Allocation",
        "The mapping from a type of activity to its financial cost \u2014 how much it costs to do this kind of work.",
        "The mapping from a type of activity to its financial cost. It connects the doing (activity types) to the spending (cost drivers, revenue). When the system allocates costs to activities, it can answer questions like \u2018what does it cost us to deliver a grooming session?\u2019 or \u2018how much of our spend goes on consultations vs. administration?\u2019",
    ),
    # ---- ResourcePlanning (7 elements) ----
    (
        "ResourceType",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Resource Type",
        "A category of resource that your service requires \u2014 personnel, technology, estate, or consumables.",
        "A category of resource your service needs \u2014 the kind of person, technology, space, or consumable that enables delivery. When you define resource types, the system uses them to connect your capacity planning to the people, equipment, and infrastructure that make your service work.",
    ),
    (
        "ResourceInstance",
        "Role",
        "CCO:Agent",
        "Resource Instance",
        "A planning-level archetype of a specific resource \u2014 'a prescribing clinician at 0.5 FTE'.",
        "A specific resource configuration for planning purposes \u2014 not a named individual, but a defined slot: a prescribing clinician at 0.5 FTE, a grooming table at full availability, a consultation room shared with another service. When you define resource instances, the system tracks what is available, at what capacity, and what it costs.",
    ),
    (
        "Capability",
        "Disposition",
        "CCO:ArtifactFunction",
        "Capability",
        "An organised ability to produce a defined service function \u2014 what your service can do.",
        "An organised ability your service has to produce a defined outcome \u2014 the right combination of people, equipment, space, and process to deliver a specific function. When you define capabilities, the system maps them to the resources that enable them and the strategic objectives they serve.",
    ),
    (
        "CapacityModel",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Capacity Model",
        "A model of how your resource configuration translates into throughput capacity.",
        "An assertion about how your resource configuration translates into throughput \u2014 how many engagements per week, how many concurrent patients, how many items processed per shift. When you define a capacity model, the system uses it to detect bottlenecks, project future capacity needs, and connect resource planning to activity budgets.",
    ),
    (
        "ResourceConstraint",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Resource Constraint",
        "A limit on resource availability \u2014 regulatory, practical, or contractual.",
        "A limit on what resources are available \u2014 whether imposed externally (regulation, contract, physical law) or declared internally (policy, practical reality). When you record a resource constraint, the system factors it into capacity planning and flags it when plans exceed available resources.",
    ),
    (
        "InventoryRecord",
        "GenericallyDependentContinuant",
        "IAO:MeasurementDatum",
        "Inventory Record",
        "A point-in-time record of how much you have of something.",
        "A snapshot of how much stock you have of something \u2014 measured at a specific point in time, against a specific item. Inventory records close the loop between what you planned (catalogue, budget) and what you actually have (counted, measured, observed). When the system records inventory, it connects to catalogue entries and resource constraints.",
    ),
    (
        "ObjectiveCapabilityMapping",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Objective\u2013Capability Mapping",
        "A declared link between a strategic objective and the capabilities required to achieve it.",
        "A declared traceability link between a strategic objective and the capabilities your service needs to achieve it. When you map objectives to capabilities, the system can answer: \u2018do we have the capabilities to achieve this objective?\u2019 and \u2018which objectives are at risk if this capability degrades?\u2019",
    ),
    # ---- FinancialPlanning (6 elements) ----
    (
        "RevenueStream",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Revenue Stream",
        "A mechanism by which your service generates income.",
        "A way your business earns money \u2014 whether per-episode fees, subscriptions, block contracts, or ancillary income. When you define your revenue streams, the system connects them to the service offerings they monetise, the customer segments they draw from, and the pricing models they apply.",
    ),
    (
        "CostDriver",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Cost Driver",
        "A structural factor that generates cost in your service.",
        "A factor that generates cost in your service \u2014 a resource type, an activity pattern, a regulatory requirement, or an operational overhead. When you identify cost drivers, the system connects them to the resources and activities that incur the cost, so you can see where money goes and why.",
    ),
    (
        "UnitEconomics",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Unit Economics",
        "The financial profile of one unit of service \u2014 revenue, cost, and margin per engagement.",
        "The financial picture of one unit of your service \u2014 what it costs to deliver one engagement, what revenue it generates, and what margin remains. When you define unit economics, the system uses them as the building block for financial projections, break-even analysis, and pricing decisions.",
    ),
    (
        "PricingModel",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Pricing Model",
        "The logic that determines what a customer pays for your service.",
        "The rules and logic that determine what a customer pays \u2014 fixed fees, tiered pricing, time-based rates, outcome-based payments, or any other pricing structure. When you define a pricing model, the system connects it to the service offerings it prices and the revenue streams it feeds.",
    ),
    (
        "FinancialProjection",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Financial Projection",
        "A forward-looking financial picture \u2014 projected revenue, costs, and margins over time.",
        "A forward-looking financial picture for your service \u2014 projected revenue, costs, and margins built from your unit economics, activity budgets, and growth assumptions. When you create a financial projection, the system assembles it from your actual model data, not from a disconnected spreadsheet.",
    ),
    # ---- GovernanceMapping (2 elements) ----
    (
        "GovernanceRequirement",
        "GenericallyDependentContinuant",
        "IAO:ObjectiveSpecification",
        "Governance Requirement",
        "A regulatory, legal, or policy obligation that your service must satisfy.",
        "A specific obligation your service must satisfy \u2014 a regulation, a professional standard, a contractual requirement, an internal policy commitment. When you record governance requirements, the system tracks them as constraints on your service design and connects them to the evidence that demonstrates compliance.",
    ),
    (
        "AuditEvidenceRecord",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "Audit Evidence Record",
        "A record that demonstrates compliance with a governance requirement.",
        "A piece of evidence that demonstrates you are meeting a specific governance requirement \u2014 a completed checklist, a signed attestation, a test result, a policy document with a review date. When you record audit evidence, the system connects it to the governance requirement it satisfies.",
    ),
    # ---- StakeholderModel (6 elements) ----
    (
        "StakeholderRelationship",
        "GenericallyDependentContinuant",
        "",
        "Stakeholder Relationship",
        "A typed, ongoing relationship between your service and an external entity.",
        "A typed, ongoing relationship between your service and an external entity \u2014 a supplier, a partner, a regulator, a funder, a community group. When you define stakeholder relationships, the system tracks the nature of the relationship, its criticality, and how it connects to your service delivery.",
    ),
    (
        "CooperativeArrangement",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Cooperative Arrangement",
        "A formalised agreement for shared service delivery with another organisation.",
        "A formalised agreement between your service and another organisation for shared delivery \u2014 joint clinics, shared staff, reciprocal referral agreements, service-level agreements. When you define cooperative arrangements, the system tracks the terms, responsibilities, and expected outcomes of the partnership.",
    ),
    (
        "ReferralPathway",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Referral Pathway",
        "A structured route by which people or work items flow between your service and others.",
        "A defined route by which people or work items flow between your service and another \u2014 inbound referrals from GPs, outbound referrals to specialists, or bidirectional flows with partner organisations. When you define referral pathways, the system tracks direction, criteria, protocol, and expected response times.",
    ),
    (
        "ExternalDependency",
        "GenericallyDependentContinuant",
        "IAO:InformationContentEntity",
        "External Dependency",
        "A record of something your service relies on that you do not control.",
        "A record of something your service relies on that you do not control \u2014 a supplier, a data feed, an accreditation body, a funding decision. When you record external dependencies, the system tracks the nature of the reliance, its criticality, and what would happen if it failed or changed.",
    ),
    (
        "CommunityRelationship",
        "GenericallyDependentContinuant",
        "",
        "Community Relationship",
        "Your service\u2019s constitutive connection to a community it serves or belongs to.",
        "Your service\u2019s constitutive connection to a community \u2014 the patient community, the local area, a professional network, a cultural group. This is not a transactional relationship; it\u2019s the fabric your service exists within. When you define community relationships, the system tracks how your service gives back, listens, and maintains its social licence to operate.",
    ),
    (
        "ParticipationModel",
        "GenericallyDependentContinuant",
        "IAO:PlanSpecification",
        "Participation Model",
        "A specification of how customers or patients participate in your service.",
        "A specification of how the people your service serves participate in it \u2014 what decisions they make, what information they contribute, how much self-service is available, and how their voice shapes the service. When you define a participation model, the system tracks the scope and depth of participation as a design commitment, not an afterthought.",
    ),
]

# ---------------------------------------------------------------
# CCO SPARQL Resolution
# ---------------------------------------------------------------

SPARQL_CCO_LOOKUP = """
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX cco: <https://www.commoncoreontologies.org/>

SELECT ?iri ?label WHERE {
    ?iri a owl:Class .
    ?iri rdfs:label ?label .
    FILTER(STRSTARTS(STR(?iri), "https://www.commoncoreontologies.org/"))
    FILTER(?label IN (
        "Group of Agents"@en,
        "Artifact Function"@en,
        "Agent"@en
    ))
}
ORDER BY ?label
"""

# Map from our CCO:ClassName notation to the rdfs:label used in CCO
CCO_LABEL_MAP = {
    "CCO:GroupOfAgents": "Group of Agents",
    "CCO:ArtifactFunction": "Artifact Function",
    "CCO:Agent": "Agent",
}


def resolve_cco_iris():
    """Query GraphDB to resolve CCO class labels to opaque IRIs."""
    print(f"Querying GraphDB ({GRAPHDB_BASE}) for CCO class IRIs...")

    sparql_encoded = urllib.parse.quote(SPARQL_CCO_LOOKUP)
    url = f"{GRAPHDB_BASE}/repositories/{REPO_ID}?query={sparql_encoded}"

    req = urllib.request.Request(url, headers={"Accept": "application/sparql-results+json"})
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except urllib.error.URLError as e:
        print(f"ERROR: Cannot reach GraphDB at {GRAPHDB_BASE}: {e}")
        print("Is GraphDB running?")
        sys.exit(1)

    bindings = data.get("results", {}).get("bindings", [])

    # Build reverse lookup: label → IRI
    label_to_iri = {}
    for row in bindings:
        label = row["label"]["value"]
        iri = row["iri"]["value"]
        label_to_iri[label] = iri
        print(f"  Found: {label} → {iri}")

    # Build our notation → IRI lookup
    lookup = {}
    for notation, label in CCO_LABEL_MAP.items():
        if label in label_to_iri:
            lookup[notation] = label_to_iri[label]
        else:
            print(f"  WARNING: {notation} (label '{label}') not found in GraphDB")

    # Report
    found = len(lookup)
    needed = len(CCO_LABEL_MAP)
    print(f"\nResolved {found}/{needed} CCO classes.")

    if found < needed:
        missing = set(CCO_LABEL_MAP.keys()) - set(lookup.keys())
        print(f"Missing: {missing}")
        print("These classes may use different labels in CCO 2.0.")
        print("Run a broader SPARQL query to investigate.")

    return lookup


# ---------------------------------------------------------------
# IRI Resolution
# ---------------------------------------------------------------

def resolve_parent_iri(bfo_class, mid_level_class, cco_lookup):
    """
    Resolve the parent class IRI for rdfs:subClassOf.

    Design decision 2 (Session 102):
      - If midLevelClass is non-empty → use mid-level IRI
      - If midLevelClass is empty → use BFO IRI directly
    """
    if mid_level_class:
        # Try IAO first
        if mid_level_class in IAO_IRI_LOOKUP:
            return IAO_IRI_LOOKUP[mid_level_class]
        # Try CCO
        if mid_level_class in cco_lookup:
            return cco_lookup[mid_level_class]
        # Not resolved
        return None
    else:
        # No mid-level — fall back to BFO
        if bfo_class in BFO_IRI_LOOKUP:
            return BFO_IRI_LOOKUP[bfo_class]
        return None


# ---------------------------------------------------------------
# Turtle Generation
# ---------------------------------------------------------------

def generate_turtle(cco_lookup):
    """Generate the ontara-bmm.ttl Turtle content."""
    lines = []

    # Prefixes
    lines.append(f"@prefix ontara-bmm: <{ONTARA_BMM_NS}> .")
    lines.append(f"@prefix bfo: <{BFO_NS}> .")
    lines.append(f"@prefix cco: <{CCO_NS}> .")
    lines.append(f"@prefix iao: <{IAO_NS}> .")
    lines.append(f"@prefix owl: <{OWL_NS}> .")
    lines.append(f"@prefix rdf: <{RDF_NS}> .")
    lines.append(f"@prefix rdfs: <{RDFS_NS}> .")
    lines.append(f"@prefix skos: <{SKOS_NS}> .")
    lines.append(f"@prefix xsd: <{XSD_NS}> .")
    lines.append(f"@prefix dcterms: <{DCTERMS_NS}> .")
    lines.append("")

    # Ontology declaration
    lines.append("# =============================================")
    lines.append("# Ontara BMM Ontology")
    lines.append("# =============================================")
    lines.append(f"<{ONTARA_BMM_NS}> rdf:type owl:Ontology ;")
    lines.append(f'    rdfs:label "Ontara Business Meta Model"@en ;')
    lines.append(f'    rdfs:comment "OWL representation of the 34 BMM part defs from the Ontara platform. Each class is positioned under its BFO 2020 parent via @BfoType annotations."@en ;')
    lines.append(f'    owl:versionInfo "Generated by gen_ontara_bmm.py — Session 102"@en ;')
    lines.append(f'    dcterms:created "2026-04-01"^^xsd:date .')
    lines.append("")

    # Imports — declare BFO, CCO, IAO as imported ontologies
    # (GraphDB handles actual import resolution; these are documentation)
    lines.append("# Imports (loaded separately into GraphDB)")
    lines.append(f"# BFO 2020: <http://purl.obolibrary.org/obo/bfo-core.owl>")
    lines.append(f"# CCO 2.0:  <{CCO_NS}CommonCoreOntologiesMerged>")
    lines.append(f"# IAO:      <http://purl.obolibrary.org/obo/iao.owl>")
    lines.append("")

    # Track statistics
    resolved_count = 0
    unresolved = []

    # Class declarations
    lines.append("# =============================================")
    lines.append("# BMM Classes (34 elements)")
    lines.append("# =============================================")
    lines.append("")

    current_concern = None
    concern_map = {
        "CustomerSegment": "ServiceConcept",
        "ValueProposition": "ServiceConcept",
        "ServiceOffering": "ServiceConcept",
        "Channel": "ServiceConcept",
        "DifferentiationClaim": "ServiceConcept",
        "ServiceSubject": "ServiceConcept",
        "ServiceParticipant": "ServiceConcept",
        "CatalogueEntry": "ServiceConcept",
        "ExternalReference": "ServiceConcept",
        "ActivityType": "ActivityModel",
        "ActivityRecord": "ActivityModel",
        "ActivityBudget": "ActivityModel",
        "ActivityGranularity": "ActivityModel",
        "ActivityCostAllocation": "ActivityModel",
        "ResourceType": "ResourcePlanning",
        "ResourceInstance": "ResourcePlanning",
        "Capability": "ResourcePlanning",
        "CapacityModel": "ResourcePlanning",
        "ResourceConstraint": "ResourcePlanning",
        "InventoryRecord": "ResourcePlanning",
        "ObjectiveCapabilityMapping": "ResourcePlanning",
        "RevenueStream": "FinancialPlanning",
        "CostDriver": "FinancialPlanning",
        "UnitEconomics": "FinancialPlanning",
        "PricingModel": "FinancialPlanning",
        "FinancialProjection": "FinancialPlanning",
        "GovernanceRequirement": "GovernanceMapping",
        "AuditEvidenceRecord": "GovernanceMapping",
        "StakeholderRelationship": "StakeholderModel",
        "CooperativeArrangement": "StakeholderModel",
        "ReferralPathway": "StakeholderModel",
        "ExternalDependency": "StakeholderModel",
        "CommunityRelationship": "StakeholderModel",
        "ParticipationModel": "StakeholderModel",
    }

    for elem in BMM_ELEMENTS:
        (name, bfo_class, mid_level, friendly_name,
         short_desc, purposive_desc) = elem

        # Section header
        concern = concern_map.get(name, "Unknown")
        if concern != current_concern:
            current_concern = concern
            lines.append(f"# --- {concern} ---")
            lines.append("")

        # Resolve parent IRI
        parent_iri = resolve_parent_iri(bfo_class, mid_level, cco_lookup)

        if parent_iri:
            resolved_count += 1
        else:
            unresolved.append((name, bfo_class, mid_level))

        # Escape quotes in strings for Turtle
        def escape_turtle(s):
            return s.replace("\\", "\\\\").replace('"', '\\"')

        # Build the class declaration
        class_iri = f"ontara-bmm:{name}"
        lines.append(f"### {ONTARA_BMM_NS}{name}")
        lines.append(f"{class_iri} rdf:type owl:Class ;")

        # rdfs:subClassOf — use full IRI (not prefixed) for resolved parents
        if parent_iri:
            lines.append(f"    rdfs:subClassOf <{parent_iri}> ;")
        else:
            # Unresolved mid-level — fall back to BFO
            bfo_iri = BFO_IRI_LOOKUP.get(bfo_class)
            if bfo_iri:
                lines.append(f"    rdfs:subClassOf <{bfo_iri}> ;  # Fallback: mid-level '{mid_level}' unresolved")
            else:
                lines.append(f"    # WARNING: No parent IRI resolved for bfoClass='{bfo_class}', midLevel='{mid_level}'")

        # rdfs:label from @UserFacing.friendlyName
        lines.append(f'    rdfs:label "{escape_turtle(friendly_name)}"@en ;')

        # rdfs:comment from @UserFacing.shortDescription
        lines.append(f'    rdfs:comment "{escape_turtle(short_desc)}"@en ;')

        # skos:definition from @PurposiveDescription.description
        lines.append(f'    skos:definition "{escape_turtle(purposive_desc)}"@en .')

        lines.append("")

    # Summary comment
    lines.append("# =============================================")
    lines.append(f"# Summary: {len(BMM_ELEMENTS)} BMM classes declared")
    lines.append(f"# Parent IRIs resolved: {resolved_count}/{len(BMM_ELEMENTS)}")
    if unresolved:
        lines.append(f"# Unresolved mid-level mappings ({len(unresolved)}):")
        for name, bfo, mid in unresolved:
            lines.append(f"#   {name}: bfo={bfo}, midLevel='{mid}'")
    lines.append("# =============================================")

    return "\n".join(lines), resolved_count, unresolved


# ---------------------------------------------------------------
# Verification
# ---------------------------------------------------------------

def verify_lookup(cco_lookup):
    """Check that all needed CCO classes are in the lookup."""
    print("Verifying CCO IRI lookup completeness...")
    missing = []
    for notation in CCO_CLASSES_NEEDED:
        if notation not in cco_lookup:
            missing.append(notation)
        else:
            print(f"  OK: {notation} → {cco_lookup[notation]}")

    if missing:
        print(f"\n  MISSING ({len(missing)}):")
        for m in missing:
            print(f"    {m}")
        print(f"\nRun: python scripts/gen_ontara_bmm.py --resolve-cco")
        return False
    else:
        print(f"\nAll {len(CCO_CLASSES_NEEDED)} CCO classes resolved.")
        return True


# ---------------------------------------------------------------
# Main
# ---------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Generate the Ontara BMM ontology (ontara-bmm.ttl)"
    )
    parser.add_argument("--resolve-cco", action="store_true",
                        help="Query GraphDB to populate CCO IRI lookup")
    parser.add_argument("--save", action="store_true",
                        help="Save to generated/ontology/ontara-bmm.ttl")
    parser.add_argument("--verify", action="store_true",
                        help="Check CCO lookup completeness")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print Turtle to stdout without saving")
    args = parser.parse_args()

    # Handle --resolve-cco
    if args.resolve_cco:
        lookup = resolve_cco_iris()
        save_cco_lookup(lookup)
        return

    # Load CCO lookup
    cco_lookup = load_cco_lookup()

    # Handle --verify
    if args.verify:
        ok = verify_lookup(cco_lookup)
        sys.exit(0 if ok else 1)

    # Generate
    print(f"Generating ontara-bmm.ttl ({len(BMM_ELEMENTS)} BMM classes)...")
    print(f"CCO lookup: {len(cco_lookup)} entries loaded from {CCO_LOOKUP_FILE}")

    turtle_content, resolved, unresolved = generate_turtle(cco_lookup)

    print(f"Resolved: {resolved}/{len(BMM_ELEMENTS)} parent IRIs")
    if unresolved:
        print(f"Unresolved ({len(unresolved)}):")
        for name, bfo, mid in unresolved:
            if mid:
                print(f"  {name}: mid-level '{mid}' not in CCO lookup — falling back to BFO:{bfo}")
            else:
                print(f"  {name}: no mid-level mapping — using BFO:{bfo} directly")

    # Output
    if args.dry_run:
        print("\n--- Turtle output ---\n")
        print(turtle_content)
        return

    if args.save or not args.dry_run:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        output_path = OUTPUT_DIR / "ontara-bmm.ttl"
        output_path.write_text(turtle_content, encoding="utf-8")
        print(f"\nSaved to {output_path}")
        print(f"File size: {output_path.stat().st_size:,} bytes")

        # Also report what to do next
        if unresolved and any(mid for _, _, mid in unresolved):
            print(f"\nNOTE: {len([u for u in unresolved if u[2]])} classes have unresolved CCO mid-level parents.")
            print("Run: python scripts/gen_ontara_bmm.py --resolve-cco")
            print("Then: python scripts/gen_ontara_bmm.py --save")
        else:
            print("\nNext steps:")
            print("  1. Validate in Protégé: open generated/ontology/ontara-bmm.ttl")
            print("  2. Load into GraphDB:")
            print(f"     curl -X POST {GRAPHDB_BASE}/repositories/{REPO_ID}/statements \\")
            print(f"       -H 'Content-Type: text/turtle' \\")
            print(f"       -G --data-urlencode 'context=<https://ontara.dev/graph/domain>' \\")
            print(f"       --data-binary @generated/ontology/ontara-bmm.ttl")
            print("  3. Verify: python scripts/setup_graphdb.py --verify")


if __name__ == "__main__":
    main()
