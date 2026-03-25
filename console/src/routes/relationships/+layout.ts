import type { LayoutLoad } from './$types';
import type { WeightedRelationshipGraph } from '$lib/types/relationships';
import type { ComprehensionContent, CatalogueElement } from '$lib/types/catalogue';

export interface RelationshipsLayoutData {
  graph: WeightedRelationshipGraph;
  comprehensionContent: Record<string, ComprehensionContent>;
  glossaryEntries: CatalogueElement[];
  generatedAt: string;
}

export const load: LayoutLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  const glossaryEntries: CatalogueElement[] = Object.values(data.coverageMatrix)
    .filter((entry: any) => entry.catalogueTag && entry.userFacing?.friendlyName)
    .map((entry: any) => ({
      name: entry.name,
      layer: entry.layer,
      package: entry.package,
      doc: entry.doc || '',
      catalogueTag: entry.catalogueTag,
      userFacing: entry.userFacing,
      purposiveDescription: entry.purposiveDescription || undefined,
      domains: entry.domains || {},
    }));

  return {
    graph: data.weightedRelationshipGraph,
    comprehensionContent: data.comprehensionContent || {},
    glossaryEntries,
    generatedAt: data.generatedAt,
  };
};
