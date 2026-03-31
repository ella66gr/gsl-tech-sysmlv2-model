<script lang="ts">
  import { getContext } from 'svelte';
  import RelationshipTable from '$lib/components/RelationshipTable.svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';

  let { data } = $props();

  const graph: WeightedRelationshipGraph = data.graph;

  const filters: { selectedConcerns: Set<string>; selectedStrengths: Set<string>; searchText: string } =
    getContext('relationships-filters');
</script>

<RelationshipTable
  {graph}
  selectedConcerns={filters.selectedConcerns}
  selectedStrengths={filters.selectedStrengths}
  searchText={filters.searchText}
/>
