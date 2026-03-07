/**
 * EHRbase REST API Client — CDR Exercise Phase B
 *
 * Thin TypeScript wrapper around the EHRbase openEHR REST API.
 * Uses canonical JSON format for compositions.
 *
 * This module is designed to be used from both Temporal activities
 * (where it commits compositions as part of workflow execution)
 * and SvelteKit server endpoints (where it queries for entity views).
 *
 * Design decisions:
 *   - Canonical JSON (not flat/structured) — standard format, explicit RM types
 *   - One EHR per customer — mirrors clinical pattern (one EHR per patient)
 *   - Template ID on every commit — CDR validates composition structure
 *   - Basic auth for development — production would use OAuth/JWT
 *
 * Findings:
 *   - EHRbase namespace regex: [a-zA-Z][a-zA-Z0-9-_:/&+?]* — dots NOT allowed
 *   - With Prefer: return=minimal, EHRbase returns 204 (not 200/201) on composition commit
 *   - Composition UID is in the ETag and/or Location header regardless of status code
 */

// ── Configuration ──

export interface EhrbaseConfig {
  /** Base URL for the EHRbase REST API, e.g. "http://localhost:8080/ehrbase/rest/openehr/v1" */
  readonly baseUrl: string;
  /** Basic auth username */
  readonly username: string;
  /** Basic auth password */
  readonly password: string;
}

/**
 * Default configuration matching the docker-compose.ehrbase.yml setup.
 * Override via createEhrbaseClient() for different environments.
 */
export const DEFAULT_EHRBASE_CONFIG: EhrbaseConfig = {
  baseUrl: 'http://localhost:8080/ehrbase/rest/openehr/v1',
  username: 'ehrbase-user',
  password: 'SuperSecretPassword',
};

/** Default subject namespace for EHR external references.
 *  EHRbase namespace must match [a-zA-Z][a-zA-Z0-9-_:/&+?]* — no dots. */
const DEFAULT_SUBJECT_NAMESPACE = 'coffeeshop-customer';

// ── Response types ──

export interface EhrCreationResult {
  /** The UUID assigned to the new EHR */
  readonly ehrId: string;
}

export interface CompositionCommitResult {
  /** The versioned object UID of the committed composition */
  readonly compositionUid: string;
}

export interface AqlResultSet {
  /** Column metadata */
  readonly columns: ReadonlyArray<{ name: string; path: string }>;
  /** Result rows — each row is an array of values matching the columns */
  readonly rows: ReadonlyArray<ReadonlyArray<unknown>>;
}

// ── Error types ──

export class EhrbaseError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
    public readonly responseBody: string,
  ) {
    super(`EHRbase error (${statusCode}): ${message}`);
    this.name = 'EhrbaseError';
  }
}

// ── Client interface ──

export interface EhrbaseClient {
  /**
   * Create a new EHR. Returns the assigned EHR ID.
   * Optionally associates an external subject ID (e.g. customer name)
   * for later lookup.
   */
  createEhr(subjectId?: string, subjectNamespace?: string): Promise<EhrCreationResult>;

  /**
   * Get or create an EHR for a given subject. If an EHR already exists
   * for the subject, returns its ID. Otherwise creates a new one.
   *
   * This is the recommended pattern for workflow activities: call this
   * before committing a composition, and the activity is idempotent
   * with respect to EHR creation.
   */
  getOrCreateEhr(subjectId: string, subjectNamespace?: string): Promise<EhrCreationResult>;

  /**
   * Commit a composition to an EHR. The composition must conform to
   * the template identified by templateId — EHRbase validates this
   * and rejects non-conforming data.
   *
   * @param ehrId - The EHR to commit to (UUID)
   * @param templateId - Template ID for validation (e.g. "coffeeshop-order-composition.v1")
   * @param composition - Canonical JSON composition object
   * @returns The versioned object UID of the committed composition
   */
  commitComposition(
    ehrId: string,
    templateId: string,
    composition: Record<string, unknown>,
  ): Promise<CompositionCommitResult>;

  /**
   * Retrieve a composition by its versioned UID.
   */
  getComposition(ehrId: string, compositionUid: string): Promise<Record<string, unknown>>;

  /**
   * Execute an AQL query against the CDR.
   *
   * @param aql - The AQL query string
   * @param queryParameters - Optional named parameters for parameterised queries
   */
  executeAql(
    aql: string,
    queryParameters?: Record<string, unknown>,
  ): Promise<AqlResultSet>;
}

// ── Client implementation ──

export function createEhrbaseClient(config: EhrbaseConfig = DEFAULT_EHRBASE_CONFIG): EhrbaseClient {
  const authHeader = 'Basic ' + Buffer.from(`${config.username}:${config.password}`).toString('base64');

  async function request(
    method: string,
    path: string,
    body?: Record<string, unknown> | string,
    extraHeaders?: Record<string, string>,
  ): Promise<Response> {
    const url = `${config.baseUrl}${path}`;
    const headers: Record<string, string> = {
      'Authorization': authHeader,
      'Accept': 'application/json',
      ...extraHeaders,
    };

    // Build fetch options conditionally to satisfy exactOptionalPropertyTypes.
    // body must not be present as undefined — only include it when we have data.
    const options: RequestInit = { method, headers };

    if (body !== undefined) {
      headers['Content-Type'] = 'application/json';
      options.body = typeof body === 'string' ? body : JSON.stringify(body);
    }

    return await fetch(url, options);
  }

  /**
   * Parse the EHR ID from a Location header or response body.
   * EHRbase returns the EHR ID in the Location header on creation:
   *   Location: .../ehr/{ehrId}
   */
  function extractEhrIdFromLocation(locationHeader: string | null): string | undefined {
    if (!locationHeader) return undefined;
    const parts = locationHeader.split('/');
    return parts[parts.length - 1];
  }

  /**
   * Parse the composition UID from the Location or ETag header.
   * EHRbase returns:
   *   Location: .../composition/{versionedObjectUid}::nodeName::version
   *   or ETag: "{versionedObjectUid}::nodeName::version"
   */
  function extractCompositionUid(response: Response): string {
    // Try ETag first (more reliable)
    const etag = response.headers.get('ETag');
    if (etag) {
      // ETag value is quoted: "uid::node::version"
      return etag.replace(/"/g, '');
    }

    // Fall back to Location header
    const location = response.headers.get('Location');
    if (location) {
      const parts = location.split('/');
      return parts[parts.length - 1] ?? '';
    }

    throw new Error('Cannot extract composition UID: no ETag or Location header');
  }

  // ── Interface implementation ──

  const client: EhrbaseClient = {
    async createEhr(subjectId?: string, subjectNamespace?: string): Promise<EhrCreationResult> {
      // If subject details provided, include them in the request body
      // so the EHR is associated with an external subject reference.
      let body: Record<string, unknown> | undefined;
      if (subjectId) {
        body = {
          _type: 'EHR_STATUS',
          archetype_node_id: 'openEHR-EHR-EHR_STATUS.generic.v1',
          name: { _type: 'DV_TEXT', value: 'EHR Status' },
          subject: {
            _type: 'PARTY_SELF',
            external_ref: {
              _type: 'PARTY_REF',
              id: {
                _type: 'GENERIC_ID',
                value: subjectId,
                scheme: 'coffeeshop',
              },
              namespace: subjectNamespace ?? DEFAULT_SUBJECT_NAMESPACE,
              type: 'PERSON',
            },
          },
          is_modifiable: true,
          is_queryable: true,
        };
      }

      const response = await request('POST', '/ehr', body);

      if (response.status === 201) {
        // EHR created successfully
        const ehrId = extractEhrIdFromLocation(response.headers.get('Location'));
        if (!ehrId) {
          // Try response body
          const responseBody = await response.json() as Record<string, unknown>;
          const bodyEhrId = (responseBody as { ehr_id?: { value?: string } }).ehr_id?.value;
          if (!bodyEhrId) {
            throw new Error('EHR created but could not extract ehr_id from response');
          }
          return { ehrId: bodyEhrId };
        }
        return { ehrId };
      }

      const errorBody = await response.text();
      throw new EhrbaseError('Failed to create EHR', response.status, errorBody);
    },

    async getOrCreateEhr(subjectId: string, subjectNamespace?: string): Promise<EhrCreationResult> {
      const ns = subjectNamespace ?? DEFAULT_SUBJECT_NAMESPACE;

      // First, try to find an existing EHR for this subject
      const response = await request(
        'GET',
        `/ehr?subject_id=${encodeURIComponent(subjectId)}&subject_namespace=${encodeURIComponent(ns)}`,
      );

      if (response.status === 200) {
        const body = await response.json() as Record<string, unknown>;
        const ehrId = (body as { ehr_id?: { value?: string } }).ehr_id?.value;
        if (ehrId) {
          return { ehrId };
        }
      }

      // No existing EHR found — create one
      return client.createEhr(subjectId, subjectNamespace);
    },

    async commitComposition(
      ehrId: string,
      templateId: string,
      composition: Record<string, unknown>,
    ): Promise<CompositionCommitResult> {
      const response = await request(
        'POST',
        `/ehr/${ehrId}/composition`,
        composition,
        {
          // Prefer=return=minimal tells EHRbase not to return the full composition.
          // EHRbase responds with 204 No Content (not 200/201) in this case.
          // The composition UID is in the ETag and Location headers.
          'Prefer': 'return=minimal',
        },
      );

      if (response.status === 200 || response.status === 201 || response.status === 204) {
        const compositionUid = extractCompositionUid(response);
        return { compositionUid };
      }

      const errorBody = await response.text();
      throw new EhrbaseError(
        `Failed to commit composition (template: ${templateId})`,
        response.status,
        errorBody,
      );
    },

    async getComposition(ehrId: string, compositionUid: string): Promise<Record<string, unknown>> {
      const response = await request('GET', `/ehr/${ehrId}/composition/${compositionUid}`);

      if (response.status === 200) {
        return await response.json() as Record<string, unknown>;
      }

      const errorBody = await response.text();
      throw new EhrbaseError('Failed to retrieve composition', response.status, errorBody);
    },

    async executeAql(
      aql: string,
      queryParameters?: Record<string, unknown>,
    ): Promise<AqlResultSet> {
      const body: Record<string, unknown> = { q: aql };
      if (queryParameters) {
        body['query_parameters'] = queryParameters;
      }

      const response = await request('POST', '/query/aql', body);

      if (response.status === 200) {
        const result = await response.json() as {
          columns?: Array<{ name: string; path: string }>;
          rows?: Array<Array<unknown>>;
        };
        return {
          columns: result.columns ?? [],
          rows: result.rows ?? [],
        };
      }

      const errorBody = await response.text();
      throw new EhrbaseError('AQL query failed', response.status, errorBody);
    },
  };

  return client;
}
