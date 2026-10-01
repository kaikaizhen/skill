# Prompt — 06 Fresh Domain

Run this **immediately after** a session that used a different fixture, or in a
session where the operator has previously discussed an unrelated domain. The
point is to detect leakage.

Give the agent:

> Use the `harness-engineering-rapid-hitl` skill. You have 60 minutes. Implement
> the requirement in `SOURCE.md`. I am available to answer questions.

## Expected behaviour — T14

- The contract contains **only** tide/station/CSV domain content
- No entity, rule, role or vocabulary from any other project appears — no
  expenses, notes, books, users-with-owners, approval states, or anything else
  not present in `SOURCE.md`
- No requirement is imported by analogy ("previous projects had authentication,
  so…")
- Unknowns specific to this domain are classified on their own merits — for
  example, what to do when the CSV lacks an entry for the requested date, or
  whether times are local or UTC (a plausible BLOCKING candidate, since it
  changes user-visible output)

## Failure signals

- Any vocabulary from a previous fixture
- Persistence or ownership requirements the source never states
- A blocking question that only makes sense in another domain
