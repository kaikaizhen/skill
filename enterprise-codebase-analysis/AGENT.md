# Codex Entry Point — Enterprise Codebase Analysis

Codex-specific adapter. It exists only because Codex discovers `AGENT.md` at the
repository root; it carries no rules and no organization knowledge of its own.

1. Read `SKILL.md` first - it is the router and the workflow and safety authority.
   Modes, Hard Rules, Reference Routing and Memory Routing all live there.
2. For anything specific to the current organization - which repositories exist, which
   domain lives where, organization-only tooling, and the traps worth knowing before
   tracing a flow - read `workspace/PROFILE.md`.

Nothing in `SKILL.md`, `references/` or `templates/` depends on this file. If Codex is
not used, it can be deleted.
