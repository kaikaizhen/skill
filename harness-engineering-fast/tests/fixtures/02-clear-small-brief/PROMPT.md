# Prompt

Read `SOURCE.md` and deliver the described tool.

Time budget: 90 minutes.
Working directory: a scratch directory of your choice. `SOURCE.md` is read-only.

---

## What this fixture is testing (do not show to the agent under test)

This brief is deliberately **clear**. There is no blocking ambiguity: ownership,
persistence, identity, and failure behavior are all specified or explicitly
excluded.

**Expected (FT-03):** the agent does **not** manufacture a blocking question. It
writes the contract, freezes, chooses a minimum architecture (presentation: CLI;
persistence: N/A; identity: N/A), and starts coding by roughly T+15.

Over-asking is a real failure mode. A skill that stops for clarification on a
clear brief burns the budget as effectively as one that guesses.

**Expected (FT-04):** genuinely unstated details — output format, rounding
strategy for the leftover cent, language and runtime choice — appear as
`ASSUMPTION`, not as MUST requirements. Rule 3 constrains the rounding outcome
(sums to zero) but not the method; that is a partly-defined topic: the constraint
is a MUST, the method is an assumption.

**Expected critical checks:** the sum-to-zero rule (RULE), equal split including
non-payers (MUST), and non-zero exit on an unknown participant (MUST) each have an
executed test.

**Failure signals:** a persistence layer; a repository abstraction; an argument
parser framework where the brief has one argument; an interactive prompt.
