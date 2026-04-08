import type { ConfigFieldDefinition, BmmConcern } from '$lib/types.js';

export interface ConcernMeta {
    label: string;
    description: string;
    icon: string;
    schema: ConfigFieldDefinition[];
}

export const CONCERN_META: Record<BmmConcern, ConcernMeta> = {
    ServiceConcept: {
        label: 'Service Concept',
        description: 'What value your business delivers, to whom, and why it is worth paying for.',
        icon: 'TagOutline',
        schema: [
            { key: 'businessName', type: 'text', label: 'Business name', description: 'The trading name of this service business.', defaultValue: '', required: true },
            { key: 'valueProposition', type: 'text', label: 'Value proposition', description: 'What makes your service valuable to customers — in one or two sentences.', defaultValue: '', required: false },
            { key: 'targetMarket', type: 'text', label: 'Target market', description: 'Who your primary customers are.', defaultValue: '', required: false },
            { key: 'deliveryMode', type: 'select', label: 'Delivery mode', description: 'How services are delivered to customers.', defaultValue: 'in-person', required: true, options: [{ value: 'in-person', label: 'In person' }, { value: 'remote', label: 'Remote' }, { value: 'hybrid', label: 'Hybrid' }] }
        ]
    },
    ActivityModel: {
        label: 'Activity Model',
        description: 'How value is produced and delivered — processes, pathways, workflows, and operating rhythm.',
        icon: 'CalendarMonthOutline',
        schema: [
            { key: 'operatingHours', type: 'text', label: 'Operating hours', description: 'Typical operating hours, e.g. "Mon–Fri 9:00–17:00".', defaultValue: '', required: false },
            { key: 'peakPeriods', type: 'text', label: 'Peak periods', description: 'When demand is highest, e.g. "December", "Monday mornings".', defaultValue: '', required: false },
            { key: 'handoverProtocol', type: 'text', label: 'Handover protocol', description: 'How work is handed over between shifts, teams, or stages.', defaultValue: '', required: false }
        ]
    },
    ResourcePlanning: {
        label: 'Resource Planning',
        description: 'What resources and capabilities are required — premises, people, equipment, and skills.',
        icon: 'UserSettingsOutline',
        schema: [
            { key: 'primaryPremises', type: 'text', label: 'Primary premises', description: 'Where the service operates from.', defaultValue: '', required: false },
            { key: 'staffCount', type: 'number', label: 'Staff count', description: 'Approximate number of staff involved in service delivery.', defaultValue: 1, required: true },
            { key: 'keyEquipment', type: 'text', label: 'Key equipment', description: 'Main equipment or tools used in service delivery.', defaultValue: '', required: false }
        ]
    },
    FinancialPlanning: {
        label: 'Financial Planning',
        description: 'How money flows — revenue model, costs, pricing, and financial projections.',
        icon: 'ChartOutline',
        schema: [
            { key: 'currency', type: 'select', label: 'Operating currency', description: 'Primary currency for financial operations.', defaultValue: 'GBP', required: true, options: [{ value: 'GBP', label: 'GBP (£)' }, { value: 'EUR', label: 'EUR (€)' }, { value: 'USD', label: 'USD ($)' }] },
            { key: 'vatRegistered', type: 'boolean', label: 'VAT registered', description: 'Whether the business is registered for VAT.', defaultValue: false, required: false },
            { key: 'financialYear', type: 'text', label: 'Financial year end', description: 'e.g. "31 March", "31 December".', defaultValue: '', required: false },
            { key: 'targetRevenue', type: 'number', label: 'Target annual revenue', description: 'Annual revenue target in the operating currency.', defaultValue: 0, required: false }
        ]
    },
    GovernanceMapping: {
        label: 'Governance Mapping',
        description: 'Regulatory requirements, compliance obligations, risk management, and learning.',
        icon: 'ShieldCheckOutline',
        schema: [
            { key: 'jurisdiction', type: 'select', label: 'Jurisdiction', description: 'Legal jurisdiction for governance obligations.', defaultValue: 'england-wales', required: true, options: [{ value: 'england-wales', label: 'England & Wales' }, { value: 'scotland', label: 'Scotland' }, { value: 'northern-ireland', label: 'Northern Ireland' }, { value: 'republic-of-ireland', label: 'Republic of Ireland' }] },
            { key: 'regulatoryBodies', type: 'text', label: 'Regulatory bodies', description: 'Key regulators and standards bodies, e.g. "CQC, NMC, NICE".', defaultValue: '', required: false },
            { key: 'dataProtectionApproach', type: 'select', label: 'Data protection approach', description: 'How data protection is managed.', defaultValue: 'basic', required: true, options: [{ value: 'basic', label: 'Basic compliance' }, { value: 'dpo-appointed', label: 'DPO appointed' }, { value: 'outsourced', label: 'Outsourced' }] }
        ]
    },
    StakeholderModel: {
        label: 'Stakeholder Model',
        description: 'Relationships, partnerships, cooperative delivery, community, and participation.',
        icon: 'UsersOutline',
        schema: [
            { key: 'keyPartners', type: 'text', label: 'Key partners', description: 'Main business partners, suppliers, or cooperating organisations.', defaultValue: '', required: false },
            { key: 'customerSegments', type: 'text', label: 'Customer segments', description: 'Distinct customer groups your business serves.', defaultValue: '', required: false },
            { key: 'communityRelationships', type: 'text', label: 'Community relationships', description: 'Relationships with local communities, professional networks, or industry bodies.', defaultValue: '', required: false }
        ]
    }
};
