import type { ModuleDefinition, ModuleInstanceWithDefinition, BmmConcern, DomainContext } from '$lib/types.js';
import { BMM_CONCERNS } from '$lib/types.js';
import { CONCERN_META } from '$lib/context/schemas.js';

export interface CompositionPreview {
    covers: { concern: BmmConcern; label: string }[];
    connectedModules: { name: string; sharedConcerns: string[] }[];
    newConcerns: { concern: BmmConcern; label: string }[];
    contextSummary: { concern: BmmConcern; label: string; hasValues: boolean }[];
}

/**
 * Produce a composition preview for installing a module definition
 * into a domain that already has some modules installed.
 */
export function getCompositionPreview(
    definition: ModuleDefinition,
    installedModules: ModuleInstanceWithDefinition[],
    contexts: DomainContext[]
): CompositionPreview {
    const defConcerns = definition.bmmConcerns.filter(
        (c): c is BmmConcern => BMM_CONCERNS.includes(c as BmmConcern)
    );

    // Concerns this module covers
    const covers = defConcerns.map(c => ({
        concern: c,
        label: CONCERN_META[c]?.label ?? c
    }));

    // Modules sharing concerns
    const active = installedModules.filter(m => m.installationState !== 'trashed');
    const connectedModules: { name: string; sharedConcerns: string[] }[] = [];
    for (const mod of active) {
        const shared = mod.definition.bmmConcerns.filter(c => defConcerns.includes(c as BmmConcern));
        if (shared.length > 0) {
            connectedModules.push({
                name: mod.displayName || mod.definition.name,
                sharedConcerns: shared
            });
        }
    }

    // New concerns not yet covered
    const coveredConcerns = new Set(active.flatMap(m => m.definition.bmmConcerns));
    const newConcerns = defConcerns
        .filter(c => !coveredConcerns.has(c))
        .map(c => ({ concern: c, label: CONCERN_META[c]?.label ?? c }));

    // Domain context status for relevant concerns
    const contextSummary = defConcerns.map(c => {
        const ctx = contexts.find(dc => dc.concern === c);
        const hasValues = ctx
            ? Object.values(ctx.contextValues).some(v => v !== '' && v !== 0 && v !== false && v !== null && v !== undefined)
            : false;
        return { concern: c, label: CONCERN_META[c]?.label ?? c, hasValues };
    });

    return { covers, connectedModules, newConcerns, contextSummary };
}

/**
 * Hard-coded composition hints per module definition.
 * These explain in business language how a module connects to the domain.
 */
export const COMPOSITION_HINTS: Record<string, string> = {
    '01-service-offerings': 'Defines what your business offers. Other modules — particularly Customer Management and Financial Tracking — draw on this to understand what is being sold and delivered.',
    '02-customer-management': 'Manages your customer relationships. Connects to Service Offerings through the ServiceConcept — knowing who your customers are and what they receive.',
    '03-scheduling-workflow': 'Configures how work is scheduled. Can connect with Team & Resources to match available staff to appointment slots, and uses your domain\'s operating hours as a baseline.',
    '04-team-resources': 'Tracks your team, premises, and equipment. Scheduling & Workflow can use this to match capacity with demand.',
    '05-financial-tracking': 'Tracks income, expenses, and invoicing. Uses your domain\'s operating currency and VAT status from the Financial Planning context.',
    '06-compliance-governance': 'Maps regulatory obligations and compliance requirements. Uses your domain\'s jurisdiction and regulatory bodies from the Governance Mapping context.',
    '07-business-overview': 'A cross-cutting analytical view that aggregates data from all installed modules. More useful once several business modules are active.',
    '08-customer-traffic-generator': 'Generates synthetic customer traffic for simulation runs. Install this to create simulation scenarios — it produces customer arrivals and transactions that business modules can be tested against.',
    '09-scenario-driver': 'Generates operational scenarios — issues and resource pressures — for simulation runs. Pair with the Customer Traffic Generator for comprehensive business simulations.',
    '10-comparative-dashboard': 'Compares metrics across sibling module variants. Most useful after duplicating business modules as hypothesis variants and running simulations against them.'
};
