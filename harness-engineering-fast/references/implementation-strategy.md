# Implementation Strategy

Budget: **T+15 - T+65** at a 90-minute total. Roughly 55% of the clock.

---

## Priority Order

```
1. Critical business rules
2. MUST happy path
3. Persistence / state correctness
4. Failure behavior
5. Core navigation / interaction
6. Critical validation
7. UI clarity
8. Polish
9. Optional enhancement
```

When time runs short, cut from the **bottom**. Never from the top.

The instinct under pressure runs backwards: polish is visible, business rules are
not. A delivery with beautiful styling and a broken ownership rule fails; a
delivery with plain styling and correct rules passes. Cut in the order above even
when the cheap win is at the top of the list of temptations.

**Ordering note.** Items 1 and 2 interleave in practice — a business rule usually
needs a happy path to live in. Build the happy path *with* its critical rule
enforced, rather than building the path and adding the rule afterwards. Rules
retrofitted at T+60 are the ones that get missed.

---

## Vertical Slice First

Build one complete path through every layer before broadening:

```
UI  ->  application  ->  persistence  ->  result visible again
```

Pick the slice that carries the most requirement weight — usually the primary
create-or-read flow with its critical rule attached.

**Why.** A horizontal build (all models, then all services, then all controllers,
then the UI) has no runnable state until the last layer lands. If the clock
expires at 80%, a vertical build has a working feature and a vertical build's
risks have already surfaced. A horizontal build has nothing to demonstrate and all
its integration risk still ahead of it.

**Anti-pattern to avoid:** spending T+15 to T+45 constructing layers, scaffolding,
base classes, and shared abstractions, and reaching T+45 with nothing executable.

---

## Checkpoints

Three mandatory checkpoints. Each is a real execution, not a judgment about the
code.

### CHECKPOINT A — Core flow executable

Target: ~T+35 (90-min budget).

The application builds, starts, and one core flow runs end to end. Confirmed by
running it.

**If A is late:** stop adding features. Get something runnable. An unrunnable
codebase at T+50 is a failed delivery regardless of how much was written.

### CHECKPOINT B — Critical business rules working

Target: ~T+55.

Every rule in the contract's Critical Business Rules section is implemented and
observed to behave correctly at least once.

**If B is at risk:** cut optional features immediately. Rules outrank features.

### CHECKPOINT C — Critical tests runnable

Target: ~T+65.

The verification harness exists and executes — the test command runs, the API is
reachable, the manual checklist is written down. Not that tests pass; that they
*can be run*.

**If C is at risk:** stop implementation now and enter verification. A tested
smaller delivery beats an untested larger one.

---

## Verification Reserve Rule

At least **15 minutes** (90-minute budget; scale with the table in
`lifecycle.md`) is reserved for verification and fixing. Implementation cannot
borrow from it.

When implementation overruns, the response is to **drop low-priority work**, never
to shorten verification. "Finish everything, then test if there's time" reliably
produces an unverified delivery, because there is never time.

At each checkpoint, ask one question: *if I stop coding now, can I still verify
what exists?* When the answer turns to no, you are already over.

---

## Working Rules

**Run the thing early and often.** The first successful start of the application
should happen well before Checkpoint A — ideally within a few minutes of the first
code. Discovering at T+50 that the environment cannot run the project is
unrecoverable.

**Keep it working.** Prefer small increments that leave the build green over large
refactors that leave it broken for ten minutes. A broken build at the verification
boundary costs the whole reserve.

**Do not refactor for elegance.** Refactor only when the current shape blocks a
remaining MUST.

**Do not add unrequested features.** The same Source Fidelity rule that governs
requirements governs code. A feature nobody asked for consumes budget that
verification needs, and it can violate a rule the contract never had to state.

**Handle failure behavior only where required.** Item 4 in the priority list means
the failure behavior the *contract* names — not a comprehensive error-handling
strategy.

**Write down what you skip.** When you cut item 8 or 9, note it immediately; it
becomes a Known Limitation at the final gate. Cuts remembered at T+88 are cuts
reported inaccurately.

---

## When You Discover a Requirement Problem Mid-Implementation

This happens, and it is legitimate. The response depends on what you found:

| Discovery | Action |
|---|---|
| A MUST is ambiguous in a way that changes implementation | Stop. BLOCKING QUESTION. This is what the freeze exception exists for. |
| A MUST is harder than estimated but clear | Continue. Cut from the bottom of the priority list. |
| The source contradicts itself | `SOURCE_CONTRADICTION` -> escalate; do not choose. |
| Architecture cannot satisfy a MUST | Reopen architecture (exception 1) — briefly. |
| You want a nicer design | Not an exception. Continue. |

Requirement Freeze exists to stop *reflexive* reopening, not to force you to
implement something you now know to be wrong.
