import { error } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
import {
    getComposed,
    applyMutations,
    validateBinding,
    ResolverError,
    type MutationOp
} from '$lib/server/substrate/resolver-client';

export const load: PageServerLoad = async ({ params }) => {
    try {
        const composed = await getComposed(params.slug);
        return {
            document: composed.document,
            tree: composed.tree
        };
    } catch (e) {
        if (e instanceof ResolverError) {
            if (e.status === 404) {
                throw error(404, `No substrate document with slug "${params.slug}"`);
            }
            throw error(e.status, `Resolver error: ${JSON.stringify(e.detail)}`);
        }
        throw error(500, e instanceof Error ? e.message : String(e));
    }
};

export const actions = {
    save: async ({ params, request }) => {
        const formData = await request.formData();
        const opsRaw = formData.get('operations');
        const baseRevisionRaw = formData.get('baseRevision');

        if (typeof opsRaw !== 'string') {
            return { ok: false, error: 'No operations payload received' };
        }

        let operations: MutationOp[];
        try {
            operations = JSON.parse(opsRaw);
        } catch (e) {
            return { ok: false, error: `operations payload was not valid JSON: ${e}` };
        }

        if (operations.length === 0) {
            return { ok: true, newRevision: null, accepted: 0, message: 'No changes to save.' };
        }

        const baseRevision =
            typeof baseRevisionRaw === 'string' && baseRevisionRaw.length > 0
                ? baseRevisionRaw
                : null;

        try {
            const res = await applyMutations(params.slug, { baseRevision, operations });
            return {
                ok: true,
                newRevision: res.newRevision,
                accepted: res.acceptedOperations
            };
        } catch (e) {
            const message =
                e instanceof ResolverError
                    ? `Resolver ${e.status}: ${typeof e.detail === 'string' ? e.detail : JSON.stringify(e.detail)}`
                    : e instanceof Error
                      ? e.message
                      : String(e);
            return { ok: false, error: message };
        }
    },

    validateBindings: async ({ request }) => {
        const formData = await request.formData();
        const payload = formData.get('bindings');
        if (typeof payload !== 'string') {
            return { ok: false, error: 'No bindings payload', results: [] };
        }
        let bindings: { block_id: string; entity_type: string; entity_id: string }[];
        try {
            bindings = JSON.parse(payload);
        } catch (e) {
            return { ok: false, error: `bindings was not valid JSON: ${e}`, results: [] };
        }

        const results: { block_id: string; resolves: boolean; error?: string }[] = [];
        for (const b of bindings) {
            try {
                const r = await validateBinding(b.entity_type, b.entity_id);
                results.push({ block_id: b.block_id, resolves: r.resolves });
            } catch (e) {
                results.push({
                    block_id: b.block_id,
                    resolves: false,
                    error: e instanceof Error ? e.message : String(e)
                });
            }
        }
        return { ok: true, results };
    }
} satisfies Actions;
