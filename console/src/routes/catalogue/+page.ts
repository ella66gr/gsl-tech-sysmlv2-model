import type { PageLoad } from './$types';
import type { CatalogueElement, CataloguePageData } from '$lib/types/catalogue';

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  // Extract catalogue-eligible elements from coverageMatrix:
  // only entries that have a non-empty catalogueTag property.
  // Empty objects {} are truthy, so check for at least one key.
  const catalogueElements: CatalogueElement[] = Object.values(data.coverageMatrix)
    .filter((entry: any) => entry.catalogueTag && Object.keys(entry.catalogueTag).length > 0)
    .map((entry: any) => ({
      name: entry.name,
      layer: entry.layer,
      package: entry.package,
      doc: entry.doc || '',
      catalogueTag: entry.catalogueTag,
      userFacing: entry.userFacing || undefined,
      domains: entry.domains || {},
    }));

  const pageData: CataloguePageData = {
    elements: catalogueElements,
    facets: data.facets || {},
    comprehension: data.comprehension || {
      catalogueTaggedCount: 0,
      userFacingCount: 0,
      coveragePercent: 0,
      missingUserFacing: [],
    },
    domains: data.domains || {},
    generatedAt: data.generatedAt,
    generator: data.generator,
  };

  return { catalogue: pageData };
};
