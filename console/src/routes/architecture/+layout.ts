import type { LayoutLoad } from './$types';

export interface ArchitecturalSection {
  name: string;
  displayName: string;
  group: string;
  presentationOrder: number;
  primaryFormalism: string;
  persistenceMechanism: string;
  implementationStatus: string;
  purposiveDescription: string;
  friendlyName: string;
  shortDescription: string;
  representationalModalitySummary: string;
  persistenceSummary: string;
  interfacesSummary: string;
  domainIllustrationSummary: string;
  docKey: string;
}

export interface ArchitectureLayoutData {
  sections: ArchitecturalSection[];
  generatedAt: string;
}

export const load: LayoutLoad = async ({ fetch }) => {
  const response = await fetch('/data/model-introspection.json');
  const data = await response.json();
  const sections: ArchitecturalSection[] = data.architecturalSections || [];
  return {
    architecture: {
      sections,
      generatedAt: data.generatedAt,
    } satisfies ArchitectureLayoutData,
  };
};
