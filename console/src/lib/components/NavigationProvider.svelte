<script lang="ts">
  import type { Snippet } from 'svelte';
  import { setContext } from 'svelte';
  import { createNavigationStore } from '$lib/stores/navigation.svelte';

  let { children }: { children: Snippet } = $props();

  const store = createNavigationStore();
  setContext('navigation-store', store);
</script>

{@render children()}
