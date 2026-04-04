<script lang="ts">
  import type { Snippet } from 'svelte';
  import { useNavigation } from '$lib/stores/navigation.svelte';

  interface Props {
    href: string;
    label: string;
    relationship?: string;
    query?: Record<string, string>;
    class?: string;
    children?: Snippet;
  }

  let { href, label, relationship, query, class: className, children }: Props = $props();

  const navStore = useNavigation();

  const computedHref = $derived(
    href + (query ? '?' + new URLSearchParams(query).toString() : '')
  );

  function handleClick(event: MouseEvent) {
    event.preventDefault();
    navStore.navigateTo({ route: href, label, relationship, query });
  }
</script>

<a href={computedHref} class={className} onclick={handleClick}>
  {@render children?.()}
</a>
