/**
 * PostgreSQL Business Database Client — server-side only
 *
 * Provides a singleton PostgreSQL client for use by SvelteKit API routes.
 * The $lib/server/ directory ensures SvelteKit never bundles this into
 * client-side code.
 *
 * CSW Extension Phase 2: Catalogue and inventory queries.
 */

import { createPostgresClient, type PostgresClient } from '@coffeeshop/shared';

let client: PostgresClient | null = null;

export function getPostgresClient(): PostgresClient {
  if (!client) {
    client = createPostgresClient();
  }
  return client;
}
