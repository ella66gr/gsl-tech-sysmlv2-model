# Vault Housekeeping Sweep — Session 230
## Code Instruction Set

**Purpose:** Mechanical find-and-replace sweep for known stale references across the live vault. All items are well-specified with zero ambiguity. No judgement calls required.

**Vault root:** `/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/`
**Exclude:** `07 Ontara History & Archive/`

**Source:** W-061 findings F38, F39, F42, F43, F44–F57, F59, F63, F64.

---

## Task 1 — Concept note Source-section version drift (F44–F57)

Replace stale foundation-paper version attributions in concept note Source sections. These are mechanical substitutions — the note bodies are already current; only the attribution lines are stale.

### Step 1a — Audit

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "Service Business Meta Modelling (v3\.1)" \
  -e "Service Business Meta Modelling v2" \
  -e "SysML Modelling Strategy v2" \
  -e "Platform Modelling Strategy (v4\.1)" \
  . > /tmp/s230-version-drift-audit.txt

cat /tmp/s230-version-drift-audit.txt
```

Review output. Expected hits: concept notes F44–F57, principle notes F57–F58 (body text of F58 requires manual attention — see Task 5). Confirm before proceeding.

### Step 1b — Replace

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

FILES=$(find . -name "*.md" \
  -not -path "./07 Ontara History & Archive/*")

echo "$FILES" | while read f; do
  sed -i '' \
    -e 's/Service Business Meta Modelling (v3\.1)/Service Business Meta Modelling (v4)/g' \
    -e 's/Service Business Meta Modelling v2 §9/Service Business Meta Modelling (v4) §5.7/g' \
    -e 's/SysML Modelling Strategy v2/Platform Modelling Strategy (v5)/g' \
    -e 's/Platform Modelling Strategy (v4\.1)/Platform Modelling Strategy (v5)/g' \
    "$f"
done
```

### Step 1c — Verify zero hits

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "Service Business Meta Modelling (v3\.1)" \
  -e "Service Business Meta Modelling v2" \
  -e "SysML Modelling Strategy v2" \
  -e "Platform Modelling Strategy (v4\.1)" \
  .
```

Expected: no results.

---

## Task 2 — AP5 and PMS5 stale forward-references (F38, F39)

Two targeted fixes in the foundations papers themselves.

**F38** — Architecture Principles v5 Related Documents section describes PMS as "v5 in preparation" and SBMM as "v4 in preparation / Currently at v3.1".

**F39** — Platform Modelling Strategy v5 Related Documents section describes SBMM as "(v3.1) … v4 pending (W-049 remainder)".

### Step 2a — Locate the lines

```bash
grep -n "in preparation\|v4 pending\|Currently at v3" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/04 Ontara Architecture/ontara-architecture-platform-principles.md" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/04 Ontara Architecture/ontara-architecture-platform-modelling-strategy.md"
```

Review exact wording before editing.

### Step 2b — Fix AP5

Open `ontara-architecture-platform-principles.md` and in the Related Documents section update the PMS and SBMM references to reflect current versions:
- PMS: `[[ontara-architecture-platform-modelling-strategy|Platform Modelling Strategy (v5)]]`
- SBMM: `[[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v4)]]`

Remove any "in preparation" or "Currently at v3.1" qualifiers.

Bump frontmatter `session:` to `230` and `date:` to `2026-04-16` if not already current.

### Step 2c — Fix PMS5

Open `ontara-architecture-platform-modelling-strategy.md` and in the Related Documents section update the SBMM reference:
- SBMM: `[[ontara-architecture-business-meta-modelling|Service Business Meta Modelling (v4)]]`

Remove any "v3.1", "v4 pending", or "W-049 remainder" qualifiers.

Bump frontmatter `session:` to `230` and `date:` to `2026-04-16` if not already current.

---

## Task 3 — Register count drift (F42, F43, F63)

Replace stale concept count figures. Current authoritative count is ~232.

### Step 3a — Audit

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "~212 concepts" \
  -e "~220+ concepts" \
  -e "~220 concepts" \
  .
```

### Step 3b — Replace

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

FILES=$(find . -name "*.md" \
  -not -path "./07 Ontara History & Archive/*")

echo "$FILES" | while read f; do
  sed -i '' \
    -e 's/~212 concepts/~232 concepts/g' \
    -e 's/~220+ concepts/~232 concepts/g' \
    -e 's/~220 concepts/~232 concepts/g' \
    "$f"
done
```

### Step 3c — Verify

```bash
cd "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA"

grep -rn \
  --include="*.md" \
  --exclude-dir="07 Ontara History & Archive" \
  -e "~212 concepts" \
  -e "~220" \
  .
```

Expected: no results.

---

## Task 4 — Workflow guide version reference in Architecture Papers Index (F64)

Single targeted fix: the Architecture Papers Index lists "Development Workflow Guide (v2)" — should be v3.

### Step 4a — Locate

```bash
grep -n "Workflow Guide (v2)\|workflow guide (v2)\|Workflow Guide v2" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/—— ARCHITECTURE INDEX ——.md"
```

### Step 4b — Fix

```bash
sed -i '' \
  's/Workflow Guide (v2)/Workflow Guide (v3)/g' \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/—— ARCHITECTURE INDEX ——.md"
```

Bump frontmatter `session:` to `230` and `date:` to `2026-04-16` in the Architecture Papers Index.

### Step 4c — Verify

```bash
grep -n "Workflow Guide" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/01 —— START HERE ——/—— ARCHITECTURE INDEX ——.md"
```

Expected: v3 only.

---

## Task 5 — domain-suds "five concerns" → "six concerns" (F59)

Single targeted fix in `domain-suds.md`.

### Step 5a — Locate

```bash
grep -n "five.*concern\|five BMM" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/05 Ontara Demonstrators/domain-suds.md"
```

### Step 5b — Fix

```bash
sed -i '' \
  's/All five BMM concerns instantiated/All six BMM concerns instantiated/g' \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/05 Ontara Demonstrators/domain-suds.md"
```

If the exact phrasing differs from the above, edit manually to correct "five" → "six" in the specific sentence identified in Step 5a.

Bump frontmatter `session:` to `230` and `date:` to `2026-04-16` in `domain-suds.md`.

### Step 5c — Verify

```bash
grep -n "concern" \
  "/Users/ellagreen/Obsidian/GenderSense/02 ONTARA/05 Ontara Demonstrators/domain-suds.md"
```

Confirm the sentence now reads six concerns.

---

## Not in scope for this instruction set (requires judgement)

- **F58** (`principle-two-meta-model-distinction.md` body) — "36 part defs" claim is a pre-SBMM-v4 articulation requiring a considered rewrite, not sed. Handle in a future Chat session.
- **W-062/063/064 TLA migrations** — prose-care requirement makes mechanical substitution unsafe. Handle per tracker.

---

## Post-execution checklist

- [ ] Task 1 — Step 1c shows zero hits
- [ ] Task 2 — AP5 and PMS5 Related Documents updated and frontmatter bumped
- [ ] Task 3 — Step 3c shows zero hits
- [ ] Task 4 — Architecture Papers Index shows v3 only and frontmatter bumped
- [ ] Task 5 — domain-suds shows six concerns and frontmatter bumped
- [ ] Report any unexpected hits or manual corrections made

---

*Produced S230. Sources: W-061 Part 2 findings F38, F39, F42, F43, F44–F57, F59, F63, F64.*
