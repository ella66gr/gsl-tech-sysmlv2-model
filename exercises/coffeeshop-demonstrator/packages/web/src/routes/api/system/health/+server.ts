/**
 * System Health API — CSW Extension Phase 9
 *
 * GET /api/system/health — Ping all three persistence layers and report status.
 *
 * Returns:
 *   {
 *     overall: 'healthy' | 'degraded' | 'unavailable',
 *     services: [{ service, status, responseTimeMs, detail? }],
 *     checkedAt: ISO timestamp
 *   }
 *
 * Each service is checked independently via Promise.all so a single
 * failure doesn't block reporting on the others.
 */

import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import { getPostgresClient } from '$lib/server/postgres';
import { getTemporalClient } from '$lib/server/temporal';
import { WORKFLOW_NAME } from '@coffeeshop/shared/dist/workflow-constants.js';

// ── Types ──

interface ServiceHealth {
  service: string;
  status: 'healthy' | 'degraded' | 'unavailable';
  responseTimeMs: number;
  detail?: string;
}

// ── Service checks ──

async function checkEhrbase(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const client = getEhrbaseClient();
    // Use a trivial AQL query as the health probe — exercises the full
    // CDR query path (connection, auth, AQL engine).
    await client.executeAql('SELECT e/ehr_id/value FROM EHR e LIMIT 1');
    return { service: 'EHRbase', status: 'healthy', responseTimeMs: Date.now() - start };
  } catch (err) {
    return {
      service: 'EHRbase',
      status: 'unavailable',
      responseTimeMs: Date.now() - start,
      detail: err instanceof Error ? err.message : 'Connection failed',
    };
  }
}

async function checkPostgres(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const db = getPostgresClient();
    await db.query('SELECT 1');
    return { service: 'PostgreSQL', status: 'healthy', responseTimeMs: Date.now() - start };
  } catch (err) {
    return {
      service: 'PostgreSQL',
      status: 'unavailable',
      responseTimeMs: Date.now() - start,
      detail: err instanceof Error ? err.message : 'Connection failed',
    };
  }
}

async function checkTemporal(): Promise<ServiceHealth> {
  const start = Date.now();
  try {
    const client = await getTemporalClient();
    // Minimal list operation — verifies gRPC connectivity to the Temporal server.
    const iterator = client.workflow.list({
      query: `WorkflowType = '${WORKFLOW_NAME}'`,
      pageSize: 1,
    });
    // Consume the first page to confirm the connection works.
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    for await (const _ of iterator) {
      break; // one result is enough
    }
    return { service: 'Temporal', status: 'healthy', responseTimeMs: Date.now() - start };
  } catch (err) {
    return {
      service: 'Temporal',
      status: 'unavailable',
      responseTimeMs: Date.now() - start,
      detail: err instanceof Error ? err.message : 'Connection failed',
    };
  }
}

// ── Route handler ──

export const GET: RequestHandler = async () => {
  const services = await Promise.all([
    checkEhrbase(),
    checkPostgres(),
    checkTemporal(),
  ]);

  const overall = services.every(s => s.status === 'healthy')
    ? 'healthy'
    : services.some(s => s.status === 'unavailable')
      ? 'unavailable'
      : 'degraded';

  return json({
    overall,
    services,
    checkedAt: new Date().toISOString(),
  });
};
