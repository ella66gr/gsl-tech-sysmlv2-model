<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';
  import { getConcernColour } from '$lib/utils/colours';

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

  let containerEl: HTMLDivElement;

  // $state so that $effect blocks re-run when fg is set in onMount
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let fg = $state<any>(null);

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let graphData: { nodes: any[]; links: any[] } = { nodes: [], links: [] };

  // HTML label elements lifted to module scope so the filter $effect can sync visibility
  let labelElements: Map<string, HTMLDivElement> = new Map();

  // Nodes currently hidden by filters — checked by the RAF label loop
  let hiddenNodeIds: Set<string> = new Set();

  let initialCameraPosition: { x: number; y: number; z: number } | null = null;
  let cameraTimer: ReturnType<typeof setTimeout> | null = null;
  let rafId: number | null = null;

  // Double-click tracking for node unpin
  let lastClickTime = 0;
  let lastClickNodeId: string | null = null;

  function resetView() {
    if (fg && initialCameraPosition) {
      fg.cameraPosition(initialCameraPosition, { x: 0, y: 0, z: 0 }, 1000);
    }
  }

  onMount(async () => {
    // Dynamic imports — avoids SSR errors (3d-force-graph requires window/document)
    const { default: ForceGraph3D } = await import('3d-force-graph');
    const THREE = await import('three');

    // Build graph data
    graphData = {
      nodes: graph.nodes.map((n) => ({
        id: n.id,
        friendlyName: n.friendlyName,
        bmmConcern: n.bmmConcern,
        classification: n.classification,
        package: n.package,
        shortDescription: n.shortDescription,
        degree: 0,
      })),
      links: graph.edges.map((e) => ({
        source: e.source,
        target: e.target,
        strength: e.strength,
        rationale: e.rationale,
        isBidirectional: false,
        curvature: 0,
        rotation: 0,
      })),
    };

    // Compute degree
    const degreeMap = new Map<string, number>();
    for (const link of graphData.links) {
      const src = link.source as string;
      const tgt = link.target as string;
      degreeMap.set(src, (degreeMap.get(src) || 0) + 1);
      degreeMap.set(tgt, (degreeMap.get(tgt) || 0) + 1);
    }
    for (const node of graphData.nodes) {
      node.degree = degreeMap.get(node.id) || 0;
    }

    // Mark bidirectional pairs — same curvature, rotation PI/2 apart, so curves sweep
    // through perpendicular planes and are visually distinct.
    // linkWidth must be 0 for curvature to work (positive linkWidth uses cylinder renderer).
    const linkPairs = new Map<string, (typeof graphData.links)[0]>();
    for (const link of graphData.links) {
      const fwd = `${link.source}->${link.target}`;
      const rev = `${link.target}->${link.source}`;
      if (linkPairs.has(rev)) {
        link.isBidirectional = true;
        link.curvature = 0.3;
        link.rotation = Math.PI / 2;
        const firstEdge = linkPairs.get(rev)!;
        firstEdge.isBidirectional = true;
        firstEdge.curvature = 0.3;
        firstEdge.rotation = 0;
      } else {
        link.curvature = 0;
        link.rotation = 0;
        link.isBidirectional = false;
        linkPairs.set(fwd, link);
      }
    }

    // Initialise graph — assigns to the $state variable so $effect blocks re-run
    fg = new ForceGraph3D(containerEl, { controlType: 'orbit' })
      .graphData(graphData)
      .backgroundColor('#0f172a')
      .showNavInfo(false)

      // === NODE RENDERING ===
      .nodeVal((node: { degree: number }) => Math.max(2, node.degree * 1.5))
      .nodeColor((node: { bmmConcern: string }) => getConcernColour(node.bmmConcern))
      .nodeOpacity(0.9)
      .nodeLabel((node: { friendlyName: string; degree: number; bmmConcern: string }) =>
        `<div style="background: rgba(15,23,42,0.92); color: #e2e8f0; padding: 7px 11px; border-radius: 7px; font-size: 12px; font-family: system-ui, -apple-system, sans-serif; border: 1px solid rgba(148,163,184,0.2);">
          <div style="font-weight: 600; color: #f1f5f9;">${node.friendlyName}</div>
          <div style="opacity: 0.65; margin-top: 3px; font-size: 11px;">${node.degree} connections · ${node.bmmConcern}</div>
        </div>`
      )

      // === LINK RENDERING ===
      // linkWidth 0 required for linkCurvature to work (cylinder renderer ignores curvature)
      .linkWidth(0)
      .linkOpacity(0.7)
      .linkColor((link: { source: unknown }) => {
        const srcId = typeof link.source === 'object' && link.source !== null
          ? (link.source as { id: string }).id
          : link.source as string;
        const srcNode = graphData.nodes.find((n) => n.id === srcId);
        return srcNode ? getConcernColour(srcNode.bmmConcern) : '#6b7280';
      })
      .linkCurvature('curvature')
      .linkCurveRotation('rotation')
      .linkDirectionalArrowLength(6)
      .linkDirectionalArrowRelPos(0.92)
      .linkDirectionalArrowColor((link: { source: unknown }) => {
        const srcId = typeof link.source === 'object' && link.source !== null
          ? (link.source as { id: string }).id
          : link.source as string;
        const srcNode = graphData.nodes.find((n) => n.id === srcId);
        return srcNode ? getConcernColour(srcNode.bmmConcern) : '#6b7280';
      })
      // Particles indicate edge strength — more/larger = stronger
      .linkDirectionalParticles((link: { strength: string }) => {
        const counts: Record<string, number> = { strong: 10, moderate: 6, weak: 2, contextual: 0 };
        return counts[link.strength] ?? 1;
      })
      .linkDirectionalParticleWidth((link: { strength: string }) => {
        const widths: Record<string, number> = { strong: 4, moderate: 2.5, weak: 1.5, contextual: 1 };
        return widths[link.strength] ?? 2;
      })
      .linkDirectionalParticleSpeed(0.0004)
      .linkLabel((link: { source: unknown; target: unknown; strength: string; rationale?: string }) => {
        const srcLabel = typeof link.source === 'object' && link.source !== null
          ? (link.source as { friendlyName?: string; id: string }).friendlyName || (link.source as { id: string }).id
          : link.source as string;
        const tgtLabel = typeof link.target === 'object' && link.target !== null
          ? (link.target as { friendlyName?: string; id: string }).friendlyName || (link.target as { id: string }).id
          : link.target as string;
        return `<div style="background: rgba(15,23,42,0.92); color: #e2e8f0; padding: 7px 11px; border-radius: 7px; font-size: 12px; font-family: system-ui, -apple-system, sans-serif; max-width: 320px; border: 1px solid rgba(148,163,184,0.2);">
          <div style="font-weight: 600; color: #f1f5f9;">${srcLabel} → ${tgtLabel}</div>
          <div style="opacity: 0.7; margin-top: 3px; font-size: 11px;">Strength: ${link.strength}</div>
          ${link.rationale ? `<div style="opacity: 0.55; margin-top: 5px; font-size: 11px; line-height: 1.4;">${link.rationale}</div>` : ''}
        </div>`;
      })

      // === PHYSICS ===
      .d3AlphaDecay(0.01)
      .d3VelocityDecay(0.3)

      // === INTERACTION ===
      .onNodeClick((node: { id: string; fx?: number; fy?: number; fz?: number }) => {
        const now = Date.now();
        if (lastClickNodeId === node.id && now - lastClickTime < 400) {
          node.fx = undefined;
          node.fy = undefined;
          node.fz = undefined;
          lastClickNodeId = null;
        } else {
          onNodeSelect(node.id);
          lastClickNodeId = node.id;
        }
        lastClickTime = now;
      })
      .onNodeDragEnd((node: { x?: number; y?: number; z?: number; fx?: number; fy?: number; fz?: number }) => {
        node.fx = node.x;
        node.fy = node.y;
        node.fz = node.z;
      })
      .enableNodeDrag(true)
      .enableNavigationControls(true);

    // Enable panning
    const controls = fg.controls();
    if (controls) controls.enablePan = true;

    // === 3D SHADING ===
    const scene = fg.scene();
    if (scene) {
      const ambient = new THREE.AmbientLight(0xffffff, 0.6);
      scene.add(ambient);

      const dirLight = new THREE.DirectionalLight(0xffffff, 1.2);
      dirLight.position.set(200, 300, 200);
      scene.add(dirLight);

      const fillLight = new THREE.DirectionalLight(0xffffff, 0.5);
      fillLight.position.set(-150, -100, -150);
      scene.add(fillLight);

      const pointLight = new THREE.PointLight(0xffffff, 1.0, 500);
      pointLight.position.set(0, 50, 100);
      scene.add(pointLight);
    }

    // Replace default spheres with shiny MeshPhongMaterial for visible 3D shading
    fg.nodeThreeObject((node: { degree: number; bmmConcern: string }) => {
      const val = Math.max(2, node.degree * 1.5);
      const r = Math.cbrt(val) * 4;
      const colour = getConcernColour(node.bmmConcern);
      const geometry = new THREE.SphereGeometry(r, 32, 24);
      const material = new THREE.MeshPhongMaterial({
        color: colour,
        shininess: 100,
        specular: 0x666666,
        transparent: true,
        opacity: 0.92,
      });
      return new THREE.Mesh(geometry, material);
    })
    .nodeThreeObjectExtend(false);

    // Tune physics forces
    const chargeForce = fg.d3Force('charge');
    if (chargeForce) chargeForce.strength(-120);
    const linkForce = fg.d3Force('link');
    if (linkForce) linkForce.distance(60).strength(0.7);

    // === HTML OVERLAY LABELS ===
    // Injected into the container as an absolutely-positioned overlay.
    // The RAF loop projects 3D→2D each frame. The filter $effect syncs hiddenNodeIds
    // which this loop checks before showing any label.
    const labelsDiv = document.createElement('div');
    labelsDiv.style.cssText = 'position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; overflow: hidden;';
    containerEl.style.position = 'relative';
    containerEl.appendChild(labelsDiv);

    // Populate module-scope labelElements map
    labelElements = new Map();
    for (const node of graphData.nodes) {
      const el = document.createElement('div');
      el.textContent = node.friendlyName;
      el.style.cssText = [
        'position: absolute',
        'color: #cbd5e1',
        'font-size: 14px',
        'font-family: system-ui, -apple-system, sans-serif',
        'font-weight: 500',
        'white-space: nowrap',
        'transform: translate(-50%, 0)',
        'pointer-events: none',
        'text-shadow: 0 1px 3px rgba(0,0,0,0.9), 0 0 8px rgba(0,0,0,0.6)',
        'will-change: left, top, opacity',
      ].join(';');
      labelsDiv.appendChild(el);
      labelElements.set(node.id, el);
    }

    // Project 3D positions to 2D screen coords each frame
    const vecTemp = new THREE.Vector3();
    function updateLabels() {
      rafId = requestAnimationFrame(updateLabels);
      if (!fg) return;

      const camera = fg.camera();
      const renderer = fg.renderer();
      if (!camera || !renderer) return;

      const canvas = renderer.domElement;
      const width = canvas.clientWidth || canvas.width;
      const height = canvas.clientHeight || canvas.height;

      for (const node of graphData.nodes) {
        const el = labelElements.get(node.id);
        if (!el) continue;

        // Hide label if node is filtered out
        if (hiddenNodeIds.has(node.id)) {
          el.style.display = 'none';
          continue;
        }

        if (node.x === undefined || node.y === undefined || node.z === undefined) continue;

        vecTemp.set(node.x, node.y, node.z);
        vecTemp.project(camera);

        // z > 1 means behind camera
        if (vecTemp.z > 1) {
          el.style.display = 'none';
          continue;
        }

        const x = (vecTemp.x * 0.5 + 0.5) * width;
        const y = (-vecTemp.y * 0.5 + 0.5) * height;

        el.style.display = '';
        el.style.left = `${x}px`;
        el.style.top = `${y + 14}px`;

        // Fade labels at distance
        const dist = camera.position.distanceTo(vecTemp.set(node.x, node.y, node.z));
        const opacity = Math.max(0.25, Math.min(1, 180 / dist));
        el.style.opacity = String(opacity);
      }
    }
    requestAnimationFrame(updateLabels);

    // Capture initial camera position after physics warm-up
    cameraTimer = setTimeout(() => {
      if (fg) {
        const cam = fg.camera();
        initialCameraPosition = { x: cam.position.x, y: cam.position.y, z: cam.position.z };
      }
    }, 2000);
  });

  // Selection highlight — re-runs when fg is set (it's $state) or selectedNodeId changes
  $effect(() => {
    if (!fg) return;

    const sel = selectedNodeId;

    fg.nodeColor((node: { id: string; bmmConcern: string }) => {
      if (sel && node.id !== sel) {
        const isNeighbour = graphData.links.some((l) => {
          const src = typeof l.source === 'object' && l.source !== null ? (l.source as { id: string }).id : l.source as string;
          const tgt = typeof l.target === 'object' && l.target !== null ? (l.target as { id: string }).id : l.target as string;
          return (src === sel && tgt === node.id) || (tgt === sel && src === node.id);
        });
        if (!isNeighbour) return getConcernColour(node.bmmConcern) + '28';
      }
      return getConcernColour(node.bmmConcern);
    });

    fg.linkOpacity((link: { source: unknown; target: unknown }) => {
      if (!sel) return 0.7;
      const src = typeof link.source === 'object' && link.source !== null ? (link.source as { id: string }).id : link.source as string;
      const tgt = typeof link.target === 'object' && link.target !== null ? (link.target as { id: string }).id : link.target as string;
      if (src === sel || tgt === sel) return 0.9;
      return 0.05;
    });
  });

  // Filtering — re-runs when fg is set ($state) or any filter prop changes.
  // Calls nodeVisibility/linkVisibility on the graph AND syncs hiddenNodeIds so
  // the HTML label RAF loop knows which labels to hide.
  $effect(() => {
    if (!fg) return;

    const cf = concernFilter;
    const sf = strengthFilter;
    const st = searchText;

    // Rebuild hiddenNodeIds so the label RAF loop can check it
    const newHidden = new Set<string>();
    for (const node of graphData.nodes) {
      let hidden = false;
      if (cf !== 'all' && node.bmmConcern !== cf) hidden = true;
      if (!hidden && st) {
        const s = st.toLowerCase();
        if (!node.friendlyName.toLowerCase().includes(s) && !node.id.toLowerCase().includes(s)) hidden = true;
      }
      if (hidden) newHidden.add(node.id);
    }
    hiddenNodeIds = newHidden;

    // Update 3D graph visibility
    fg.nodeVisibility((node: { id: string; friendlyName: string; bmmConcern: string }) => {
      if (cf !== 'all' && node.bmmConcern !== cf) return false;
      if (st) {
        const s = st.toLowerCase();
        if (!node.friendlyName.toLowerCase().includes(s) && !node.id.toLowerCase().includes(s)) return false;
      }
      return true;
    });

    fg.linkVisibility((link: { source: unknown; target: unknown; strength: string }) => {
      const srcId = typeof link.source === 'object' && link.source !== null ? (link.source as { id: string }).id : link.source as string;
      const tgtId = typeof link.target === 'object' && link.target !== null ? (link.target as { id: string }).id : link.target as string;
      const srcNode = graphData.nodes.find((n) => n.id === srcId);
      const tgtNode = graphData.nodes.find((n) => n.id === tgtId);
      if (!srcNode || !tgtNode) return false;

      if (sf !== 'all' && link.strength !== sf) return false;
      if (cf !== 'all' && srcNode.bmmConcern !== cf && tgtNode.bmmConcern !== cf) return false;
      if (st) {
        const s = st.toLowerCase();
        const srcMatch = srcNode.friendlyName.toLowerCase().includes(s) || srcNode.id.toLowerCase().includes(s);
        const tgtMatch = tgtNode.friendlyName.toLowerCase().includes(s) || tgtNode.id.toLowerCase().includes(s);
        if (!srcMatch && !tgtMatch) return false;
      }
      return true;
    });

    fg.refresh();
  });

  onDestroy(() => {
    if (rafId !== null) cancelAnimationFrame(rafId);
    if (cameraTimer !== null) clearTimeout(cameraTimer);
    if (fg) {
      try {
        fg._destructor();
      } catch {
        // ignore cleanup errors
      }
    }
  });
</script>

<div
  class="relative w-full overflow-hidden rounded-lg border border-secondary-200 dark:border-secondary-700"
  style="height: calc(100vh - 260px); min-height: 500px;"
>
  <!-- 3D WebGL graph container — label overlay injected here by onMount -->
  <div bind:this={containerEl} class="h-full w-full"></div>

  <!-- Reset view button -->
  <button
    onclick={resetView}
    class="absolute right-3 top-3 z-10 rounded-md bg-white/80 px-2.5 py-1.5 text-xs font-medium text-secondary-600 shadow-sm ring-1 ring-secondary-200 backdrop-blur-sm transition hover:bg-white hover:text-secondary-800 dark:bg-secondary-800/80 dark:text-secondary-300 dark:ring-secondary-700 dark:hover:bg-secondary-800 dark:hover:text-white"
    title="Reset zoom and position"
  >
    Reset View
  </button>
</div>
