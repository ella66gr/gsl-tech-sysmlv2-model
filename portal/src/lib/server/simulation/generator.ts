import { v4 as uuidv4 } from 'uuid';
import db from '../db/index.js';
import type { SimulationFidelity, SimulationEventType } from '$lib/types.js';

interface GeneratorConfig {
    arrivalRate?: number;
    avgTransactionValue?: number;
    transactionVariance?: number;
    peakHoursEnabled?: boolean;
    issueFrequency?: number;
    severityDistribution?: string;
    resourcePressure?: string;
}

interface EventInsert {
    id: string;
    runId: string;
    domainId: string;
    eventType: SimulationEventType;
    sourceModuleId: string;
    targetModuleId: string;
    payload: string;
    simulatedAt: string;
}

// ── Random helpers ───────────────────────────────────────────────────

function randomPoisson(lambda: number): number {
    // Knuth algorithm for Poisson-distributed random variable
    let L = Math.exp(-lambda);
    let k = 0;
    let p = 1;
    do {
        k++;
        p *= Math.random();
    } while (p > L);
    return k - 1;
}

function randomLogNormal(mean: number, sigma: number): number {
    // Box-Muller transform for normal, then exponentiate
    const u1 = Math.random();
    const u2 = Math.random();
    const z = Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
    const mu = Math.log(mean) - (sigma * sigma) / 2;
    return Math.exp(mu + sigma * z);
}

function randomUniform(min: number, max: number): number {
    return min + Math.random() * (max - min);
}

function pickSeverity(distribution: string): string {
    const r = Math.random();
    switch (distribution) {
        case 'mostly-low':
            return r < 0.7 ? 'low' : r < 0.9 ? 'medium' : 'high';
        case 'mostly-high':
            return r < 0.2 ? 'low' : r < 0.5 ? 'medium' : 'high';
        case 'balanced':
        default:
            return r < 0.33 ? 'low' : r < 0.66 ? 'medium' : 'high';
    }
}

function isPeakHour(hour: number): boolean {
    return hour >= 10 && hour < 14;
}

// ── Main generator ───────────────────────────────────────────────────

/**
 * Generates all events for a simulation run in batch.
 * Returns the total number of events generated.
 *
 * @param runId - The simulation run ID
 * @param domainId - The domain ID
 * @param sourceModuleId - The generative module instance ID producing events
 * @param targetModuleIds - The business module instance IDs receiving events
 * @param generatorDefinitionId - The module definition ID (determines generator type)
 * @param config - The generator module's config values
 * @param fidelity - simplified or realistic
 * @param durationDays - Simulated duration in days
 */
export function generateEvents(
    runId: string,
    domainId: string,
    sourceModuleId: string,
    targetModuleIds: string[],
    generatorDefinitionId: string,
    config: GeneratorConfig,
    fidelity: SimulationFidelity,
    durationDays: number
): number {
    const events: EventInsert[] = [];

    // Base date for simulated timestamps (start of the simulated period)
    const baseDate = new Date();
    baseDate.setHours(0, 0, 0, 0);

    if (generatorDefinitionId === '08-customer-traffic-generator') {
        generateCustomerTrafficEvents(events, runId, domainId, sourceModuleId, targetModuleIds, config, fidelity, durationDays, baseDate);
    } else if (generatorDefinitionId === '09-scenario-driver') {
        generateScenarioEvents(events, runId, domainId, sourceModuleId, targetModuleIds, config, fidelity, durationDays, baseDate);
    }

    // Batch insert all events using a transaction
    const insert = db.prepare(`
        INSERT INTO simulation_events
            (id, run_id, domain_id, event_type, source_module_id, target_module_id, payload, simulated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    const insertAll = db.transaction((evts: EventInsert[]) => {
        for (const evt of evts) {
            insert.run(evt.id, evt.runId, evt.domainId, evt.eventType, evt.sourceModuleId, evt.targetModuleId, evt.payload, evt.simulatedAt);
        }
    });

    insertAll(events);
    return events.length;
}

// ── Customer Traffic Generator ───────────────────────────────────────

function generateCustomerTrafficEvents(
    events: EventInsert[],
    runId: string,
    domainId: string,
    sourceModuleId: string,
    targetModuleIds: string[],
    config: GeneratorConfig,
    fidelity: SimulationFidelity,
    durationDays: number,
    baseDate: Date
): void {
    const arrivalRate = config.arrivalRate ?? 10;
    const avgValue = config.avgTransactionValue ?? 50;
    const variance = config.transactionVariance ?? 0.3;
    const peakEnabled = config.peakHoursEnabled ?? false;

    for (let day = 0; day < durationDays; day++) {
        // Generate events for hours 7:00–21:00 (operational hours)
        for (let hour = 7; hour < 21; hour++) {
            let hourlyRate = arrivalRate;

            // Apply peak hour multiplier
            if (peakEnabled && isPeakHour(hour)) {
                hourlyRate = fidelity === 'realistic' ? arrivalRate * 1.5 : arrivalRate * 1.2;
            }

            // Determine number of arrivals this hour
            const arrivals = fidelity === 'realistic'
                ? randomPoisson(hourlyRate)
                : Math.round(hourlyRate + (Math.random() - 0.5) * 2);

            for (let i = 0; i < Math.max(0, arrivals); i++) {
                // Pick a random target module
                const targetId = targetModuleIds[Math.floor(Math.random() * targetModuleIds.length)];

                // Random minute within the hour
                const minute = Math.floor(Math.random() * 60);
                const simDate = new Date(baseDate);
                simDate.setDate(simDate.getDate() + day);
                simDate.setHours(hour, minute, Math.floor(Math.random() * 60));
                const simulatedAt = simDate.toISOString();

                // Customer arrival event
                events.push({
                    id: uuidv4(),
                    runId,
                    domainId,
                    eventType: 'customer_arrival',
                    sourceModuleId,
                    targetModuleId: targetId,
                    payload: JSON.stringify({
                        hour,
                        dayOfWeek: simDate.getDay(),
                        isPeak: peakEnabled && isPeakHour(hour)
                    }),
                    simulatedAt
                });

                // Transaction event (most arrivals lead to a transaction)
                const transactionProbability = fidelity === 'realistic' ? 0.85 : 0.95;
                if (Math.random() < transactionProbability) {
                    let amount: number;
                    if (fidelity === 'realistic') {
                        // Log-normal distribution for realistic variance
                        const sigma = variance * 1.5;
                        amount = randomLogNormal(avgValue, sigma);
                    } else {
                        // Uniform distribution for simplified
                        const spread = avgValue * variance;
                        amount = randomUniform(avgValue - spread, avgValue + spread);
                    }
                    amount = Math.round(amount * 100) / 100; // Round to 2 decimal places

                    events.push({
                        id: uuidv4(),
                        runId,
                        domainId,
                        eventType: 'transaction',
                        sourceModuleId,
                        targetModuleId: targetId,
                        payload: JSON.stringify({
                            amount,
                            currency: 'GBP',
                            hour,
                            isPeak: peakEnabled && isPeakHour(hour)
                        }),
                        simulatedAt
                    });
                }
            }
        }
    }
}

// ── Scenario Driver ──────────────────────────────────────────────────

function generateScenarioEvents(
    events: EventInsert[],
    runId: string,
    domainId: string,
    sourceModuleId: string,
    targetModuleIds: string[],
    config: GeneratorConfig,
    fidelity: SimulationFidelity,
    durationDays: number,
    baseDate: Date
): void {
    const issueFreq = config.issueFrequency ?? 2;
    const severityDist = config.severityDistribution ?? 'balanced';
    const resourcePressure = config.resourcePressure ?? 'normal';

    for (let day = 0; day < durationDays; day++) {
        // Issues for this day
        const issueCount = fidelity === 'realistic'
            ? randomPoisson(issueFreq)
            : Math.round(issueFreq + (Math.random() - 0.5));

        for (let i = 0; i < Math.max(0, issueCount); i++) {
            const targetId = targetModuleIds[Math.floor(Math.random() * targetModuleIds.length)];
            const hour = Math.floor(randomUniform(8, 18));
            const minute = Math.floor(Math.random() * 60);

            const simDate = new Date(baseDate);
            simDate.setDate(simDate.getDate() + day);
            simDate.setHours(hour, minute, Math.floor(Math.random() * 60));

            const severity = pickSeverity(severityDist);

            events.push({
                id: uuidv4(),
                runId,
                domainId,
                eventType: 'issue_raised',
                sourceModuleId,
                targetModuleId: targetId,
                payload: JSON.stringify({
                    severity,
                    category: severity === 'high' ? 'critical' : severity === 'medium' ? 'operational' : 'minor',
                    dayOfWeek: simDate.getDay()
                }),
                simulatedAt: simDate.toISOString()
            });
        }

        // Resource requests based on pressure level
        const baseRequests = resourcePressure === 'high' ? 4 : resourcePressure === 'normal' ? 2 : 1;
        const requestCount = fidelity === 'realistic'
            ? randomPoisson(baseRequests)
            : Math.round(baseRequests + (Math.random() - 0.5));

        for (let i = 0; i < Math.max(0, requestCount); i++) {
            const targetId = targetModuleIds[Math.floor(Math.random() * targetModuleIds.length)];
            const hour = Math.floor(randomUniform(8, 18));
            const minute = Math.floor(Math.random() * 60);

            const simDate = new Date(baseDate);
            simDate.setDate(simDate.getDate() + day);
            simDate.setHours(hour, minute, Math.floor(Math.random() * 60));

            const urgency = resourcePressure === 'high'
                ? (Math.random() < 0.4 ? 'urgent' : 'normal')
                : (Math.random() < 0.1 ? 'urgent' : 'normal');

            events.push({
                id: uuidv4(),
                runId,
                domainId,
                eventType: 'resource_request',
                sourceModuleId,
                targetModuleId: targetId,
                payload: JSON.stringify({
                    urgency,
                    resourceType: ['staff', 'equipment', 'space', 'budget'][Math.floor(Math.random() * 4)],
                    pressureLevel: resourcePressure
                }),
                simulatedAt: simDate.toISOString()
            });
        }
    }
}
