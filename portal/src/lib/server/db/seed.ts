import { v4 as uuidv4 } from 'uuid';
import type { Database } from 'better-sqlite3';

interface SeedDefinition {
    id: string;
    name: string;
    slug: string;
    description: string;
    category: string;
    icon: string;
    bmm_concerns: string;
    config_schema: string;
    dependencies: string | null;
    sort_order: number;
}

const definitions: SeedDefinition[] = [
    {
        id: '01-service-offerings',
        name: 'Service Offerings',
        slug: 'service-offerings',
        description: 'Define and manage the services your business provides — what you offer, how it is priced, and how it is delivered.',
        category: 'business',
        icon: 'TagOutline',
        bmm_concerns: JSON.stringify(['ServiceConcept']),
        config_schema: JSON.stringify([
            { key: 'serviceName', type: 'text', label: 'Primary service name', description: 'The main service or product your business provides.', defaultValue: '', required: true },
            { key: 'serviceType', type: 'select', label: 'Service type', description: 'How your service is delivered.', defaultValue: 'Appointment', required: true, options: [{ value: 'Retail', label: 'Retail' }, { value: 'Appointment', label: 'Appointment-based' }, { value: 'Subscription', label: 'Subscription' }, { value: 'Project', label: 'Project-based' }] },
            { key: 'pricingModel', type: 'select', label: 'Pricing model', description: 'How you charge for services.', defaultValue: 'Fixed', required: true, options: [{ value: 'Fixed', label: 'Fixed price' }, { value: 'Hourly', label: 'Hourly rate' }, { value: 'Tiered', label: 'Tiered pricing' }, { value: 'Custom', label: 'Custom / quoted' }] },
            { key: 'description', type: 'text', label: 'Service description', description: 'A brief description of your service offering.', defaultValue: '', required: false }
        ]),
        dependencies: null,
        sort_order: 1
    },
    {
        id: '02-customer-management',
        name: 'Customer Management',
        slug: 'customer-management',
        description: 'Manage your customer relationships — how customers are registered, how you communicate with them, and how you retain them.',
        category: 'business',
        icon: 'UsersOutline',
        bmm_concerns: JSON.stringify(['StakeholderModel', 'ServiceConcept']),
        config_schema: JSON.stringify([
            { key: 'registrationType', type: 'select', label: 'Customer registration', description: 'How customers are registered with your service.', defaultValue: 'Both', required: true, options: [{ value: 'Walk-in', label: 'Walk-in only' }, { value: 'Registered', label: 'Registered accounts' }, { value: 'Both', label: 'Both' }] },
            { key: 'communicationPreference', type: 'select', label: 'Communication channel', description: 'Primary channel for customer communication.', defaultValue: 'Email', required: true, options: [{ value: 'Email', label: 'Email' }, { value: 'SMS', label: 'SMS' }, { value: 'Both', label: 'Both' }, { value: 'None', label: 'None' }] },
            { key: 'retentionPolicy', type: 'text', label: 'Retention policy', description: 'Describe how you manage customer data retention.', defaultValue: '', required: false }
        ]),
        dependencies: null,
        sort_order: 2
    },
    {
        id: '03-scheduling-workflow',
        name: 'Scheduling & Workflow',
        slug: 'scheduling-workflow',
        description: 'Configure how work is scheduled and sequenced — appointments, queues, batches, and operating hours.',
        category: 'business',
        icon: 'CalendarMonthOutline',
        bmm_concerns: JSON.stringify(['ActivityModel']),
        config_schema: JSON.stringify([
            { key: 'schedulingMode', type: 'select', label: 'Scheduling mode', description: 'How work is allocated and sequenced.', defaultValue: 'Appointment', required: true, options: [{ value: 'Appointment', label: 'Appointment-based' }, { value: 'Walk-in', label: 'Walk-in / first-come' }, { value: 'Queue', label: 'Managed queue' }, { value: 'Batch', label: 'Batch processing' }] },
            { key: 'defaultSlotMinutes', type: 'number', label: 'Default slot length (minutes)', description: 'Default duration for a single appointment or task slot.', defaultValue: 30, required: true },
            { key: 'operatingHours', type: 'text', label: 'Operating hours', description: 'Describe your typical operating hours, e.g. "Mon–Fri 9–5".', defaultValue: '', required: false },
            { key: 'allowOverbooking', type: 'boolean', label: 'Allow overbooking', description: 'Whether the system can accept more bookings than strict capacity allows.', defaultValue: false, required: false }
        ]),
        dependencies: null,
        sort_order: 3
    },
    {
        id: '04-team-resources',
        name: 'Team & Resources',
        slug: 'team-resources',
        description: 'Track your team, premises, equipment, and skills — the resources that make service delivery possible.',
        category: 'business',
        icon: 'UserSettingsOutline',
        bmm_concerns: JSON.stringify(['ResourcePlanning']),
        config_schema: JSON.stringify([
            { key: 'teamSize', type: 'number', label: 'Team size', description: 'Number of people in the service delivery team.', defaultValue: 1, required: true },
            { key: 'premisesType', type: 'select', label: 'Premises type', description: 'Where service is delivered from.', defaultValue: 'Fixed', required: true, options: [{ value: 'Fixed', label: 'Fixed premises' }, { value: 'Mobile', label: 'Mobile / on-site' }, { value: 'Home-based', label: 'Home-based' }, { value: 'Shared', label: 'Shared / co-working' }] },
            { key: 'keyEquipment', type: 'text', label: 'Key equipment', description: 'List the main equipment or tools your team uses.', defaultValue: '', required: false },
            { key: 'skillTracking', type: 'boolean', label: 'Track skills per team member', description: 'Whether individual team member skills are tracked for scheduling.', defaultValue: false, required: false }
        ]),
        dependencies: null,
        sort_order: 4
    },
    {
        id: '05-financial-tracking',
        name: 'Financial Tracking',
        slug: 'financial-tracking',
        description: 'Track income, expenses, invoicing, and tax — financial visibility for your service business.',
        category: 'business',
        icon: 'ChartOutline',
        bmm_concerns: JSON.stringify(['FinancialPlanning']),
        config_schema: JSON.stringify([
            { key: 'currency', type: 'select', label: 'Currency', description: 'Primary currency for financial tracking.', defaultValue: 'GBP', required: true, options: [{ value: 'GBP', label: 'GBP (£)' }, { value: 'EUR', label: 'EUR (€)' }, { value: 'USD', label: 'USD ($)' }] },
            { key: 'vatRegistered', type: 'boolean', label: 'VAT registered', description: 'Whether your business is registered for VAT.', defaultValue: false, required: false },
            { key: 'invoicingFrequency', type: 'select', label: 'Invoicing frequency', description: 'How often invoices are issued.', defaultValue: 'Per-service', required: true, options: [{ value: 'Per-service', label: 'Per service' }, { value: 'Weekly', label: 'Weekly' }, { value: 'Monthly', label: 'Monthly' }] },
            { key: 'paymentMethods', type: 'text', label: 'Payment methods accepted', description: 'e.g. Card, bank transfer, cash.', defaultValue: '', required: false }
        ]),
        dependencies: null,
        sort_order: 5
    },
    {
        id: '06-compliance-governance',
        name: 'Compliance & Governance',
        slug: 'compliance-governance',
        description: 'Map your regulatory obligations, compliance level, and governance structure — knowing what you must do and when.',
        category: 'business',
        icon: 'ShieldCheckOutline',
        bmm_concerns: JSON.stringify(['GovernanceMapping']),
        config_schema: JSON.stringify([
            { key: 'regulatoryBody', type: 'text', label: 'Regulatory body', description: 'Primary regulator or standards body for your sector, e.g. CQC, FCA.', defaultValue: '', required: false },
            { key: 'complianceLevel', type: 'select', label: 'Compliance level', description: 'How heavily regulated your service is.', defaultValue: 'Standard', required: true, options: [{ value: 'Light', label: 'Light (general business)' }, { value: 'Standard', label: 'Standard (registered business)' }, { value: 'Sector-regulated', label: 'Sector-regulated (e.g. healthcare, finance)' }] },
            { key: 'auditFrequency', type: 'select', label: 'Audit frequency', description: 'How often compliance is audited.', defaultValue: 'Annual', required: true, options: [{ value: 'Annual', label: 'Annual' }, { value: 'Quarterly', label: 'Quarterly' }, { value: 'Monthly', label: 'Monthly' }, { value: 'Continuous', label: 'Continuous monitoring' }] },
            { key: 'dataProtectionOfficer', type: 'boolean', label: 'Data Protection Officer appointed', description: 'Whether a DPO has been appointed (required for some regulated sectors).', defaultValue: false, required: false }
        ]),
        dependencies: null,
        sort_order: 6
    },
    {
        id: '07-business-overview',
        name: 'Business Overview',
        slug: 'business-overview',
        description: 'A cross-cutting analytical view of your domain — aggregates data from installed modules to provide a unified picture of business performance.',
        category: 'analytical',
        icon: 'ChartMixedOutline',
        bmm_concerns: JSON.stringify(['Cross-cutting']),
        config_schema: JSON.stringify([
            { key: 'refreshInterval', type: 'select', label: 'Refresh interval', description: 'How frequently the overview data is updated.', defaultValue: 'Daily', required: true, options: [{ value: 'Real-time', label: 'Real-time' }, { value: 'Hourly', label: 'Hourly' }, { value: 'Daily', label: 'Daily' }] },
            { key: 'metricsScope', type: 'select', label: 'Metrics scope', description: 'Which modules contribute to the overview.', defaultValue: 'All modules', required: true, options: [{ value: 'All modules', label: 'All installed modules' }, { value: 'Selected modules', label: 'Selected modules only' }] },
            { key: 'comparisonMode', type: 'boolean', label: 'Enable comparison mode', description: 'Show period-over-period comparisons in the overview.', defaultValue: false, required: false }
        ]),
        dependencies: null,
        sort_order: 7
    },
    {
        id: '08-customer-traffic-generator',
        name: 'Customer Traffic Generator',
        slug: 'customer-traffic-generator',
        description: 'Generates synthetic customer traffic and transactions for simulation runs. Configure arrival rates, transaction values, and distribution patterns.',
        category: 'generative',
        icon: 'ArrowsRepeatOutline',
        bmm_concerns: JSON.stringify(['Cross-cutting']),
        config_schema: JSON.stringify([
            { key: 'arrivalRate', type: 'number', label: 'Arrival rate (per simulated hour)', description: 'Average number of customer arrivals per simulated hour.', defaultValue: 10, required: true },
            { key: 'avgTransactionValue', type: 'number', label: 'Average transaction value', description: 'Mean transaction value in the domain currency.', defaultValue: 50, required: true },
            { key: 'transactionVariance', type: 'number', label: 'Transaction variance (0–1)', description: 'How much transaction values vary. 0 = uniform, 1 = high variance.', defaultValue: 0.3, required: true },
            { key: 'peakHoursEnabled', type: 'boolean', label: 'Enable peak hours', description: 'Whether to simulate higher traffic during peak periods (10:00–14:00).', defaultValue: false, required: false }
        ]),
        dependencies: null,
        sort_order: 8
    },
    {
        id: '09-scenario-driver',
        name: 'Scenario Driver',
        slug: 'scenario-driver',
        description: 'Generates operational scenarios — issues, resource pressures, and incidents — to stress-test your business configuration.',
        category: 'generative',
        icon: 'AdjustmentsHorizontalOutline',
        bmm_concerns: JSON.stringify(['Cross-cutting']),
        config_schema: JSON.stringify([
            { key: 'issueFrequency', type: 'number', label: 'Issues per simulated day', description: 'Average number of operational issues generated per simulated day.', defaultValue: 2, required: true },
            { key: 'severityDistribution', type: 'select', label: 'Severity distribution', description: 'How issue severity is distributed.', defaultValue: 'balanced', required: true, options: [{ value: 'mostly-low', label: 'Mostly low severity' }, { value: 'balanced', label: 'Balanced' }, { value: 'mostly-high', label: 'Mostly high severity' }] },
            { key: 'resourcePressure', type: 'select', label: 'Resource pressure level', description: 'Level of resource pressure to simulate.', defaultValue: 'normal', required: true, options: [{ value: 'low', label: 'Low' }, { value: 'normal', label: 'Normal' }, { value: 'high', label: 'High' }] }
        ]),
        dependencies: null,
        sort_order: 9
    },
    {
        id: '10-comparative-dashboard',
        name: 'Comparative Dashboard',
        slug: 'comparative-dashboard',
        description: 'Compares metrics across sibling business module variants side by side. Shows event volumes, financial performance, issue rates, and health scores.',
        category: 'analytical',
        icon: 'ChartMixedOutline',
        bmm_concerns: JSON.stringify(['Cross-cutting']),
        config_schema: JSON.stringify([
            { key: 'comparisonModuleIds', type: 'text', label: 'Comparison module IDs', description: 'Comma-separated IDs of module instances to compare. Will become a picker in a later phase.', defaultValue: '', required: false },
            { key: 'metricsToShow', type: 'select', label: 'Metrics to display', description: 'Which categories of metrics to show in the comparison.', defaultValue: 'all', required: true, options: [{ value: 'all', label: 'All metrics' }, { value: 'financial', label: 'Financial only' }, { value: 'operational', label: 'Operational only' }] }
        ]),
        dependencies: null,
        sort_order: 10
    }
];

export function seedModuleDefinitions(db: Database): void {
    const insert = db.prepare(`
        INSERT OR IGNORE INTO module_definitions
            (id, name, slug, description, category, icon, bmm_concerns, config_schema, dependencies, sort_order)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertMany = db.transaction((defs: SeedDefinition[]) => {
        for (const def of defs) {
            insert.run(def.id, def.name, def.slug, def.description, def.category, def.icon, def.bmm_concerns, def.config_schema, def.dependencies, def.sort_order);
        }
    });

    insertMany(definitions);
}
