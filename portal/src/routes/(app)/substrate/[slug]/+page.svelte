<script lang="ts">
    import { onMount, onDestroy } from 'svelte';
    import { deserialize } from '$app/forms';
    import type { ActionResult } from '@sveltejs/kit';
    import type { PageData } from './$types';
    import { Editor } from '@tiptap/core';
    import {
        createSubstrateEditor,
        setUnresolvedBlocks
    } from '$lib/substrate/tiptap-setup';
    import {
        composeToEditor,
        diffToMutations,
        type EditorPayload,
        type PMNode
    } from '$lib/substrate/document-mapping';

    let { data }: { data: PageData } = $props();

    let editorContainer: HTMLDivElement | undefined = $state();
    let editor: Editor | undefined = $state();
    let payload: EditorPayload = $state.raw(composeToEditor(data.tree));
    let dirty = $state(false);
    let saving = $state(false);
    let saveStatus = $state<{ kind: 'idle' | 'ok' | 'error'; message: string }>({
        kind: 'idle',
        message: ''
    });
    let unresolvedCount = $state(0);

    let baseRevision = $state<string | null>(null);

    let saveTimer: ReturnType<typeof setTimeout> | null = null;
    const SAVE_DEBOUNCE_MS = 1500;

    onMount(() => {
        if (!editorContainer) return;
        editor = createSubstrateEditor({
            element: editorContainer,
            initialDoc: payload.doc as unknown as Record<string, unknown>,
            onUpdate: handleEdit
        });
        // Validate bindings on initial load.
        scheduleBindingValidation();
    });

    onDestroy(() => {
        if (saveTimer) clearTimeout(saveTimer);
        editor?.destroy();
    });

    function handleEdit(): void {
        dirty = true;
        saveStatus = { kind: 'idle', message: '' };
        if (saveTimer) clearTimeout(saveTimer);
        saveTimer = setTimeout(save, SAVE_DEBOUNCE_MS);
    }

    async function save(): Promise<void> {
        if (!editor || saving) return;
        saving = true;
        try {
            const currentDoc = editor.getJSON() as PMNode;
            const ops = diffToMutations(currentDoc, payload.snapshots);

            if (ops.length === 0) {
                dirty = false;
                saveStatus = { kind: 'ok', message: 'No changes to save.' };
                saving = false;
                return;
            }

            const formData = new FormData();
            formData.set('operations', JSON.stringify(ops));
            formData.set('baseRevision', baseRevision ?? '');

            const res = await fetch('?/save', { method: 'POST', body: formData });
            const action = deserialize(await res.text()) as ActionResult<{
                ok: boolean;
                newRevision?: string | null;
                accepted?: number;
                error?: string;
            }>;

            let result: { ok: boolean; newRevision?: string | null; accepted?: number; error?: string };
            if (action.type === 'success' || action.type === 'failure') {
                result = action.data ?? { ok: false, error: 'Action returned no data' };
            } else if (action.type === 'error') {
                result = { ok: false, error: action.error?.message ?? 'Action error' };
            } else {
                result = { ok: false, error: `Unexpected action type: ${action.type}` };
            }

            if (result.ok) {
                dirty = false;
                if (result.newRevision) baseRevision = result.newRevision;
                // Refresh snapshots so the next diff is against what we just saved.
                refreshSnapshotsFromEditor();
                saveStatus = {
                    kind: 'ok',
                    message: `Saved ${result.accepted ?? 0} change${result.accepted === 1 ? '' : 's'}.`
                };
                scheduleBindingValidation();
            } else {
                saveStatus = { kind: 'error', message: result.error ?? 'Unknown error' };
            }
        } catch (e) {
            saveStatus = {
                kind: 'error',
                message: e instanceof Error ? e.message : String(e)
            };
        } finally {
            saving = false;
        }
    }

    function refreshSnapshotsFromEditor(): void {
        if (!editor) return;
        const currentDoc = editor.getJSON() as PMNode;
        const rootId = currentDoc.attrs?.['data-block-id'] as string | undefined;

        // Walk the new doc, collecting (id, block_type, content, parent, ordinal)
        // for every block-level node. We rebuild the snapshot map to match —
        // existing entries refresh in place, new entries (just-created blocks
        // for which the diff assigned ids) get a snapshot of their own,
        // entries no longer present are dropped.
        const seen = new Set<string>();

        const visitContainer = (container: PMNode, parentId: string | null): void => {
            const children = container.content ?? [];
            // Compute ordinals to mirror the diff's allocation: linear 1, 2,
            // 3, … unless every sibling is an existing block in monotonic
            // ordinal order (in which case keep originals). The diff itself
            // is the source of truth; this snapshot refresh just has to
            // produce ordinals consistent with what the resolver was sent.
            let blockChildIndex = 0;
            for (const c of children) {
                const id = c.attrs?.['data-block-id'] as string | undefined;
                if (!id) continue;
                blockChildIndex += 1;
                seen.add(id);
                if (id === rootId) {
                    // Document root snapshot: parent null, ordinal null.
                    if (!payload.snapshots[id]) {
                        payload.snapshots[id] = {
                            block_id: id,
                            block_type: 'document_root',
                            content: null,
                            props: null,
                            entity_type: null,
                            entity_id: null,
                            parent_id: null,
                            ordinal: null
                        };
                    }
                } else {
                    const existing = payload.snapshots[id];
                    const blockType = existing
                        ? existing.block_type
                        : inferBlockTypeFromPM(c);
                    payload.snapshots[id] = {
                        block_id: id,
                        block_type: blockType,
                        content: nodeAsContent(c, blockType),
                        props: existing?.props ?? inferPropsFromPM(c, blockType),
                        entity_type:
                            existing?.entity_type ??
                            ((c.attrs?.entity_type as string | undefined) ?? null),
                        entity_id:
                            existing?.entity_id ??
                            ((c.attrs?.entity_id as string | undefined) ?? null),
                        parent_id: parentId,
                        ordinal: blockChildIndex
                    };
                }
            }
        };

        // The doc node itself carries the document_root id.
        if (rootId) seen.add(rootId);
        if (rootId && !payload.snapshots[rootId]) {
            payload.snapshots[rootId] = {
                block_id: rootId,
                block_type: 'document_root',
                content: null,
                props: null,
                entity_type: null,
                entity_id: null,
                parent_id: null,
                ordinal: null
            };
        }
        visitContainer(currentDoc, rootId ?? null);

        // Drop snapshots whose blocks are no longer in the doc.
        for (const id of Object.keys(payload.snapshots)) {
            if (!seen.has(id)) delete payload.snapshots[id];
        }
    }

    function inferBlockTypeFromPM(node: PMNode): string {
        switch (node.type) {
            case 'paragraph': return 'paragraph';
            case 'heading':   return 'heading';
            case 'principle': return 'principle';
            case 'table':     return 'table';
            case 'codeBlock': return 'code';
            default:          return 'paragraph';
        }
    }

    function inferPropsFromPM(node: PMNode, blockType: string): Record<string, unknown> {
        if (blockType === 'heading') {
            return { level: (node.attrs?.level as number | undefined) ?? 2 };
        }
        if (blockType === 'code') {
            // Mirror document-mapping.ts inferBlockProps — language attr
            // plus concatenated inline text from PM children, lifted into
            // props. The database content jsonb stays empty for code
            // blocks (atomic, props-lifted shape).
            const language = (node.attrs?.language as string | null | undefined) ?? '';
            const text = (node.content ?? [])
                .filter((c) => c.type === 'text')
                .map((c) => (typeof c.text === 'string' ? c.text : ''))
                .join('');
            return { language: language ?? '', text };
        }
        return {};
    }

    function nodeAsContent(
        pmNode: PMNode,
        blockType: string
    ): Record<string, unknown> | null {
        // Mirror the shape produced by diffToMutations so equality holds on
        // the next pass. We deliberately strip our private attrs.
        if (blockType === 'heading' || blockType === 'paragraph' || blockType === 'principle') {
            return {
                type: blockType === 'principle' ? 'paragraph' : blockType,
                content: stripBlockIdAttrsDeep(pmNode.content ?? [])
            };
        }
        if (blockType === 'table') {
            return stripBlockIdAttrsOne(pmNode) as unknown as Record<string, unknown>;
        }
        if (blockType === 'code') {
            // Atomic, props-lifted — content jsonb is empty for code
            // blocks (text and language live in props, captured by
            // inferPropsFromPM).
            return {};
        }
        return null;
    }

    function stripBlockIdAttrsDeep(nodes: PMNode[]): PMNode[] {
        return nodes.map(stripBlockIdAttrsOne);
    }

    function stripBlockIdAttrsOne(node: PMNode): PMNode {
        const cleaned: PMNode = { type: node.type };
        if (node.attrs) {
            const a = { ...node.attrs };
            delete a['data-block-id'];
            if (Object.keys(a).length > 0) cleaned.attrs = a;
        }
        if (node.text !== undefined) cleaned.text = node.text;
        if (node.marks) cleaned.marks = node.marks;
        if (node.content) cleaned.content = node.content.map(stripBlockIdAttrsOne);
        return cleaned;
    }

    async function scheduleBindingValidation(): Promise<void> {
        if (!editor) return;
        const bindings: { block_id: string; entity_type: string; entity_id: string }[] = [];
        for (const snap of Object.values(payload.snapshots)) {
            if (snap.entity_type && snap.entity_id) {
                bindings.push({
                    block_id: snap.block_id,
                    entity_type: snap.entity_type,
                    entity_id: snap.entity_id
                });
            }
        }
        if (bindings.length === 0) {
            unresolvedCount = 0;
            return;
        }

        const formData = new FormData();
        formData.set('bindings', JSON.stringify(bindings));
        const res = await fetch('?/validateBindings', { method: 'POST', body: formData });
        const action = deserialize(await res.text()) as ActionResult<{
            ok: boolean;
            results?: { block_id: string; resolves: boolean }[];
        }>;
        if (action.type !== 'success' && action.type !== 'failure') return;
        const result = action.data;
        if (!result?.ok || !result.results) return;
        const unresolved = result.results
            .filter((r) => !r.resolves)
            .map((r) => r.block_id);
        unresolvedCount = unresolved.length;
        if (editor) setUnresolvedBlocks(editor, unresolved);
    }

    async function saveNow(): Promise<void> {
        if (saveTimer) {
            clearTimeout(saveTimer);
            saveTimer = null;
        }
        await save();
    }
</script>

<svelte:head>
    <title>{data.document.title} — Substrate Editor</title>
</svelte:head>

<div class="px-6 py-6 max-w-4xl mx-auto">
    <header class="mb-4 flex items-baseline gap-3 flex-wrap">
        <a href="/substrate" class="text-xs text-secondary-500 dark:text-secondary-400 hover:text-primary-600">
            ← Substrate
        </a>
        <h1 class="text-xl font-semibold text-secondary-900 dark:text-secondary-100">
            {data.document.title}
        </h1>
        <code class="text-xs text-secondary-500 dark:text-secondary-400">{data.document.slug}</code>
    </header>

    <div class="flex items-center gap-3 mb-3 text-xs">
        {#if dirty && !saving}
            <span class="text-amber-600 dark:text-amber-400">● Unsaved changes</span>
        {:else if saving}
            <span class="text-secondary-500 dark:text-secondary-400">Saving…</span>
        {:else}
            <span class="text-secondary-400 dark:text-secondary-500">Saved</span>
        {/if}

        {#if saveStatus.kind === 'ok' && saveStatus.message}
            <span class="text-green-600 dark:text-green-400">{saveStatus.message}</span>
        {:else if saveStatus.kind === 'error'}
            <span class="text-red-600 dark:text-red-400">{saveStatus.message}</span>
        {/if}

        {#if unresolvedCount > 0}
            <span class="text-amber-600 dark:text-amber-400 ml-auto">
                {unresolvedCount} unresolved binding{unresolvedCount === 1 ? '' : 's'}
            </span>
        {/if}

        <button
            type="button"
            onclick={saveNow}
            disabled={!dirty || saving}
            class="ml-auto px-3 py-1 text-xs rounded border border-secondary-200 dark:border-secondary-700 text-secondary-700 dark:text-secondary-300 hover:bg-secondary-100 dark:hover:bg-secondary-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
            Save now
        </button>
    </div>

    <div
        bind:this={editorContainer}
        class="substrate-editor bg-white dark:bg-secondary-800 border border-secondary-200 dark:border-secondary-700 rounded-lg p-6 max-w-none min-h-[24rem] text-secondary-900 dark:text-secondary-100"
    ></div>
</div>

<style>
    /* Editor surface — explicit styling rather than Tailwind's `prose`
       plugin, because ProseMirror's contenteditable subtree doesn't always
       inherit prose classes reliably and we want predictable dark-mode
       behaviour. The four block types we render (heading / paragraph /
       principle / table) cover the whole stylesheet. */
    :global(.substrate-editor .ProseMirror) {
        outline: none;
        min-height: 20rem;
        font-size: 0.95rem;
        line-height: 1.6;
        color: inherit;
    }

    :global(.substrate-editor .ProseMirror h1) {
        font-size: 1.6rem;
        font-weight: 700;
        margin: 1.4rem 0 0.6rem;
        line-height: 1.25;
    }
    :global(.substrate-editor .ProseMirror h2) {
        font-size: 1.3rem;
        font-weight: 600;
        margin: 1.4rem 0 0.5rem;
        line-height: 1.3;
    }
    :global(.substrate-editor .ProseMirror h3) {
        font-size: 1.1rem;
        font-weight: 600;
        margin: 1.2rem 0 0.4rem;
    }
    :global(.substrate-editor .ProseMirror h4) {
        font-size: 1rem;
        font-weight: 600;
        margin: 1rem 0 0.3rem;
    }

    :global(.substrate-editor .ProseMirror p) {
        margin: 0.6rem 0;
    }

    /* Principle block — a styled aside marking a binding to a principle
       in the concept graph. Light + dark variants set explicitly. */
    :global(.substrate-editor .principle-block) {
        margin: 1rem 0;
        padding: 0.85rem 1rem 0.85rem 1.05rem;
        border-left: 3px solid #14b8a6;
        background: rgba(20, 184, 166, 0.06);
        border-radius: 0 0.4rem 0.4rem 0;
        position: relative;
        color: #1c1917;
    }

    :global(.dark .substrate-editor .principle-block) {
        background: rgba(20, 184, 166, 0.12);
        border-left-color: #2dd4bf;
        color: #f5f5f4;
    }

    :global(.substrate-editor .principle-binding) {
        font-size: 0.7rem;
        text-transform: uppercase;
        letter-spacing: 0.06em;
        color: #0f766e;
        font-weight: 600;
        margin-bottom: 0.35rem;
    }

    :global(.dark .substrate-editor .principle-binding) {
        color: #5eead4;
    }

    :global(.substrate-editor .principle-body p) {
        margin: 0.2rem 0;
    }

    /* Table block — basic styling so the structure is visible. */
    :global(.substrate-editor .ProseMirror table) {
        border-collapse: collapse;
        margin: 1rem 0;
        width: 100%;
    }
    :global(.substrate-editor .ProseMirror th),
    :global(.substrate-editor .ProseMirror td) {
        border: 1px solid #d6d3d1;
        padding: 0.4rem 0.6rem;
        vertical-align: top;
    }
    :global(.dark .substrate-editor .ProseMirror th),
    :global(.dark .substrate-editor .ProseMirror td) {
        border-color: #44403c;
    }
    :global(.substrate-editor .ProseMirror th) {
        background: #f5f5f4;
        font-weight: 600;
    }
    :global(.dark .substrate-editor .ProseMirror th) {
        background: #292524;
    }

    /* Code block — fenced code (W-P / S351, language attr lifted to
       props.language). Tinted background to mark it as code-shaped
       content distinct from prose. Monospace, no inline mark expansion,
       horizontal scroll on overflow. Light + dark variants. */
    :global(.substrate-editor .ProseMirror pre) {
        margin: 1rem 0;
        padding: 0.85rem 1rem;
        background: #f5f5f4;
        border: 1px solid #e7e5e4;
        border-radius: 0.4rem;
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
        font-size: 0.85rem;
        line-height: 1.5;
        color: #1c1917;
        overflow-x: auto;
        white-space: pre;
    }
    :global(.dark .substrate-editor .ProseMirror pre) {
        background: #1c1917;
        border-color: #44403c;
        color: #f5f5f4;
    }
    :global(.substrate-editor .ProseMirror pre code) {
        background: transparent;
        padding: 0;
        font-size: inherit;
        color: inherit;
    }

    /* Selection visibility in dark mode — ProseMirror's default selection
       gets lost on a dark background. */
    :global(.dark .substrate-editor .ProseMirror ::selection) {
        background: rgba(20, 184, 166, 0.35);
    }

    /* Wikilink mark — Obsidian-style vault reference. Distinct
       styling from external links so it reads as an internal reference
       rather than something that will leave the page. */
    :global(.substrate-editor .ProseMirror a.wikilink) {
        color: #0f766e;
        text-decoration: none;
        background: rgba(20, 184, 166, 0.08);
        border-bottom: 1px dashed rgba(15, 118, 110, 0.45);
        padding: 0 0.15rem;
        border-radius: 0.15rem;
        cursor: pointer;
    }
    :global(.substrate-editor .ProseMirror a.wikilink:hover) {
        background: rgba(20, 184, 166, 0.16);
        border-bottom-style: solid;
    }
    :global(.dark .substrate-editor .ProseMirror a.wikilink) {
        color: #5eead4;
        background: rgba(20, 184, 166, 0.14);
        border-bottom-color: rgba(94, 234, 212, 0.5);
    }
    :global(.dark .substrate-editor .ProseMirror a.wikilink:hover) {
        background: rgba(20, 184, 166, 0.24);
    }

    /* Unresolved-binding decoration — drawn by the ProseMirror plugin in
       tiptap-setup.ts. */
    :global(.substrate-editor .principle-block--unresolved) {
        border-left-color: #d97706 !important;
        background: rgba(217, 119, 6, 0.08);
    }
    :global(.dark .substrate-editor .principle-block--unresolved) {
        background: rgba(217, 119, 6, 0.18);
    }

    :global(.substrate-editor .principle-block--unresolved::after) {
        content: '⚠ unresolved binding';
        position: absolute;
        top: 0.4rem;
        right: 0.6rem;
        font-size: 0.65rem;
        color: #b45309;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }
    :global(.dark .substrate-editor .principle-block--unresolved::after) {
        color: #fbbf24;
    }
</style>
