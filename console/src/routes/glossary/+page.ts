import type { PageLoad } from './$types';
import type { CatalogueElement, ComprehensionSummary, ComprehensionContent, FacetSummary, DomainMeta } from '$lib/types/catalogue';

export interface GlossaryPageData {
  /** Elements that have @UserFacing metadata — the glossary entries. */
  entries: CatalogueElement[];
  /** Comprehension stats — how many elements have glossary entries vs total catalogue. */
  comprehension: ComprehensionSummary;
  /** Dynamically assembled comprehension content keyed by element name. */
  comprehensionContent: Record<string, ComprehensionContent>;
  /** Facet dimensions for filtering. */
  facets: FacetSummary;
  /** Domain metadata for labels and descriptions. */
  domains: Record<string, DomainMeta>;
  generatedAt: string;
  generator: string;
}

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  // Extract glossary-eligible elements: coverageMatrix entries with populated @UserFacing.
  const entries: CatalogueElement[] = Object.values(data.coverageMatrix)
    .filter((entry: any) => {
      // Must have catalogueTag (to be in the catalogue at all)
      if (!entry.catalogueTag || Object.keys(entry.catalogueTag).length === 0) return false;
      // Must have userFacing with a non-empty friendlyName
      if (!entry.userFacing || !entry.userFacing.friendlyName) return false;
      return true;
    })
    .map((entry: any) => ({
      name: entry.name,
      layer: entry.layer,
      package: entry.package,
      doc: entry.doc || '',
      catalogueTag: entry.catalogueTag,
      userFacing: entry.userFacing,
      purposiveDescription: entry.purposiveDescription || undefined,
      comprehension: entry.comprehension || undefined,
      bfoType: entry.bfoType && entry.bfoType.bfoClass ? entry.bfoType : undefined,
      domains: entry.domains || {},
    }));

  const pageData: GlossaryPageData = {
    entries,
    comprehension: data.comprehension || {
      catalogueTaggedCount: 0,
      userFacingCount: 0,
      purposiveDescriptionCount: 0,
      comprehensionAnnotationCount: 0,
      coveragePercent: 0,
      purposiveCoveragePercent: 0,
      missingUserFacing: [],
      missingPurposiveDescription: [],
    },
    comprehensionContent: data.comprehensionContent || {},
    facets: data.facets || {},
    domains: data.domains || {},
    generatedAt: data.generatedAt,
    generator: data.generator,
  };

  return { glossary: pageData };
};
