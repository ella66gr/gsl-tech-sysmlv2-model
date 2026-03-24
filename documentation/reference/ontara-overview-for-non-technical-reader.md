# Ontara

*A platform for designing, building and governing service businesses*

An introduction for the interested non-specialist

---

## The problem

Every service business — a GP surgery, a hospital department, a laundry, a café — is a surprisingly complex thing. It has a service it offers, processes for delivering that service, people and equipment it depends on, money flowing in and out, and rules that govern how everything works. In a healthcare setting, add clinical pathways, regulatory obligations, governance frameworks, audit trails, and the requirement that every decision is traceable and defensible.

The knowledge of how all these pieces fit together usually lives in a patchwork: some in people's heads, some in policy documents that may or may not be current, some buried in software that nobody outside the development team can read, some in spreadsheets, some in regulatory checklists that exist in isolation from the systems they're supposed to govern. When something changes — a new regulation, a revised clinical pathway, a staffing restructure — the consequences ripple across this patchwork unpredictably. Things get missed. Compliance gaps open silently. The people running the service spend their time chasing information rather than delivering care.

This is not really a technology problem. It is a *knowledge representation* problem. The understanding of what a service business is, how it works, and what rules govern it has no single, coherent home — no place where the whole picture is visible, navigable, and trustworthy.

## What Ontara is

Ontara is a platform that gives that knowledge a home.

At its core, Ontara maintains a complete model of a service business: what value it delivers and to whom, how that value is produced and delivered, what resources and capabilities it needs, how money flows through it, and what governance obligations apply. All of this lives in one place, expressed in a form that is precise enough for computers to work with and structured enough for people to navigate and understand.

The crucial difference from conventional approaches is that the model is not documentation. It is not a description of a system that exists elsewhere. The model is the authoritative source from which the running system is generated. If you want to change how the service works, you change the model — and the system changes with it. The documentation, the governance reports, the process diagrams, the audit trails: these are all produced from the same model, automatically, and they stay in sync because they share a single source of truth.

The name Ontara evokes ontology — the study of what things are and how they relate — along with a sense of being, essence, and self-awareness. It is not a fanciful label. The platform is grounded in the idea that if you represent a service business with enough precision and completeness, the representation becomes genuinely generative: it can produce working software, governance evidence, structural diagrams, and explanations of itself, all from the same source.

## What makes it unusual

Many platforms exist for building software. What makes Ontara distinctive is not the technology it uses but the level at which it operates and two properties that follow from that.

**First: it works at the level of the business, not the technology.** Most development platforms require you to think in terms of databases, APIs, user interfaces, and code. Ontara's primary vocabulary is the language of the service itself: what is the service offering, who participates, what activities take place, what resources are needed, what does it cost, what are the governance requirements. The technology is there — it has to be — but it is downstream of the business model, not the starting point.

**Second: the system describes itself.** This is the property that takes Ontara from useful to genuinely interesting. Most software systems are opaque — you need a specialist to tell you what they do and why. Ontara's model carries enough information about its own structure and purpose that it can generate explanations of what it contains. Not static documentation that someone wrote and then forgot to update, but descriptions that are computed from the live state of the model. If the model changes, the explanations change with it, because the explanations are derived from the structure, not written alongside it.

This self-describing quality means that a service designer, a clinical lead, or a governance officer can interrogate the system directly. What does this service offer? What activities are involved in delivering it? What governance requirements apply, and where is the evidence that they're being met? The answers come from the model itself, not from a separate set of documents that may or may not reflect reality.

## What it makes possible

The practical implications become clearer with some concrete scenarios.

**Designing a new service from proven building blocks.** Ontara maintains a library of validated components — service concepts, activity types, resource models, governance patterns, financial structures — that have been tested across multiple domains. A new service can be composed by selecting and combining these components, rather than being designed from scratch every time. The platform provides real-time feedback on completeness: are all the necessary pieces in place? Are the governance requirements covered? What's missing?

**Governance traceability that actually works.** In regulated environments — and healthcare is among the most heavily regulated — the chain from regulatory requirement to operational evidence is often fragile. A regulation says you must do X; somewhere there's a policy that says how; somewhere else there's a system that supposedly enforces it; and buried in a filing cabinet or a database is the evidence that it happened. Ontara models this entire chain as a connected structure: requirement traces to constraint traces to runtime check traces to audit evidence. If a link in the chain is missing, the system knows.

**Understanding the impact of change.** One of the most valuable features of a connected model is the ability to ask: if I change this, what else is affected? Ontara tracks the relationships between all the components of a service business, including the strength and direction of their connections. This means it can tell you, before you make a change, which other parts of the system will need attention. A change to a service offering has implications for pricing, resources, governance, and activity design — and the model can surface those implications rather than leaving them to be discovered by trial and error.

**Supporting multiple services from the same foundations.** The architecture is deliberately general. The same structural vocabulary that describes a gender-affirming healthcare service can describe a café, a laundry, or a dog grooming business. These are not artificial examples — they are working demonstrator domains that validate the model's generality. Any service business can be modelled as a tenant of the platform, inheriting the same structural rigour, governance machinery, and self-describing capabilities.

## The clinical motivation

Ontara is being built by Ella Green, a GP specialist in transgender healthcare who works across NHS and private practice. The primary motivating use case is GenderSense Limited, a private gender-affirming healthcare service.

The clinical context matters because it sets the bar high. Healthcare services have complex multi-step pathways where each step has clinical, governance, and information requirements. Clinical decisions must be traceable and auditable. Regulatory obligations are extensive and overlapping. Patient data carries strict handling requirements. The consequences of getting things wrong are not merely commercial — they affect people's health and wellbeing.

A platform that can handle these demands — where governance traceability is structural rather than aspirational, where clinical pathways are modelled with the precision needed for safe care, where the system can explain and justify its own behaviour — can handle any service domain. The clinical use case is not a limitation; it is a proving ground.

The personal motivation runs deeper still. Ella's background spans clinical practice, healthcare informatics, and systems thinking. Ontara reflects a conviction that the fragmentation of knowledge in service delivery — the disconnect between what a service is supposed to do, what the technology actually does, and what the governance framework requires — is a solvable problem. Not by adding more documentation or more process, but by changing the fundamental representation: putting the knowledge into a form where it is connected, generative, and self-describing.

## Where it stands

Ontara is a real, working system, though it is still at an early stage of its ambition.

The structural model of what a service business is — the business meta model — is moderately complete and tested. It defines 28 distinct elements across five concerns: what value is delivered, how it is delivered, what resources are needed, how money flows, and what governance applies. Every element carries authored descriptions of its purpose, and structural metadata that allows the system to generate explanations of how it relates to everything else.

Three demonstrator domains are operational: a café, a laundry, and a dog grooming business. These are not toys — they are rigorous exercises of the meta model, each with domain-appropriate governance requirements. The café has a basic working application with order management, workflow orchestration, and a clinical data repository (a technology component whose real purpose is to prove patterns that will be needed in healthcare). The laundry demonstrates chemical safety governance traceability. The dog grooming business tests the vocabulary in a third, distinct context.

A developer-facing console — the Ontara Console — provides navigable views of the model: a glossary of terms with expandable explanations, a coverage matrix showing which domains exercise which components, a component catalogue, a governance traceability view, and several other perspectives. The console reads from the model and presents what the model knows about itself.

The next development phase will make the model's internal structure visually navigable — an interactive graph showing how the 28 elements relate to each other, with the strength and direction of their connections displayed as a network. This is the bridge between comprehension (understanding what each piece is) and construction (building new services from those pieces).

The clinical application for GenderSense is a destination, not the starting point. The architecture is being validated and refined in simpler domains first, building a foundation of proven patterns and validated structures before the complexity and stakes of healthcare delivery are introduced.

## Why it matters

There are many ways to build software, and many platforms that help. What makes Ontara worth paying attention to is the ambition of its central idea: that a service business can be modelled with enough precision and completeness that the model becomes the thing itself — the authoritative representation from which everything else flows.

If that idea works — and the encouraging evidence so far is that it does — the implications are significant. Service businesses become designable in the way that engineered products are designable: from clear specifications, with known components, with predictable behaviour, and with built-in quality assurance. Governance stops being a retrospective audit exercise and becomes a structural property of the system. The knowledge of how a service works stops being fragmented across documents and people and becomes navigable, queryable, and self-maintaining.

For healthcare specifically, this matters because the stakes are high, the complexity is real, and the current tools are not adequate. A platform that treats clinical governance as a structural concern rather than a compliance afterthought, that can trace the chain from a regulatory requirement to runtime evidence that it's being met, and that can explain its own behaviour in terms a clinician can interrogate — that is something worth building.

---

*Ontara is developed by Ella Green through GenderSense Limited.*

*March 2026*
