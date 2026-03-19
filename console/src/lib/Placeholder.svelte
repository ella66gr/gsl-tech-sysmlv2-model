<script lang="ts">
  import { Badge } from 'flowbite-svelte';

  let { title, stage, description } = $props<{
    title: string;
    stage: string;
    description: string;
  }>();
</script>

<div class="flex flex-col items-center justify-center py-20 text-center">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">{title}</h1>
  <p class="mt-2 max-w-md text-secondary-500 dark:text-secondary-300">{description}</p>
  <Badge color="indigo" class="mt-4">{stage}</Badge>
</div>
