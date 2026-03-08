# Package hierarchy proposal

**Status:** Reconciled with SysML model 8 March 2026 (Session 7). All packages now exist in the model. Naming updated to reflect SysML identifier constraints.

**Note:** The TemporalMetadata package lives as a separate library (`libraries/temporal-metadata/temporal-metadata.sysml`), not under Foundation::MetadataLibrary. It is imported directly by orchestration-layer action flows.

GenderSense
├── Enterprise
│   ├── Organisation          — roles, teams, governance structure
│   ├── Regulation            — CQC, ICO/GDPR, DCB0129, professional standards
│   ├── Strategy              — partnerships, business model, ethos & values
│   └── Risk                  — clinical risk, business continuity, safeguarding
│
├── Knowledge
│   ├── ClinicalDecisionSupport  — decision rules, eligibility criteria, monitoring protocols
│   ├── ConstraintLibrary        — composable clinical constraints, safety rules, interaction checks
│   ├── LogicEngine              — inference rules, Prolog-style reasoning, deterministic evaluation
│   ├── DecisionModels           — DMN-style decision tables, decision requirement graphs
│   ├── OutcomeFramework         — outcome definitions, measurement points, structured capture
│   ├── LearningCycles           — pathway refinement process, evidence review, change control
│   └── Analytics                — data contracts for BI/predictive/ML, event streams,
│                                  LLM integration points, advisory layer interface
│
├── ServiceDelivery
│   ├── PatientJourney        — top-level lifecycle (acquisition → discharge)
│   ├── ClinicalPathways
│   │   ├── HormoneTherapy    — initiation, monitoring, shared care
│   │   ├── Assessment        — new patient assessment, self-assessment, clinician assessment
│   │   ├── Referrals         — inbound, outbound, specialist
│   │   └── Prescribing       — prescribing, dispensing, monitoring
│   ├── Consent               — consent models, withdrawal, capacity
│   ├── CoachingSupport       — transition coaching, group work, peer support
│   ├── ClinicalGovernance    — policies, protocols, procedures, audit, outcome tracking
│   └── ClinicalEntities      — patient, episode, consultation, prescription, referral, lab result
│
├── Platform
│   ├── PatientPortal         — patient-facing web platform, self-management hub
│   │   ├── SelfManagement    — personal dashboard, progress tracking, alerts & notifications,
│   │   │                       access to individual clinical records including blood results,
│   │   │                       self-assessment tools, decision aids, progress sharing
│   │   ├── IdentityAndAvatar — personal evolving avatar: self-representation, identity
│   │   │                       exploration, gender expression, presentation preferences,
│   │   │                       aptitudes, values, concerns and vulnerabilities. Versioned
│   │   │                       history — earlier selves are meaningful, not obsolete.
│   │   │                       Selective sharing controls (clinician, peer group, private).
│   │   │                       Connects to: Journal (reflective identity work), Community
│   │   │                       (presentation in group spaces), TherapyPathways (guided
│   │   │                       identity exercises), SelfManagement (milestone integration),
│   │   │                       OutcomeFramework (progress as lived experience, not just
│   │   │                       clinical measures). Not gamification — externalised identity
│   │   │                       work with therapeutic value: articulation, development,
│   │   │                       confidence-building, sense of agency and control
│   │   ├── Journal           — personal journal, reflective practice, clinician-shared entries
│   │   ├── SessionPlanning   — consultation session sequence planning, appointment preparation,
│   │   │                       agenda setting, post-session actions
│   │   └── DocumentAccess    — secure document portal, e-signing for consent and contracts,
│   │                           document sharing with clinicians and third parties
│   ├── Education             — patient-facing knowledge and learning platform
│   │   ├── KnowledgeBase     — FAQs, reference materials, answerbase, curated information,
│   │   │                       decision aids, terminology guides
│   │   ├── LearningContent   — structured courses, self-directed learning modules,
│   │   │                       instructional video and audio, educational pathways
│   │   ├── TherapyPathways   — structured therapy journeys, guided self-development,
│   │   │                       coaching exercises, psychoeducation sequences
│   │   └── ContentDelivery   — content management, personalised recommendations,
│   │                           progress-aware delivery, accessibility
│   ├── Community             — patient-to-patient and group interaction
│   │   ├── GroupSpaces       — group spaces with privacy controls, shared resources,
│   │   │                       moderation, community guidelines enforcement
│   │   ├── GroupSessions     — group video sessions, facilitated workshops,
│   │   │                       peer support circles, scheduled group events
│   │   └── PeerMessaging     — patient-to-patient messaging, group chat,
│   │                           peer support channels (distinct from clinical messaging)
│   ├── Booking               — appointment scheduling, availability, reminders
│   ├── EHR                   — clinical record (openEHR CDR), demographics, document storage
│   ├── Forms                 — questionnaires, clinical forms, validation rules
│   ├── Messaging             — clinical comms, secure clinician-patient messaging, notifications
│   ├── VideoConsulting        — telehealth integration (1:1 clinical sessions)
│   ├── LabInterface          — lab orders, results, pathology integration
│   ├── PrescribingSystem     — electronic prescribing system integration (disambiguated from
│   │                           ServiceDelivery::ClinicalPathways::Prescribing)
│   ├── Payments              — payment processing, invoicing, receipts
│   ├── Documents             — document generation, templates, signing
│   ├── Identity              — user accounts, authentication, authorisation
│   ├── Orchestration         — Temporal infrastructure, workflow engine
│   └── Integration           — API gateway, third-party connectors, Dante networking of services
│
├── Operations
│   ├── Finance               — billing, accounts, Xero integration
│   ├── People                — HR, contracts, indemnity
│   ├── Marketing             — acquisition funnel, content, community (Mighty Networks, Kit)
│   ├── CRM                   — prospect/patient relationship management
│   └── Reporting             — BI, operational dashboards, regulatory reporting
│
└── Foundation
    ├── MetadataLibrary       — @ClinicalReviewGate, @ConsentRequired, @AuditPoint,
    │                           @LogicRule, @DecisionTable, @SafetyConstraint,
    │                           @OpenEhrArchetype, @OpenEhrElement, @OpenEhrTemplate
    ├── CommonTypes           — shared data types, enumerations, units
    ├── StatePatterns         — reusable lifecycle state machine patterns
    └── GenerationPipeline    — generator configs, templates, conventions

(TemporalMetadata — @TemporalWorkflow, @TemporalActivity, @TemporalSignal,
 @StateTransitionTrigger — lives in libraries/temporal-metadata/ as a
 separate top-level package, imported by orchestration-layer action flows)
