# W-077 — Vault-Wide Wikilink Stub Sweep
## Code Instruction Set

**Purpose:** Replace all broken wikilink stubs referencing the two renamed foundations papers across the live vault. Excludes the archive folder.

**Vault root:** `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/`
**Exclude:** `07 Ontara History & Archive/`

---

## Background

Two foundations paper files were renamed in Obsidian at S230:

| Old filename | New filename |
|---|---|
| `ontara-architecture (pms) platform-modelling-strategy.md` | `ontara-architecture-platform-modelling-strategy.md` |
| `ontara-architecture (sbmm) service-business-meta-modelling.md` | `ontara-architecture-business-meta-modelling.md` |

Obsidian auto-updated links to these files at rename time. However, some wikilinks were already broken *before* the rename (pointing at stubs that never matched the old filenames either). These were not updated by Obsidian and must be corrected manually.

---

## Target stubs to find and replace

### Group 1 — PMS stubs (replace with `ontara-architecture-platform-modelling-strategy`)

These stubs are broken and must be replaced:

| Broken stub | Replacement |
|---|---|
| `ontara-architecture (pms) platform-modelling-strategy` | `ontara-architecture-platform-modelling-strategy` |
| `ontara-architecture-platform-modelling-strategy (pms)` | `ontara-architecture-platform-modelling-strategy` |

Note: `ontara-architecture-platform-modelling-strategy` without any qualifier is already correct — do not touch it.

### Group 2 — SBMM stubs (replace with `ontara-architecture-business-meta-modelling`)

These stubs are broken and must be replaced:

| Broken stub | Replacement |
|---|---|
| `ontara-architecture (sbmm) service-business-meta-modelling` | `ontara-architecture-business-meta-modelling` |
| `ontara-architecture-business-meta-modelling (sbmm)` | `ontara-architecture-business-meta-modelling` |
| `ontara-architecture-service-business-meta-modelling` | `ontara-architecture-business-meta-modelling` |

Note: `ontara-architecture-business-meta-modelling` without any qualifier is already correct — do not touch it.

---

## Execution steps

### Step 1 — Audit (grep, no edits)

Run a grep across the live vault to find all occurrences of broken stubs. Output to a findings file for review before any edits are made.

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "ontara-architecture (pms) platform-modelling-strategy" \
  -e "ontara-architecture-platform-modelling-strategy (pms)" \
  -e "ontara-architecture (sbmm) service-business-meta-modelling" \
  -e "ontara-architecture-business-meta-modelling (sbmm)" \
  -e "ontara-architecture-service-business-meta-modelling" \
  . > /tmp/w077-broken-stubs-audit.txt

cat /tmp/w077-broken-stubs-audit.txt
```

Review the output. Confirm the hit list looks reasonable before proceeding to Step 2.

### Step 2 — Replace (sed, in-place)

Run sed substitutions across the same scope. Each substitution is targeted — only the broken stubs are replaced.

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

# Find all .md files excluding archive
FILES=$(find . -name "*.md" \
  -not -path "./07 Ontara History & Archive/*" \
  -not -path "./.DS_Store")

# Apply substitutions
echo "$FILES" | while read f; do
  sed -i '' \
    -e 's/ontara-architecture (pms) platform-modelling-strategy/ontara-architecture-platform-modelling-strategy/g' \
    -e 's/ontara-architecture-platform-modelling-strategy (pms)/ontara-architecture-platform-modelling-strategy/g' \
    -e 's/ontara-architecture (sbmm) service-business-meta-modelling/ontara-architecture-business-meta-modelling/g' \
    -e 's/ontara-architecture-business-meta-modelling (sbmm)/ontara-architecture-business-meta-modelling/g' \
    -e 's/ontara-architecture-service-business-meta-modelling/ontara-architecture-business-meta-modelling/g' \
    "$f"
done
```

### Step 3 — Verify (grep, confirm zero hits)

Re-run the audit grep to confirm all broken stubs are gone.

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "ontara-architecture (pms) platform-modelling-strategy" \
  -e "ontara-architecture-platform-modelling-strategy (pms)" \
  -e "ontara-architecture (sbmm) service-business-meta-modelling" \
  -e "ontara-architecture-business-meta-modelling (sbmm)" \
  -e "ontara-architecture-service-business-meta-modelling" \
  .
```

Expected output: no results. If any hits remain, inspect and correct manually.

### Step 4 — Spot-check correct stubs (confirm replacements landed)

Confirm the correct stubs are present and resolving:

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "ontara-architecture-platform-modelling-strategy" \
  -e "ontara-architecture-business-meta-modelling" \
  . | head -40
```

Review a sample of hits to confirm they look correct in context.

---

## Post-execution

- Report findings from Step 1 audit (count of broken stubs found, files affected)
- Confirm Step 3 shows zero hits
- Note any manual corrections made
- W-077 can be closed in the tracker once Step 3 is clean

---

*Produced S230. Workstream W-077.*
