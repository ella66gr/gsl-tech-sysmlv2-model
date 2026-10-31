"""Platform generation package (Plan B Stage 0, S0.2).

Generators that read a tenant's SysML v2 model folder and write generated
code into an output folder. No generator names a tenant: every
tenant-specific path, package name or file name is an argument or is read
from the model. Tenant wiring lives in the repository Makefile.

Generators:
    generation.ts_types              TypeScript enums and interfaces
    generation.state_machine         XState machine, lifecycle guard, next-action map
    generation.temporal_workflow     Temporal workflow and its step table
    generation.mermaid_pathway       Mermaid flowchart of an action flow
    generation.constraint_evaluator  E6 constraint evaluators
    generation.element_list          General elements a tenant instantiates (S0.3)

Run any of them as ``python3 -m generation.<name> --help``.
"""
