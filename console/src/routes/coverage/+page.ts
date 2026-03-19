import type { PageLoad } from './$types';

interface CoverageEntry {
  name: string;
  layer: string;
  package: string;
  doc: string;
  domains: Record<string, Array<{ name: string; package: string }>>;
}

interface IntrospectionData {
  generatedAt: string;
  domains: Record<string, { label: string; description: string; elementCount: number }>;
  summary: {
    totalElements: number;
    byKind: Record<string, number>;
    byLayer: Record<string, number>;
    byDomain: Record<string, number>;
  };
  coverageMatrix: Record<string, CoverageEntry>;
}

export const load: PageLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data: IntrospectionData = await response.json();
  return { introspection: data };
};
