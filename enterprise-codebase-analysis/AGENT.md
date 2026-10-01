# Agent Host Entry Point — Enterprise Codebase Analysis

A host adapter, not a model adapter. It exists only because some agent hosts
discover `AGENT.md` / `AGENTS.md` at the repository root rather than `SKILL.md`.
It carries no rules, no model assumptions and no organization knowledge of its own.

1. Read `SKILL.md` first - it is the router and the workflow and safety authority.
   Modes, Hard Rules, Reference Routing and Memory Routing all live there.
2. This skill is model-agnostic (HARD RULE 15). The host owns model selection; do
   not configure a provider, endpoint or model here. What the engine assumes about
   the selected model - `context_limit`, `capabilities`, context budget, rolling
   context, mid-ticket model switching - is in `references/runtime-contract.md`,
   and this installation's declared values are in
   `workspace/references/runtime.yaml`.
3. For anything specific to the current organization - which repositories exist,
   which domain lives where, organization-only tooling, and the traps worth knowing
   before tracing a flow - read `workspace/PROFILE.md`.

Nothing in `SKILL.md`, `references/` or `templates/` depends on this file. If the
host finds `SKILL.md` on its own, it can be deleted.
