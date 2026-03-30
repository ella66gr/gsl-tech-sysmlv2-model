/**
 * Shared BMM concern colour mapping.
 *
 * Used by the graph component (node fills, edge colours) and the table
 * component (concern and strength badges) for visual consistency.
 *
 * Stage 4 Phase 1 — Session 72.
 */

/** Known concern colours — dark-mode-friendly palette. */
const CONCERN_COLOURS: Record<string, string> = {
  ServiceConcept: '#3b82f6',     // blue-500
  ActivityModel: '#10b981',      // emerald-500
  ResourceCapability: '#f59e0b', // amber-500
  FinancialModel: '#a855f7',     // purple-500
  Governance: '#f43f5e',         // rose-500
  StakeholderModel: '#06b6d4',   // cyan-500
};

/** Reserve palette for concerns not in the known set. */
const RESERVE_COLOURS = [
  '#06b6d4', // cyan-500
  '#ec4899', // pink-500
  '#84cc16', // lime-500
  '#f97316', // orange-500
  '#6366f1', // indigo-500
];

const dynamicMap = new Map<string, string>();

/**
 * Returns a hex colour for the given BMM concern name.
 * Deterministic — same concern always maps to the same colour.
 * Falls back through a reserve palette, then to neutral grey.
 */
export function getConcernColour(concern: string): string {
  if (CONCERN_COLOURS[concern]) {
    return CONCERN_COLOURS[concern];
  }
  if (dynamicMap.has(concern)) {
    return dynamicMap.get(concern)!;
  }
  const idx = dynamicMap.size;
  const colour = idx < RESERVE_COLOURS.length ? RESERVE_COLOURS[idx] : '#6b7280';
  dynamicMap.set(concern, colour);
  return colour;
}

/** Strength styling configuration for edges and badges. */
export const STRENGTH_STYLES: Record<string, { width: number; opacity: number; label: string }> = {
  strong: { width: 3, opacity: 0.9, label: 'Strong' },
  moderate: { width: 2, opacity: 0.6, label: 'Moderate' },
  weak: { width: 1, opacity: 0.35, label: 'Weak' },
  contextual: { width: 1, opacity: 0.25, label: 'Contextual' },
};

/** Strength badge colour (Flowbite badge colour names). */
export function getStrengthBadgeColour(strength: string): string {
  const map: Record<string, string> = {
    strong: 'red',
    moderate: 'yellow',
    weak: 'blue',
    contextual: 'dark',
  };
  return map[strength] || 'dark';
}

/** Concern badge colour (Flowbite badge colour names). */
export function getConcernBadgeColour(concern: string): string {
  const map: Record<string, string> = {
    ServiceConcept: 'blue',
    ActivityModel: 'green',
    ResourceCapability: 'yellow',
    FinancialModel: 'purple',
    Governance: 'red',
    StakeholderModel: 'indigo',
  };
  return map[concern] || 'dark';
}
