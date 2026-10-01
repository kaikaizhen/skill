# Fixtures

Each fixture is a small, self-contained source brief plus a `PROMPT.md` giving the
agent its task and time budget. They are deliberately short — the point is to
trigger a specific guardrail, not to simulate a real project.

| Fixture | Triggers |
|---|---|
| `01-underspecified-brief/` | BLOCKING detection, no hidden requirements |
| `02-clear-small-brief/` | Fast path, assumption labelling |
| `03-contradictory-brief/` | Source contradiction escalation |
| `04-oversized-brief/` | Mode switching to Full Mode |
| `05-resume-partial/` | Resume detection, build-first rule |

Fixture sources are **protected inputs**: an agent under test may read them and
must not modify them. All output goes to a scratch working directory outside this
tree.

The briefs are intentionally imperfect. Their gaps and contradictions are the test.
Do not "fix" a fixture — a repaired fixture tests nothing.
