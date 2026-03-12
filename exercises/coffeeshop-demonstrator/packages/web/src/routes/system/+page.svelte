<script lang="ts">
  import { Card } from 'flowbite-svelte';
  import { ServerOutline } from 'flowbite-svelte-icons';
</script>

<h1 class="mb-4 text-2xl font-bold text-secondary-800 dark:text-white">System Status</h1>

<Card class="max-w-lg">
  <div class="flex items-center gap-3 text-secondary-500 dark:text-secondary-400">
    <ServerOutline class="h-8 w-8" />
    <div>
      <p class="font-medium text-secondary-700 dark:text-secondary-300">Coming in Phase 9</p>
      <p class="text-sm">Infrastructure health, structural inventory, and self-assessment dashboard.</p>
    </div>
  </div>
</Card>
