import type { PageLoad } from './$types';
import type { OntologyPageData, OntologicalHierarchy, ReasoningSummary } from '$lib/types/ontology';

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

  let reasoning: ReasoningSummary | null = null;
  try {
    const reasoningResponse = await fetch('/data/reasoning-summary.json');
    if (reasoningResponse.ok) {
      reasoning = await reasoningResponse.json();
    }
  } catch {
    // File doesn't exist yet — that's fine
  }

  return { ontology: pageData, reasoning };
};
