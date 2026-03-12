<script lang="ts">
  import '../app.css';
  import favicon from '$lib/assets/favicon.svg';

  let { children } = $props();
</script>

<svelte:head>
  <link rel="icon" href={favicon} />
  <title>Coffee Shop Demonstrator</title>
</svelte:head>

<nav style="padding: 0.5em 1em; border-bottom: 1px solid #ccc; margin-bottom: 1em;">
  <a href="/">New Order</a>
  &nbsp;|&nbsp;
  <a href="/orders">Orders</a>
  &nbsp;|&nbsp;
  <a href="/entity">Entity Views</a>
  &nbsp;|&nbsp;
  <a href="/feedback">Feedback</a>
  &nbsp;|&nbsp;
  <a href="/governance">Governance</a>
  &nbsp;|&nbsp;
  <a href="/pathway">Pathway</a>
</nav>

<main style="padding: 0 1em;">
  {@render children()}
</main>
