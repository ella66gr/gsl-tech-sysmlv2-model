# Sourced by the stack's bin scripts. Not run on its own.
#
# Results set: every result of a run goes under results/<set>/, and the set's
# name says the store and the UTC date, for example results/fuseki-2026-11-01/
# (S0.1 pass 3). Set RESULTS_SET to choose another name. The pass 1 (GraphDB)
# results stay where they were, in results/loadtest/ and results/shacl-*.
RESULTS_SET="${RESULTS_SET:-fuseki-$(date -u +%Y-%m-%d)}"
# Optional local overrides (ports, heap); the stack runs without them.
if [ -f .env ]; then set -a; . ./.env; set +a; fi
