<script lang="ts">
  let customerName = $state('');
  let rating = $state(4);
  let comment = $state('');
  let orderReference = $state('');
  let submitting = $state(false);
  let errorMessage = $state('');
  let successMessage = $state('');

  async function submitFeedback() {
    submitting = true;
    errorMessage = '';
    successMessage = '';

    try {
      const body: Record<string, unknown> = {
        customerName,
        rating,
      };
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
      successMessage = `Feedback submitted! Composition: ${data.compositionUid} (EHR: ${data.ehrId})`;

      // Reset form
      comment = '';
      rating = 4;
      orderReference = '';
    } catch (err) {
      errorMessage = err instanceof Error ? err.message : 'Failed to submit feedback';
    } finally {
      submitting = false;
    }
  }

  // ── Feedback list ──

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
    } catch {
      // Silently fail — the list is supplementary
    } finally {
      listLoading = false;
    }
  }

  function formatTime(iso: string): string {
    try {
      return new Date(iso).toLocaleString();
    } catch {
      return iso;
    }
  }
</script>

<h1>Customer Feedback</h1>
<p>Form-driven data entry — commits directly to the CDR, <strong>no workflow involved</strong>.</p>
<p style="color: #666; font-size: 0.9em;">
  Clinical analogy: a patient completing a PROM questionnaire at any time,
  outside any scheduled pathway step. The data is structured, validated,
  and queryable in exactly the same way as workflow-committed data.
</p>

<hr />

<h2>Submit Feedback</h2>

{#if errorMessage}
  <p style="color: red;"><strong>Error:</strong> {errorMessage}</p>
{/if}

{#if successMessage}
  <p style="color: green;"><strong>Success:</strong> {successMessage}</p>
{/if}

<div style="max-width: 30em;">
  <div style="margin-bottom: 0.75em;">
    <label>
      Customer Name:
      <input type="text" bind:value={customerName} placeholder="Enter your name" style="width: 100%;" />
    </label>
  </div>

  <div style="margin-bottom: 0.75em;">
    <label>
      Rating:
      <select bind:value={rating}>
        <option value={1}>1 star — Very Poor</option>
        <option value={2}>2 stars — Poor</option>
        <option value={3}>3 stars — Average</option>
        <option value={4}>4 stars — Good</option>
        <option value={5}>5 stars — Excellent</option>
      </select>
    </label>
  </div>

  <div style="margin-bottom: 0.75em;">
    <label>
      Comment (optional):
      <textarea bind:value={comment} rows={3} placeholder="Tell us about your experience" style="width: 100%;"></textarea>
    </label>
  </div>

  <div style="margin-bottom: 0.75em;">
    <label>
      Order Reference (optional):
      <input type="text" bind:value={orderReference} placeholder="Order ID or composition UID" style="width: 100%;" />
    </label>
  </div>

  <button onclick={submitFeedback} disabled={submitting || !customerName}>
    {submitting ? 'Submitting…' : 'Submit Feedback'}
  </button>
</div>

<hr />

<h2>All Feedback (Entity View)</h2>
<button onclick={loadFeedback} disabled={listLoading}>
  {listLoading ? 'Loading…' : 'Load Feedback from CDR'}
</button>

{#if feedbackList.length > 0}
  <table style="margin-top: 1em; border-collapse: collapse; width: 100%;">
    <thead>
      <tr style="border-bottom: 2px solid #333; text-align: left;">
        <th style="padding: 0.3em 0.5em;">Time</th>
        <th style="padding: 0.3em 0.5em;">Rating</th>
        <th style="padding: 0.3em 0.5em;">Comment</th>
        <th style="padding: 0.3em 0.5em;">Order Ref</th>
        <th style="padding: 0.3em 0.5em;">EHR ID</th>
      </tr>
    </thead>
    <tbody>
      {#each feedbackList as entry}
        <tr style="border-bottom: 1px solid #ddd;">
          <td style="padding: 0.3em 0.5em;">{formatTime(entry.feedbackTime)}</td>
          <td style="padding: 0.3em 0.5em;">{entry.rating}</td>
          <td style="padding: 0.3em 0.5em;">{entry.comment ?? '—'}</td>
          <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.75em;">{entry.orderReference ?? '—'}</code></td>
          <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.75em;">{entry.ehrId}</code></td>
        </tr>
      {/each}
    </tbody>
  </table>
{:else if !listLoading && feedbackList.length === 0}
  <p style="margin-top: 0.5em; color: #666;">No feedback yet. Submit some above!</p>
{/if}
