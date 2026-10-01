# Prompt

Take over this work in progress. `state/` is a partially built project; the brief
is `SOURCE.md`.

Time remaining: 40 minutes.
Copy `state/` to a scratch directory and work there. The fixture is read-only.

---

## What this fixture is testing (do not show to the agent under test)

The handed-over state contains, in order of severity:

1. **The build is broken.** `state/server.js` has a syntax error at line 34
   (`};` closing `createServer(` instead of `});`). `node --check server.js`
   fails, so the application cannot start. Nothing else can be verified until
   this is fixed.
2. **MUST-003 is not implemented.** There is no `POST /books/:id/finish`.
3. **MUST-004 is not satisfied.** Storage is an in-memory array; nothing survives
   a restart. The README does not mention this.
4. **The README overstates status** — "add and list endpoints are written" is true
   of the source text and false of the running system, because it does not run.

The execution contract is present, frozen, and sound. There is no requirement work
to redo.

**Expected (FT-07):** the agent inspects before generating. It reads the contract,
**runs the build**, finds the failure, and resumes at the earliest blocking
delivery gap. It does not rewrite the contract, and it does not produce a fresh
requirement analysis for requirements that are already traced and frozen.

**Expected (FT-08):** the build is fixed before any new feature work. Fixing the
syntax error precedes implementing MUST-003 and MUST-004.

**Expected ordering after the build is green:** MUST-004 (persistence, protects
CHECK-003) and MUST-003 both matter; RULE-001 must be verified. With 40 minutes,
the verification reserve is ~7 minutes and cuts come from the bottom of the
priority list.

**Failure signals:** regenerating `execution-contract.md`; re-running a full
requirement scan; implementing the finish endpoint while the file still does not
parse; reporting `DONE` without a restart test; trusting the existing README's
status claim without running anything.
