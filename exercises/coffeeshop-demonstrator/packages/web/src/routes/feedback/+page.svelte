<script lang="ts">
  import { Card, Button, Label, Input, Select, Alert, Badge, Table, TableHead, TableHeadCell, TableBody, TableBodyRow, TableBodyCell } from 'flowbite-svelte';

  let customerName = $state('');
  let rating = $state(4);
  let comment = $state('');
  let orderReference = $state('');
  let submitting = $state(false);
  let errorMessage = $state('');
  let successMessage = $state('');

  const ratingOptions = [
    { value: 1, name: '1 star — Very Poor' },
    { value: 2, name: '2 stars — Poor' },
    { value: 3, name: '3 stars — Average' },
    { value: 4, name: '4 stars — Good' },
    { value: 5, name: '5 stars — Excellent' },
  ];

  async function submitFeedback() {
    submitting = true;
    errorMessage = '';
    successMessage = '';
    try {
      const body: Record<string, unknown> = { customerName, rating };
      if (comment.trim()) body['comment'] = comment.trim();
      if (orderReference.trim()) body['orderReference'] = orderReference.trim();

      const response = await fetch('/api/entity/feedback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      if (!response.ok) {
        const data = await response.json();
        errorMessage = data.message || `Error: ${response.status}`;
        return;
      }
      const data = await response.json();
      successMessage = `Feedback submitted! Composition: ${data.compositionUid}`;
      comment = '';
      rating = 4;
      orderReference = '';
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to submit feedback';
    } finally {
      submitting = false;
    }
  }

  interface FeedbackEntry {
    ehrId: string;
    compositionUid: string;
    feedbackTime: string;
    rating: string;
    comment: string | null;
    orderReference: string | null;
  }

  let feedbackList = $state<FeedbackEntry[]>([]);
  let listLoading = $state(false);

  async function loadFeedback() {
    listLoading = true;
    try {
      const response = await fetch('/api/entity/feedback');
      if (response.ok) {
        const data = await response.json();
        feedbackList = data.feedback ?? [];
      }
    } catch { /* silently fail */ }
    finally { listLoading = false; }
  }

  function formatTime(iso: string): string {
    try { return new Date(iso).toLocaleString(); } catch { return iso; }
  }
</script>

<div class="mb-6">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Customer Voice</h1>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Form-driven data entry — commits directly to the CDR, <strong>no workflow involved</strong>.
  </p>
  <p class="text-xs text-secondary-400 dark:text-secondary-500">
    Clinical analogy: a patient completing a PROM questionnaire outside any scheduled pathway step.
  </p>
</div>

<Card class="mb-6 max-w-lg">
  <h2 class="mb-4 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Submit Feedback</h2>

  {#if errorMessage}
    <Alert color="red" class="mb-4"><span class="font-medium">Error:</span> {errorMessage}</Alert>
  {/if}
  {#if successMessage}
    <Alert color="green" class="mb-4"><span class="font-medium">Success:</span> {successMessage}</Alert>
  {/if}

  <div class="mb-4">
    <Label for="fbName" class="mb-2">Customer Name</Label>
    <Input id="fbName" bind:value={customerName} placeholder="Enter your name" />
  </div>
  <div class="mb-4">
    <Label for="fbRating" class="mb-2">Rating</Label>
    <Select id="fbRating" bind:value={rating} items={ratingOptions} />
  </div>
  <div class="mb-4">
    <Label for="fbComment" class="mb-2">Comment (optional)</Label>
    <textarea id="fbComment" bind:value={comment} rows={3} placeholder="Tell us about your experience"
      class="block w-full rounded-lg border border-secondary-300 bg-secondary-50 p-2.5 text-sm text-secondary-900 focus:border-primary-500 focus:ring-primary-500 dark:border-secondary-600 dark:bg-secondary-700 dark:text-white dark:placeholder-secondary-400"></textarea>
  </div>
  <div class="mb-4">
    <Label for="fbRef" class="mb-2">Order Reference (optional)</Label>
    <Input id="fbRef" bind:value={orderReference} placeholder="Order ID or composition UID" />
  </div>

  <Button color="primary" onclick={submitFeedback} disabled={submitting || !customerName} class="w-full">
    {submitting ? 'Submitting…' : 'Submit Feedback'}
  </Button>
</Card>

<div>
  <h2 class="mb-3 text-lg font-semibold text-secondary-700 dark:text-secondary-300">All Feedback (Entity View)</h2>
  <Button color="light" onclick={loadFeedback} disabled={listLoading} class="mb-3">
    {listLoading ? 'Loading…' : 'Load Feedback from CDR'}
  </Button>

  {#if feedbackList.length > 0}
    <Table striped={true}>
      <TableHead>
        <TableHeadCell>Time</TableHeadCell>
        <TableHeadCell>Rating</TableHeadCell>
        <TableHeadCell>Comment</TableHeadCell>
        <TableHeadCell>Order Ref</TableHeadCell>
        <TableHeadCell>EHR ID</TableHeadCell>
      </TableHead>
      <TableBody>
        {#each feedbackList as entry}
          <TableBodyRow>
            <TableBodyCell class="text-sm">{formatTime(entry.feedbackTime)}</TableBodyCell>
            <TableBodyCell>{entry.rating}</TableBodyCell>
            <TableBodyCell>{entry.comment ?? '—'}</TableBodyCell>
            <TableBodyCell><code class="text-xs">{entry.orderReference ?? '—'}</code></TableBodyCell>
            <TableBodyCell><code class="text-xs">{entry.ehrId}</code></TableBodyCell>
          </TableBodyRow>
        {/each}
      </TableBody>
    </Table>
  {:else if !listLoading && feedbackList.length === 0}
    <p class="text-sm text-secondary-500">No feedback yet. Submit some above!</p>
  {/if}
</div>
