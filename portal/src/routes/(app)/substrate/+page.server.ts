import type { PageServerLoad } from './$types';
import { listDocuments, ResolverError } from '$lib/server/substrate/resolver-client';

export const load: PageServerLoad = async () => {
    try {
        const list = await listDocuments();
        return { documents: list.items, error: null };
    } catch (e) {
        const message =
            e instanceof ResolverError
                ? `Resolver ${e.status}: ${typeof e.detail === 'string' ? e.detail : JSON.stringify(e.detail)}`
                : e instanceof Error
                  ? e.message
                  : String(e);
        return { documents: [], error: message };
    }
};
