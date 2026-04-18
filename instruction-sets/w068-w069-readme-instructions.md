# Claude Code Instruction Set — W-068, W-069, README update
## Session 226, 16 April 2026

**Authority:** W-061 Part 1 findings (F1–F37, session-224-findings.md) and Part 2 findings (F38–F65, session-225-findings-w-061-part-2.md).

**Scope:** Multi-file mechanical edits across the Obsidian vault and the gsl-sysml-model repo. Scan-only discipline is over — normal edit authority applies.

**Vault root:** `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA`
**Repo root:** `/Users/ellagreen/Developer/gsl-tech/gsl-sysml-model`

**Already done in Chat (do NOT repeat):**
- Architecture Papers Index (`—— ARCHITECTURE INDEX ——.md`) — F1–F5, F60–F65 resolved at S226
- Architecture Principles v5 — F38 resolved (Related Documents + colophon updated)
- Research & Background Index — frontmatter bumped to S226

---

## W-069 — Frontmatter reconciliation sweep (Priority A)

Three documents have `session:` frontmatter that lags the DCR. One has an inverse mismatch (body older than frontmatter). Fix all four.

### W-069-1: Strategic Snapshot — bump frontmatter to S222 (F7)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-strategic-snapshot.md`

In YAML frontmatter, change:
- `session: 208` → `session: 222`

Body text "Last updated: 16 April 2026 (Session 208 — major trim)" → "Last updated: 16 April 2026 (Session 222 — major trim)"

### W-069-2: Modelling Paradigm Reference — bump frontmatter to S222 (F20)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-modelling-paradigms.md`

In YAML frontmatter, change:
- `session: 208` → `session: 222`

Body "Last updated: Session 208" → "Last updated: Session 222"

### W-069-3: EIL — bump frontmatter to S222 (F28)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-workflow (eil) emergent-ideas-log.md`

In YAML frontmatter, change:
- `session: 208` → `session: 222`

### W-069-4: Shell Command Reference — reconcile body text with frontmatter (F26)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-shell-commands.md`

Frontmatter is correct (`session: 137`). Body text says "Last refreshed: Session 124" — update body to "Last refreshed: Session 137".

---

## W-068 — Currency propagation fix batch (Priority A)

### Part A: Reference documents (Part 1 findings)

#### W-068-A1: Strategic Snapshot — stale counts and version references (F9, F10, F11)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-strategic-snapshot.md`

**F9 — Delete §4.3 governance currency table.** Find the section headed `### 4.3` or similar containing "Governance currency (as of S208)" — this is a table with rows for each document's "Current as of" and "Next due" dates. Delete the entire subsection (heading + table). The DCR in the tracker is the authority; this table is redundant and contradicts it.

**F10 — Register count in §3.7.** Find `~222 concepts` in the body (in the Knowledge base metrics section) → change to `~232 concepts`. Also find discussion papers count: verify it says 42 and leave it; if it says a lower number, update to 42.

**F11 — Foundations table in §5.** Find the key documents table in §5 that lists the foundations papers. Update:
- `SysML Modelling Strategy (v4.1)` → `Platform Modelling Strategy (v5)`
- `Service Business Meta Modelling (v3.1)` → `Service Business Meta Modelling (v4)`

Update any associated wikilinks: the SBMM link should be `[[ontara-architecture (sbmm) service-business-meta-modelling|Service Business Meta Modelling (v4)]]`.

#### W-068-A2: Modelling Paradigm Reference — stale PMS version (F21)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-modelling-paradigms.md`

Find `SysML Modelling Strategy (v4.1)` → change to `Platform Modelling Strategy (v5)`. Update the associated wikilink if present to point to `ontara-architecture (pms) platform-modelling-strategy`.

#### W-068-A3: Claude Tooling Guide — stale workflow guide version (F23)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/02 Ontara Development/ontara-guide-claude-tooling.md`

Find `Workflow guide (v2)` → change to `Workflow guide (v3)`. Update wikilink display text if piped.

#### W-068-A4: Non-Technical Overview — ontology file count (F35)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-non-technical-overview.md`

Find `nine files` (referring to the ontology stack) → change to `thirteen files`. If the phrasing is "ontology stack of nine files" or similar, update to "thirteen files".

---

### Part B: Concept graph — Source-section version drift (Part 2 findings F44–F58)

All files are in `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/03 Ontara Concept Graph/`.

The pattern in every case: the Source section at the bottom of the note contains a stale version reference. Update the version string and wikilink only — do not alter body text.

**SBMM v3.1 → v4 updates (F44–F48):**

For each file below, find the Source section entry referencing `Service Business Meta Modelling (v3.1)` and update to `Service Business Meta Modelling (v4)`. Update the wikilink target to `ontara-architecture (sbmm) service-business-meta-modelling` if a wikilink is present.

- `concepts/concept-catalogue-entry.md` — update `Service Business Meta Modelling (v3.1) §3.1` → `Service Business Meta Modelling (v4) §3.1`
- `concepts/concept-external-reference.md` — update `Service Business Meta Modelling (v3.1) §3.1` → `Service Business Meta Modelling (v4) §3.1`
- `concepts/concept-inventory-record.md` — update `Service Business Meta Modelling (v3.1) §3.3` → `Service Business Meta Modelling (v4) §3.3`
- `concepts/concept-horizontal-mappings.md` — update `Service Business Meta Modelling (v3.1) §2` → `Service Business Meta Modelling (v4) §2`
- `concepts/concept-scenario-definition.md` — update `Service Business Meta Modelling (v3.1) §3.4` → `Service Business Meta Modelling (v4) §3.4`

**SBMM v2 → v4 updates (F49–F52):**

For each file below, find the Source section entry referencing `Service Business Meta Modelling v2 §9` and update to `Service Business Meta Modelling (v4) §5.7` (simulation content is now in v4 §5.7).

- `concepts/concept-simulation-data-generation.md`
- `concepts/concept-simulation-workflow-execution.md`
- `concepts/concept-simulation-temporal-control.md`
- `concepts/concept-simulation-purposes.md`

**PMS v4.1 / "SysML Modelling Strategy v2" → v5 updates (F53–F56):**

- `concepts/concept-persistence-policy.md` — update `Platform Modelling Strategy (v4.1) §8.3` → `Platform Modelling Strategy (v5) §8.3`. Update wikilink target to `ontara-architecture (pms) platform-modelling-strategy`.
- `concepts/concept-form-generation-from-model.md` — update `SysML Modelling Strategy v2 §9.3.2` → `Platform Modelling Strategy (v5) §9.3.2`. Update wikilink target to `ontara-architecture (pms) platform-modelling-strategy`.
- `concepts/concept-population-level-governance.md` — update `SysML Modelling Strategy v2 §9.3.3` → `Platform Modelling Strategy (v5) §9.3.3`. Update wikilink target to `ontara-architecture (pms) platform-modelling-strategy`.
- `concepts/concept-syside-automator-generation.md` — update `SysML Modelling Strategy v2 §9.2.3` → `Platform Modelling Strategy (v5) §9.2.3`. Update wikilink target to `ontara-architecture (pms) platform-modelling-strategy`.

---

### Part C: Principle notes — Source-section drift (F57–F58)

Files in `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/03 Ontara Concept Graph/principles/`.

**F57 — principle-self-describing-system.md:**

Find Source section referencing `SysML Modelling Strategy (v4.1) §3.1` → update to `Platform Modelling Strategy (v5) §3.1`. Update wikilink target to `ontara-architecture (pms) platform-modelling-strategy`.

**F58 — principle-two-meta-model-distinction.md:**

Two fixes:
1. Find the element count claim "The BMM contains 36 `part def`s across six concerns" → update to "The BMM contains 34 core elements across six concerns in `BusinessModel`, with `BusinessScenarios` and `BusinessStrategy` as sibling packages — per SBMM v4 §4."
2. Find Source section referencing `Service Business Meta Modelling (v3.1) §1` → update to `Service Business Meta Modelling (v4) §1`. Update wikilink target to `ontara-architecture (sbmm) service-business-meta-modelling`.

---

### Part D: Register-count updates (F43, F42)

**F43 — Concept Graph Purpose / index file:**

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/03 Ontara Concept Graph/—— CONCEPT GRAPH PURPOSE ——/—— CONCEPT GRAPH PURPOSE ——.md`

Find `all ~212 design concepts across 16 sections (A–P)` → update to `all ~232 design concepts across 16 sections (A–P)`.

**F42 — SBMM v4 Related Documents register count:**

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/04 Ontara Architecture/ontara-architecture (sbmm) service-business-meta-modelling.md`

Find `~220+ concepts across 16 sections (A–P)` in the Related Documents section → update to `~232 concepts across 16 sections (A–P)`.

---

### Part E: Demonstrator note (F59)

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/03 Ontara Concept Graph/domains/domain-suds.md`

Find `All five BMM concerns instantiated` → update to `All six BMM concerns instantiated` (StakeholderModel is the sixth concern, added S76–S81).

---

### Part F: Foundations paper micro-edits (F38 already done — F39 only)

**F39 — PMS v5 Related Documents SBMM reference:**

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/04 Ontara Architecture/ontara-architecture (pms) platform-modelling-strategy.md`

Find in the Related Documents section a line describing SBMM as "(v3.1) … v4 pending (W-049 remainder)" or similar → update to `Service Business Meta Modelling (v4) — complete (S218)`. Update wikilink target to `ontara-architecture (sbmm) service-business-meta-modelling`.

---

## README update

File: `/Users/ellagreen/Developer/gsl-tech/gsl-sysml-model/README.md`

**Current State section** — rewrite the section headed `## Current State (Session 213, April 2026)` with:

```markdown
## Current State (Session 226, April 2026)

- **All three foundations papers complete** (W-049 closed). Architecture Principles v5 (Sessions 210–211): strengthened A4 (stratified two-side architecture, six strata, two sides, ten loci), KG-canonical binding (B22), coordinate framework binding (A12), BS → SR rename, SRS/PRS strata named, five-principle unification hypothesis Test 1 passed. Platform Modelling Strategy v5 (S216): KG-canonical inversion formalised (OWL 2 DL canonical; SysML v2 engineering projection). SBMM v4 (S218): General/Tailored sub-structuring with four-criterion framework and 50-element audit; Tests 2 and 3 of unification hypothesis passed.
- **Eighth systematic documentation review complete** (Sessions 224–225, W-061). F1–F65 findings across Tier 1 reference documents, Tier 2 foundations papers, and Tier 3 concept-graph sweep. Reference corpus now fully characterised; fix batch (W-068/W-069) in execution at S226.
- **Stage 9 architectural foundation complete** (Sessions 192–200). Four foundation papers establish the basis for Stage 9. *Connecting the Stacks* (S192–193) defines eight design decisions and seven open questions. *BS Substrate and Bindings* (S197) establishes BR, SR, and bindings as first-class elements. *Surface Families* (S199) establishes the seven-user-band framing, headless five-layer architecture, and state placement discipline. *The Architect-Analyst Workspace* (S198, revised S200) locates the architect-analyst surface at user band 6.
- **Stage 8 — Ontara Portal formally closed** (Sessions 175–185, W-037). Auth, domain management, 10-module catalogue, two lifecycle state machines, progressive governance with 20 typed constraints (8 hard, 6 soft, 6 graded), promotion/demotion, simulation with comparative analytics, production visual treatment.
- **Ears clinical domain intake complete** (Sessions 160–168). Coverage map (86.2% Full), ~83 reasoning instance individuals, HermiT CONSISTENT on 13-file stack, SPARQL suite 66 queries.
- **Stage 7 — Reasoning Metamodel** (Sessions 148–158) formally closed S159. `ontara-reasoning.ttl`: 42 OWL classes, 15 named individuals, 40 object + 10 datatype properties. Three-way constraint hierarchy, decision mode routing, SEPIO evidence architecture.
- **Foundations papers:** Architecture Principles v5 (S211), Platform Modelling Strategy v5 (S216), Service Business Meta Modelling v4 (S218).
- **Ontology stack:** 13-file stack, HermiT CONSISTENT. SPARQL validation suite: 66 queries in 12 groups. Round-trip diff: 288 semantic units.
- **Console** has 13 views including 3D weighted relationship graph, visual architecture map, and Reasoning Vocabulary Explorer. BMM structurally complete — 34 core elements, 96 weighted relationships.
- **Vision and Architecture Reference** at v12 (Session 201). Refresh to v13 pending (W-059) once reference corpus fixes are applied.
```

**Companion Knowledge Base section** — update the final paragraph:

Find: `~212 registered design concepts across 16 sections (A–P), ~42 discussion papers, ~213 session reports (Sessions 28–213), 30 emergent ideas log entries, and the full governance structure including an Observation and Watchpoint Register (91+ items)`

Replace with: `~232 registered design concepts across 16 sections (A–P), 42 discussion papers, ~225 session reports (Sessions 28–S225), 37 live EIL entries (E001–E037), and the full governance structure including an Observation and Watchpoint Register (~110 items)`

**Key documents list** — find the line listing the foundations papers:

`Architecture Principles (v5), SysML Modelling Strategy (v4.1), Service Business Meta Modelling (v3.1)`

Replace with:

`Architecture Principles (v5), Platform Modelling Strategy (v5), Service Business Meta Modelling (v4)`

**Session reference** — update the footer:

`*README last updated: Session 214, 15 April 2026.*` → `*README last updated: Session 226, 16 April 2026.*`

Also update the inline `currently Session 214` reference in the Development Methodology section to `currently Session 226`.

---

## Tracker and DCR updates (do in vault)

After completing all edits above, update the work item tracker:

File: `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/ontara-ref-work-item-tracker.md`

1. **Delete W-068 and W-069** from Active Work Items (completed).
2. **Bump tracker frontmatter** `session:` to `226`.
3. **Update tracker footer** to record: "Last updated S226 (W-068 and W-069 complete)."
4. **Update DCR rows** for documents touched:
   - Strategic Snapshot: already S222 — no change needed
   - Modelling Paradigm Reference: already S222 — no change needed
   - Repo README.md: change `S214` → `S226`, next due `~S226` → `~S238`

---

## Commit instructions

### Vault commit:
```bash
cd /Users/ellagreen/Obsidian/GenderSense
git add -A
git commit -m "S226 W-068/W-069: currency propagation fixes; frontmatter sweep; concept/principle/domain note Source-section updates; README updated"
git push
```

### Repo commit:
```bash
cd /Users/ellagreen/Developer/gsl-tech/gsl-sysml-model
git add README.md
git commit -m "S226: README updated to current state (Session 226, v5 foundations papers, W-061 complete)"
git push
```

---

## Verification checklist

Before committing, verify:
- [ ] All 9 concept notes (F44–F56) have updated Source sections
- [ ] Both principle notes (F57–F58) updated
- [ ] domain-suds.md says "six BMM concerns" (F59)
- [ ] concept-index.md says ~232 (F43)
- [ ] SBMM v4 Related Documents says ~232 (F42)
- [ ] PMS v5 Related Documents SBMM ref updated (F39)
- [ ] Strategic Snapshot: §4.3 deleted, register count updated, §5 foundations updated (F9, F10, F11)
- [ ] Modelling Paradigm Reference: PMS v5 reference updated (F21)
- [ ] Claude Tooling Guide: workflow guide v3 reference updated (F23)
- [ ] Non-Technical Overview: thirteen files (F35)
- [ ] All four frontmatter reconciliations done (W-069)
- [ ] README: current state section rewritten, companion KB counts updated, foundations list updated, footer updated
- [ ] Tracker: W-068 and W-069 deleted, DCR updated for README

---

*Instruction set produced Session 226 by Claude Chat. Execute via Claude Code against vault and repo paths above.*
