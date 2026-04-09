import type { Domain, ModuleInstanceWithDefinition } from '$lib/types.js';

export interface EvaluatorContext {
    configValues: Record<string, unknown>;
    domain: Domain;
    allModules: ModuleInstanceWithDefinition[];
}

export type EvaluatorFn = (ctx: EvaluatorContext) => { satisfied: boolean; explanation: string };

const evaluators: Record<string, EvaluatorFn> = {

    // ── Service Offerings ────────────────────────────────────────────

    serviceDescriptionRequired: ({ configValues }) => {
        const desc = (configValues.description as string)?.trim() ?? '';
        return desc.length > 0
            ? { satisfied: true, explanation: 'Service description is provided.' }
            : { satisfied: false, explanation: 'Service description is empty. A description is required before this module can be promoted.' };
    },

    pricingModelExplicit: ({ configValues }) => {
        const model = configValues.pricingModel as string;
        // 'Fixed' is the default — check if it was explicitly set or left unchanged
        // For the prototype, we treat any non-empty value as explicit
        return model && model.length > 0
            ? { satisfied: true, explanation: `Pricing model is set to "${model}".` }
            : { satisfied: false, explanation: 'Pricing model has not been configured.' };
    },

    serviceNameDescriptive: ({ configValues }) => {
        const name = (configValues.serviceName as string)?.trim() ?? '';
        return name.length > 3
            ? { satisfied: true, explanation: `Service name "${name}" is descriptive.` }
            : { satisfied: false, explanation: `Service name "${name}" is very short. Consider a more descriptive name.` };
    },

    // ── Customer Management ──────────────────────────────────────────

    registrationTypeConfigured: ({ configValues }) => {
        const regType = configValues.registrationType as string;
        return regType && regType.length > 0
            ? { satisfied: true, explanation: `Registration type is set to "${regType}".` }
            : { satisfied: false, explanation: 'Customer registration type has not been configured.' };
    },

    retentionPolicyRecommended: ({ configValues }) => {
        const regType = configValues.registrationType as string;
        const policy = (configValues.retentionPolicy as string)?.trim() ?? '';
        if (regType === 'Walk-in') {
            return { satisfied: true, explanation: 'Walk-in customers do not require a retention policy.' };
        }
        return policy.length > 0
            ? { satisfied: true, explanation: 'Retention policy is documented.' }
            : { satisfied: false, explanation: 'No retention policy specified. Recommended for businesses with registered customers.' };
    },

    // ── Scheduling & Workflow ────────────────────────────────────────

    operatingHoursRequired: ({ configValues }) => {
        const hours = (configValues.operatingHours as string)?.trim() ?? '';
        return hours.length > 0
            ? { satisfied: true, explanation: 'Operating hours are specified.' }
            : { satisfied: false, explanation: 'Operating hours must be specified before this module can be promoted.' };
    },

    slotLengthReasonable: ({ configValues }) => {
        const mode = configValues.schedulingMode as string;
        const slot = configValues.defaultSlotMinutes as number;
        if (mode !== 'Appointment') {
            return { satisfied: true, explanation: `Slot length check not applicable for ${mode} scheduling.` };
        }
        return slot >= 15
            ? { satisfied: true, explanation: `Slot length of ${slot} minutes is reasonable.` }
            : { satisfied: false, explanation: `Slot length of ${slot} minutes is very short for appointment-based scheduling. Consider at least 15 minutes.` };
    },

    overbookingAppropriate: ({ configValues }) => {
        const mode = configValues.schedulingMode as string;
        const overbooking = configValues.allowOverbooking as boolean;
        if (!overbooking) {
            return { satisfied: true, explanation: 'Overbooking is disabled.' };
        }
        return mode === 'Queue'
            ? { satisfied: true, explanation: 'Overbooking is acceptable for queue-based scheduling.' }
            : { satisfied: false, explanation: `Overbooking is enabled but scheduling mode is "${mode}". Consider disabling unless queue-based.` };
    },

    // ── Team & Resources ─────────────────────────────────────────────

    teamSizeMinimum: ({ configValues }) => {
        const size = configValues.teamSize as number;
        return size >= 1
            ? { satisfied: true, explanation: `Team size is ${size}.` }
            : { satisfied: false, explanation: 'Team size must be at least 1.' };
    },

    skillTrackingRecommended: ({ configValues }) => {
        const size = configValues.teamSize as number;
        const tracking = configValues.skillTracking as boolean;
        if (size <= 5) {
            return { satisfied: true, explanation: `Team size is ${size} — skill tracking is optional.` };
        }
        return tracking
            ? { satisfied: true, explanation: 'Skill tracking is enabled for a team of ' + size + '.' }
            : { satisfied: false, explanation: `Team has ${size} members. Skill tracking is recommended for teams larger than 5.` };
    },

    // ── Financial Tracking ───────────────────────────────────────────

    vatRegistrationRequired: ({ configValues }) => {
        const vatRegistered = configValues.vatRegistered as boolean;
        // In a real system this would check domain business type and turnover
        // For the prototype, flag if currency is GBP and VAT not confirmed
        const currency = configValues.currency as string;
        if (currency !== 'GBP') {
            return { satisfied: true, explanation: 'VAT check applies to GBP businesses only.' };
        }
        return vatRegistered
            ? { satisfied: true, explanation: 'VAT registration is confirmed.' }
            : { satisfied: false, explanation: 'VAT registration not confirmed. Required for UK businesses above the VAT threshold.' };
    },

    paymentMethodsDocumented: ({ configValues }) => {
        const methods = (configValues.paymentMethods as string)?.trim() ?? '';
        return methods.length > 0
            ? { satisfied: true, explanation: 'Payment methods are documented.' }
            : { satisfied: false, explanation: 'No payment methods documented. Consider specifying accepted payment methods.' };
    },

    invoicingFrequencyAppropriate: ({ configValues }) => {
        const frequency = configValues.invoicingFrequency as string;
        // This evaluator is cross-module — it checks against the service type
        // from the Service Offerings module. For the prototype, we just
        // check the local config and give a gentle recommendation.
        if (frequency === 'Per-service') {
            return { satisfied: true, explanation: 'Per-service invoicing is a reasonable default.' };
        }
        return { satisfied: true, explanation: `Invoicing frequency is set to "${frequency}".` };
    },

    // ── Compliance & Governance ───────────────────────────────────────

    regulatoryBodyRequired: ({ configValues }) => {
        const level = configValues.complianceLevel as string;
        const body = (configValues.regulatoryBody as string)?.trim() ?? '';
        if (level !== 'Sector-regulated') {
            return { satisfied: true, explanation: `Compliance level is "${level}" — regulatory body is optional.` };
        }
        return body.length > 0
            ? { satisfied: true, explanation: `Regulatory body specified: "${body}".` }
            : { satisfied: false, explanation: 'Compliance level is Sector-regulated but no regulatory body is specified. This is required.' };
    },

    dpoRequired: ({ configValues }) => {
        const level = configValues.complianceLevel as string;
        const dpo = configValues.dataProtectionOfficer as boolean;
        if (level !== 'Sector-regulated') {
            return { satisfied: true, explanation: `Compliance level is "${level}" — DPO appointment is optional.` };
        }
        return dpo
            ? { satisfied: true, explanation: 'Data Protection Officer is appointed.' }
            : { satisfied: false, explanation: 'Compliance level is Sector-regulated but no DPO appointed. Required for sector-regulated businesses.' };
    },

    auditFrequencyAppropriate: ({ configValues }) => {
        const level = configValues.complianceLevel as string;
        const frequency = configValues.auditFrequency as string;
        if (level !== 'Sector-regulated') {
            return { satisfied: true, explanation: `Compliance level is "${level}" — audit frequency is at discretion.` };
        }
        const adequate = frequency === 'Quarterly' || frequency === 'Monthly' || frequency === 'Continuous';
        return adequate
            ? { satisfied: true, explanation: `Audit frequency "${frequency}" is appropriate for sector-regulated businesses.` }
            : { satisfied: false, explanation: `Audit frequency "${frequency}" may be insufficient for sector-regulated businesses. Quarterly or more frequent is recommended.` };
    },

    // ── Business Overview (analytical) ────────────────────────────────

    comparisonModeAppropriate: ({ configValues, allModules }) => {
        const comparisonMode = configValues.comparisonMode as boolean;
        // Check if there are multiple variants (modules sharing the same definition)
        const defCounts = new Map<string, number>();
        for (const m of allModules) {
            if (m.installationState === 'installed') {
                defCounts.set(m.definitionId, (defCounts.get(m.definitionId) ?? 0) + 1);
            }
        }
        const hasVariants = Array.from(defCounts.values()).some(count => count > 1);
        if (!hasVariants) {
            return { satisfied: true, explanation: 'No module variants exist — comparison mode is not needed.' };
        }
        return comparisonMode
            ? { satisfied: true, explanation: 'Comparison mode is enabled and variants exist.' }
            : { satisfied: false, explanation: 'Multiple module variants exist but comparison mode is disabled. Consider enabling it.' };
    },

    // ── Customer Traffic Generator (generative) ──────────────────────

    arrivalRateReasonable: ({ configValues }) => {
        const rate = configValues.arrivalRate as number;
        return rate <= 50
            ? { satisfied: true, explanation: `Arrival rate of ${rate}/hour is within reasonable range.` }
            : { satisfied: false, explanation: `Arrival rate of ${rate}/hour exceeds 50. Results may be unrealistic at this volume.` };
    },

    // ── Scenario Driver (generative) ─────────────────────────────────

    scenarioIntensityReasonable: ({ configValues }) => {
        const severity = configValues.severityDistribution as string;
        const pressure = configValues.resourcePressure as string;
        if (severity === 'mostly-high' && pressure === 'high') {
            return { satisfied: false, explanation: 'High severity combined with high resource pressure may overwhelm simulation metrics. Consider reducing one or both.' };
        }
        return { satisfied: true, explanation: 'Scenario intensity is within reasonable bounds.' };
    },

    // ── Comparative Dashboard (analytical) ───────────────────────────

    comparisonModulesConfigured: ({ configValues }) => {
        const ids = (configValues.comparisonModuleIds as string)?.trim() ?? '';
        return ids.length > 0
            ? { satisfied: true, explanation: 'Comparison module IDs are configured.' }
            : { satisfied: false, explanation: 'No comparison module IDs configured. The dashboard needs target modules for meaningful analysis.' };
    }
};

export function getEvaluator(name: string): EvaluatorFn | undefined {
    return evaluators[name];
}

export function hasEvaluator(name: string): boolean {
    return name in evaluators;
}
