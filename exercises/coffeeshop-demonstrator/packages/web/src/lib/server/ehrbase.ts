/**
 * EHRbase Client — server-side only
 *
 * Provides a singleton EHRbase client for use by SvelteKit API routes.
 * The $lib/server/ directory ensures SvelteKit never bundles this into
 * client-side code.
 *
 * Phase C: Entity-view endpoints query the CDR via this client.
 */

import { createEhrbaseClient, type EhrbaseClient } from '@coffeeshop/shared';

let client: EhrbaseClient | null = null;

export function getEhrbaseClient(): EhrbaseClient {
  if (!client) {
    client = createEhrbaseClient();
  }
  return client;
}
