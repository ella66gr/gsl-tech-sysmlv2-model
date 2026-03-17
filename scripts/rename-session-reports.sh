#!/bin/bash
# GSL Session Report Renaming Script — v2 (recovery-safe)
# 
# Run from: ~/Developer/gsl-tech/gsl-sysml-model
# After: git checkout -- documentation/session-reports/

set -euo pipefail

REPO="$HOME/Developer/gsl-tech/gsl-sysml-model"
HIST="$REPO/documentation/session-reports/session history"
CURR="$REPO/documentation/session-reports"
TMP="$HIST/.rename-staging"

echo "=== Step 1: Clean staging directory and start fresh ==="
rm -rf "$TMP"
mkdir -p "$TMP"
echo "  Clean staging directory created"

echo ""
echo "=== Step 2: Copy all originals to staging with new names ==="

# Pre-session (March 5)
cp "$HIST/gsl-session-report-2026-03-05-s1.md"    "$TMP/gsl-session-report-2026-03-05-s00.md"

# March 6 — per-day s1,s2,s3 → global s01,s02,s03
cp "$HIST/gsl-session-report-2026-03-06-s1.md"    "$TMP/gsl-session-report-2026-03-06-s01.md"
cp "$HIST/gsl-session-report-2026-03-06-s2.md"    "$TMP/gsl-session-report-2026-03-06-s02.md"
cp "$HIST/gsl-session-report-2026-03-06-s3.md"    "$TMP/gsl-session-report-2026-03-06-s03.md"

# March 7 — per-day s1,s2,s3,s4 → global s04,s05,s06,s07
cp "$HIST/gsl-session-report-2026-03-07-s1.md"    "$TMP/gsl-session-report-2026-03-07-s04.md"
cp "$HIST/gsl-session-report-2026-03-07-s2.md"    "$TMP/gsl-session-report-2026-03-07-s05.md"
cp "$HIST/gsl-session-report-2026-03-07-s3.md"    "$TMP/gsl-session-report-2026-03-07-s06.md"
cp "$HIST/gsl-session-report-2026-03-07-s4.md"    "$TMP/gsl-session-report-2026-03-07-s07.md"

# March 8 — old s5,s6,s7,s8 → global s08,s09,s10,s11
cp "$HIST/gsl-session-report-2026-03-08-s5.md"    "$TMP/gsl-session-report-2026-03-08-s08.md"
cp "$HIST/gsl-session-report-2026-03-08-s6.md"    "$TMP/gsl-session-report-2026-03-08-s09.md"
cp "$HIST/gsl-session-report-2026-03-08-s7.md"    "$TMP/gsl-session-report-2026-03-08-s10.md"
cp "$HIST/gsl-session-report-2026-03-08-s8.md"    "$TMP/gsl-session-report-2026-03-08-s11.md"

# March 9 — old s9,s10,s11,s12 → global s12,s13,s14,s15
cp "$HIST/gsl-session-report-2026-03-09-s9.md"    "$TMP/gsl-session-report-2026-03-09-s12.md"
cp "$HIST/gsl-session-report-2026-03-09-s10.md"   "$TMP/gsl-session-report-2026-03-09-s13.md"
cp "$HIST/gsl-session-report-2026-03-09-s11.md"   "$TMP/gsl-session-report-2026-03-09-s14.md"
cp "$HIST/gsl-session-report-2026-03-09-s12.md"   "$TMP/gsl-session-report-2026-03-09-s15.md"

# March 10 — old s13,s14 → global s16,s17
cp "$HIST/gsl-session-report-2026-03-10-s13.md"   "$TMP/gsl-session-report-2026-03-10-s16.md"
cp "$HIST/gsl-session-report-2026-03-10-s14.md"   "$TMP/gsl-session-report-2026-03-10-s17.md"

# March 11 — old s15,s16,s17,s18-1,s18-2,s19 → global s18,s19,s20,s21a,s21,s22
cp "$HIST/gsl-session-report-2026-03-11-s15.md"   "$TMP/gsl-session-report-2026-03-11-s18.md"
cp "$HIST/gsl-session-report-2026-03-11-s16.md"   "$TMP/gsl-session-report-2026-03-11-s19.md"
cp "$HIST/gsl-session-report-2026-03-11-s17.md"   "$TMP/gsl-session-report-2026-03-11-s20.md"
cp "$HIST/gsl-session-report-2026-03-11-s18-1.md" "$TMP/gsl-session-report-2026-03-11-s21a.md"
cp "$HIST/gsl-session-report-2026-03-11-s18-2.md" "$TMP/gsl-session-report-2026-03-11-s21.md"
cp "$HIST/gsl-session-report-2026-03-11-s19.md"   "$TMP/gsl-session-report-2026-03-11-s22.md"

# March 12 — old s20,s21,s22,s23 → global s23,s24,s25,s26
cp "$HIST/gsl-session-report-2026-03-12-s20.md"   "$TMP/gsl-session-report-2026-03-12-s23.md"
cp "$HIST/gsl-session-report-2026-03-12-s21.md"   "$TMP/gsl-session-report-2026-03-12-s24.md"
cp "$HIST/gsl-session-report-2026-03-12-s22.md"   "$TMP/gsl-session-report-2026-03-12-s25.md"
cp "$HIST/gsl-session-report-2026-03-12-s23.md"   "$TMP/gsl-session-report-2026-03-12-s26.md"

# March 13 — old s24 → global s27
cp "$HIST/gsl-session-report-2026-03-13-s24.md"   "$TMP/gsl-session-report-2026-03-13-s27.md"

# March 14 — old s25,s26,s27,s28,s29 → global s28,s29,s30,s31,s32
cp "$HIST/gsl-session-report-2026-03-14-s25.md"   "$TMP/gsl-session-report-2026-03-14-s28.md"
cp "$HIST/gsl-session-report-2026-03-14-s26.md"   "$TMP/gsl-session-report-2026-03-14-s29.md"
cp "$HIST/gsl-session-report-2026-03-14-s27.md"   "$TMP/gsl-session-report-2026-03-14-s30.md"
cp "$HIST/gsl-session-report-2026-03-14-s28.md"   "$TMP/gsl-session-report-2026-03-14-s31.md"
cp "$HIST/gsl-session-report-2026-03-14-s29.md"   "$TMP/gsl-session-report-2026-03-14-s32.md"

# March 15 — old s30 → global s33 (in history)
cp "$HIST/gsl-session-report-2026-03-15-s30.md"   "$TMP/gsl-session-report-2026-03-15-s33.md"

# March 15 — old s31 → global s34 (top-level current report)
cp "$CURR/gsl-session-report-2026-03-15-s31.md"   "$TMP/gsl-session-report-2026-03-15-s34.md"

STAGED=$(ls -1 "$TMP"/gsl-session-report-*.md | wc -l | tr -d ' ')
echo "  Staged $STAGED files"

if [ "$STAGED" -ne 36 ]; then
  echo "  ⚠️  Expected 36 staged files, got $STAGED. Aborting."
  exit 1
fi

echo ""
echo "=== Step 3: Remove all originals ==="

rm -f "$HIST"/gsl-session-report-2026-03-05-s1.md
rm -f "$HIST"/gsl-session-report-2026-03-06-s1.md
rm -f "$HIST"/gsl-session-report-2026-03-06-s2.md
rm -f "$HIST"/gsl-session-report-2026-03-06-s3.md
rm -f "$HIST"/gsl-session-report-2026-03-07-s1.md
rm -f "$HIST"/gsl-session-report-2026-03-07-s2.md
rm -f "$HIST"/gsl-session-report-2026-03-07-s3.md
rm -f "$HIST"/gsl-session-report-2026-03-07-s4.md
rm -f "$HIST"/gsl-session-report-2026-03-08-s5.md
rm -f "$HIST"/gsl-session-report-2026-03-08-s6.md
rm -f "$HIST"/gsl-session-report-2026-03-08-s7.md
rm -f "$HIST"/gsl-session-report-2026-03-08-s8.md
rm -f "$HIST"/gsl-session-report-2026-03-09-s9.md
rm -f "$HIST"/gsl-session-report-2026-03-09-s10.md
rm -f "$HIST"/gsl-session-report-2026-03-09-s11.md
rm -f "$HIST"/gsl-session-report-2026-03-09-s12.md
rm -f "$HIST"/gsl-session-report-2026-03-10-s13.md
rm -f "$HIST"/gsl-session-report-2026-03-10-s14.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s15.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s16.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s17.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s18-1.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s18-2.md
rm -f "$HIST"/gsl-session-report-2026-03-11-s19.md
rm -f "$HIST"/gsl-session-report-2026-03-12-s20.md
rm -f "$HIST"/gsl-session-report-2026-03-12-s21.md
rm -f "$HIST"/gsl-session-report-2026-03-12-s22.md
rm -f "$HIST"/gsl-session-report-2026-03-12-s23.md
rm -f "$HIST"/gsl-session-report-2026-03-13-s24.md
rm -f "$HIST"/gsl-session-report-2026-03-14-s25.md
rm -f "$HIST"/gsl-session-report-2026-03-14-s26.md
rm -f "$HIST"/gsl-session-report-2026-03-14-s27.md
rm -f "$HIST"/gsl-session-report-2026-03-14-s28.md
rm -f "$HIST"/gsl-session-report-2026-03-14-s29.md
rm -f "$HIST"/gsl-session-report-2026-03-15-s30.md
rm -f "$CURR"/gsl-session-report-2026-03-15-s31.md

echo "  Originals removed"

echo ""
echo "=== Step 4: Move staged files to final locations ==="

for f in "$TMP"/gsl-session-report-*.md; do
  basename=$(basename "$f")
  if [ "$basename" = "gsl-session-report-2026-03-15-s34.md" ]; then
    mv "$f" "$CURR/$basename"
  else
    mv "$f" "$HIST/$basename"
  fi
done

echo "  Files moved"

echo ""
echo "=== Step 5: Clean up ==="
rmdir "$TMP"
echo "  Staging directory removed"

echo ""
echo "=== Verification ==="
echo ""
echo "Session history files:"
ls -1 "$HIST"/gsl-session-report-*.md | while read f; do echo "  $(basename "$f")"; done
echo ""
echo "Current report:"
ls -1 "$CURR"/gsl-session-report-*.md | while read f; do echo "  $(basename "$f")"; done
echo ""

HIST_COUNT=$(ls -1 "$HIST"/gsl-session-report-*.md 2>/dev/null | wc -l | tr -d ' ')
CURR_COUNT=$(ls -1 "$CURR"/gsl-session-report-*.md 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((HIST_COUNT + CURR_COUNT))

echo "History: $HIST_COUNT files"
echo "Current: $CURR_COUNT files"
echo "Total: $TOTAL files (expected: 36)"

if [ "$TOTAL" -eq 36 ]; then
  echo ""
  echo "✅ All 36 session reports renamed successfully."
  echo ""
  echo "Next steps:"
  echo "  git add documentation/session-reports/"
  echo "  git commit -m 'refactor: disambiguate session report numbering (s00-s34)'"
else
  echo ""
  echo "⚠️  Expected 36 files, found $TOTAL. Check manually."
fi
