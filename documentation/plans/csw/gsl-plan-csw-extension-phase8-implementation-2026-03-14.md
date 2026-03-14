# CSW Extension Phase 8: Data & Insights Pages — Detailed Implementation Plan

**Workstream:** Coffee Shop Extension — Catalogue, Inventory & Frontend
**Phase:** 8 of 10
**Date:** 14 March 2026
**Session:** 27
**Prerequisites:** Phase 7 complete (Order Board & Order Timeline, Session 26)
**Source plan:** `gsl-plan-csw -extension-workstream-2026-03-12.md` §Phase 8
**Estimated effort:** 5 stages across 2–3 commits

---

## Goal

The three pages under "Data & Insights" in the sidebar — Records (`/entity`), Audit Dashboard (`/governance`), and Customer Voice (`/feedback`) — are functional but were built during the Phase C/D CDR exercise (Sessions 3–6) and received only minimal visual updates during Phase 4 (frontend foundation). They are the least polished pages in the application, using raw table layouts, manual "load" buttons, and plain text where richer visual patterns would better communicate the data.

Phase 8 brings these pages up to the standard established by the Counter (Phase 5), Manager GUI (Phase 6), and Order Board/Timeline (Phase 7) — visual richness, consistent Flowbite component usage, and clear information hierarchy.

This phase is **entirely frontend**. No new API routes are needed — all data comes from existing entity endpoints built in Phases C and D.

---

## Architecture Overview

### API Surface (All Existing — No Backend Changes)

| Route | Method | Purpose | Built in |
|---|---|---|---|
| `/api/entity/orders` | GET | All order compositions (CDR entity view) | Phase C |
| `/api/entity/orders/today` | GET | Today's order compositions | Phase C |
| `/api/entity/customers/[ehrId]/orders` | GET | Orders for a specific customer | Phase C |
| `/api/entity/feedback` | GET | All feedback compositions | Phase C |
| `/api/entity/feedback` | POST | Submit new feedback | Phase C |
| `/api/entity/governance` | GET | Population-level completeness audit | Phase D |

### Design Principles for Phase 8

1. **Auto-load on mount.** The current Records and Audit Dashboard pages require the user to click a button to load data. This was appropriate for the CDR exercise (explicit query execution) but is wrong for an operational application. All three pages should load their primary data automatically on mount.

2. **Cards over raw tables.** Where the data represents discrete entities (orders, feedback entries), render as cards with visual hierarchy rather than raw table rows. Tables remain appropriate for tabular detail (e.g. within an expanded customer audit section).

3. **Visual indicators for CDR provenance.** These pages show data from the CDR (EHRbase), distinct from the PostgreSQL business data shown on the Counter and Manager pages. Each page should visually indicate its data source — reinforcing the three-persistence-layer architecture.

4. **Consistent split-view pattern where appropriate.** The Records page has a natural split: entity list on the left, detail panel on the right — matching the Counter and Manager patterns.

5. **No new API routes.** All data reshaping is client-side. The existing API responses provide all needed fields.

---

## Stage 1: Records Page — Tabbed Entity View with Record Cards

### 1.1 Current state

The existing `/entity` page has three manual-trigger buttons (All Orders, Today's Orders, Customer Orders) that each call a different API endpoint and render results in a Flowbite Table. There is no auto-loading, no visual record cards, and no indication of CDR provenance beyond a text metadata bar.

### 1.2 Design

Replace with a tabbed interface that auto-loads data and renders order records as cards:

```
/entity (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Records" + CDR source badge                          │
│  "Entity view of CDR data — organised by data type, not by process" │
├─────────────────────────────────────────────────────────────────────┤
│  [ All Orders ]  [ Today ]  [ By Customer ]     N records · CDR     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        │
│  │ ☕ Flat White   │  │ ☕ Americano    │  │ ☕ Cappuccino   │        │
│  │ Regular · Oat   │  │ Large          │  │ Regular · Whole │        │
│  │ £2.80           │  │ £2.50          │  │ £2.80           │        │
│  │ 14:23 today     │  │ 13:45 today    │  │ 12:10 today     │        │
│  │ EHR: a3f2…      │  │ EHR: b7c1…     │  │ EHR: a3f2…      │        │
│  └────────────────┘  └────────────────┘  └────────────────┘        │
│                                                                     │
│  ┌────────────────┐  ┌────────────────┐  ...                        │
│  │ ...             │  │ ...             │                            │
│  └────────────────┘  └────────────────┘                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.3 Tabbed navigation

Use Flowbite tab styling (underline style) for the three views. The active tab determines which API endpoint is called. The "By Customer" tab shows an inline EHR ID input field.

```typescript
type ViewTab = 'all' | 'today' | 'customer';
let activeTab = $state<ViewTab>('all');
let ehrIdInput = $state('');
let orders = $state<OrderRow[]>([]);
let loading = $state(true);
let error = $state('');
let viewMeta = $state<Record<string, unknown>>({});

// Auto-load on mount
onMount(() => {
  fetchOrders('all');
});

// Re-fetch when tab changes
function switchTab(tab: ViewTab) {
  activeTab = tab;
  if (tab !== 'customer') {
    fetchOrders(tab);
  }
}
```

### 1.4 Order record cards

Each order renders as a card rather than a table row. The card shows:

- **Drink name** as the card title (bold, larger text)
- **Size and milk** as subtitle detail
- **Price** with currency formatting
- **Order time** in relative format ("14:23 today" or "Yesterday 09:15")
- **EHR ID** abbreviated (first 8 chars) with copy-on-click
- **Composition UID** abbreviated, shown on hover or in a detail expansion

```svelte
<div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
  {#each orders as order}
    <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
      <!-- Header -->
      <div class="mb-2 flex items-start justify-between">
        <div>
          <h3 class="font-semibold text-secondary-800 dark:text-white">{order.drinkName}</h3>
          <p class="text-sm text-secondary-500 dark:text-secondary-400">
            {order.drinkSize}
            {#if order.milkChoice} · {order.milkChoice}{/if}
          </p>
        </div>
        <span class="text-lg font-bold text-primary-700 dark:text-primary-300">{order.price}</span>
      </div>

      <!-- Metadata -->
      <div class="flex flex-wrap gap-2 text-xs text-secondary-400 dark:text-secondary-500">
        <span>{formatOrderTime(order.orderTime)}</span>
        <span>·</span>
        <span title={order.ehrId ?? ''}>EHR: <code>{(order.ehrId ?? '').substring(0, 8)}…</code></span>
      </div>
    </div>
  {/each}
</div>
```

### 1.5 CDR source indicator

A persistent badge in the page header and metadata bar:

```svelte
<div class="mb-6">
  <div class="flex items-center gap-3">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Records</h1>
    <Badge color="indigo" class="text-xs">CDR · EHRbase</Badge>
  </div>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Entity view — data organised by type, not by process.
    Compare with <a href="/orders" class="text-primary-600 hover:underline dark:text-primary-400">Order Board</a> (process view).
  </p>
</div>
```

### 1.6 Count and metadata bar

Below the tabs, show a summary strip:

```svelte
<div class="mb-4 flex items-center gap-3 text-sm text-secondary-500 dark:text-secondary-400">
  <span>{orders.length} record{orders.length !== 1 ? 's' : ''}</span>
  {#if viewMeta.date}
    <span>· {viewMeta.date}</span>
  {/if}
  {#if viewMeta.ehrId}
    <span>· Customer <code class="text-xs">{String(viewMeta.ehrId).substring(0, 8)}…</code></span>
  {/if}
  <span class="ml-auto text-xs">Source: AQL → EHRbase</span>
</div>
```

### 1.7 "By Customer" tab — inline input

When the "By Customer" tab is active, show an inline input field within the tab area (not a separate form section):

```svelte
{#if activeTab === 'customer'}
  <div class="mt-3 flex items-end gap-2">
    <div class="flex-1 max-w-sm">
      <Label for="ehrId" class="mb-1 text-xs">EHR ID</Label>
      <Input id="ehrId" size="sm" bind:value={ehrIdInput} placeholder="Paste EHR UUID" />
    </div>
    <Button size="sm" color="primary" onclick={() => fetchOrders('customer')} disabled={loading || !ehrIdInput.trim()}>
      Load
    </Button>
  </div>
{/if}
```

### 1.8 Empty and loading states

```svelte
{#if loading}
  <div class="flex items-center gap-2 py-8 text-secondary-500">
    <Spinner size="5" /> Loading records from CDR…
  </div>
{:else if orders.length === 0}
  <div class="rounded-lg border-2 border-dashed border-secondary-200 p-8 text-center text-sm text-secondary-400 dark:border-secondary-700 dark:text-secondary-500">
    No records found. {#if activeTab === 'today'}No orders placed today.{:else if activeTab === 'customer'}Check the EHR ID and try again.{:else}Place an order from the <a href="/" class="text-primary-600 hover:underline">Counter</a> to see records here.{/if}
  </div>
{/if}
```

### 1.9 Time formatting helper

```typescript
function formatOrderTime(iso: string): string {
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
}
```

### 1.10 Verification

1. Page auto-loads "All Orders" tab on mount — no manual button click needed
2. Tab switching loads the correct data set (all / today / customer)
3. Record cards display drink name, size, milk, price, time, EHR ID
4. "By Customer" tab shows inline EHR ID input
5. Empty states display correctly per tab
6. CDR source badge appears in the header
7. Count and metadata bar updates with each fetch
8. Grid layout is responsive: 3 columns → 2 → 1 on mobile
9. Dark mode renders correctly for all card and tab styles
10. Error states are handled gracefully (CDR connectivity failure)

### 1.11 Commit point

Combined with Stage 2 for a meaningful commit.

---

## Stage 2: Records Page — Table Toggle and AQL Visual Indicator

### 2.1 Table/card view toggle

Some users may prefer the tabular view for scanning data quickly (e.g. comparing composition UIDs). Add a simple toggle between card view and table view:

```svelte
<div class="mb-4 flex items-center justify-between">
  <!-- Count and metadata (from 1.6) -->
  <div class="flex items-center gap-3 text-sm text-secondary-500 dark:text-secondary-400">
    <span>{orders.length} record{orders.length !== 1 ? 's' : ''}</span>
    <!-- ... -->
  </div>

  <!-- View toggle -->
  <div class="flex rounded-lg border border-secondary-200 dark:border-secondary-700">
    <button
      class="px-3 py-1.5 text-xs font-medium {viewMode === 'cards' ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-500 hover:bg-secondary-50 dark:text-secondary-400 dark:hover:bg-secondary-800'}"
      onclick={() => viewMode = 'cards'}
    >Cards</button>
    <button
      class="px-3 py-1.5 text-xs font-medium {viewMode === 'table' ? 'bg-primary-100 text-primary-700 dark:bg-primary-900/30 dark:text-primary-300' : 'text-secondary-500 hover:bg-secondary-50 dark:text-secondary-400 dark:hover:bg-secondary-800'}"
      onclick={() => viewMode = 'table'}
    >Table</button>
  </div>
</div>
```

The table view retains the existing Flowbite Table with the same data, but with updated styling for consistency. The card view is the default.

### 2.2 AQL query indicator

Below the metadata bar, show a collapsible AQL query indicator — a small panel that explains what AQL query is being used. This demonstrates the CDR query model to the user and reinforces the clinical analogy:

```svelte
<details class="mb-4">
  <summary class="cursor-pointer text-xs text-secondary-400 hover:text-secondary-600 dark:text-secondary-500 dark:hover:text-secondary-300">
    AQL query details
  </summary>
  <div class="mt-2 rounded-lg bg-secondary-50 p-3 text-xs dark:bg-secondary-800/50">
    <p class="mb-1 text-secondary-600 dark:text-secondary-400">
      <strong>Query type:</strong> {AQL_DESCRIPTIONS[activeTab].type}
    </p>
    <p class="mb-1 text-secondary-600 dark:text-secondary-400">
      <strong>Clinical analogy:</strong> {AQL_DESCRIPTIONS[activeTab].analogy}
    </p>
    <p class="text-secondary-500 dark:text-secondary-400">
      <strong>Archetype:</strong> <code>openEHR-EHR-OBSERVATION.order_record.v0</code>
    </p>
  </div>
</details>
```

With configuration:

```typescript
const AQL_DESCRIPTIONS: Record<ViewTab, { type: string; analogy: string }> = {
  all:      { type: 'All compositions by type',    analogy: '"Show me all lab results across all patients"' },
  today:    { type: 'Date-filtered compositions',   analogy: '"Show me all consultations today"' },
  customer: { type: 'Patient-scoped compositions',  analogy: '"Show me all lab results for this patient"' },
};
```

### 2.3 Verification

1. View toggle switches between card and table views
2. Default view is cards
3. AQL query details collapsible works
4. AQL descriptions are correct per tab
5. Toggle state persists within the session (not across page navigations)

### 2.4 Commit point

```bash
git add -A && git commit -m "CSW frontend: Records page with tabbed entity view, record cards, and AQL indicators"
```

---

## Stage 3: Audit Dashboard — Auto-Loading Compliance Dashboard

### 3.1 Current state

The existing `/governance` page has a manual "Run Governance Audit" button that triggers the CDR completeness check. Results show summary cards, a compliance rate, and expandable customer detail sections with inline order/preparation tables. The structure is good but the manual trigger is awkward, and the layout could be tightened.

### 3.2 Design

Retain the governance report structure (it works well) but make three changes:

1. **Auto-load the audit on mount** — the CDR data completeness check runs automatically when the page loads, with a refresh button for re-running.
2. **Visual compliance gauge** — replace the plain "100.0%" text with a visual radial gauge or coloured progress bar.
3. **Layout refinement** — tighter card grid, more prominent governance question, improved customer detail section with Flowbite Accordion.

```
/governance (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Audit Dashboard" + CDR source badge                  │
│  "Population-level data completeness check"                         │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ "Does every order also have a preparation event recorded?"   │   │
│  └──────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────────────────┐ ┌───────────┐  │
│  │  3   │ │  5   │ │  4   │ │  ███████░░  80%    │ │  1 Gap    │  │
│  │Cust. │ │Orders│ │Preps │ │ Compliance Rate    │ │ Data Gaps │  │
│  └──────┘ └──────┘ └──────┘ └────────────────────┘ └───────────┘  │
├─────────────────────────────────────────────────────────────────────┤
│  Customer Detail (Accordion)                                        │
│  ▶ ✗ NON-COMPLIANT  a3f2… — Orders: 2 | Preps: 1 | Gap: 1        │
│  ▶ ✓ COMPLIANT      b7c1… — Orders: 2 | Preps: 2 | Gap: 0        │
│  ▶ ✓ COMPLIANT      c9d4… — Orders: 1 | Preps: 1 | Gap: 0        │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.3 Auto-load and refresh

```typescript
let loading = $state(true);
let report = $state<GovernanceReport | null>(null);
let errorMessage = $state('');

onMount(() => {
  runAudit();
});

async function runAudit() {
  loading = true;
  errorMessage = '';
  try {
    const response = await fetch('/api/entity/governance');
    if (!response.ok) {
      const data = await response.json();
      errorMessage = data.message || `Error: ${response.status}`;
      return;
    }
    report = await response.json();
  } catch (err) {
    errorMessage = err instanceof Error ? err.message : 'Failed to run governance audit';
  } finally {
    loading = false;
  }
}
```

### 3.4 Compliance progress bar

Replace the plain percentage text with a horizontal bar:

```svelte
{@const rate = parseFloat(report.summary.complianceRate) || 0}
{@const barColor = rate === 100 ? 'bg-green-500' : rate >= 75 ? 'bg-yellow-500' : 'bg-red-500'}

<div class="min-w-[180px] rounded-lg bg-secondary-50 p-4 dark:bg-secondary-800">
  <div class="mb-2 text-2xl font-bold text-secondary-800 dark:text-white">{report.summary.complianceRate}</div>
  <div class="mb-1 h-2 w-full overflow-hidden rounded-full bg-secondary-200 dark:bg-secondary-700">
    <div class="{barColor} h-2 rounded-full transition-all duration-500" style="width: {rate}%"></div>
  </div>
  <div class="text-xs text-secondary-500 dark:text-secondary-400">Compliance Rate</div>
</div>
```

### 3.5 Summary cards — refined layout

The existing summary cards work well but can be tighter. Keep the same five metrics but arrange them in a responsive grid:

```svelte
<div class="mb-6 grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-5">
  {#each summaryCards as card}
    <div class="rounded-lg {card.bg} p-4 text-center">
      <div class="text-2xl font-bold text-secondary-800 dark:text-white">{card.value}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">{card.label}</div>
    </div>
  {/each}
</div>
```

The compliance rate card is wider (spans 2 columns on narrow screens) to accommodate the progress bar.

### 3.6 Governance question — prominent banner

Elevate the governance question to a more visually prominent position, matching the "policy statement" pattern:

```svelte
<div class="mb-6 rounded-lg border-l-4 border-primary-500 bg-primary-50 p-4 dark:bg-primary-900/20">
  <p class="text-xs font-semibold uppercase tracking-wider text-primary-600 dark:text-primary-400">Governance Question</p>
  <p class="mt-1 text-secondary-700 dark:text-secondary-300">{report.governanceQuestion}</p>
  <p class="mt-2 text-xs text-secondary-400 dark:text-secondary-500 italic">
    Clinical analogy: "Does every patient on hormone therapy who has passed their 3-month mark have monitoring bloods recorded?"
  </p>
</div>
```

### 3.7 Customer detail — existing accordion pattern

The existing expandable customer sections work well. Retain the structure with minor refinements:

- Use consistent border colouring (green for compliant, red for non-compliant)
- Add the CDR source indicator to the detail section header
- Keep the inline order/preparation tables within expanded sections (tables are appropriate here for detailed comparison)

### 3.8 Refresh button

Instead of the prominent "Run Governance Audit" button, add a subtle refresh action in the page header:

```svelte
<div class="flex items-center gap-3">
  <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Audit Dashboard</h1>
  <Badge color="indigo" class="text-xs">CDR · EHRbase</Badge>
  {#if !loading}
    <button
      onclick={runAudit}
      class="text-xs text-secondary-400 hover:text-secondary-600 dark:text-secondary-500 dark:hover:text-secondary-300"
      title="Re-run audit"
    >↻ Refresh</button>
  {/if}
</div>
```

### 3.9 Verification

1. Audit runs automatically on page load — no manual trigger needed
2. Compliance progress bar renders correctly at 0%, partial, and 100%
3. Summary cards show correct counts
4. Governance question banner is visually prominent
5. Customer detail accordion expands/collapses
6. Non-compliant customers sort first
7. Unmatched orders highlighted in expanded detail
8. Refresh button re-runs the audit
9. Loading spinner during audit execution
10. Error state if CDR is unavailable
11. Dark mode correct throughout

### 3.10 Commit point

```bash
git add -A && git commit -m "CSW frontend: Audit Dashboard with auto-loading compliance gauge and refined layout"
```

---

## Stage 4: Customer Voice — Visual Feedback with Star Ratings

### 4.1 Current state

The existing `/feedback` page has two sections: a submit form (Card with form fields) and a "Load Feedback from CDR" button that renders results in a table. The rating is a `<Select>` dropdown (1–5 with text labels). The feedback list shows raw text.

### 4.2 Design

Improve three areas:

1. **Visual star rating input** — replace the dropdown with clickable/hoverable stars
2. **Auto-load feedback list** — remove the manual "Load" button
3. **Feedback cards with star display** — replace the table with cards showing visual star ratings

```
/feedback (+page.svelte)
┌─────────────────────────────────────────────────────────────────────┐
│  Page Header: "Customer Voice" + CDR source badge                   │
│  "Form-driven data entry — commits directly to the CDR"             │
├──────────────────────────────────┬──────────────────────────────────┤
│  Submit Feedback (Card)          │  Recent Feedback                 │
│                                  │                                  │
│  Customer Name: [          ]     │  ┌────────────────────────────┐  │
│                                  │  │ ★★★★★  "Great coffee!"    │  │
│  Rating: ★★★★☆               │  │ Alice · 14:23 today        │  │
│                                  │  │ CDR: a3f2…               │  │
│  Comment: [                ]     │  └────────────────────────────┘  │
│                                  │                                  │
│  Order Ref: [              ]     │  ┌────────────────────────────┐  │
│                                  │  │ ★★★☆☆  "A bit lukewarm"  │  │
│  [     Submit Feedback     ]     │  │ Bob · 13:45 today         │  │
│                                  │  │ CDR: b7c1…               │  │
│                                  │  └────────────────────────────┘  │
├──────────────────────────────────┴──────────────────────────────────┤
│  Clinical analogy: "A patient completing a PROM outside any         │
│  scheduled pathway step."                                           │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.3 Split-view layout

The feedback page naturally splits into a submit form (left) and a feedback list (right), matching the split-view pattern from the Counter and Manager pages:

```svelte
<div class="flex flex-col gap-6 lg:flex-row">
  <!-- Left: Submit form -->
  <div class="w-full lg:w-96 shrink-0">
    <!-- Form card -->
  </div>

  <!-- Right: Feedback list -->
  <div class="flex-1 min-w-0">
    <!-- Feedback cards -->
  </div>
</div>
```

### 4.4 Star rating input component

Replace the `<Select>` dropdown with a visual star rating:

```svelte
<div class="mb-4">
  <Label class="mb-2">Rating</Label>
  <div class="flex gap-1">
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
    <span class="ml-2 self-center text-sm text-secondary-500 dark:text-secondary-400">
      {RATING_LABELS[rating]}
    </span>
  </div>
</div>
```

With labels:

```typescript
let hoverRating = $state(0);

const RATING_LABELS: Record<number, string> = {
  1: 'Very Poor',
  2: 'Poor',
  3: 'Average',
  4: 'Good',
  5: 'Excellent',
};
```

### 4.5 Feedback list — auto-loading cards

Auto-load the feedback list on mount and after each successful submission. Render as cards with visual star display:

```svelte
{#each feedbackList as entry}
  <div class="rounded-lg border border-secondary-200 bg-white p-4 dark:border-secondary-700 dark:bg-secondary-800">
    <!-- Stars and comment -->
    <div class="mb-2 flex items-start gap-3">
      <div class="flex text-lg">
        {#each [1, 2, 3, 4, 5] as star}
          <span class="{parseInt(entry.rating) >= star ? 'text-yellow-400' : 'text-secondary-200 dark:text-secondary-600'}">★</span>
        {/each}
      </div>
      {#if entry.comment}
        <p class="flex-1 text-sm text-secondary-700 dark:text-secondary-300 italic">"{entry.comment}"</p>
      {/if}
    </div>

    <!-- Metadata -->
    <div class="flex flex-wrap gap-2 text-xs text-secondary-400 dark:text-secondary-500">
      <span>{formatTime(entry.feedbackTime)}</span>
      {#if entry.orderReference}
        <span>· Ref: <code>{entry.orderReference}</code></span>
      {/if}
      <span>· EHR: <code>{entry.ehrId.substring(0, 8)}…</code></span>
    </div>
  </div>
{/each}
```

### 4.6 Post-submit refresh

After successful feedback submission, auto-reload the feedback list so the new entry appears immediately:

```typescript
async function submitFeedback() {
  submitting = true;
  errorMessage = '';
  successMessage = '';
  try {
    // ... existing submit logic ...
    successMessage = `Feedback submitted!`;
    comment = '';
    rating = 4;
    orderReference = '';
    // Refresh the list
    await loadFeedback();
  } catch (err) {
    errorMessage = err instanceof Error ? err.message : 'Failed to submit feedback';
  } finally {
    submitting = false;
  }
}
```

### 4.7 CDR source indicator

Like the Records page, show the CDR provenance:

```svelte
<div class="mb-6">
  <div class="flex items-center gap-3">
    <h1 class="text-2xl font-bold text-secondary-800 dark:text-white">Customer Voice</h1>
    <Badge color="indigo" class="text-xs">CDR · EHRbase</Badge>
  </div>
  <p class="text-sm text-secondary-500 dark:text-secondary-400">
    Form-driven data entry — commits directly to the CDR, <strong>no workflow involved</strong>.
  </p>
</div>
```

### 4.8 Clinical analogy footer

Retain but restyle the clinical analogy note:

```svelte
<div class="mt-6 rounded-lg bg-secondary-50 p-4 text-xs text-secondary-500 dark:bg-secondary-800/50 dark:text-secondary-400">
  <strong>Clinical analogy:</strong> A patient completing a Patient-Reported Outcome Measure (PROM) questionnaire
  outside any scheduled pathway step. Data enters the CDR directly via form submission — no Temporal workflow involved.
  This demonstrates that the CDR accepts data from multiple entry points, not just workflow activities.
</div>
```

### 4.9 Verification

1. Feedback list auto-loads on mount
2. Star rating input is interactive (hover and click)
3. Star rating label updates on selection
4. Form submission works with visual stars
5. Feedback list refreshes after successful submission
6. Feedback cards show visual star display
7. Comments shown in italics with quotation marks
8. CDR source badge present
9. Split-view layout works on desktop, stacks on mobile
10. Dark mode correct for star colours, card backgrounds
11. Empty state when no feedback exists
12. Error handling for CDR connectivity failure

### 4.10 Commit point

```bash
git add -A && git commit -m "CSW frontend: Customer Voice with visual star ratings and auto-loading feedback cards"
```

---

## Stage 5: Polish, Cross-Page Consistency, and Integration Testing

### 5.1 Cross-page consistency checks

Verify consistent patterns across all three Phase 8 pages:

- **CDR source badge:** All three pages show `CDR · EHRbase` badge in the header
- **Auto-loading:** All three pages load data on mount (no manual trigger buttons)
- **Colour coding:** The indigo badge colour for CDR pages is distinct from the green/blue operational badges
- **Clinical analogies:** Each page includes a clinical analogy note
- **Error states:** All three pages handle CDR unavailability gracefully
- **Empty states:** All three pages show helpful empty state messages

### 5.2 CDR source badge consistency with non-CDR pages

The CDR pages use an indigo badge; the operational pages (Counter, Order Board) and management pages (Stock & Catalogue) do not have a source badge (their data comes from PostgreSQL and Temporal). This visual distinction reinforces the three-persistence-layer architecture without being heavy-handed.

### 5.3 Navigation link updates

Check that all cross-page links are up to date:

- Records page → links to Order Board (process view counterpart)
- Audit Dashboard → no cross-links needed (self-contained)
- Customer Voice → could link to Records (to see the committed data appear)
- Order Timeline → links to Records page (CDR records)

### 5.4 End-to-end integration test

Complete scenario exercising all three Phase 8 pages:

1. **Place an order** from the Counter page
2. **Navigate to Records** → "All Orders" tab shows the new order as a card (CDR composition exists because the workflow committed it)
3. **Switch to "Today" tab** → same order appears (date filter)
4. **Toggle to table view** → data appears in tabular format
5. **Expand AQL query details** → shows query type and clinical analogy
6. **Navigate to Audit Dashboard** → audit runs automatically
7. **Check summary cards** → order count and preparation count reflect the new order
8. **If order is completed:** compliance should be 100% (preparation event recorded). If not yet completed: compliance gap should be visible (order without preparation)
9. **Expand customer detail** → shows order and preparation records
10. **Navigate to Customer Voice** → feedback list loads automatically
11. **Submit feedback** with 5 stars and a comment → success message appears, list refreshes, new entry visible as a card with stars
12. **Dark mode:** verify all three pages in dark mode

### 5.5 Dark mode verification

All new components across the three pages:

- Record cards: white/secondary-800 backgrounds, secondary-200/700 borders
- Tab styling: active tab highlight, inactive tab hover
- View toggle: active/inactive button states
- AQL detail panel: secondary-50/800 backgrounds
- Compliance progress bar: green/yellow/red on secondary-200/700 track
- Star rating: yellow-400 filled, secondary-300/600 empty
- Feedback cards: same pattern as record cards
- CDR source badges: indigo colour in both modes

### 5.6 Mobile responsiveness

- Record cards: 3 → 2 → 1 column grid
- Feedback split-view: side-by-side → stacked
- Audit summary cards: 5 → 3 → 2 column grid
- Customer detail accordion: full width, no horizontal scroll
- Tabs: wrap gracefully on narrow screens

### 5.7 Final commit

```bash
git add -A && git commit -m "CSW frontend: Data & Insights pages polish and integration verification"
```

---

## Files Created / Modified

### Modified files

| File | Change |
|---|---|
| `src/routes/entity/+page.svelte` | **Rewritten** — tabbed entity view with record cards, view toggle, AQL indicators |
| `src/routes/governance/+page.svelte` | **Rewritten** — auto-loading audit with compliance progress bar and refined layout |
| `src/routes/feedback/+page.svelte` | **Rewritten** — split-view with visual star ratings and auto-loading feedback cards |

### Unchanged

All API routes, all `$lib/server/` modules, all `packages/shared/` and `packages/temporal/` code, the Counter page, the Order Board, the Order Timeline, the Manager GUI, the layout, `app.css`, and all other pages and system pages.

This phase is entirely frontend — no backend changes, no new API routes, no package changes.

---

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| **CDR data latency on page load** | Medium | The governance audit in particular runs two AQL queries and does application-side joining. Show a loading spinner; the query typically completes in < 1 second with the demonstrator's data volume. If slow, the auto-load pattern gracefully degrades to "loading…" with no broken UI. |
| **Star rating accessibility** | Low | The star buttons use `aria-label` for screen readers and are keyboard-navigable (standard button focus). The text label next to the stars provides redundant information. |
| **Empty CDR on first visit** | Medium | All three pages handle the "no data" case. The Records and Audit pages show helpful messages directing users to the Counter to create data. The Feedback page's submit form is always available regardless of existing data. |
| **EHR ID input for customer view** | Low | The "By Customer" tab requires a UUID that most users won't have memorised. The existing Records page has this same limitation. A future enhancement would be a customer name search or a dropdown populated from known EHR IDs. Not in scope for Phase 8. |
| **Flowbite component interactions** | Low | All Flowbite components used (Badge, Table, Spinner, Alert, Input, Label, Button, Card) are proven from previous phases. No new component patterns. |

---

## What This Phase Does Not Do

- Does not add new API routes or backend logic (all endpoints exist from Phases C/D)
- Does not add CDR composition detail view (clicking a composition UID to see the full openEHR JSON) — this would be a useful future enhancement but is not needed for the demonstrator
- Does not add feedback analytics (average rating, rating distribution, trend over time) — this would require application-side aggregation from the entity view. Candidate for Phase 9 (System Status page) or a post-workstream enhancement
- Does not add customer name resolution (EHR ID → customer name lookup) — the CDR doesn't expose a simple name lookup; the EHR ID is the canonical identifier. Customer names appear in composition content, not in the EHR metadata
- Does not modify the SysML model (Phase 10)
- Does not implement Knowledge Layer Increments — this phase is pure UI polish for existing data views

---

## Coffee Shop Demonstrator Extension

**Capability demonstrated:** Rich data exploration across the CDR — entity views with tabbed navigation, visual record cards, automated governance auditing with compliance visualisation, and form-driven data entry with immediate visual feedback. The CDR source provenance is consistently indicated across all entity-view pages.

**Clinical implementation confidence:** High. The patterns map directly to:

- **Clinical records view:** Tabbed entity view for lab results (All / Recent / By Patient). Record cards showing result values, reference ranges, and ordering clinician. AQL query indicator shows the clinical query model.
- **Governance dashboard:** Auto-loading compliance audit for pathway adherence. "Does every patient on hormone therapy who has passed their 3-month mark have monitoring bloods recorded?" — the exact clinical analogy currently shown on the Audit Dashboard page. The compliance progress bar becomes a real governance metric.
- **Patient-reported outcomes:** The Customer Voice pattern maps directly to PROM questionnaire submission — structured data entry outside any workflow, committed directly to the CDR. Visual star ratings become Likert scales or validated PROM instruments.

**What will be learned:**

- Whether auto-loading CDR data on page mount provides an acceptable user experience (vs explicit query execution)
- Whether card-based record display is more effective than tabular display for scanning entity-view data
- How the visual CDR source indicator communicates the three-persistence-layer architecture
- Whether the star rating input pattern is intuitive and accessible

---

## Relationship to Subsequent Phases

### Phase 9 — System Pages

Phase 9 (Process Model and System Status) is the final frontend phase. Phase 8's CDR source badges establish a pattern that Phase 9 can extend — the System Status page could show connection status for all three persistence layers (PostgreSQL, Temporal, EHRbase) with the same badge visual language.

### Phase 10 — Meta Model Update

Phase 8 introduces no new concepts to the SysML model. However, the visual patterns (entity view tabs, compliance gauge, star ratings) could inform meta model concepts around "data view" and "visual indicator" if a UI pattern catalogue is developed as part of Phase 10 or the subsequent Pattern Catalogue workstream.

### Knowledge Layer Increment 1

The Records page's record cards could eventually display inline constraint evaluation results — "This order was evaluated against SysML constraint X: PASS" — once KL Increment 1 is implemented. Phase 8 creates a richer visual surface for this.

---

*Plan prepared 14 March 2026. Phase 8 of the CSW Extension workstream.*
