---
name: commit
description: Stage and commit changes with Ontara session-number convention
allowed-tools: Bash
---

# Git Commit with Session Convention

Ontara commits reference the session number in the message.

## Usage

`/commit <session-number> <description>`

Example: `/commit 61 Add weighted relationship graph to console`

## Steps

1. Show current status:
   ```bash
   git status
   ```

2. Show a summary of changes (files changed, insertions, deletions):
   ```bash
   git diff --stat
   ```

3. Present the proposed commit to Ella for review. Do NOT commit without her confirmation.

4. Once confirmed, stage and commit:
   ```bash
   git add -A
   git commit -m "Session $1: $2"
   ```

5. Remind Ella to push when ready: `git push origin main`

## Notes

- Never force-push.
- Never commit without showing Ella what will be committed first.
- Generated files under `generated/` should be committed — they are part of the deliverable.
- `console/node_modules/` and `.svelte-kit/` are gitignored.
