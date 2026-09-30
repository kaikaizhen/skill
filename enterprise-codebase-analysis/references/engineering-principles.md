# Engineering Principles

Five principles covering the engineering risk this skill exists to catch, so that
a new risk is **classified into one of them** instead of becoming another
checklist item (see "Adding a rule" at the bottom). They are reasoning tools, not
a per-ticket form: apply the ones this ticket's change actually touches, at a
depth proportional to it (`scoped-scan.md`). The required *outputs* are Gate 3's
and Gate 5's tables; everything here is how to fill them honestly.

| Concept | Lives in |
|---|---|
| Defense in Depth, Server-side Enforcement | P1 |
| Behavioral Contract Parity, Security Non-Regression, Side Effects, Auditability | P2 |
| Blast Radius Analysis | P3 |
| Idempotency / Duplicate Submission, Concurrency, Transaction Safety / ACID | P4 |
| Existing Capability First, SOLID / Maintainability, minimal change | P5 |

---

## P1 - Server-Side Authority

> The frontend is a usability layer. It is never a security or correctness
> boundary.

When the ticket involves a **mutation, verification, ownership, authorization,
eligibility, quota or amount**, confirm the rule is enforced on the server, by the
code that actually persists or authorises the change:

- Removing, hiding or disabling a UI entry point does **not** close the route
  behind it. The old route stays callable until the server refuses it.
- Client-side validation, a disabled button, a hidden field, a modal flow or a JS
  guard are defense in depth - additional layers, never the only layer.
- "The UI can no longer produce that state" is not evidence. The evidence is a
  server-side check cited at `path:line`, on the authoritative mutation path.
- If no server-side enforcement exists, that is a finding
  (`SERVER-SIDE ENFORCEMENT GAP`) and Gate 5 classifies it. Whether this ticket
  closes it is a requirement decision (HARD RULE 12); reporting it is not optional.
- This includes routes merely left behind: an endpoint the new flow stops calling
  is an active surface until a caller scan (P3) and an explicit decision retire it.

---

## P2 - Behavioral Contract Parity

> When an existing flow is modified, replaced, re-routed or refactored, compare
> the **whole contract** - not just "does the main feature still work", and not
> just "is the same row still written".

Seven contract dimensions, each a row in Gate 5's table:

```
1  Security / auth / CSRF   authn, authz, anti-forgery, ownership checks, and the
                            attributes/filters/middleware that applied before
2  Server-side validation   input validation, business-rule enforcement, state
                            preconditions (P1)
3  Data integrity           which fields/rows/flags are written, their values,
                            uniqueness and ordering constraints
4  Transaction / ACID       the transaction boundary and what sits inside it (P4)
5  Side effects             success AND failure paths: notifications, mail,
                            downstream calls, cache invalidation, queue messages,
                            counters, derived-record creation
6  Logging / audit / trace  what the old path recorded, at what level, with what
                            correlation id - and who consumes it
7  Caller compatibility     request/response shape, status codes, error codes,
                            headers, every other caller of what changed (P3)
```

Dimension 6 is a regression like any other: losing an audit trail is HIGH even
when the feature works, because it removes the ability to investigate the next
incident. A dimension the change does not touch is one word, `unchanged`. And
**parity is not preservation** - a difference the ticket explicitly requires is an
intended change; the ticket decides business behaviour (HARD RULE 12), while this
principle only ensures no difference goes *unnoticed*.

### Side-effect identity (dimension 5, and why it is the one that breaks)

Dimension 5 is where "the new path does the same thing" is usually wrong, because
a side effect's contract is not the method being called. **Calling the same method
is not the same contract.** Six attributes define it, each able to change without
the call site looking different:

```
Trigger      exactly which success / failure branches fire it, and which must not
Count        once per operation? per row? can a retry or a second entry double it?
Order        relative to the persistence, the response, and the other side effects
Sync / async inline on the request thread, or queued / backgrounded / fire-and-forget
Failure      when the effect itself throws: does the operation still report success,
             does it roll back, does the caller learn
Reliability  guaranteed delivery - survives a process recycle, retried, durable -
             or best effort that can silently vanish
```

Wrapping an inline call in a background task, a `try`/`catch` or a helper changes
Sync/async, Failure and Reliability at once while the diff still shows the same
method name. That is a contract change, reported as one, whatever the wrapper is
named.

Side effects are found from **both** success and failure paths, and include the
indirect ones: what the service, DAO, trigger, handler or domain hook fires
downstream, not only what the changed method calls directly. An effect no longer
reachable from any success path has been lost even when its code still exists.

---

## P3 - Blast Radius

> Before changing shared code, know who else runs it.

Triggered by a change to a shared endpoint, service, DAO, helper, extension
method, base class, filter, config, DTO, DB object, or any contract crossing a
repository boundary.

- Enumerate callers from code, not from the change's purpose: grep the symbol, the
  route, the column, the config key; check DI registration, filters, middleware,
  background jobs, and the other repositories in this flow.
- **Absence of a caller in this repository is not confirmed absence of callers.**
  Mobile apps, other repos, partners, scheduled jobs and deployed frontends
  don't appear in this repo's grep output - `UNKNOWN`, stating what breaks.
- A change that *tightens* a shared contract (new required validation, a token, a
  stricter status) breaks every caller that does not already satisfy it. Update
  those callers in the same change or stage it - never ship the tightening alone
  on the assumption that there are none.
- **Extending a shared method is a blast-radius event, not a local edit.** A new
  parameter, overload, flag or branch changes a contract every caller, test and
  reviewer depends on, even when it defaults to the old behaviour. It needs the
  caller enumeration above *and* the user's decision (P5, Gate 3) beforehand.
- **A side effect added to, removed from or re-wrapped inside shared code reaches
  every caller**, not only the ticket's. Adding a notification to a shared success
  path sends it for all of them; wrapping a shared hook in a swallow-and-log makes
  every caller stop failing on it. Each is a P2 delta *per caller*.
- When one side effect is invoked from several call sites, they must end up with
  **one** contract. A diff leaving some inline and others wrapped has created two
  failure semantics for one behaviour; say so rather than treating the touched
  sites as the whole picture.
- Result vocabulary: `CONFIRMED SOLE CALLER` / `CALLERS ENUMERATED (n)` /
  `UNKNOWN CALLERS`, each with what was searched.

---

## P4 - State Safety

> Repetition, concurrency and partial failure are normal in production, not edge
> cases.

Applies when the change writes state, spans more than one write, or is reachable
more than once.

**Idempotency / duplicate submission.** A double-click, retry, resend, refresh or
replayed request must not produce a second effect. Name the authoritative guard: a
unique constraint, a conditional update, a token, a state check - not a disabled
button, which is P1's client layer.

**Concurrency.** Two requests for the same subject may interleave; `read -> check
-> write` without a guard is a race. Name the guard (DB constraint, isolation
level, optimistic concurrency / rowversion, atomic update, lock) or record its
absence and the window.

**Transaction safety / ACID.** When a unit of work spans several mutations,
tables, state flags or an external call:

```
Atomicity    all-or-nothing - name the boundary, and every mutation in and outside it
Consistency  invariants across the affected tables/flags still hold afterwards
Isolation    what a concurrent reader/writer can observe mid-flight
Durability   the point after which the change survives a crash
```

- The failure to look for is the partial update: step 1 commits, step 2 throws,
  state is half-changed with no rollback and no compensation.
- An external call (mail, SMS, HTTP, queue) **cannot be rolled back**: place it
  after the commit or make it compensatable, and say which.
- Legacy code often has no explicit transaction. Recording `no transaction
  boundary; N independent writes; partial-failure state = <what>` is a valid
  answer; introducing one is a scope decision the ticket must authorise.

---

## P5 - Existing Capability First (SOLID proposes, it never authorises)

> If the code that already exists can carry this ticket safely, it is neither
> extended nor refactored.

### Existing Capability First

Before writing a method, parameter, overload, wrapper or abstraction, establish
what existing shared code can already do. Three outcomes, in order:

```
1 It already supports this   USE IT AS IS. Add no method, overload, parameter,
  need as it stands          flag or layer for something already reachable. The
                             seam the ticket needs is usually an extension point
                             already there - a delegate, callback, strategy,
                             handler, optional argument or fallback already
                             being passed in.
2 It cannot support it       Name the concrete limitation at path:line first.
                             "I did not immediately see how" is not a limitation
                             (negative evidence / Gate 3). Then check whether the
                             CALLER can meet the need with the shared code
                             untouched.
3 Extension is genuinely     STOP. Do not modify shared code on your own
  needed                     initiative. Present the limitation, the options and
                             the impact on every other caller; the user decides.
```

- Outcome 3's block is `SHARED CAPABILITY EXTENSION APPROVAL REQUIRED`
  (`capability-reuse.md`, Gate 3). Silence is not approval.
- **A backward-compatible extension is still a change to shared code.** An optional
  parameter with a default, a new overload or an extra branch alters a contract
  other callers, their tests and their reviewers depend on. "It defaults to the old
  behaviour" lowers the risk; it removes neither the decision nor P2 and P3.
- Order of preference: use the existing seam as-is -> solve it at the caller ->
  extend shared code with approval. A new shared abstraction comes last.
- The smallest change that satisfies the ticket wins. A diff touching only the call
  site the ticket is about beats one that touches shared code and every caller's
  risk surface, even when the latter looks tidier.

### SOLID / Design Pattern Strategy

Whether a pattern decision needs a user proposal, or is the ticket's own work,
is set by its classification (`scoped-scan.md` -> Depth By Issue Type):

| Classification | Pattern decision |
|---|---|
| Bug / Feature / Migration | "It would be more SOLID" is **never on its own a sufficient reason** to restructure legacy code. Offered only when all four preconditions in `development-convention.md` §3 hold (no business-behaviour change with evidence, confined to this ticket's code path, existing tests still express the same requirements, a nameable maintenance gain); anything wider is a one-line follow-up note, not this ticket's diff. |
| Optimization / Refactor | The design decision **is** the ticket's scope, not scope creep. After the scoped scan and before implementing, plan it - readability, maintainability, testability, coupling, reuse/extensibility - naming a pattern only where it earns its place against a concrete, present need, never a hypothetical future one (`development-convention.md` §3). |

SOLID's diagnostic use is unchanged either way: naming why a change is risky
(one class doing three jobs) and recognising a pattern the repo already uses.
A refactor in scope still owes the full P2 comparison - that is where
behaviour-preserving refactors hide a contract loss.

---

## Adding a rule (skill evolution)

Before a retrospective adds anything to this skill:

1. **Classify it.** Does it belong to P1-P5, an existing gate, or an existing hard
   rule? If so, sharpen that text - do not add a new rule or a new gate.
2. **Generalise it.** A finding is written as the engineering concept, never as the
   ticket's method, endpoint, table or class name. Ticket specifics belong in
   `<workspace>/issue/<Repo>/`, or as a worked example in `examples.md`.
3. **Consolidate.** If two or more existing rules turn out to be the same concept,
   merge them and delete the duplicates. A shrinking rule set that catches more is
   the goal; a growing checklist is the failure mode.
4. **Make it checkable.** A rule with no output and no stop condition is a
   reminder, and reminders do not change behaviour. Prefer a required field in a
   gate's table over another paragraph of prose.
5. **Budget.** Every `SKILL.md`, reference and template stays at or under 250
   lines. If a change would exceed that, something has earned deletion.
