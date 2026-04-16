---
abbreviation: S224 findings part 1
date: 2026-04-16
session: 224
status: current
tags:
- findings
- governance
- review
version: v1
---

# W-061 Eighth Systematic Documentation Review — Findings (Part 1: Tier 1 Reference Documents)
> `= this.file.path`

**Session:** 224
**Date:** 16 April 2026
**Workstream:** W-061 (eighth systematic documentation review)
**Status:** Part 1 of 2 — Tier 1 (reference documents) complete; Tier 2 (foundations papers spot-check) and Tier 3 (cross-cutting sweep) deferred to Session 225.

---

## Contents

- [[#1. Summary|§1. Summary]]
- [[#2. Methodology|§2. Methodology]]
- [[#3. Findings by Document|§3. Findings by Document]]
- [[#4. Cross-Cutting Observations|§4. Cross-Cutting Observations]]
- [[#5. Proposed W-Items|§5. Proposed W-Items]]
- [[#6. Next Steps|§6. Next Steps]]

---

## 1. Summary

### 1.1 Scope of this findings document

Part 1 covers Tier 1 — the reference documents in `01 —— START HERE ——` and related locations that are the authoritative orientation documents for the project. Every finding here concerns documents that Claude reads at session open (O1) or that are meant to be an authoritative single source.

Tier 2 (foundations papers spot-check: [[ontara-architecture-platform-principles|Architecture Principles v5]], [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]], [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]]) and Tier 3 (vault-wide sweep for stale cross-references) are deferred to Session 225.

### 1.2 Findings counts

| Category | Count | Meaning |
|---|---|---|
| Fix-now | 16 | Surgical corrections; batched for fix session |
| Schedule-fix | 5 | Require a scheduled work item |
| Inconsistency | 3 | Frontmatter/body mismatch; systematic |
| Note-for-awareness | 8 | OW-items; no direct fix |
| No-action | 5 | Checked and current |
| **Total** | **37** | |

### 1.3 Principal finding

**The S208 foundations refresh ([[ontara-architecture-platform-principles|Architecture Principles v5]], [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]] at S216, [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]] at S218) has not propagated downstream to reference documents.** The [[—— ARCHITECTURE INDEX ——|Architecture Papers Index]], [[ontara-ref-strategic-snapshot|Strategic Snapshot]], [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], [[ontara-guide-claude-tooling|Claude Tooling Guide]], [[ontara-ref (v&a) vision-architecture|V&A Reference]], and [[ontara-non-technical-overview|Non-Technical Overview]] all still cite "PMS v4.1", "SBMM v3.1", "workflow guide v2", or stale register counts ("~212 concepts", "~222 concepts") in multiple places. This is not a single document error — it is a **systemic downstream-currency gap** that the [[ontara-workflow-guide|workflow guide]] does not currently guard against.

### 1.4 Secondary finding

**Reference document frontmatter drifts out of sync with body headers when documents are edited without frontmatter bumps.** Three documents exhibit this pattern ([[ontara-ref-strategic-snapshot|Strategic Snapshot]], [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], [[ontara-workflow (eil) emergent-ideas-log|EIL]]). The [[ontara-ref-shell-commands|Shell Command Reference]] shows the inverse (body text older than frontmatter). The DCR is correct in each case; the document internals are not.

---

## 2. Methodology

### 2.1 Documents reviewed (Tier 1)

1. [[—— ARCHITECTURE INDEX ——|Architecture Papers Index]] — last refreshed S213
2. [[ontara-ref-strategic-snapshot|Strategic Snapshot]] — DCR says S222
3. [[ontara-ref-master-register|Master Register]] — last refreshed S223
4. [[ontara-ref (v&a) vision-architecture|V&A Reference]] — v12, S201
5. [[—— RESEARCH & BACKGROUND INDEX (RBI) ——|Research & Background Index]] — S213
6. [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]] — DCR says S222
7. [[ontara-guide-claude-tooling|Claude Tooling Guide]] — S213
8. [[ontara-ref-shell-commands|Shell Command Reference]] — v2, S137
9. [[ontara-workflow (eil) emergent-ideas-log|EIL]] — DCR says S222
10. [[ontara-non-technical-overview|Non-Technical Overview]] — S129
11. [[ontara-workflow-guide|Workflow Guide]] — v3, S220
12. [[ontara-ref-work-item-tracker|Work Item Tracker]] — S223

### 2.2 Review method

Scan-only discipline. No document was edited during the review. Findings recorded with category tags (`fix-now`, `schedule-fix`, `inconsistency`, `note-for-awareness`, `no-action`) and consolidated here.

### 2.3 Category definitions

- **Fix-now** — a surgical correction (wrong version number, stale count, broken reference). Grouped for a batch fix session.
- **Schedule-fix** — requires a scheduled work item (rewrite, trim, structural change).
- **Inconsistency** — frontmatter/body/DCR mismatch that needs a policy decision, not just a text fix.
- **Note-for-awareness** — observation or testable prediction; becomes an OW-item.
- **No-action** — document checked, current, no issues.

### 2.4 Out of scope for Part 1

- [[ontara-ref (v&a) vision-architecture|V&A Reference]] content was scanned but not itemised line-by-line. V&A is known-stale and tracked as [[ontara-ref-work-item-tracker|W-059]]; F16 records it as a meta-finding rather than enumerating every instance.
- [[ontara-ref-master-register|Master register]] content accuracy was not line-by-line audited; the T1 quick reference and tier counts were spot-checked.
- [[ontara-ref-work-item-tracker|Work item tracker]] was the source authority for cross-document currency; not itself reviewed critically (would be circular).

---

## 3. Findings by Document

### 3.1 Architecture Papers Index — last refreshed S213

File: [[—— ARCHITECTURE INDEX ——|—— ARCHITECTURE INDEX ——.md]]

| # | Category | Finding |
|---|---|---|
| F1 | fix-now | L82: `Development Workflow Guide (v2)` — workflow guide is now v3 (S220). |
| F2 | fix-now | L81: `~212 concepts across 16 sections (A–P)` — register is now ~232 concepts after S223 W-043 additions. |
| F3 | fix-now | L50: `SysML Modelling Strategy (v4.1, Session 170)` — PMS is now v5 (S216) per DCR. Foundational section cites superseded version. |
| F4 | fix-now | L57: `Service Business Meta Modelling (v3.1, Session 170)` — SBMM is now v4 (S218). Same currency regression. |
| F5 | fix-now | L145: Reasoning Metamodel entry says "seven candidate register concepts (B40–B46)". Register has B40 as four-level distinction (S207); B40–B46 numbers are now reassigned. Rephrase to avoid implying those specific register codes. |
| F6 | schedule-fix | L184: History section is extremely long and exceeds workflow guide §1.8 discipline. Should be trimmed at next refresh. |

### 3.2 Strategic Snapshot — DCR says S222

File: [[ontara-ref-strategic-snapshot|ontara-ref-strategic-snapshot.md]]

| # | Category | Finding |
|---|---|---|
| F7 | inconsistency | Frontmatter `session: 208, date: 2026-04-16`; body says "Last updated: 16 April 2026 (Session 208 — major trim)"; DCR records last refresh as S222. S222 session report confirms a trim pass. Frontmatter and body text should be bumped to S222. |
| F8 | note-for-awareness | §4.2 active workstreams table lists W-043 as "Partial" and W-049 as "Architecture Principles v5 complete S211" with PMS/SBMM "remain". Both are now complete. Prep note flagged this will be picked up at next refresh. |
| F9 | fix-now | §4.3 "Governance currency (as of S208)" table is very stale and contradicts the DCR in the tracker. Recommend delete — DCR is the authority per workflow guide §7.5. |
| F10 | fix-now | §3.7 says "Master register entries ~222 concepts across 16 sections (A–P)". Register is now ~232. Discussion papers count 42 — verify against architecture folder. |
| F11 | fix-now | §5 Foundations table cites SysML Modelling Strategy v4.1 and SBMM v3.1. Should be PMS v5 / SBMM v4. |
| F12 | no-action | §5 Development Workflow Guide says "(v3)" — correct. |

### 3.3 Master Register — last refreshed S223

File: [[ontara-ref-master-register|ontara-ref-master-register.md]]

| # | Category | Finding |
|---|---|---|
| F13 | fix-now | Tier structure table says "Tier 3 ~102". Not verified this session. Low priority — count is approximate. |
| F14 | no-action | Tier 1 Quick Reference includes 12 principles matching workflow guide; correct. |
| F15 | note-for-awareness | Section B is very dense. B45 (substrate), B46 (binding), B50 (bounded agent) are all load-bearing for Stage 9 — when next reviewing tier counts, check whether any should be promoted to T1. Design question, not a fix. |

### 3.4 V&A Reference — v12, S201 (tracked W-059)

File: [[ontara-ref (v&a) vision-architecture|ontara-ref (v&a) vision-architecture.md]]

| # | Category | Finding |
|---|---|---|
| F16 | meta | V&A is pre-v5 across the board: references [[ontara-architecture (pms) platform-modelling-strategy|PMS v4.1]] (4 instances), [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v3.1]] (4 instances), ~212 concepts (2 instances), [[ontara-workflow-guide|workflow guide v2]] (1 instance), "six-layer architecture" (not stratified two-side), BS/BR terminology (not TLA DKG/DBR/DSR). No A4 strengthening, no formalism boundary, no SRS/PRS strata names. All consistent with v12 being pre-S208 content. **[[ontara-ref-work-item-tracker|W-059]] already tracked.** Scope of W-059 should explicitly include TLA migration ([[ontara-ref-work-item-tracker|W-062]]/63/64) in the same rewrite to avoid a double pass. |
| F17 | no-action | Contents index uses correct Obsidian-native piped format. |
| F18 | schedule-fix | §15 (Stage 9 Architectural Foundation) was added at S201 but predates the S208 strengthening of A4, the SR/PRS rename, and the S216/S218 foundations papers — so §15 is itself partially stale. Note for W-059 scope. |

### 3.5 Research & Background Index — S213

File: [[—— RESEARCH & BACKGROUND INDEX (RBI) ——|—— RESEARCH & BACKGROUND INDEX (RBI) ——.md]]

| # | Category | Finding |
|---|---|---|
| F19 | no-action | Simple index of research notes; no stale cross-references found. Currency check at S213 (OW-212-3) was appropriate. |

### 3.6 Modelling Paradigm Reference — DCR says S222

File: [[ontara-ref-modelling-paradigms|ontara-ref-modelling-paradigms.md]]

| # | Category | Finding |
|---|---|---|
| F20 | inconsistency | Frontmatter `session: 208, date: 2026-04-16`; body "Last updated: 16 April 2026 (Session 208 — trim)"; DCR records S222. Same pattern as Strategic Snapshot. Frontmatter and body header should be bumped to S222. |
| F21 | fix-now | L93: `SysML Modelling Strategy (v4.1)` — should be (v5). |
| F22 | no-action | Otherwise content is stable and well-scoped. |

### 3.7 Claude Tooling Guide — S213

File: [[ontara-guide-claude-tooling|ontara-guide-claude-tooling.md]]

| # | Category | Finding |
|---|---|---|
| F23 | fix-now | L221: `Workflow guide (v2)` — should be (v3). |
| F24 | note-for-awareness | L248: final paragraph is a history log exceeding workflow guide §1.8 discipline. Consistent with F6 — reference documents still carry legacy history footers. Meta-pattern across multiple documents. |
| F25 | no-action | Otherwise current and tight. Currency check at S213 was thorough. |

### 3.8 Shell Command Reference — v2, S137

File: [[ontara-ref-shell-commands|ontara-ref-shell-commands.md]]

| # | Category | Finding |
|---|---|---|
| F26 | inconsistency | Frontmatter `session: 137, date: 2026-04-03`; body "Last refreshed: Session 124 (3 April 2026)". Frontmatter correct (matches DCR S137); body text should be updated to match. |
| F27 | no-action | Content is "as needed" per DCR (no threshold). No operational findings. |

### 3.9 EIL — DCR says S222

File: [[ontara-workflow (eil) emergent-ideas-log|ontara-workflow (eil) emergent-ideas-log.md]]

| # | Category | Finding |
|---|---|---|
| F28 | inconsistency | Frontmatter `session: 208` but S222 split operation (EIL archive created) is reflected in DCR. Frontmatter should be bumped to S222. |
| F29 | no-action | Live EIL retains E024, E026, E031–E037; all entries have defined status; well-managed. |
| F30 | schedule-fix | E024 and E026 both still "Captured. Not yet routed." from S147 and S151 (~73–77 sessions old). C5 EIL review protocol in place but these have persisted. Route or retire. |
| F31 | note-for-awareness | E037 TLA table shows `OW → OWR` conversion. Tracker has no W-item for this. Either OW → OWR has been dropped or a W-item is missing. |
| F32 | note-for-awareness | E037 TLA table shows `SBMM → PMM` (Platform Meta Modelling). SBMM v4 was produced at S218 with the SBMM name retained. Either dropped or pending. No W-item. |

### 3.10 Non-Technical Overview — S129

File: [[ontara-non-technical-overview|ontara-non-technical-overview.md]]

| # | Category | Finding |
|---|---|---|
| F33 | schedule-fix | Last updated S129 — 95 sessions past. Not listed in DCR. Recommend adding to DCR at ~20-session threshold. |
| F34 | content-check | Numbers partially stale (see F35); conceptual currency lags the Stage 9 foundation work (see F36). |
| F35 | fix-now | "Ontology stack of nine files" — should be 13 files per snapshot §3.6. |
| F36 | note-for-awareness | Does not mention stratified two-side architecture, SRS/PRS strata, BR/substrate/bindings, surface families, user bands, bounded agents, four-level distinction. Reasonable for non-specialist audience, but the "Where it stands" section says "early stage of its full ambition" which understates the current platform. Review at next refresh. |
| F37 | no-action | Ontara Console / ontology foundation framing consistent with register. |

### 3.11 Workflow Guide — v3, S220

File: [[ontara-workflow-guide|ontara-workflow-guide.md]]

Scanned as part of O1; no findings requiring correction. The v3 restructure itself is the current state of the art; any regression would be a finding against it.

### 3.12 Work Item Tracker — S223

File: [[ontara-ref-work-item-tracker|ontara-ref-work-item-tracker.md]]

Used as source authority for this review. Self-review deferred (would be circular) — will be examined at Tier 3 cross-cutting pass for consistency of entries against found documentation.

---

## 4. Cross-Cutting Observations

### 4.1 The downstream currency gap

The principal systemic issue (see §1.3). When a foundations paper is refreshed ([[ontara-architecture-platform-principles|Architecture Principles v5]] S211, [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]] S216, [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]] S218), downstream documents are not currently required to propagate the version bump. The [[ontara-workflow-guide|workflow guide]] §7.1 "Downstream concept note check" addresses concept graph notes but not reference documents. This is why the [[—— ARCHITECTURE INDEX ——|Architecture Index]], [[ontara-ref-strategic-snapshot|Strategic Snapshot]], [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], [[ontara-guide-claude-tooling|Claude Tooling Guide]], [[ontara-ref (v&a) vision-architecture|V&A]], and [[ontara-non-technical-overview|Non-Technical Overview]] all cite v4.1/v3.1 concurrently.

**Recommendation:** Add to the [[ontara-workflow-guide|workflow guide]] §7.1 or §7.5 a **downstream reference-document propagation rule**: when any foundations paper is refreshed, the tracker must record an explicit propagation W-item that identifies the reference documents citing the old version, and that W-item must be at Priority A with a short session-count horizon (e.g. within 3 sessions).

### 4.2 The frontmatter-drift pattern

Three reference documents ([[ontara-ref-strategic-snapshot|Strategic Snapshot]], [[ontara-ref-modelling-paradigms|Modelling Paradigm Reference]], [[ontara-workflow (eil) emergent-ideas-log|EIL]]) have frontmatter that lags the DCR. The cause is identifiable: when a document is edited for a size-discipline trim (S222) without a version bump in the YAML, the frontmatter records the previous substantive edit (S208) while the DCR correctly records the trim pass (S222). The [[ontara-ref-shell-commands|Shell Command Reference]] shows the inverse: frontmatter ahead of body.

**Recommendation:** [[ontara-workflow-guide|Workflow guide]] §5.1 already requires YAML frontmatter on all vault documents. Add a rule that any `edit_file` or `write_file` operation on a reference document must bump `session:` and `date:` in the frontmatter. This is a §2.3 C3 obligation.

### 4.3 History footer bloat

F6 ([[—— ARCHITECTURE INDEX ——|Architecture Index]]), F24 ([[ontara-guide-claude-tooling|Claude Tooling Guide]]) both identify long history footer paragraphs that exceed §1.8 discipline. The [[ontara-workflow-guide|workflow guide]] v3 S220 restructure removed these from the guide itself and from the register, but the pattern remains in other reference documents.

**Recommendation:** Schedule a "history footer sweep" W-item — identify all reference documents with long history footers and remove per §1.8. Most can be reduced to a single line naming the last major change, with git history carrying the detail.

### 4.4 The TLA migration has untracked items

F31 (OW → OWR) and F32 (SBMM → PMM) are conversions identified in EIL E037 but not reflected in the tracker's [[ontara-ref-work-item-tracker|W-062]]/63/64. Either these conversions were dropped from the migration scope (in which case E037 should be amended to record the decision) or they are missing W-items.

**Recommendation:** Reconcile the E037 conversion table with the tracker. Record any scope changes in a short note. If OW → OWR and SBMM → PMM are still on the table, raise W-items.

### 4.5 Frontmatter vs body vs DCR triangulation

The DCR is the single source of truth for document currency per [[ontara-workflow-guide|workflow guide]] §7.1. But the frontmatter and body "Last updated" statements are the documents' self-claims about currency. When these three diverge, Claude at session O1 is liable to read the document's self-claim rather than the DCR, leading to subtle misreads about what the document contains.

**Recommendation:** Either (a) remove the body-text "Last updated" headers from reference documents (DCR is authority; frontmatter is the document's own record; body-text is redundant), or (b) enforce them all to move together. Option (a) is cleaner; it moves currency-claim to a single point-of-truth (the DCR in the [[ontara-ref-work-item-tracker|tracker]]).

---

## 5. Proposed W-Items

These replace individual fix-now findings where the findings cluster naturally.

| Proposed W# | Priority | Summary | Source findings |
|---|---|---|---|
| W-068 | A | Reference-document currency propagation (fix batch): version bumps for PMS v5, SBMM v4, workflow guide v3, and register count refresh across Architecture Index, Strategic Snapshot §4.3/§3.7/§5, Modelling Paradigm Reference, Claude Tooling Guide | F1, F2, F3, F4, F9, F10, F11, F21, F23, F35 |
| W-069 | A | Frontmatter reconciliation sweep: bump frontmatter `session:` and `date:` on Strategic Snapshot, Modelling Paradigm Reference, EIL (all to S222 where that was the actual edit session); reconcile Shell Command Reference body text with frontmatter | F7, F20, F26, F28 |
| W-070 | B | Strategic Snapshot §4.3 governance currency table: delete (redundant with DCR in tracker) or refresh as part of next snapshot refresh (~S232) | F9 |
| W-071 | B | Non-Technical Overview refresh: add to DCR; update number of ontology stack files; add a "Where it stands" paragraph acknowledging Stage 8 portal complete and Stage 9 design foundation in place | F33, F34, F35, F36 |
| W-072 | B | Workflow guide amendment: add downstream reference-document propagation rule triggered by foundations-paper refresh (see §4.1 recommendation) | Meta — from cross-cutting observation 4.1 |
| W-073 | B | Workflow guide amendment: require YAML frontmatter bump on every reference-document edit (see §4.2 recommendation) | Meta — from cross-cutting observation 4.2 |
| W-074 | C | History footer sweep across reference documents (see §4.3 recommendation) | F6, F24 |
| W-075 | B | TLA migration reconciliation: reconcile EIL E037 conversion table against tracker W-062/63/64. Clarify status of OW → OWR and SBMM → PMM | F31, F32 |
| W-076 | C | EIL stale entries: route or retire E024 (S147) and E026 (S151) | F30 |
| W-077 | C | Architecture Papers Index: refresh to v5/v4 references, correct register count, rephrase reasoning-metamodel entry to avoid implying B40–B46 register codes, trim history footer (absorbs F1, F2, F3, F4, F5, F6) | Covered by W-068 and W-074; retain as the consolidated document-level work item if batch approach not adopted |

### Observation and Watchpoint register additions

| Proposed OW# | Watchpoint | Action |
|---|---|---|
| OW-224-1 | V&A Reference §15 (Stage 9 foundation) predates S208 A4 strengthening and S216/S218 foundations papers; partially stale within an otherwise-pre-v5 document. | W-059 scope must include §15 rewrite, not only v5-era content insertion. |
| OW-224-2 | Section B registry is dense post-S223 (B45–B53); B45, B46, B50 are load-bearing for Stage 9 and may warrant T1 promotion. | Review at next register governance pass. |
| OW-224-3 | Reference-document frontmatter drifts when trim or minor edits happen without frontmatter bump. | Codify in workflow guide (W-073). |
| OW-224-4 | Downstream currency propagation is not currently a workflow guide obligation; foundations refreshes leave reference documents citing stale versions. | Codify in workflow guide (W-072). |

---

## 6. Next Steps

### 6.1 Session 225 scope — W-061 Part 2

- **Tier 2:** Foundations papers spot-check. Each of [[ontara-architecture-platform-principles|Architecture Principles v5]], [[ontara-architecture (pms) platform-modelling-strategy|PMS v5]], [[ontara-architecture (sbmm) service-business-meta-modelling|SBMM v4]] will be checked for:
  - Accurate self-version references
  - Accurate cross-references to the other two foundations papers (not citing superseded versions as live)
  - Accurate register-count claims
  - TLA compliance (DKG/DBR/DSR where appropriate)

- **Tier 3:** Cross-cutting sweep. Mechanical scan across the vault for:
  - `v4.1` and `v3.1` occurrences outside of explicit history references
  - `~212 concepts`, `~214 concepts`, `~222 concepts` outside of Register History
  - `Workflow Guide (v2)` outside of explicit history references
  - `six-layer architecture` where `stratified two-side architecture` is the current formulation
  - Bare `BS`, `BR`, `SR`, `BM`, `SM` where TLA discipline (DKG, DBR, DSR, DBM, DSM) now applies

- **Finalisation:** Consolidated findings document (Part 2) combines with this Part 1 into the authoritative W-061 output; tracker updated; W-061 closed.

### 6.2 Session 226 scope — Fix session

- Execute W-068 (reference document currency batch) — likely a Claude Code session given the multi-file edit scope
- Execute W-069 (frontmatter sweep)
- Apply other priority-A W-items from the findings

### 6.3 Subsequent sessions

- [[ontara-ref-work-item-tracker|W-059]] (V&A Reference refresh to v13) — substantial workstream; Part 2 findings will sharpen its scope
- [[ontara-ref-work-item-tracker|W-060]] (concept graph content currency pass) — resume as originally planned
- [[ontara-ref-work-item-tracker|W-067]] (new concept-graph notes for B40, B42, B45, B46, B50, D30 plus siblings) — resume as originally planned
- Workflow guide amendments ([[ontara-ref-work-item-tracker|W-072]], [[ontara-ref-work-item-tracker|W-073]]) — compact governance session

### 6.4 Governance consequence

No Priority A item is deferred. The review has identified new Priority A items ([[ontara-ref-work-item-tracker|W-068]], [[ontara-ref-work-item-tracker|W-069]]) which take priority over the previously recommended sequencing (W-045 → W-059 → W-053). These cannot proceed until the reference corpus is trustworthy.

---

*Session 224 findings, Part 1 of 2. Part 2 will be produced at Session 225 close, covering Tier 2 foundations papers and Tier 3 cross-cutting sweep.*
