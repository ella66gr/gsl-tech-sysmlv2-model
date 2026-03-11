# GenderSense Package Hierarchy (Generated)

**Generated:** 2026-03-10 23:55  
**Source:** `model/*.sysml`, `libraries/**/*.sysml`  
**Total packages:** 71 (excluding root)  
**Generator:** `scripts/gen_package_hierarchy.py --save=markdown`

This document is generated from the SysML model. Do not edit manually.

---

```
GenderSense Package Hierarchy
Generated 2026-03-10 23:55 from model/*.sysml (71 packages)

GenderSense
├── Enterprise                    Defines the organisational, regulatory, strategic, and risk context.
│   ├── Organisation              Roles, teams, governance structure, board, leadership, — [3 parts]
│   ├── Regulation                CQC fundamental standards, ICO/GDPR obligations, — [4 use cases, 8 requirements]
│   ├── Strategy                  Partnerships, business model, ethos and values, — [2 parts]
│   └── Risk                      Clinical risk management, business continuity, safeguarding — [3 use cases]
│
├── Foundation                    Cross-cutting infrastructure that everything else imports.
│   ├── MetadataLibrary           Metadata definitions for generator configuration and — [9 metadata]
│   ├── CommonTypes               Shared data types, enumerations, units of measure, and — [2 parts, 25 enums]
│   ├── StatePatterns             Reusable lifecycle state machine patterns. — [1 states]
│   └── GenerationPipeline        Generator configurations, template definitions, generation
│
├── Knowledge                     Explicit treatment of knowledge, decision logic, and adaptive
│   ├── ClinicalDecisionSupport   Decision rules, eligibility criteria, monitoring protocols, — [3 parts, 3 use cases]
│   ├── ConstraintLibrary         Composable clinical constraints, safety rules, drug — [8 constraints]
│   ├── LogicEngine               Inference rules, Prolog-style reasoning, deterministic — [21 parts, 4 use cases]
│   ├── DecisionModels            DMN-style decision tables modelled as SysML part defs — [5 parts, 2 use cases, 1 enums]
│   ├── OutcomeFramework          Outcome definitions, measurement points, structured outcome — [5 parts, 4 use cases]
│   ├── LearningCycles            Pathway refinement process, evidence review, change control — [2 use cases]
│   └── Analytics                 Data contracts for BI and predictive analytics, event stream — [1 parts]
│
├── Operations                    Back office and growth functions.
│   ├── Finance                   Billing, accounts, Xero integration, financial reporting, — [2 use cases]
│   ├── People                    HR, contracts, indemnity arrangements, personnel
│   ├── Marketing                 Acquisition funnel, content production, community — [1 use cases]
│   ├── CRM                       Prospect and patient relationship management,
│   └── Reporting                 Business intelligence, operational dashboards, regulatory — [2 use cases]
│
├── Platform                      The technology systems that support service delivery.
│   ├── PatientPortal             Patient-facing web platform, self-management hub. — [2 use cases]
│   │   ├── SelfManagement        Personal dashboard, progress tracking, alerts and — [3 use cases]
│   │   ├── IdentityAndAvatar     Personal evolving avatar: self-representation, identity — [3 use cases]
│   │   ├── Journal               Personal journal for reflective practice. — [2 use cases]
│   │   ├── SessionPlanning       Consultation session sequence planning, appointment — [2 use cases]
│   │   └── DocumentAccess        Secure document portal for patient access to their — [3 use cases]
│   ├── Education                 Patient-facing knowledge and learning platform.
│   │   ├── KnowledgeBase         FAQs, reference materials, answerbase, curated — [2 use cases]
│   │   ├── LearningContent       Structured courses, self-directed learning modules, — [1 use cases]
│   │   ├── TherapyPathways       Structured therapy journeys, guided self-development, — [2 use cases]
│   │   └── ContentDelivery       Content management, personalised recommendations, — [2 use cases]
│   ├── Community                 Patient-to-patient and group interaction platform.
│   │   ├── GroupSpaces           Group spaces with privacy controls, shared resources, — [2 use cases]
│   │   ├── GroupSessions         Group video sessions, facilitated workshops, peer — [2 use cases]
│   │   └── PeerMessaging         Patient-to-patient messaging, group chat, peer — [1 use cases]
│   ├── Booking                   Appointment scheduling, availability management, reminders, — [2 use cases]
│   ├── EHR                       Clinical record layer: openEHR CDR (EHRbase). — [5 parts, 4 use cases]
│   ├── Forms                     Questionnaires, clinical assessment forms, validation rules, — [2 use cases]
│   ├── Messaging                 Patient communications, secure messaging, notifications, — [2 use cases]
│   ├── VideoConsulting           Telehealth platform integration, session management. — [1 use cases]
│   ├── LabInterface              Laboratory orders, results receipt, pathology integration, — [2 use cases]
│   ├── PrescribingSystem         Electronic prescribing system integration, medication — [2 use cases]
│   ├── Payments                  Payment processing, invoicing, receipts, subscription — [2 use cases]
│   ├── Documents                 Document generation, templates, electronic signing, — [2 use cases]
│   ├── Identity                  User accounts, authentication, authorisation, role-based — [1 parts, 2 use cases]
│   ├── Orchestration             Temporal infrastructure, workflow engine, worker deployment,
│   └── Integration               API gateway, third-party connectors, webhook management,
│
├── ServiceDelivery               The clinical and operational heart of GenderSense.
│   ├── PatientJourney            Top-level lifecycle from acquisition through to discharge — [5 use cases]
│   ├── ClinicalPathways          Detailed clinical pathway models.
│   │   ├── HormoneTherapy        Hormone therapy initiation, titration, monitoring, — [3 use cases, 2 actions]
│   │   ├── Assessment            New patient assessment, self-assessment instruments, — [3 use cases]
│   │   ├── Referrals             Inbound referral processing, outbound specialist — [3 use cases]
│   │   └── Prescribing           Prescribing protocols, dispensing, medication monitoring, — [3 use cases]
│   ├── Consent                   Consent models: informed consent for treatment, consent — [3 use cases]
│   ├── CoachingSupport           Transition coaching services, group work, peer support — [2 use cases]
│   ├── ClinicalGovernance        Policies, protocols, procedures, clinical audit, outcome — [3 use cases]
│   └── ClinicalEntities          Core domain entities: the nouns of the clinical domain. — [6 parts, 4 states]
│
└── BusinessModel                 The business model package captures the strategic logic of the
    ├── ServiceConcept            Defines the value proposition, customer segments, service — [5 parts]
    ├── ActivityModel             Cross-cutting activity taxonomy and costing foundation. — [5 parts, 2 enums]
    ├── ResourcePlanning          Defines the resources required to operate the service — [5 parts]
    ├── FinancialPlanning         Defines the financial structure of the business: how — [5 parts, 1 enums]
    ├── ScenarioModelling         Provides the mechanics for driving the business model — [11 parts, 2 enums]
    └── StrategyAndEvolution      Strategic direction, business model variants, and — [3 parts]

Libraries (separate from main model):
  TemporalMetadata (libraries/temporal-metadata/temporal-metadata.sysml) — Metadata definitions for Temporal workflow generation. — [4 metadata]
```

---

*Generated 2026-03-10 23:55 by `gen_package_hierarchy.py`.*
