#!/usr/bin/env bash
# check_package_direction.sh — OP-132 import-direction rules R1..R8
#
# Source of the rules: session-515-op-132-mahmood-package-map.md §4 (ADR-012).
# Run from anywhere; paths are resolved relative to the repo root.
#
# Usage:
#   scripts/check_package_direction.sh              # strict: any offending line fails
#   scripts/check_package_direction.sh --pending-ok # lines that name a package not yet
#                                                   # moved by OP-132 are tagged
#                                                   # "pending" and do not fail
#
# Each rule prints its label, then its offending lines (if any), then a verdict.
# A rule whose target files do not exist yet prints "n/a (not yet applicable)".
# Exit status is 1 if any applicable rule has offending lines that are not
# excused as pending; 0 otherwise.
#
# Package classes (map §4):
#   General   : BusinessMetamodelGeneral, SystemMetamodelGeneral
#   Domain    : BusinessMetamodelDomain<Sector>, SystemMetamodelDomain<Sector>
#   Apparatus : ScalarValues, ProjectionMetadata, TemporalMetadata
#   Platform description: ArchitecturalStructure, PatternCatalogue
#   Tenant    : every package declared under exercises/

set -u
cd "$(dirname "$0")/.." || exit 2

PENDING_OK=0
[[ "${1:-}" == "--pending-ok" ]] && PENDING_OK=1

# Old top-level names that OP-132 has not yet retired. A line is "pending" if
# the package it names is in this list. Trim the list as steps complete:
#   step 5  BusinessModel/BusinessScenarios/BusinessStrategy GSL usages leave
#   step 8  Knowledge, Platform retired (done S515)
#   step 9  BusinessModel, BusinessScenarios, BusinessStrategy, CanonicalRuntime retired (done S515)
#   step 11 Foundation retired (done S515)
#   step 12 root's PatternCatalogue import dropped (done S515) — list now empty
PENDING_NAMES=''   # empty since S515 step 12: every rule runs strict; --pending-ok now equals the default

IMPORT_RE='^\s*(private |public )?import '
APPARATUS='ScalarValues|ProjectionMetadata|TemporalMetadata'
GENERAL='BusinessMetamodelGeneral|SystemMetamodelGeneral'

FAIL=0

# report <label> <lines>  — prints verdict, updates FAIL
report() {
    local label="$1" lines="$2"
    if [[ -z "$lines" ]]; then
        echo "  ok"
        return
    fi
    local real=0 pending=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        if [[ -n "$PENDING_NAMES" ]] \
           && grep -qE "(import |^package |\b)(${PENDING_NAMES})(::| |\{)" <<<"$line" \
           && grep -qE "(${PENDING_NAMES})" <<<"$line"; then
            if (( PENDING_OK )); then
                echo "  pending  $line"; ((pending++)); continue
            fi
        fi
        echo "  OFFEND   $line"; ((real++))
    done <<<"$lines"
    if (( real > 0 )); then
        echo "  FAIL ($real offending, $pending pending)"; FAIL=1
    else
        echo "  ok with $pending pending (names not yet moved by OP-132)"
    fi
}

exists_any() { for f in "$@"; do [[ -e "$f" ]] && return 0; done; return 1; }

# ---------------------------------------------------------------- R1
echo "R1. General imports only General and apparatus"
if exists_any model/business-metamodel-general.sysml model/system-metamodel-general.sysml; then
    out=$(grep -nHE "$IMPORT_RE" model/business-metamodel-general.sysml model/system-metamodel-general.sysml 2>/dev/null \
          | grep -vE "import (${APPARATUS}|${GENERAL})::")
    report R1 "$out"
else
    echo "  n/a (not yet applicable: no model/*-metamodel-general.sysml)"
fi

# ---------------------------------------------------------------- R2
echo "R2. Domain imports only General, apparatus and Domain of its own sector"
shopt -s nullglob
domain_files=(model/*-metamodel-domain-*.sysml)
shopt -u nullglob
if (( ${#domain_files[@]} )); then
    out=""
    for f in "${domain_files[@]}"; do
        sector=$(sed -E 's/.*-metamodel-domain-([a-z]+)\.sysml/\1/' <<<"$f")
        Sector="$(tr '[:lower:]' '[:upper:]' <<<"${sector:0:1}")${sector:1}"
        o=$(grep -nHE "$IMPORT_RE" "$f" \
            | grep -vE "import (${APPARATUS}|${GENERAL}|(Business|System)MetamodelDomain${Sector})::")
        [[ -n "$o" ]] && out+="$o"$'\n'
    done
    report R2 "$out"
else
    echo "  n/a (not yet applicable: no model/*-metamodel-domain-*.sysml)"
fi

# ---------------------------------------------------------------- R3
echo "R3. The business side never imports the system side"
shopt -s nullglob
bus_files=(model/business-metamodel-*.sysml)
shopt -u nullglob
if (( ${#bus_files[@]} )); then
    out=$(grep -nHE 'import SystemMetamodel' "${bus_files[@]}")
    report R3 "$out"
else
    echo "  n/a (not yet applicable: no model/business-metamodel-*.sysml)"
fi

# ---------------------------------------------------------------- R4
echo "R4. Platform description imports only General and apparatus, and nothing imports it"
if exists_any model/architectural-structure.sysml model/pattern-catalogue.sysml; then
    out=$(grep -nHE "$IMPORT_RE" model/architectural-structure.sysml model/pattern-catalogue.sysml 2>/dev/null \
          | grep -vE "import (ScalarValues|ProjectionMetadata|${GENERAL})::")
    out2=$(grep -rnE 'import (ArchitecturalStructure|PatternCatalogue)::' --include='*.sysml' model exercises \
           | grep -v 'model/syntax-tests')
    report R4 "${out}${out:+$'\n'}${out2}"
else
    echo "  n/a (not yet applicable)"
fi

# ---------------------------------------------------------------- R5
echo "R5. model/ holds no tenant package"
out=$(grep -HE '^package ' model/*.sysml \
      | grep -vE ':package (BusinessMetamodelGeneral|SystemMetamodelGeneral|(Business|System)MetamodelDomain[A-Z][A-Za-z]*|ProjectionMetadata|ArchitecturalStructure|PatternCatalogue) ')
report R5 "$out"

# ---------------------------------------------------------------- R6
echo "R6. Foundation is gone, in imports and in strings"
out=$(grep -rn 'Foundation::' --include='*.sysml' model exercises libraries | grep -v 'model/syntax-tests')
report R6 "$out"

# ---------------------------------------------------------------- R7
echo "R7. A tenant imports no other tenant"
# bash 3.2 (macOS) has no associative arrays: use a case table.
tenant_dir() {
    case "$1" in
        gsl)   echo "exercises/gendersense/model" ;;
        cafe)  echo "exercises/coffeeshop-demonstrator/model" ;;
        suds)  echo "exercises/suds-demonstrator/model" ;;
        paws)  echo "exercises/paws-demonstrator/model" ;;
        minds) echo "exercises/minds-demonstrator/model" ;;
    esac
}
tenant_own() {
    case "$1" in
        gsl)   echo 'Gsl[A-Za-z]*|GenderSense' ;;
        cafe)  echo 'CoffeeShop[A-Za-z]*|Coffeeshop[A-Za-z]*|BusinessRules|DrinkFulfilment|FulfilDrinkOrchestration|OrderLifeCycle' ;;
        suds)  echo 'Suds[A-Za-z]*' ;;
        paws)  echo 'Paws[A-Za-z]*' ;;
        minds) echo 'Minds[A-Za-z]*' ;;
    esac
}
for t in gsl cafe suds paws minds; do
    d="$(tenant_dir "$t")"
    echo "  [$t] $d"
    if [[ ! -d "$d" ]]; then echo "  n/a (not yet applicable: $d missing)"; continue; fi
    out=$(grep -rnHE "$IMPORT_RE" "$d" --include='*.sysml' \
          | grep -vE "import (${APPARATUS}|${GENERAL}|(Business|System)MetamodelDomainClinical|$(tenant_own "$t"))::")
    report "R7[$t]" "$out"
done

# ---------------------------------------------------------------- R8
echo "R8. No qualified reference bypasses an import (General/Domain files)"
TENANT_NAMES='Gsl[A-Za-z]*|GenderSense|CoffeeShop[A-Za-z]*|Coffeeshop[A-Za-z]*|Suds[A-Za-z]*|Paws[A-Za-z]*|Minds[A-Za-z]*'
shopt -s nullglob
gen_files=(model/*-metamodel-general.sysml)
shopt -u nullglob
if (( ${#gen_files[@]} || ${#domain_files[@]} )); then
    out=""
    # bash 3.2 + set -u: an empty array expansion is "unbound"; guard it.
    for f in ${gen_files[@]+"${gen_files[@]}"}; do
        o=$(grep -nHE "\b(BusinessMetamodelDomain[A-Za-z]*|SystemMetamodelDomain[A-Za-z]*|${TENANT_NAMES})::" "$f" \
            | grep -vE '^[^:]+:[0-9]+:\s*(//|\*)')
        [[ -n "$o" ]] && out+="$o"$'\n'
    done
    for f in ${domain_files[@]+"${domain_files[@]}"}; do
        sector=$(sed -E 's/.*-metamodel-domain-([a-z]+)\.sysml/\1/' <<<"$f")
        Sector="$(tr '[:lower:]' '[:upper:]' <<<"${sector:0:1}")${sector:1}"
        o=$(grep -nHE "\b(BusinessMetamodelDomain[A-Za-z]*|SystemMetamodelDomain[A-Za-z]*|${TENANT_NAMES})::" "$f" \
            | grep -vE "(Business|System)MetamodelDomain${Sector}::" \
            | grep -vE '^[^:]+:[0-9]+:\s*(//|\*)')
        [[ -n "$o" ]] && out+="$o"$'\n'
    done
    report R8 "$out"
else
    echo "  n/a (not yet applicable: no General or Domain files)"
fi

echo
if (( FAIL )); then echo "RESULT: FAIL"; exit 1; else echo "RESULT: PASS"; exit 0; fi
