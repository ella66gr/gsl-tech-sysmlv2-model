/**
 * AQL Queries — CDR Exercise Phase C
 *
 * Centralised AQL query definitions for entity-view endpoints.
 * Each query retrieves data organised by type (entity view) rather
 * than by process (Temporal view).
 *
 * AQL path structure follows the RM hierarchy using archetype node IDs:
 *   COMPOSITION → content[archetype] → data[at0001] → events[at0002]
 *     → data[at0003] → items[atNNNN] → /value/value (display text)
 *                                    → /value/defining_code/code_string (at-code)
 *
 * Archetype: openEHR-EHR-OBSERVATION.order_record.v0
 * Template:  coffeeshop-order-composition.v1
 *
 * Phase C finding: EHRbase 2.11.0 does NOT support AQL aggregate
 * functions (COUNT, GROUP BY). Aggregate queries return HTTP 400.
 * Aggregation must be done application-side. This is noted in the
 * session report as an implication for GenderSense — population-level
 * analytics queries may need application-level aggregation rather
 * than pure AQL.
 */

// ── Archetype and composition constants ──

const ORDER_OBSERVATION = 'openEHR-EHR-OBSERVATION.order_record.v0';
const ORDER_COMPOSITION = 'openEHR-EHR-COMPOSITION.order_composition.v0';

/** Base AQL path into the ORDER_RECORD data items */
const ORDER_DATA_PATH =
  `c/content[${ORDER_OBSERVATION}]/data[at0001]/events[at0002]/data[at0003]`;

// Export constants for use by other modules (e.g. comparison endpoint)
export { ORDER_OBSERVATION, ORDER_COMPOSITION, ORDER_DATA_PATH };

// ── Query definitions ──

/**
 * All orders for a specific customer (by EHR ID).
 * Returns: composition UID, order time, drink name, size, milk, extras, price.
 *
 * Clinical analogy: "All lab results for this patient."
 */
export function allOrdersForCustomerAql(ehrId: string): string {
  return `
    SELECT
      c/uid/value as composition_uid,
      c/context/start_time/value as order_time,
      ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
      ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
      ${ORDER_DATA_PATH}/items[at0012]/value/value as milk_choice,
      ${ORDER_DATA_PATH}/items[at0018]/value/value as extras,
      ${ORDER_DATA_PATH}/items[at0019]/value/value as price
    FROM EHR e
    CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
    WHERE e/ehr_id/value = '${ehrId}'
    ORDER BY c/context/start_time/value DESC
  `;
}

/**
 * All orders across all customers, with customer EHR ID.
 * Returns: ehr_id, composition UID, order time, drink name, size, milk, price.
 *
 * Clinical analogy: "All consultations across all patients."
 */
export function allOrdersAql(): string {
  return `
    SELECT
      e/ehr_id/value as ehr_id,
      c/uid/value as composition_uid,
      c/context/start_time/value as order_time,
      ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
      ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
      ${ORDER_DATA_PATH}/items[at0012]/value/value as milk_choice,
      ${ORDER_DATA_PATH}/items[at0019]/value/value as price
    FROM EHR e
    CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
    ORDER BY c/context/start_time/value DESC
  `;
}

/**
 * Orders placed today (across all customers).
 * Uses a date filter on the composition context start_time.
 *
 * Clinical analogy: "All consultations today."
 */
export function ordersPlacedTodayAql(todayIso: string): string {
  return `
    SELECT
      e/ehr_id/value as ehr_id,
      c/uid/value as composition_uid,
      c/context/start_time/value as order_time,
      ${ORDER_DATA_PATH}/items[at0005]/value/value as drink_name,
      ${ORDER_DATA_PATH}/items[at0006]/value/value as drink_size,
      ${ORDER_DATA_PATH}/items[at0019]/value/value as price
    FROM EHR e
    CONTAINS COMPOSITION c[${ORDER_COMPOSITION}]
    WHERE c/context/start_time/value >= '${todayIso}'
    ORDER BY c/context/start_time/value DESC
  `;
}
