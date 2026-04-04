/** A single entry in the navigation stack */
export interface NavigationEntry {
  /** Unique ID for this entry (crypto.randomUUID()) */
  id: string;
  /** SvelteKit route path, e.g. '/glossary' */
  route: string;
  /** Human-readable label for breadcrumb, e.g. 'Glossary: ServiceOffering' */
  label: string;
  /** Optional: the semantic relationship traversed to reach this entry */
  relationship?: string;
  /** ISO timestamp */
  timestamp: string;
  /** Route-specific state snapshot, opaque to the store */
  pageState?: Record<string, unknown>;
}

/** Callback contract between a route and the store */
export interface PageStateContract {
  /** Called by the store to capture current page state before navigating away */
  captureState: () => Record<string, unknown>;
  /** Called by the store to restore state when navigating back to this page */
  restoreState: (state: Record<string, unknown>) => void;
}

/** Journey export format */
export interface JourneyExport {
  startTime: string;
  exportTime: string;
  steps: {
    label: string;
    route: string;
    relationship?: string;
    timestamp: string;
  }[];
}
