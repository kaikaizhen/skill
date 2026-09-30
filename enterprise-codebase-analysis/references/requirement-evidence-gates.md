# Requirement & Evidence Gates (Mode A)

Four checkable gates between "the ticket arrived" and Approval Gate #1. They exist
because this skill's general principles - `current evidence beats memory`, `same
domain is not the same execution path` - are reminders, not stop conditions: they
force no ordering and produce no checkable output. Each gate has a **trigger**, a
**required output** and a **stop condition**.

They answer *what to build and what the evidence supports*. **Gate 5 - what the
change silently removes - is `regression-validator.md`**, running between the plan
and Gate 4, then again on the real diff. How a change is written once approved is
`development-convention.md`; whether it is verified is `verification.md`. Mode A
only: Mode B seeds memory, Mode C may borrow Gate 2's question without paperwork.

**Proportionality rule.** Gates 2 and 3 fire on their trigger, not on every
ticket: a copy change or one-line bug with a stack trace gets neither a carrier
identity card nor an ownership matrix. Gate 1 always runs but is three lines with
no designated baseline and no reference document. Gate 4 is a recompute, never a
rewrite. No gate licenses tracing to the DB / SP / provider "for completeness".

**Size is never an exemption from Gate 3.** Proportionality decides how *long* a
gate is, never whether it runs. The moment the change would touch code with more
than one caller - a shared helper, extension method, base class, filter,
middleware, common DTO - Gate 3 fires and owes a `Reuse` verdict, **even for a
one-line diff, even with a stack trace in hand, even when the change is only a
defaulted optional parameter**. Such a change is small in the diff and wide in
blast radius, which is the exact case this gate exists for; "the ticket was tiny"
is how it gets skipped.

---

## The five categories that must never be merged

Most of the damage these gates prevent starts as one being filed as another:

```
Requirement           what the Ticket must deliver                 (source level 1)
Baseline              what the designated existing feature actually does today
Gap                   requirement minus the target surface's current behaviour
Technical blocker     without it, safe implementation is impossible
Requirement decision  product has not decided whether to go beyond the baseline
```

A **requirement decision is never a technical blocker**: it produces
`STATUS: BLOCKED` only if safe implementation is genuinely impossible without the
answer (workflow steps 7-9). A capability the ticket never asked for is never a
**gap**, even when its absence is confirmed. Anything parked sits under an
explicitly non-scope heading, never in the gap table or the implementation plan.

---

## Gate 1 - Requirement Resolution

**When:** every Mode A ticket, after repository memory is loaded and **before**
Requirement Classification and Scope Definition (workflow step 6.5).

**Requirement source order** (the scope authority, HARD RULE 12):

```
1. Ticket / UA explicit requirement and acceptance criteria
2. The baseline the ticket explicitly designates ("比照 X", "跟 X 一樣")
3. That baseline's CURRENT ACTIVE behaviour  (Gate 2 confirms which carrier that is)
4. Reference documents - HackMD, old specs, historical design docs
5. Memory / prior analysis
```

- **Level 1 decides scope.** Nothing at levels 2-5 adds an implementation
  requirement, gap, blocker or data/persistence design on its own.
- **Level 2 is interpreted only by level 3.** "比照 X" means *reuse X as it behaves
  today*, not "port every historical spec about X"; a document describing X does
  not override what X currently does.
- **Levels 4-5 are background, navigation and capability discovery only.** A
  capability appearing only there is a `FOLLOW-UP`, entering scope only if it
  chains back to level 1 or the owner adopts it; a more complete document is not
  a more authoritative one.
- **Conflicts are not resolved by technical reasoning.** If the ticket and a lower
  level disagree on scope, record the difference and ask the requirement owner. (On
  *scope* the ticket wins; on *what the baseline currently does*, runtime/current
  code wins - different questions.)

**Required output** - `## Requirement Resolution` in the analysis document:

| Item | Ticket evidence | Designated baseline - actual behaviour | Classification |
|---|---|---|---|
| <behaviour> | explicit (AC #n) / absent | exists / differs / unknown / n/a | SCOPE / CLARIFICATION / OUT OF SCOPE / FOLLOW-UP |

List the ticket's explicit behaviours first; do **not** fill the list out from a
reference document. A behaviour the baseline lacks does not become a blocker -
only a level-1 requirement creates a gap. Reference/memory extras go in as
`FOLLOW-UP`, non-blocking, or are left out.

**Stop condition:** every level-1 requirement has a row with a classification.

---

## Gate 2 - Active Carrier Confirmation

**Trigger** - any of: the ticket targets a page, screen, app flow or user-facing
entry rather than a single named method; it says "比照 X" / designates an existing
feature as baseline; the domain is a known multiple-carrier domain
(`workspace/memory/shared/domain-entrypoints.md`); or more than one plausible same-named
handler / service / partial turned up.

**Not triggered** by a ticket that already names one endpoint or method and
carries a stack trace, or a pure library/backend change with one confirmed caller.

**When:** at the start of the scoped scan, **before** any downstream trace into
Service / DAO / DB (workflow step 9.5).

**Required output** - a **Carrier Identity Card** per involved carrier (the
ticket's target, and the designated baseline if there is one):

```
Carrier:                    <page / screen / app surface>
User entry & trigger:       <what the user opens or clicks>
Active frontend artifact:   <checked-in source | deployed artifact | runtime
                            evidence - say WHICH of the three it rests on>
Endpoint / action contract: <the endpoint that entry actually calls>
State mutation owner:       <what actually persists the change>
Status:                     ACTIVE | LEGACY / REFERENCE ONLY | UNKNOWN
```

- Identify **from the entry point downward**: page -> bundle/component/handler ->
  endpoint -> service -> DAO. Never upward from an endpoint name, a controller
  action name, or a grep hit.
- A same-named endpoint, same-domain service, same table, `...Ajax`-style action
  name or checked-in partial view are **candidates**, never evidence that a
  carrier is the active one.
- **Shared dependency is not the same flow.** Two carriers calling the same
  Service / DAO / table proves a dependency and nothing about UI interaction,
  endpoint contract or initial-value behaviour; shared dependencies get their own
  field, labelled as such.
- If the deployed artifact cannot be confirmed, status is `UNKNOWN` plus what
  evidence would settle it. Do not promote the most convenient candidate.
- Scope: enough to answer "which carrier is really used, what does it do, what can
  be reused" - not a full scan of the baseline. This makes `scoped-scan.md` ->
  "Same Domain, Multiple Carriers" a **required output** rather than a reminder;
  the caller-chain technique and domain list stay there.

**Stop condition:** each involved carrier has a card whose Status is `ACTIVE`,
explicitly `LEGACY / REFERENCE ONLY`, or `UNKNOWN` with the missing evidence
named. Only then trace downstream.

---

## Gate 3 - Capability Ownership, Reuse & Negative Evidence

**Trigger** - any of: the ticket reuses or depends on an existing verification /
limit / quota / counter / state machine / shared backend mutation; the analysis is
about to state that a capability is **missing**; or the change is about to add a
method, parameter, overload, wrapper or abstraction, or modify shared code
(P5 - Existing Capability First).

**Required output** - `## Capability Ownership`, with a `Result` per capability
(`CONFIRMED EXISTS` / `CONFIRMED MISSING` / `NOT OBSERVED IN TRACED PATH` /
`UNKNOWN`) and a `Reuse` verdict per existing one (`SUFFICIENT AS IS` /
`CALLER-SIDE` / `EXTENSION NEEDED`). Ask whether the ticket requires a capability
**before** tracing its owner; nothing new is designed on `UNKNOWN` or `NOT
OBSERVED`; and no shared code is modified while a row sits at `EXTENSION NEEDED`
without a user decision.

Full rules, the negative-evidence threshold, the seam inventory and the
`SHARED CAPABILITY EXTENSION APPROVAL REQUIRED` block: **`capability-reuse.md`**.

---

## Gate 4 - Final Consistency / Evidence Supersession

**When:** immediately before Approval Gate #1, and again after any evidence round
that overturns an earlier conclusion (workflow steps 17.4-18). A **recompute, not
a rewrite**: no re-scan, no regeneration - it removes conclusions newer evidence
killed and realigns scope.

```
1. Every implementation-plan item traces back to a level-1 requirement (Gate 1).
2. Every blocker genuinely prevents safe implementation - otherwise it is a
   requirement decision or follow-up, and is moved there.
3. Every MISSING meets Gate 3's threshold - otherwise demote it to
   NOT OBSERVED IN TRACED PATH or UNKNOWN.
4. Every carrier statement matches Gate 2's identity cards; no shared dependency
   does duty as a same-flow claim.
5. Every shared-code change has an answered Reuse verdict - nothing sits at
   EXTENSION NEEDED without a user decision (Gate 3).
6. Superseded conclusions are DELETED, not annotated. No "初版 ... 以下為準" double
   narrative, no UNKNOWN later evidence already resolved. Investigation history
   belongs in the conversation, not the analysis.
7. The test plan matches the final scope, and facts and root cause still cite
   evidence that survived this pass.
```

**Required output** - a short `## Consistency Pass` block: what was removed,
demoted or reclassified, or `No superseded content`. One or two lines is normal.

**Stop condition:** the document states exactly one version of the truth.
