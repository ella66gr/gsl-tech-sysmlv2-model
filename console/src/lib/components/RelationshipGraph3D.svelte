<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';
  import { getConcernColour } from '$lib/utils/colours';

  interface Props {
    graph: WeightedRelationshipGraph;
    selectedConcerns: Set<string>;
    selectedStrengths: Set<string>;
    searchText: string;
    selectedNodeId: string | null;
    onNodeSelect: (nodeId: string) => void;
    panelOpacity?: number;
  }

  let {
    graph,
    selectedConcerns,
    selectedStrengths,
    searchText,
    selectedNodeId,
    onNodeSelect,
    panelOpacity = 85,
  }: Props = $props();

  // Derived overlay background — respects dark mode and slider opacity
  const isDarkMode = typeof document !== 'undefined' && document.documentElement.classList.contains('dark');
  const overlayBg = $derived(
    isDarkMode
      ? `background-color: rgba(15, 23, 42, ${panelOpacity / 100})`
      : `background-color: rgba(255, 255, 255, ${panelOpacity / 100})`
  );

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

  // Ad-hoc node selection (⌘+click to build, Enter to commit, Escape to clear)
  let adHocSelection = $state<Set<string>>(new Set());
  let selectionCommitted = $state(false);

  // Ring meshes for selected nodes (Three.js objects, keyed by node ID)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let selectionRings: Map<string, any> = new Map();

  // THREE module reference — set in onMount, used by the ring $effect
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let THREE_REF: any = null;

  // Keyboard listener reference — hoisted so onDestroy can remove it
  let handleKeydownFn: ((e: KeyboardEvent) => void) | null = null;
  let handleKeyupFn: ((e: KeyboardEvent) => void) | null = null;

  // Keyboard state: is the F key currently held down?
  let fKeyHeld = $state(false);

  // Focus-node exploration mode (Ctrl+click to enter, Escape to exit)
  let focusNodeId = $state<string | null>(null);
  let focusDirection = $state<'in' | 'out' | 'both'>('both');
  let focusBreadcrumb = $state<string[]>([]);

  // Focus ring mesh (distinct amber ring — not part of the selectionRings map)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let focusRing: any = null;

  function resetView() {
    if (fg && initialCameraPosition) {
      fg.cameraPosition(initialCameraPosition, { x: 0, y: 0, z: 0 }, 1000);
    }
  }

  function toggleAdHocNode(nodeId: string) {
    const next = new Set(adHocSelection);
    if (next.has(nodeId)) {
      next.delete(nodeId);
    } else {
      next.add(nodeId);
    }
    adHocSelection = next;
    // Uncommit if the user is changing the selection after committing
    if (selectionCommitted) selectionCommitted = false;
  }

  function commitSelection() {
    if (adHocSelection.size > 0) {
      selectionCommitted = true;
    }
  }

  function clearSelection() {
    adHocSelection = new Set();
    selectionCommitted = false;
  }

  /**
   * Compute the visible neighbourhood of a focus node.
   * Returns the set of node IDs that should be visible (focus + neighbours).
   * Respects direction filter and the pill/search hidden set.
   */
  function computeFocusNeighbours(
    focusId: string,
    direction: 'in' | 'out' | 'both',
    pillHidden: Set<string>,
    strengthSet: Set<string>,
  ): Set<string> {
    const neighbours = new Set<string>();
    neighbours.add(focusId);

    for (const link of graphData.links) {
      const srcId = typeof link.source === 'object' && link.source !== null
        ? (link.source as { id: string }).id : link.source as string;
      const tgtId = typeof link.target === 'object' && link.target !== null
        ? (link.target as { id: string }).id : link.target as string;

      // Skip edges where either endpoint is hidden by pill/search filters
      if (pillHidden.has(srcId) || pillHidden.has(tgtId)) continue;

      // Skip edges that don't pass the strength filter
      if (strengthSet.size > 0 && !strengthSet.has(link.strength)) continue;

      // Direction logic: edge goes source → target
      if (direction === 'out' || direction === 'both') {
        if (srcId === focusId) neighbours.add(tgtId);
      }
      if (direction === 'in' || direction === 'both') {
        if (tgtId === focusId) neighbours.add(srcId);
      }
    }

    return neighbours;
  }

  function setFocusNode(nodeId: string) {
    if (focusNodeId && focusNodeId !== nodeId) {
      focusBreadcrumb = [...focusBreadcrumb, focusNodeId];
    }
    focusNodeId = nodeId;
  }

  function jumpToBreadcrumb(index: number) {
    const targetId = focusBreadcrumb[index];
    focusBreadcrumb = focusBreadcrumb.slice(0, index);
    focusNodeId = targetId;
  }

  function exitFocusMode() {
    focusNodeId = null;
    focusDirection = 'both';
    focusBreadcrumb = [];
  }

  onMount(async () => {
    // Dynamic imports — avoids SSR errors (3d-force-graph requires window/document)
    const { default: ForceGraph3D } = await import('3d-force-graph');
    const THREE = await import('three');
    THREE_REF = THREE;

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

      // === CUSTOM LINK RENDERING ===
      // Each link is a Three.js Group: curved TubeGeometry + ConeGeometry arrowhead.
      // Strength → tube radius + material opacity.
      // Direction → cone arrowhead at target end, oriented along curve tangent.
      // Bidirectional separation → QuadraticBezierCurve3 with perpendicular control point offset.
      .linkThreeObject((link: { source: unknown; target: unknown; strength: string; curvature: number; rotation: number }) => {
        const srcId = typeof link.source === 'object' && link.source !== null
          ? (link.source as { id: string }).id : link.source as string;
        const srcNode = graphData.nodes.find((n) => n.id === srcId);
        const colour = srcNode ? getConcernColour(srcNode.bmmConcern) : '#6b7280';

        // Strength → visual properties
        const radiusMap: Record<string, number> = { strong: 0.8, moderate: 0.45, weak: 0.2, contextual: 0.12 };
        const opacityMap: Record<string, number> = { strong: 0.85, moderate: 0.55, weak: 0.28, contextual: 0.15 };
        const tubeRadius = radiusMap[link.strength] ?? 0.3;
        const tubeOpacity = opacityMap[link.strength] ?? 0.4;

        const material = new THREE.MeshPhongMaterial({
          color: colour,
          transparent: true,
          opacity: tubeOpacity,
          shininess: 30,
        });

        // Arrow properties scaled to tube size
        const arrowRadius = Math.max(2.0, tubeRadius * 4);
        const arrowHeight = arrowRadius * 2;

        // Arrowhead cone
        const arrowGeom = new THREE.ConeGeometry(arrowRadius, arrowHeight, 8);
        const arrowMat = new THREE.MeshPhongMaterial({
          color: colour,
          transparent: true,
          opacity: Math.min(1, tubeOpacity + 0.2),
          shininess: 30,
        });
        const arrow = new THREE.Mesh(arrowGeom, arrowMat);

        // Placeholder tube — will be replaced in linkPositionUpdate with correct geometry
        const placeholderGeom = new THREE.BufferGeometry();
        const tube = new THREE.Mesh(placeholderGeom, material);

        const group = new THREE.Group();
        group.add(tube);
        group.add(arrow);
        group.userData = {
          tube,
          arrow,
          material,
          arrowMat,
          arrowHeight,
          tubeRadius,
          curvature: link.curvature,
          rotation: link.rotation,
          colour,
        };

        return group;
      })
      .linkPositionUpdate((group: any, { start, end }: { start: { x: number; y: number; z: number }; end: { x: number; y: number; z: number } }, link: any) => {
        if (!group?.userData) return false;
        const { tube, arrow, material, arrowHeight, tubeRadius, curvature, rotation } = group.userData;

        const startV = new THREE.Vector3(start.x, start.y, start.z);
        const endV = new THREE.Vector3(end.x, end.y, end.z);
        const dist = startV.distanceTo(endV);
        if (dist < 0.1) return false;

        // Direction vector and midpoint
        const dir = new THREE.Vector3().subVectors(endV, startV).normalize();
        const mid = new THREE.Vector3().addVectors(startV, endV).multiplyScalar(0.5);

        // Compute control point for quadratic Bézier curve
        // For bidirectional edges, curvature > 0 and rotation offsets the control point
        // into a perpendicular plane so the two edges arc in different directions.
        let controlPoint = mid.clone();
        if (curvature > 0) {
          // Find a perpendicular vector to the link direction
          const up = new THREE.Vector3(0, 1, 0);
          let perp = new THREE.Vector3().crossVectors(dir, up);
          if (perp.lengthSq() < 0.001) {
            // dir is nearly parallel to up — use a different reference
            perp.crossVectors(dir, new THREE.Vector3(1, 0, 0));
          }
          perp.normalize();

          // Rotate the perpendicular vector around the link axis by the rotation angle
          // This separates bidirectional pairs into different planes
          if (rotation > 0) {
            const rotQuat = new THREE.Quaternion().setFromAxisAngle(dir, rotation);
            perp.applyQuaternion(rotQuat);
          }

          // Offset the control point perpendicular to the link
          const offsetDist = dist * curvature;
          controlPoint.add(perp.multiplyScalar(offsetDist));
        }

        // Build the Bézier curve
        const curve = new THREE.QuadraticBezierCurve3(startV, controlPoint, endV);

        // Compute actual node radii from degree (matches nodeVal and nodeThreeObject sizing)
        const srcDegree = typeof link.source === 'object' ? (link.source as any).degree || 0 : 0;
        const tgtDegree = typeof link.target === 'object' ? (link.target as any).degree || 0 : 0;
        const srcRadius = Math.cbrt(Math.max(2, srcDegree * 1.5)) * 4 + 2; // +2 clearance margin
        const tgtRadius = Math.cbrt(Math.max(2, tgtDegree * 1.5)) * 4 + 2; // +2 clearance margin

        const tubeStartFrac = srcRadius / dist;
        const arrowTip = tgtRadius / dist;

        // Get trimmed curve range — trim both ends to stop at node surfaces
        const tubeEndFrac = Math.max(tubeStartFrac + 0.01, 1 - arrowTip - (arrowHeight / dist));
        const trimmedPoints: THREE.Vector3[] = [];
        const segments = 20;
        for (let i = 0; i <= segments; i++) {
          const t = tubeStartFrac + (tubeEndFrac - tubeStartFrac) * (i / segments);
          trimmedPoints.push(curve.getPoint(t));
        }

        // Create a CatmullRom curve through the trimmed points (for TubeGeometry)
        const tubePath = new THREE.CatmullRomCurve3(trimmedPoints);

        // Replace tube geometry
        if (tube.geometry) tube.geometry.dispose();
        tube.geometry = new THREE.TubeGeometry(tubePath, 16, tubeRadius, 6, false);

        // Reset tube transform — TubeGeometry is already in world coordinates
        tube.position.set(0, 0, 0);
        tube.rotation.set(0, 0, 0);
        tube.scale.set(1, 1, 1);

        // Position arrowhead at the end of the curve, just before the target node
        const arrowFrac = Math.max(tubeStartFrac + 0.01, 1 - arrowTip - (arrowHeight * 0.5 / dist));
        const arrowPos = curve.getPoint(arrowFrac);
        arrow.position.copy(arrowPos);

        // Orient arrowhead along the curve tangent at that point
        const tangent = curve.getTangent(arrowFrac).normalize();
        const arrowUp = new THREE.Vector3(0, 1, 0);
        const arrowQuat = new THREE.Quaternion().setFromUnitVectors(arrowUp, tangent);
        arrow.setRotationFromQuaternion(arrowQuat);

        return true; // We've handled positioning
      })
      // Suppress the default line rendering — we handle everything via linkThreeObject
      .linkColor(() => 'rgba(0,0,0,0)')
      .linkWidth(0)
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
      .onNodeClick((node: { id: string; fx?: number; fy?: number; fz?: number }, event: MouseEvent) => {
        const now = Date.now();

        // Double-click: unpin node
        if (lastClickNodeId === node.id && now - lastClickTime < 400) {
          node.fx = undefined;
          node.fy = undefined;
          node.fz = undefined;
          lastClickNodeId = null;
          lastClickTime = now;
          return;
        }

        // F+click: focus-node exploration (F+click focused node to exit)
        if (fKeyHeld) {
          if (focusNodeId === node.id) {
            exitFocusMode();
            lastClickNodeId = node.id;
            lastClickTime = now;
            return;
          }
          if (adHocSelection.size > 0) clearSelection();
          setFocusNode(node.id);
          lastClickNodeId = node.id;
          lastClickTime = now;
          return;
        }

        // ⌘+click (Mac) or Ctrl+click (Windows/Linux): toggle ad-hoc multi-select
        if (event.metaKey || event.ctrlKey) {
          toggleAdHocNode(node.id);
          lastClickNodeId = node.id;
          lastClickTime = now;
          return;
        }

        // Plain click: open side panel
        onNodeSelect(node.id);
        lastClickNodeId = node.id;
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

    // Keyboard: F tracks focus-key state; Enter commits selection; Escape exits modes
    handleKeydownFn = (e: KeyboardEvent) => {
      if (e.key === 'f' || e.key === 'F') {
        fKeyHeld = true;
        return; // F alone does nothing else
      }
      if (e.key === 'Enter') {
        e.preventDefault();
        commitSelection();
      } else if (e.key === 'Escape') {
        e.preventDefault();
        if (focusNodeId) {
          exitFocusMode();
        } else {
          clearSelection();
        }
      }
    };
    window.addEventListener('keydown', handleKeydownFn);

    // Track F key release
    handleKeyupFn = (e: KeyboardEvent) => {
      if (e.key === 'f' || e.key === 'F') {
        fKeyHeld = false;
      }
    };
    window.addEventListener('keyup', handleKeyupFn);

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

      // Track selection ring positions
      for (const [nodeId, ring] of selectionRings) {
        const node = graphData.nodes.find((n: { id: string }) => n.id === nodeId);
        if (node && node.x !== undefined && node.y !== undefined && node.z !== undefined) {
          ring.position.set(node.x, node.y, node.z);
        }
      }

      // Track focus ring position
      if (focusRing && focusNodeId) {
        const fNode = graphData.nodes.find((n: { id: string }) => n.id === focusNodeId);
        if (fNode && fNode.x !== undefined && fNode.y !== undefined && fNode.z !== undefined) {
          focusRing.position.set(fNode.x, fNode.y, fNode.z);
        }
      }

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

        // Scale labels with distance — larger when close, smaller when far
        const dist = camera.position.distanceTo(vecTemp.set(node.x, node.y, node.z));
        const opacity = Math.max(0.25, Math.min(1, 180 / dist));
        el.style.opacity = String(opacity);

        // Font size: 10px at far distance, 18px at close, 14px at reference distance 120
        const fontSize = Math.max(12, Math.min(36, 18 * (120 / dist)));
        el.style.fontSize = `${fontSize}px`;
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

  });

  // Ad-hoc selection rings — visible only while building (not committed)
  $effect(() => {
    if (!fg || !THREE_REF) return;

    const scene = fg.scene();
    if (!scene) return;

    const currentSelection = adHocSelection;
    const committed = selectionCommitted;

    // If committed, remove ALL rings — the badge communicates the state now
    if (committed) {
      for (const [nodeId, ring] of selectionRings) {
        scene.remove(ring);
        selectionRings.delete(nodeId);
      }
      return;
    }

    // Remove rings for nodes no longer in the selection
    for (const [nodeId, ring] of selectionRings) {
      if (!currentSelection.has(nodeId)) {
        scene.remove(ring);
        selectionRings.delete(nodeId);
      }
    }

    // Add rings for newly selected nodes
    for (const nodeId of currentSelection) {
      if (selectionRings.has(nodeId)) continue;
      const node = graphData.nodes.find((n: { id: string }) => n.id === nodeId);
      if (!node) continue;
      const val = Math.max(2, (node.degree || 0) * 1.5);
      const r = Math.cbrt(val) * 4 + 2;
      const ringGeometry = new THREE_REF.SphereGeometry(r, 24, 16);
      const ringMaterial = new THREE_REF.MeshBasicMaterial({
        color: 0xffffff,
        wireframe: true,
        transparent: true,
        opacity: 0.35,
      });
      const ring = new THREE_REF.Mesh(ringGeometry, ringMaterial);
      if (node.x !== undefined && node.y !== undefined && node.z !== undefined) {
        ring.position.set(node.x, node.y, node.z);
      }
      scene.add(ring);
      selectionRings.set(nodeId, ring);
    }
  });

  // Focus node ring — amber/gold wireframe, visible only when in focus mode
  $effect(() => {
    if (!fg || !THREE_REF) return;

    const scene = fg.scene();
    if (!scene) return;

    const currentFocus = focusNodeId;

    // Remove existing focus ring whenever focus changes or clears
    if (focusRing) {
      scene.remove(focusRing);
      focusRing = null;
    }

    if (currentFocus) {
      const node = graphData.nodes.find((n: { id: string }) => n.id === currentFocus);
      if (node) {
        const val = Math.max(2, (node.degree || 0) * 1.5);
        const r = Math.cbrt(val) * 4 + 3; // Slightly larger than selection rings
        const ringGeometry = new THREE_REF.SphereGeometry(r, 24, 16);
        const ringColour = getConcernColour(node.bmmConcern);
        const ringMaterial = new THREE_REF.MeshBasicMaterial({
          color: ringColour,
          wireframe: true,
          transparent: true,
          opacity: 0.5,
        });
        focusRing = new THREE_REF.Mesh(ringGeometry, ringMaterial);
        if (node.x !== undefined && node.y !== undefined && node.z !== undefined) {
          focusRing.position.set(node.x, node.y, node.z);
        }
        scene.add(focusRing);
      }
    }
  });

  // Filtering — pill filters, search, ad-hoc selection, and focus-node exploration all compose here.
  // Syncs hiddenNodeIds so the HTML label RAF loop knows which labels to hide.
  $effect(() => {
    if (!fg) return;

    const concerns = selectedConcerns;
    const strengths = selectedStrengths;
    const st = searchText;
    const committed = selectionCommitted;
    const selection = adHocSelection;
    const focus = focusNodeId;
    const direction = focusDirection;

    // Step 1: compute pill/search hidden set
    // In focus mode, the focus node is exempt from the concern pill filter
    // (it must remain visible as the anchor of the neighbourhood view).
    const pillHidden = new Set<string>();
    for (const node of graphData.nodes) {
      let hidden = false;

      // Concern pill filter — focus node is exempt
      if (concerns.size > 0 && !concerns.has(node.bmmConcern)) {
        if (!(focus && node.id === focus)) {
          hidden = true;
        }
      }

      // Search filter — applies to all nodes including the focus node
      if (!hidden && st) {
        const s = st.toLowerCase();
        if (!node.friendlyName.toLowerCase().includes(s) && !node.id.toLowerCase().includes(s)) hidden = true;
      }

      if (hidden) pillHidden.add(node.id);
    }

    // Step 2: build final hidden set by composing additional filter layers
    const newHidden = new Set<string>(pillHidden);

    // Committed ad-hoc selection (ignored when focus mode is active)
    if (!focus && committed && selection.size > 0) {
      for (const node of graphData.nodes) {
        if (!pillHidden.has(node.id) && !selection.has(node.id)) {
          newHidden.add(node.id);
        }
      }
    }

    // Focus-node exploration — overrides ad-hoc selection when active
    if (focus && !pillHidden.has(focus)) {
      const visible = computeFocusNeighbours(focus, direction, pillHidden, strengths);
      for (const node of graphData.nodes) {
        if (!pillHidden.has(node.id) && !visible.has(node.id)) {
          newHidden.add(node.id);
        }
      }
    }

    hiddenNodeIds = newHidden;

    fg.nodeVisibility((node: { id: string }) => !newHidden.has(node.id));

    fg.linkVisibility((link: { source: unknown; target: unknown; strength: string }) => {
      const srcId = typeof link.source === 'object' && link.source !== null ? (link.source as { id: string }).id : link.source as string;
      const tgtId = typeof link.target === 'object' && link.target !== null ? (link.target as { id: string }).id : link.target as string;

      // Both endpoints must be visible
      if (newHidden.has(srcId) || newHidden.has(tgtId)) return false;

      // Strength filter
      if (strengths.size > 0 && !strengths.has(link.strength)) return false;

      // In focus mode: only show edges directly involving the focus node,
      // and apply direction filtering to those edges
      if (focus) {
        const isFocusEdge = srcId === focus || tgtId === focus;
        if (!isFocusEdge) return false;
        if (direction === 'out' && srcId !== focus) return false;
        if (direction === 'in' && tgtId !== focus) return false;
      }

      return true;
    });

    fg.refresh();
  });

  onDestroy(() => {
    if (handleKeydownFn) window.removeEventListener('keydown', handleKeydownFn);
    if (handleKeyupFn) window.removeEventListener('keyup', handleKeyupFn);
    if (rafId !== null) cancelAnimationFrame(rafId);
    if (cameraTimer !== null) clearTimeout(cameraTimer);
    if (fg) {
      const scene = fg.scene();
      if (scene) {
        for (const [, ring] of selectionRings) {
          scene.remove(ring);
        }
        if (focusRing) scene.remove(focusRing);
      }
      try {
        fg._destructor();
      } catch {
        // ignore cleanup errors
      }
    }
    selectionRings.clear();
    focusRing = null;
  });
</script>

<div
  class="relative h-full w-full overflow-hidden rounded-lg border border-secondary-200 dark:border-secondary-700"
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

  <!-- Interaction hints — visible when no mode is active -->
  {#if !focusNodeId && adHocSelection.size === 0}
    <div class="absolute bottom-3 left-3 z-10 rounded-md px-2.5 py-1.5 text-[10px] text-secondary-400 backdrop-blur-sm dark:text-secondary-500"
      style={overlayBg}>
      <span class="font-medium">⌘+click</span> multi-select · <span class="font-medium">F+click</span> focus · <span class="font-medium">drag</span> pin
    </div>
  {/if}

  <!-- Ad-hoc selection indicator (hidden while focus mode is active) -->
  {#if adHocSelection.size > 0 && !focusNodeId}
    <div class="absolute bottom-3 left-3 z-10 flex items-center gap-2 rounded-md px-3 py-2 text-xs font-medium text-secondary-700 shadow-sm ring-1 ring-secondary-200 backdrop-blur-sm dark:text-secondary-300 dark:ring-secondary-700"
      style={overlayBg}>
      {#if selectionCommitted}
        <span class="inline-block h-2 w-2 rounded-full bg-primary-500"></span>
        Showing {adHocSelection.size} nodes
      {:else}
        <span class="inline-block h-2 w-2 rounded-full bg-amber-400"></span>
        {adHocSelection.size} selected — <kbd class="rounded bg-secondary-200 px-1 py-0.5 text-[10px] dark:bg-secondary-700">Enter</kbd> to focus
      {/if}
      <button
        onclick={clearSelection}
        class="ml-1 rounded px-1.5 py-0.5 text-secondary-400 transition hover:bg-secondary-200 hover:text-secondary-600 dark:hover:bg-secondary-700 dark:hover:text-secondary-200"
        title="Clear selection (Esc)"
      >
        ✕
      </button>
    </div>
  {/if}

  <!-- Focus mode overlay: direction toggles + breadcrumb trail -->
  {#if focusNodeId}
    {@const focusNode = graph.nodes.find(n => n.id === focusNodeId)}
    <div class="absolute bottom-3 left-3 z-10 flex flex-col gap-2 rounded-lg p-3 shadow-lg ring-1 ring-secondary-200 backdrop-blur-sm dark:ring-secondary-700"
      style="{overlayBg}; max-width: 420px;">
      <!-- Header: focus node name + exit -->
      <div class="flex items-center justify-between gap-3">
        <div class="flex items-center gap-2 min-w-0">
          <span class="inline-block h-2.5 w-2.5 shrink-0 rounded-full" style="background-color: {getConcernColour(focusNode?.bmmConcern || '')}"></span>
          <span class="truncate text-sm font-semibold text-secondary-800 dark:text-white">
            {focusNode?.friendlyName || focusNodeId}
          </span>
          <span class="shrink-0 text-xs text-secondary-400 dark:text-secondary-500">
            — hold F + click to travel
          </span>
        </div>
        <button
          onclick={exitFocusMode}
          class="shrink-0 rounded px-1.5 py-0.5 text-secondary-400 transition hover:bg-secondary-200 hover:text-secondary-600 dark:hover:bg-secondary-700 dark:hover:text-secondary-200"
          title="Exit focus mode (Esc)"
        >
          ✕
        </button>
      </div>

      <!-- Direction toggles -->
      <div class="flex items-center gap-1">
        <span class="mr-1 text-xs text-secondary-500 dark:text-secondary-400">Direction</span>
        {#each [{ value: 'in', label: '← In' }, { value: 'both', label: '↔ Both' }, { value: 'out', label: 'Out →' }] as dir}
          <button
            onclick={() => focusDirection = dir.value as 'in' | 'out' | 'both'}
            class="rounded-full border px-2.5 py-0.5 text-xs font-medium transition
              {focusDirection === dir.value
                ? 'text-white'
                : 'border-secondary-300 text-secondary-500 hover:border-secondary-400 dark:border-secondary-600 dark:text-secondary-400 dark:hover:border-secondary-500'}"
            style={focusDirection === dir.value
              ? `background-color: ${getConcernColour(focusNode?.bmmConcern || '')}; border-color: ${getConcernColour(focusNode?.bmmConcern || '')}`
              : ''}
          >
            {dir.label}
          </button>
        {/each}
      </div>

      <!-- Breadcrumb trail (only shown after at least one traversal) -->
      {#if focusBreadcrumb.length > 0}
        <div class="flex flex-wrap items-center gap-1 text-xs">
          {#each focusBreadcrumb as crumbId, idx}
            {@const crumbNode = graph.nodes.find(n => n.id === crumbId)}
            <button
              onclick={() => jumpToBreadcrumb(idx)}
              class="rounded px-1.5 py-0.5 text-secondary-500 transition hover:bg-secondary-100 hover:text-secondary-700 dark:text-secondary-400 dark:hover:bg-secondary-700 dark:hover:text-secondary-200"
            >
              {crumbNode?.friendlyName || crumbId}
            </button>
            <span class="text-secondary-300 dark:text-secondary-600">→</span>
          {/each}
          <span class="font-medium" style="color: {getConcernColour(focusNode?.bmmConcern || '')}">
            {focusNode?.friendlyName || focusNodeId}
          </span>
        </div>
      {/if}
    </div>
  {/if}
</div>
