<script lang="ts">
  import { getContext } from 'svelte';
  import RelationshipTable from '$lib/components/RelationshipTable.svelte';
  import type { WeightedRelationshipGraph } from '$lib/types/relationships';

  let { data } = $props();

  const graph: WeightedRelationshipGraph = data.graph;

  const filters: { concernFilter: string; strengthFilter: string; searchText: string } =
    getContext('relationships-filters');
</script>

<RelationshipTable
  {graph}
  concernFilter={filters.concernFilter}
  strengthFilter={filters.strengthFilter}
  searchText={filters.searchText}
/>
