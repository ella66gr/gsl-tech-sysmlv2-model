<script lang="ts">
  let loading = $state(false);
  let errorMessage = $state('');
  let report = $state<GovernanceReport | null>(null);
  let expandedCustomer = $state<string | null>(null);

  interface OrderRecord {
    ehrId: string;
    compositionUid: string;
    orderTime: string;
    drinkName: string;
    drinkSize: string;
    milkChoice: string | null;
    price: string;
  }

  interface PrepRecord {
    ehrId: string;
    compositionUid: string;
    prepTime: string;
    prepMethod: string | null;
    baristaName: string | null;
  }

  interface CustomerAudit {
    ehrId: string;
    orderCount: number;
    prepCount: number;
    gap: number;
    compliant: boolean;
    orders: OrderRecord[];
    preparations: PrepRecord[];
    unmatched: OrderRecord[];
  }

  interface GovernanceReport {
    title: string;
    generatedAt: string;
    governanceQuestion: string;
    source: string;
    summary: {
      totalCustomers: number;
      totalOrders: number;
      totalPreparations: number;
      totalGaps: number;
      compliantCustomers: number;
      nonCompliantCustomers: number;
      complianceRate: string;
    };
    customers: CustomerAudit[];
  }

  async function runAudit() {
    loading = true;
    errorMessage = '';
    report = null;
    expandedCustomer = null;

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

  function formatTime(iso: string): string {
    try {
      return new Date(iso).toLocaleString();
    } catch {
      return iso;
    }
  }

  function shortUid(uid: string): string {
    return uid.split('::')[0]?.substring(0, 8) ?? uid;
  }

  function toggleCustomer(ehrId: string) {
    expandedCustomer = expandedCustomer === ehrId ? null : ehrId;
  }
</script>

<h1>Governance Audit</h1>
<p>Population-level data completeness check against the CDR.</p>
<p style="color: #666; font-size: 0.9em;">
  Clinical analogy: "Does every patient on hormone therapy who has passed their
  3-month mark have monitoring bloods recorded?"
</p>

<hr />

<button onclick={runAudit} disabled={loading} style="font-size: 1em; padding: 0.5em 1.5em;">
  {loading ? 'Running audit…' : 'Run Governance Audit'}
</button>

{#if errorMessage}
  <p style="color: red; margin-top: 1em;"><strong>Error:</strong> {errorMessage}</p>
{/if}

{#if report}
  <div style="margin-top: 1.5em;">
    <h2>{report.title}</h2>
    <p style="font-size: 0.85em; color: #666;">
      Generated: {formatTime(report.generatedAt)} &nbsp;|&nbsp; Source: {report.source}
    </p>

    <div style="margin: 1em 0; padding: 1em; background: #f0f4f8; border-radius: 6px; border-left: 4px solid #4a7ab5;">
      <strong>Governance question:</strong> {report.governanceQuestion}
    </div>

    <!-- Summary cards -->
    <div style="display: flex; gap: 1em; flex-wrap: wrap; margin: 1em 0;">
      <div style="padding: 1em; background: #f5f5f5; border-radius: 6px; min-width: 120px; text-align: center;">
        <div style="font-size: 2em; font-weight: bold;">{report.summary.totalCustomers}</div>
        <div style="font-size: 0.85em; color: #666;">Customers</div>
      </div>
      <div style="padding: 1em; background: #f5f5f5; border-radius: 6px; min-width: 120px; text-align: center;">
        <div style="font-size: 2em; font-weight: bold;">{report.summary.totalOrders}</div>
        <div style="font-size: 0.85em; color: #666;">Orders</div>
      </div>
      <div style="padding: 1em; background: #f5f5f5; border-radius: 6px; min-width: 120px; text-align: center;">
        <div style="font-size: 2em; font-weight: bold;">{report.summary.totalPreparations}</div>
        <div style="font-size: 0.85em; color: #666;">Preparations</div>
      </div>
      <div style="padding: 1em; border-radius: 6px; min-width: 120px; text-align: center;"
           style:background={report.summary.totalGaps > 0 ? '#fde8e8' : '#e8fde8'}>
        <div style="font-size: 2em; font-weight: bold;">{report.summary.totalGaps}</div>
        <div style="font-size: 0.85em; color: #666;">Data Gaps</div>
      </div>
      <div style="padding: 1em; border-radius: 6px; min-width: 140px; text-align: center;"
           style:background={report.summary.complianceRate === '100.0%' ? '#e8fde8' : '#fef9e7'}>
        <div style="font-size: 2em; font-weight: bold;">{report.summary.complianceRate}</div>
        <div style="font-size: 0.85em; color: #666;">Compliance Rate</div>
      </div>
    </div>

    <!-- Compliance summary bar -->
    <div style="margin: 1em 0;">
      <div style="display: flex; gap: 1em; font-size: 0.9em;">
        <span style="color: #2d7d2d;">✓ Compliant: {report.summary.compliantCustomers}</span>
        <span style="color: #c0392b;">✗ Non-compliant: {report.summary.nonCompliantCustomers}</span>
      </div>
    </div>

    <hr />

    <!-- Customer detail -->
    <h3>Customer Detail</h3>

    {#each report.customers as customer}
      <div style="margin: 0.5em 0; border: 1px solid {customer.compliant ? '#b7e4b7' : '#f5c6cb'}; border-radius: 6px; overflow: hidden;">

        <!-- Customer header row — clickable -->
        <button
          onclick={() => toggleCustomer(customer.ehrId)}
          style="width: 100%; display: flex; justify-content: space-between; align-items: center; padding: 0.75em 1em; background: {customer.compliant ? '#e8fde8' : '#fde8e8'}; border: none; cursor: pointer; font-size: 0.95em; text-align: left;"
        >
          <span>
            <strong style="color: {customer.compliant ? '#2d7d2d' : '#c0392b'};">
              {customer.compliant ? '✓ COMPLIANT' : '✗ NON-COMPLIANT'}
            </strong>
            &nbsp;
            <code style="font-size: 0.8em; color: #555;">{customer.ehrId.substring(0, 8)}…</code>
          </span>
          <span style="font-size: 0.85em; color: #555;">
            Orders: {customer.orderCount} &nbsp;|&nbsp;
            Preps: {customer.prepCount} &nbsp;|&nbsp;
            Gap: <strong style="color: {customer.gap > 0 ? '#c0392b' : '#2d7d2d'};">{customer.gap}</strong>
            &nbsp; {expandedCustomer === customer.ehrId ? '▲' : '▼'}
          </span>
        </button>

        <!-- Expanded detail -->
        {#if expandedCustomer === customer.ehrId}
          <div style="padding: 0.75em 1em; background: #fff;">

            {#if customer.unmatched.length > 0}
              <h4 style="color: #c0392b; margin: 0.5em 0 0.3em;">Unmatched Orders (no preparation event)</h4>
              <table style="border-collapse: collapse; width: 100%; font-size: 0.85em;">
                <thead>
                  <tr style="border-bottom: 2px solid #ddd; text-align: left;">
                    <th style="padding: 0.3em 0.5em;">Time</th>
                    <th style="padding: 0.3em 0.5em;">Drink</th>
                    <th style="padding: 0.3em 0.5em;">Size</th>
                    <th style="padding: 0.3em 0.5em;">Price</th>
                    <th style="padding: 0.3em 0.5em;">Composition</th>
                  </tr>
                </thead>
                <tbody>
                  {#each customer.unmatched as order}
                    <tr style="border-bottom: 1px solid #eee; background: #fff5f5;">
                      <td style="padding: 0.3em 0.5em;">{formatTime(order.orderTime)}</td>
                      <td style="padding: 0.3em 0.5em;">{order.drinkName}</td>
                      <td style="padding: 0.3em 0.5em;">{order.drinkSize}</td>
                      <td style="padding: 0.3em 0.5em;">{order.price}</td>
                      <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.8em;">{shortUid(order.compositionUid)}…</code></td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            {/if}

            <h4 style="margin: 0.8em 0 0.3em;">All Orders</h4>
            <table style="border-collapse: collapse; width: 100%; font-size: 0.85em;">
              <thead>
                <tr style="border-bottom: 2px solid #ddd; text-align: left;">
                  <th style="padding: 0.3em 0.5em;">Time</th>
                  <th style="padding: 0.3em 0.5em;">Drink</th>
                  <th style="padding: 0.3em 0.5em;">Size</th>
                  <th style="padding: 0.3em 0.5em;">Milk</th>
                  <th style="padding: 0.3em 0.5em;">Price</th>
                  <th style="padding: 0.3em 0.5em;">Composition</th>
                </tr>
              </thead>
              <tbody>
                {#each customer.orders as order}
                  {@const isUnmatched = customer.unmatched.some(u => u.compositionUid === order.compositionUid)}
                  <tr style="border-bottom: 1px solid #eee; {isUnmatched ? 'background: #fff5f5;' : ''}">
                    <td style="padding: 0.3em 0.5em;">{formatTime(order.orderTime)}</td>
                    <td style="padding: 0.3em 0.5em;">{order.drinkName} {isUnmatched ? '⚠' : ''}</td>
                    <td style="padding: 0.3em 0.5em;">{order.drinkSize}</td>
                    <td style="padding: 0.3em 0.5em;">{order.milkChoice ?? '—'}</td>
                    <td style="padding: 0.3em 0.5em;">{order.price}</td>
                    <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.8em;">{shortUid(order.compositionUid)}…</code></td>
                  </tr>
                {/each}
              </tbody>
            </table>

            {#if customer.preparations.length > 0}
              <h4 style="margin: 0.8em 0 0.3em;">Preparation Events</h4>
              <table style="border-collapse: collapse; width: 100%; font-size: 0.85em;">
                <thead>
                  <tr style="border-bottom: 2px solid #ddd; text-align: left;">
                    <th style="padding: 0.3em 0.5em;">Time</th>
                    <th style="padding: 0.3em 0.5em;">Method</th>
                    <th style="padding: 0.3em 0.5em;">Barista</th>
                    <th style="padding: 0.3em 0.5em;">Composition</th>
                  </tr>
                </thead>
                <tbody>
                  {#each customer.preparations as prep}
                    <tr style="border-bottom: 1px solid #eee;">
                      <td style="padding: 0.3em 0.5em;">{formatTime(prep.prepTime)}</td>
                      <td style="padding: 0.3em 0.5em;">{prep.prepMethod ?? '—'}</td>
                      <td style="padding: 0.3em 0.5em;">{prep.baristaName ?? '—'}</td>
                      <td style="padding: 0.3em 0.5em;"><code style="font-size: 0.8em;">{shortUid(prep.compositionUid)}…</code></td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            {:else}
              <p style="color: #999; font-size: 0.85em; margin: 0.5em 0;">No preparation events recorded.</p>
            {/if}
          </div>
        {/if}
      </div>
    {/each}
  </div>
{/if}
