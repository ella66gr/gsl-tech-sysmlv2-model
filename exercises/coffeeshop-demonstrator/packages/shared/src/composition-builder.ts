/**
 * Order Composition Builder — CDR Exercise Phase B
 *
 * Builds canonical JSON compositions conforming to the
 * coffeeshop-order-composition.v1 template for commit to EHRbase.
 *
 * The coded term text must match EXACTLY what is defined in the
 * archetype terminology — EHRbase validates DV_CODED_TEXT values
 * against term definitions and rejects mismatches.
 * (Lesson from Phase A: "Oak milk" vs "Oat milk" typo.)
 *
 * Archetype: openEHR-EHR-OBSERVATION.order_record.v0
 * Template:  coffeeshop-order-composition.v1
 */

import type { MilkOption } from './generated/types.js';

// ── Template and archetype constants ──

export const ORDER_TEMPLATE_ID = 'coffeeshop-order-composition.v1';

const COMPOSITION_ARCHETYPE_ID = 'openEHR-EHR-COMPOSITION.order_composition.v0';
const OBSERVATION_ARCHETYPE_ID = 'openEHR-EHR-OBSERVATION.order_record.v0';

// ── Archetype term mappings ──
//
// These map from application-level values to the archetype's internal
// coded terminology. The display text must match the archetype term
// definitions exactly.

interface CodedTerm {
  readonly code: string;
  readonly text: string;
}

/** Drink name: at0005, coded values at0010/at0011 */
const DRINK_NAME_TERMS: Record<string, CodedTerm> = {
  'coffee':     { code: 'at0010', text: 'Coffee' },
  'Coffee':     { code: 'at0010', text: 'Coffee' },
  'tea':        { code: 'at0011', text: 'Tea' },
  'Tea':        { code: 'at0011', text: 'Tea' },
  // Common drink type strings from the existing workflow
  'flat white': { code: 'at0010', text: 'Coffee' },
  'latte':      { code: 'at0010', text: 'Coffee' },
  'espresso':   { code: 'at0010', text: 'Coffee' },
  'americano':  { code: 'at0010', text: 'Coffee' },
  'cappuccino': { code: 'at0010', text: 'Coffee' },
};

/** Drink size: at0006, coded values at0007/at0008/at0009 */
const DRINK_SIZE_TERMS: Record<string, CodedTerm> = {
  'small':  { code: 'at0007', text: 'Small' },
  'medium': { code: 'at0008', text: 'Medium' },
  'large':  { code: 'at0009', text: 'Large' },
};

/** Milk choice: at0012, coded values at0013–at0017 */
const MILK_CHOICE_TERMS: Record<string, CodedTerm> = {
  'none':  { code: 'at0013', text: 'None' },
  'whole': { code: 'at0014', text: 'Whole milk' },
  'semi':  { code: 'at0015', text: 'Semi-skimmed milk' },
  'oat':   { code: 'at0016', text: 'Oat milk' },
  'soy':   { code: 'at0017', text: 'Soy milk' },
};

/**
 * Price: at0019, coded values at0020–at0023
 * Maps from size to price — in this exercise, price is determined by size.
 *
 * TODO Phase 10: CDR order archetype uses these coded price terms which
 * don't match catalogue prices (e.g. Flat White is £2.80 in catalogue but
 * size-based here at £1.75 medium). The catalogue (PostgreSQL) is the
 * authoritative price source. The CDR records an approximate price bracket.
 * Resolution: update the archetype to accept DV_QUANTITY with currency,
 * or add new coded terms matching the full price list.
 */
const PRICE_BY_SIZE: Record<string, CodedTerm> = {
  'small':  { code: 'at0020', text: '£1.25' },
  'medium': { code: 'at0021', text: '£1.75' },
  'large':  { code: 'at0022', text: '£2.30' },
};

/**
 * Special price for extras (e.g. large + extra shot = £2.85).
 * The archetype has at0023 = £2.85 as the highest price point.
 */
const PRICE_PREMIUM: CodedTerm = { code: 'at0023', text: '£2.85' };

// ── Input type ──

/**
 * Extended order details for composition building.
 * The base fields (orderId, customerName, drinkType, size) match the
 * existing OrderDetails interface in barista.ts. New fields are optional
 * for backward compatibility.
 */
export interface OrderCompositionInput {
  readonly orderId: string;
  readonly customerName: string;
  readonly drinkType: string;
  readonly size: 'small' | 'medium' | 'large';
  readonly milkChoice?: MilkOption | string;
  readonly extras?: string;
  readonly composerName?: string;
}

// ── Helpers ──

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
 * Build a canonical JSON composition for an order record.
 *
 * The output conforms to the coffeeshop-order-composition.v1 template
 * and can be committed directly to EHRbase via the composition API.
 */
export function buildOrderComposition(input: OrderCompositionInput): Record<string, unknown> {
  const now = new Date().toISOString();

  // Resolve coded terms from input values
  const drinkTerm = DRINK_NAME_TERMS[input.drinkType.toLowerCase()]
    ?? DRINK_NAME_TERMS['coffee']!;
  const sizeTerm = DRINK_SIZE_TERMS[input.size]!;
  const milkTerm = MILK_CHOICE_TERMS[input.milkChoice ?? 'none']
    ?? MILK_CHOICE_TERMS['none']!;

  // Price: use premium price if extras specified, otherwise by size
  const priceTerm = input.extras
    ? PRICE_PREMIUM
    : (PRICE_BY_SIZE[input.size] ?? PRICE_BY_SIZE['medium']!);

  // Build the items array for the ITEM_TREE
  const items: Array<Record<string, unknown>> = [
    {
      _type: 'ELEMENT',
      name: dvText('Drink name'),
      archetype_node_id: 'at0005',
      value: codedText(drinkTerm),
    },
    {
      _type: 'ELEMENT',
      name: dvText('Drink size'),
      archetype_node_id: 'at0006',
      value: codedText(sizeTerm),
    },
    {
      _type: 'ELEMENT',
      name: dvText('Milk choice'),
      archetype_node_id: 'at0012',
      value: codedText(milkTerm),
    },
  ];

  // Extras is optional free text (DV_TEXT, not coded)
  if (input.extras) {
    items.push({
      _type: 'ELEMENT',
      name: dvText('Extras'),
      archetype_node_id: 'at0018',
      value: dvText(input.extras),
    });
  }

  // Price
  items.push({
    _type: 'ELEMENT',
    name: dvText('Price'),
    archetype_node_id: 'at0019',
    value: codedText(priceTerm),
  });

  // Assemble the full canonical JSON composition
  return {
    _type: 'COMPOSITION',
    name: dvText(ORDER_TEMPLATE_ID),
    archetype_details: {
      _type: 'ARCHETYPED',
      archetype_id: { _type: 'ARCHETYPE_ID', value: COMPOSITION_ARCHETYPE_ID },
      template_id: { _type: 'TEMPLATE_ID', value: ORDER_TEMPLATE_ID },
      rm_version: '1.1.0',
    },
    archetype_node_id: COMPOSITION_ARCHETYPE_ID,
    language: codePhrase('ISO_639-1', 'en'),
    territory: codePhrase('ISO_3166-1', 'GB'),
    category: {
      _type: 'DV_CODED_TEXT',
      value: 'event',
      defining_code: codePhrase('openehr', '433'),
    },
    composer: {
      _type: 'PARTY_IDENTIFIED',
      name: input.composerName ?? 'System',
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
        _type: 'OBSERVATION',
        name: dvText('order_record'),
        archetype_details: {
          _type: 'ARCHETYPED',
          archetype_id: { _type: 'ARCHETYPE_ID', value: OBSERVATION_ARCHETYPE_ID },
          rm_version: '1.1.0',
        },
        archetype_node_id: OBSERVATION_ARCHETYPE_ID,
        language: codePhrase('ISO_639-1', 'en'),
        encoding: codePhrase('IANA_character-sets', 'UTF-8'),
        subject: { _type: 'PARTY_SELF' },
        data: {
          _type: 'HISTORY',
          name: dvText('History'),
          archetype_node_id: 'at0001',
          origin: dvDateTime(now),
          events: [
            {
              _type: 'POINT_EVENT',
              name: dvText('Any event'),
              archetype_node_id: 'at0002',
              time: dvDateTime(now),
              data: {
                _type: 'ITEM_TREE',
                name: dvText('Tree'),
                archetype_node_id: 'at0003',
                items,
              },
            },
          ],
        },
      },
    ],
  };
}
