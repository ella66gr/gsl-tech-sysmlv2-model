import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';
import { getDomainsForUser } from '$lib/server/db/domains';
import { getDomainBySlug } from '$lib/server/db/domains';
import { getInstancesForDomain } from '$lib/server/db/modules';

export const load: LayoutServerLoad = async ({ locals, url }) => {
    if (!locals.user) throw redirect(303, '/login');
    const domains = getDomainsForUser(locals.user.id);

    // Extract domain slug from URL if on a domain sub-route
    const slugMatch = url.pathname.match(/^\/domains\/([^/]+)/);
    const currentSlug = slugMatch ? slugMatch[1] : null;

    let sidebarModules: { id: string; displayName: string; operationalState: string }[] = [];
    if (currentSlug && currentSlug !== 'new') {
        const domain = getDomainBySlug(currentSlug);
        if (domain) {
            const instances = getInstancesForDomain(domain.id);
            sidebarModules = instances.map(i => ({
                id: i.id,
                displayName: i.displayName || i.definition.name,
                operationalState: i.operationalState
            }));
        }
    }

    return { user: locals.user, domains, sidebarModules };
};
