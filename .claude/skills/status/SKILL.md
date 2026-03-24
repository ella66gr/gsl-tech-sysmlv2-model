---
name: status
description: Show the current state of the Ontara repo — git status, generated file freshness, and service health
allowed-tools: Bash
---

# Ontara Project Status

Get a quick overview of the current state of the repo and services.

## Steps

1. **Git status:**
   ```bash
   git status --short
   ```

2. **Last commit:**
   ```bash
   git log --oneline -5
   ```

3. **Generated file timestamps** (to assess freshness):
   ```bash
   ls -la generated/ontara/model-introspection.json
   ls -la console/static/data/model-introspection.json
   ```

4. **Check if generated JSON is in sync:**
   ```bash
   diff generated/ontara/model-introspection.json console/static/data/model-introspection.json > /dev/null 2>&1 && echo "SYNC: Console data matches generated data" || echo "OUT OF SYNC: Console data differs from generated data — run /generate then /console refresh"
   ```

5. **Check Docker services** (if Coffee Shop is relevant):
   ```bash
   docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker not running or no containers"
   ```

6. **Model file summary:**
   ```bash
   echo "Core model files:" && ls model/*.sysml | wc -l
   echo "Demonstrator files:" && find exercises -name "*.sysml" | wc -l
   ```

7. Report findings concisely.
