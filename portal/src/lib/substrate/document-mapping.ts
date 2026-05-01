/**
 * Substrate ↔ ProseMirror conversion.
 *
 * The editor consumes a composed block tree (one tree, every node carries
 * its block_id) and produces a ProseMirror JSON document with a per-block
 * `data-block-id` attr threaded through. On save, walking the PM doc
 * yields a fresh content map by block_id, which is diffed against the
 * snapshot taken at load time to produce the minimum set of
 * `patchBlockContent` mutations.
 *
 * Phase 1 first cut scope:
 *
 *   - Round-trip preserves text edits inside existing blocks.
 *   - Block creation, deletion, and reordering are out of scope; the
 *     diff path silently ignores structural changes for now.
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
}

export interface EditorPayload {
    doc: PMNode;
    snapshots: Record<string, BlockSnapshot>;
    rootBlockId: string;
}

// ---------- Compose → PM ----------

/**
 * Convert a composed block tree to a ProseMirror doc plus a snapshot map.
 *
 * The snapshot map is keyed by block_id and is used at save time to
 * compute the minimum set of `patchBlockContent` mutations.
 */
export function composeToEditor(root: ComposedNode): EditorPayload {
    const snapshots: Record<string, BlockSnapshot> = {};
    const doc = nodeToPM(root, snapshots);
    if (doc.type !== 'doc') {
        throw new Error(
            `composeToEditor: expected document_root at the top, got ${root.block_type}`
        );
    }
    return { doc, snapshots, rootBlockId: root.id };
}

function nodeToPM(node: ComposedNode, snapshots: Record<string, BlockSnapshot>): PMNode {
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
        entity_id: node.entity_id
    };

    switch (node.block_type) {
        case 'document_root':
            return {
                type: 'doc',
                attrs: { 'data-block-id': node.id },
                content: node.children.map((c) => nodeToPM(c, snapshots))
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

// ---------- PM → save mutations ----------

/**
 * Walk the editor's PM doc, gather every node carrying a block_id, and
 * diff each against the snapshot. Returns one `patchBlockContent` op per
 * block whose content has changed.
 *
 * Structural changes (added / removed / reparented blocks) are deliberately
 * ignored at this first cut; they need a tree-diff which we'll do in a
 * follow-up.
 */
export function diffToMutations(
    currentDoc: PMNode,
    snapshots: Record<string, BlockSnapshot>
): { op: 'patchBlockContent'; block_id: string; content: Record<string, unknown> }[] {
    const ops: { op: 'patchBlockContent'; block_id: string; content: Record<string, unknown> }[] =
        [];

    const visited = new Set<string>();

    walk(currentDoc, (node) => {
        const id = (node.attrs?.['data-block-id'] as string | undefined) ?? null;
        if (!id) return;
        if (visited.has(id)) return;
        visited.add(id);
        const snap = snapshots[id];
        if (!snap) return;

        const newContent = nodeToBlockContent(node, snap.block_type);
        if (newContent === null) return;
        if (!contentEqual(snap.content, newContent)) {
            ops.push({ op: 'patchBlockContent', block_id: id, content: newContent });
        }
    });

    return ops;
}

function walk(node: PMNode, visit: (n: PMNode) => void): void {
    visit(node);
    if (node.content) {
        for (const c of node.content) walk(c, visit);
    }
}

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
