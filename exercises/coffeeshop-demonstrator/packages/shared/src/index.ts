/**
 * @coffeeshop/shared — Re-exports from generated code and shared constants
 *
 * This package provides shared types, enums, the XState machine
 * definition, and workflow constants to both the Temporal worker
 * and the SvelteKit web application.
 */

// Domain types generated from SysML structural model
export * from './generated/types.js';

// XState order lifecycle machine generated from SysML state def
export {
  orderLifecycleMachine,
  type OrderEvent,
  type OrderState,
} from './generated/order-lifecycle-machine.js';

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

// Composition builders — Phase B
export {
  buildOrderComposition,
  ORDER_TEMPLATE_ID,
  type OrderCompositionInput,
} from './composition-builder.js';
