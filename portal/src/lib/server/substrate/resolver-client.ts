/**
 * Resolver client.
 *
 * Server-only helper for talking to the FastAPI resolver
 * (PostgreSQL substrate) at http://localhost:7300/v1/...
 *
 * The bearer token is read from $env/static/private and never reaches
 * the browser. All editor traffic flows through Portal endpoints that
 * proxy to the resolver with this token attached.
 *
 * Configuration (env / .env):
 *   RESOLVER_BASE_URL  — default: http://localhost:7300
 *   RESOLVER_TOKEN     — required for write paths and token-protected
 *                        reads (/v1/documents/.../projection,
 *                        /v1/registry/binding/validate, ...)
 */

import { env } from '$env/dynamic/private';

const BASE = env.RESOLVER_BASE_URL ?? 'http://localhost:7300';
const TOKEN = env.RESOLVER_TOKEN ?? '';

interface FetchOpts {
    method?: string;
    body?: unknown;
    query?: Record<string, string | number | boolean>;
}

async function call<T>(path: string, opts: FetchOpts = {}): Promise<T> {
    const { method = 'GET', body, query } = opts;
    const url = new URL(BASE + path);
    if (query) {
        for (const [k, v] of Object.entries(query)) {
            url.searchParams.set(k, String(v));
        }
    }

    const headers: Record<string, string> = {
        'Accept': 'application/json'
    };
    if (TOKEN) headers['X-Ontara-Token'] = TOKEN;
    if (body !== undefined) headers['Content-Type'] = 'application/json';

    const res = await fetch(url, {
        method,
        headers,
        body: body !== undefined ? JSON.stringify(body) : undefined
    });

    if (!res.ok) {
        let detail: unknown;
        try {
            detail = await res.json();
        } catch {
            detail = await res.text();
        }
        throw new ResolverError(res.status, detail, `${method} ${path}`);
    }
    return res.json();
}

export class ResolverError extends Error {
    constructor(
        public readonly status: number,
        public readonly detail: unknown,
        public readonly origin: string
    ) {
        super(`Resolver ${status} on ${origin}: ${JSON.stringify(detail)}`);
    }
}

// ---------- Document listing (public read view) ----------

export interface DocumentListItem {
    id: string;
    slug: string;
    title: string;
    root_block_id: string | null;
    current_revision_id: string | null;
    created_session: number;
    updated_session: number;
    created_by: string | null;
    created_at: string | null;
    updated_at: string | null;
    block_count: number;
}

export interface DocumentList {
    count: number;
    items: DocumentListItem[];
}

export async function listDocuments(): Promise<DocumentList> {
    return call<DocumentList>('/documents', { query: { format: 'json' } });
}

// ---------- Document loading ----------

export interface ProjectionResponse {
    document: { id: string; slug: string; title: string };
    projection: ProseMirrorDoc;
}

export interface ProseMirrorDoc {
    type: 'doc';
    content?: ProseMirrorNode[];
}

export interface ProseMirrorNode {
    type: string;
    attrs?: Record<string, unknown>;
    content?: ProseMirrorNode[];
    text?: string;
    marks?: { type: string; attrs?: Record<string, unknown> }[];
}

export async function getProjection(idOrSlug: string): Promise<ProjectionResponse> {
    return call<ProjectionResponse>(
        `/v1/documents/${encodeURIComponent(idOrSlug)}/projection`
    );
}

// compose returns the full block tree — useful for editor binding,
// since the projection flattens everything to PM nodes whereas the
// editor needs to know which PM nodes correspond to which block ids
// for save-back. We carry both.
export interface ComposedTree {
    document: { id: string; slug: string; title: string };
    tree: ComposedNode;
}

export interface ComposedNode {
    id: string;
    block_type: string;
    props: Record<string, unknown> | null;
    content: Record<string, unknown> | null;
    entity_type: string | null;
    entity_id: string | null;
    children: ComposedNode[];
    edges: unknown[];
    _cycle?: boolean;
    _missing?: boolean;
    _transcluded?: boolean;
    _transclude_props?: Record<string, unknown>;
}

export async function getComposed(idOrSlug: string): Promise<ComposedTree> {
    return call<ComposedTree>(
        `/v1/documents/${encodeURIComponent(idOrSlug)}/compose`
    );
}

// ---------- Mutations ----------

export interface MutationOp {
    op: 'createBlock' | 'insertChild' | 'patchBlockContent' | 'addEdge' | 'removeEdge' | 'moveBlock';
    [key: string]: unknown;
}

export interface MutationsRequest {
    baseRevision: string | null;
    operations: MutationOp[];
}

export interface MutationsResponse {
    newRevision: string;
    acceptedOperations: number;
    operations: { op: string; [key: string]: unknown }[];
    projectionPatch: null;
}

export async function applyMutations(
    idOrSlug: string,
    body: MutationsRequest
): Promise<MutationsResponse> {
    return call<MutationsResponse>(
        `/v1/documents/${encodeURIComponent(idOrSlug)}/mutations`,
        { method: 'POST', body }
    );
}

// ---------- Render to vault ----------

export interface RenderResponse {
    slug: string;
    title: string;
    target: 'vault' | 'temp' | 'return';
    path: string | null;
    bytes: number;
    markdown: string | null;
    warnings: string[];
}

/**
 * Render a substrate document to its vault path.
 *
 * No body — slug-as-identity (W-149) means the renderer resolves the
 * vault location server-side by matching `document.slug` against
 * frontmatter `slug:` fields in the live vault tree.
 */
export async function renderToVault(idOrSlug: string): Promise<RenderResponse> {
    return call<RenderResponse>(
        `/v1/documents/${encodeURIComponent(idOrSlug)}/render`,
        { method: 'POST', query: { target: 'vault' } }
    );
}

// ---------- Binding validation ----------

export interface BindingValidationResponse {
    entity_type: string;
    entity_id: string;
    source_table: string;
    source_id_column: string;
    resolves: boolean;
}

export async function validateBinding(
    entity_type: string,
    entity_id: string
): Promise<BindingValidationResponse> {
    return call<BindingValidationResponse>('/v1/registry/binding/validate', {
        method: 'POST',
        body: { entity_type, entity_id }
    });
}
