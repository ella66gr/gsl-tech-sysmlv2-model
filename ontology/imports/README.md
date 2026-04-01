# Ontology Imports

Version-pinned external ontologies for the Ontara knowledge graph.

## Download Commands

Run from repo root:

```bash
# BFO 2020 (Core) — path on master is 21838-2/owl/bfo-core.owl
curl -L -o ontology/imports/bfo-core.owl \
  "https://raw.githubusercontent.com/BFO-ontology/BFO-2020/master/21838-2/owl/bfo-core.owl"

# CCO (Merged — all 11 modules) — develop branch, filename is CommonCoreOntologiesMerged.ttl
curl -L -o ontology/imports/CommonCoreOntologiesMerged.ttl \
  "https://raw.githubusercontent.com/CommonCoreOntology/CommonCoreOntologies/develop/src/cco-merged/CommonCoreOntologiesMerged.ttl"

# IAO — at repo root
curl -L -o ontology/imports/iao.owl \
  "https://raw.githubusercontent.com/information-artifact-ontology/IAO/master/iao.owl"
```

## Import Order (into GraphDB)

1. BFO 2020 (`bfo-core.owl`) — upper ontology, no dependencies
2. CCO merged (`CommonCoreOntologiesMerged.ttl`) — imports BFO
3. IAO (`iao.owl`) — imports BFO; some overlap with CCO

## Version Pins

| Ontology | Source | Branch/Tag | Pinned at |
|---|---|---|---|
| BFO 2020 | BFO-ontology/BFO-2020 | `master` @ `21838-2/owl/` | Downloaded 2026-04-01 |
| CCO 2.0 | CommonCoreOntology/CommonCoreOntologies | `develop` @ `src/cco-merged/` | Downloaded 2026-04-01 |
| IAO | information-artifact-ontology/IAO | `master` | Downloaded 2026-04-01 |

Pin to specific commits once validated.
