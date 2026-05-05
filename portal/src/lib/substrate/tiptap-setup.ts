/**
 * Tiptap editor setup for the substrate editor.
 *
 * Builds an editor instance configured with the five substrate block types
 * mapped onto Tiptap nodes:
 *
 *   document_root → doc        (built-in)
 *   heading       → heading    (built-in)
 *   paragraph     → paragraph  (built-in)
 *   table         → table      (extension-table family)
 *   principle     → principle  (custom node, defined here)
 *   code          → codeBlock  (extension-code-block; W-137 / S351;
 *                                language attr from props.language)
 *
 * The unresolved-reference decoration is a ProseMirror plugin that
 * reads each `principle` node's `entity_type`/`entity_id` attrs and
 * marks the node when validation fails. The validation result is
 * passed in via editor storage rather than being computed here, so
 * the host page can refresh it in response to save events.
 */

import { Editor, Extension, Mark, type EditorOptions } from '@tiptap/core';
import { Document } from '@tiptap/extension-document';
import { Paragraph } from '@tiptap/extension-paragraph';
import { Heading } from '@tiptap/extension-heading';
import { Text } from '@tiptap/extension-text';
import { History } from '@tiptap/extension-history';
import { Table } from '@tiptap/extension-table';
import { TableRow } from '@tiptap/extension-table-row';
import { TableCell } from '@tiptap/extension-table-cell';
import { TableHeader } from '@tiptap/extension-table-header';
import { Bold } from '@tiptap/extension-bold';
import { Italic } from '@tiptap/extension-italic';
import { Code } from '@tiptap/extension-code';
import { CodeBlock } from '@tiptap/extension-code-block';
import { Node, mergeAttributes } from '@tiptap/core';
import { Plugin, PluginKey } from '@tiptap/pm/state';
import { Decoration, DecorationSet } from '@tiptap/pm/view';

// ---------- block-id pass-through extension ----------

/**
 * Adds a `data-block-id` global attribute to every block-level node.
 * This means heading, paragraph, principle, table, codeBlock all carry
 * their substrate block_id into and out of the editor.
 */
const BlockIdAttribute = Extension.create({
    name: 'blockIdAttribute',
    addGlobalAttributes() {
        return [
            {
                types: ['doc', 'heading', 'paragraph', 'principle', 'table', 'codeBlock'],
                attributes: {
                    'data-block-id': {
                        default: null,
                        parseHTML: (el) => el.getAttribute('data-block-id'),
                        renderHTML: (attrs) => {
                            const id = attrs['data-block-id'];
                            return id ? { 'data-block-id': id } : {};
                        }
                    }
                }
            }
        ];
    }
});

// ---------- wikilink custom mark ----------

/**
 * `wikilink` inline mark — Obsidian-style vault reference.
 *
 * A wikilink in source markdown is `[[target]]` or `[[target|alias]]`.
 * In substrate prose it is stored as a text run with this mark attached:
 *
 *   { type: 'text', text: <alias>, marks: [
 *       { type: 'wikilink', attrs: { target: <target>, alias: <alias> } }
 *   ] }
 *
 * Rendered as `<a class="wikilink" data-target="...">alias</a>` so styling
 * and click-to-navigate behaviour can be added by the host page (the link
 * itself does not navigate yet — that is a separate work item).
 *
 * The alias attr is stored alongside target so a save round-trip through
 * the editor recovers the original `[[target|alias]]` form even if the
 * displayed text was edited away from the alias. (For the current pass
 * the alias attr equals the rendered text on creation.)
 */
const Wikilink = Mark.create({
    name: 'wikilink',
    inclusive: false,
    spanning: false,
    excludes: 'code',

    addAttributes() {
        return {
            target: { default: null },
            alias: { default: null }
        };
    },

    parseHTML() {
        return [{ tag: 'a.wikilink' }];
    },

    renderHTML({ HTMLAttributes }) {
        return [
            'a',
            mergeAttributes(HTMLAttributes, {
                class: 'wikilink',
                href: '#',
                'data-target': HTMLAttributes.target ?? ''
            }),
            0
        ];
    }
});

// ---------- principle custom node ----------

/**
 * `principle` block — substrate-specific block type for principle
 * elaborations. Carries `entity_type`/`entity_id` for binding to a
 * principle in the concept graph.
 *
 * Renders as a `<aside class="principle-block">` with the binding
 * shown in a header strip. Inline content is paragraph-shaped.
 */
const Principle = Node.create({
    name: 'principle',
    group: 'block',
    content: 'inline*',
    defining: true,

    addAttributes() {
        return {
            entity_type: { default: null },
            entity_id: { default: null }
        };
    },

    parseHTML() {
        return [{ tag: 'aside.principle-block' }];
    },

    renderHTML({ HTMLAttributes }) {
        return [
            'aside',
            mergeAttributes(HTMLAttributes, { class: 'principle-block' }),
            ['div', { class: 'principle-binding', contenteditable: 'false' },
                ['span', { class: 'principle-binding-label' }, 'principle']
            ],
            ['div', { class: 'principle-body' }, 0]
        ];
    }
});

// ---------- unresolved-reference decoration ----------

const unresolvedRefKey = new PluginKey('substrate-unresolved-refs');

interface UnresolvedRefStorage {
    unresolvedBlockIds: Set<string>;
}

const UnresolvedRefPlugin = Extension.create<unknown, UnresolvedRefStorage>({
    name: 'unresolvedRefPlugin',

    addStorage() {
        return { unresolvedBlockIds: new Set<string>() };
    },

    addProseMirrorPlugins() {
        const storage = this.storage as unknown as UnresolvedRefStorage;
        return [
            new Plugin({
                key: unresolvedRefKey,
                props: {
                    decorations: (state) => {
                        const decs: Decoration[] = [];
                        state.doc.descendants((node, pos) => {
                            if (node.type.name !== 'principle') return;
                            const id = node.attrs['data-block-id'] as string | null;
                            if (id && storage.unresolvedBlockIds.has(id)) {
                                decs.push(
                                    Decoration.node(pos, pos + node.nodeSize, {
                                        class: 'principle-block--unresolved',
                                        title: 'Bound entity does not resolve'
                                    })
                                );
                            }
                        });
                        return DecorationSet.create(state.doc, decs);
                    }
                }
            })
        ];
    }
});

// ---------- factory ----------

export interface SubstrateEditorConfig {
    element: HTMLElement;
    initialDoc: Record<string, unknown>;
    onUpdate: () => void;
    editable?: boolean;
}

export function createSubstrateEditor(config: SubstrateEditorConfig): Editor {
    const options: Partial<EditorOptions> = {
        element: config.element,
        editable: config.editable ?? true,
        extensions: [
            Document,
            Paragraph,
            Heading.configure({ levels: [1, 2, 3, 4] }),
            Text,
            History,
            Table.configure({ resizable: false }),
            TableRow,
            TableHeader,
            TableCell,
            Bold,
            Italic,
            Code,
            CodeBlock,
            Wikilink,
            Principle,
            BlockIdAttribute,
            UnresolvedRefPlugin
        ],
        content: config.initialDoc,
        onUpdate: () => config.onUpdate()
    };
    return new Editor(options);
}

/**
 * Update the unresolved-block-id set on an existing editor and force
 * a redraw so the decorations re-render.
 */
export function setUnresolvedBlocks(editor: Editor, ids: Iterable<string>): void {
    const storage = (editor.storage as unknown as Record<string, unknown>)
        .unresolvedRefPlugin as UnresolvedRefStorage | undefined;
    if (!storage) return;
    storage.unresolvedBlockIds = new Set(ids);
    // Trigger a no-op transaction so the decoration plugin recomputes.
    editor.view.dispatch(editor.state.tr);
}
