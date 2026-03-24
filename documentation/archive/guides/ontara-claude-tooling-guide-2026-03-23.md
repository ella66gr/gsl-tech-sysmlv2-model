# Ontara — Claude Tooling Guide

**Date:** 23 March 2026 (Session 61)
**Purpose:** Ella's reference for working with Claude Code, Claude Chat, and Claude Cowork on the Ontara project. Covers setup, daily use, and how the knowledge systems stay in sync across tools.

---

## 1. The Three Tools and What They Know

Each Claude tool has a different relationship with the project's knowledge:

| Tool | What it knows at session start | How it learns during a session | Persistent memory |
|---|---|---|---|
| **Claude Chat** | Memory system (from past conversations) + whatever documents it reads via MCP at session open | Reads vault/repo files on demand via MCP. Conversation context accumulates within the session. | Anthropic's memory system across conversations. MCP gives live filesystem access. |
| **Claude Code** | `CLAUDE.md` (auto-loaded) + auto-memory from previous Code sessions + skills (available on demand) | Full shell access. Reads any file. Builds and runs things. Auto-memory captures corrections/patterns. | `CLAUDE.md` + `.claude/skills/` (committed to repo) + auto-memory in `~/.claude/projects/` (local) |
| **Claude Cowork** | What you tell it in the task + what it can see on screen | Interacts with desktop applications visually. | None between sessions. Task instructions are the only input. |

The key insight: **Chat is the architect, Code is the builder, Cowork is the hands.** Chat holds the deep project context (architecture, principles, [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|register]], vault). Code holds the executable knowledge (how to build, run, generate). Cowork holds nothing — it needs instructions each time.

---

## 2. What's Been Set Up

### 2.1 CLAUDE.md (repo root)

This file is loaded automatically at the start of every Claude Code session. It contains:

- Project identity and architecture summary
- Complete repo layout with all key file paths
- Tech stack for console, Coffee Shop demonstrator, and generators
- All the commands needed to run generators, console, and demonstrator services
- The critical data sync rule (generated JSON → console static data)
- SysML conventions (syntax reference, reserved words, doc block requirements, part def vs part)
- Development principles ([[concept-co-evolution|co-evolution]], [[concept-non-constraining|non-constraining]], [[principle-model-generates-everything|model generates everything]])
- Commit convention (session numbers)
- Working-with-Ella guidance

**You don't need to re-explain any of this when starting a Code session.** Claude Code already knows it.

### 2.2 Skills (slash commands)

Skills live in `.claude/skills/` in the repo. Each is a markdown file with step-by-step instructions. Available commands:

| Command | What it does |
|---|---|
| `/generate` | Regenerate model-introspection.json and sync to console. `/generate all` runs all generators. |
| `/console` | Start the Ontara Console dev server. Also: `/console build`, `/console refresh` |
| `/coffeeshop` | Start Coffee Shop demonstrator (Docker + Temporal + web). Also: `/coffeeshop stop`, `/coffeeshop generate` |
| `/commit 61 description` | Git commit with session-number convention. Shows diff first, waits for confirmation. |
| `/status` | Quick health check: git status, file freshness, sync check, running services. |
| `/syntax-check [term]` | Read SysML syntax reference and reserved words. Optionally search for a specific term. |
| `/model-edit [file]` | Guided SysML model editing with safety checks and conventions. |
| `/archive type path` | Copy enriched vault documents to repo archive directory. |

**Usage:** In Claude Code, just type the command. You can also use natural language — e.g. "regenerate from the model and start the console" — and Code will recognise what to do because the skills describe the same operations that the CLAUDE.md documents.

### 2.3 Auto-memory

Claude Code automatically accumulates knowledge as you work with it — corrections you make, patterns it discovers, debugging insights. This is stored locally in `~/.claude/projects/` and loaded at session start. You don't need to manage it, but you can review it by typing `/memory` in a Code session.

### 2.4 CLAUDE.local.md (optional, gitignored)

If you want personal preferences that aren't shared with the repo (e.g. preferred terminal colours, editor settings, personal workflow shortcuts), create `CLAUDE.local.md` at the repo root. It's gitignored and supplements the project `CLAUDE.md`.

---

## 3. Daily Use Patterns

### 3.1 Starting a Code session

Open your terminal in the repo root and start Claude Code. It will automatically load `CLAUDE.md` and auto-memory. You can immediately:

- `/status` to see where things stand
- `/generate` to regenerate from the model
- `/console` to start the dev server
- Or just describe what you want to do in natural language

### 3.2 Implementation work planned in Chat

The typical flow for implementation:

1. **Chat session:** Discuss, plan, produce a detailed implementation plan (see [[ontara-workflow-development-guide-v2-2026-03-23|workflow guide v2]] §5.4). The plan tags each step `[Chat]`, `[Code]`, or `[Cowork]`.
2. **Code session:** Open Claude Code. Paste or describe the implementation plan (or just say "implement Phase 1 of the Stage 4 plan"). Code executes it step by step.
3. **Back to Chat:** Session close — report, register update, vault maintenance.

For Code steps, Chat will produce self-contained instructions that include file paths, acceptance criteria, and constraints. You can copy these directly into a Code session.

### 3.3 Quick tasks

For quick tasks, you don't need a formal plan:

- "Add a @PurposiveDescription to the FinancialPlanning package in business-model.sysml" — Code can handle this directly, guided by the syntax reference it knows about.
- "Regenerate and check the console still works" — `/generate` then `/console`.
- "Show me what's changed since last commit" — `/status` or just `git diff`.

### 3.4 Cowork tasks

Cowork is best for cross-application operations. Give it a clear, self-contained task description:

- "Copy these three files from the Downloads folder to the Obsidian vault at [path], then rename them to match the ontara- prefix convention."
- "In Finder, move the old session reports from Sessions 51-60 folder to the archive."

Cowork does not have persistent project context, so always include the relevant paths and conventions in the task description.

---

## 4. Keeping Instructions Up to Date

### 4.1 What changes and where to update it

| What changed | Update where | Who does it |
|---|---|---|
| **New generator added** | `CLAUDE.md` (generator commands section) + new `/generate` variant or new skill | Ella (or Chat drafts, Ella places) |
| **New console view or route** | `CLAUDE.md` (if it changes the architecture summary) | Ella or Code (via auto-memory for minor changes) |
| **Repo structure changed** (new directories, moved files) | `CLAUDE.md` (repo layout section) | Ella or Chat drafts update |
| **New SysML convention** | `CLAUDE.md` (SysML conventions section). Syntax reference file updated as usual. | Chat updates syntax ref via MCP; Ella updates CLAUDE.md |
| **New recurring workflow** | New skill in `.claude/skills/` | Chat drafts it, Ella places it |
| **New development principle or register concept** | `CLAUDE.md` only if it's a T1 principle. Otherwise, Code doesn't need it — that's Chat's domain. | Chat manages register; Ella updates CLAUDE.md for T1 changes |
| **Coffee Shop demonstrator changes** | `/coffeeshop` skill and `CLAUDE.md` if architecture changes | As needed |
| **Minor correction or preference** | Just tell Code during a session — auto-memory will capture it | Automatic |

### 4.2 The update rhythm

**Every session (Chat's responsibility at session close):** If the session produced changes that affect Code's knowledge — new files, changed commands, new conventions — Chat flags this in the preparation note: *"CLAUDE.md needs updating: new generator added"* or *"New skill needed for X."*

**Periodically (every ~5 sessions or at stage boundaries):** Review the `CLAUDE.md` and skills as part of the vault health check. Ask: does Code know about everything it needs to? Are any skills stale? This takes five minutes and prevents drift.

**On the fly:** If you notice Code getting something wrong repeatedly, the quickest fix is to either (a) correct it in the session (auto-memory captures it) or (b) update `CLAUDE.md` directly — it's just a text file in the repo root.

### 4.3 The golden rule

**`CLAUDE.md` should describe the project as it is now, not as it was when the file was written.** Treat it like a living reference document — the same way we treat the [[ontara-ref-strategic-snapshot-2026-03-23-s60|strategic snapshot]] and the [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|master register]]. If it's stale, Code's first actions in every session will be slightly wrong, and you'll waste time correcting.

---

## 5. How Chat Tracks What Code Knows

This is important: **Chat and Code do not share memory.** They are separate tools with separate knowledge systems. Chat doesn't automatically know what Code has learned via auto-memory, and Code doesn't have access to Chat's conversation history or the Obsidian vault.

The bridge between them is the **committed, shared documents:**

- `CLAUDE.md` — Chat can read this via MCP, so Chat knows exactly what Code knows at session start.
- `.claude/skills/` — Chat can read these via MCP, so Chat knows what commands Code has available.
- The vault's [[ontara-workflow-development-guide-v2-2026-03-23|workflow guide]] and preparation notes — these tell Chat what Code should be used for in the next session.

**In practice, this means:**

1. **Chat should read `CLAUDE.md` at session start** (alongside the vault documents) when the session involves planning Code work. This lets Chat write implementation plans that use the right commands, reference the right paths, and align with what Code already knows.

2. **When Chat produces implementation instructions for Code**, it can reference skills by name: "Use `/generate` to regenerate, then run `/console refresh`" — because Chat has read the skill definitions and knows they exist.

3. **When Chat identifies that Code's knowledge needs updating**, it produces the updated `CLAUDE.md` or new skill file as a session deliverable, just like any other document.

4. **The preparation note is the handover mechanism** — not just between Chat sessions, but between tools. If a Chat session decides "we need a new `/test` skill for the console," the preparation note says so, and the next session (Chat or Code) creates it.

### 5.1 Adding to Chat's session-open reading list

For sessions that will involve Code or Cowork work, add to the session-open reading list:

- `CLAUDE.md` (from the repo root via MCP)
- `.claude/skills/README.md` (for the current skill inventory)

This keeps Chat's awareness of Code's capabilities current.

---

## 6. File Locations Summary

| File | Location | Committed to git? | Purpose |
|---|---|---|---|
| `CLAUDE.md` | Repo root | Yes | Persistent project context for Code |
| `CLAUDE.local.md` | Repo root | No (gitignored) | Personal preferences |
| `.claude/skills/*/SKILL.md` | `.claude/skills/` in repo | Yes | Slash commands / executable workflows |
| `.claude/settings.local.json` | `.claude/` in repo | No (gitignored) | Local Code settings |
| Auto-memory | `~/.claude/projects/` | No (outside repo) | Code's accumulated learnings |
| [[ontara-workflow-development-guide-v2-2026-03-23|Workflow guide (v2)]] | Obsidian vault | No (vault document) | Chat's operating agreement |
| [[ontara-ref-master-register-design-concepts-tiered-2026-03-20|Master register]] | Obsidian vault | No (vault document) | Chat's concept governance |
| [[ontara-ref-strategic-snapshot-2026-03-23-s60|Strategic snapshot]] | Obsidian vault | No (vault document) | Chat's project overview |

---

*Guide written Session 61, 23 March 2026.*
