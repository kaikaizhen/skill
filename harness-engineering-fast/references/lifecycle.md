# Fast Lifecycle — Phases, Budget, Resume, Escalation

## Phase Order

```
SOURCE
  -> Rapid Requirement Scan
     -> Execution Contract
        -> Blocking Question Check
           -> Requirement Freeze          REQUIREMENT_FAST_GATE = PASS
              -> Minimum Architecture
                 -> Architecture Freeze   ARCHITECTURE_FAST_GATE = PASS
                    -> Implementation
                       -> Critical Verification
                          -> Fix Critical Failures
                             -> Final Acceptance   FAST_DELIVERY_GATE
```

Each phase has one job and one exit condition. Nothing else belongs in it.

---

## Phase 1 — Rapid Requirement Scan (T+0 - T+8)

**Job.** Read the source once, completely, and extract only what it actually says.

**Do:**
- Read every provided source artifact end to end before writing anything.
- Mark each extracted item with where it came from (section, page, line, quote
  fragment). A MUST with no traceable origin is not a MUST.
- Note contradictions inside the source rather than resolving them silently.
- Split partly-defined topics: what the source establishes vs what it leaves open.

**Do not:**
- Fill gaps with engineering common sense.
- Expand a stated feature into the "obvious" surrounding feature set.
- Design anything.

**Exit.** You can name every MUST requirement, every critical business rule, and
every unknown with its classification.

---

## Phase 2 — Execution Contract (inside T+0 - T+8)

**Job.** Write `docs/execution-contract.md` from `templates/execution-contract.md`.

One file. Goal, MUST Requirements, Critical Business Rules, Blocking Ambiguities,
Safe Assumptions, Out of Scope, Critical Acceptance Checks.

**Exit.** Every section is present and every MUST cites its source.

---

## Phase 3 — Blocking Question Check

**Job.** Decide whether implementation can safely start.

If any unknown is classified `BLOCKING`, issue the minimum set of BLOCKING
QUESTION blocks (format in `SKILL.md`) and **stop**. Do not select an
interpretation yourself.

When the human answers: update the contract, mark the ambiguity `RESOLVED — human
clarification`, and continue.

When the human is unreachable and the clock forces a decision: record
`BLOCKING — UNANSWERED`, state the interpretation you are proceeding under, and
carry `NEEDS_ATTENTION` into the final gate. This is a degraded delivery, and it
is reported as one.

---

## Phase 4 — Requirement Freeze (target: T+8)

Run the Rapid Requirement Review (`requirement-fast-loop.md`). Critical check FAIL
means no coding. On PASS:

```
REQUIREMENT_FAST_GATE = PASS
```

Freeze does not mean requirements can never change. It means requirement analysis
does not reopen except for: source contradiction, missing blocking requirement,
new human clarification, or an acceptance failure traced to a requirement defect.

---

## Phase 5 — Minimum Architecture (T+8 - T+15)

Decide only what blocks coding. See `minimum-architecture.md`. On completion:

```
ARCHITECTURE_FAST_GATE = PASS
```

Then coding starts. If T+15 arrives and architecture is unsettled, take the
cheapest option that satisfies every MUST, record it as a Time-constrained
Engineering Assumption, and start.

---

## Phase 6 — Implementation (T+15 - T+65)

See `implementation-strategy.md`. Vertical slice first; checkpoints A, B, C;
priority order enforced when cutting.

---

## Phase 7 — Critical Verification (T+65 - T+82)

See `risk-based-verification.md`. Execute the critical test plan. Real evidence
only.

---

## Phase 8 — Fix Critical Failures (inside T+65 - T+82)

Critical Acceptance Check FAIL -> fix first.
Optional feature FAIL -> record as a Known Limitation if time is short.
MUST requirement FAIL -> the delivery is not complete; say so.

---

## Phase 9 — Final Acceptance (T+82 - T+90)

Run `templates/final-acceptance.md`. Produce a terminal line:

```
FAST_DELIVERY_GATE = PASS | NEEDS_ATTENTION | INCOMPLETE
```

Write or update the README with: how to run, what was built, assumptions, known
limitations, what was not verified.

---

## Time Budget

Default 90 minutes:

| Window | Phase | Share |
|---|---|---|
| T+0 - T+8 | Requirement scan + contract | ~9% |
| T+8 - T+15 | Minimum architecture | ~8% |
| T+15 - T+65 | Implementation | ~55% |
| T+65 - T+82 | Verification + fix | ~19% |
| T+82 - T+90 | Acceptance + README | ~9% |

Scaled budgets:

| Total | Req+Contract | Arch | Impl | Verify+Fix | Accept |
|---|---|---|---|---|---|
| 60 min | 6 | 5 | 32 | 12 | 5 |
| 90 min | 8 | 7 | 50 | 17 | 8 |
| 120 min | 10 | 9 | 68 | 22 | 11 |
| 180 min | 14 | 13 | 102 | 34 | 17 |

**Anchor the budget to wall clock at T+0** and restate the remaining time at each
checkpoint. A budget nobody checks is decoration.

### Guardrails

- Requirement analysis over budget -> only BLOCKING items continue.
- Architecture discussion over budget -> cheapest MUST-satisfying option, recorded
  as a Time-constrained Engineering Assumption.
- Verification reserve (>= 15 min at 90) is not borrowable by implementation.
- The clock never authorizes skipping a BLOCKING question.

---

## Resume — Existing Project

Do not regenerate artifacts by reflex. Detect, then resume at the earliest
**blocking delivery gap**.

Detection order:

1. **Source / requirement material** — present? readable?
2. **Execution contract** — exists? does it cite sources? are ambiguities
   classified?
3. **Implementation** — what exists, and does it match the contract's MUSTs?
4. **Build state** — does it build? does it start? (Run it. Do not infer.)
5. **Tests** — do they exist, and what was their last actual result?
6. **Known failures** — recorded anywhere?
7. **Remaining time** — ask, or state your assumption.

Gap resolution table:

| Detected state | Resume at |
|---|---|
| No source read, no contract | Phase 1 |
| Contract exists, MUSTs untraceable to source | Phase 1 (repair contract) |
| Contract exists, BLOCKING unanswered | Phase 3 (stop and ask) |
| Contract passed review, no architecture | Phase 5 |
| Code exists, build fails | Fix build **before** any new feature work |
| Code exists, core flow never run | Run it; that is the earliest real gap |
| Core flow works, no critical tests | Phase 7 |
| Tests failing on a MUST | Phase 8 |
| All above satisfied | Phase 9 |

**Rule.** A build failure or an unstartable application outranks every documented
gap. There is no value in a well-documented delivery that does not run.

Existing artifacts follow the inherited principle: *Artifact Exists != Artifact
Trusted*. An execution contract you did not write is a claim, not evidence. Spot
check its MUSTs against the source before building on it — but spot check, not
re-derive; the budget is the same 8 minutes.

---

## Mode Switching

Warn the user that **Fast Mode may be insufficient** when you observe:

- many requirement ambiguities, or ambiguity in the core domain itself
- multiple actors or multiple bounded contexts
- non-trivial security requirements (authentication, authorization, tenancy)
- high data risk (real user data, irreversible operations, migrations)
- integration across several systems
- an architecture decision with high irreversibility
- production-critical requirements

Format:

```
MODE WARNING

Observed: ...
Why Fast Mode may be insufficient: ...
Recommended: harness-engineering (Full Mode) for <specific stage>
Fast Mode can still deliver: ...
```

The human decides. Do not switch modes unilaterally, and do not silently apply
full-harness weight inside a 90-minute budget — that is how a delivery ends with
excellent documents and no working software.
