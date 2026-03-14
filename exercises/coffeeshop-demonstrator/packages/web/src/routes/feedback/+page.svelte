<script lang="ts">
  import { onMount } from 'svelte';
  import { Card, Button, Label, Input, Alert, Badge, Spinner } from 'flowbite-svelte';

  // ── State: submit form ──

  let customerName = $state('');
  let rating = $state(4);
  let hoverRating = $state(0);
  let comment = $state('');
  let orderReference = $state('');
  let submitting = $state(false);
  let errorMessage = $state('');
  let successMessage = $state('');

  const RATING_LABELS: Record<number, string> = {
    1: 'Very Poor',
    2: 'Poor',
    3: 'Average',
    4: 'Good',
    5: 'Excellent',
  };

  // ── State: feedback list ──

  interface FeedbackEntry {
    ehrId: string;
    compositionUid: string;
    feedbackTime: string;
    rating: string;
    comment: string | null;
    orderReference: string | null;
  }

  let feedbackList = $state<FeedbackEntry[]>([]);
  let listLoading = $state(true);

  // ── Auto-load on mount ──

  onMount(() => {
    loadFeedback();
  });

  // ── Data fetching ──

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
      successMessage = 'Feedback submitted!';
      customerName = '';
      comment = '';
      rating = 4;
      hoverRating = 0;
      orderReference = '';
      // Refresh the list to show new entry
      await loadFeedback();
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to submit feedback';
    } finally {
      submitting = false;
    }
  }

  // ── Helpers ──

  function formatTime(iso: string): string {
    try {
      const date = new Date(iso);
      const now = new Date();
      const isToday = date.toDateString() === now.toDateString();
      const yesterday = new Date(now);
      yesterday.setDate(yesterday.getDate() - 1);
      const isYesterday = date.toDateString() === yesterday.toDateString();

      const time = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
      if (isToday) return `${time} today`;
      if (isYesterday) return `Yesterday ${time}`;
      return date.toLocaleDateString([], { day: 'numeric', month: 'short' }) + ` ${time}`;
    } catch {
      return iso;
    }
  }
</script>

<!-- Page header -->
<div class="mb-6">
  <div class="flex items-center gap-3">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Customer Voice</h1>
    <Badge color="indigo">CDR · EHRbase</Badge>
  </div>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Form-driven data entry — commits directly to the CDR, <strong>no workflow involved</strong>.
  </p>
</div>

<!-- Split view: form (left) + feedback list (right) -->
<div class="flex flex-col gap-6 lg:flex-row">
  <!-- Left: Submit form -->
  <div class="w-full shrink-0 lg:w-96">
    <Card class="max-w-none">
      <h2 class="mb-4 text-lg font-semibold text-secondary-700 dark:text-secondary-300">Submit Feedback</h2>

      {#if errorMessage}
        <Alert color="red" class="mb-4"><span class="font-medium">Error:</span> {errorMessage}</Alert>
      {/if}
      {#if successMessage}
        <Alert color="green" class="mb-4">{successMessage}</Alert>
      {/if}

      <div class="mb-4">
        <Label for="fbName" class="mb-2">Customer Name</Label>
        <Input id="fbName" bind:value={customerName} placeholder="Enter your name" />
      </div>

      <!-- Star rating -->
      <div class="mb-4">
        <Label class="mb-2">Rating</Label>
        <div class="flex items-center gap-1">
          {#each [1, 2, 3, 4, 5] as star}
            <button
              type="button"
              onclick={() => rating = star}
              onmouseenter={() => hoverRating = star}
              onmouseleave={() => hoverRating = 0}
              class="text-2xl transition-colors {(hoverRating || rating) >= star
                ? 'text-yellow-400'
                : 'text-secondary-300 dark:text-secondary-600'}"
              aria-label="{star} star{star !== 1 ? 's' : ''}"
            >★</button>
          {/each}
          <span class="ml-2 text-sm text-secondary-500 dark:text-secondary-400">
            {RATING_LABELS[hoverRating || rating]}
          </span>
        </div>
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
  </div>

  <!-- Right: Feedback list -->
  <div class="min-w-0 flex-1">
    <div class="mb-3 flex items-center justify-between">
      <h2 class="text-lg font-semibold text-secondary-700 dark:text-secondary-300">Recent Feedback</h2>
      <span class="text-xs text-secondary-400 dark:text-secondary-500">{feedbackList.length} entries · AQL → EHRbase</span>
    </div>

    {#if listLoading}
      <div class="flex items-center gap-2 py-8 text-secondary-500 dark:text-secondary-400">
        <Spinner size="5" /> Loading feedback from CDR…
      </div>
    {:else if feedbackList.length === 0}
      <div class="rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:text-secondary-500">
        No feedback yet. Submit some using the form.
      </div>
    {:else}
      <div class="space-y-3">
        {#each feedbackList as entry}
          <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
            <!-- Stars and comment -->
            <div class="mb-2 flex items-start gap-3">
              <div class="flex shrink-0 text-lg">
                {#each [1, 2, 3, 4, 5] as star}
                  <span class="{parseInt(entry.rating) >= star ? 'text-yellow-400' : 'text-secondary-200 dark:text-secondary-600'}">★</span>
                {/each}
              </div>
              {#if entry.comment}
                <p class="flex-1 text-sm italic text-secondary-700 dark:text-secondary-300">"{entry.comment}"</p>
              {:else}
                <p class="flex-1 text-sm text-secondary-400 dark:text-secondary-500 italic">No comment</p>
              {/if}
            </div>

            <!-- Metadata -->
            <div class="flex flex-wrap gap-x-2 gap-y-1 text-xs text-secondary-400 dark:text-secondary-500">
              <span>{formatTime(entry.feedbackTime)}</span>
              {#if entry.orderReference}
                <span>· Ref: <code>{entry.orderReference}</code></span>
              {/if}
              <span>· EHR: <code>{entry.ehrId.substring(0, 8)}…</code></span>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>

<!-- Clinical analogy footer -->
<div class="mt-6 rounded-lg bg-secondary-50 p-4 text-xs text-secondary-500 dark:bg-secondary-800/50 dark:text-secondary-400">
  <strong>Clinical analogy:</strong> A patient completing a Patient-Reported Outcome Measure (PROM) questionnaire
  outside any scheduled pathway step. Data enters the CDR directly via form submission — no Temporal workflow involved.
  This demonstrates that the CDR accepts data from multiple entry points, not just workflow activities.
</div>
