import type { PageLoad } from './$types';
import type { GovernancePageData } from '$lib/types/governance';

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();

  const pageData: GovernancePageData = {
    governance: data.governanceTraceability || {
      requirementDefs: [],
      constraintDefs: [],
      satisfyChains: [],
      requirementInstances: [],
      auditEvidenceInstances: [],
    },
    domains: data.domains || {},
    generatedAt: data.generatedAt,
  };

  return { governance: pageData };
};
