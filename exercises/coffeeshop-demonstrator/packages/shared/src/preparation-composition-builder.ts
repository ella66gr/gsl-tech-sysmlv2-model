/**
 * Preparation Composition Builder — CDR Exercise Phase D
 *
 * Builds canonical JSON compositions conforming to the
 * coffeeshop-preparation-composition.v1 template for commit to EHRbase.
 *
 * This composition records what happened during drink preparation.
 * The ACTION RM class includes an ism_transition element that tracks
 * the activity state machine (planned → active → completed).
 *
 * Archetype: openEHR-EHR-ACTION.preparation_event.v0
 * Template:  coffeeshop-preparation-composition.v1
 *
 * At-codes (from Archetype Designer):
 *   at0001 — Item tree (description root)
 *   at0002 — Preparation method (DV_CODED_TEXT)
 *   at0003 — Hot path (coded term)
 *   at0004 — Cold path (coded term)
 *   at0005 — Barista name (DV_TEXT)
 *   at0006 — Start time (DV_DATE_TIME)
 *   at0007 — End time (DV_DATE_TIME)
 *   at0008 — Preparation notes (DV_TEXT)
 */

// ── Template and archetype constants ──

export const PREPARATION_TEMPLATE_ID = 'coffeeshop-preparation-composition.v1';

const PREPARATION_COMPOSITION_ARCHETYPE_ID = 'openEHR-EHR-COMPOSITION.preparation_composition.v0';
const PREPARATION_ACTION_ARCHETYPE_ID = 'openEHR-EHR-ACTION.preparation_event.v0';

// ── Preparation method term mappings ──

interface CodedTerm {
  readonly code: string;
  readonly text: string;
}

const PREPARATION_METHOD_TERMS: Record<string, CodedTerm> = {
  'hot':  { code: 'at0003', text: 'Hot path' },
  'cold': { code: 'at0004', text: 'Cold path' },
};

// ── Input type ──

export interface PreparationCompositionInput {
  /** Preparation method: 'hot' or 'cold' */
  readonly method: 'hot' | 'cold';
  /** Name of the barista who prepared the drink */
  readonly baristaName: string;
  /** When preparation started (ISO 8601) */
  readonly startTime: string;
  /** When preparation finished (ISO 8601) */
  readonly endTime: string;
  /** Optional preparation notes */
  readonly notes?: string;
  /** Composer name for the composition */
  readonly composerName?: string;
}

// ── Helpers (same patterns as other composition builders) ──

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
 * Build a canonical JSON composition for a preparation event.
 *
 * The output conforms to the coffeeshop-preparation-composition.v1
 * template and can be committed directly to EHRbase.
 *
 * ACTION compositions include an ism_transition element that records
 * the activity state. We set this to "completed" since we're recording
 * preparation events after the fact.
 */
export function buildPreparationComposition(input: PreparationCompositionInput): Record<string, unknown> {
  const now = new Date().toISOString();

  // Resolve preparation method term
  const methodTerm = PREPARATION_METHOD_TERMS[input.method];
  if (!methodTerm) {
    throw new Error(`Invalid preparation method: ${input.method}. Must be 'hot' or 'cold'.`);
  }

  // Build the items array for the description ITEM_TREE
  const items: Array<Record<string, unknown>> = [
    {
      _type: 'ELEMENT',
      name: dvText('Preparation method'),
      archetype_node_id: 'at0002',
      value: codedText(methodTerm),
    },
    {
      _type: 'ELEMENT',
      name: dvText('Barista name'),
      archetype_node_id: 'at0005',
      value: dvText(input.baristaName),
    },
    {
      _type: 'ELEMENT',
      name: dvText('Start time'),
      archetype_node_id: 'at0006',
      value: dvDateTime(input.startTime),
    },
    {
      _type: 'ELEMENT',
      name: dvText('End time'),
      archetype_node_id: 'at0007',
      value: dvDateTime(input.endTime),
    },
  ];

  // Preparation notes is optional
  if (input.notes) {
    items.push({
      _type: 'ELEMENT',
      name: dvText('Preparation notes'),
      archetype_node_id: 'at0008',
      value: dvText(input.notes),
    });
  }

  // Assemble the full canonical JSON composition
  return {
    _type: 'COMPOSITION',
    name: dvText(PREPARATION_TEMPLATE_ID),
    archetype_details: {
      _type: 'ARCHETYPED',
      archetype_id: { _type: 'ARCHETYPE_ID', value: PREPARATION_COMPOSITION_ARCHETYPE_ID },
      template_id: { _type: 'TEMPLATE_ID', value: PREPARATION_TEMPLATE_ID },
      rm_version: '1.1.0',
    },
    archetype_node_id: PREPARATION_COMPOSITION_ARCHETYPE_ID,
    language: codePhrase('ISO_639-1', 'en'),
    territory: codePhrase('ISO_3166-1', 'GB'),
    category: {
      _type: 'DV_CODED_TEXT',
      value: 'event',
      defining_code: codePhrase('openehr', '433'),
    },
    composer: {
      _type: 'PARTY_IDENTIFIED',
      name: input.composerName ?? 'Barista System',
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
        _type: 'ACTION',
        name: dvText('preparation_event'),
        archetype_details: {
          _type: 'ARCHETYPED',
          archetype_id: { _type: 'ARCHETYPE_ID', value: PREPARATION_ACTION_ARCHETYPE_ID },
          rm_version: '1.1.0',
        },
        archetype_node_id: PREPARATION_ACTION_ARCHETYPE_ID,
        language: codePhrase('ISO_639-1', 'en'),
        encoding: codePhrase('IANA_character-sets', 'UTF-8'),
        subject: { _type: 'PARTY_SELF' },
        time: dvDateTime(input.endTime),
        ism_transition: {
          _type: 'ISM_TRANSITION',
          current_state: {
            _type: 'DV_CODED_TEXT',
            value: 'completed',
            defining_code: codePhrase('openehr', '532'),
          },
        },
        description: {
          _type: 'ITEM_TREE',
          name: dvText('Item tree'),
          archetype_node_id: 'at0001',
          items,
        },
      },
    ],
  };
}
