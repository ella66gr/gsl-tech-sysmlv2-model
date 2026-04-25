// =========================================================================
// MINDS DEMONSTRATOR — Blended Remote Mental Health and Wellbeing Service
// =========================================================================
//
// Cross-domain validation: validates that BMM General part defs generalise
// from immediate retail (Cafe), batch processing (Suds), appointment-based
// personal service (Paws), and sector-regulated community ear care (Ears)
// to a structurally novel service business — blended professional-body-
// regulated remote-only human-led services plus subscription digital
// wellbeing content.
//
// Key structural differences from prior demonstrators:
//   - Service shape: five service offerings under one brand (counselling,
//     psychotherapy, coaching, digital subscription, signposting)
//   - Delivery: fully remote — no premises, no domiciliary, no in-person
//   - Regulation: professional-body-regulated (BACP / UKCP / ICF), not
//     statutory or sector-regulated; first exercise of B76 tier
//   - Service subject: client and content-subscriber are typically the
//     same individual, but corporate-coaching introduces employer-as-
//     ordering-party (acting-party-on-behalf-of pattern, OW-S254-5)
//   - Financial model: per-session revenue alongside subscription
//     revenue — first exercise of B73 digital content as offering
//   - Resource pattern: three founder-practitioners are simultaneously
//     service-delivery resource, governance resource, and ownership —
//     first exercise of B77 small-practice ownership-level compression
//   - Pathway: ten-stage human-service pathway plus three-stage digital-
//     only pathway; cross-modality engagement transitions (B75)
//   - Multi-axis status: ClientEngagement (five-axis with novel modality
//     axis) and DigitalSubscription (four-axis with first derived axis)
//
// Stratum-and-side locus:
//   MindsBusinessModel — Configured-Model stratum, business side (DBM)
//   MindsCanonicalRuntime — Configured-Model stratum, business side
//
// Source: S272 Minds BMM Configuration paper, with reconciliations
// recorded in §15 critique observations of that paper:
//   (1) Names converted to actual BMM General part defs (e.g.
//       ValueProposition not ServiceProposition);
//   (2) ValueSpaceShape values reduced to enum admitted values
//       (unorderedEnum / orderedEnum / structuredValue);
//   (3) AxisAuthority compounds expressed as multi-valued tuples;
//   (4) Axis names and value-space values in camelCase per Paws.
//
// Session 275 (25 April 2026): W-105 part (c) — first SysML projection
// of Minds. Stage 3 of the Minds programme. Authored after the S273
// register additions (A14, B73-B76, B79; B15 enum extended; B37 refined).
//
// Annotation coverage: deferred to a second pass after parse confirmed.
// Initial first-pass attempted @UserFacing on every part def and on
// part usages; both authored with @BfoType on the canonical runtime
// type part defs. All annotations were removed at S275 after Syside
// parse-failures: usage-level annotations failed with "Metadata
// feature must be typed by exactly one metaclass / No Feature named
// 'friendlyName' found"; canonical-runtime-type-level annotations
// failed with the same metaclass-resolution error apparently due to
// scope ambiguity between this file's imports and the inherited
// CanonicalRuntimeType metaclass binding. Doc-blocks throughout
// carry the descriptive content. Annotations to be reinstated in a
// dedicated annotation pass once the structural projection parses
// cleanly.
//
// =========================================================================

package MindsBusinessModel {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::*;
    private import BusinessModel::ActivityModel::*;
    private import BusinessModel::ResourcePlanning::*;
    private import BusinessModel::FinancialPlanning::*;
    private import BusinessModel::GovernanceMapping::*;
    private import BusinessModel::StakeholderModel::*;
    private import Foundation::CommonTypes::*;

    doc /* Minds blended remote mental health and wellbeing service
         * business model. Instantiates BMM General part defs across
         * the seven concerns (C1 ServiceConcept, C2 ActivityModel,
         * C3 ResourcePlanning, C4 FinancialPlanning, C5 GovernanceMapping,
         * C6 ActivityAwareness cross-cutting, C7 StakeholderModel).
         *
         * Cross-domain validation: same BMM vocabulary as Cafe, Suds,
         * Paws, Ears — different values, structurally novel shape.
         * First exercise of B76 (professional-body-regulated tenancy
         * tier), B73 (digital content as service offering), B75 (cross-
         * modality engagement trajectory), B77 (small-practice
         * deployment pattern), B79 (supervision-as-first-class).
         *
         * Source: S272 Minds BMM Configuration paper. */

    // =====================================================================
    // C1 SERVICE CONCEPT — What Minds offers, to whom, and why
    // =====================================================================

    // -- Value Proposition -------------------------------------

    part mindsBlendedProposition : ValueProposition {
        doc /* The blended-offer-within-one-identity proposition.
             * A client meets Minds once and finds counselling,
             * psychotherapy, coaching, digital wellbeing content,
             * and signposting all under a single named, accessible
             * service. Differentiates from marketplaces (which
             * fragment) and single-modality providers (which limit
             * scope). Source: intake S271 §4.1.
             *
             * Business meta model concept. */
        attribute :>> propositionName = "Blended human and digital wellbeing under one trusted name";
        attribute :>> description = "Five services under one identity: counselling, psychotherapy, coaching, digital wellbeing content, and signposting. Practitioner-owned, named accessible founders, fully remote, ethically designed.";
        ref :>> targetSegment = ukAdultNonAcuteSegment;
        attribute :>> differentiator = "Blended-offer + practitioner-owned + named-accessible-founders + ethical-product-design commitments";
        attribute :>> evidenceBasis = "Founder credentials (BACP, UKCP, ICF); remote-practice competence frameworks; transparent pricing; published ethical commitments";
    }

    // -- Customer Segments -------------------------------------

    part ukAdultNonAcuteSegment : CustomerSegment {
        doc /* The principal customer segment. Self-pay or corporate-
             * referred individuals seeking talking therapy, coaching,
             * or digital wellbeing support outside the NHS pathway,
             * with presentations within Minds' inclusion criteria
             * and outside its exclusion criteria. Source: intake §4.6.
             *
             * Business meta model concept. */
        attribute :>> segmentName = "UK adult non-acute mental health and wellbeing";
        attribute :>> description = "Adults 18+ resident in the UK with non-acute presentations seeking talking therapy, coaching, or digital wellbeing support";
        attribute :>> needs = "Accessible non-NHS provision; flexible remote delivery; clinician-led where appropriate; transparent pricing; ethical product design";
        attribute :>> acquisitionChannel = "Self-referral via web search; word of mouth; employer wellbeing schemes; GP signposting; community references";
        attribute :>> willingnessToPayIndicator = "medium";
    }

    part corporateCoachingSegment : CustomerSegment {
        doc /* Distinct sponsor segment for the corporate coaching
             * stream. The employer is the ordering and paying party;
             * the employee is the service subject and beneficiary.
             * Pricing tier: £150/session (corporate rate). Exercises
             * the acting-party-on-behalf-of pattern from OW-S254-5.
             *
             * Business meta model concept. */
        attribute :>> segmentName = "Corporate coaching sponsor";
        attribute :>> description = "Employers funding coaching for named employees as a wellbeing benefit";
        attribute :>> needs = "Accountable provider; outcome reporting at appropriate scope; invoice-based billing";
        attribute :>> acquisitionChannel = "Direct enquiry; HR / wellbeing-lead networks";
        attribute :>> willingnessToPayIndicator = "medium-high";
    }

    // -- Channels -----------------------------------------------

    part webChannel : Channel {
        doc /* The Minds web channel — public-facing site with
             * service descriptions, founder bios, pricing, intake
             * form, and signposting content. Primary acquisition
             * and intake channel for human-led services and digital
             * subscription. Business meta model concept. */
        attribute :>> channelName = "Web channel";
        attribute :>> description = "Public website with service catalogue, founder accessibility, intake form, and signposting content";
        attribute :>> channelType = "acquisition and delivery";
        attribute :>> estimatedReach = "national — UK-wide";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "Conversion driven by transparent founder bios, ethical-design commitments, accessible pricing";
    }

    part mobileAppChannel : Channel {
        doc /* Mobile app delivering the digital wellbeing content
             * library. Companion to the web channel for human-led
             * service clients. Business meta model concept. */
        attribute :>> channelName = "Mobile app channel";
        attribute :>> description = "Native mobile app for digital content delivery and engagement-event capture";
        attribute :>> channelType = "delivery";
        attribute :>> estimatedReach = "national — UK-wide";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "Free-to-paid conversion is a tracked subscription metric";
    }

    part videoVoiceChannel : Channel {
        doc /* Enterprise video / voice platform with UK-GDPR DPA,
             * used for all human-led session delivery. HMB-mediated;
             * not a customer-facing channel in the marketing sense.
             * Business meta model concept. */
        attribute :>> channelName = "Video and voice delivery";
        attribute :>> description = "Enterprise-grade video and voice platform compliant with UK GDPR for session delivery";
        attribute :>> channelType = "delivery";
        attribute :>> estimatedReach = "national — UK-wide";
        attribute :>> estimatedCostLevel = "medium";
        attribute :>> conversionNotes = "Not a marketing channel; reliability and confidentiality are the load-bearing properties";
    }

    // -- Service Offerings -------------------------------------

    part counsellingService : ServiceOffering {
        doc /* Counselling service offering. BACP-framework. Delivered
             * remotely (video primary; voice on client preference) by
             * Cara Aldana. Episode shape: 6-20 weekly sessions typical;
             * block-of-6 and block-of-12 prepay admitted. £65/session.
             * Source: intake S271 §4.2 and §4.7.
             *
             * Business meta model concept. */
        attribute :>> offeringName = "Counselling";
        attribute :>> description = "BACP-framework counselling for non-acute presentations — anxiety, low mood, grief, life transitions, relational difficulties";
        attribute :>> scope = "Intake → suitability review → contracting → weekly sessions (typically 6-20) → review at sessions 6, 12, 20 → planned ending or transition";
        attribute :>> pricingBasis = "per-session £65; block-of-6 / block-of-12 discounted";
        attribute :>> estimatedDurationWeeks = 12;
        attribute :>> clinicalPathwayRef = "minds-counselling-pathway";
    }

    part psychotherapyService : ServiceOffering {
        doc /* Psychotherapy service offering. UKCP-framework. Delivered
             * remotely (video primary; voice as exception only) by
             * Graham Okafor-Reeves. Episode shape: long-term, often
             * 6-24 months weekly. No block-purchase — psychotherapeutic
             * frame discourages prepaid blocks. £95/session. Source:
             * intake §4.2.
             *
             * Business meta model concept. */
        attribute :>> offeringName = "Psychotherapy";
        attribute :>> description = "UKCP-framework psychotherapy for deeper work — identity, attachment, persistent relational difficulty, longer-term distress";
        attribute :>> scope = "Intake → suitability review → contracting → weekly sessions (typically months to years) → periodic review → planned ending";
        attribute :>> pricingBasis = "per-session £95; no block-purchase";
        attribute :>> estimatedDurationWeeks = 52;
        attribute :>> clinicalPathwayRef = "minds-psychotherapy-pathway";
    }

    part coachingService : ServiceOffering {
        doc /* Coaching service offering. ICF-framework. Delivered
             * remotely (video, voice, text-chat follow-ups) by
             * Shireen Pathirana. Episode shape: 6-12 weekly sessions
             * typical. Self-pay £95/session; corporate £150/session.
             * Block-of-6 and block-of-12 admitted for self-pay.
             * Source: intake §4.2 and §10.1.
             *
             * Business meta model concept. */
        attribute :>> offeringName = "Coaching";
        attribute :>> description = "ICF-framework coaching for goal-directed change — life transitions, leadership, performance, post-therapy resilience";
        attribute :>> scope = "Intake → suitability review → contracting → weekly sessions (6-12 typical) → review → planned ending";
        attribute :>> pricingBasis = "per-session £95 self-pay / £150 corporate; block-of-6 / block-of-12 discounted self-pay";
        attribute :>> estimatedDurationWeeks = 8;
        attribute :>> clinicalPathwayRef = "minds-coaching-pathway";
    }

    part digitalWellbeingContent : ServiceOffering {
        doc /* Digital wellbeing content offering — first exercise of
             * B73 (digital content as canonical service offering).
             * Free tier: limited library; paid subscription £9.99/mo
             * or £89/yr for full library and guided programmes.
             * Subscription economics (MRR, churn, LTV, free-to-paid
             * conversion) are first-class concerns. Substrate
             * candidates: ContentItem, GuidedProgramme, Entitlement,
             * DigitalSubscription. Curated by Shireen.
             *
             * BMM Tailored extension expressed inline — pending
             * formal Tailored hook-in mechanics treatment.
             *
             * Business meta model concept. */
        attribute :>> offeringName = "Digital wellbeing content";
        attribute :>> description = "Self-serve digital library and guided programmes — sleep, anxiety, low mood, life transitions. Free tier and paid subscription.";
        attribute :>> scope = "Sign up → choose tier → access library / programmes → engage → cancel or continue";
        attribute :>> pricingBasis = "free tier; £9.99/mo or £89/yr paid subscription";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "minds-digital-only-pathway";
    }

    part signpostingAndOnwardReferral : ServiceOffering {
        doc /* Signposting offering — decision-and-content service.
             * Triggered when enquiry is out-of-scope for Minds'
             * service offerings (active suicidality, acute presentation,
             * specialist need). Output: structured signposting content
             * to NHS 111, Samaritans, GP, IAPT, specialist providers
             * per intake §11.3. No per-session pricing; no booking;
             * delivered free as part of Minds' relational commitment
             * to the enquirer. First exercise of B74 (scope-of-service
             * decision class) at the offering level.
             *
             * Business meta model concept. */
        attribute :>> offeringName = "Signposting and onward referral";
        attribute :>> description = "Structured signposting to appropriate external destinations for out-of-scope or specialist needs";
        attribute :>> scope = "Enquiry received → scope-of-service decision → signposting content delivered → optional warm handover";
        attribute :>> pricingBasis = "no charge — relational commitment";
        attribute :>> estimatedDurationWeeks = 0;
        attribute :>> clinicalPathwayRef = "minds-signposting-pathway";
    }

    // -- Differentiation Claims --------------------------------

    part blendedOfferClaim : DifferentiationClaim {
        doc /* Differentiation claim 1 of 4. Source: intake §4.8.
             * Business meta model concept. */
        attribute :>> claimName = "Blended offer within one identity";
        attribute :>> statement = "Counselling, psychotherapy, coaching, digital content, and signposting under one trusted brand — find what you need without piecing it together yourself";
        attribute :>> basis = "Three founder-practitioners covering BACP / UKCP / ICF frameworks; integrated digital library; cross-modality transitions admitted";
        attribute :>> testability = "Number of clients accessing more than one service line; cross-modality transition rate; brand awareness surveys";
    }

    part practitionerOwnedClaim : DifferentiationClaim {
        doc /* Differentiation claim 2 of 4. Source: intake §4.8.
             * Business meta model concept. */
        attribute :>> claimName = "Practitioner-owned, not a marketplace";
        attribute :>> statement = "Three named founder-practitioners own, run, and deliver Minds — you are not buying access to a contractor pool";
        attribute :>> basis = "Three-founder equal-shareholder structure; founders deliver every service; no contractor or freelancer model";
        attribute :>> testability = "Founder-delivery rate (target 100% at v1); ownership disclosure on website; companies-house verification";
    }

    part namedAccessibleFoundersClaim : DifferentiationClaim {
        doc /* Differentiation claim 3 of 4. Source: intake §4.8.
             * Business meta model concept. */
        attribute :>> claimName = "Named, accessible founders";
        attribute :>> statement = "Cara, Graham, and Shireen are named on the website with bios and credentials — you can see who you are working with before you book";
        attribute :>> basis = "Founder bios with credentials; direct contact route at appropriate scope; no anonymised practitioner pool";
        attribute :>> testability = "Founder bios published; complaint route includes named-founder escalation; client survey on perceived accessibility";
    }

    part ethicalProductDesignClaim : DifferentiationClaim {
        doc /* Differentiation claim 4 of 4 — also the surface of
             * the B78 ethical product design candidate (placement
             * pending: A14 ethical-product-design-as-first-class-
             * concern was added to the register at S273 as T2 in
             * the A-section). Source: intake §4.8 and S273
             * register additions.
             *
             * Business meta model concept. */
        attribute :>> claimName = "Ethical product design commitments";
        attribute :>> statement = "Our digital product is designed to help — not to maximise engagement. No retention-optimising hooks; no gamification; transparent crisis signposting always one tap away";
        attribute :>> basis = "A14 ethical product design as first-class concern (master register T2, S273); design commitments published in service terms";
        attribute :>> testability = "Engagement-pattern audit against retention-optimisation patterns; absence of gamification mechanics; crisis-signposting accessibility test on every screen";
    }

    // -- Service Subjects and Participants ---------------------
    //
    // Three-field vocabulary stress-tested at Ears (OW-S264-2):
    // orderingParty, actingParty, beneficiary. At Minds the
    // typical case is single-individual (client orders, acts,
    // receives). Corporate-coaching is the explicit acting-on-
    // behalf-of case (employer orders, client receives).

    part clientSubject : ServiceSubject {
        doc /* The client: service subject. Receives the human-led
             * service or holds the digital subscription. In the
             * typical self-pay case the client is also the customer,
             * payer, and decision-maker. In the corporate-coaching
             * case, the client is the service subject and beneficiary
             * but the employer is the ordering party and payer.
             *
             * Independent needs: clinical safety, confidentiality,
             * informed consent, capacity to engage with the service.
             * Governance obligations attach to the client directly —
             * particularly safety-plan activation, safeguarding
             * disclosure routes, and consent granularity.
             *
             * Business meta model concept. */
        attribute :>> subjectName = "Client";
        attribute :>> entityDescription = "Adult person receiving the human-led service or holding the digital subscription";
        attribute :>> independentNeeds = "Clinical safety, confidentiality, informed consent, capacity to engage. Risk-tier classification updated through engagement. Safety-plan activation on escalation. Confidentiality scope governed by per-engagement consent.";
        attribute :>> conditionNotes = "Established at intake: presentation, exclusion-criteria check, suitability for remote delivery, capacity for the chosen modality";
        attribute :>> statusNotes = "Multi-axis tracked at runtime via ClientEngagement canonical type — see MindsCanonicalRuntime";
    }

    part selfPayClientParticipant : ServiceParticipant {
        doc /* The self-pay client as participant: customer, payer,
             * decision-maker. In this case the same Person bears
             * both ServiceSubject and ServiceParticipant roles —
             * the typical collapsed pattern when there is no
             * acting-on-behalf-of relationship.
             *
             * Business meta model concept. */
        attribute :>> participantName = "Self-pay client";
        attribute :>> participantRole = "customer, payer, decision-maker";
        attribute :>> entityDescription = "Adult person purchasing the service for themselves";
        attribute :>> relationshipToEngagement = "Books, pays, attends, makes decisions about pathway transitions. Retains full consent authority. Governance obligations as ServiceSubject apply.";
        attribute :>> statusNotes = "Three-field vocabulary: orderingParty = self; actingParty = self; beneficiary = self";
    }

    part corporateSponsorParticipant : ServiceParticipant {
        doc /* Corporate sponsor participant: ordering party and
             * payer for coaching commissioned for a named employee.
             * Distinct from the employee, who is the ServiceSubject
             * and beneficiary. Acting-party is typically the
             * employee directly within sessions; the employer's
             * scope is limited to commissioning, billing, and
             * outcome-summary at appropriate confidentiality scope.
             *
             * First exercise of the acting-on-behalf-of pattern at
             * Minds. OW-S254-5 carry-forward.
             *
             * Business meta model concept. */
        attribute :>> participantName = "Corporate sponsor";
        attribute :>> participantRole = "ordering party, payer";
        attribute :>> entityDescription = "Employer organisation commissioning coaching for a named employee";
        attribute :>> relationshipToEngagement = "Commissions and pays via invoice. Receives outcome summary at appropriate confidentiality scope only — does not have access to session content. Cannot vary or end the engagement unilaterally.";
        attribute :>> statusNotes = "Three-field vocabulary: orderingParty = employer; actingParty = employee in sessions; beneficiary = employee";
    }

    // -- Catalogue Entries --------------------------------------

    part counsellingCatalogueEntry : CatalogueEntry {
        attribute :>> entryName = "Counselling — single session";
        attribute :>> itemReference = "counsellingService";
        attribute :>> pricingDescription = "£65 per 50-minute session; block-of-6 £360; block-of-12 £700";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-04-25";
        attribute :>> statusNotes = "Cara — counsellor, BACP-registered";
    }

    part psychotherapyCatalogueEntry : CatalogueEntry {
        attribute :>> entryName = "Psychotherapy — single session";
        attribute :>> itemReference = "psychotherapyService";
        attribute :>> pricingDescription = "£95 per 50-minute session; no block-purchase";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-04-25";
        attribute :>> statusNotes = "Graham — psychotherapist, UKCP-registered";
    }

    part coachingCatalogueEntry : CatalogueEntry {
        attribute :>> entryName = "Coaching — single session";
        attribute :>> itemReference = "coachingService";
        attribute :>> pricingDescription = "£95 self-pay; £150 corporate; block-of-6 £540 / block-of-12 £1,050 self-pay";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "service";
        attribute :>> effectiveDate = "2026-04-25";
        attribute :>> statusNotes = "Shireen — coach, ICF-credentialed";
    }

    part digitalSubscriptionCatalogueEntry : CatalogueEntry {
        attribute :>> entryName = "Digital wellbeing subscription";
        attribute :>> itemReference = "digitalWellbeingContent";
        attribute :>> pricingDescription = "Free tier £0; paid £9.99/mo or £89/yr";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "subscription";
        attribute :>> effectiveDate = "2026-04-25";
        attribute :>> statusNotes = "Curated by Shireen; first exercise of B73";
    }

    part signpostingCatalogueEntry : CatalogueEntry {
        attribute :>> entryName = "Signposting and onward referral";
        attribute :>> itemReference = "signpostingAndOnwardReferral";
        attribute :>> pricingDescription = "No charge — relational commitment";
        attribute :>> availabilityStatus = "active";
        attribute :>> provisionType = "advisory";
        attribute :>> effectiveDate = "2026-04-25";
        attribute :>> statusNotes = "Triggered when enquiry is out of scope for human-led offerings";
    }

    // =====================================================================
    // C2 ACTIVITY MODEL — How Minds delivers value
    // =====================================================================

    // -- Activity Types ----------------------------------------

    part enquiryAndIntake : ActivityType {
        doc /* Service delivery: first-contact handling. Enquiry
             * received via web channel; structured intake form
             * completed by enquirer covering presentation,
             * exclusion-criteria self-check, contact preferences,
             * and capacity-to-engage. First exercise of the scope-
             * of-service decision (B74) — the intake form output
             * routes to suitability review, signposting, or decline.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Enquiry and intake";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Receive enquiry, capture structured intake form, run exclusion-criteria check, route to suitability review or signposting";
        attribute :>> expectedDurationMinutes = 20;
        attribute :>> frequencyNotes = "Per enquiry; volume scales with marketing reach";
    }

    part suitabilityReview : ActivityType {
        doc /* Service delivery: practitioner-led suitability
             * assessment. Cara / Graham / Shireen review the intake
             * content, conduct an initial conversation if needed,
             * and produce a suitability recommendation. Heuristic-
             * dominant decision (intake §6) — exercises the
             * GradedRule end of the constraint hierarchy.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Suitability review";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Practitioner reviews intake, conducts brief suitability call, decides on offering allocation, signposting, or decline";
        attribute :>> expectedDurationMinutes = 30;
        attribute :>> frequencyNotes = "Per accepted enquiry; ~70% of enquiries proceed to this stage";
    }

    part contractingAndConsent : ActivityType {
        doc /* Service delivery: contracting gate. First-session
             * contracting (within-first-session, distinct from
             * pre-session agreement) plus baseline consent capture
             * and — for counselling and psychotherapy — safety plan
             * completion. Required gate before any further session.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Contracting and consent";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "First-session contracting, baseline consent capture, safety-plan completion (counselling/psychotherapy), goal-setting (coaching)";
        attribute :>> expectedDurationMinutes = 50;
        attribute :>> frequencyNotes = "Per accepted client; once at engagement start";
    }

    part sessionDelivery : ActivityType {
        doc /* Service delivery: the principal activity. Remote-
             * delivered session — video primary; voice as configured
             * per offering. 50 minutes typical. Practitioner-mediated
             * via HMB binding class. Session content is governed
             * by professional-body framework (BACP / UKCP / ICF).
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Session delivery";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Remote-delivered 50-minute session under professional-body framework; HMB-mediated; content governed by ethical framework";
        attribute :>> expectedDurationMinutes = 50;
        attribute :>> frequencyNotes = "Typically weekly per active engagement";
    }

    part sessionNotesAuthoring : ActivityType {
        doc /* Service enabling: session-note authoring. Post-session
             * within 24-hour window per professional-body expectation.
             * HMB write-path; governance-evidence record. Business
             * meta model concept. */
        attribute :>> activityTypeName = "Session notes authoring";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Author session note within 24h; record clinical observations, risk indicators, agreed actions, next-session plan";
        attribute :>> expectedDurationMinutes = 15;
        attribute :>> frequencyNotes = "Once per session";
    }

    part reviewGate : ActivityType {
        doc /* Service delivery: structured review gate. Per intake
             * §5.1 stage 8. Review gates at sessions 6, 12, 20.
             * Inputs: progress against goals, client satisfaction,
             * practitioner judgement, optional outcome-measure score.
             * Outputs: continue / change modality / step up to
             * referral / step down / end. Drives lifecycle axis on
             * ClientEngagement.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Review gate";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Structured review at sessions 6, 12, 20; outputs continue / change-modality / step-up / step-down / end";
        attribute :>> expectedDurationMinutes = 50;
        attribute :>> frequencyNotes = "Three review gates per typical engagement";
    }

    part endingWellSession : ActivityType {
        doc /* Service delivery: planned-ending. Distinct from a
             * regular session — final-session purpose is review,
             * consolidation, signposting for post-engagement
             * support, and formal closure. Source: intake §5.1
             * stage 9.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Ending-well session";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Planned final session; review, consolidation, post-engagement signposting, formal closure";
        attribute :>> expectedDurationMinutes = 50;
        attribute :>> frequencyNotes = "Once per planned-ending engagement";
    }

    part supervisionMeeting : ActivityType {
        doc /* Governance: standing supervision activity per
             * practitioner. BACP / UKCP / ICF frameworks each
             * mandate ongoing supervision as a condition of
             * professional-body membership. Frequency varies by
             * framework and caseload. Exercises B79 (supervision-
             * as-first-class) at the activity level.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Supervision meeting";
        attribute :>> activityCategory = ActivityCategory::governance;
        attribute :>> description = "Standing per-practitioner supervision under professional-body framework; reflective practice and case discussion";
        attribute :>> expectedDurationMinutes = 60;
        attribute :>> frequencyNotes = "Monthly per practitioner; per-framework cadence applies";
    }

    part contentEngagementEvent : ActivityType {
        doc /* Service delivery: digital-content side. High-volume
             * low-per-event activity. Each content view, completion,
             * abandonment, or programme-step produces an SRS runtime
             * instance. Engagement-axis on DigitalSubscription is
             * derived from these events by an RSR (reflective
             * reasoner). First exercise of high-volume content-
             * engagement events at Minds. OW-S270-6 territory.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Content engagement event";
        attribute :>> activityCategory = ActivityCategory::serviceDelivery;
        attribute :>> description = "Per-event: view, completion, abandonment, programme step. High-volume, low-per-event content";
        attribute :>> expectedDurationMinutes = 5;
        attribute :>> frequencyNotes = "Variable per subscriber; aggregate volume substantial — first high-volume activity at Minds";
    }

    part incidentAndComplaintHandling : ActivityType {
        doc /* Governance: incident and complaint handling.
             * Incidents (clinical-safety events, technical failures,
             * disclosures triggering safeguarding) and complaints
             * (service complaints handled internally; professional-
             * body complaints handled externally). Producing
             * IncidentRecord and ComplaintRecord governance
             * artefacts.
             *
             * Business meta model concept. */
        attribute :>> activityTypeName = "Incident and complaint handling";
        attribute :>> activityCategory = ActivityCategory::governance;
        attribute :>> description = "Record incidents, route complaints, document investigation and resolution";
        attribute :>> expectedDurationMinutes = 60;
        attribute :>> frequencyNotes = "As required; expected to be infrequent at v1 volumes";
    }

    // -- Activity Granularity ----------------------------------

    part serviceDeliveryGranularityMinds : ActivityGranularity {
        attribute :>> businessArea = "Service delivery (human-led)";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Tracked via ClientEngagement and Session canonical runtime types; per-session events captured";
    }

    part contentEngagementGranularityMinds : ActivityGranularity {
        attribute :>> businessArea = "Service delivery (digital content)";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Per-event tracked at content-engagement-event level; aggregated by RSR for engagement-axis derivation on DigitalSubscription";
    }

    part governanceGranularityMinds : ActivityGranularity {
        attribute :>> businessArea = "Governance";
        attribute :>> currentLevel = GranularityLevel::tracked;
        attribute :>> targetLevel = GranularityLevel::tracked;
        attribute :>> migrationNotes = "Supervision, incident, complaint, audit cycles all tracked — professional-body frameworks require evidence trails";
    }

    part overheadGranularityMinds : ActivityGranularity {
        attribute :>> businessArea = "Overhead";
        attribute :>> currentLevel = GranularityLevel::category;
        attribute :>> targetLevel = GranularityLevel::category;
        attribute :>> migrationNotes = "Booking, billing, content-curation aggregated at category level";
    }
}

// =========================================================================
// MINDS DEMONSTRATOR — Resource and Financial Planning
// =========================================================================

package MindsResourceFinancial {
    private import ScalarValues::*;
    private import BusinessModel::ResourcePlanning::*;
    private import BusinessModel::FinancialPlanning::*;
    private import Foundation::CommonTypes::*;
    private import MindsBusinessModel::*;

    // -- Resource Types — the three founder-practitioners ------
    //
    // First exercise of B77 small-practice ownership-level
    // compression — each founder is simultaneously service-
    // delivery resource, governance resource, and shareholder-
    // owner. A single Person bears multiple Roles across
    // multiple concerns simultaneously; this is the default
    // configuration at Minds, not an edge case.

    part counsellorPractitioner : ResourceType {
        doc /* Cara Aldana: BACP-registered counsellor. Delivers
             * counselling. Internal role: Data Protection Lead.
             * 18-22 client-hours per week; remainder allocated to
             * supervision, notes, CPD, operations. Equal shareholder.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Counsellor practitioner";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "founder-owner";
        attribute :>> costProfile = "Founder draw — variable by trading position";
        attribute :>> capacityUnit = "client-hours per week";
    }

    part psychotherapistPractitioner : ResourceType {
        doc /* Graham Okafor-Reeves: UKCP-registered psychotherapist.
             * Delivers psychotherapy. Internal role: Clinical Safety
             * Lead and Safeguarding Lead. 20-24 client-hours per
             * week. Equal shareholder.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Psychotherapist practitioner";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "founder-owner";
        attribute :>> costProfile = "Founder draw — variable by trading position";
        attribute :>> capacityUnit = "client-hours per week";
    }

    part coachPractitioner : ResourceType {
        doc /* Shireen Pathirana: ICF-credentialed coach. Delivers
             * coaching. Internal role: Operations Lead and content
             * editor for digital wellbeing content. 16-20 client-
             * hours per week. Equal shareholder.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Coach practitioner";
        attribute :>> category = "personnel";
        attribute :>> acquisitionMethod = "founder-owner";
        attribute :>> costProfile = "Founder draw — variable by trading position";
        attribute :>> capacityUnit = "client-hours per week";
    }

    // -- Resource Types — infrastructure and external services -

    part homeOfficeLocation : ResourceType {
        doc /* Home-office as ResourceLocation. Replaces premises in
             * the Minds remote-only configuration. Per-location
             * compliance evidence (sound-isolation declaration,
             * device-security declaration, broadband-reliability
             * declaration). One per practitioner.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Home-office location";
        attribute :>> category = "estate";
        attribute :>> acquisitionMethod = "founder-provided";
        attribute :>> costProfile = "£0 direct (founder home); compliance-evidence overhead per location";
        attribute :>> capacityUnit = "locations";
    }

    part technologyPlatform : ResourceType {
        doc /* The technology platform on which Minds runs. Web app,
             * mobile app, operator app, admin console. Implementation:
             * Ontara realising components per stratum 8 (PRS).
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Technology platform";
        attribute :>> category = "technology";
        attribute :>> acquisitionMethod = "platform-provided";
        attribute :>> costProfile = "Hosting, cloud services, third-party integrations — variable";
        attribute :>> capacityUnit = "platform-instances";
    }

    part videoVoicePlatform : ResourceType {
        doc /* Enterprise video and voice platform with appropriate
             * DPA for special-category-data processing under DPA
             * 2018 Art 9(2)(h). Business meta model concept. */
        attribute :>> resourceTypeName = "Video and voice platform";
        attribute :>> category = "technology";
        attribute :>> acquisitionMethod = "subscribed";
        attribute :>> costProfile = "~£40-£80 per month per practitioner";
        attribute :>> capacityUnit = "concurrent-sessions";
    }

    part secureMessagingPlatform : ResourceType {
        attribute :>> resourceTypeName = "Secure messaging platform";
        attribute :>> category = "technology";
        attribute :>> acquisitionMethod = "subscribed";
        attribute :>> costProfile = "~£30 per month total";
        attribute :>> capacityUnit = "instances";
    }

    part digitalContentLibrary : ResourceType {
        doc /* The digital wellbeing content library. ContentItems
             * (B73-candidate canonical type), GuidedProgrammes,
             * Entitlement rules. Curated by Shireen. Authoritative
             * representation lives in the Configured-Model stratum
             * with content artefacts at PRS.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "Digital content library";
        attribute :>> category = "knowledge";
        attribute :>> acquisitionMethod = "internally-curated";
        attribute :>> costProfile = "Curator time (Shireen); content production costs variable";
        attribute :>> capacityUnit = "content-items";
    }

    part externalSupervisionService : ResourceType {
        doc /* External supervision service. Each founder maintains
             * a supervisor relationship under their respective
             * professional-body framework. Exercises B79 (supervision-
             * as-first-class) at the resource level.
             *
             * Business meta model concept. */
        attribute :>> resourceTypeName = "External supervision service";
        attribute :>> category = "professional-service";
        attribute :>> acquisitionMethod = "contracted-external";
        attribute :>> costProfile = "~£80-£120 per supervision session per practitioner";
        attribute :>> capacityUnit = "supervision-sessions";
    }

    part externalDpoService : ResourceType {
        doc /* DPO-as-a-service. Holds the statutory DPO role under
             * UK GDPR Art 37. Cara holds the internal Data Protection
             * Lead role as contact point. Business meta model
             * concept. */
        attribute :>> resourceTypeName = "External DPO service";
        attribute :>> category = "professional-service";
        attribute :>> acquisitionMethod = "contracted-external";
        attribute :>> costProfile = "Annual retainer + ad-hoc consultation fees";
        attribute :>> capacityUnit = "retainer-instances";
    }

    part externalSafeguardingAdvisor : ResourceType {
        attribute :>> resourceTypeName = "External safeguarding advisor";
        attribute :>> category = "professional-service";
        attribute :>> acquisitionMethod = "contracted-external";
        attribute :>> costProfile = "Quarterly review retainer + ad-hoc consultation fees";
        attribute :>> capacityUnit = "retainer-instances";
    }

    // -- Capabilities ------------------------------------------

    part deliverHumanLedSession : Capability {
        attribute :>> capabilityName = "Deliver a human-led session";
        attribute :>> description = "Receive a booked client at session start, deliver a 50-minute remote session under the appropriate professional-body framework, author session note within 24 hours";
        attribute :>> requiredResources = "1 practitioner + home-office location + video-voice platform + secure messaging platform + technology platform";
        attribute :>> enabledOfferingsDescription = "Counselling, Psychotherapy, Coaching";
    }

    part deliverDigitalContentService : Capability {
        attribute :>> capabilityName = "Deliver a digital wellbeing content service";
        attribute :>> description = "Provide curated digital library and guided programmes to subscribers via mobile app; capture engagement events; manage subscription lifecycle";
        attribute :>> requiredResources = "Technology platform + mobile app + digital content library + content curator (Shireen) capacity";
        attribute :>> enabledOfferingsDescription = "Digital Wellbeing Content";
    }

    // -- Capacity Models ---------------------------------------

    part counsellingDayCapacity : CapacityModel {
        attribute :>> resourceConfiguration = "Cara — counsellor + home-office + video-voice platform";
        attribute :>> throughputPerPeriod = "4-5 sessions";
        attribute :>> periodUnit = "per day (working day, 18-22 hours per week)";
        attribute :>> assumptions = "50-minute session + 10-minute turnover; ~70 minutes per session-cycle; allowance for notes, supervision prep, CPD";
        attribute :>> bottleneck = "Practitioner attention — hard cap at safe-practice limit";
    }

    part psychotherapyDayCapacity : CapacityModel {
        attribute :>> resourceConfiguration = "Graham — psychotherapist + home-office + video-voice platform";
        attribute :>> throughputPerPeriod = "5-6 sessions";
        attribute :>> periodUnit = "per day (working day, 20-24 hours per week)";
        attribute :>> assumptions = "Same per-session shape as counselling; psychotherapy may run 50 or 80 minutes per session; mix tracked";
        attribute :>> bottleneck = "Practitioner attention — and clinical safety boundary";
    }

    part coachingDayCapacity : CapacityModel {
        attribute :>> resourceConfiguration = "Shireen — coach + home-office + video-voice platform";
        attribute :>> throughputPerPeriod = "3-4 coaching sessions";
        attribute :>> periodUnit = "per day (working day, 16-20 hours per week)";
        attribute :>> assumptions = "Shireen also carries content-curation and Operations Lead time within working week";
        attribute :>> bottleneck = "Practitioner attention split across operations and content as well as delivery";
    }

    // -- Resource Constraints ----------------------------------

    part scopeOfPracticeConstraint : ResourceConstraint {
        doc /* Scope of practice constraint. Cara delivers
             * counselling under BACP. Graham delivers psychotherapy
             * under UKCP. Shireen delivers coaching under ICF. No
             * cross-coverage at v1 — modality switches require
             * re-contracting with the appropriate practitioner.
             *
             * Business meta model concept. */
        attribute :>> constraintName = "Scope of practice per practitioner";
        attribute :>> constraintType = "professional-body";
        ref :>> affectedResource = counsellorPractitioner;
        attribute :>> limit = "Each practitioner delivers only within their professional-body framework. Cross-modality client transitions require re-contracting with the appropriate practitioner.";
        attribute :>> regulatorySourceDescription = "BACP Ethical Framework; UKCP Code of Ethics; ICF Code of Ethics — scope of practice provisions";
    }

    part remotePracticeCompetenceConstraint : ResourceConstraint {
        doc /* Remote-practice competence constraint. Each professional
             * body has its own remote-practice competence framework
             * (BACP online-and-phone-therapy; UKCP online-therapy
             * guidelines; ICF online-coaching competence). All three
             * founders hold the relevant competence; this is
             * load-bearing for the remote-only service configuration.
             *
             * Business meta model concept. */
        attribute :>> constraintName = "Remote practice competence";
        attribute :>> constraintType = "professional-body";
        ref :>> affectedResource = counsellorPractitioner;
        attribute :>> limit = "All session delivery must be by a practitioner holding current remote-practice competence under their professional-body framework";
        attribute :>> regulatorySourceDescription = "BACP online-and-phone-therapy competence framework; UKCP online-therapy guidelines; ICF online-coaching competence framework";
    }

    // -- Revenue Streams ---------------------------------------

    part counsellingRevenue : RevenueStream {
        attribute :>> streamName = "Counselling session revenue";
        attribute :>> sourceSegment = "Self-pay UK adults";
        attribute :>> triggerEvent = "Counselling session completed";
        ref :>> pricingModel = sessionBasedPricing;
        attribute :>> projectedVolume = "~18 sessions per week (Cara at 4 sessions per day average across 4-5 working days)";
    }

    part psychotherapyRevenue : RevenueStream {
        attribute :>> streamName = "Psychotherapy session revenue";
        attribute :>> sourceSegment = "Self-pay UK adults";
        attribute :>> triggerEvent = "Psychotherapy session completed";
        ref :>> pricingModel = sessionBasedPricing;
        attribute :>> projectedVolume = "~22 sessions per week (Graham at 5 sessions per day average)";
    }

    part coachingRevenue : RevenueStream {
        attribute :>> streamName = "Coaching session revenue";
        attribute :>> sourceSegment = "Self-pay and corporate";
        attribute :>> triggerEvent = "Coaching session completed";
        ref :>> pricingModel = sessionBasedPricing;
        attribute :>> projectedVolume = "~16 sessions per week (Shireen at 3-4 per day; mix of self-pay and corporate)";
    }

    part digitalSubscriptionRevenue : RevenueStream {
        doc /* Digital subscription recurring revenue. Subscription-
             * shape revenue (continuous; recognition over period) is
             * qualitatively different from per-session revenue
             * (transactional; recognition on delivery). Subscription
             * analytics (MRR, churn, LTV, free-to-paid conversion)
             * are first-class concerns at Minds.
             *
             * Business meta model concept (Tailored shape; B73
             * promotion candidate). */
        attribute :>> streamName = "Digital subscription revenue";
        attribute :>> sourceSegment = "UK adults (free-tier conversion and direct sign-up)";
        attribute :>> triggerEvent = "Subscription billing event (monthly or annual)";
        ref :>> pricingModel = subscriptionPricing;
        attribute :>> projectedVolume = "Variable — target conversion rate from free tier; subscription growth over time";
    }

    part digitalFreeTierRevenue : RevenueStream {
        attribute :>> streamName = "Digital free tier (zero revenue)";
        attribute :>> sourceSegment = "UK adults exploring the service";
        attribute :>> triggerEvent = "Free-tier sign-up";
        ref :>> pricingModel = freeTierPricing;
        attribute :>> projectedVolume = "Volume tracked as a funnel input to paid-subscription conversion";
    }

    // -- Cost Drivers ------------------------------------------

    part founderDrawCostDriver : CostDriver {
        attribute :>> driverName = "Founder draw";
        ref :>> linkedResource = counsellorPractitioner;
        attribute :>> costBehaviour = "fixed-target with surplus distribution";
        attribute :>> estimatedUnitCost = 0.0;
        attribute :>> scalingFactor = "founder draw is target-based, not per-unit";
    }

    part platformHostingCostDriver : CostDriver {
        attribute :>> driverName = "Platform hosting and SaaS";
        ref :>> linkedResource = technologyPlatform;
        attribute :>> costBehaviour = "semi-variable";
        attribute :>> estimatedUnitCost = 200.0;
        attribute :>> scalingFactor = "per month — scales modestly with subscriber count and storage";
    }

    part videoVoiceCostDriver : CostDriver {
        attribute :>> driverName = "Video and voice platform";
        ref :>> linkedResource = videoVoicePlatform;
        attribute :>> costBehaviour = "fixed";
        attribute :>> estimatedUnitCost = 180.0;
        attribute :>> scalingFactor = "per month — three practitioner seats";
    }

    part externalServicesCostDriver : CostDriver {
        attribute :>> driverName = "External professional services";
        ref :>> linkedResource = externalSupervisionService;
        attribute :>> costBehaviour = "variable";
        attribute :>> estimatedUnitCost = 350.0;
        attribute :>> scalingFactor = "per month average — supervision, DPO, safeguarding, accountant, solicitor combined";
    }

    // -- Unit Economics ----------------------------------------

    part counsellingEconomics : UnitEconomics {
        ref :>> offering = counsellingService;
        attribute :>> revenuePerUnit = 65.0;
        attribute :>> costPerUnit = 8.0;
        attribute :>> marginPerUnit = 57.0;
        attribute :>> breakdownNotes = "Direct cost is platform allocation (~£3) plus payment processing (~£2) plus per-session supervision/CPD allocation (~£3). Founder draw not in unit cost.";
    }

    part psychotherapyEconomics : UnitEconomics {
        ref :>> offering = psychotherapyService;
        attribute :>> revenuePerUnit = 95.0;
        attribute :>> costPerUnit = 10.0;
        attribute :>> marginPerUnit = 85.0;
        attribute :>> breakdownNotes = "Slightly higher per-session supervision and CPD allocation reflecting UKCP framework intensity";
    }

    part coachingSelfPayEconomics : UnitEconomics {
        ref :>> offering = coachingService;
        attribute :>> revenuePerUnit = 95.0;
        attribute :>> costPerUnit = 8.0;
        attribute :>> marginPerUnit = 87.0;
        attribute :>> breakdownNotes = "Self-pay rate. Corporate rate (£150) carries the same direct cost — corporate margin per session is £142.";
    }

    part digitalSubscriptionEconomics : UnitEconomics {
        doc /* Subscription unit economics — per-subscriber-month.
             * Direct cost is content-delivery allocation plus
             * payment processing. Curator time (Shireen) is amortised
             * across all subscribers and treated as overhead, not
             * unit cost. Subscription LTV depends on retention; ARPU
             * is the headline figure here.
             *
             * Business meta model concept (B73 subscription shape). */
        ref :>> offering = digitalWellbeingContent;
        attribute :>> revenuePerUnit = 9.99;
        attribute :>> costPerUnit = 1.5;
        attribute :>> marginPerUnit = 8.49;
        attribute :>> breakdownNotes = "Per-subscriber-month. Annual subscribers (£89/yr) at 60% take-up effectively pay ~£7.42/mo, narrowing margin. Curator time amortised as overhead.";
    }

    // -- Pricing Models ----------------------------------------

    part sessionBasedPricing : PricingModel {
        doc /* Per-session pricing. Counselling £65, psychotherapy £95,
             * coaching £95 self-pay / £150 corporate. Block-of-6 and
             * block-of-12 prepay admitted for counselling and coaching;
             * not for psychotherapy (psychotherapeutic frame discourages
             * prepaid blocks). Business meta model concept. */
        attribute :>> pricingModelName = "Per-session with optional block-purchase";
        attribute :>> pricingType = PricingType::perEpisode;
        attribute :>> basePrice = 65.0;
        attribute :>> adjustmentLogic = "Counselling £65; psychotherapy £95; coaching £95 self-pay / £150 corporate. Block-of-6 ~10% off; block-of-12 ~15% off — counselling and coaching only.";
        attribute :>> applicableOfferings = "Counselling, Psychotherapy, Coaching";
    }

    part subscriptionPricing : PricingModel {
        doc /* Subscription pricing for digital wellbeing content paid
             * tier. Monthly £9.99 or annual £89 (~25% saving). First
             * subscription PricingModel at Minds — exercises B73
             * subscription pricing shape distinct from per-session
             * pricing. Business meta model concept. */
        attribute :>> pricingModelName = "Subscription monthly or annual";
        attribute :>> pricingType = PricingType::subscription;
        attribute :>> basePrice = 9.99;
        attribute :>> adjustmentLogic = "Monthly £9.99; annual £89 (effective £7.42/mo)";
        attribute :>> applicableOfferings = "Digital Wellbeing Content";
    }

    part freeTierPricing : PricingModel {
        attribute :>> pricingModelName = "Free tier (zero charge)";
        attribute :>> pricingType = PricingType::flatFee;
        attribute :>> basePrice = 0.0;
        attribute :>> adjustmentLogic = "Zero charge; limited content scope; conversion-funnel input to paid subscription";
        attribute :>> applicableOfferings = "Digital Wellbeing Content (free tier)";
    }
}

// =========================================================================
// MINDS DEMONSTRATOR — Governance: Professional-Body Frameworks Plus
// UK GDPR / DPA 2018 / Statutory Frameworks
// =========================================================================
//
// First exercise of B76 (professional-body-regulated tenancy tier).
// Three professional-body frameworks (BACP / UKCP / ICF) carry the
// principal governance content alongside statutory regulation
// (UK GDPR, DPA 2018, ICO guidance, Consumer Rights Act, Companies Act).
//
// =========================================================================

package MindsGovernance {
    private import ScalarValues::*;
    private import BusinessModel::ServiceConcept::ExternalReference;
    private import BusinessModel::GovernanceMapping::*;
    private import Foundation::CommonTypes::*;
    private import MindsBusinessModel::*;

    doc /* Minds governance configuration. Professional-body-regulated
         * tier (B76) plus statutory data protection plus consumer-
         * protection plus safeguarding. The principal governance anchor
         * is the three professional-body frameworks; statutory regulation
         * sits alongside but does not subsume them.
         *
         * Source: intake S271 §7. */

    // -- Governance Requirements -------------------------------

    requirement bacpFrameworkRequirement : GovernanceRequirement {
        doc /* BACP Ethical Framework as a GovernanceRequirement.
             * The framework carries scope of practice, ethical
             * principles, supervision requirement, complaint route,
             * online-practice competence, and CPD requirement —
             * all in one source. First exercise of B76 professional-
             * body-regulated tier at the requirement level.
             *
             * Business meta model concept. */
        attribute :>> requirementId = "MINDS-GOV-BACP-001";
        attribute :>> title = "BACP Ethical Framework — counselling delivery";
        attribute :>> regulatorySource = "British Association for Counselling and Psychotherapy — Ethical Framework for the Counselling Professions (current version)";
        attribute :>> complianceDescription = "All counselling delivered by a current BACP registrant in good standing, working within scope of practice, with current online-and-phone-therapy competence, in standing supervision, with complaint route published.";
        attribute :>> evidenceRequired = "BACP registration certificate (current); online-and-phone-therapy competence evidence; supervision arrangement record; complaint procedure published; CPD log";
    }

    requirement ukcpFrameworkRequirement : GovernanceRequirement {
        attribute :>> requirementId = "MINDS-GOV-UKCP-001";
        attribute :>> title = "UKCP Code of Ethics — psychotherapy delivery";
        attribute :>> regulatorySource = "UK Council for Psychotherapy — Code of Ethics and Professional Practice (current version)";
        attribute :>> complianceDescription = "All psychotherapy delivered by a current UKCP registrant in good standing, working within scope of practice, with current online-therapy competence, in standing supervision, with complaint route published.";
        attribute :>> evidenceRequired = "UKCP registration certificate (current); online-therapy competence evidence; supervision arrangement record; complaint procedure published; CPD log";
    }

    requirement icfFrameworkRequirement : GovernanceRequirement {
        attribute :>> requirementId = "MINDS-GOV-ICF-001";
        attribute :>> title = "ICF Code of Ethics — coaching delivery";
        attribute :>> regulatorySource = "International Coaching Federation — Code of Ethics and Core Competencies (current version)";
        attribute :>> complianceDescription = "All coaching delivered by a current ICF credential holder in good standing, working within scope of practice, with online-coaching competence, supervised under ICF mentoring requirements, with complaint route published.";
        attribute :>> evidenceRequired = "ICF credential certificate (current); online-coaching competence evidence; mentoring arrangement record; complaint procedure published; CPD log";
    }

    requirement ukGdprDpaRequirement : GovernanceRequirement {
        doc /* UK GDPR plus DPA 2018 Art 9(2)(h) for special-category
             * health-data processing on the counselling and
             * psychotherapy side. Business meta model concept. */
        attribute :>> requirementId = "MINDS-GOV-DPA-001";
        attribute :>> title = "UK GDPR and DPA 2018 — special-category health-data processing";
        attribute :>> regulatorySource = "UK GDPR; Data Protection Act 2018 — including Art 9(2)(h) basis for special-category health-data processing";
        attribute :>> complianceDescription = "All processing of personal data complies with UK GDPR principles. Special-category health-data processed under Art 9(2)(h) basis. DPIA in place; DPO appointed (external service). ICO registration current.";
        attribute :>> evidenceRequired = "DPIA records; DPO appointment letter; ICO registration; processing-record (Art 30); breach-notification log";
    }

    requirement consumerProtectionRequirement : GovernanceRequirement {
        attribute :>> requirementId = "MINDS-GOV-CPL-001";
        attribute :>> title = "Consumer Rights Act and Consumer Contracts Regulations";
        attribute :>> regulatorySource = "Consumer Rights Act 2015; Consumer Contracts (Information, Cancellation and Additional Charges) Regulations 2013";
        attribute :>> complianceDescription = "Service terms comply with consumer-rights legislation. 14-day cancellation right where applicable. Pricing transparent. Refund policy clear and lawful.";
        attribute :>> evidenceRequired = "Published terms of service; published refund policy; cancellation-handling log";
    }

    requirement safeguardingRequirement : GovernanceRequirement {
        attribute :>> requirementId = "MINDS-GOV-SG-001";
        attribute :>> title = "Safeguarding adults and children in the wider community";
        attribute :>> regulatorySource = "Care Act 2014; Children Act 1989/2004";
        attribute :>> complianceDescription = "Recognise and act on safeguarding disclosures and concerns. Trained Safeguarding Lead. External advisor for ad-hoc consultation. Local-authority Safeguarding Adults Board engagement.";
        attribute :>> evidenceRequired = "Safeguarding policy; Safeguarding Lead role record; safeguarding training records; SAB engagement evidence; safeguarding incident log";
    }

    // -- Audit Evidence Records --------------------------------

    part bacpRegistrationEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "professional-body registration";
        attribute :>> evidenceDescription = "Current BACP registration certificate for Cara — registered counsellor in good standing";
        attribute :>> retentionPeriod = "Current plus 6 years";
        attribute :>> responsibleRole = "Cara — counsellor (Data Protection Lead)";
        attribute :>> frequency = "Annual renewal — certificate held on file";
    }

    part ukcpRegistrationEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "professional-body registration";
        attribute :>> evidenceDescription = "Current UKCP registration certificate for Graham — registered psychotherapist in good standing";
        attribute :>> retentionPeriod = "Current plus 6 years";
        attribute :>> responsibleRole = "Graham — psychotherapist (Clinical Safety Lead)";
        attribute :>> frequency = "Annual renewal — certificate held on file";
    }

    part icfCredentialEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "professional-body credential";
        attribute :>> evidenceDescription = "Current ICF credential for Shireen — coach in good standing";
        attribute :>> retentionPeriod = "Current plus 6 years";
        attribute :>> responsibleRole = "Shireen — coach (Operations Lead)";
        attribute :>> frequency = "Triennial renewal — credential held on file";
    }

    part supervisionRecordEvidence : AuditEvidenceRecord {
        doc /* Supervision record evidence. Per practitioner; per
             * professional-body framework cadence. First exercise
             * of B79 supervision-as-first-class at the audit-evidence
             * level. Business meta model concept. */
        attribute :>> evidenceType = "supervision record";
        attribute :>> evidenceDescription = "Per-practitioner supervision attendance record under professional-body framework — supervisor identity, dates, anonymised case-discussion topics";
        attribute :>> retentionPeriod = "10 years";
        attribute :>> responsibleRole = "Each practitioner for own record; aggregated by Operations Lead";
        attribute :>> frequency = "Per supervision session — typically monthly per practitioner";
    }

    part dpiaEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "data protection impact assessment";
        attribute :>> evidenceDescription = "Current DPIA covering all special-category data processing — counselling, psychotherapy, digital subscription, intake forms, session notes";
        attribute :>> retentionPeriod = "Lifetime of processing plus 6 years";
        attribute :>> responsibleRole = "External DPO with internal Data Protection Lead (Cara)";
        attribute :>> frequency = "Reviewed annually and on substantive change";
    }

    part incidentLogEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "incident log";
        attribute :>> evidenceDescription = "Dated record of clinical-safety, technical, safeguarding, and data-protection incidents — and responses";
        attribute :>> retentionPeriod = "10 years";
        attribute :>> responsibleRole = "Practitioner on duty for capture; Clinical Safety Lead for review";
        attribute :>> frequency = "Per incident; weekly review";
    }

    part complaintLogEvidence : AuditEvidenceRecord {
        attribute :>> evidenceType = "complaint log";
        attribute :>> evidenceDescription = "Service-complaint log handled internally before any onward professional-body or ombudsman route";
        attribute :>> retentionPeriod = "10 years";
        attribute :>> responsibleRole = "Operations Lead (Shireen) with solicitor advice";
        attribute :>> frequency = "Per complaint; quarterly review";
    }

    // -- External References -----------------------------------

    part bacpFrameworkReference : ExternalReference {
        attribute :>> referenceType = "professional-body framework";
        attribute :>> referenceId = "BACP-EF";
        attribute :>> referenceSource = "British Association for Counselling and Psychotherapy — Ethical Framework";
        attribute :>> referenceNotes = "Authoritative ethical framework for BACP-registered counsellors and psychotherapists; carries scope, ethics, supervision, complaint, online-practice, CPD provisions";
    }

    part ukcpCodeReference : ExternalReference {
        attribute :>> referenceType = "professional-body framework";
        attribute :>> referenceId = "UKCP-COE";
        attribute :>> referenceSource = "UK Council for Psychotherapy — Code of Ethics and Professional Practice";
        attribute :>> referenceNotes = "Authoritative ethical framework for UKCP-registered psychotherapists";
    }

    part icfCodeReference : ExternalReference {
        attribute :>> referenceType = "professional-body framework";
        attribute :>> referenceId = "ICF-COE";
        attribute :>> referenceSource = "International Coaching Federation — Code of Ethics and Core Competencies";
        attribute :>> referenceNotes = "Authoritative framework for ICF-credentialed coaches";
    }

    part ukGdprReference : ExternalReference {
        attribute :>> referenceType = "primary legislation";
        attribute :>> referenceId = "UK-GDPR";
        attribute :>> referenceSource = "Retained EU law — UK GDPR (post-Brexit retained version)";
        attribute :>> referenceNotes = "Principal data-protection regulation. Special-category provisions at Art 9 most relevant for clinical-adjacent processing.";
    }

    part dpa2018Reference : ExternalReference {
        attribute :>> referenceType = "primary legislation";
        attribute :>> referenceId = "DPA-2018";
        attribute :>> referenceSource = "UK Parliament — Data Protection Act 2018";
        attribute :>> referenceNotes = "Schedule 1 conditions for special-category processing — Art 9(2)(h) basis is principal Minds basis for health-data processing";
    }
}

// =========================================================================
// MINDS DEMONSTRATOR — Stakeholder Model
// =========================================================================

package MindsStakeholderModel {
    private import ScalarValues::*;
    private import BusinessModel::StakeholderModel::*;
    private import Foundation::CommonTypes::*;
    private import MindsBusinessModel::*;

    doc /* Minds stakeholder configuration. Inbound referral routes
         * (informal only at v1 — no commissioning), outbound signposting
         * to 11+ destinations, external dependencies (professional bodies,
         * supervisors, DPO, safeguarding advisor, IT, accountant, solicitor,
         * insurance broker), client participation model (active partner),
         * community relationships (Safeguarding Adults Boards), regulatory
         * relationships (BACP / UKCP / ICF / ICO).
         *
         * Source: intake S271 §11. */

    // -- Stakeholder Relationships -----------------------------

    part bacpRelationship : StakeholderRelationship {
        doc /* BACP relationship as professional-body regulator.
             * Distinct from statutory regulation — no statutory
             * power to remove practice; complaint route via
             * complaint procedure with sanctions including
             * removal from register. First exercise of B76
             * tier-distinct relationship.
             *
             * Business meta model concept. */
        attribute :>> stakeholderName = "British Association for Counselling and Psychotherapy (BACP)";
        attribute :>> stakeholderDescription = "Professional body for counselling — registers practitioners; publishes Ethical Framework; handles complaints.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "Maintains the Ethical Framework; provides registration; runs complaint procedure; offers CPD resources.";
        attribute :>> obligationsOutward = "Cara maintains current registration; works within scope of practice and online-practice competence; maintains supervision; meets CPD requirement; cooperates with any complaint investigation.";
        attribute :>> informationExchanged = "Registration renewal data (outward); ethics framework updates and CPD opportunities (inward); complaint information as needed.";
        attribute :>> governanceArrangements = "Annual registration renewal; ongoing supervision and CPD; complaint procedure if invoked.";
        attribute :>> healthIndicators = "Registration current; no open complaints; CPD up to date; supervision attended.";
        attribute :>> reviewCadence = "Annual registration; ongoing per-framework cadence";
    }

    part ukcpRelationship : StakeholderRelationship {
        attribute :>> stakeholderName = "UK Council for Psychotherapy (UKCP)";
        attribute :>> stakeholderDescription = "Professional body for psychotherapy — registers practitioners; publishes Code of Ethics; handles complaints.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "Maintains the Code of Ethics; provides registration; runs complaint procedure; offers CPD resources.";
        attribute :>> obligationsOutward = "Graham maintains current registration; works within scope; maintains supervision; meets CPD requirement; cooperates with complaint investigation.";
        attribute :>> informationExchanged = "Registration renewal data; ethics updates and CPD opportunities; complaint information as needed.";
        attribute :>> governanceArrangements = "Annual registration renewal; ongoing supervision and CPD; complaint procedure if invoked.";
        attribute :>> healthIndicators = "Registration current; no open complaints; CPD up to date; supervision attended.";
        attribute :>> reviewCadence = "Annual registration; ongoing per-framework cadence";
    }

    part icfRelationship : StakeholderRelationship {
        attribute :>> stakeholderName = "International Coaching Federation (ICF)";
        attribute :>> stakeholderDescription = "Credentialing body for coaching — credentials practitioners; publishes Code of Ethics and Core Competencies; handles complaints.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "Maintains the Code of Ethics and Core Competencies; provides credentialing; runs complaint procedure.";
        attribute :>> obligationsOutward = "Shireen maintains current credential; works within scope; maintains mentoring; meets CCEU requirement; cooperates with complaint investigation.";
        attribute :>> informationExchanged = "Credential renewal data; CCEU records; complaint information as needed.";
        attribute :>> governanceArrangements = "Triennial credential renewal; ongoing CCEU; complaint procedure if invoked.";
        attribute :>> healthIndicators = "Credential current; no open complaints; CCEU on track; mentoring engaged.";
        attribute :>> reviewCadence = "Triennial credential renewal; ongoing per-framework cadence";
    }

    part icoRelationship : StakeholderRelationship {
        attribute :>> stakeholderName = "Information Commissioner's Office (ICO)";
        attribute :>> stakeholderDescription = "Regulatory body for UK GDPR and DPA 2018 — data-protection registration, guidance, breach notification and investigation.";
        attribute :>> relationshipNature = RelationshipNature::regulatory;
        attribute :>> obligationsInward = "ICO registration; guidance publications; breach-notification handling; complaint and investigation route for data subjects.";
        attribute :>> obligationsOutward = "Maintain current registration; pay data-protection fee; notify breaches within statutory window; cooperate with investigations.";
        attribute :>> informationExchanged = "Registration renewal; breach notifications if any; investigation correspondence if any.";
        attribute :>> governanceArrangements = "Annual ICO registration; breach-notification protocol.";
        attribute :>> healthIndicators = "Registration current; no open breach notifications; no open investigations.";
        attribute :>> reviewCadence = "Annual";
    }

    part insuranceRelationship : StakeholderRelationship {
        attribute :>> stakeholderName = "Professional indemnity insurance provider";
        attribute :>> stakeholderDescription = "Insurance provider for professional indemnity, public liability, and cyber liability cover.";
        attribute :>> relationshipNature = RelationshipNature::contractual;
        attribute :>> obligationsInward = "Provides PI / PL / cyber cover; advice on incident response.";
        attribute :>> obligationsOutward = "Pay premiums; maintain safe-practice arrangements; notify incidents promptly; comply with policy conditions.";
        attribute :>> informationExchanged = "Policy details; incident notifications; renewal documentation.";
        attribute :>> governanceArrangements = "Annual policy renewal; incident-notification protocol.";
        attribute :>> healthIndicators = "Policy current; claims history; premium trajectory.";
        attribute :>> reviewCadence = "Annual renewal; immediate per-incident.";
    }

    // -- Cooperative Arrangements (none formal at v1) ---------
    //
    // No formal partnerships at v1. Post-v1 candidates: content-
    // partnership for the digital library; EAP-partnership for
    // corporate coaching at scale.

    // -- Referral Pathways — Outbound Signposting --------------

    part nhs111SignpostingPathway : ReferralPathway {
        doc /* NHS 111 signposting destination. Outbound — no
             * inbound referral relationship. Used when the
             * presentation is urgent or out of scope and the client
             * needs immediate clinical advice. Business meta model
             * concept. */
        attribute :>> pathwayName = "NHS 111 signposting";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Minds (signposting only — no formal referral relationship)";
        attribute :>> referralCriteria = "Urgent presentation; out-of-scope acute symptoms; need for clinical advice now";
        attribute :>> referralProtocol = "Signposting content with NHS 111 details; client self-contacts";
        attribute :>> expectedResponseTime = "Not applicable — signposting only";
        attribute :>> feedbackMechanism = "None — outbound signposting, no closed loop";
        attribute :>> volumeTracking = "Tracked as part of signposting service usage metrics";
    }

    part samaritansSignpostingPathway : ReferralPathway {
        attribute :>> pathwayName = "Samaritans signposting";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Minds (signposting only)";
        attribute :>> referralCriteria = "Active distress; emotional support need; out-of-hours need; suicide-related disclosure with capacity";
        attribute :>> referralProtocol = "Signposting content with Samaritans details (24/7 phone and email)";
        attribute :>> expectedResponseTime = "Not applicable";
        attribute :>> feedbackMechanism = "None";
        attribute :>> volumeTracking = "Tracked";
    }

    part gpSignpostingPathway : ReferralPathway {
        attribute :>> pathwayName = "GP signposting";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Minds (signposting only)";
        attribute :>> referralCriteria = "Need for medical assessment; medication review; referral to NHS specialist services";
        attribute :>> referralProtocol = "Signposting content with general GP-route guidance";
        attribute :>> expectedResponseTime = "Not applicable";
        attribute :>> feedbackMechanism = "Optional — with consent, brief signposting note may be sent to GP via client";
        attribute :>> volumeTracking = "Tracked";
    }

    part iaptSignpostingPathway : ReferralPathway {
        attribute :>> pathwayName = "NHS Talking Therapies (IAPT) signposting";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Minds (signposting only)";
        attribute :>> referralCriteria = "NHS-eligible presentation suitable for primary-care talking therapy; cost is a barrier to private";
        attribute :>> referralProtocol = "Signposting content with NHS Talking Therapies self-referral route";
        attribute :>> expectedResponseTime = "Not applicable";
        attribute :>> feedbackMechanism = "None";
        attribute :>> volumeTracking = "Tracked";
    }

    part specialistTraumaSignpostingPathway : ReferralPathway {
        attribute :>> pathwayName = "Specialist trauma provider signposting";
        attribute :>> direction = ReferralDirection::outbound;
        attribute :>> referringEntity = "Minds (signposting only)";
        attribute :>> referralCriteria = "Trauma-focused presentation requiring specialist trauma intervention beyond Minds' scope";
        attribute :>> referralProtocol = "Curated specialist-list signposting content";
        attribute :>> expectedResponseTime = "Not applicable";
        attribute :>> feedbackMechanism = "None";
        attribute :>> volumeTracking = "Tracked";
    }

    // -- External Dependencies ---------------------------------

    part professionalIndemnityInsuranceDependency : ExternalDependency {
        attribute :>> dependencyName = "Professional indemnity insurance";
        attribute :>> provider = "Specialist insurance broker";
        attribute :>> dependencyDescription = "Professional indemnity, public liability, cyber liability cover";
        attribute :>> criticality = DependencyCriticality::essential;
        attribute :>> substitutability = "Multiple providers available; switching mid-policy possible at renewal";
        attribute :>> contingencyPlan = "Annual renewal review; alternative quotes obtained at renewal";
        attribute :>> contractualTerms = "Annual policy with broker-managed renewal";
        attribute :>> supplyRisk = "Low — established market";
    }

    part externalDpoDependency : ExternalDependency {
        attribute :>> dependencyName = "External DPO service";
        attribute :>> provider = "DPO-as-a-service contractor";
        attribute :>> dependencyDescription = "Statutory DPO function under UK GDPR Art 37";
        attribute :>> criticality = DependencyCriticality::essential;
        attribute :>> substitutability = "Multiple providers; switching at end-of-engagement requires handover period";
        attribute :>> contingencyPlan = "Documented DPO handover protocol; contact-route continuity through Cara as internal Data Protection Lead";
        attribute :>> contractualTerms = "Annual retainer";
        attribute :>> supplyRisk = "Low — established market";
    }

    part externalSafeguardingAdvisorDependency : ExternalDependency {
        attribute :>> dependencyName = "External safeguarding advisor";
        attribute :>> provider = "Specialist safeguarding consultant";
        attribute :>> dependencyDescription = "Quarterly review and ad-hoc consultation on safeguarding matters";
        attribute :>> criticality = DependencyCriticality::important;
        attribute :>> substitutability = "Specialist market; switching requires careful handover";
        attribute :>> contingencyPlan = "Documented consultation log; SAB engagement provides additional fallback route";
        attribute :>> contractualTerms = "Quarterly retainer plus ad-hoc fees";
        attribute :>> supplyRisk = "Medium — specialist market";
    }

    part itAgencyDependency : ExternalDependency {
        attribute :>> dependencyName = "IT agency";
        attribute :>> provider = "Managed-services IT provider";
        attribute :>> dependencyDescription = "Endpoint security, network configuration, backup, incident response";
        attribute :>> criticality = DependencyCriticality::important;
        attribute :>> substitutability = "Multiple providers available";
        attribute :>> contingencyPlan = "Standard IT-service contract with handover provisions";
        attribute :>> contractualTerms = "Monthly managed-services agreement";
        attribute :>> supplyRisk = "Low";
    }

    // -- Community Relationships -------------------------------

    part safeguardingAdultsBoardCommunityRelationship : CommunityRelationship {
        attribute :>> communityName = "Local Safeguarding Adults Boards (founders' local authorities)";
        attribute :>> communityDescription = "Statutory multi-agency partnerships at local-authority level coordinating adult safeguarding";
        attribute :>> relationshipToService = "Engagement at the founders' local-authority levels (Stockport, Bristol, Birmingham); awareness of local safeguarding pathways and concerns";
        attribute :>> engagementMode = "Information-receipt from SAB publications; ad-hoc consultation if a safeguarding concern crosses Minds' service";
        attribute :>> mutualBenefit = "SAB receives any incident-disclosure relevant to local safeguarding; Minds receives current local-authority safeguarding pathway awareness";
        attribute :>> communityVoice = "SAB publications; local-authority safeguarding leadership communications";
    }

    // -- Participation Model -----------------------------------

    part mindsParticipationModel : ParticipationModel {
        doc /* Active partner participation model — explicit
             * service-identity commitment. Source: intake §11.5.
             * Business meta model concept. */
        attribute :>> participationName = "Active partner";
        attribute :>> participantRole = "Active partner — not patient, not customer-as-passive-recipient";
        attribute :>> participationDescription = "Client co-constructs the engagement agreement at contracting; participates collaboratively in review-gate decisions; co-decides ending or transition. Practitioner brings clinical judgement; client brings ownership of own goals.";
        attribute :>> informationContribution = "Client brings presentation, history, goals, preferences, ongoing reflections. Information is shared as part of the working relationship under per-engagement consent.";
        attribute :>> decisionInvolvement = "Co-construction at contracting; collaborative review at review-gates; co-decision at ending. Practitioner retains professional judgement on safety and scope.";
        attribute :>> selfServiceScope = "Booking, rebooking, cancellation; access to digital content library; safety-plan review; cancellation of engagement (subject to notice).";
        attribute :>> supportRequired = "Clear contracting; transparent pricing; published ethical commitments; named-accessible-founder route for queries.";
    }
}

// =========================================================================
// MINDS DEMONSTRATOR — Canonical Runtime Types (Multi-Axis Status)
// =========================================================================
//
// Session 275 — Minds tenant declarations of W-094 (multi-axis status
// primitive). Source specification: ontara-minds-bmm-configuration
// (S272) §11 (ClientEngagement) and §12 (DigitalSubscription).
//
// Stratum-and-side locus: Configured-Model stratum, business side
// (Minds DBM). Per the strengthened A4 (tenant configured-model
// content).
//
// Reconciliations from S272 §11 and §12 sketches (recorded in §15
// critique observations of that paper):
//
//   (R1) Axis-value names converted from kebab-case to camelCase
//        per Paws / canonical-runtime.sysml precedent.
//
//   (R2) ValueSpaceShape values reduced to the three admitted by
//        the metamodel enum (unorderedEnum / orderedEnum /
//        structuredValue). S272 sketch values mapped as follows:
//        - "partially-ordered" → orderedEnum (axis is principally
//          forward-progressing; non-forward branches are explicit
//          permitted-transition rows)
//        - "graph" → unorderedEnum (axis-transitions are the
//          canonical truth; permitted-transition rows enumerate
//          the graph)
//        - "state-machine" → unorderedEnum
//        - "totally-ordered-with-derived" → orderedEnum (with
//          derivation discipline noted in doc block)
//        - "independent" → unorderedEnum
//
//   (R3) AxisAuthority compound values (S272 used hyphenated
//        compounds like "practitioner-client-system") expressed as
//        multi-valued tuples of the six existing enum values.
//        Practitioner-side mapped to operatorSide (the practitioner
//        is the operator at Minds).
//
//   (R4) S272 §12 introduced a "system-derived" axis-authority for
//        the engagement axis on DigitalSubscription. The
//        canonical-runtime AxisAuthority enum does not admit this
//        value. Configured here as systemSide with a doc-block note
//        flagging OW-S272-4 (derived axes are a new axis-authority
//        type; multi-axis-primitive paper sharpening candidate).
//
//   (R5) Cross-axis consequence rules (S272 §11.5 and §12.5) are
//        noted in doc blocks but not authored as SysML. Consistent
//        with the Paws first-implementation precedent; cross-axis
//        rules are deferred S253 §6 territory.
//
// Out of scope this session:
//   - Booking, Session, UserAccount, PractitionerRole, IncidentRecord,
//     ContentItem, GuidedProgramme, Entitlement canonical types
//     (deferred to Stage 4 band papers per S272 §10.6).
//   - Cross-axis consequence rules.
//   - OWL axiomatisation.
//
// =========================================================================

package MindsCanonicalRuntime {
    private import ScalarValues::*;
    private import CanonicalRuntime::*;

    doc /* Canonical runtime types for the Minds tenant. At Stage 3
         * (this session) the two principal types are declared:
         * ClientEngagement (five-axis) and DigitalSubscription
         * (four-axis). Other canonical types defer to Stage 4.
         *
         * Stratum-and-side locus: Configured-Model stratum, business
         * side. Tenant configured-model content. The StatusAxis part
         * def and supporting types live in CanonicalRuntime (BMM
         * General, Metamodel stratum).
         *
         * Source: S272 Minds BMM Configuration §11 and §12, with
         * reconciliations recorded in §15 of that paper. */

    // =====================================================================
    // CLIENT ENGAGEMENT — Five-axis canonical runtime type (S272 §11)
    // =====================================================================

    part def ClientEngagement :> CanonicalRuntimeType {
        doc /* Minds ClientEngagement canonical runtime type.
             *
             * The durable record of a person's engagement with Minds
             * as a service. Persists across sessions, across modality
             * transitions (B75), across episode endings and re-
             * presentations (within the 90-day re-presentation window
             * per intake §6.3).
             *
             * The runtime instance carries a five-axis status tuple at
             * all times:
             *   - lifecycle (orderedEnum): the ten-stage engagement
             *     lifecycle; principally forward-progressing with
             *     review-gate branches
             *   - modality (unorderedEnum): which service-offering
             *     the engagement is delivering; Minds-novel axis
             *     substantiating B75 cross-modality engagement
             *     trajectory
             *   - riskTier (orderedEnum): clinical-safety
             *     classification; advances on intake, observation,
             *     disclosure
             *   - payment (unorderedEnum): commercial state;
             *     orthogonal to lifecycle
             *   - confidentiality (unorderedEnum): consent and
             *     confidentiality configuration
             *   - epistemic (platform-inherited): real / inferred /
             *     expected / predicted / hypothetical / simulated /
             *     retrospectively-recorded
             *
             * No per-type epistemic axis declared — B17 platform-
             * provided tag handles real-vs-synthetic at SRS level
             * uniformly. Per S272 §11.7.
             *
             * Cross-axis rules (S272 §11.5) noted but not authored
             * as SysML in this first implementation. Examples:
             *   - lifecycle.active requires confidentiality.consentedBaseline
             *   - riskTier.activeEscalation requires confidentiality.safetyPlanActivated
             *   - modality.transitioning requires lifecycle.active or lifecycle.underReview
             *   - payment.overdue does not block lifecycle but surfaces at band 5
             *   - confidentiality.consentWithdrawnFull forces lifecycle to close
             *
             * Configured-model content (Minds DBM). Business meta
             * model concept. */

        // -- lifecycle axis (orderedEnum) -------------------------

        part lifecycleAxis : StatusAxis {
            :>> axisName = "lifecycle";
            :>> axisDescription = "The lifecycle stage of the engagement from prospective enquiry through to closure.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide, AxisAuthority::systemSide);
            :>> defaultValue = "prospective";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("prospective", "intake", "suitabilityReview",
                                  "contracting", "active", "paused",
                                  "underReview", "transitioning",
                                  "endedPlanned", "endedUnplanned",
                                  "referredOut", "closed");
            }

            part prospectiveToIntake : AxisTransition {
                :>> fromValue = "prospective";
                :>> toValue = "intake";
                :>> transitionLabel = "enquiry received and intake form initiated";
                :>> requiredAuthority = (AxisAuthority::customerSide, AxisAuthority::systemSide);
            }

            part intakeToSuitabilityReview : AxisTransition {
                :>> fromValue = "intake";
                :>> toValue = "suitabilityReview";
                :>> transitionLabel = "intake form submitted; routed to suitability review";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part suitabilityReviewToContracting : AxisTransition {
                :>> fromValue = "suitabilityReview";
                :>> toValue = "contracting";
                :>> transitionLabel = "suitability accepted; proceed to first-session contracting";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part suitabilityReviewToReferredOut : AxisTransition {
                :>> fromValue = "suitabilityReview";
                :>> toValue = "referredOut";
                :>> transitionLabel = "out-of-scope; signposted to external destination";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part contractingToActive : AxisTransition {
                :>> fromValue = "contracting";
                :>> toValue = "active";
                :>> transitionLabel = "first session contracted; engagement active";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part activeToUnderReview : AxisTransition {
                :>> fromValue = "active";
                :>> toValue = "underReview";
                :>> transitionLabel = "review gate reached at session 6 / 12 / 20";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part underReviewToActive : AxisTransition {
                :>> fromValue = "underReview";
                :>> toValue = "active";
                :>> transitionLabel = "review gate decision: continue";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part underReviewToTransitioning : AxisTransition {
                :>> fromValue = "underReview";
                :>> toValue = "transitioning";
                :>> transitionLabel = "review gate decision: change modality";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part transitioningToActive : AxisTransition {
                :>> fromValue = "transitioning";
                :>> toValue = "active";
                :>> transitionLabel = "modality re-contracting complete; active under new modality";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part activeToPaused : AxisTransition {
                :>> fromValue = "active";
                :>> toValue = "paused";
                :>> transitionLabel = "client requests pause; preserved within 90-day re-presentation window";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part pausedToActive : AxisTransition {
                :>> fromValue = "paused";
                :>> toValue = "active";
                :>> transitionLabel = "client returns within 90-day window";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part pausedToClosed : AxisTransition {
                :>> fromValue = "paused";
                :>> toValue = "closed";
                :>> transitionLabel = "90-day re-presentation window passed without return";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part underReviewToEndedPlanned : AxisTransition {
                :>> fromValue = "underReview";
                :>> toValue = "endedPlanned";
                :>> transitionLabel = "review gate decision: ending well";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part activeToEndedUnplanned : AxisTransition {
                :>> fromValue = "active";
                :>> toValue = "endedUnplanned";
                :>> transitionLabel = "engagement ends without ending-well session";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part endedPlannedToClosed : AxisTransition {
                :>> fromValue = "endedPlanned";
                :>> toValue = "closed";
                :>> transitionLabel = "post-closure check-in window passed; engagement closed";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part endedUnplannedToClosed : AxisTransition {
                :>> fromValue = "endedUnplanned";
                :>> toValue = "closed";
                :>> transitionLabel = "post-closure check-in attempt completed or window passed; engagement closed";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }

        // -- modality axis (unorderedEnum) — Minds-novel ----------

        part modalityAxis : StatusAxis {
            :>> axisName = "modality";
            :>> axisDescription = "The service offering currently being delivered to this engagement. Minds-novel axis substantiating B75 cross-modality engagement trajectory; the engagement may transition between offerings within continuous engagement.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            :>> defaultValue = "digitalOnly";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("digitalOnly", "counselling", "psychotherapy",
                                  "coaching", "transitioning");
            }

            part digitalOnlyToCounselling : AxisTransition {
                :>> fromValue = "digitalOnly";
                :>> toValue = "transitioning";
                :>> transitionLabel = "digital-only client moves into human-led counselling — re-contracting with Cara";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part transitioningToCounselling : AxisTransition {
                :>> fromValue = "transitioning";
                :>> toValue = "counselling";
                :>> transitionLabel = "re-contracting complete; counselling delivery active";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part counsellingToTransitioning : AxisTransition {
                :>> fromValue = "counselling";
                :>> toValue = "transitioning";
                :>> transitionLabel = "modality change initiated from counselling";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part psychotherapyToTransitioning : AxisTransition {
                :>> fromValue = "psychotherapy";
                :>> toValue = "transitioning";
                :>> transitionLabel = "modality change initiated from psychotherapy";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part coachingToTransitioning : AxisTransition {
                :>> fromValue = "coaching";
                :>> toValue = "transitioning";
                :>> transitionLabel = "modality change initiated from coaching";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part transitioningToPsychotherapy : AxisTransition {
                :>> fromValue = "transitioning";
                :>> toValue = "psychotherapy";
                :>> transitionLabel = "re-contracting complete; psychotherapy delivery active";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }

            part transitioningToCoaching : AxisTransition {
                :>> fromValue = "transitioning";
                :>> toValue = "coaching";
                :>> transitionLabel = "re-contracting complete; coaching delivery active";
                :>> requiredAuthority = (AxisAuthority::operatorSide, AxisAuthority::customerSide);
            }
        }

        // -- riskTier axis (orderedEnum) --------------------------

        part riskTierAxis : StatusAxis {
            :>> axisName = "riskTier";
            :>> axisDescription = "The clinical-safety classification of the engagement. Drives band-3 practitioner-attention triage and band-5 founder dashboard risk-overview.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::operatorSide, AxisAuthority::systemSide);
            :>> defaultValue = "standard";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("standard", "gradedConcern", "elevated",
                                  "activeEscalation", "postEscalationReview");
            }

            part standardToGradedConcern : AxisTransition {
                :>> fromValue = "standard";
                :>> toValue = "gradedConcern";
                :>> transitionLabel = "graded concern observed — continued engagement with watchpoint";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part gradedConcernToElevated : AxisTransition {
                :>> fromValue = "gradedConcern";
                :>> toValue = "elevated";
                :>> transitionLabel = "concern advanced to elevated risk — additional safeguards engaged";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part elevatedToActiveEscalation : AxisTransition {
                :>> fromValue = "elevated";
                :>> toValue = "activeEscalation";
                :>> transitionLabel = "active escalation — mandatory safety-plan activation, trusted-contact check";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part standardToActiveEscalation : AxisTransition {
                :>> fromValue = "standard";
                :>> toValue = "activeEscalation";
                :>> transitionLabel = "rapid escalation to active escalation from standard";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part activeEscalationToPostEscalationReview : AxisTransition {
                :>> fromValue = "activeEscalation";
                :>> toValue = "postEscalationReview";
                :>> transitionLabel = "active escalation closed — review of escalation closure";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part postEscalationReviewToStandard : AxisTransition {
                :>> fromValue = "postEscalationReview";
                :>> toValue = "standard";
                :>> transitionLabel = "post-escalation review confirms return to standard tier";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }

        // -- payment axis (unorderedEnum) -------------------------

        part paymentAxis : StatusAxis {
            :>> axisName = "payment";
            :>> axisDescription = "Commercial state of the engagement. Orthogonal to lifecycle — can be active and overdue simultaneously.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::systemSide, AxisAuthority::operatorSide);
            :>> defaultValue = "selfPayPerSession";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("selfPayPerSession", "blockPurchaseActive",
                                  "corporateInvoice", "overdue", "paidUp",
                                  "refunded");
            }

            part selfPayToBlockPurchase : AxisTransition {
                :>> fromValue = "selfPayPerSession";
                :>> toValue = "blockPurchaseActive";
                :>> transitionLabel = "client purchases a block (counselling or coaching only)";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part blockPurchaseToPaidUp : AxisTransition {
                :>> fromValue = "blockPurchaseActive";
                :>> toValue = "paidUp";
                :>> transitionLabel = "block prepay reconciled at session delivery";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part selfPayToOverdue : AxisTransition {
                :>> fromValue = "selfPayPerSession";
                :>> toValue = "overdue";
                :>> transitionLabel = "expected payment not received within window";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part overdueToSelfPay : AxisTransition {
                :>> fromValue = "overdue";
                :>> toValue = "selfPayPerSession";
                :>> transitionLabel = "outstanding payment received — return to standard";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part overdueToRefunded : AxisTransition {
                :>> fromValue = "overdue";
                :>> toValue = "refunded";
                :>> transitionLabel = "refund issued under PricingRule";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part selfPayToCorporateInvoice : AxisTransition {
                :>> fromValue = "selfPayPerSession";
                :>> toValue = "corporateInvoice";
                :>> transitionLabel = "engagement reconfigured under corporate-coaching arrangement";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }
        }

        // -- confidentiality axis (unorderedEnum) -----------------

        part confidentialityAxis : StatusAxis {
            :>> axisName = "confidentiality";
            :>> axisDescription = "Consent and confidentiality configuration. Baseline plus permission grants plus safety-plan activation state.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::customerSide, AxisAuthority::operatorSide);
            :>> defaultValue = "consentedBaseline";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("consentedBaseline",
                                  "consentedWithSharingPermission",
                                  "safetyPlanActivated",
                                  "consentWithdrawnPartial",
                                  "consentWithdrawnFull");
            }

            part baselineToWithSharingPermission : AxisTransition {
                :>> fromValue = "consentedBaseline";
                :>> toValue = "consentedWithSharingPermission";
                :>> transitionLabel = "client grants specific sharing permission (e.g. GP liaison)";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part withSharingPermissionToBaseline : AxisTransition {
                :>> fromValue = "consentedWithSharingPermission";
                :>> toValue = "consentedBaseline";
                :>> transitionLabel = "client revokes specific sharing permission";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part baselineToSafetyPlanActivated : AxisTransition {
                :>> fromValue = "consentedBaseline";
                :>> toValue = "safetyPlanActivated";
                :>> transitionLabel = "safety plan activated on clinical grounds";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part safetyPlanActivatedToBaseline : AxisTransition {
                :>> fromValue = "safetyPlanActivated";
                :>> toValue = "consentedBaseline";
                :>> transitionLabel = "post-escalation review confirms return to baseline";
                :>> requiredAuthority = (AxisAuthority::operatorSide);
            }

            part baselineToConsentWithdrawnPartial : AxisTransition {
                :>> fromValue = "consentedBaseline";
                :>> toValue = "consentWithdrawnPartial";
                :>> transitionLabel = "client withdraws specific consent (e.g. data sharing with employer)";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part baselineToConsentWithdrawnFull : AxisTransition {
                :>> fromValue = "consentedBaseline";
                :>> toValue = "consentWithdrawnFull";
                :>> transitionLabel = "client withdraws full consent — engagement closure required";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }
        }
    }

    // =====================================================================
    // DIGITAL SUBSCRIPTION — Four-axis canonical runtime type (S272 §12)
    //
    // First exercise of B73 (digital content as canonical service
    // offering) at the canonical-runtime-type level. The engagement
    // axis is the first explicitly derived axis declared on any
    // canonical runtime type — flagged as OW-S272-4 territory for
    // multi-axis-primitive paper sharpening.
    //
    // No per-type epistemic axis declared (B17 platform-provided tag
    // handles real-vs-synthetic at SRS level uniformly).
    //
    // =====================================================================

    part def DigitalSubscription :> CanonicalRuntimeType {
        doc /* Minds DigitalSubscription canonical runtime type.
             *
             * The subscriber's relationship with the digital wellbeing
             * content paid tier. Structurally distinct from
             * ClientEngagement: continuous lifecycle (not episodic),
             * subscription-shaped progression (not clinical-encounter-
             * shaped), state-transitions dominated by billing-events
             * and content-engagement-events rather than practitioner-
             * decisions.
             *
             * The runtime instance carries a four-axis status tuple at
             * all times:
             *   - subscriptionLifecycle (unorderedEnum): the
             *     subscription commercial lifecycle including
             *     reactivation as a distinguished transition
             *   - billing (unorderedEnum): payment-processing state
             *   - engagement (orderedEnum, derived): content-
             *     engagement intensity pattern derived by RSR from
             *     SRS content-engagement events. First explicitly
             *     derived axis in the platform; OW-S272-4 territory.
             *   - planConfiguration (unorderedEnum): plan-level shape
             *     (monthly / annual / changing)
             *   - epistemic (platform-inherited)
             *
             * No per-type epistemic axis (per S272 §12.8).
             *
             * Cross-axis rules (S272 §12.5) noted but not authored
             * as SysML in this first implementation. Examples:
             *   - billing.finalFailure forces subscriptionLifecycle
             *     to cancelledPendingEndOfPeriod
             *   - subscriptionLifecycle.churned terminates engagement
             *     tracking
             *   - subscriptionLifecycle.trial limits content access
             *     to trial-allowed subset
             *   - planConfiguration.planChanging requires billing.current
             *
             * Configured-model content (Minds DBM). Business meta
             * model concept. */

        // -- subscriptionLifecycle axis (unorderedEnum) -----------

        part subscriptionLifecycleAxis : StatusAxis {
            :>> axisName = "subscriptionLifecycle";
            :>> axisDescription = "The commercial lifecycle of the subscription — graph-shaped with reactivation as a distinguished transition. Driven primarily by billing events and user actions.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::customerSide, AxisAuthority::systemSide);
            :>> defaultValue = "trial";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("trial", "active", "paused", "gracePeriod",
                                  "cancelledPendingEndOfPeriod",
                                  "cancelled", "churned", "reactivated");
            }

            part trialToActive : AxisTransition {
                :>> fromValue = "trial";
                :>> toValue = "active";
                :>> transitionLabel = "first paid billing event succeeds";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part activeToGracePeriod : AxisTransition {
                :>> fromValue = "active";
                :>> toValue = "gracePeriod";
                :>> transitionLabel = "billing failure — entered grace period for retry";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part gracePeriodToActive : AxisTransition {
                :>> fromValue = "gracePeriod";
                :>> toValue = "active";
                :>> transitionLabel = "billing resolved within grace period";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part gracePeriodToCancelledPendingEnd : AxisTransition {
                :>> fromValue = "gracePeriod";
                :>> toValue = "cancelledPendingEndOfPeriod";
                :>> transitionLabel = "billing not resolved within grace period — cancellation scheduled at period end";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part activeToCancelledPendingEnd : AxisTransition {
                :>> fromValue = "active";
                :>> toValue = "cancelledPendingEndOfPeriod";
                :>> transitionLabel = "user cancels — access continues until end of paid period";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part cancelledPendingEndToCancelled : AxisTransition {
                :>> fromValue = "cancelledPendingEndOfPeriod";
                :>> toValue = "cancelled";
                :>> transitionLabel = "paid period ends — subscription cancelled";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part cancelledToChurned : AxisTransition {
                :>> fromValue = "cancelled";
                :>> toValue = "churned";
                :>> transitionLabel = "30-day post-cancellation window passed without reactivation";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part churnedToReactivated : AxisTransition {
                :>> fromValue = "churned";
                :>> toValue = "reactivated";
                :>> transitionLabel = "previously-churned subscriber returns and signs up";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part reactivatedToActive : AxisTransition {
                :>> fromValue = "reactivated";
                :>> toValue = "active";
                :>> transitionLabel = "reactivated subscription enters active lifecycle";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }

        // -- billing axis (unorderedEnum) -------------------------

        part billingAxis : StatusAxis {
            :>> axisName = "billing";
            :>> axisDescription = "Payment-processing state. Independent of subscriptionLifecycle in transient states; final failure forces cancellation.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::systemSide);
            :>> defaultValue = "current";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("current", "paymentFailed", "retryScheduled",
                                  "resolved", "finalFailure");
            }

            part currentToPaymentFailed : AxisTransition {
                :>> fromValue = "current";
                :>> toValue = "paymentFailed";
                :>> transitionLabel = "payment-processor reports failed transaction";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part paymentFailedToRetryScheduled : AxisTransition {
                :>> fromValue = "paymentFailed";
                :>> toValue = "retryScheduled";
                :>> transitionLabel = "automatic retry queued";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part retryScheduledToResolved : AxisTransition {
                :>> fromValue = "retryScheduled";
                :>> toValue = "resolved";
                :>> transitionLabel = "retry succeeds";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part resolvedToCurrent : AxisTransition {
                :>> fromValue = "resolved";
                :>> toValue = "current";
                :>> transitionLabel = "payment resolved; return to standard state";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part retryScheduledToFinalFailure : AxisTransition {
                :>> fromValue = "retryScheduled";
                :>> toValue = "finalFailure";
                :>> transitionLabel = "all retries exhausted; final failure recorded";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }

        // -- engagement axis (orderedEnum, derived) ---------------
        //
        // Derivation note: this axis is computed by an RSR
        // (reflective reasoner) from SRS content-engagement events
        // — not asserted by user or system directly. The
        // canonical-runtime AxisAuthority enum does not yet admit
        // a "systemDerived" value. Configured here as systemSide
        // with this doc-block flagging OW-S272-4: derived axes are
        // a new axis-authority type; multi-axis-primitive paper
        // (S253) sharpening candidate.

        part engagementAxis : StatusAxis {
            :>> axisName = "engagement";
            :>> axisDescription = "Content-engagement intensity pattern, derived by an RSR (reflective reasoner) from SRS content-engagement events. First explicitly derived axis in the platform — OW-S272-4 candidate for axis-authority enum extension.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::systemSide);
            :>> defaultValue = "dormant";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::orderedEnum;
                :>> enumValues = ("dormant", "occasional", "regular", "heavy",
                                  "reEngaged", "disengaging");
            }

            part dormantToOccasional : AxisTransition {
                :>> fromValue = "dormant";
                :>> toValue = "occasional";
                :>> transitionLabel = "RSR detects first or returning content engagement after dormancy";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part occasionalToRegular : AxisTransition {
                :>> fromValue = "occasional";
                :>> toValue = "regular";
                :>> transitionLabel = "RSR detects sustained regular engagement";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part regularToHeavy : AxisTransition {
                :>> fromValue = "regular";
                :>> toValue = "heavy";
                :>> transitionLabel = "RSR detects high engagement intensity";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part heavyToRegular : AxisTransition {
                :>> fromValue = "heavy";
                :>> toValue = "regular";
                :>> transitionLabel = "RSR detects engagement reduced to regular level";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part regularToDisengaging : AxisTransition {
                :>> fromValue = "regular";
                :>> toValue = "disengaging";
                :>> transitionLabel = "RSR detects regular-to-occasional-to-dormant trajectory — churn risk";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part disengagingToDormant : AxisTransition {
                :>> fromValue = "disengaging";
                :>> toValue = "dormant";
                :>> transitionLabel = "engagement falls to zero over trailing window";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part dormantToReEngaged : AxisTransition {
                :>> fromValue = "dormant";
                :>> toValue = "reEngaged";
                :>> transitionLabel = "RSR detects dormant-to-regular trajectory — re-engagement signal";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part reEngagedToRegular : AxisTransition {
                :>> fromValue = "reEngaged";
                :>> toValue = "regular";
                :>> transitionLabel = "re-engagement consolidated to regular";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }

        // -- planConfiguration axis (unorderedEnum) ---------------

        part planConfigurationAxis : StatusAxis {
            :>> axisName = "planConfiguration";
            :>> axisDescription = "The plan-level shape — monthly, annual, or transitioning between plans. Plan changes take effect at end of current period.";
            :>> axisScope = AxisScope::tenantDeclared;
            :>> axisAuthority = (AxisAuthority::customerSide, AxisAuthority::systemSide);
            :>> defaultValue = "monthlyPaid";

            part :>> valueSpace : ValueSpace {
                :>> valueShape = ValueSpaceShape::unorderedEnum;
                :>> enumValues = ("monthlyPaid", "annualPaid",
                                  "planChangingMonthlyToAnnual",
                                  "planChangingAnnualToMonthly");
            }

            part monthlyToChangingToAnnual : AxisTransition {
                :>> fromValue = "monthlyPaid";
                :>> toValue = "planChangingMonthlyToAnnual";
                :>> transitionLabel = "user requests plan change to annual — effective at period end";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part changingToAnnualComplete : AxisTransition {
                :>> fromValue = "planChangingMonthlyToAnnual";
                :>> toValue = "annualPaid";
                :>> transitionLabel = "plan change effective at period end — now annual";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }

            part annualToChangingToMonthly : AxisTransition {
                :>> fromValue = "annualPaid";
                :>> toValue = "planChangingAnnualToMonthly";
                :>> transitionLabel = "user requests plan change to monthly — effective at period end";
                :>> requiredAuthority = (AxisAuthority::customerSide);
            }

            part changingToMonthlyComplete : AxisTransition {
                :>> fromValue = "planChangingAnnualToMonthly";
                :>> toValue = "monthlyPaid";
                :>> transitionLabel = "plan change effective at period end — now monthly";
                :>> requiredAuthority = (AxisAuthority::systemSide);
            }
        }
    }
}
