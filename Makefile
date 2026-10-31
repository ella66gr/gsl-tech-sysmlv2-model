# Ontara QA layers (Plan B Stage 0, S0.1 pass 2, Session 517).
#
# Each target is a thin wrapper over an existing script and exits non-zero
# when its layer fails. `make qa` runs all four in order and carries on past
# a failing layer, so every layer reports; it exits non-zero if any failed.
#
# qa-validate and qa-diff need GraphDB Desktop running with the `ontara-dev`
# repository on http://localhost:7200. qa-reason needs Java and tools/robot.jar
# only. The recorded baseline is qa/baseline.json (prose: qa/BASELINE.md).

PYTHON ?= python3

.PHONY: qa qa-pipeline qa-validate qa-reason qa-diff

# Regenerates generated/ontology/ from the current model.
qa-pipeline:
	$(PYTHON) scripts/gen_owl_pipeline.py --save

# Reloads the pipeline output into ontara-dev, then runs the SPARQL suite.
qa-validate:
	$(PYTHON) scripts/validate_kg.py --load

# HermiT over the stack reason_kg.py assembles; does not need GraphDB.
qa-reason:
	$(PYTHON) scripts/reason_kg.py --save-summary

# Round-trip diff, generated OWL against the live store.
# Report: generated/ontara/diff-report.json
qa-diff:
	$(PYTHON) scripts/diff_kg.py --json-only

qa:
	@failed=""; \
	for t in qa-pipeline qa-validate qa-reason qa-diff; do \
		echo "=== $$t"; \
		$(MAKE) --no-print-directory $$t || failed="$$failed $$t"; \
	done; \
	if [ -n "$$failed" ]; then echo "=== QA FAILED:$$failed"; exit 1; fi; \
	echo "=== QA PASSED"

# ---------------------------------------------------------------------------
# Generation (Plan B Stage 0, S0.2, Session 517).
#
# The platform generators in generation/ know no tenant; the tenant wiring
# (model folder, output folder, package and import names) lives here. Each
# tenant's output is written in place, to the files its consumers import.
#
#   make gen        regenerate every tenant's committed output
#   make gen-check  regenerate into a scratch folder and fail, with a diff,
#                   on any difference from the files at the target paths
#   make gen-test   the generation package's tests (fixture models only),
#                   then the Cafe's generated lifecycle guard refusal check
#
# gen-test needs Node 23.6 or later (runs TypeScript by type stripping).

CAFE_MODEL := exercises/coffeeshop-demonstrator/model
CAFE_OUT   := exercises/coffeeshop-demonstrator/generated
GSL_MODEL  := exercises/gendersense/model
GSL_OUT    := generated
NODE       ?= node

.PHONY: gen gen-cafe gen-gsl gen-check gen-test

gen: gen-cafe gen-gsl

# Cafe: types, XState machine + lifecycle guard + next-action map, Temporal
# workflow + step table, Mermaid pathway.
gen-cafe:
	$(PYTHON) -m generation.ts_types --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --package CoffeeShop
	$(PYTHON) -m generation.state_machine --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop
	$(PYTHON) -m generation.temporal_workflow --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop \
		--activities-import ../activities/barista.js --input-type OrderDetails \
		--lifecycle-import @coffeeshop/shared/dist/generated/order-lifecycle-guard.js
	$(PYTHON) -m generation.mermaid_pathway --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --action-def FulfilDrink

# GenderSense: E6 constraint evaluators.
gen-gsl:
	$(PYTHON) -m generation.constraint_evaluator --model $(GSL_MODEL) --out $(GSL_OUT) \
		--model-name GenderSense --platform-model model \
		--constraint-package ConstraintLibrary --spec-package ClinicalDecisionSupport --quiet

gen-check:
	@tmp=$$(mktemp -d "$${TMPDIR:-/tmp}/ontara-gen-check.XXXXXX") || exit 2; \
	trap 'rm -rf "$$tmp"' EXIT; \
	if ! $(MAKE) --no-print-directory gen CAFE_OUT="$$tmp/cafe" GSL_OUT="$$tmp/gsl" >"$$tmp/gen.log" 2>&1; then \
		cat "$$tmp/gen.log"; echo "=== GEN-CHECK FAILED: generation itself failed"; exit 1; \
	fi; \
	status=0; checked=0; \
	for pair in "cafe:$(CAFE_OUT)" "gsl:$(GSL_OUT)"; do \
		name=$${pair%%:*}; dir=$${pair#*:}; \
		for f in $$(cd "$$tmp/$$name" && ls | sort); do \
			checked=$$((checked + 1)); \
			if [ ! -f "$$dir/$$f" ]; then \
				echo "MISSING: $$dir/$$f is generated but not present"; status=1; \
			elif ! diff -u --label "committed: $$dir/$$f" --label "regenerated: $$dir/$$f" \
					"$$dir/$$f" "$$tmp/$$name/$$f"; then \
				status=1; \
			fi; \
		done; \
	done; \
	if [ $$status -ne 0 ]; then \
		echo "=== GEN-CHECK FAILED: generated files differ from the model (edited by hand, or not regenerated). Run 'make gen'."; \
		exit 1; \
	fi; \
	echo "=== GEN-CHECK PASSED: $$checked generated files match the model"

gen-test:
	$(PYTHON) -m unittest discover -s generation/tests -t . -v
	$(NODE) --disable-warning=MODULE_TYPELESS_PACKAGE_JSON --test exercises/coffeeshop-demonstrator/tests/order-lifecycle-guard.test.mts
