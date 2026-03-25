<script lang="ts">
  import { onMount } from 'svelte';
  import * as d3 from 'd3';
  import type { WeightedRelationshipGraph, SimNode, SimEdge } from '$lib/types/relationships';
  import { getConcernColour, STRENGTH_STYLES } from '$lib/utils/colours';

  interface Props {
    graph: WeightedRelationshipGraph;
    concernFilter: string;
    strengthFilter: string;
    searchText: string;
    selectedNodeId: string | null;
    onNodeSelect: (nodeId: string) => void;
  }

  let {
    graph,
    concernFilter,
    strengthFilter,
    searchText,
    selectedNodeId,
    onNodeSelect,
  }: Props = $props();

  let svgEl: SVGSVGElement;
  let containerEl: HTMLDivElement;

  // Simulation state
  let simNodes = $state<SimNode[]>([]);
  let simEdges = $state<SimEdge[]>([]);
  let transform = $state({ x: 0, y: 0, k: 1 });
  let hoveredNodeId = $state<string | null>(null);
  let hoveredEdgeIdx = $state<number | null>(null);
  let simulation: d3.Simulation<SimNode, SimEdge> | null = null;
  let viewBox = $state('0 0 800 600');

  // Taper half-widths by strength (at the source/base end)
  const TAPER_HALF_WIDTH: Record<string, number> = {
    strong: 9,
    moderate: 5,
    weak: 2,
    contextual: 1.5,
  };

  // Bezier curve sampling resolution
  const CURVE_SAMPLES = 16;

  // Compute degree for each node
  function computeDegrees(nodes: SimNode[], edges: SimEdge[]): void {
    const degreeMap = new Map<string, number>();
    for (const edge of edges) {
      const src = typeof edge.source === 'string' ? edge.source : (edge.source as SimNode).id;
      const tgt = typeof edge.target === 'string' ? edge.target : (edge.target as SimNode).id;
      degreeMap.set(src, (degreeMap.get(src) || 0) + 1);
      degreeMap.set(tgt, (degreeMap.get(tgt) || 0) + 1);
    }
    for (const node of nodes) {
      node.degree = degreeMap.get(node.id) || 0;
    }
  }

  // Mark bidirectional edges and assign curve directions
  function markBidirectional(edges: SimEdge[]): void {
    const edgeSet = new Set<string>();
    for (const e of edges) {
      const src = typeof e.source === 'string' ? e.source : (e.source as SimNode).id;
      const tgt = typeof e.target === 'string' ? e.target : (e.target as SimNode).id;
      edgeSet.add(`${src}->${tgt}`);
    }
    for (const e of edges) {
      const src = typeof e.source === 'string' ? e.source : (e.source as SimNode).id;
      const tgt = typeof e.target === 'string' ? e.target : (e.target as SimNode).id;
      if (edgeSet.has(`${tgt}->${src}`)) {
        e.isBidirectional = true;
        e.curveDirection = src < tgt ? 1 : -1;
      } else {
        e.isBidirectional = false;
        e.curveDirection = undefined;
      }
    }
  }

  // Radius scale
  const radiusScale = $derived(
    d3.scaleSqrt()
      .domain([0, d3.max(simNodes, (n) => n.degree) || 1])
      .range([8, 28])
  );

  // Font size scale
  function fontSize(degree: number): number {
    return Math.max(9, Math.min(13, 8 + degree * 0.4));
  }

  // Compute viewBox from node positions with generous padding
  function computeViewBox(nodes: SimNode[]): string {
    if (nodes.length === 0) return '0 0 800 600';
    const padding = 100;
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (const n of nodes) {
      const r = radiusScale(n.degree);
      const labelExtra = 20;
      if (n.x !== undefined && n.y !== undefined) {
        minX = Math.min(minX, n.x - r);
        minY = Math.min(minY, n.y - r);
        maxX = Math.max(maxX, n.x + r);
        maxY = Math.max(maxY, n.y + r + labelExtra);
      }
    }
    return `${minX - padding} ${minY - padding} ${maxX - minX + padding * 2} ${maxY - minY + padding * 2}`;
  }

  // --- Bezier helpers ---

  /** Evaluate quadratic bezier at parameter t. */
  function quadBezier(
    p0x: number, p0y: number,
    cpx: number, cpy: number,
    p1x: number, p1y: number,
    t: number
  ): [number, number] {
    const mt = 1 - t;
    return [
      mt * mt * p0x + 2 * mt * t * cpx + t * t * p1x,
      mt * mt * p0y + 2 * mt * t * cpy + t * t * p1y,
    ];
  }

  /** Tangent of quadratic bezier at parameter t. Returns unit vector. */
  function quadBezierTangent(
    p0x: number, p0y: number,
    cpx: number, cpy: number,
    p1x: number, p1y: number,
    t: number
  ): [number, number] {
    const dx = 2 * (1 - t) * (cpx - p0x) + 2 * t * (p1x - cpx);
    const dy = 2 * (1 - t) * (cpy - p0y) + 2 * t * (p1y - cpy);
    const len = Math.sqrt(dx * dx + dy * dy) || 1;
    return [dx / len, dy / len];
  }

  // --- Tapered edge path generators ---

  /** Straight taper for unidirectional edges. */
  function straightTaperPath(e: SimEdge): string {
    const src = e.source as SimNode;
    const tgt = e.target as SimNode;
    if (src.x == null || src.y == null || tgt.x == null || tgt.y == null) return '';

    const srcR = radiusScale(src.degree);
    const tgtR = radiusScale(tgt.degree);
    const halfW = TAPER_HALF_WIDTH[e.strength] || TAPER_HALF_WIDTH.moderate;

    const dx = tgt.x - src.x;
    const dy = tgt.y - src.y;
    const dist = Math.sqrt(dx * dx + dy * dy) || 1;
    const ux = dx / dist;
    const uy = dy / dist;
    const px = -uy;
    const py = ux;

    // Boundary points
    const srcBx = src.x + ux * srcR;
    const srcBy = src.y + uy * srcR;
    const tgtBx = tgt.x - ux * tgtR;
    const tgtBy = tgt.y - uy * tgtR;

    // Base corners at source
    const s1x = srcBx + px * halfW;
    const s1y = srcBy + py * halfW;
    const s2x = srcBx - px * halfW;
    const s2y = srcBy - py * halfW;

    return `M${s1x},${s1y} L${tgtBx},${tgtBy} L${s2x},${s2y} Z`;
  }

  /**
   * Curved taper for bidirectional edges.
   * Samples points along a quadratic bezier and builds a polygon outline
   * with width tapering from halfW at source to 0 at target.
   */
  function curvedTaperPath(e: SimEdge): string {
    const src = e.source as SimNode;
    const tgt = e.target as SimNode;
    if (src.x == null || src.y == null || tgt.x == null || tgt.y == null) return '';

    const srcR = radiusScale(src.degree);
    const tgtR = radiusScale(tgt.degree);
    const halfW = TAPER_HALF_WIDTH[e.strength] || TAPER_HALF_WIDTH.moderate;
    const dir = e.curveDirection || 1;

    const dx = tgt.x - src.x;
    const dy = tgt.y - src.y;
    const dist = Math.sqrt(dx * dx + dy * dy) || 1;
    const ux = dx / dist;
    const uy = dy / dist;
    // Perpendicular
    const px = -uy;
    const py = ux;

    // Curve offset — enough to separate bidirectional pairs
    const curveOffset = Math.max(20, dist * 0.18) * dir;

    // Control point: midpoint offset perpendicular
    const cpx = (src.x + tgt.x) / 2 + px * curveOffset;
    const cpy = (src.y + tgt.y) / 2 + py * curveOffset;

    // Find boundary start/end by computing the bezier direction at t=0 and t=1
    // and offsetting from node centres along those directions
    const [t0x, t0y] = quadBezierTangent(src.x, src.y, cpx, cpy, tgt.x, tgt.y, 0);
    const [t1x, t1y] = quadBezierTangent(src.x, src.y, cpx, cpy, tgt.x, tgt.y, 1);

    // Start point: source centre + tangent * srcR
    const startX = src.x + t0x * srcR;
    const startY = src.y + t0y * srcR;
    // End point: target centre - tangent * tgtR (tangent at t=1 points away from target)
    const endX = tgt.x - t1x * tgtR;
    const endY = tgt.y - t1y * tgtR;

    // Remap: we need to find the t-parameters corresponding to start and end
    // For simplicity, compute the fraction of the total bezier length consumed by the radii
    // and use that as t_start and t_end
    const bezierLen = approximateBezierLength(src.x, src.y, cpx, cpy, tgt.x, tgt.y);
    const tStart = Math.min(0.15, srcR / bezierLen);
    const tEnd = Math.max(0.85, 1 - tgtR / bezierLen);

    // Sample the centreline between tStart and tEnd
    const n = CURVE_SAMPLES;
    const leftPoints: string[] = [];
    const rightPoints: string[] = [];

    for (let i = 0; i <= n; i++) {
      const t = tStart + (tEnd - tStart) * (i / n);
      const [bx, by] = quadBezier(src.x, src.y, cpx, cpy, tgt.x, tgt.y, t);
      const [tx, ty] = quadBezierTangent(src.x, src.y, cpx, cpy, tgt.x, tgt.y, t);

      // Perpendicular to tangent
      const npx = -ty;
      const npy = tx;

      // Width tapers linearly from halfW at i=0 to ~0.5 at i=n
      const w = halfW * (1 - i / n) + 0.5 * (i / n);

      leftPoints.push(`${bx + npx * w},${by + npy * w}`);
      rightPoints.push(`${bx - npx * w},${by - npy * w}`);
    }

    // Build polygon: left side forward, right side backward
    rightPoints.reverse();
    return `M${leftPoints[0]} L${leftPoints.slice(1).join(' L')} L${rightPoints.join(' L')} Z`;
  }

  /** Approximate quadratic bezier arc length by sampling. */
  function approximateBezierLength(
    p0x: number, p0y: number,
    cpx: number, cpy: number,
    p1x: number, p1y: number
  ): number {
    let length = 0;
    let prevX = p0x, prevY = p0y;
    const steps = 20;
    for (let i = 1; i <= steps; i++) {
      const [bx, by] = quadBezier(p0x, p0y, cpx, cpy, p1x, p1y, i / steps);
      const ddx = bx - prevX;
      const ddy = by - prevY;
      length += Math.sqrt(ddx * ddx + ddy * ddy);
      prevX = bx;
      prevY = by;
    }
    return length;
  }

  function taperPath(e: SimEdge): string {
    const src = e.source as SimNode;
    const tgt = e.target as SimNode;
    if (src.x == null || src.y == null || tgt.x == null || tgt.y == null) return '';

    if (e.isBidirectional && e.curveDirection) {
      return curvedTaperPath(e);
    }
    return straightTaperPath(e);
  }

  // Filter matching
  function nodeMatches(nodeId: string): boolean {
    const node = simNodes.find((n) => n.id === nodeId);
    if (!node) return false;
    if (concernFilter !== 'all' && node.bmmConcern !== concernFilter) return false;
    if (searchText) {
      const s = searchText.toLowerCase();
      if (!node.friendlyName.toLowerCase().includes(s) && !node.id.toLowerCase().includes(s)) return false;
    }
    return true;
  }

  function edgeMatches(e: SimEdge): boolean {
    const src = e.source as SimNode;
    const tgt = e.target as SimNode;
    if (strengthFilter !== 'all' && e.strength !== strengthFilter) return false;
    if (concernFilter !== 'all' && src.bmmConcern !== concernFilter && tgt.bmmConcern !== concernFilter) return false;
    if (searchText) {
      const s = searchText.toLowerCase();
      if (!src.friendlyName.toLowerCase().includes(s) && !src.id.toLowerCase().includes(s) &&
          !tgt.friendlyName.toLowerCase().includes(s) && !tgt.id.toLowerCase().includes(s)) return false;
    }
    return true;
  }

  // Node opacity based on filters + selection
  function nodeOpacity(node: SimNode): number {
    const hasFilters = concernFilter !== 'all' || strengthFilter !== 'all' || searchText !== '';
    const hasSelection = selectedNodeId !== null;

    if (hasSelection) {
      if (node.id === selectedNodeId) return 1;
      const isNeighbour = simEdges.some((e) => {
        const src = (e.source as SimNode).id;
        const tgt = (e.target as SimNode).id;
        return (src === selectedNodeId && tgt === node.id) || (tgt === selectedNodeId && src === node.id);
      });
      if (isNeighbour) return 1;
      return 0.15;
    }

    if (hasFilters) {
      return nodeMatches(node.id) ? 1 : 0.1;
    }

    return 1;
  }

  function edgeOpacity(e: SimEdge): number {
    const style = STRENGTH_STYLES[e.strength] || STRENGTH_STYLES.moderate;
    const hasSelection = selectedNodeId !== null;
    const hasFilters = concernFilter !== 'all' || strengthFilter !== 'all' || searchText !== '';

    if (hasSelection) {
      const src = (e.source as SimNode).id;
      const tgt = (e.target as SimNode).id;
      if (src === selectedNodeId || tgt === selectedNodeId) return style.opacity;
      return 0.05;
    }

    if (hasFilters) {
      return edgeMatches(e) ? style.opacity : 0.05;
    }

    return style.opacity;
  }

  onMount(() => {
    // Build sim nodes and edges
    const nodes: SimNode[] = graph.nodes.map((n) => ({
      ...n,
      degree: 0,
    }));

    const nodeMap = new Map(nodes.map((n) => [n.id, n]));

    const edges: SimEdge[] = graph.edges
      .filter((e) => nodeMap.has(e.source) && nodeMap.has(e.target))
      .map((e) => ({
        source: e.source,
        target: e.target,
        strength: e.strength,
        rationale: e.rationale,
      }));

    computeDegrees(nodes, edges);
    markBidirectional(edges);

    // Measure container for initial center
    const rect = containerEl.getBoundingClientRect();
    const w = rect.width || 800;
    const h = Math.max(600, rect.height);

    // Create simulation
    simulation = d3.forceSimulation<SimNode>(nodes)
      .force('link', d3.forceLink<SimNode, SimEdge>(edges)
        .id((d) => d.id)
        .distance(120))
      .force('charge', d3.forceManyBody().strength(-400))
      .force('center', d3.forceCenter(w / 2, h / 2))
      .force('collide', d3.forceCollide<SimNode>().radius((d) => radiusScale(d.degree) + 10))
      .stop();

    // Pre-compute to equilibrium
    for (let i = 0; i < 300; i++) {
      simulation.tick();
    }

    simNodes = nodes;
    simEdges = edges;

    // Compute viewBox to fit all nodes after settling
    viewBox = computeViewBox(nodes);

    // Restart with low alpha for drag interactions
    simulation.alpha(0).restart().on('tick', () => {
      simNodes = [...simNodes];
      simEdges = [...simEdges];
      viewBox = computeViewBox(simNodes);
    });

    // Setup zoom
    const zoomBehaviour = d3.zoom<SVGSVGElement, unknown>()
      .scaleExtent([0.2, 4])
      .on('zoom', (event) => {
        transform = { x: event.transform.x, y: event.transform.y, k: event.transform.k };
      });

    d3.select(svgEl).call(zoomBehaviour);

    // Setup drag
    const dragBehaviour = d3.drag<SVGGElement, SimNode>()
      .on('start', (event, d) => {
        if (!event.active) simulation?.alphaTarget(0.1).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) simulation?.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });

    d3.select(svgEl)
      .selectAll<SVGGElement, SimNode>('.node-group')
      .data(simNodes)
      .call(dragBehaviour);

    return () => {
      simulation?.stop();
    };
  });

  // Re-apply drag when simNodes change
  $effect(() => {
    if (!svgEl || !simulation || simNodes.length === 0) return;

    const dragBehaviour = d3.drag<SVGGElement, SimNode>()
      .on('start', (event, d) => {
        if (!event.active) simulation?.alphaTarget(0.1).restart();
        d.fx = d.x;
        d.fy = d.y;
      })
      .on('drag', (event, d) => {
        d.fx = event.x;
        d.fy = event.y;
      })
      .on('end', (event, d) => {
        if (!event.active) simulation?.alphaTarget(0);
        d.fx = null;
        d.fy = null;
      });

    d3.select(svgEl)
      .selectAll<SVGGElement, SimNode>('.node-group')
      .data(simNodes, (d) => d.id)
      .call(dragBehaviour);
  });
</script>

<div bind:this={containerEl} class="relative w-full overflow-hidden rounded-lg border border-secondary-200 bg-secondary-50 dark:border-secondary-700 dark:bg-secondary-950" style="height: calc(100vh - 260px); min-height: 500px;">
  <svg
    bind:this={svgEl}
    class="h-full w-full"
    viewBox={viewBox}
    preserveAspectRatio="xMidYMid meet"
  >
    <g transform="translate({transform.x},{transform.y}) scale({transform.k})">
      <!-- Tapered edges -->
      {#each simEdges as edge, idx}
        {@const src = edge.source as SimNode}
        <path
          d={taperPath(edge)}
          fill={getConcernColour(src.bmmConcern)}
          opacity={edgeOpacity(edge)}
          stroke="none"
          class="transition-opacity duration-200"
          role="presentation"
          onmouseenter={() => hoveredEdgeIdx = idx}
          onmouseleave={() => hoveredEdgeIdx = null}
        />
      {/each}

      <!-- Nodes -->
      {#each simNodes as node (node.id)}
        {@const r = radiusScale(node.degree)}
        <!-- svelte-ignore a11y_no_static_element_interactions -->
        <g
          class="node-group cursor-pointer"
          transform="translate({node.x || 0},{node.y || 0})"
          opacity={nodeOpacity(node)}
          onclick={() => onNodeSelect(node.id)}
          onmouseenter={() => hoveredNodeId = node.id}
          onmouseleave={() => hoveredNodeId = null}
        >
          <!-- Node circle -->
          <circle
            {r}
            fill={getConcernColour(node.bmmConcern)}
            stroke={node.id === selectedNodeId ? '#fff' : hoveredNodeId === node.id ? '#e5e7eb' : 'none'}
            stroke-width={node.id === selectedNodeId ? 3 : hoveredNodeId === node.id ? 2 : 0}
            class="transition-all duration-200"
          />
          <!-- Label -->
          <text
            y={r + 14}
            text-anchor="middle"
            class="fill-secondary-700 dark:fill-secondary-300"
            font-size={fontSize(node.degree)}
          >
            {node.friendlyName}
          </text>
        </g>
      {/each}
    </g>
  </svg>

  <!-- Node tooltip -->
  {#if hoveredNodeId && hoveredNodeId !== selectedNodeId}
    {@const node = simNodes.find((n) => n.id === hoveredNodeId)}
    {#if node}
      <div class="pointer-events-none absolute left-3 top-3 z-10 rounded-md bg-secondary-800 px-3 py-2 text-xs text-white shadow-lg dark:bg-secondary-700">
        <div class="font-medium">{node.friendlyName}</div>
        <div class="text-secondary-300">{node.degree} connections</div>
      </div>
    {/if}
  {/if}

  <!-- Edge tooltip -->
  {#if hoveredEdgeIdx !== null}
    {@const edge = simEdges[hoveredEdgeIdx]}
    {@const src = edge?.source as SimNode}
    {@const tgt = edge?.target as SimNode}
    {#if edge && src && tgt}
      <div class="pointer-events-none absolute bottom-3 left-3 z-10 max-w-sm rounded-md bg-secondary-800 px-3 py-2 text-xs text-white shadow-lg dark:bg-secondary-700">
        <div class="font-medium">{src.friendlyName} → {tgt.friendlyName}: {edge.strength}</div>
        {#if edge.rationale}
          <div class="mt-1 text-secondary-300">{edge.rationale}</div>
        {/if}
      </div>
    {/if}
  {/if}
</div>
