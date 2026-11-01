/**
 * @coffeeshop/shared — Re-exports from generated code and shared constants
 *
 * This package provides shared types, enums, the XState machine
 * definition, and workflow constants to both the Temporal worker
 * and the SvelteKit web application.
 */

// Domain types generated from SysML structural model
export * from './generated/types.js';

// XState machines generated from the SysML status axis declarations (S0.4):
// one per canonical runtime type, one parallel region per axis
export {
  orderAxesMachine,
  orderLineAxesMachine,
  type OrderAxisEvent,
  type OrderLineAxisEvent,
} from './generated/axis-machine.js';

// Axis guard and E6 cross-axis precondition evaluator, generated (S0.4)
export * from './generated/axis-guard.js';
export * from './generated/axis-preconditions.js';

// Workflow constants shared between Temporal and SvelteKit
export * from './workflow-constants.js';

// Re-export Phase D audit types explicitly for clarity
export type { WorkflowStepDef } from './workflow-constants.js';

// EHRbase CDR client — Phase B
export {
  createEhrbaseClient,
  DEFAULT_EHRBASE_CONFIG,
  EhrbaseError,
  type EhrbaseClient,
  type EhrbaseConfig,
  type EhrCreationResult,
  type CompositionCommitResult,
  type AqlResultSet,
} from './ehrbase-client.js';

// Order composition builder — Phase B
export {
  buildOrderComposition,
  ORDER_TEMPLATE_ID,
  type OrderCompositionInput,
} from './composition-builder.js';

// Feedback composition builder — Phase C
export {
  buildFeedbackComposition,
  FEEDBACK_TEMPLATE_ID,
  type FeedbackCompositionInput,
} from './feedback-composition-builder.js';

// Preparation composition builder — Phase D
export {
  buildPreparationComposition,
  PREPARATION_TEMPLATE_ID,
  type PreparationCompositionInput,
} from './preparation-composition-builder.js';

// PostgreSQL business database client — CSW Extension Phase 2 + Phase 3
export {
  createPostgresClient,
  DEFAULT_POSTGRES_CONFIG,
  PostgresClientError,
  type PostgresClient,
  type PostgresConfig,
  type MenuItemRow,
  type CatalogueEntryRow,
  type InventoryRecordRow,
  type CatalogueItemView,
  type InventoryItemView,
  type CreateMenuItemInput,
  type CreateCatalogueItemInput,
  type UpdateCatalogueEntryInput,
  type UpdateInventoryInput,
  type CatalogueLookupResult,
} from './postgres-client.js';
