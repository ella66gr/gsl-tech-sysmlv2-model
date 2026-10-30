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
