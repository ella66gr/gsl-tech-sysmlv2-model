<script lang="ts">
  import { goto } from '$app/navigation';
  import { Card, Button, Label, Input, Select, Alert } from 'flowbite-svelte';

  let customerName = $state('');
  let drinkType = $state('flat white');
  let size = $state('medium');
  let submitting = $state(false);
  let errorMessage = $state('');

  const drinkOptions = [
    { value: 'flat white', name: 'Flat White' },
    { value: 'latte', name: 'Latte' },
    { value: 'americano', name: 'Americano' },
    { value: 'cappuccino', name: 'Cappuccino' },
    { value: 'espresso', name: 'Espresso' },
    { value: 'iced latte', name: 'Iced Latte' },
    { value: 'cold brew', name: 'Cold Brew' },
  ];

  const sizeOptions = [
    { value: 'small', name: 'Small' },
    { value: 'medium', name: 'Medium' },
    { value: 'large', name: 'Large' },
  ];

  async function placeOrder() {
    submitting = true;
    errorMessage = '';

    try {
      const response = await fetch('/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ customerName, drinkType, size }),
      });

      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }

      const data = await response.json();
      await goto(`/orders/${data.orderId}`);
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to place order';
    } finally {
      submitting = false;
    }
  }
</script>

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Counter</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">SysML v2 Model-Driven Execution — Coffee Shop Demonstrator</p>
</div>

<Card class="max-w-lg">
  <h2 class="mb-4 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Place an Order</h2>

  {#if errorMessage}
    <Alert color="red" class="mb-4">
      <span class="font-medium">Error:</span> {errorMessage}
    </Alert>
  {/if}

  <div class="mb-4">
    <Label for="customerName" class="mb-2">Customer Name</Label>
    <Input id="customerName" bind:value={customerName} placeholder="Enter name" />
  </div>

  <div class="mb-4">
    <Label for="drinkType" class="mb-2">Drink Type</Label>
    <Select id="drinkType" bind:value={drinkType} items={drinkOptions} />
  </div>

  <div class="mb-4">
    <Label for="size" class="mb-2">Size</Label>
    <Select id="size" bind:value={size} items={sizeOptions} />
  </div>

  <Button color="primary" onclick={placeOrder} disabled={submitting || !customerName} class="w-full">
    {submitting ? 'Placing order…' : 'Place Order'}
  </Button>
</Card>
