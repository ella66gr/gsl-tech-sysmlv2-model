<script lang="ts">
  import { Badge, Tooltip } from 'flowbite-svelte';
  import {
    ChevronDownOutline,
    ChevronRightOutline,
    CheckCircleOutline,
    ShieldCheckOutline,
    ClipboardListOutline,
  } from 'flowbite-svelte-icons';
  import type {
    GovernanceRequirementInstance,
    SatisfyChain,
    GovernanceConstraintDef,
    AuditEvidenceInstance,
  } from '$lib/types/governance';

  let { data } = $props();

  const gov = data.governance.governance;
  const domains = data.governance.domains;

  // --- Filter state ---
  let reqDefFilter = $state<string>('all');
  let domainFilter = $state<string>('all');

  // Distinct values for filter dropdowns
  const requirementDefTypes = $derived(
    [...new Set(gov.requirementInstances.map((r) => r.typedBy))].sort()
  );
  const instanceDomains = $derived(
    [...new Set(gov.requirementInstances.map((r) => r.sourceDomain))].sort()
  );

  // --- Computed views ---

  // Group satisfy chains by requirement instance, with filtering
  const requirementChains = $derived.by(() => {
    const filtered = gov.requirementInstances.filter((req) => {
      if (reqDefFilter !== 'all' && req.typedBy !== reqDefFilter) return false;
      if (domainFilter !== 'all' && req.sourceDomain !== domainFilter) return false;
      return true;
    });
    return filtered.map((req) => {
      // Find satisfy chains that reference this requirement's typedBy def
      // and are in the same domain
      const chains = gov.satisfyChains.filter(
        (s) => s.requirementDef === req.typedBy && s.sourceDomain === req.sourceDomain
      );

      // For each chain, find the constraint def
      const constraintsWithDefs = chains.map((chain) => {
        const constraintDef = gov.constraintDefs.find(
          (cd) => cd.name === chain.constraintDef
        );
        return { chain, constraintDef };
      });

      // Find audit evidence in the same domain
      const evidence = gov.auditEvidenceInstances.filter(
        (e) => e.sourceDomain === req.sourceDomain
      );

      return { requirement: req, constraints: constraintsWithDefs, evidence };
    });
  });

  // --- Expand/collapse state ---
  let expandedRequirement = $state<string | null>(
    gov.requirementInstances.length > 0 ? gov.requirementInstances[0].name : null
  );

  // --- Helper functions ---

  function domainLabel(domainKey: string): string {
    return domains[domainKey]?.label || domainKey;
  }

  function getAttrValue(
    attrs: Array<{ name: string; value?: string }>,
    attrName: string
  ): string {
    const attr = attrs.find((a) => a.name === attrName);
    return attr?.value || '';
  }

  function domainColor(domainKey: string): string {
    const colors: Record<string, string> = {
      core: 'blue',
      csw: 'yellow',
      suds: 'green',
      paws: 'purple',
    };
    return colors[domainKey] || 'gray';
  }
</script>

<div class="space-y-6">
  <!-- Page header -->
  <div>
    <h1 class="text-2xl font-bold text-secondary-900 dark:text-white">
      Governance Traceability
    </h1>
    <p class="mt-1 text-sm text-secondary-500 dark:text-secondary-400">
      Requirement → Constraint → Satisfy → Audit Evidence chains across domains.
    </p>
  </div>

  <!-- Summary stats -->
  <div class="grid grid-cols-2 gap-3 sm:grid-cols-5">
    <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="text-2xl font-bold text-secondary-900 dark:text-white">{gov.requirementDefs.length}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Requirement Defs</div>
    </div>
    <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="text-2xl font-bold text-secondary-900 dark:text-white">{gov.requirementInstances.length}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Requirement Instances</div>
    </div>
    <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="text-2xl font-bold text-secondary-900 dark:text-white">{gov.constraintDefs.length}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Constraint Defs</div>
    </div>
    <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="text-2xl font-bold text-secondary-900 dark:text-white">{gov.satisfyChains.length}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Satisfy Chains</div>
    </div>
    <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="text-2xl font-bold text-secondary-900 dark:text-white">{gov.auditEvidenceInstances.length}</div>
      <div class="text-xs text-secondary-500 dark:text-secondary-400">Evidence Records</div>
    </div>
  </div>

  <!-- Traceability chains -->
  <section>
    <h2 class="mb-3 text-lg font-semibold text-secondary-900 dark:text-white">
      Traceability Chains
    </h2>

    <!-- Filter controls -->
    <div class="flex flex-wrap items-center gap-3 rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
      <div class="flex items-center gap-2">
        <label for="reqDefFilter" class="text-xs font-medium text-secondary-500 dark:text-secondary-400">Type</label>
        <select
          id="reqDefFilter"
          bind:value={reqDefFilter}
          class="rounded-md border-secondary-300 bg-white py-1 pl-2 pr-7 text-sm text-secondary-700 dark:border-secondary-600 dark:bg-secondary-700 dark:text-secondary-200"
        >
          <option value="all">All types</option>
          {#each requirementDefTypes as t}
            <option value={t}>{t}</option>
          {/each}
        </select>
      </div>
      <div class="flex items-center gap-2">
        <label for="domainFilter" class="text-xs font-medium text-secondary-500 dark:text-secondary-400">Domain</label>
        <select
          id="domainFilter"
          bind:value={domainFilter}
          class="rounded-md border-secondary-300 bg-white py-1 pl-2 pr-7 text-sm text-secondary-700 dark:border-secondary-600 dark:bg-secondary-700 dark:text-secondary-200"
        >
          <option value="all">All domains</option>
          {#each instanceDomains as d}
            <option value={d}>{domainLabel(d)}</option>
          {/each}
        </select>
      </div>
      <span class="text-xs text-secondary-400">
        {requirementChains.length} of {gov.requirementInstances.length} requirement{gov.requirementInstances.length !== 1 ? 's' : ''}
      </span>
      {#if reqDefFilter !== 'all' || domainFilter !== 'all'}
        <button
          class="text-xs text-primary-600 hover:underline dark:text-primary-400"
          onclick={() => { reqDefFilter = 'all'; domainFilter = 'all'; }}
        >
          Clear filters
        </button>
      {/if}
    </div>

    {#if requirementChains.length === 0}
      <p class="text-sm text-secondary-500 dark:text-secondary-400">
        No requirements match the current filters.
      </p>
    {:else}
      <div class="space-y-4">
        {#each requirementChains as { requirement, constraints, evidence }}
          {@const isExpanded = expandedRequirement === requirement.name}
          {@const reqTitle = getAttrValue(requirement.attributes, 'title') || requirement.name}
          {@const reqId = getAttrValue(requirement.attributes, 'requirementId')}
          {@const reqSource = getAttrValue(requirement.attributes, 'regulatorySource')}

          <!-- Requirement card -->
          <div class="rounded-lg border border-secondary-200 bg-white dark:border-secondary-700 dark:bg-secondary-800">
            <!-- Requirement header (clickable) -->
            <button
              class="flex w-full items-start gap-3 p-4 text-left"
              onclick={() => expandedRequirement = isExpanded ? null : requirement.name}
            >
              <div class="mt-0.5 flex-shrink-0">
                {#if isExpanded}
                  <ChevronDownOutline class="h-5 w-5 text-secondary-400" />
                {:else}
                  <ChevronRightOutline class="h-5 w-5 text-secondary-400" />
                {/if}
              </div>
              <div class="min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-2">
                  <ShieldCheckOutline class="h-5 w-5 flex-shrink-0 text-red-500 dark:text-red-400" />
                  <span class="font-semibold text-secondary-900 dark:text-white">{reqTitle}</span>
                  {#if reqId}
                    <Badge color="none" class="text-xs bg-secondary-200 text-secondary-700 dark:bg-secondary-600 dark:text-secondary-200">{reqId}</Badge>
                  {/if}
                  <Badge color={domainColor(requirement.sourceDomain)}>{domainLabel(requirement.sourceDomain)}</Badge>
                </div>
                {#if reqSource}
                  <p class="mt-1 text-xs text-secondary-500 dark:text-secondary-400">{reqSource}</p>
                {/if}
              </div>
              <div class="flex-shrink-0 text-right">
                <div class="text-xs text-secondary-400">
                  {constraints.length} constraint{constraints.length !== 1 ? 's' : ''} · {evidence.length} evidence record{evidence.length !== 1 ? 's' : ''}
                </div>
              </div>
            </button>

            <!-- Expanded content: traceability chain -->
            {#if isExpanded}
              <div class="border-t border-secondary-200 px-4 pb-4 dark:border-secondary-700">

                <!-- Requirement details -->
                <div class="mt-3">
                  <div class="text-xs font-semibold uppercase tracking-wider text-secondary-400">
                    Compliance Description
                  </div>
                  <p class="mt-1 text-sm text-secondary-700 dark:text-secondary-300">
                    {getAttrValue(requirement.attributes, 'complianceDescription')}
                  </p>
                </div>

                <div class="mt-3">
                  <div class="text-xs font-semibold uppercase tracking-wider text-secondary-400">
                    Evidence Required
                  </div>
                  <p class="mt-1 text-sm text-secondary-700 dark:text-secondary-300">
                    {getAttrValue(requirement.attributes, 'evidenceRequired')}
                  </p>
                </div>

                <!-- Vertical connector -->
                <div class="ml-6 mt-4 border-l-2 border-secondary-300 pl-6 dark:border-secondary-600">

                  <!-- Constraint cards -->
                  <div class="text-xs font-semibold uppercase tracking-wider text-secondary-400">
                    Constraints (satisfy)
                  </div>
                  <div class="mt-2 space-y-2">
                    {#each constraints as { chain, constraintDef }}
                      <div class="rounded-md border border-blue-200 bg-blue-50 p-3 dark:border-blue-800 dark:bg-blue-900/20">
                        <div class="flex items-center gap-2">
                          <CheckCircleOutline class="h-4 w-4 flex-shrink-0 text-blue-600 dark:text-blue-400" />
                          <span class="text-sm font-medium text-blue-900 dark:text-blue-200">
                            {chain.constraintDef}
                          </span>
                          <span class="text-xs text-blue-600 dark:text-blue-400">
                            via {chain.constraintUsage}
                          </span>
                        </div>
                        {#if constraintDef?.doc}
                          <p class="mt-1 ml-6 text-xs text-blue-700 dark:text-blue-300">
                            {constraintDef.doc}
                          </p>
                        {/if}
                      </div>
                    {/each}
                  </div>

                  <!-- Evidence records -->
                  <div class="mt-4 text-xs font-semibold uppercase tracking-wider text-secondary-400">
                    Audit Evidence Records
                  </div>
                  <div class="mt-2 space-y-2">
                    {#each evidence as record}
                      {@const evidenceType = getAttrValue(record.attributes, 'evidenceType')}
                      {@const evidenceDesc = getAttrValue(record.attributes, 'evidenceDescription')}
                      {@const retention = getAttrValue(record.attributes, 'retentionPeriod')}
                      {@const role = getAttrValue(record.attributes, 'responsibleRole')}
                      {@const frequency = getAttrValue(record.attributes, 'frequency')}

                      <div class="rounded-md border border-green-200 bg-green-50 p-3 dark:border-green-800 dark:bg-green-900/20">
                        <div class="flex items-center gap-2">
                          <ClipboardListOutline class="h-4 w-4 flex-shrink-0 text-green-600 dark:text-green-400" />
                          <span class="text-sm font-medium text-green-900 dark:text-green-200">
                            {record.name}
                          </span>
                          {#if evidenceType}
                            <Badge color="green" class="text-xs">{evidenceType}</Badge>
                          {/if}
                        </div>
                        {#if evidenceDesc}
                          <p class="mt-1 ml-6 text-xs text-green-700 dark:text-green-300">
                            {evidenceDesc}
                          </p>
                        {/if}
                        <div class="mt-2 ml-6 flex flex-wrap gap-x-4 gap-y-1 text-xs text-green-600 dark:text-green-400">
                          {#if frequency}
                            <span><span class="font-medium">Frequency:</span> {frequency}</span>
                          {/if}
                          {#if role}
                            <span><span class="font-medium">Responsible:</span> {role}</span>
                          {/if}
                          {#if retention}
                            <span><span class="font-medium">Retention:</span> {retention}</span>
                          {/if}
                        </div>
                      </div>
                    {/each}
                  </div>

                </div>
              </div>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </section>

  <!-- Evidence Records Table -->
  <section>
    <h2 class="mb-3 text-lg font-semibold text-secondary-900 dark:text-white">
      All Evidence Records
    </h2>

    {#if gov.auditEvidenceInstances.filter((e) => domainFilter === 'all' || e.sourceDomain === domainFilter).length === 0}
      <p class="text-sm text-secondary-500 dark:text-secondary-400">
        No audit evidence records found.
      </p>
    {:else}
      <div class="overflow-x-auto rounded-lg border border-secondary-200 dark:border-secondary-700">
        <table class="w-full text-left text-sm text-secondary-700 dark:text-secondary-300">
          <thead class="bg-secondary-50 text-xs uppercase text-secondary-600 dark:bg-secondary-800 dark:text-secondary-400">
            <tr>
              <th class="px-4 py-2">Record</th>
              <th class="px-4 py-2">Type</th>
              <th class="px-4 py-2">Frequency</th>
              <th class="px-4 py-2">Responsible</th>
              <th class="px-4 py-2">Retention</th>
              <th class="px-4 py-2">Domain</th>
            </tr>
          </thead>
          <tbody>
            {#each gov.auditEvidenceInstances.filter((e) => domainFilter === 'all' || e.sourceDomain === domainFilter) as record}
              <tr class="border-t border-secondary-200 dark:border-secondary-700">
                <td class="px-4 py-2 font-medium text-secondary-900 dark:text-white">
                  {record.name}
                </td>
                <td class="px-4 py-2">{getAttrValue(record.attributes, 'evidenceType')}</td>
                <td class="px-4 py-2">{getAttrValue(record.attributes, 'frequency')}</td>
                <td class="px-4 py-2">{getAttrValue(record.attributes, 'responsibleRole')}</td>
                <td class="px-4 py-2">{getAttrValue(record.attributes, 'retentionPeriod')}</td>
                <td class="px-4 py-2">
                  <Badge color={domainColor(record.sourceDomain)}>{domainLabel(record.sourceDomain)}</Badge>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </section>

  <!-- Constraint Definitions -->
  <section>
    <h2 class="mb-3 text-lg font-semibold text-secondary-900 dark:text-white">
      Constraint Definitions
    </h2>
    <p class="mb-3 text-xs text-secondary-500 dark:text-secondary-400">
      Domain-specific testable conditions. Showing constraints from demonstrator domains only.
    </p>

    {#if gov.constraintDefs.filter((cd) => cd.sourceDomain !== 'core' && (domainFilter === 'all' || cd.sourceDomain === domainFilter)).length === 0}
      <p class="text-sm text-secondary-500 dark:text-secondary-400">
        No domain-specific constraint definitions found.
      </p>
    {:else}
      <div class="space-y-2">
        {#each gov.constraintDefs.filter((cd) => cd.sourceDomain !== 'core' && (domainFilter === 'all' || cd.sourceDomain === domainFilter)) as cdef}
          <div class="rounded-lg border border-secondary-200 bg-white p-3 dark:border-secondary-700 dark:bg-secondary-800">
            <div class="flex items-center gap-2">
              <span class="font-mono text-sm font-medium text-secondary-900 dark:text-white">{cdef.name}</span>
              <Badge color={domainColor(cdef.sourceDomain)}>{domainLabel(cdef.sourceDomain)}</Badge>
              <span class="text-xs text-secondary-400">{cdef.package}</span>
            </div>
            {#if cdef.doc}
              <p class="mt-1 text-xs text-secondary-600 dark:text-secondary-400">{cdef.doc}</p>
            {/if}
            {#if cdef.attributes.length > 0}
              <div class="mt-2 flex flex-wrap gap-2">
                {#each cdef.attributes as attr}
                  <span class="rounded bg-secondary-100 px-2 py-0.5 text-xs font-mono text-secondary-600 dark:bg-secondary-700 dark:text-secondary-300">
                    in {attr.name} : {attr.type || '?'}
                  </span>
                {/each}
              </div>
            {/if}
          </div>
        {/each}
      </div>
    {/if}
  </section>

  <!-- Footer -->
  <div class="border-t border-secondary-200 pt-3 text-xs text-secondary-400 dark:border-secondary-700">
    Generated {data.governance.generatedAt ? new Date(data.governance.generatedAt).toLocaleString() : 'unknown'}
  </div>
</div>
