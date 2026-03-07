/**
 * POST /api/entity/feedback — Submit customer feedback (form-driven)
 * GET  /api/entity/feedback — List all feedback (entity view)
 *
 * POST: Commits a feedback composition directly to EHRbase.
 * No Temporal involvement — this is form-driven data entry
 * outside any workflow, demonstrating that data can enter the
 * CDR from paths other than workflow activities.
 *
 * GET: Queries the CDR for all feedback compositions across
 * all customers — the feedback entity view.
 *
 * Clinical analogy (POST): A patient completing a PROM questionnaire
 * at any time, outside any scheduled pathway step.
 * Clinical analogy (GET): "Show me all patient satisfaction scores."
 *
 * Phase C, Step C3.
 */

import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getEhrbaseClient } from '$lib/server/ehrbase';
import {
  buildFeedbackComposition,
  FEEDBACK_TEMPLATE_ID,
} from '@coffeeshop/shared';

// ── POST: Submit feedback ──

export const POST: RequestHandler = async ({ request }) => {
  let body: {
    customerName?: string;
    rating?: number;
    comment?: string;
    orderReference?: string;
  };

  try {
    body = await request.json();
  } catch {
    throw error(400, 'Invalid JSON body');
  }

  const { customerName, rating, comment, orderReference } = body;

  if (!customerName) {
    throw error(400, 'Missing required field: customerName');
  }
  if (rating === undefined || rating < 1 || rating > 5) {
    throw error(400, 'Rating must be between 1 and 5');
  }

  const client = getEhrbaseClient();

  try {
    // 1. Get or create EHR for this customer
    const { ehrId } = await client.getOrCreateEhr(customerName);

    // 2. Build the feedback composition
    const composition = buildFeedbackComposition({
      rating,
      ...(comment !== undefined && { comment }),
      ...(orderReference !== undefined && { orderReference }),
      composerName: customerName,
    });

    // 3. Commit directly to EHRbase — no Temporal, no workflow
    const { compositionUid } = await client.commitComposition(
      ehrId,
      FEEDBACK_TEMPLATE_ID,
      composition,
    );

    return json({
      success: true,
      ehrId,
      compositionUid,
      message: 'Feedback submitted directly to CDR (no workflow involved)',
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Failed to submit feedback: ${message}`);
  }
};

// ── GET: List all feedback ──

const FEEDBACK_EVALUATION = 'openEHR-EHR-EVALUATION.customer_feedback.v0';
const FEEDBACK_COMPOSITION = 'openEHR-EHR-COMPOSITION.feedback_composition.v0';

export const GET: RequestHandler = async () => {
  const client = getEhrbaseClient();

  const aql = `
    SELECT
      e/ehr_id/value as ehr_id,
      c/uid/value as composition_uid,
      c/context/start_time/value as feedback_time,
      c/content[${FEEDBACK_EVALUATION}]/data[at0001]/items[at0002]/value/value as rating,
      c/content[${FEEDBACK_EVALUATION}]/data[at0001]/items[at0003]/value/value as comment,
      c/content[${FEEDBACK_EVALUATION}]/data[at0001]/items[at0004]/value/value as order_reference
    FROM EHR e
    CONTAINS COMPOSITION c[${FEEDBACK_COMPOSITION}]
    ORDER BY c/context/start_time/value DESC
  `;

  try {
    const result = await client.executeAql(aql);

    const feedback = result.rows.map((row) => ({
      ehrId: row[0] as string,
      compositionUid: row[1] as string,
      feedbackTime: row[2] as string,
      rating: row[3] as string,
      comment: (row[4] as string) ?? null,
      orderReference: (row[5] as string) ?? null,
    }));

    return json({
      view: 'entity',
      source: 'CDR (EHRbase)',
      count: feedback.length,
      feedback,
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    throw error(500, `Feedback entity view query failed: ${message}`);
  }
};
