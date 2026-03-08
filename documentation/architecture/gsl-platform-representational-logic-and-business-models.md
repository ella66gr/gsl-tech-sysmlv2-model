# Representational Logic & Business Models

**State machines (finite automata and extensions)**

The system is characterised by being *in* a state, and events cause transitions between states. The model answers the question "what state is this thing in, and what happens next?" This is the natural model for entities with lifecycles — a ServiceUser who moves through states like Enquiry → Triaged → AwaitingAssessment → InTreatment → Discharged. It's also the model behind most workflow engines and status tracking. UML state diagrams and statecharts (Harel's extension that adds hierarchy and concurrency to flat state machines) are the classic notation. SysML v2 supports this through `state def` and `exhibit` constructs.

The strength is clarity about "where are we now and what can happen." The limitation is that complex systems have combinatorial state explosion — if you have 10 entities each with 5 states, the composite system has potentially 5^10 states, which is unmanageable without hierarchical decomposition.

**Petri nets and token flow (BPMN's foundation)**

As you identified, BPMN's underlying semantics are based on token flow derived from Petri nets. The system is characterised by *tokens* moving through a *net* of places and transitions. A transition fires when its input places all have tokens, consuming them and producing tokens in output places. This naturally models concurrency, synchronisation, and resource contention — things that state machines handle awkwardly. It's why BPMN feels natural for business processes: "this task and that task can happen in parallel, and we need both to complete before we proceed" is directly expressible.

The strength is that concurrent and distributed behaviour is a first-class concept. The limitation is that the token abstraction can feel disconnected from the domain — you're reasoning about token movement rather than about the business entities themselves. It can also be difficult to express complex decision logic cleanly.

**Dataflow / functional flow**

The system is characterised as a graph of transformations. Data flows in, gets processed, flows out. Each node is a function that transforms its inputs to outputs. This is the model behind signal processing, data pipelines, and much functional programming. In systems engineering, it appears as functional flow block diagrams (FFBDs) and in SysML v2 as action/flow compositions where `stream` and `flow` connect actions that process items continuously.

The strength is composability — you can reason about each transformation independently and compose them. It maps well to data processing, analytics pipelines, and any system where the dominant concern is "what happens to information as it moves through the system." The limitation is that it's less natural for modelling stateful entities with complex lifecycles, or for systems where the interesting behaviour is about waiting, synchronisation, and human decision-making.

**Event-driven / reactive models**

The system is characterised as a set of agents that respond to events. There's no single thread of control — things happen because something *triggered* them. This is the model behind event-driven architectures, publish-subscribe systems, and most modern web architectures. It's also the natural model for systems where many things are happening independently and need to coordinate loosely.

SysML v2 supports this through actions that accept events and signals between parts. The strength is that it models loosely-coupled systems well — your community platform, notifications, asynchronous communications. The limitation is that reasoning about overall system behaviour becomes harder because there's no single flow to follow; you have to think about all possible event orderings.

**Contract / interaction models**

The system is characterised by agreements between parties about what each will do. This includes the Actor model, CSP (Communicating Sequential Processes), and pi-calculus at the formal end, but also the more pragmatic concept of service contracts and API specifications. The focus is on *interfaces* — what one part of the system promises to another. UML sequence diagrams and interaction diagrams capture specific scenarios of this, but the underlying model is about the contract rather than any particular execution.

This is particularly relevant for GenderSense because you're designing a service system with multiple stakeholders (service users, clinicians, coaches, community moderators, external labs, prescribers) who interact through defined interfaces. The strength is that it forces you to think about boundaries, responsibilities, and what each party can rely on from others. The limitation is that it describes interactions rather than internal behaviour — you need to combine it with another paradigm for the internals.

**Rule-based / declarative models**

Rather than specifying *how* the system behaves step by step, you specify *what conditions must hold* and let an engine figure out the execution. This is the model behind business rule engines, Prolog (which you've explored), constraint satisfaction, and declarative policy frameworks. Decision Model and Notation (DMN), which you encountered through Camunda, sits here — you define decision tables and the engine evaluates them.

For GenderSense, this is relevant for clinical decision support, eligibility rules, escalation policies, and regulatory compliance logic. The strength is that complex conditional logic is expressed clearly and can be audited and modified independently of the process flow. The limitation is that purely declarative models can be hard to reason about in terms of "what will actually happen in this scenario" — the execution semantics are hidden in the engine.

**Agent-based / autonomous entity models**

The system is characterised as a population of autonomous agents with their own goals, behaviours, and interactions. This is the model behind multi-agent simulations, microservice architectures at the technical level, and organisational modelling at the business level. Each agent has its own internal state and decision logic, and system-level behaviour emerges from their interactions.

This is conceptually close to how a real business operates — your clinicians, service users, coaches, and admin staff are all agents with their own goals and constraints, and the business behaviour emerges from their interactions within the structures and processes you design.