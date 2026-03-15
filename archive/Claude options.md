<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Tell me what are all the options for integrating Claude AI with Obsidian. How does each bring benefit, which can be used together?

You have four main ways to integrate Claude with Obsidian right now, plus a few “lego-brick” automations that layer on top.[^1_1][^1_2][^1_3][^1_4]

## 1. Claude Desktop + MCP Tools into your vault

This is the “second brain” style integration where Claude Desktop connects directly to your vault using MCP tools that expose your notes as a filesystem / search API.[^1_2][^1_3][^1_4]

Benefits:[^1_3][^1_2]

- **Vault‑aware reasoning**: Claude can read, search, create, and edit notes and folders, and keep structure intact.
- Semantic search and smart linking across notes (“find everything related to X and suggest links”).
- Bi‑directional sync: you edit in Obsidian, iterate and refactor in Claude, then sync back.
- Works across devices where Claude Desktop + MCP are available.

Plays well with:[^1_5][^1_3]

- Any Obsidian plugin (Templater, Dataview, Kanban, etc.) because Claude just sees files.
- QuickAdd / Templater workflows where Claude generates content that templates then structure.

Typical use: long‑form thinking, refactors, research synthesis, building documentation where you want Claude to roam freely across the vault.

## 2. Native Obsidian plugins that call Claude

These run inside Obsidian and talk to Claude via API / CLI.

### 2.1 CAO – Claude AI for Obsidian

CAO is a community plugin that embeds Claude chat directly in Obsidian panes.[^1_6]

Benefits:[^1_6]

- Chat‑style notes: each note can hold a conversation, configurable via front‑matter (model, temperature, system prompt).
- Multiple Claude models exposed; per‑note settings for different tasks (coding, drafting, analysis).
- Commands for new chat, resume, fetch response, so you stay keyboard‑driven.

Plays well with:[^1_6]

- Your existing note structure (CAO stores chats as markdown).
- Other AI/automation plugins because CAO is “just notes plus chat.”


### 2.2 Agent Client – hook Claude Code (and other CLIs) into Obsidian

Agent Client is a plugin that connects to external agents like Claude Code via ACP, and lets them act on your vault.[^1_7]

Benefits:[^1_7]

- Vault‑aware agents: use `@[[note name]]` or `@notename` to inject specific notes or selections into a conversation.
- Auto‑mention mode: always include current note context, ideal for iterative editing.
- Tool execution: the agent can run terminal commands and MCP tools, so you can orchestrate more complex workflows (build, run scripts, etc.).

Plays well with:[^1_7]

- Claude Code running locally.
- Other agent CLIs (Codex, Gemini, etc.) in parallel.


### 2.3 Claude Sidebar – Claude Code embedded in the UI

“Claude Sidebar” is a plugin that literally embeds Claude Code’s terminal UI in Obsidian’s sidebar.[^1_8]

Benefits:[^1_9][^1_10][^1_8]

- One‑click Claude Code: no switching to a separate terminal; directly in your workspace.
- Multiple tabs for parallel conversations (e.g., one for code, one for notes).
- Claude can read and edit files in your vault using its normal CLI capabilities.

Plays well with:[^1_8][^1_7]

- Agent Client (they can coexist; one is CLI UI in sidebar, the other is an Obsidian‑native agent front‑end).
- MCP‑based workflows, since Claude Code can load your vault as a context/tool.


## 3. QuickAdd / Templater + Claude API (DIY calls)

You can also wire Claude in via generic HTTP calls or scripts triggered by QuickAdd and/or Templater.[^1_11][^1_3][^1_5]

Benefits:[^1_3][^1_5]

- Highly **custom** workflows: “summarise current note to a new file”, “generate spaced‑repetition questions into a specific folder”, “draft a clinic letter from this template using Claude.”
- Works even if you do not use Claude Desktop or CLIs, as long as you have an API key.
- Can chain with Templater variables, front‑matter, and Dataview to build sophisticated, repeatable automations.

Plays well with:[^1_5][^1_11]

- Any core or community plugin that consumes markdown or front‑matter.
- Claude Desktop/MCP setups (these workflows just create/edit files that Claude then sees).


## 4. Claude Code as the “outer loop” coding assistant

Finally, there is the meta‑integration where you use Claude Code to develop and maintain Obsidian plugins and scripts that run in your vault.[^1_12][^1_10][^1_13][^1_9]

Benefits:[^1_13]

- Use Claude to scaffold entire Obsidian plugins (TypeScript) from a description and some existing code.
- Keep a Claude Project pointed at your plugin repo so it can iteratively refactor, add commands, and fix bugs.
- Great for building your own tailored “clinic workflow” or “research assistant” plugin.

Plays well with:[^1_13]

- All of the above, because you can customise or fork CAO/Agent Client‑style patterns for your own use.


## How these options combine

You can safely combine most of these; they operate at different layers.


| Layer / Goal | Recommended pieces |
| :-- | :-- |
| Vault‑wide “second brain” | Claude Desktop + MCP Tools to your vault, plus Templater/Dataview in Obsidian[^1_2][^1_3] |
| In‑vault chatting \& editing | CAO plugin for per‑note chats, or Agent Client for agent‑style workflows[^1_6][^1_7] |
| Embedded terminal‑style agent | Claude Sidebar with Claude Code configured for your vault[^1_8][^1_9] |
| One‑shot automations / templates | QuickAdd + Templater + small scripts calling Claude API[^1_3][^1_5][^1_11] |
| Custom plugin development | Claude Code / Projects to generate and maintain plugins and scripts[^1_9][^1_12][^1_13] |

Common combined setups:[^1_2][^1_3][^1_8][^1_6][^1_7]

- “Maximalist”: Claude Desktop + MCP (global context) + Agent Client for structured agent workflows + Claude Sidebar for fast CLI access + QuickAdd automations for repeatable tasks.
- “Lightweight”: CAO for chat‑in‑notes + QuickAdd calls to Claude API for summaries and drafts.
- “Dev‑focused”: Claude Sidebar + Agent Client (both wired to Claude Code) for code and docs, plus MCP pointing at your project vault.

Given your workflow in GenderSci and clinical documentation, the main fork is: do you want Claude to have continuous, broad access to your whole vault (MCP) or mostly scoped, per‑note operations (CAO/QuickAdd)?

What’s your primary use case right now: clinical note/letter generation, research/knowledge management, or plugin/tool building?
<span style="display:none">[^1_14][^1_15]</span>

<div align="center">⁂</div>

[^1_1]: https://www.xda-developers.com/connected-claude-with-obsidian-and-never-looking-back/

[^1_2]: https://pub.towardsai.net/from-notes-to-knowledge-the-claude-and-obsidian-second-brain-setup-37af4f47486f

[^1_3]: https://dev.to/sroy8091/connect-claude-ai-with-obsidian-a-game-changer-for-knowledge-management-25o2

[^1_4]: https://www.eleanorkonik.com/p/claude-obsidian-got-a-level-up

[^1_5]: https://quickadd.obsidian.guide/docs/

[^1_6]: https://www.obsidianstats.com/plugins/cao

[^1_7]: https://forum.obsidian.md/t/new-plugin-agent-client-bring-claude-code-codex-gemini-cli-inside-obsidian/108448

[^1_8]: https://forum.obsidian.md/t/claude-code-from-the-sidebar/109634

[^1_9]: https://www.youtube.com/watch?v=NsIJ3dkke-o

[^1_10]: https://www.youtube.com/watch?v=0ah7qpuOpPg

[^1_11]: https://www.youtube.com/watch?v=gYK3VDQsZJo

[^1_12]: https://www.youtube.com/watch?v=a0k8wh69PjM

[^1_13]: https://www.stephanmiller.com/creating-an-obsidian-plugin-with-claude/

[^1_14]: https://www.youtube.com/watch?v=a1FDaoF8Jog

[^1_15]: https://www.reddit.com/r/ObsidianMD/comments/1q6fnx3/who_all_are_using_this_claude_code_and_how/


---

# I work with Claude AI in the desktop on business and business system development. We are building a SysML.v2 model of both the business and the tech system platform. It works well. I run commands in the command line and share the outoput with Claude. Claude accesses the filesystem directly to edit code. I'm really unclear at the moment what Claude Code brings.

Please explain.

Claude Code is a separate “agentic coding environment” that runs in your terminal; it overlaps with what you’re already doing in Desktop + filesystem, but adds structure, persistence, and automation around software‑type work.[^2_1][^2_2][^2_3]

## Core difference from Desktop + MCP

Claude Desktop with MCP/skills is a general agent that can read/write files and run commands, but every chat is still “just a chat” that you orchestrate step‑by‑step.[^2_4][^2_5]
Claude Code is a dedicated CLI/TUI that treats the current directory as a project and is optimised around planning, editing, and iterating on codebases with minimal prompting.[^2_2][^2_3][^2_1]

Concrete distinctions:[^2_3][^2_5][^2_1][^2_2]

- **Interface \& focus**:
    - Desktop: conversational UI with optional tools; you copy in command output, ask for next steps, then run them yourself.
    - Code: runs inside the repo, can directly read/modify files, and executes shell commands as part of its own plan.
- Project‑level context:
    - Code builds an internal model of the whole directory: structure, build commands, tests, dependencies, etc., and reuses this across steps with less re‑prompting.
    - You steer at the “goal” level (“migrate this module to a hexagonal architecture”), it figures out which files to open, edit, and test.


## What Claude Code specifically adds

These are the pieces you don’t really get (or only get in a more manual way) with Desktop + MCP + “copy command output into chat”:

- Goal‑driven, multi‑step agents
    - You describe an outcome; Code decomposes into a plan, reads files, proposes edits, runs tests/commands, and iterates with relatively few extra prompts.[^2_6][^2_2][^2_3]
    - Think “junior engineer who can sit in your repo for an hour” vs “chatbot that helps with each individual step.”
- Structured project metadata via `CLAUDE.md`
    - A project‑root file where you define coding standards, architecture rules, naming conventions, acceptance criteria, etc.[^2_1]
    - Code reads this on every session and uses it as a persistent style/architecture spec without you re‑explaining your system each time.
- Auto‑memory across sessions
    - Code persists things like “how to run tests”, common commands, known flaky tests, debugging insights, etc., as auto‑memory tied to the project.[^2_2][^2_1]
    - In Desktop you’d typically restate or store this in a project prompt, but Code is opinionated about treating it as operational memory.
- Custom `/commands` and hooks
    - You can define custom commands like `/review-pr`, `/update-tests`, `/deploy-staging` that run repeatable workflows (plan + code edits + shell commands).[^2_7][^2_1][^2_2]
    - Hooks let you automatically run linters, formatters, tests, or other scripts before/after its actions (e.g. “after every write, run `black` and `pytest -q`”).[^2_1][^2_2]
- Guardrails and policy
    - You can configure protections like “never modify infra/prod configs,” require tests to pass before committing, enforce branch policies, etc.[^2_7][^2_2]
    - That moves you from ad‑hoc edits to a more governed pipeline, closer to how you’d supervise a junior dev team.

In practice, Code is less about “Claude can touch the filesystem” (which you already have) and more about “Claude can own a workflow end‑to‑end inside a repo with structure, memory, and automation.”

## How this matters for your SysML / business‑system work

Given what you described, you’re already doing three things manually: orchestrating steps, passing terminal output back into Desktop, and re‑encoding project rules in prompts.

Claude Code would help mainly in these areas:

- Long‑running refactors and system‑wide changes
    - E.g. “update the SysML.v2 model and corresponding platform modules to new naming conventions,” “instrument all domain services with common logging/metrics,” or “align model and code with a new bounded‑context split.”
    - Code will walk the dependency tree, touch multiple files, run tests, and iteratively fix breakages, rather than you driving every micro‑step.[^2_3][^2_6][^2_2]
- Codifying architecture as living rules
    - Put your business + technical architecture decisions (DDD boundaries, model patterns, safety constraints) into `CLAUDE.md` + skills so every change is checked against them.[^2_8][^2_1]
    - That’s closer to “architecture as executable spec”, which aligns with the way you treat SysML.
- Repeatable business‑system workflows
    - You can wrap things like “generate a new service from a SysML block + interfaces” into a custom command that reads the model artifacts, scaffolds code, wires tests, and updates docs in one go.[^2_2][^2_1]
    - Over time that becomes a library of “business system automations” your team can run without hand‑holding the model each time.

If you’re happy manually driving the loop and like fine‑grained control, Desktop + MCP is already very capable. Claude Code becomes compelling when you want Claude to behave more like a persistent, policy‑constrained junior engineer who can own chunks of the development workflow rather than just assist with each step.

Would it help if I mapped out a concrete “from SysML change to code + docs updated” pipeline showing what you’d keep in Desktop vs what you’d delegate to Claude Code?
<span style="display:none">[^2_10][^2_11][^2_12][^2_13][^2_14][^2_15][^2_9]</span>

<div align="center">⁂</div>

[^2_1]: https://code.claude.com/docs/en/overview

[^2_2]: https://www.datacamp.com/tutorial/claude-code

[^2_3]: https://www.pluralsight.com/resources/blog/ai-and-data/what-is-claude-code

[^2_4]: https://www.youtube.com/watch?v=TAXdDEZaR9U

[^2_5]: https://www.producttalk.org/claude-code-what-it-is-and-how-its-different/

[^2_6]: https://www.youtube.com/watch?v=zxMjOqM7DFs

[^2_7]: https://eval.16x.engineer/blog/claude-vs-claude-api-vs-claude-code

[^2_8]: https://limitededitionjonathan.substack.com/p/the-definitive-guide-to-claude-skills

[^2_9]: https://www.reddit.com/r/ClaudeAI/comments/1ixave9/whats_claude_code/

[^2_10]: https://www.youtube.com/watch?v=AJpK3YTTKZ4

[^2_11]: https://newsletter.pragmaticengineer.com/p/how-claude-code-is-built

[^2_12]: https://www.youtube.com/watch?v=uDRjhVXZaBc

[^2_13]: https://support.claude.com/en/articles/12111783-create-and-edit-files-with-claude

[^2_14]: https://www.builder.io/blog/claude-code

[^2_15]: https://github.com/anthropics/claude-code/issues/25363


---

# Yes. Would I continue to use both Desktop chat and Claude Code together, each for their own strengths? What about Claude Cowork? Is there also a role for that? Does it work to integrate all 3 of these, or should I mainly stick to one? I have found the Desktop Chat approach to be very capable already compared with previous generations of trying to develop a project.

There is development workflow of coming up with ideas, chatting about them and discussing options, and then creating a high level plan, followed by detailed implementation plans per session. Along the way, I have created multiple governance, architecture, strategy and journal docs, that help to keep everything on the rails and Claude reads these from the filesystem each session as required.

It does sound like I could benefit from Claude Code for the implementation stage of each phase.

Yes, you can (and probably should) use all three, but in different layers: Chat for thinking and design, Code for implementation in repos, Cowork for operational / cross‑file and cross‑app work.[^3_1][^3_2][^3_3][^3_4]

## Mental model of the three

- **Chat (Desktop, normal tabs)** – conversational, exploratory, “thinking partner” with light file access when you explicitly share things or use skills/MCP.[^3_5][^3_3]
- **Claude Code** – agentic coding environment tied to a project directory, optimised for editing code and running commands with structure, plans, and diffs.[^3_6][^3_7][^3_8]
- **Cowork** – agentic desktop “operations” assistant: it runs multi‑step tasks on folders, documents, spreadsheets, slides, and connectors (Drive, Slack, etc.) with sub‑agents and scheduling.[^3_9][^3_4][^3_1][^3_5]

Your current workflow already matches this separation quite nicely; you are just doing most of the “agentic” part by hand in Chat.

## How they map onto your phases

Given your described flow (ideation → high‑level plan → implementation plans → execution with governance docs) a natural division is:

### 1. Chat: ideas, architecture, governance

Keep using **Chat** where it already shines for you:

- Exploration and **strategy**: shaping business models, operating models, SysML viewpoints, value flows, governance principles.[^3_3]
- Architecture and systems design: drafting and iterating SysMLv2 packages, views, constraints, platform service boundaries, and alignment with clinical workflows.
- Governance / journals: elaborating policy docs, architecture decision records, session journals, and “what did we learn from this iteration” notes.[^3_5][^3_3]

You can keep those governance/architecture/journal docs in the filesystem and have Chat read them at the start of each session (or bundle them into skills), which you’re already doing effectively.

### 2. Claude Code: implementation inside repos

Use **Claude Code** when you move from plan to code or model artifacts living in a project directory:[^3_7][^3_8][^3_6]

- Implementing a planned change set: “Apply ADR‑017 to the `care-journey-service` repo” or “Refactor the SysMLv2 model + code for the assessment workflow into new bounded contexts.”
- Multi‑file, test‑driven work: Code scans the repo, updates many files, runs your scripts/tests, and iterates until green.
- Enforcing rules you already wrote: encode key constraints into `CLAUDE.md` (architecture principles, safety requirements, naming conventions), so every edit is checked against them automatically.[^3_6]

In other words: take the implementation stage of each phase, and instead of you manually running commands and pasting outputs back into Chat, delegate it to Code with goals and constraints.

### 3. Cowork: business‑system operations and cross‑artifact tasks

**Cowork** makes most sense for your *non‑repo* but still structured work:[^3_4][^3_1][^3_9][^3_5]

- Business artefacts and ops: generating and updating strategy decks, business process docs, spreadsheets for capacity / finance models, risk registers, OKR trackers, etc.
- Cross‑file synthesis: “Sweep all journal notes for the last 4 weeks and produce an architecture impact report” or “Analyse our clinical pathway specs + SysML diagrams + governance docs and produce a consolidated change log.”
- Long‑running or scheduled tasks: “Every Sunday, read this `governance/` folder and produce a weekly digest + decision backlog,” or “Regenerate stakeholder‑friendly views from the canonical SysML packages.”[^3_10][^3_9]

Cowork uses a similar agentic architecture to Code, but oriented toward **knowledge work and file operations** rather than repo‑centric coding.[^3_2][^3_1][^3_9]

## How to integrate all three without tripping over yourself

A clean pattern for your context:

1. **Start in Chat (design phase)**
    - Explore options, decide on an approach, and draft / update governance and architecture docs.
    - From Chat, when you converge on “this is the change set,” explicitly define it as a short spec (requirements + constraints) and save it into the repo or a nearby `plans/` folder.
2. **Hand off to Claude Code (implementation phase)**
    - Open Code in the relevant repo directory.
    - Give it the spec file + the relevant governance docs (or reference `CLAUDE.md`) and say: “Implement this plan while respecting the architecture principles in `CLAUDE.md` and the safety constraints in `governance/safety.md`.”[^3_7][^3_6]
    - Let Code propose a plan, review diffs, run tests, and iterate until you’re happy.
3. **Use Cowork for cross‑repo and business artefacts**
    - When you want roll‑ups, reports, spreadsheets, or cross‑folder synthesis, start a Cowork task on the higher‑level folder that contains your journals, ADRs, SysML package exports, and business docs.[^3_1][^3_9][^3_5]
    - E.g. “From everything in `/model/` and `/governance/` and `/journals/2026-Q1`, produce: a stakeholder briefing deck, an internal technical change log, and an updated risk register.”
4. **Loop back to Chat for reflection and next‑phase design**
    - Once Code and/or Cowork have produced artefacts, bring them into Chat for higher‑order reflection, critique, and next‑step planning.
    - That keeps Chat as the “thinking and sense‑making” hub while offloading execution to the agentic modes.

### When to *not* add Code or Cowork

There are also cases where it’s simpler to stay with Chat only:[^3_11][^3_5]

- Short, contained feature changes or one‑file tweaks.
- Pure conceptual modelling where you’re not yet touching implementation artefacts.
- Sessions where the marginal overhead of setting up a Code or Cowork task outweighs the benefit (e.g. “five‑minute change”).


## Answering your “should I mainly stick to one?” question

Given your description and comfort level:

- You do **not** need to pick only one; choosing just Chat will keep working but leaves a lot of automation value on the table for implementation and operations.
- A pragmatic path would be:
    - Keep Chat as your default.
    - Introduce **Claude Code** *only* for bigger implementation phases (anything that touches multiple files, tests, and repos).
    - Experiment with **Cowork** for 1–2 recurring operational tasks (weekly synthesis, updating business artefacts), and only expand if it clearly reduces your manual glue work.[^3_9][^3_2]

From what you wrote, your intuition is exactly right: Chat for ideation and planning, Code for implementation, Cowork for business‑system operations and large, cross‑file syntheses.

Would it be most useful if we next designed a concrete “playbook” for one typical change cycle (e.g. “new assessment pathway” from SysML change through to code, docs, and governance) with explicit prompts for each of Chat, Code, and Cowork?
<span style="display:none">[^3_12][^3_13][^3_14][^3_15][^3_16][^3_17][^3_18]</span>

<div align="center">⁂</div>

[^3_1]: https://www.linkedin.com/pulse/claude-cowork-explained-what-how-runs-why-changes-knowledge-laboy-to17e

[^3_2]: https://fortelabs.com/blog/the-difference-between-claude-code-and-cowork/

[^3_3]: https://www.youtube.com/watch?v=TAXdDEZaR9U

[^3_4]: https://www.facebook.com/groups/vibecodinglife/posts/1975979689657225/

[^3_5]: https://awesomeclaude.ai/claude-cowork

[^3_6]: https://code.claude.com/docs/en/overview

[^3_7]: https://www.datacamp.com/tutorial/claude-code

[^3_8]: https://www.pluralsight.com/resources/blog/ai-and-data/what-is-claude-code

[^3_9]: https://support.claude.com/en/articles/13345190-get-started-with-cowork

[^3_10]: https://techysurgeon.substack.com/p/the-6-am-dispatch-how-i-use-claude

[^3_11]: https://www.reddit.com/r/ClaudeAI/comments/1reyaij/what_exactly_is_claude_cowork/

[^3_12]: https://www.youtube.com/watch?v=j9IwqqnTByk

[^3_13]: https://www.youtube.com/watch?v=ZeWfksNXlbU

[^3_14]: https://www.youtube.com/watch?v=_42sUaf037k

[^3_15]: https://ccforeveryone.com/cowork

[^3_16]: https://ccforpms.com/cowork

[^3_17]: https://www.datacamp.com/tutorial/claude-cowork-tutorial

[^3_18]: https://www.reddit.com/r/Anthropic/comments/1re3orh/claude_vs_claude_code_vs_claude_cowork_practical/


---

# Ok, can I 'chat' in Code and Cowork, including asking questions, or are they purely for giving instructions to do work that I have already scoped?

You can absolutely “chat” in both Code and Cowork; they’re not limited to pre‑scoped tasks, but the *style* of chat is a bit more work‑oriented than Desktop Chat.

## Can you ask open questions in Code?

Yes. Claude Code sessions are conversational, with a chat pane where you can:[^4_1][^4_2][^4_3]

- Ask general questions about the repo (“What is this service doing?”, “How do these SysML export scripts work?”).
- Brainstorm implementation options (“Should we represent this assessment pathway as separate bounded contexts or subdomains?”).
- Refine the plan before it starts editing files (“Show me your proposed steps and we’ll adjust them together.”).

The difference is: the conversation is **anchored to a project directory**, and Code is biased toward turning that conversation into concrete edits, commands, and tests.[^4_2][^4_1]

## Can you ask open questions in Cowork?

Yes. Cowork also presents a chat‑style interface where you can:[^4_4][^4_5][^4_6]

- Ask questions about your docs, slides, sheets, etc. (“Summarise our governance decisions so far,” “What open risks do you see?”).
- Iterate on analysis before/while running tasks (“Before you create the deck, tell me how you’d frame the clinical pathway changes.”).
- Adjust the scope of a run interactively (“Include the March journal files as well and re‑think the key themes.”).

Again, the bias is toward **multi‑step work on collections of files and apps**, but you can keep it conversational and exploratory as you go.[^4_5][^4_4]

## How is this different from Desktop Chat?

Desktop Chat is “pure” conversation where tools are optional and everything starts as a blank chat.[^4_7]
Code and Cowork are conversation *plus* opinionated scaffolding: default assumptions about context (project directory or workspace), typical plans, and task execution.[^4_8][^4_1][^4_4]

In practice for you:

- Use **Chat** for unbounded thinking and design, where you might not even know what artefacts are involved yet.
- Use **Code** when the conversation is mostly about “this repo, this model, these tests” and you’re ready to let Claude propose and execute concrete steps.
- Use **Cowork** when the conversation is about “this folder of docs / these business artefacts / these cross‑app resources” and you want synthesis or structured output.

You don’t have to arrive with a fully scoped task; it’s fine to start with “I’m thinking about X, given this repo/folder, can we explore options?” and then let the agent gradually move from Q\&A into action.

Given your description, a good pattern would be: start a phase in Desktop Chat, then when the conversation becomes implementation‑heavy in a repo, switch to Code; when it becomes “pull together and analyse all these docs/spreadsheets,” switch to Cowork.

Is there a specific phase in your current workflow (e.g. assessment pathway refactor, or weekly governance review) where you’d like me to suggest exact “starter prompts” for Code and Cowork?
<span style="display:none">[^4_10][^4_9]</span>

<div align="center">⁂</div>

[^4_1]: https://code.claude.com/docs/en/overview

[^4_2]: https://www.datacamp.com/tutorial/claude-code

[^4_3]: https://www.pluralsight.com/resources/blog/ai-and-data/what-is-claude-code

[^4_4]: https://www.linkedin.com/pulse/claude-cowork-explained-what-how-runs-why-changes-knowledge-laboy-to17e

[^4_5]: https://support.claude.com/en/articles/13345190-get-started-with-cowork

[^4_6]: https://awesomeclaude.ai/claude-cowork

[^4_7]: https://www.youtube.com/watch?v=TAXdDEZaR9U

[^4_8]: https://fortelabs.com/blog/the-difference-between-claude-code-and-cowork/

[^4_9]: https://www.perplexity.ai/help-center/en/articles/10354971-can-i-use-my-chatgpt-or-claude-ai-account-with-perplexity

[^4_10]: https://www.perplexity.ai/hub/blog/introducing-perplexity-computer


---

# I would like to make much more use of Hookmark across my desktop and projects. Can Claude help me do that effectively?

Yes, Claude can help you get a lot more value from Hookmark, but mostly by designing and systematising how *you* use it, rather than “driving” Hookmark directly (since Hookmark itself doesn’t expose a first‑class AI control surface yet).[^5_1][^5_2][^5_3]

## What Hookmark is really giving you

Hookmark is a system‑wide, bi‑directional linking and bookmarking layer across macOS apps: files, emails, web pages, tasks, notes, etc.[^5_2][^5_4][^5_1]
You can copy links, hook items together, and create “Hook to New” notes in Obsidian or other apps, all from a universal popup.[^5_5][^5_1][^5_2]

For your kind of work (SysML, business architecture, clinical and tech artefacts scattered across tools) the big value is: “everything relevant to this thing is one shortcut away, regardless of app.”[^5_4][^5_6][^5_2]

## How Claude can help you use Hookmark effectively

Claude can’t press Hookmark’s keyboard shortcuts, but it can design the *patterns* and artefacts that make Hookmark powerful:

1. **Design a linking ontology and conventions**
    - Claude can help you define naming conventions and link‑types: e.g. `Assessment Pathway ⟷ SysML package ⟷ Jira epics ⟷ Obsidian ADR ⟷ key papers ⟷ clinic SOP PDF`, and how those should be represented in Obsidian dashboards.[^5_7][^5_6][^5_2]
    - You can then use Hookmark to actually forge those links (copy link / hook to copied link) while Claude keeps the model coherent in docs and diagrams.
2. **Create Obsidian “hub” notes that assume Hookmark**
    - Claude can generate templates for project hubs, patient‑journey hubs, service hubs, etc., with sections like “Hooked artefacts: [insert links here]”.
    - You then use Hookmark’s Obsidian integration to drop in `obsidian://` or external URLs and keep everything navigable.[^5_8][^5_6][^5_9][^5_5]
3. **Integrate Hookmark with your PKM / SysML system design**
    - Claude can help you decide when something should become a Hookmark hook vs an Obsidian link vs a SysML reference (e.g. “link from SysML block → Obsidian note → Hookmark collection of external docs”).
    - That prevents link sprawl and keeps your “second brain” architecture intentional.
4. **Workflow scripts, checklists, and prompts**
    - For each recurring workflow (e.g. “new assessment pathway”, “new feature experiment”, “governance review”), Claude can design a short checklist that includes specific Hookmark actions: “Create Hook from ADR → design doc → Jira epic”, “Hook this email thread to the decision record”, etc.
    - Over time you can turn these into Claude prompts (“Apply the ‘assessment pathway’ linking checklist to this new work”) so it reminds you where to create hooks.
5. **Leverage Hookmark’s Obsidian integration choices**
    - Claude can help you evaluate which Obsidian URL scheme (default `obsidian://`, advanced URI, or hook file) best fits your architecture, then generate the frontmatter / UID conventions and migration scripts if needed.[^5_8][^5_5]
    - It can also refactor your notes to add the necessary UID fields for advanced URI linking.

## Where each Claude mode fits with Hookmark

- **Desktop Chat**
    - Design your linking strategy, conventions, Obsidian templates, and SysML ↔ docs ↔ Hookmark architecture.
    - Reflect on “is this link graph working?” using screenshots/snippets of your Hookmark context windows and note structures.
- **Claude Code**
    - If you store hook files or metadata inside an Obsidian vault or repo (Hookmark can keep hook files in a folder), Code can help refactor, audit, or generate them in bulk.[^5_7][^5_8]
    - It can also build helper tools (e.g. scripts that extract Hookmark links from markdown and validate them, or generate dashboards from hook metadata).
- **Cowork**
    - For cross‑app collections (“everything hooked to this project note, this folder, these PDFs”), Cowork can read those files and produce summaries, dashboards, or reports.
    - Example: run Cowork on a folder of Obsidian notes that are heavily Hookmarked to emails/docs, and ask it to produce a “project dossier” based on the linked materials.


## A concrete starting pattern

Given your stack (Obsidian + SysML + business docs + macOS):

- Ask Chat to help you define:
    - A small set of **hub note types** (project, pathway, service, stakeholder) and what should be hooked to each.
    - A naming and tagging scheme for Hookmark bookmarks and Obsidian notes.
- Implement that manually with Hookmark for one project.
- Then, if you like it, have Claude Code help you:
    - Scan your vault for existing notes and retrofit them to the new linking conventions.
    - Optionally generate helper scripts to list and check expected hooks.

That way Claude isn’t replacing Hookmark, but acting as the architect, spec‑writer, and refactor engine for how Hookmark fits your overall system.

Would you like to start by designing a small, opinionated “Hookmark + Obsidian + SysML” convention for a single assessment pathway project, and then generalise from there?
<span style="display:none">[^5_10][^5_11][^5_12][^5_13][^5_14][^5_15]</span>

<div align="center">⁂</div>

[^5_1]: https://hookproductivity.com

[^5_2]: https://hookproductivity.com/help/general/features/

[^5_3]: https://discourse.hookproductivity.com/t/hookmark-7-product-road-map-better-bookmarking-recommendations-ai-and-more/9423

[^5_4]: https://hookproductivity.com/help/integration/

[^5_5]: https://hookproductivity.com/help/integration/using-hook-with-obsidian/

[^5_6]: https://www.reddit.com/r/ObsidianMD/comments/1fgp1qq/linking_your_obsidianbased_thinking_with_hookmark/

[^5_7]: https://discourse.hookproductivity.com/t/using-hookmark-to-glue-together-my-custom-pkm/7194

[^5_8]: https://hookproductivity.com/help/integration/using-hook-with-obsidian/for-hook-3-4-3/

[^5_9]: http://www.robbyburns.com/blog/linking-together-data-across-many-apps-using-obsidian-and-hookmark

[^5_10]: https://hookproductivity.com/help/general/overview/

[^5_11]: https://hookproductivity.com/help/general/getting-started/

[^5_12]: https://apps.apple.com/gb/app/hookmark-pal/id1521721999

[^5_13]: https://www.youtube.com/watch?v=36X0LxAhfNU

[^5_14]: https://www.youtube.com/watch?v=2E610yzqQwg

[^5_15]: https://capacities.io/blog/better-linking-with-hookmark


---

# How can Claude help me make better use of Excalidraw, either within Obsidian, or outside of Obsidian?

Claude can’t “draw” inside Excalidraw directly yet, but it can massively upgrade how you *use* Excalidraw as part of your thinking and system design, especially via Obsidian.[^6_1][^6_2][^6_3]

## 1. Inside Obsidian: diagrams as first‑class system artefacts

With the Obsidian‑Excalidraw plugin, your `.excalidraw.md` files sit in the vault with front‑matter, tags, embeds, and links.[^6_4][^6_1]
Claude can help you treat these diagrams as structured system artefacts instead of ad‑hoc sketches.

Ways Claude helps:

- Design diagram **types and conventions**
    - Ask Claude to define a small set of diagram patterns: “assessment pathway storyboard”, “service interaction diagram”, “business capability map”, “SysML view sketch”, each with constraints on shapes, colours, labels, and layering.
    - Claude can generate Excalidraw template descriptions and the corresponding Obsidian front‑matter/tagging schemes so each drawing type is recognisable and machine‑queriable.[^6_1][^6_4]
- Turn text notes into diagram plans
    - Start in text: describe a workflow, domain model, or system interaction in a bullet list.
    - Ask Claude to transform that into an explicit Excalidraw layout spec: “top‑left: patient; right: triage service; arrows; labels; swimlanes,” etc., that you then quickly sketch following the spec.
    - Over time you can standardise these as prompt → layout patterns for repeated use.
- Make Excalidraw a hub in your graph
    - The plugin supports links and markdown embeds in both directions.[^6_1]
    - Claude can help you define rules like: every core concept gets (a) an Obsidian concept note, (b) optionally a canonical Excalidraw visual, and (c) links between them plus related ADRs, SysML model exports, and governance docs.
    - This lets you treat Excalidraw diagrams as the visual “front” for clusters of text and model artefacts.
- Maintain and refactor the ecosystem
    - Because Excalidraw drawings are stored as markdown with JSON in them, you can have Claude Code scan and refactor front‑matter, tags, and embedding patterns at scale (e.g. “mark which diagrams are canonical, deprecated, or draft”).[^6_1]
    - Claude can also design scripts that extract metadata from your `.excalidraw.md` files to build visual indexes or dashboards.


## 2. Outside Obsidian: whiteboard as modelling scratchpad

In the browser or Excalidraw+ you have collaborative boards, frames, and presentations.[^6_5][^6_3][^6_6]
Claude can help before and after the drawing session.

Before / during:

- Pre‑structure sessions
    - Ask Claude to design a whiteboard layout for a meeting: zones for “goals”, “constraints”, “actors”, “flows”, “open questions”, and “decisions”.
    - You then drop those onto the Excalidraw canvas so you’re not starting from an empty board.
- Generate element libraries
    - Claude can help you define small libraries of reusable shapes and labels for your domain (patient states, clinic services, platform components, governance artefact types) which you then implement as Excalidraw libraries or copy‑paste patterns.[^6_7]

After:

- Turn drawings back into structured artefacts
    - You export the board (image or JSON) and describe it, or share a screenshot.
    - Claude can: summarise decisions, extract entities and relationships, translate them into SysML elements, or generate corresponding ADRs / stories.
    - With discipline, that means every “messy” board gets folded back into your formal system model and docs.
- Whiteboard‑to‑text pipelines
    - You can adopt a standard: after each diagramming session, paste a short textual description + maybe OCR of key labels into Claude and ask it to generate:
        - a domain model change list
        - updated system descriptions
        - a change log / journal entry
        - a checklist of follow‑up modelling and implementation actions.


## 3. AI‑assisted diagram generation (emerging options)

There are already workflows and tools that generate Excalidraw scenes from structured descriptions or other inputs.[^6_8][^6_9][^6_10]

Claude can sit at the “specification” layer:

- From prose or models to diagram specs
    - You describe relationships in text or show SysML elements.
    - Claude produces a JSON‑ish or declarative description that a converter or script can turn into Excalidraw elements (nodes, connectors, positions).
    - With Claude Code, you can build small tools that take Claude’s output and create `.excalidraw` files in your repo, so diagrams are generated alongside code and models.[^6_9][^6_10][^6_8]
- From screenshots/whiteboards to structured descriptions
    - If you snapshot a physical whiteboard or messy Excalidraw, Claude can help transcribe and structure it, which you then convert into cleaner diagrams via reusable scripts or manual redrawing.
    - That’s similar in spirit to the whiteboard‑to‑Excalidraw agent workflows people are building.[^6_9]


## 4. How to integrate with your current stack

Given your SysML + Obsidian + governance system:

- Use **Desktop Chat** to:
    - Define diagram types, conventions, and templates.
    - Translate between diagrams and SysML viewpoints (“for this Excalidraw, what are the corresponding blocks/activities/requirements?”).
    - Generate summarising text and follow‑up tasks from diagrams.
- Use **Claude Code** to:
    - Manage `.excalidraw.md` files as part of repos (rename, re‑tag, migrate, validate).
    - Build helper tools: e.g. scripts that scan diagrams, link them into README files, or enforce “every service has at least one visual overview”.
- (Optionally later) Use **Cowork** to:
    - Sweep folders containing Excalidraw exports and related notes to produce decks, briefings, or multi‑view syntheses for stakeholders.

A simple first experiment: pick one active assessment pathway, decide on a canonical “visual grammar” for it with Claude, create 1–2 Excalidraw templates in Obsidian based on that, and then have Claude help you consistently derive SysML and text artefacts from those diagrams over a week or two.

Would you like a concrete set of prompts + one Excalidraw template description for something like “Assessment Pathway Overview” to try this out immediately?
<span style="display:none">[^6_11][^6_12][^6_13][^6_14][^6_15]</span>

<div align="center">⁂</div>

[^6_1]: https://github.com/zsviczian/obsidian-excalidraw-plugin

[^6_2]: https://forum.obsidian.md/t/excalidraw-full-featured-sketching-plugin-in-obsidian/17367

[^6_3]: https://excalidraw.com

[^6_4]: https://excalidraw-obsidian.online/wiki/settings

[^6_5]: https://forum.effectivealtruism.org/posts/iKes4JjvpLM8LKMyT/excalidraw-why-and-how-to-use-it

[^6_6]: https://plus.excalidraw.com/use-cases/presentations

[^6_7]: https://plus.excalidraw.com/use-cases/game-design

[^6_8]: https://www.youtube.com/watch?v=AORfk6-HARE

[^6_9]: https://mastra.ai/blog/whiteboard-to-excalidraw-converter

[^6_10]: https://www.oreateai.com/blog/ai-drawing-that-frees-your-hands-three-ways-to-achieve-automated-excalidraw-chart-generation/fd3caf45cd40afc12031ff96c55b42b2

[^6_11]: https://www.reddit.com/r/ObsidianMD/comments/1h8zvmm/excalidraw_plugin_how_do_you_use_it/

[^6_12]: https://www.youtube.com/watch?v=P_Q6avJGoWI

[^6_13]: https://www.youtube.com/watch?v=pfgUbDxfMtQ

[^6_14]: https://discourse.joplinapp.org/t/obsidian-excalidraw-plugin-a-plugin-to-edit-and-view-excalidraw-drawings-in/39508

[^6_15]: https://www.youtube.com/watch?v=xmqiBTrlbEM


---

# We have used Mermaid to visualise pathways and modelled entities programmatically. How might I maximise or optimise using Claude to make the most use of this? What other comparable or better approaches are there to programmatic diagram, illustration generation on a systematic basis?

You can turn Mermaid into a “diagrams‑as‑code” surface that Claude helps design, generate, and keep consistent; there are also a few other notations worth adding alongside it.[^7_1][^7_2][^7_3][^7_4]

## Maximising Mermaid with Claude

For your pathways and entities, the key is to make Mermaid a formal projection of the underlying model, not a one‑off sketch.

Ways to use Claude more systematically:[^7_2][^7_4][^7_5][^7_6]

- From model → Mermaid
    - Give Claude a structured description (SysML elements, YAML/JSON of entities, or a table in markdown) and ask it to emit canonical Mermaid: flowcharts for pathways, ER/class diagrams for entities, sequence diagrams for interactions, state diagrams for patient or service states.
    - Standardise prompts (“Given this block definition, emit a Mermaid class diagram following our conventions”) so generation is repeatable.
- From prose → Mermaid (for exploratory work)
    - Paste a narrative of a clinical or business flow and have Claude draft a Mermaid `graph`, `sequenceDiagram`, or `stateDiagram` snippet, which you then refine manually.[^7_5][^7_2]
    - Keep a small library of “good” examples so Claude learns your house style.
- Round‑trip edits
    - When you change the underlying model or requirements, ask Claude to diff the old Mermaid vs the new model description and regenerate updated diagrams, rather than editing them by hand.
    - Because Mermaid is plain text, this fits well with Git; Claude Code can handle refactors across many `.md` files.
- Consistency checks
    - Periodically have Claude Code scan your repo/vault for Mermaid blocks and compare them with source definitions (e.g. entities in a schema, SysML exports) to identify inconsistencies or missing diagrams.[^7_4][^7_2]
    - Use this to enforce “every key pathway/entity has at least one diagram, and diagrams match current definitions.”


## Other programmatic diagram approaches

There are several complementary options you can combine with Mermaid.

### PlantUML and friends

PlantUML is more feature‑rich and detailed than Mermaid, with strong UML coverage (class, sequence, state, component, etc.).[^7_3][^7_7]

- Pros with Claude: more expressive for full UML, better for complex, formal diagrams; AI can generate the code quite well because it’s structured text.[^7_2][^7_3][^7_4]
- Cons: steeper syntax, slightly less “markdown‑native” than Mermaid; integration in Obsidian is possible but not as frictionless as Mermaid in many setups.[^7_7][^7_3]

You can use Mermaid for lightweight pathway overviews and PlantUML for more formal architecture or API diagrams, still generated by Claude from the same underlying model descriptions.

### D2, Graphviz, Structurizr

- **D2**: modern text‑to‑diagram language; good for architecture and system overviews, works well with AI because of concise syntax.[^7_8]
- **Graphviz/DOT**: excellent for algorithmic or graph‑heavy views (dependency graphs, state transitions), where you may want Claude to generate DOT and let Graphviz handle layout.[^7_8]
- **Structurizr**: C4‑model‑oriented; you define model plus views as code, then render diagrams, and LLMs can help maintain those definitions.[^7_4]

These are especially relevant if you want tighter alignment with C4 and architecture viewpoints alongside SysML.

### AI‑enhanced diagram tools

There is a wave of tools that take text and generate Mermaid/PlantUML/Excalidraw for you.[^7_9][^7_10][^7_11][^7_6]

- Some (like Eraser, AI Diagram Maker, DiagrammingAI) generate Mermaid/PlantUML/Graphviz/D2 from natural language and let you edit the code.[^7_10][^7_11][^7_9]
- Excalidraw+ itself now has “text to diagram” features; you can use Claude to refine the textual spec and then feed it into that tool.[^7_12]

You can treat Claude as the spec writer and reviewer, and these tools as renderers.

## A systematic pattern for you

Given your SysML and pathway work, a layered approach makes sense:[^7_3][^7_2][^7_4]

- Canonical model: SysMLv2 and/or structured definitions (YAML/JSON/domain code).
- Diagram surfaces:
    - Mermaid for quick, embedded views in markdown/Obsidian and docs.
    - PlantUML or D2 for richer architecture/UML where needed.
    - Excalidraw for exploratory / stakeholder‑friendly visuals, possibly generated from the same descriptions.
- Claude’s role:
    - Generate and refactor diagram code from the canonical model.
    - Enforce conventions (naming, layering, colours, layout patterns) across all diagrams.
    - Maintain “diagrams‑as‑code” side‑by‑side with your implementation repo and SysML, via Claude Code.

That gives you multiple visual projections of the same underlying system, but with Claude keeping the text definitions and diagrams coherent over time.

Would it help if I sketched a concrete minimal “diagram grammar” for one assessment pathway (Mermaid + maybe one richer notation) and the exact prompts you’d use with Claude to generate and maintain them from your SysML blocks?
<span style="display:none">[^7_13][^7_14][^7_15]</span>

<div align="center">⁂</div>

[^7_1]: https://mermaid.js.org

[^7_2]: https://addjam.com/blog/2025-03-31/ai-llm-system-design-uml-diagrams/

[^7_3]: https://www.gleek.io/blog/mermaid-vs-plantuml

[^7_4]: https://jacquiread.com/services/training/diagrams-as-code-with-ai/

[^7_5]: https://www.youtube.com/watch?v=PCZ3mPm141s

[^7_6]: https://www.youtube.com/watch?v=RU43gmmQ6Z0

[^7_7]: https://www.reddit.com/r/ExperiencedDevs/comments/1k7ki6k/plantuml_vs_mermaid/

[^7_8]: https://text-to-diagram.com

[^7_9]: https://www.eraser.io/ai/mermaid-diagram-editor

[^7_10]: https://workspace.google.com/marketplace/app/ai_diagram_maker_create_diagrams_with_ai/208081298936

[^7_11]: https://diagrammingai.com

[^7_12]: https://plus.excalidraw.com/use-cases/software-architecture-diagram

[^7_13]: https://arxiv.org/abs/2511.14967

[^7_14]: https://news.ycombinator.com/item?id=43559917

[^7_15]: https://dev.to/aairom/fun-project-of-the-week-mermaid-flowcharts-generator-1416

