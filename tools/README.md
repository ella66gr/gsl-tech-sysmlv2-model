# Tools

External tool binaries used by the Ontara development pipeline.

## Robot (OWL Reasoner)

[Robot](http://robot.obolibrary.org/) is a command-line OWL tool that wraps HermiT for full OWL 2 DL reasoning.

### Installation

Download the JAR from the latest release:

```bash
cd tools
curl -L -o robot.jar https://github.com/ontodev/robot/releases/download/v1.9.8/robot.jar
```

Verify it works:

```bash
java -jar tools/robot.jar --version
```

### Usage

The `reason_kg.py` script in `scripts/` wraps Robot for the Ontara ontology stack.
See `python3 scripts/reason_kg.py --help` for details.

### Requirements

- Java 11 or later (Java 25 Temurin LTS confirmed working)

---

*`robot.jar` is listed in `.gitignore` — each developer downloads their own copy.*
