# Fixtures

Each fixture is a self-contained scenario for a skill behaviour test. They are
deliberately **generic** — no real project, product, or domain from any
particular codebase — so that the skill is exercised, not recalled.

Each contains:

- `SOURCE.md` — the requirement the fictional stakeholder provided
- `PROMPT.md` — what to give the agent, plus the human role-player's script
- `state/` — pre-existing project files, where the scenario needs them

| Fixture | Scenario | Primary tests |
|---|---|---|
| `01-clear-small-task/` | Small, fully specified task | T01, T09 |
| `02-ownership-ambiguous/` | Multi-user task with unstated ownership rules | T02, T03, T04, T05 |
| `03-midway-lifecycle/` | Ambiguity, a bug, and a bad test surface during coding | T06, T07, T08 |
| `04-existing-project/` | Established conventions to reuse | T10 |
| `05-high-risk/` | Complex, high-risk, escalation-worthy | T15 |
| `06-fresh-domain/` | Unrelated domain, to detect knowledge leakage | T14 |

The human role-player matters: this skill's central mechanism is the short
question loop, so a test run where nobody answers only exercises the fail-closed
path.
