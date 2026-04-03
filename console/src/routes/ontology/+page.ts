import type { PageLoad } from './$types';
import type { OntologyPageData, OntologicalHierarchy } from '$lib/types/ontology';

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  const hierarchy: OntologicalHierarchy = data.ontologicalHierarchy || {
    tree: { name: 'Entity', tier: 'bfo', children: [] },
    stats: { bmmElementCount: 0, bfoClassesUsed: [], midLevelClassesUsed: [], unmappedMidLevel: [] },
  };

  const pageData: OntologyPageData = {
    hierarchy,
    generatedAt: data.generatedAt,
    generator: data.generator,
  };

  return { ontology: pageData };
};
