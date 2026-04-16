---
tags:
  - preparation-note
date: 2026-04-16
status: current
session: 225
---

# Session 225 — Preparation Note

> `= this.file.path`

**Prepared at close of:** Session 224 (16 April 2026)

---

## Where we are

Session 224 completed Part 1 of [[ontara-ref-work-item-tracker|W-061]] (eighth systematic documentation review) — Tier 1 reference documents fully reviewed, 37 findings captured in the [[session-224-findings|Part 1 findings document]]. No documents edited this session — scan-only discipline adopted to produce a clean findings record.

The principal finding is a **downstream currency gap** from the S208–S218 foundations refresh: six reference documents still cite [[ontara-architecture (pms) platform-modelling-strategy|PMS v4.1]] / [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v3.1]] / [[ontara-workflow-guide|workflow guide v2]] / stale register counts. The secondary finding is a **frontmatter-drift pattern** where three reference documents have YAML `session:` values lagging the DCR.

Ella's standing instruction: **no production work contemplated until the reference corpus is fully trustworthy.** All other substantive workstreams ([[ontara-ref-work-item-tracker|W-053]] DPA, W-045 Campus Walk II, W-060 concept graph currency, W-067 new concept-graph notes) remain deferred.

---

## Priority for S225

**Priority A: W-061 Part 2 — complete the review.**

**Tier 2 — Foundations papers spot-check:**
- [[ontara-architecture-platform-principles|Architecture Principles v5]] (S211)
- [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]] (S216)
- [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]] (S218)

For each: verify self-version references, cross-references to the other two foundations papers, register-count claims, TLA compliance.

**Tier 3 — Cross-cutting vault-wide sweep:**
- Mechanical grep for `v4.1` and `v3.1` outside explicit history references
- Stale register counts (`~212`, `~214`, `~222`) outside Register History
- `Workflow Guide (v2)` outside explicit history references
- `six-layer architecture` where `stratified two-side architecture` is current
- Bare `BS`, `BR`, `SR`, `BM`, `SM` where TLA (DKG, DBR, DSR, DBM, DSM) now applies — noting these also feed the TLA migration W-062/63/64

**Deliverable:** [[session-225-findings-w-061-part-2|Part 2 findings document]] that complements Part 1 and closes W-061.

---

## After S225

- **S226 (likely a Claude Code session)** — execute [[ontara-ref-work-item-tracker|W-068]] (currency propagation fix batch) and [[ontara-ref-work-item-tracker|W-069]] (frontmatter sweep) as batch edits driven by the consolidated findings document. Code is the right tool for multi-file mechanical edits.
- **S227+** — remaining Priority B items from findings (W-070 to W-075), workflow guide amendments, then resume [[ontara-ref (v&a) vision-architecture|V&A Reference]] refresh (W-059) with the findings informing its scope.

---

## Documents to read at open

- This preparation note
- [[session-224-findings|W-061 Part 1 findings document]] — the principal carry-forward
- [[ontara-ref-strategic-snapshot|Strategic snapshot]] — Tier 1 quick reference
- [[ontara-ref-work-item-tracker|Work item tracker]] — updated at S224 C2 with new W-items and OW items
- [[ontara-ref-master-register|Master register]] — Tier 1
- Three foundations papers are the subjects of Tier 2 review ([[ontara-architecture-platform-principles|Architecture Principles v5]], [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]], [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]])

---

## Key context

- **Scan-only discipline continues into S225.** No edits during the review. Findings cumulative across Parts 1 and 2.
- **Findings document numbering.** Part 2 continues F-numbering from F38 onwards to give a single continuous set across the review.
- **Tooling preference for Tier 3.** Cross-cutting grep sweeps should use `bash_tool` with `python3` against stored vault content rather than repeated filesystem reads — more efficient and produces an auditable list.
- **Decision held open.** The "body-text currency claims — remove or enforce" decision (cross-cutting observation 4.5 in Part 1) is deferred to a workflow guide amendment session after Part 2.

---

## Governance actions at close of S224

- [[ontara-ref-work-item-tracker|W-061]] status: `open` → `in-progress`.
- Nine new W-items added to tracker (W-068 through W-076).
- Four new OW items added to tracker (OW-224-1 through OW-224-4).
- Four EIL entries archived (E031, E034, E035, E036); E037 status updated with W-075 reconciliation note.
- W-060 and W-067 remain deferred (not reopened in any sense; the deferral is recorded).
- DCR unchanged — the review produced findings against the DCR targets but did not refresh anything.

---

*Preparation note for Session 225, produced at S224 close.*
