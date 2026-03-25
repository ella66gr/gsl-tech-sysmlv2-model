/**
 * Type definitions for the Relationships view (graph + table).
 *
 * Data source: model-introspection.json → weightedRelationshipGraph key.
 * Stage 4 Phase 1 — Session 72.
 */

import type * as d3 from 'd3';

export interface GraphNode {
  id: string;
  friendlyName: string;
  bmmConcern: string;
  classification: string;
  package: string;
  shortDescription: string;
}

export interface GraphEdge {
  source: string;
  target: string;
  strength: 'strong' | 'moderate' | 'weak' | 'contextual';
  rationale: string;
}

export interface GraphStats {
  nodeCount: number;
  edgeCount: number;
  strongCount: number;
  moderateCount: number;
  weakCount: number;
  bidirectionalPairCount: number;
}

export interface WeightedRelationshipGraph {
  nodes: GraphNode[];
  edges: GraphEdge[];
  stats: GraphStats;
}

/** D3 simulation node — extends GraphNode with force layout fields. */
export interface SimNode extends GraphNode, d3.SimulationNodeDatum {
  degree: number;
}

/** D3 simulation edge — extends d3 link datum with relationship metadata. */
export interface SimEdge extends d3.SimulationLinkDatum<SimNode> {
  strength: GraphEdge['strength'];
  rationale: string;
  isBidirectional?: boolean;
  curveDirection?: 1 | -1;
}
