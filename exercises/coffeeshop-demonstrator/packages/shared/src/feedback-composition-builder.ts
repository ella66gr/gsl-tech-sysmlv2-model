/**
 * Feedback Composition Builder — CDR Exercise Phase C
 *
 * Builds canonical JSON compositions conforming to the
 * coffeeshop-feedback-composition.v1 template for commit to EHRbase.
 *
 * This composition is committed by the feedback form (form-driven
 * data entry outside any workflow) — demonstrating that data can
 * enter the CDR from paths other than Temporal activities.
 *
 * Archetype: openEHR-EHR-EVALUATION.customer_feedback.v0
 * Template:  coffeeshop-feedback-composition.v1
 *
 * At-codes (from Archetype Designer):
 *   at0001 — Item tree (data root)
 *   at0002 — Rating (DV_CODED_TEXT)
 *   at0003 — Comment (DV_TEXT)
 *   at0004 — Order reference (DV_TEXT)
 *   at0005–at0009 — Rating values: 1 star through 5 stars
 */

// ── Template and archetype constants ──

export const FEEDBACK_TEMPLATE_ID = 'coffeeshop-feedback-composition.v1';

const FEEDBACK_COMPOSITION_ARCHETYPE_ID = 'openEHR-EHR-COMPOSITION.feedback_composition.v0';
const FEEDBACK_EVALUATION_ARCHETYPE_ID = 'openEHR-EHR-EVALUATION.customer_feedback.v0';

// ── Rating term mappings ──

interface CodedTerm {
  readonly code: string;
  readonly text: string;
}

const RATING_TERMS: Record<number, CodedTerm> = {
  1: { code: 'at0005', text: '1 star' },
  2: { code: 'at0006', text: '2 stars' },
  3: { code: 'at0007', text: '3 stars' },
  4: { code: 'at0008', text: '4 stars' },
  5: { code: 'at0009', text: '5 stars' },
};

// ── Input type ──

export interface FeedbackCompositionInput {
  /** Rating 1–5 */
  readonly rating: number;
  /** Free text comment */
  readonly comment?: string;
  /** Order reference (order ID or composition UID) */
  readonly orderReference?: string;
  /** Composer name — who submitted the feedback */
  readonly composerName?: string;
}

// ── Helpers (same patterns as composition-builder.ts) ──

function codedText(term: CodedTerm): Record<string, unknown> {
  return {
    _type: 'DV_CODED_TEXT',
    value: term.text,
    defining_code: {
      _type: 'CODE_PHRASE',
      terminology_id: {
        _type: 'TERMINOLOGY_ID',
        value: 'local',
      },
      code_string: term.code,
    },
  };
}

function dvText(value: string): Record<string, unknown> {
  return { _type: 'DV_TEXT', value };
}

function codePhrase(terminologyId: string, codeString: string): Record<string, unknown> {
  return {
    _type: 'CODE_PHRASE',
    terminology_id: { _type: 'TERMINOLOGY_ID', value: terminologyId },
    code_string: codeString,
  };
}

function dvDateTime(iso: string): Record<string, unknown> {
  return { _type: 'DV_DATE_TIME', value: iso };
}

// ── Builder ──

/**
 * Build a canonical JSON composition for customer feedback.
 *
 * The output conforms to the coffeeshop-feedback-composition.v1 template
 * and can be committed directly to EHRbase.
 */
export function buildFeedbackComposition(input: FeedbackCompositionInput): Record<string, unknown> {
  const now = new Date().toISOString();

  // Validate and resolve rating
  const ratingTerm = RATING_TERMS[input.rating];
  if (!ratingTerm) {
    throw new Error(`Invalid rating: ${input.rating}. Must be 1–5.`);
  }

  // Build items array for the ITEM_TREE
  const items: Array<Record<string, unknown>> = [
    {
      _type: 'ELEMENT',
      name: dvText('Rating'),
      archetype_node_id: 'at0002',
      value: codedText(ratingTerm),
    },
  ];

  // Comment is optional
  if (input.comment) {
    items.push({
      _type: 'ELEMENT',
      name: dvText('Comment'),
      archetype_node_id: 'at0003',
      value: dvText(input.comment),
    });
  }

  // Order reference is optional
  if (input.orderReference) {
    items.push({
      _type: 'ELEMENT',
      name: dvText('Order reference'),
      archetype_node_id: 'at0004',
      value: dvText(input.orderReference),
    });
  }

  // Assemble the full canonical JSON composition
  return {
    _type: 'COMPOSITION',
    name: dvText(FEEDBACK_TEMPLATE_ID),
    archetype_details: {
      _type: 'ARCHETYPED',
      archetype_id: { _type: 'ARCHETYPE_ID', value: FEEDBACK_COMPOSITION_ARCHETYPE_ID },
      template_id: { _type: 'TEMPLATE_ID', value: FEEDBACK_TEMPLATE_ID },
      rm_version: '1.1.0',
    },
    archetype_node_id: FEEDBACK_COMPOSITION_ARCHETYPE_ID,
    language: codePhrase('ISO_639-1', 'en'),
    territory: codePhrase('ISO_3166-1', 'GB'),
    category: {
      _type: 'DV_CODED_TEXT',
      value: 'event',
      defining_code: codePhrase('openehr', '433'),
    },
    composer: {
      _type: 'PARTY_IDENTIFIED',
      name: input.composerName ?? 'Customer',
    },
    context: {
      _type: 'EVENT_CONTEXT',
      start_time: dvDateTime(now),
      setting: {
        _type: 'DV_CODED_TEXT',
        value: 'other care',
        defining_code: codePhrase('openehr', '238'),
      },
    },
    content: [
      {
        _type: 'EVALUATION',
        name: dvText('customer_feedback'),
        archetype_details: {
          _type: 'ARCHETYPED',
          archetype_id: { _type: 'ARCHETYPE_ID', value: FEEDBACK_EVALUATION_ARCHETYPE_ID },
          rm_version: '1.1.0',
        },
        archetype_node_id: FEEDBACK_EVALUATION_ARCHETYPE_ID,
        language: codePhrase('ISO_639-1', 'en'),
        encoding: codePhrase('IANA_character-sets', 'UTF-8'),
        subject: { _type: 'PARTY_SELF' },
        data: {
          _type: 'ITEM_TREE',
          name: dvText('Item tree'),
          archetype_node_id: 'at0001',
          items,
        },
      },
    ],
  };
}
