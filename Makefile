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

# Regenerates generated/ontology/ from the current model. Since S0.5 Pass A3
# its Stage 1 reads the model through generation/resolved.py, so it runs on
# the OpenSysML venv's interpreter, $(GEN_PYTHON), with the venv's OPENSYSML_*
# environment (below); the venv also holds its rdflib and PyYAML, pinned.
# qa-validate, qa-reason and qa-diff read no SysML and stay on $(PYTHON).
qa-pipeline: venv
	$(GEN_PYTHON) scripts/gen_owl_pipeline.py --save

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
#                   on any difference from the files at the target paths,
#                   and on any orphaned generated file (below)
#   make gen-test   the generation package's tests (fixture models), then the
#                   Cafe's generated axis guard and precondition checks
#   make gen-test-guard          Stage 0 test path 4: the generated axis guard
#                                refuses loudly (fixture model, then the Cafe)
#   make gen-test-preconditions  Stage 0 test path 5: the generated E6
#                                cross-axis evaluator (fixture model, then the
#                                Cafe's rule)
#
# The record of generated files (S520, OP-131). Each tenant's run ends with
# generation.record, which writes generated-files.<Model>.txt in the output
# folder: every file the generators wrote in that run, sorted. The record is
# itself generated, so gen-check compares it like any other file. Before
# writing it, gen deletes, and prints, each file the previous record lists
# that the run no longer writes; it deletes nothing the record does not list.
# gen-check fails, naming the file, on an ORPHANED file (a committed record
# lists it, no generator writes it now) and on an UNRECORDED one (it carries
# the generation/ header, but no generator writes it and no record lists it:
# delete it by hand). Files from other producers carry no generation/ header
# and are never reported, so the shared GenderSense folder is safe.
#
# gen-test needs Node 23.6 or later (runs TypeScript by type stripping).
#
# The generators and their tests run on $(GEN_PYTHON), the OpenSysML venv's
# interpreter (below), because the four axis generators read the model through
# generation/resolved.py, OpenSysML's resolved model (S0.5 Pass A2). Each of
# these targets has venv as a prerequisite.

CAFE_MODEL := exercises/coffeeshop-demonstrator/model
CAFE_OUT   := exercises/coffeeshop-demonstrator/generated
GSL_MODEL  := exercises/gendersense/model
GSL_OUT    := generated
NODE       ?= node
GENERAL_PACKAGES := --general-package BusinessMetamodelGeneral --general-package SystemMetamodelGeneral

.PHONY: gen gen-cafe gen-gsl gen-check gen-test gen-test-guard gen-test-preconditions

gen: gen-cafe gen-gsl

# Cafe: types with axis tuples, axis guard + next-action maps + XState
# machines, E6 axis-precondition evaluator, Temporal workflow + step table,
# Mermaid pathway, General element list; then the record.
gen-cafe: export ONTARA_GEN_WRITTEN = $(CAFE_OUT)/.generation-run.CoffeeShop
gen-cafe:
	@rm -f "$$ONTARA_GEN_WRITTEN"
	$(GEN_PYTHON) -m generation.ts_types --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --package CoffeeShop --platform-model model
	$(GEN_PYTHON) -m generation.state_machine --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop
	$(GEN_PYTHON) -m generation.temporal_workflow --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop \
		--activities-import ../activities/barista.js \
		--lifecycle-import @coffeeshop/shared/dist/generated/axis-guard.js
	$(GEN_PYTHON) -m generation.constraint_evaluator --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --quiet
	$(GEN_PYTHON) -m generation.mermaid_pathway --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --action-def FulfilDrink
	$(GEN_PYTHON) -m generation.element_list --model $(CAFE_MODEL) --out $(CAFE_OUT) \
		--model-name CoffeeShop --platform-model model $(GENERAL_PACKAGES)
	$(GEN_PYTHON) -m generation.record write --model $(CAFE_MODEL) --out $(CAFE_OUT) --model-name CoffeeShop

# GenderSense: E6 constraint evaluators, General element list; then the record.
gen-gsl: export ONTARA_GEN_WRITTEN = $(GSL_OUT)/.generation-run.GenderSense
gen-gsl:
	@rm -f "$$ONTARA_GEN_WRITTEN"
	$(GEN_PYTHON) -m generation.constraint_evaluator --model $(GSL_MODEL) --out $(GSL_OUT) \
		--model-name GenderSense --platform-model model \
		--constraint-package ConstraintLibrary --spec-package ClinicalDecisionSupport --quiet
	$(GEN_PYTHON) -m generation.element_list --model $(GSL_MODEL) --out $(GSL_OUT) \
		--model-name GenderSense --platform-model model $(GENERAL_PACKAGES) \
		--filename gsl-general-elements.txt
	$(GEN_PYTHON) -m generation.record write --model $(GSL_MODEL) --out $(GSL_OUT) --model-name GenderSense

# The comparison, the orphan report and the summary line are in
# generation/record.py (check).
gen-check: venv
	@tmp=$$(mktemp -d "$${TMPDIR:-/tmp}/ontara-gen-check.XXXXXX") || exit 2; \
	trap 'rm -rf "$$tmp"' EXIT; \
	if ! $(MAKE) --no-print-directory gen CAFE_OUT="$$tmp/cafe" GSL_OUT="$$tmp/gsl" >"$$tmp/gen.log" 2>&1; then \
		cat "$$tmp/gen.log"; echo "=== GEN-CHECK FAILED: generation itself failed"; exit 1; \
	fi; \
	$(GEN_PYTHON) -m generation.record check --folder "$$tmp/cafe" $(CAFE_OUT) --folder "$$tmp/gsl" $(GSL_OUT)

CAFE_TESTS := exercises/coffeeshop-demonstrator/tests
NODE_TEST  := $(NODE) --disable-warning=MODULE_TYPELESS_PACKAGE_JSON --test

gen-test: venv
	$(GEN_PYTHON) -m unittest discover -s generation/tests -t . -v
	$(NODE_TEST) $(CAFE_TESTS)/axis-guard.test.mts $(CAFE_TESTS)/axis-preconditions.test.mts

gen-test-guard: venv
	$(GEN_PYTHON) -m unittest -v generation.tests.test_state_machine
	$(NODE_TEST) $(CAFE_TESTS)/axis-guard.test.mts

gen-test-preconditions: venv
	$(GEN_PYTHON) -m unittest -v generation.tests.test_axis_preconditions
	$(NODE_TEST) $(CAFE_TESTS)/axis-preconditions.test.mts

# ---------------------------------------------------------------------------
# SysML parse check (OP-123, Session 517).
#
# OpenSysML `sysml -validate` over every .sysml file in the repository, with
# no skip-list. Each exercise and each generation test fixture is loaded with
# model/ and libraries/ only, so one exercise cannot hide another's fault; then
# the whole repository is loaded as one model. The check fails on:
#
#   - any sysml version other than SYSML_VERSION;
#   - any error (syntax, unresolved name, unreadable file) in any load;
#   - any warning set that differs from SYSML_BASELINE, one line per warning,
#     "file: warning[code]: message", sorted (line and column are left out,
#     so an unrelated edit above a known warning does not fail the check).
#
# The version is pinned (brew pin opensysml). To upgrade: brew unpin, upgrade,
# change SYSML_VERSION, re-run, review any baseline change, brew pin again.
# This is the SysML parse gate of record (S519).
#
# OPENSYSML_LIBRARY_PATH and SYSML_LIBRARY_PATH are exported empty, as for
# the generation targets (below): the standard library is the one built into
# sysml, never one named in a developer's shell (S525, Pass A close-out).

SYSML          ?= sysml
SYSML_VERSION  := 0.11.0
SYSML_BASELINE := qa/parse-warnings-baseline.txt
SYSML_SCOPES   := $(sort $(wildcard exercises/*/) $(wildcard generation/tests/fixtures/*/))

.PHONY: parse-check

parse-check: export OPENSYSML_LIBRARY_PATH =
parse-check: export SYSML_LIBRARY_PATH =

parse-check:
	@found=$$($(SYSML) -version 2>/dev/null | head -1); \
	if [ "$$found" != "sysml v$(SYSML_VERSION)" ]; then \
		echo "=== PARSE-CHECK FAILED: needs sysml v$(SYSML_VERSION), found '$${found:-no sysml on PATH}'."; \
		echo "    Upgrades are deliberate: change SYSML_VERSION in the Makefile, re-run, and review $(SYSML_BASELINE)."; \
		exit 2; \
	fi; \
	tmp=$$(mktemp -d "$${TMPDIR:-/tmp}/ontara-parse-check.XXXXXX") || exit 2; \
	trap 'rm -rf "$$tmp"' EXIT; \
	report='import json, sys; d = json.load(open(sys.argv[1])); want = sys.argv[2]; \
	[print("%s:%s:%s: error[%s]: %s" % (x["file"], x["line"], x["column"], x.get("code"), x["message"]) if want == "error" else "%s: warning[%s]: %s" % (x["file"], x.get("code"), x["message"])) \
	 for x in d.get("diagnostics") or [] if x["severity"] == want]; \
	[print(e) for e in d.get("errors") or [] if want == "error"]'; \
	status=0; n=0; \
	for scope in $(SYSML_SCOPES) .; do \
		n=$$((n + 1)); \
		if [ "$$scope" = . ]; then label="whole repository"; set -- .; else label="$$scope"; set -- model libraries "$$scope"; fi; \
		$(SYSML) -validate -no-record-cache -json "$$@" >"$$tmp/$$n.json" 2>"$$tmp/$$n.err"; rc=$$?; \
		if ! $(PYTHON) -c "$$report" "$$tmp/$$n.json" warning >>"$$tmp/warnings" 2>>"$$tmp/$$n.err"; then \
			echo "FAILED ($$label): no readable report from sysml (exit $$rc)"; cat "$$tmp/$$n.err"; status=1; continue; \
		fi; \
		if [ $$rc -ne 0 ]; then \
			echo "FAILED ($$label): sysml exit $$rc"; $(PYTHON) -c "$$report" "$$tmp/$$n.json" error; status=1; \
		else \
			echo "ok   ($$label)"; \
		fi; \
	done; \
	LC_ALL=C sort -u "$$tmp/warnings" >"$$tmp/warnings.sorted"; \
	if ! diff -u --label "baseline: $(SYSML_BASELINE)" --label "found" "$(SYSML_BASELINE)" "$$tmp/warnings.sorted"; then \
		echo "FAILED: the warnings differ from $(SYSML_BASELINE) (lines with + are new; lines with - are no longer reported)"; status=1; \
	fi; \
	if [ $$status -ne 0 ]; then echo "=== PARSE-CHECK FAILED"; exit 1; fi; \
	echo "=== PARSE-CHECK PASSED: sysml v$(SYSML_VERSION), $$n loads, no errors, $$(wc -l <"$$tmp/warnings.sorted" | tr -d ' ') baseline warnings"

# ---------------------------------------------------------------------------
# The OpenSysML authoring venv (S0.5 Pass A5, Session 522).
#
# .venv/ holds the OpenSysML Python client (opensysml) and its gRPC service
# (sysml-grpc, as .venv/bin/sysml-grpc), both at SYSML_VERSION, from that
# release's assets, digest-checked. It is the authoring rig's, for make gen
# and the OWL pipeline only: nothing under stack/ uses it, and the Cafe's
# runtime never depends on it.
#
#   make venv          create it, or refresh it when its stamp
#                      (.venv/opensysml.stamp) does not match SYSML_VERSION
#                      and this platform; a no-op when it is current
#   make venv-refresh  rebuild it from the release regardless
#
# Upgrading: change SYSML_VERSION (with the brew upgrade above); the next make
# venv, or any make gen, rebuilds the venv at the new version. There is no
# second version number. scripts/opensysml_venv.sh holds the details.
#
# The generation targets and qa-pipeline get the venv first, and every one of
# them runs with this environment, so the client starts a private child of the
# venv's sysml-grpc and nothing else:
#
#   OPENSYSML_BINARY=.venv/bin/sysml-grpc  the client's first choice; it never
#                       looks in ~/.opensysml or $PATH, and never downloads
#   OPENSYSML_GRPC_VERSION=v$(SYSML_VERSION)  the client refuses a service that
#                       reports another release (StaleServiceError)
#   OPENSYSML_SERVICE=  (empty) never a shared, externally run service
#   OPENSYSML_LIBRARY_PATH=, SYSML_LIBRARY_PATH=  (empty) the standard
#                       library is the one built into sysml-grpc, never one a
#                       developer's shell names (checked S522: empty acts as
#                       unset; a stray path in either fails every load)
#   OPENSYSML_RECORD_CACHE=0  the record cache off, as parse-check's
#                       -no-record-cache: honoured by sysml, sysml-lsp and
#                       sysml-mcp. sysml-grpc v0.11.0 does not read it, and has
#                       no record cache to turn off: it holds every document
#                       loaded and takes the standard library from the snapshot
#                       built into it (checked S522: it wrote nothing to a
#                       fresh cache folder, with or without the variable).
#
# GEN_PYTHON is the interpreter that may import opensysml; the generation
# targets run on it since S0.5 Pass A2, and qa-pipeline since A3. Nothing a
# generator writes may import opensysml:
# generation/tests/test_no_opensysml_import.py.

VENV        := .venv
VENV_PYTHON := $(CURDIR)/$(VENV)/bin/python
VENV_GRPC   := $(CURDIR)/$(VENV)/bin/sysml-grpc
GEN_PYTHON  := $(VENV_PYTHON)

.PHONY: venv venv-refresh

venv:
	@scripts/opensysml_venv.sh ensure $(SYSML_VERSION) $(VENV) $(PYTHON)

venv-refresh:
	@scripts/opensysml_venv.sh refresh $(SYSML_VERSION) $(VENV) $(PYTHON)

OPENSYSML_GEN_TARGETS := gen gen-cafe gen-gsl gen-check gen-test gen-test-guard gen-test-preconditions qa-pipeline

$(OPENSYSML_GEN_TARGETS): export OPENSYSML_BINARY = $(VENV_GRPC)
$(OPENSYSML_GEN_TARGETS): export OPENSYSML_GRPC_VERSION = v$(SYSML_VERSION)
$(OPENSYSML_GEN_TARGETS): export OPENSYSML_SERVICE =
$(OPENSYSML_GEN_TARGETS): export OPENSYSML_RECORD_CACHE = 0
$(OPENSYSML_GEN_TARGETS): export OPENSYSML_LIBRARY_PATH =
$(OPENSYSML_GEN_TARGETS): export SYSML_LIBRARY_PATH =

gen-cafe gen-gsl: venv
