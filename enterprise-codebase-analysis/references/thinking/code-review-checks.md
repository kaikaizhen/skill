# Review Checks - the six categories a review always runs

Loaded with `../code-review.md` (Mode R), and usable at Gate 6 when a change touches
the same ground. These are **default** checks: a review runs all six without being
asked for them, and without waiting for the user to name a category.

**Every item is a question, not a verdict.** A check that cannot be answered from
the code in front of you produces a ❓ row (`../code-review.md` §5.5), never an
asserted defect. Depth per category follows the change's blast radius
(`code-quality-gates.md` §0.1) - the questions are always asked, how far you trace
to answer them is not.

**Threshold values are never invented here.** A timeout, a page size, a retry count
or a length limit is judged against *the repository's own rule document* and its
surrounding code. Where that document gives a **recommended** value, it stays a
recommendation in the report - this file never promotes it into a hard standard.
Where it is silent, the finding is "no explicit timeout / limit at all", not "the
value is wrong". This organization's concrete rules (parameter syntax, forbidden
columns, secret locations, business-rule files) live in the workspace, indexed from
`workspace/PROFILE.md` -> Organization-Specific Procedures.

## 1. Correctness

- Business rule: does the code do what the requirement, the ticket or the
  repository's business-rule documents say? A conflict with a recorded business
  rule is a finding, not a style note.
- Boundaries: `null`, empty string, **leading / trailing whitespace**, case
  sensitivity, identifier format (GUID / numeric id / code value), collection
  empty, off-by-one. See `code-quality-gates.md` §3 for the full boundary set.
- **Two validation layers must agree**: a declarative validator (attribute /
  validator class / model binding) and the service's own guard clauses must not
  state different rules for the same field - and the service must still guard even
  when the validator exists, because the validator is not the only caller's path
  (P1: the outer layer is not a security boundary).
- Was existing behaviour changed unintentionally? That is Gate 5's table
  (`regression-validator.md`), referenced here, not repeated.

## 2. Security

- **SQL**: is every externally-influenced value parameterised? Look for string
  interpolation, `string.Format`, concatenation and dynamic clause building in any
  query - including values that arrive from a header, cookie, query string, route
  value, token claim or an upstream service, not just a form field. Dynamic SQL
  built per-field must follow the parameter-placeholder syntax the repository's own
  rule document mandates for its data-access stack; the wrong placeholder form is
  a defect even when it is parameterised, because the parameters can bind in the
  wrong order.
- **Authorization / IDOR**: is the endpoint actually protected (attribute, filter,
  middleware or global registration - check every registration path), and is the
  acting identity taken from the **verified credential** (token claim, session,
  authenticated principal) rather than from a request parameter the caller can
  change? A request-supplied owner id on a read or write of someone else's data is
  a 🔴 建議修正, and the usual shape is "the id is in the DTO".
- **Output encoding**: can returned content reach an HTML / WebView / template
  renderer unencoded - a hand-rolled serialisation, a raw string or HTML field, a
  path that bypasses the project's global encoder?
- **One-time codes / OTP**: expiry, attempt limit, binding to the same identifier
  that requested it, and a **send-side rate limit**. Missing any one of the four
  makes the code brute-forceable or the sender abusable.
- **Secrets**: is a key, token, authorization code or connection string written in
  source instead of configuration / a secret store? Report the **location only** -
  never copy the value into the report or into memory (HARD RULE 3).
- **Reserved / infrastructure columns**: does the change read or write a column the
  repository's rules forbid using as business data (replication, sync or
  system-maintained columns)? Such a column is not a stable value, so any logic
  keyed on it breaks when the infrastructure feature is turned off.

## 3. Performance and I/O

- Redundant or repeated queries for data already in hand; the same query inside a
  loop (N+1); any I/O inside a loop (DB, cache, HTTP, mail, file).
- A LINQ lookup re-executed per iteration where a dictionary / lookup built once
  would answer it; **materialising too early** (`ToList` / `ToArray` in a
  repository before the filter is pushed to the data store).
- Every external call (mail, SMS, HTTP, cache, search) has an **explicit timeout**
  and a defensive fallback - a logged degradation that returns a predictable
  result instead of failing or hanging the whole request. The value comes from the
  repository's rule document, as above.
- No unbounded wait: a busy-wait, a poll or a retry loop with no timeout and no
  attempt ceiling.
- HTTP client lifetime: a client constructed per call exhausts sockets; the
  project's pooled / factory mechanism is the expected form.
- Independent external calls that could run concurrently but are serialised are
  🟡 建議改善 (an optimisation), not a 🔴.

## 4. Asynchrony, transactions and locking

- **Blocking an async chain** - `.Result`, `.Wait()`, `.GetAwaiter().GetResult()`.
  **Seeing one is not a finding by itself**: never conclude "this deadlocks" from
  the call alone. Read the actual calling context - which runtime hosts it, whether
  a request synchronization context exists there, whether the awaited work can
  complete on another thread, and how hot the path is. Then report what is true
  for *that* context: with a request synchronization context, synchronous waiting
  on async work can deadlock; without one (e.g. ASP.NET Core) the specific risk is
  **thread-pool starvation** - delayed responses and, under load, a stalled
  service. Neither is "harmless", and neither verdict may be copied from another
  repository's conclusion.
- `async void` outside an event handler; a fire-and-forget task that is never
  awaited - its exceptions are lost and any scoped dependency it holds may already
  be disposed.
- Transactions: is the async-flow option set (so the ambient transaction survives
  an `await`), is the isolation level explicit, is there a timeout? Does the scope
  span more than one connection or resource manager - which can escalate to a
  distributed transaction - and does it contain an external HTTP / mail call or
  other slow work that holds locks for the duration?
- Is the transaction boundary wide enough to cover every write that must be atomic,
  and no wider? For a delete-then-insert set, or any path reachable twice, check the
  layered guard - lock, idempotent write, transaction - and which layers are actually
  present (`duplicate-write-defence.md`).

## 5. Exception handling and partial success

- **Post-write side actions**: when the data write succeeds and a follow-up action
  (mail, push, log, analytics, cache invalidation, a change hook) fails, what
  happens? Three distinct outcomes to separate, each with a different verdict:
  the caller gets an error although the data was committed; a later required step
  is skipped; or the failure is correctly degraded and logged. The first two are
  findings - say which one, with the committed data named.
- Empty `catch`, or a catch that neither logs with context nor rethrows.
- A caught exception that still reports success (Gate 5 check 3).
- Order and specificity of failures - required vs format vs business vs system
  (`code-quality-gates.md` §5).

## 6. Project convention conformance

Checked against the repository's **own** rule document and surrounding code
(`../development-convention.md` §1), never against a generic style preference:

- layering / dependency direction, and whether the change put logic in the right
  layer;
- naming, including the asynchronous-method suffix the project uses;
- dependency registration: is a new service registered at all, and is its
  lifetime sound? **A longer-lived service capturing a shorter-lived dependency**
  (a singleton holding a scoped repository) is a 🔴 建議修正 - it either throws at
  resolution or silently reuses one scope's state for the whole process;
- documentation comments and log messages in the project's required language;
- structured logging with named placeholders, not an interpolated message string;
- nullability annotations and null guards as the project requires;
- tests added or updated where the project requires them, and the project's own
  verification route when it has no automated suite (compile + documented manual
  calls) - report that route honestly rather than claiming tests exist.
