import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { createDomain, isSlugAvailable } from '$lib/server/db/domains';
import { addMember } from '$lib/server/db/memberships';

export const load: PageServerLoad = async () => {
    return {};
};

function generateSlug(name: string): string {
    return name
        .toLowerCase()
        .replace(/\s+/g, '-')
        .replace(/[^a-z0-9-]/g, '')
        .replace(/-+/g, '-')
        .replace(/^-|-$/g, '');
}

export const actions: Actions = {
    default: async ({ request, locals }) => {
        const data = await request.formData();
        const name = (data.get('name') as string)?.trim();
        const slugRaw = (data.get('slug') as string)?.trim().toLowerCase();
        const businessType = (data.get('businessType') as string)?.trim() || null;
        const description = (data.get('description') as string)?.trim() || null;

        const slug = slugRaw || generateSlug(name ?? '');

        const errors: Record<string, string> = {};

        if (!name) errors.name = 'Domain name is required.';
        if (!slug) errors.slug = 'URL slug is required.';
        else if (!/^[a-z0-9][a-z0-9-]*[a-z0-9]$/.test(slug) && !/^[a-z0-9]$/.test(slug)) {
            errors.slug = 'Slug must be lowercase alphanumeric with hyphens only, no leading/trailing hyphens.';
        } else if (!isSlugAvailable(slug)) {
            errors.slug = 'This slug is already taken. Please choose another.';
        }

        if (Object.keys(errors).length > 0) {
            return fail(400, { errors, name, slug: slugRaw, businessType, description });
        }

        const domain = createDomain(name, slug, description, businessType);
        addMember(locals.user!.id, domain.id, 'super_admin');

        throw redirect(303, `/domains/${domain.slug}`);
    }
};
