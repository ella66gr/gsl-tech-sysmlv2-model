# Ontara — Development Workflow Guide (v2)

**Date:** 23 March 2026 (Session 61)
**Replaces:** [[ontara-workflow-development-guide-2026-03-21]] (v1, Sessions 35–60)
**Purpose:** The shared operating agreement between Ella and Claude for all Ontara development work. Designed from scratch with the benefit of 60 sessions of experience.

---

## 1. Governing Commitments

Three commitments underpin everything in this guide:

1. **Ella leads, Claude supports.** Ella decides what to build, when, and why. Claude provides analysis, drafts, implementation, and review — but does not unilaterally decide to build things or consume tool-use budget on unagreed work. "Shall I go ahead?" is a genuine question, not a rhetorical preamble.

2. **Discipline is load-bearing ([[principle-discipline-as-load-bearing-structure|A9]]).** The practices in this guide propagate reliability through the platform to the end user. Regression applies to practices, not just code. Skipping a step is not saving time — it is introducing structural risk.

3. **Capture at inception ([[concept-inception-capture|J13]]).** When an idea, connection, or pattern surfaces during work, capturing it immediately in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] is a top-priority activity — not an interruption. The moment of recognition is fleeting; the web of connections that gave the insight meaning degrades rapidly if not captured.

---

## 2. Session Lifecycle

Every session follows the same backbone: **open → work → close**. The session type (§3) determines what happens during the work phase, but the bookends are invariant.

### 2.1 Open

| Step | Action | Who |
|---|---|---|
| O1 | **Read context.** Claude reads: (a) the preparation note from the previous session, (b) the [[ontara-ref-strategic-snapshot-2026-03-23-s60|strategic snapshot]], (c) the [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|master concept register]] Tier 1 quick reference. Claude also reads any documents the preparation note specifies (plans, discussion papers, reference documents). For sessions that will involve Claude Code or Cowork work, also read `CLAUDE.md` and `.claude/skills/README.md` from the repo root via MCP — this ensures Chat knows what Code knows and can write accurate implementation instructions. See the [[ontara-claude-tooling-guide-2026-03-23|Claude Tooling Guide]] (§5) for details. | Claude |
| O2 | **Staleness check.** Claude checks the session number and date on each reference document read. If any document exceeds its staleness threshold (§7.1), Claude flags it: *"The [document] is from Session N — we are now at Session M. Should we schedule a refresh?"* | Claude |
| O3 | **Register relevance scan.** Claude identifies which Tier 2 concepts are directly relevant to the session's planned work, which are at risk of being neglected, and which the planned work might contradict. This is a lightweight check, not an exhaustive audit. | Claude |
| O4 | **Agree scope.** What are we trying to achieve? What is out of scope? What is the expected deliverable? This is a conversation — Ella confirms, adjusts, or redirects. | Both |
| O5 | **Plan (for implementation sessions).** Claude produces a detailed implementation plan and gets agreement from Ella before starting work. Use this step to surface queries, unresolved issues, and tool-choice decisions (§4). Ella places the plan in the vault once complete. | Both |

### 2.2 Work

The work phase is governed by the session type (§3) and these standing rules:

- **Check before acting.** Before writing to the filesystem, creating files, or running generators, confirm the approach with Ella. Never overwrite a file Ella may have edited without checking first.
- **Use `edit_file` for existing documents.** Reserve `write_file` for new files only.
- **Flag register connections.** When working on something that touches a concept from the master register, note it: "This exercises D11" or "This doesn't yet address C6 — known gap."
- **Capture emergent ideas immediately ([[concept-inception-capture|J13]]).** Pause implementation to capture ideas in the [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]] with full context and connections. Capture first, route later.
- **Pause at milestones.** When a significant piece of work is complete, take stock. Is the work consistent with the agreed scope? Has anything come up that changes the plan?

### 2.3 Close

The close sequence is **numbered and must be followed in order**. Steps are not optional unless explicitly marked.

| Step | Action                                                                                                                                                                                                                                                                                                                                                                                    | Who                                                      | Notes                                                                                                                                                                                                                                       |        |
| ---- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| C1   | **Session report + preparation note.** Produce as container artifacts.                                                                                                                                                                                                                                                                                                                    | Claude                                                   | See §5.1 and §5.2 for specifications.                                                                                                                                                                                                       |        |
| C2   | **Master register update.** Which concepts were exercised, confirmed, or newly introduced? Any gaps identified? Claude updates the register directly via MCP.                                                                                                                                                                                                                             | Claude                                                   | Claude's responsibility. Do not defer.                                                                                                                                                                                                      |        |
| C3   | **Reference document updates.** Update applicable documents directly via MCP: syntax reference, KerML reserved words, backlog, deferred items, Architecture Papers Index, Concept Graph Index. Flag if the strategic snapshot needs refreshing (mandatory at stage/phase boundaries).                                                                                                     | Claude                                                   | See §7.1 for mandatory refresh triggers.                                                                                                                                                                                                    |        |
| C3a  | **Claude Code knowledge sync check.** If the session produced changes that affect Code's knowledge — new files, changed commands, new generators, changed repo structure, new conventions — Claude flags that `CLAUDE.md` or skills need updating. If the update is small, Claude drafts it. If it is substantial, it goes in the preparation note as a next-session task.                | Claude                                                   | Only needed if repo-affecting changes were made.                                                                                                                                                                                            |        |
| C4   | **Identify next steps.** What follows from this session? What decisions are pending? (Captured in the preparation note at C1.)                                                                                                                                                                                                                                                            | Both                                                     |                                                                                                                                                                                                                                             |        |
| C5   | **[[ontara-workflow-emergent-ideas-log                                                                                                                                                                                                                                                                                                                                                    | Emergent Ideas Log]] review ([[concept-inception-capture | J13]]).** Review *all* entries in the log — not just those added this session. For each: (a) confirm sufficient context, (b) wikilink enrichment pass, (c) update routing status if acted on, (d) note entries ready for permanent routing. | Claude |
| C6   | **Ella places documents.** Ella downloads container artifacts and places them in the vault. Claude reminds Ella to download the vault files and asks for confirmation once Ella has done this, to allow enrichment to take place.                                                                                                                                                         | Ella                                                     |                                                                                                                                                                                                                                             |        |
| C7   | **Wikilink enrichment of vault copies.** Claude reads each placed document from its vault location and performs a wikilink enrichment pass (§8). This applies to ALL placed documents — no exceptions. A document in the vault without wikilinks is disconnected from the knowledge base. Claude must not mark this step complete until every placed document has been read and enriched. | Claude                                                   | Enrichment happens on the vault copy, never on the container artifact.                                                                                                                                                                      |        |
| C8   | **Archive to repo.** Documents must be enriched (C7) before archiving. Claude provides shell commands: `cp` (vault → repo archive), `git add`, and `git commit` message referencing the session number. Preparation notes are vault-only — not archived to repo.                                                                                                                          | Claude                                                   | See §6.3 for archive paths.                                                                                                                                                                                                                 |        |
| C9   | **Ella commits and pushes.** If repo changes were made during the session (model files, scripts, console code, generated artefacts, archived documents).                                                                                                                                                                                                                                  | Ella                                                     |                                                                                                                                                                                                                                             |        |
| C10  | **Checklist confirmation.** Claude confirms with Ella that repo commands have been executed, then presents a checklist confirming each close step is complete.                                                                                                                                                                                                                            | Both                                                     |                                                                                                                                                                                                                                             |        |

### 2.4 Emergency Close

If context is running out mid-session and the full close sequence cannot be completed, capture at minimum:

1. **A preparation note** documenting exactly where work stopped, what is complete, what is incomplete, and what the next session must do first. This is the single most important close deliverable.
2. **Any new register concepts** — at minimum as bullet points in the preparation note if a full register update cannot be done.
3. **Any emergent ideas** captured during the session — at minimum as brief notes in the preparation note.

Mark the session report as "emergency close — incomplete" and list which close steps were skipped so the next session can pick them up.

---

## 3. Session Types

Not all sessions are the same. The session type determines the character of the work phase and how to allocate time.

### 3.1 Implementation

**Character:** Building things — model files, console features, generator extensions, demonstrator content.

**Rhythm:** Heavy on planning (O5), then sustained building with milestone pauses. Close is full and thorough because implementation produces artefacts that must be tracked.

**Key discipline:** Plan before building. No off-the-cuff implementation of significant features. Detailed implementation plans must identify which parts are best suited to Claude Chat, Claude Code, or Claude Cowork (§4). See the [[ontara-claude-tooling-guide-2026-03-23|Claude Tooling Guide]] for decision criteria.

### 3.2 Discussion

**Character:** Exploring ideas, evaluating options, clarifying concepts, resolving design questions.

**Rhythm:** Lighter opening (register scan still applies). The work phase is conversation. Close must capture key points in a discussion document with suitable detail and precision — a concept that exists only in chat history is a concept at risk of being lost.

**Key discipline:** Capture discussions and sift out key points. Discussion documents go to the vault. They may later inform plans, architecture papers, or model changes.

### 3.3 Planning

**Character:** Producing plans — high-level plans for new stages, detailed implementation plans for phases, or strategic planning (vision, roadmap).

**Rhythm:** The work phase *is* O5 — the plan is the deliverable. Close is lightweight since the plan itself is the primary output.

**Key discipline:** Plans must reference the register. Plans must specify Claude Chat/Code/Cowork allocation (§4).

### 3.4 Housekeeping

**Character:** Vault organisation, file renaming, register review, staleness remediation, wikilink maintenance, document revision.

**Rhythm:** Lighter opening. Work is systematic and methodical. Close may be lighter if the session was purely organisational.

**Key discipline:** Housekeeping is a legitimate, load-bearing activity ([[principle-discipline-as-load-bearing-structure|A9]]) — not a lesser form of work. It maintains the vault as a reliable, well-connected knowledge base.

### 3.5 Mixed

Many sessions combine types — e.g. a discussion that leads to planning, or implementation that surfaces a discussion topic. The session report should note the actual mix.

---

## 4. Claude Chat, Code, and Cowork: When to Use Which

Ontara development spans three Claude capabilities. Choosing the right tool for each task avoids wasted effort and plays to each tool's strengths. For detailed setup instructions, daily use patterns, and how the knowledge systems stay in sync, see the [[ontara-claude-tooling-guide-2026-03-23|Claude Tooling Guide]].

### 4.1 Claude Chat (this interface)

**Best for:**
- All session opening, scoping, and closing activities
- Discussion, design, and architectural exploration
- Planning and document drafting
- Wikilink enrichment and vault maintenance via MCP
- Reading, reviewing, and commenting on existing code or documents
- Small, targeted file edits via MCP (`edit_file`)
- Producing container artifacts (session reports, plans, discussion papers)
- Register, snapshot, and reference document updates

**Not suited for:**
- Large-scale code generation (multi-file, multi-hundred-line changes)
- Running builds, tests, or generators
- Any task requiring shell execution or iterative compile-test cycles

### 4.2 Claude Code (terminal agent)

**Best for:**
- Multi-file code implementation (console features, generator extensions)
- Tasks requiring iterative build-test-fix cycles
- Refactoring across multiple files
- Running Python generators and verifying output
- Git operations and file management in the repo
- Any task where Claude needs to execute commands and observe results

**How to use:** Ella runs Claude Code from the terminal with instructions prepared during a Chat session. Chat produces the detailed implementation plan; Code executes it. Instructions for Code should be self-contained — include the plan, file paths, acceptance criteria, and any constraints.

**Not suited for:**
- Architectural discussion (no back-and-forth dialogue)
- Vault/Obsidian operations (Code does not have MCP filesystem access to the vault)
- Tasks requiring judgement calls that need Ella's input mid-execution

### 4.3 Claude Cowork (desktop agent)

**Best for:**
- Tasks spanning multiple desktop applications (e.g. Obsidian + VS Code + Finder)
- File management operations across the vault and repo
- Repetitive desktop tasks that benefit from automation
- Cross-boundary operations (e.g. copying files between vault and repo, bulk renames)

**Not suited for:**
- Architectural discussion or design decisions
- Tasks requiring deep contextual understanding of the project
- Anything involving the SysML model semantics

### 4.4 Decision heuristic

For any piece of planned work, ask:

1. **Does it need discussion or judgement calls?** → Chat
2. **Does it need iterative code execution?** → Code
3. **Does it span multiple desktop applications?** → Cowork
4. **Is it a document, plan, or vault operation?** → Chat via MCP

Implementation plans should tag each step with `[Chat]`, `[Code]`, or `[Cowork]` to make the allocation explicit.

---

## 5. Key Document Specifications

### 5.1 Session Report

The session report summarises what was done. It is the historical record.

**Required contents:**
- Session number, date, type (§3)
- Summary of what was built, decided, or documented
- Register concepts exercised, confirmed, or newly introduced
- Emergent ideas captured (with log references)
- Open questions or deferred items
- Tier 1 principles relevant to this session's work and how they were honoured

**Format:** Narrative prose with clear section headings. Not a raw log of tool calls.

### 5.2 Preparation Note

The preparation note is the single most important handover mechanism between sessions. It tells the next session exactly where we are, what to read, and what to do next.

**Required contents:**
- **Where we are.** One paragraph: what just happened, what the current project state is.
- **What the next session should do.** Prioritised list with enough detail to begin work without re-reading the full session report.
- **Documents to read at session start.** Specific wikilinks — not "read the usual things."
- **Key principles to remember.** Any context-specific guidance for the next session (beyond what is in this guide).
- **Standing working rules.** Carried forward — MCP conventions, filesystem paths, standing commitments.

**What it is not:** A comprehensive summary of the session (that is the session report). The preparation note is forward-looking and action-oriented.

### 5.3 Discussion Document

Captures the substance of an exploratory or design discussion.

**Required contents:**
- The question or problem being explored
- The options considered and their trade-offs
- Key conclusions or positions reached
- Connections to register concepts, principles, and patterns
- Open questions remaining

**Format:** Structured prose. Discussion documents are working documents — they may later inform plans or architecture papers.

### 5.4 Implementation Plan

Produced before any significant development work.

**Required contents:**
- Objective and scope
- Prerequisite reading and context
- Step-by-step implementation sequence, each tagged `[Chat]`, `[Code]`, or `[Cowork]`
- For Code steps: self-contained instructions including file paths, acceptance criteria, and constraints
- Register concepts relevant to the work
- Expected deliverables
- Dependencies and open questions

---

## 6. Where Things Live

### 6.1 Working documents

| What | Where | Why |
|---|---|---|
| Working documents (drafts, discussion papers, plans, session notes) | Obsidian vault (`/Users/ellagreen/Obsidian/GenderSense/`) | Wikilinks, backlinks, graph view. Editable by Ella at any time. |
| Settled documents (committed snapshots) | Repo under `documentation/archive/` with sub-folders | Versioned history by deliberate choice. |
| SysML model files | Repo under `model/` and `exercises/` | Source of truth. Version-controlled. |
| Generated artefacts | Repo under `generated/` | Regenerable from model. `DO NOT EDIT` headers. |
| Scripts and generators | Repo under `scripts/` | Part of the generation pipeline. |

### 6.2 Vault structure

The vault organises Ontara content under `02 ONTARA ARCHITECTURE & MODELLING/` in seven subfolders:

- **Ontara Platform Development** — day-to-day development artefacts: reference & guides, plans (by stage), session reports & preparation notes (by decade)
- **Ontara Foundations** — settled architectural papers (principles, decisions, specifications, validated patterns)
- **Ontara Exploratory & Discussion Papers** — working discussion and exploration documents
- **Ontara Concept Graph** — individual concept, pattern, principle, domain, and deferred-item notes (with subdirectories: `concepts/`, `patterns/`, `principles/`, `domains/`, `deferred/`, `templates/`)
- **Ontara Demonstrators** — domain-specific material for Cafe, Suds, Paws
- **Ontara Research & Background** — exploratory notes, external research
- **Ontara History & Archive** — superseded snapshots, old work analyses

Claude should ask if unsure where a document belongs.

### 6.3 Repo archive paths

| Document type | Repo location |
|---|---|
| Strategic/governance documents | `documentation/archive/strategic/` |
| Implementation plans | `documentation/archive/plans/` |
| Session reports | `documentation/archive/session-reports/` |
| Design documents | `documentation/archive/design/` |

Preparation notes are **not** archived to the repo — they are vault-only.

### 6.4 Document creation rules

- **New working documents** go to the Obsidian vault in the appropriate folder.
- **Claude uses `edit_file`** for targeted changes to existing documents, never `write_file` (which overwrites everything).
- **Major revisions** are produced as separate files (e.g. with a `-v2` suffix) so Ella can compare and merge.
- **Committing to the repo** is a deliberate act by Ella, not something Claude initiates.
- **All vault references must be wikilinks.** No exceptions. Plain text vault references are fragile and silently break on restructure. The only plain text paths permitted are repo paths in shell commands (inside code blocks). This is a binding commitment ([[principle-discipline-as-load-bearing-structure|A9]]).

---

## 7. Reference Document Health

### 7.1 Staleness thresholds

| Document | Maximum staleness | Mandatory refresh trigger |
|---|---|---|
| [[ontara-ref-strategic-snapshot-2026-03-23-s60|Strategic snapshot]] | 5 sessions | Stage or phase boundary crossed |
| [[ontara-ref-vision-architecture|Vision and architecture reference]] | 10 sessions | Major architectural decision (new T1/T2 concepts) |
| [[Ontara Architecture Papers Index|Architecture Papers Index]] | 10 sessions | New papers produced; papers archived or moved |
| [[Concept Graph Index]] | 5 sessions | New concept notes created; counts changed |
| [[ontara-validated-architectural-patterns|Validated Patterns]] | 10 sessions | New patterns validated or existing patterns exercised in new domains |
| Foundations papers ([[ontara-platform-architecture-principles|Architecture Principles]], [[ontara-platform-sysml-modelling-strategy|SysML Modelling Strategy]], [[ontara-service-business-meta-modelling|Service Business Meta Modelling]]) | 15 sessions | Major BMM changes; new governing principles |

Claude checks staleness at session open (O2) and flags documents that exceed their threshold.

The master register is updated every session and does not need a staleness check.

### 7.2 Vault-wide review

Every ~10 sessions, or when the vault feels cluttered or disconnected, schedule a dedicated housekeeping session (§3.4) covering:

- **Structure:** Are folders rational, lean, and supportive of discovery? Are naming conventions consistent?
- **Content currency:** Are all reference documents within their staleness thresholds? Do index files reflect actual contents?
- **Deduplication:** Are there files covering the same ground? Are superseded documents properly archived?
- **Completeness:** Are there register concepts without concept notes that should have them? Are there discussion papers without corresponding register entries?

---

## 8. Wikilink Enrichment

### 8.1 When enrichment happens

Wikilink enrichment is performed on every document placed in the vault — session reports, preparation notes, plans, discussion documents, reference documents. No exceptions. Enrichment happens on the **vault copy** after Ella has placed it, never on the container artifact. Claude must read the vault copy and perform the enrichment there.

### 8.2 What gets linked

- **Vault documents.** References to other documents in the vault — architecture papers, plans, discussion documents, session reports, the workflow guide, the strategic snapshot, specifications. Use `[[filename|display text]]` piped syntax where the filename differs from natural prose.
- **Concept register entries.** References to specific concepts by register code (A3, J12, I14 etc.) or by name. Link to the individual concept note in `Concept Graph/` — not to the master register. If no individual note exists, create one during the enrichment pass (§8.4).
- **Patterns and principles.** References to validated patterns (D1–D22) and architectural principles link to their individual notes in `Concept Graph/patterns/` and `Concept Graph/principles/`.
- **Demonstrator domains.** References to Cafe, Suds, Paws link to their demonstrator folders or design notes.

### 8.3 Linking conventions

- **First mention per section.** Link the first substantive mention of a target in each major section (## heading level). Do not link every occurrence.
- **Natural prose context.** The wikilink should read naturally in the sentence. Use piped links to keep display text readable.
- **Concept codes in parentheses.** Link the concept name or code to the individual concept note. Link once per section; leave subsequent mentions as plain text for readability.
- **Be thorough but not exhaustive.** Link things a reader might want to follow. If a concept is merely mentioned in passing and the reader wouldn't gain from following it, leave it unlinked.

### 8.4 Creating concept notes during enrichment

When the enrichment pass references a concept that does not yet have an individual note, Claude creates one.

| Register section | Note location | Naming pattern |
|---|---|---|
| A (Architectural Principles) | `Concept Graph/principles/` | `principle-{kebab-case-name}.md` |
| D (Validated Patterns) | `Concept Graph/patterns/` | `pattern-{kebab-case-name}.md` |
| H (Deferred Items) | `Concept Graph/deferred/` | `deferred-{kebab-case-name}.md` |
| All other sections | `Concept Graph/concepts/` | `concept-{kebab-case-name}.md` |

Use existing templates in `Concept Graph/templates/`. Each note should contain: YAML frontmatter with register code, meta model classification, and tags; a brief purpose section drawn from the register summary; source reference; related concepts as wikilinks; domain instantiation status if applicable.

Only create notes for concepts actually referenced in the session's documents — not all ~171 at once. The inventory grows organically as sessions reference more concepts.

### 8.5 Link target index

Claude should build a working index of linkable targets at the start of each session by scanning the vault directory structure under `02 ONTARA ARCHITECTURE & MODELLING/`. The Concept Graph subdirectories (`concepts/`, `patterns/`, `principles/`, `domains/`, `deferred/`) are particularly important link targets. New documents created during the session become linkable targets for subsequent documents in the same session.

---

## 9. Model Development

### 9.1 Before writing SysML

1. **Check the syntax reference** (`documentation/reference/gsl-sysml-v2-syntax-reference.md`). Syside syntax differs from the spec. Check the KerML reserved words reference before choosing names for new part defs or attributes.
2. **Check the master register** for relevant concepts, patterns, and conventions.
3. **Identify which meta model** the new elements belong to (BMM or BSMM) and ensure doc blocks include the appropriate label.
4. **Identify cross-domain validation.** If introducing a new concept, how will it be validated in at least two domains?

### 9.2 The co-evolution check ([[concept-co-evolution|J2]])

When adding to the model: does tooling exist to visualise/navigate this? If not, plan to build it at the same time.

When building tooling: does model content exist to exercise this feature? If not, plan to create it at the same time.

### 9.3 After writing SysML

1. Verify it parses in Syside (Ella's responsibility — Claude cannot run Syside).
2. Update the master register if new concepts were introduced.
3. Note which patterns from the validated patterns list were exercised.
4. Note any gaps exposed (meta model concepts that couldn't express what was needed).

---

## 10. The Master Register Protocol

The master register is the guard against regression blindness.

### 10.1 When to review

- **Session opening (O3):** Tier 1 always. Relevant Tier 2 sections for the planned work.
- **Session close (C2):** Note concepts exercised, confirmed, or newly introduced. Update the register.
- **Before starting a new workstream:** Full review of Tiers 1 and 2. Check Tier 4 to ensure the workstream doesn't foreclose future directions.
- **Periodic (every ~5 sessions):** Full review of all tiers for conceptual drift.

### 10.2 How to update

- **New concept:** Add to the appropriate section with source reference and status.
- **Concept exercised:** Update instance counts or status notes.
- **Concept retired:** Mark as retired with date and rationale. Do not delete — the history matters.
- **Gap identified:** Add to section J (Identified Gaps).

### 10.3 Discussion paper pipeline convention

When a discussion paper introduces concepts that should become binding, the session report explicitly identifies them and the register update adds them at the appropriate tier. Discussion papers remain working documents; their implications are traced into the governance structure before the session closes.

---

## 11. Session Numbering

Sessions are numbered sequentially. Session numbers are assigned when the session begins, not in advance.

- If a planned session splits into two (e.g. context runs out mid-way), the second half gets the next sequential number.
- Retrospective numbering adjustments are not made — if a gap exists, it exists.
- The session number appears in: the session report filename, the preparation note filename, git commit messages, and any documents produced during the session.
- Filename conventions: `session-NN-report-YYYY-MM-DD.md`, `session-NN-preparation-note.md`.

---

## 12. Known Pitfalls

These are patterns observed across 60 sessions that cause problems. The workflow is designed to prevent them.

| Pitfall | Mitigation |
|---|---|
| **Claude runs ahead of agreed decisions.** Builds things before the approach is endorsed. | §1 commitment 1. "Shall I..." is a real question. §2.1 O5 — plan and agree before building. |
| **Wikilink enrichment skipped or performed on artifact only.** Container artifact declared "enriched" without linking the vault copy. | §2.3 C7 — enrichment happens on the vault copy after placement. Not deferrable. |
| **Claude overwrites Ella's edits.** Using `write_file` on a document Ella has been editing. | §6.4 — use `edit_file` for existing documents. Major revisions as separate files. |
| **Concepts silently dropped.** New work proceeds without reference to established principles. | §10 — register reviewed at session open and close. |
| **LLM prose smuggles fuzzy equivalences.** Generated text introduces subtle conceptual inaccuracies. | Periodic review. Ella edits directly. Precision of language matters. |
| **Tool-use budget consumed on speculative work.** Claude uses many tool calls exploring options before agreement. | §1 commitment 1. Agree the plan first. Estimate tool-use cost before starting. |
| **Documents written to wrong location.** Working docs going to repo, or vice versa. | §6 strictly. Ask if unsure. |
| **`part def` / `part` confusion.** Meta model concepts conflated with instances. | Standing convention I9. Conceptual precision required. |
| **Reference documents go stale silently.** | §7.1 — staleness check at session open. Mandatory refresh at boundaries. |
| **Preparation note is vague or incomplete.** Next session cannot pick up cleanly. | §5.2 — preparation note specification with required contents. |

---

## 13. Standing Technical Rules

These are always in force:

- Use MCP filesystem tools for the local filesystem, not bash/view on MCP paths.
- Repo root: `~/Developer/gsl-tech/gsl-sysml-model`
- Obsidian vault: `/Users/ellagreen/Obsidian/GenderSense`
- Use `filesystem:edit_file` (never `write_file`) for existing documents Ella may have edited.
- Use `filesystem:read_multiple_files` with JSON array for parallel reads.
- Use `filesystem:read_text_file` with `head` parameter for large files.
- Use `filesystem:move_file` for renames. No delete operation — prefix duplicates with `DUPLICATE-TO-DELETE-`.
- Bash/shell tools must not be used on MCP paths.
- The console's static data file (`console/static/data/model-introspection.json`) and the generated copy (`generated/ontara/model-introspection.json`) must be kept in sync.
- Check `documentation/reference/gsl-sysml-v2-syntax-reference.md` before writing new `.sysml` code.
- Check `ontara-kerml-reserved-words` before choosing names for new part defs or attributes.
- Plan filenames follow: `ontara-stage-{N}-plan-phase-{N}-{type}-{date}.md`.
- Do not treat "shall I go ahead?" as rhetorical.
- All vault references must be wikilinks. No exceptions.
- Enrichment happens on the vault copy, not the container artifact.

---

## Related Documents

- [[ontara-ref-vision-architecture|Ontara Vision and Architecture Reference]]
- [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master Concept Register]]
- [[ontara-ref-strategic-snapshot-2026-03-23-s60|Strategic Snapshot (Session 60)]]
- [[ontara-platform-architecture-principles|Architecture Principles]]
- [[ontara-platform-sysml-modelling-strategy|SysML Modelling Strategy]]
- [[ontara-service-business-meta-modelling|Service Business Meta Modelling]]
- [[ontara-validated-architectural-patterns|Validated Architectural Patterns]]
- [[Ontara Architecture Papers Index|Architecture Papers Index]]
- [[Concept Graph Index]]
- [[ontara-workflow-emergent-ideas-log|Emergent Ideas Log]]
- [[ontara-stage-4-high-level-plan-2026-03-21|Stage 4 High-Level Plan]]
- [[ontara-claude-tooling-guide-2026-03-23|Claude Tooling Guide]]
- Claude Code Project Context (`CLAUDE.md` at repo root)
- Claude Code Skills (`.claude/skills/README.md` at repo root)

---

*Workflow guide v2 designed from scratch, Session 61, 23 March 2026. Replaces the v1 guide that grew by accretion across Sessions 35–60.*
