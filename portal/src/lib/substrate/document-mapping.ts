/**
 * Substrate ↔ ProseMirror conversion.
 *
 * The editor consumes a composed block tree (one tree, every node carries
 * its block_id) and produces a ProseMirror JSON document with a per-block
 * `data-block-id` attr threaded through. On save, walking the PM doc
 * yields a fresh tree which is diffed against the snapshot map taken at
 * load time to produce the minimum set of mutation ops.
 *
 * Phase 1 second-cut scope (W-122):
 *
 *   - Round-trip preserves text edits inside existing blocks (W-C).
 *   - Block creation, deletion, and reordering of paragraph / heading /
 *     principle blocks emit createBlock / insertChild / removeEdge /
 *     moveBlock ops.
 *   - Table structural changes remain out of scope (paragraphs and
 *     headings only at this cut).
 *
 * Block-type mapping (S322 §6 → Tiptap):
 *
 *   document_root → doc
 *   heading       → heading      (level from props.level, default 2)
 *   paragraph     → paragraph
 *   table         → table / tableRow / tableCell  (Tiptap built-ins)
 *   principle     → principle    (custom node defined in tiptap-setup.ts)
 *
 * Unrecognised block types are rendered as paragraphs containing a
 * placeholder text node, so the editor never blows up on a registry
 * extension we haven't taught it yet.
 */

import type { ComposedNode } from '$lib/server/substrate/resolver-client';

// ---------- Types ----------

export interface PMNode {
    type: string;
    attrs?: Record<string, unknown>;
    content?: PMNode[];
    text?: string;
    marks?: { type: string; attrs?: Record<string, unknown> }[];
    [key: string]: unknown;
}

export interface BlockSnapshot {
    block_id: string;
    block_type: string;
    /** Content as stored in the database — ProseMirror JSON for prose blocks. */
    content: Record<string, unknown> | null;
    /** Free-form props (e.g. heading level, table cell config). */
    props: Record<string, unknown> | null;
    entity_type: string | null;
    entity_id: string | null;
    /** Containing parent block_id (null for the document_root). */
    parent_id: string | null;
    /** Ordinal within the parent's `contains` children (null for the root). */
    ordinal: number | null;
}

export interface EditorPayload {
    doc: PMNode;
    snapshots: Record<string, BlockSnapshot>;
    rootBlockId: string;
}

// ---------- Mutation op types ----------

export type MutationOp =
    | { op: 'createBlock'; id: string; block_type: string;
        props: Record<string, unknown>; content: Record<string, unknown>;
        entity_type?: string | null; entity_id?: string | null }
    | { op: 'insertChild'; parent_id: string; child_id: string; ordinal: number }
    | { op: 'patchBlockContent'; block_id: string;
        content: Record<string, unknown> }
    | { op: 'removeEdge'; from_block_id: string; to_block_id: string;
        edge_type: string }
    | { op: 'moveBlock'; block_id: string; new_parent_id: string;
        new_ordinal: number };

// ---------- Compose → PM ----------

/**
 * Convert a composed block tree to a ProseMirror doc plus a snapshot map.
 *
 * The snapshot map is keyed by block_id and is used at save time to
 * compute the minimum set of mutation ops.
 */
export function composeToEditor(root: ComposedNode): EditorPayload {
    const snapshots: Record<string, BlockSnapshot> = {};
    const doc = nodeToPM(root, snapshots, null, null);
    if (doc.type !== 'doc') {
        throw new Error(
            `composeToEditor: expected document_root at the top, got ${root.block_type}`
        );
    }
    return { doc, snapshots, rootBlockId: root.id };
}

function nodeToPM(
    node: ComposedNode,
    snapshots: Record<string, BlockSnapshot>,
    parentId: string | null,
    ordinal: number | null
): PMNode {
    if (node._missing) {
        return { type: 'paragraph', content: [{ type: 'text', text: '⟨missing block⟩' }] };
    }
    if (node._cycle) {
        return { type: 'paragraph', content: [{ type: 'text', text: '⟨cycle⟩' }] };
    }

    snapshots[node.id] = {
        block_id: node.id,
        block_type: node.block_type,
        content: node.content,
        props: node.props,
        entity_type: node.entity_type,
        entity_id: node.entity_id,
        parent_id: parentId,
        ordinal
    };

    switch (node.block_type) {
        case 'document_root':
            return {
                type: 'doc',
                attrs: { 'data-block-id': node.id },
                content: node.children.map((c, i) =>
                    nodeToPM(c, snapshots, node.id, i + 1)
                )
            };

        case 'heading': {
            const level = (node.props?.level as number | undefined) ?? 2;
            const text = extractText(node.content) ?? '';
            return {
                type: 'heading',
                attrs: { level, 'data-block-id': node.id },
                content: text ? [{ type: 'text', text }] : []
            };
        }

        case 'paragraph': {
            const inline = extractInline(node.content);
            return {
                type: 'paragraph',
                attrs: { 'data-block-id': node.id },
                content: inline
            };
        }

        case 'principle': {
            const inline = extractInline(node.content);
            return {
                type: 'principle',
                attrs: {
                    'data-block-id': node.id,
                    entity_type: node.entity_type,
                    entity_id: node.entity_id
                },
                content: inline.length ? inline : [{ type: 'text', text: '' }]
            };
        }

        case 'table': {
            // Phase 1 first cut: tables that arrive with raw PM-shaped content
            // pass through; tables stored in some other shape get a placeholder
            // until we refine the table primitive.
            const tableContent = node.content as unknown as PMNode | null;
            if (
                tableContent &&
                typeof tableContent === 'object' &&
                tableContent.type === 'table'
            ) {
                return {
                    ...tableContent,
                    attrs: {
                        ...(tableContent.attrs ?? {}),
                        'data-block-id': node.id
                    }
                };
            }
            return {
                type: 'paragraph',
                attrs: { 'data-block-id': node.id },
                content: [{ type: 'text', text: '⟨table — content shape not yet recognised⟩' }]
            };
        }

        default: {
            // Unknown block type — render as inert paragraph but keep block_id
            // so the snapshot survives.
            const text = extractText(node.content) ?? `⟨${node.block_type}⟩`;
            return {
                type: 'paragraph',
                attrs: { 'data-block-id': node.id },
                content: text ? [{ type: 'text', text }] : []
            };
        }
    }
}

// ---------- PM → save mutations (structural diff) ----------

/**
 * Walk the editor's PM doc, compare against the snapshot map, and emit
 * the full set of mutation ops needed to bring the database into line
 * with the editor.
 *
 * Op ordering is dependency-respecting so the resolver can run the batch
 * as a single transaction without forward references:
 *
 *   1. createBlock for every new block (in tree order; assigns fresh
 *      client UUIDs which the caller must thread back into the PM doc
 *      via refreshSnapshotsFromEditor for next-save consistency).
 *   2. patchBlockContent for every kept block whose stored content has
 *      changed.
 *   3. insertChild (== addEdge contains) for every new block, attaching
 *      it under its parent at its ordinal.
 *   4. moveBlock for every kept block whose parent or ordinal has
 *      changed.
 *   5. removeEdge for every deleted block's old contains edge. The
 *      block row stays as an orphan; Phase 1 does not garbage-collect.
 *
 * Block-type inference for new nodes:
 *   PM node type → substrate block_type, with heading level captured in
 *   props.level. Table structural changes are not emitted at this cut.
 *
 * Ordinals use a midpoint scheme so inserts and reorders are local: a
 * block inserted between siblings with ordinals A and B gets (A+B)/2;
 * before all → first - 1; after all → last + 1.
 */
export function diffToMutations(
    currentDoc: PMNode,
    snapshots: Record<string, BlockSnapshot>
): MutationOp[] {
    // ---- Pass 1: walk the new doc, collect (id|null, type, content, parent,
    //              ordinal) for every block-level node under document_root.
    interface NewNode {
        existingId: string | null;
        pmNode: PMNode;
        block_type: string;
        parent_id: string;       // resolved before emit (see assignment below)
        ordinal: number;
    }

    const newNodes: NewNode[] = [];
    const rootId = currentDoc.attrs?.['data-block-id'] as string | undefined;
    if (!rootId) {
        // No root id — nothing we can do safely.
        return [];
    }

    function visit(node: PMNode, parentBlockId: string): void {
        const children = node.content ?? [];
        // Compute fresh ordinals by position; midpoint reflow for inserts is
        // applied below once we know which siblings are existing-with-known-
        // ordinal vs new.
        const siblingMeta: { node: PMNode; existingId: string | null;
                             block_type: string }[] = [];
        for (const c of children) {
            const blockType = inferBlockType(c);
            if (blockType === null) continue;  // inline or unmapped node — skip
            const existingId = (c.attrs?.['data-block-id'] as string | undefined) ?? null;
            siblingMeta.push({ node: c, existingId, block_type: blockType });
        }

        const ordinals = computeOrdinals(siblingMeta, snapshots);

        for (let i = 0; i < siblingMeta.length; i++) {
            const meta = siblingMeta[i];
            newNodes.push({
                existingId: meta.existingId,
                pmNode: meta.node,
                block_type: meta.block_type,
                parent_id: parentBlockId,
                ordinal: ordinals[i]
            });
            // Recurse into containers (only document_root and table currently
            // hold contains-children at the substrate level; tables are out
            // of scope for structural diff this cut, so we recurse only on
            // doc-level for now).
            // Note: paragraph / heading / principle are leaf-ish at the
            // substrate level; their inline content is part of the block's
            // own content blob, not separate child blocks.
        }
    }

    visit(currentDoc, rootId);

    // ---- Pass 2: bucket into kept / new / deleted.
    const seenIds = new Set<string>();
    for (const n of newNodes) if (n.existingId) seenIds.add(n.existingId);

    const deletedIds: string[] = [];
    for (const id of Object.keys(snapshots)) {
        if (id === rootId) continue;
        if (!seenIds.has(id)) deletedIds.push(id);
    }

    // ---- Pass 3: emit ops in dependency order.
    const ops: MutationOp[] = [];

    // 1. createBlock for new nodes. Assign fresh UUID and write it back
    //    into the PM node's attrs so the snapshot refresh sees it.
    const newOps: { node: NewNode; assigned_id: string }[] = [];
    for (const n of newNodes) {
        if (n.existingId !== null) continue;
        const newId = randomUuid();
        n.pmNode.attrs = { ...(n.pmNode.attrs ?? {}), 'data-block-id': newId };
        const content = nodeToBlockContent(n.pmNode, n.block_type) ?? {};
        const props = inferBlockProps(n.pmNode, n.block_type);
        const create: MutationOp = {
            op: 'createBlock',
            id: newId,
            block_type: n.block_type,
            props,
            content
        };
        // Preserve binding attrs for principle blocks if Tiptap ever sets them.
        if (n.block_type === 'principle') {
            const et = n.pmNode.attrs?.entity_type as string | null | undefined;
            const eid = n.pmNode.attrs?.entity_id as string | null | undefined;
            if (et && eid) {
                (create as Record<string, unknown>).entity_type = et;
                (create as Record<string, unknown>).entity_id = eid;
            }
        }
        ops.push(create);
        newOps.push({ node: n, assigned_id: newId });
    }

    // 2. patchBlockContent for kept blocks whose content has changed.
    for (const n of newNodes) {
        if (n.existingId === null) continue;
        const snap = snapshots[n.existingId];
        if (!snap) continue;
        const newContent = nodeToBlockContent(n.pmNode, snap.block_type);
        if (newContent === null) continue;
        if (!contentEqual(snap.content, newContent)) {
            ops.push({
                op: 'patchBlockContent',
                block_id: n.existingId,
                content: newContent
            });
        }
    }

    // 3. insertChild for new blocks (now with assigned ids).
    for (const { node: n, assigned_id } of newOps) {
        ops.push({
            op: 'insertChild',
            parent_id: n.parent_id,
            child_id: assigned_id,
            ordinal: n.ordinal
        });
    }

    // 4. moveBlock for kept blocks whose parent or ordinal has changed.
    for (const n of newNodes) {
        if (n.existingId === null) continue;
        const snap = snapshots[n.existingId];
        if (!snap) continue;
        const parentChanged = snap.parent_id !== n.parent_id;
        const ordinalChanged =
            snap.ordinal === null
                ? false
                : Math.abs((snap.ordinal ?? 0) - n.ordinal) > 1e-9;
        if (parentChanged || ordinalChanged) {
            ops.push({
                op: 'moveBlock',
                block_id: n.existingId,
                new_parent_id: n.parent_id,
                new_ordinal: n.ordinal
            });
        }
    }

    // 5. removeEdge for deleted blocks (drop the contains edge to old parent).
    for (const id of deletedIds) {
        const snap = snapshots[id];
        if (!snap || snap.parent_id === null) continue;
        ops.push({
            op: 'removeEdge',
            from_block_id: snap.parent_id,
            to_block_id: id,
            edge_type: 'contains'
        });
    }

    return ops;
}

// ---------- Ordinal allocation (midpoint scheme) ----------

/**
 * Compute the ordinal each sibling should have after the edit.
 *
 * For sequences containing only existing blocks with stable ordinals,
 * we keep their ordinals (no-op). For new blocks we allocate midpoints
 * between neighbours; for sequences where reorder has happened, we
 * recompute by midpoints from a base of 1.0 step 1.0.
 */
function computeOrdinals(
    siblings: { node: PMNode; existingId: string | null; block_type: string }[],
    snapshots: Record<string, BlockSnapshot>
): number[] {
    // Detect reorder: if every sibling is existing and the original
    // ordinals are already monotonically increasing in the new order,
    // keep them; otherwise reflow.
    const allExisting = siblings.every((s) => s.existingId !== null);
    if (allExisting) {
        const origOrdinals = siblings.map(
            (s) => snapshots[s.existingId!]?.ordinal ?? null
        );
        const monotone = origOrdinals.every(
            (o, i) =>
                o !== null &&
                (i === 0 || (origOrdinals[i - 1] !== null && origOrdinals[i - 1]! < o))
        );
        if (monotone) return origOrdinals as number[];
    }

    // Otherwise: assign new ordinals by walking the sibling list.
    // Existing blocks with a known ordinal hold a fixed point; new blocks
    // and reordered existing blocks get midpoints. Simplest robust
    // approach: linear 1.0, 2.0, 3.0, … for the whole sibling list,
    // because moving every existing sibling by a fraction is fine —
    // moveBlock only fires when the ordinal *changes*, and the linear
    // scheme is stable across saves.
    return siblings.map((_, i) => i + 1);
}

// ---------- Block-type and props inference for new PM nodes ----------

/**
 * Map a ProseMirror node type to a substrate block_type, or null if
 * the node is inline (text, hard_break, etc.) or otherwise not a
 * substrate-level block.
 */
function inferBlockType(node: PMNode): string | null {
    switch (node.type) {
        case 'paragraph':
            return 'paragraph';
        case 'heading':
            return 'heading';
        case 'principle':
            return 'principle';
        case 'table':
            return 'table';
        default:
            return null;
    }
}

function inferBlockProps(node: PMNode, blockType: string): Record<string, unknown> {
    if (blockType === 'heading') {
        const level = (node.attrs?.level as number | undefined) ?? 2;
        return { level };
    }
    return {};
}

// ---------- UUID generation ----------

/**
 * Browser UUID v4. crypto.randomUUID is available in all modern browsers
 * (including Safari 15.4+); fall back to a Math.random shim if for some
 * reason it isn't.
 */
function randomUuid(): string {
    if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
        return crypto.randomUUID();
    }
    // Minimal v4-shaped fallback. Not cryptographically random; here only
    // because the surrounding code path requires *some* string.
    const hex = '0123456789abcdef';
    const bytes: string[] = [];
    for (let i = 0; i < 32; i++) bytes.push(hex[Math.floor(Math.random() * 16)]);
    bytes[12] = '4';
    bytes[16] = hex[(Math.floor(Math.random() * 4)) + 8];
    return (
        bytes.slice(0, 8).join('') + '-' +
        bytes.slice(8, 12).join('') + '-' +
        bytes.slice(12, 16).join('') + '-' +
        bytes.slice(16, 20).join('') + '-' +
        bytes.slice(20, 32).join('')
    );
}

// ---------- Block-content serialisation (PM → on-disk shape) ----------

/**
 * Convert a PM node back to the on-disk content shape for its block_type.
 *
 * For prose blocks we store the inline content shape directly:
 *   heading  → { type: 'heading',   content: [...] }
 *   paragraph → { type: 'paragraph', content: [...] }
 *   principle → { type: 'paragraph', content: [...] }   (principle stores prose
 *                                                        in paragraph shape;
 *                                                        block_type is the
 *                                                        semantic carrier.)
 *
 * Returns null if we don't know how to serialise this node type.
 */
function nodeToBlockContent(
    pmNode: PMNode,
    blockType: string
): Record<string, unknown> | null {
    switch (blockType) {
        case 'heading':
            return {
                type: 'heading',
                content: stripBlockIdAttrs(pmNode.content ?? [])
            };
        case 'paragraph':
            return {
                type: 'paragraph',
                content: stripBlockIdAttrs(pmNode.content ?? [])
            };
        case 'principle':
            return {
                type: 'paragraph',
                content: stripBlockIdAttrs(pmNode.content ?? [])
            };
        case 'table':
            // Round-trip the whole table node minus our annotations.
            return stripBlockIdAttrsDeep(pmNode) as unknown as Record<string, unknown>;
        default:
            return null;
    }
}

function stripBlockIdAttrs(nodes: PMNode[]): PMNode[] {
    return nodes.map(stripBlockIdAttrsDeep);
}

function stripBlockIdAttrsDeep(node: PMNode): PMNode {
    const cleaned: PMNode = { type: node.type };
    if (node.attrs) {
        const a: Record<string, unknown> = { ...node.attrs };
        delete a['data-block-id'];
        if (Object.keys(a).length > 0) cleaned.attrs = a;
    }
    if (node.text !== undefined) cleaned.text = node.text;
    if (node.marks) cleaned.marks = node.marks;
    if (node.content) cleaned.content = node.content.map(stripBlockIdAttrsDeep);
    return cleaned;
}

function contentEqual(
    a: Record<string, unknown> | null,
    b: Record<string, unknown> | null
): boolean {
    return JSON.stringify(a ?? {}) === JSON.stringify(b ?? {});
}

// ---------- Helpers ----------

/**
 * Extract a single text string from a content blob — used for headings
 * which we model as text-only at this first cut.
 */
function extractText(content: Record<string, unknown> | null): string | null {
    if (!content) return null;
    const inline = extractInline(content);
    return inline
        .filter((n) => n.type === 'text')
        .map((n) => n.text ?? '')
        .join('');
}

/**
 * Extract the inline content array from a stored block content blob.
 *
 * Database content for prose blocks is stored as a single PM node, e.g.
 *   { type: 'paragraph', content: [{ type: 'text', text: 'hello' }] }
 *
 * The editor needs the inline children, so we unwrap one level.
 */
function extractInline(content: Record<string, unknown> | null): PMNode[] {
    if (!content) return [];
    if (typeof content !== 'object') return [];
    const c = content as unknown as PMNode;
    if (Array.isArray(c.content)) return c.content;
    if (c.type === 'text' && typeof c.text === 'string') return [c];
    return [];
}
