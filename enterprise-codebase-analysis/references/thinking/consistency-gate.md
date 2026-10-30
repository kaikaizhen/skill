# Gate 7 - Codebase Consistency

**Understand the existing design before deciding whether a new one is needed.**

Runs inside Mode A's solution step (workflow §14-17), **before** the candidate
solutions are written - its findings are what those candidates are built from. It
feeds the existing decision flow and adds no parallel approval: the recommendation
lands in `../change-proposal.md` §4 (candidates) and §7 (Approval Recommendation).

Depth follows the tier set by `risk-tiers.md`:

| Tier | What Gate 7 produces |
|---|---|
| **L1** | three short lines: does it follow existing practice · does it change any meaning · any obvious compatibility problem. No report block. |
| **L2** | which similar implementations exist · whether they can be reused · whether the new approach is justified · whether it creates an unnecessary design difference. |
| **L3** | the full block in §6. |

It never replaces Gates 1-6, HARD RULES, the approval gates, or the git / DB safety
rules. Where it would repeat an existing rule, it cites it instead.

## 1. Existing Implementation First

Before proposing anything new, establish - at the tier's depth - whether something
reusable already exists. This is Gate 3's reuse judgement applied to *design*, not
just to a method signature (`capability-reuse.md`, P5 in `engineering-principles.md`):

- How is this kind of thing implemented today?
- Is there already a shared service, helper, utility or component for it?
- Is the same business data handled some other way elsewhere?
- Does an identity, ordering, validation or conversion mechanism already exist?
- Can the existing approach be reused directly, or extended modestly?
- **Would the new approach leave one concept with two contradictory handlings?**

### Existing Data Strategy First

When the requirement touches how data is **identified, updated, deleted, copied or
restructured**, first establish what each affected repository already does for the
*same business function*. Removing `rowguid` is not a cue to invent a composite GUID,
a hash, an index or a new identity column - it is a cue to read how the live projects
already save that data. Where a project already does *delete the whole set, then
insert it again*, that flow is a first-class candidate and is evaluated **before** any
new identifier.

Two cautions that invert the usual conclusion: **a column existing does not mean the
function depends on it**, and **a repository having a batch-update method does not mean
every single-row feature can be removed**.

Full rules - the strategy taxonomy, the cross-repository comparison table, the
reuse-priority order, the eight preconditions for whole-collection replacement, and
the list of unnecessary new identity mechanisms that must be warned about:
`data-strategy.md`. It is part of this gate, not a separate gate.

### Finding similar code is not a reason to reuse it

Before reusing, confirm all five:

1. the **business meaning** is the same;
2. the **data source and lifecycle** are the same;
3. the **use cases** are compatible;
4. the existing design's known limitations are acceptable here;
5. reuse genuinely lowers long-term maintenance cost.

**Rewriting because it is faster than reading is forbidden. Forcing an unsuitable old
design on a new need, in the name of uniformity, is equally forbidden.**

> Project consistency means the same business concept has a consistent division of
> responsibility, meaning and design principle - **not** that all code looks alike.

## 2. Semantic Integrity

When a field, variable, model, DTO, API or database structure changes, answer - at
the tier's depth:

```
1 What business concept does it represent today?
2 Who produces the value?
3 Where does it come from and where is it stored?
4 Which features read it, and which modify it?
5 Is it used for identity, ordering, relation, or display?
6 Does it still mean the same thing after the change?
7 What else depends on its original meaning?
```

## 3. Semantic Overloading - forbidden

**Never put a new concept into a field that means something else, just to avoid the
cost of changing things properly.** Every one of these is semantic overloading:

- a field meaning "database row identifier" now holding an identifier computed from
  content;
- a field meaning "permanent identity" now holding a transient array index;
- a field meaning "business result" now carrying an error state;
- an API that returned a valid identifier now returning an empty string, with no
  consumer confirmation;
- **the field name unchanged while its business meaning is entirely different.**

**The same data type does not mean the same semantics.** Two values can both be
`GUID` and still be different business concepts; two `INT`s can be a row id and a
display order.

When the meaning genuinely must change, evaluate in this order: a **new field** · a
**rename** · an explicit **conversion layer** · an **API version or compatibility
path** · a design another module already uses successfully.

If an external compatibility constraint forces the historical field *name* to stay,
then isolate the conversion responsibility in one place, record the old and the new
meaning plus the migration route, and **do not describe it as fully compatible** - it
is a documented, time-boxed exception.

## 4. Identifier Lifecycle

Runs **only** when the change touches an ID, GUID, key, index, hash, sequence or
token mechanism. Then it is mandatory:

- Does it identify a **database row**, a **business entity**, or a **screen item**?
- What is its valid scope and lifetime?
- Deleted and re-created: must it still identify the same business entity?
- Does **re-ordering** change the identity?
- Can identical content produce the **same** identifier?
- Does editing the content change the identifier?
- Do frontend, backend and external systems use the **same** mapping rule?
- Is there a concurrent-modification or race problem?
- Does the project already have an identity mechanism that can be reused?

Hard limits:

| Claim | Reality |
|---|---|
| a stable hash | does not guarantee business uniqueness |
| a GUID shape | does not guarantee consistent meaning |
| an index | is not necessarily a durable identifier |
| a column combination | is not automatically a unique business key |
| delete-all-then-insert | does not make ordering or identity mapping stable |

**Never propose replacing an existing identifier with a hash, GUID or index until the
items above are confirmed.** Related: `table-design.md` §1 (technical PK vs business
unique key) and §4 (UPSERT concurrency).

## 5. Cross-Layer Contract Consistency

For an API, cross-module or cross-repository change, trace - to the extent the actual
impact requires:

```
produced -> stored -> queried -> transformed -> API output -> consumer -> what it then does
```

Check: format and meaning identical at each hop · frontend and backend using the same
identity rule · external services depending on the original field · how many callers
must change together · whether historical data stays compatible · whether the
deployment order and the rollback are safe. The seven contract dimensions and the
regression grade stay with Gate 5 (`regression-validator.md`); this section is about
**meaning surviving the whole path**.

When a consumer cannot be reached, label it `UNKNOWN` or
`NEEDS HUMAN CONFIRMATION` - never silence.

**Not finding a consumer is not proof there is none. Not finding a caller does not
make the code dead.** Without evidence, never recommend removing the feature,
dropping support, or returning a default value.

## 6. Solution Comparison and the Gate output

Compare only real options - typically: reuse the existing design · extend the existing
capability · add a separate, semantically explicit mechanism · change the API or data
contract · another necessary alternative. **No fixed number of options is required**
and a manufactured alternative is a defect (`../change-proposal.md` §4).

Weigh them on:

| Aspect | Question |
|---|---|
| Correctness | does it meet the requirement |
| **Existing Strategy** | how does the project already handle this kind of data (`data-strategy.md`) |
| **Existing Reusability** | can an existing feature be reused as it stands |
| **Cross-Repository Consistency** | do the related projects already share one business approach |
| **New Mechanism Necessity** | is a new identity mechanism genuinely required - why can the existing strategy not do it |
| **Behavior Preservation** | does the user-visible and API behaviour stay as it is |
| **Migration Risk** | does it add deployment, data-migration or rollback risk |
| Consistency | does it fit the project's existing design |
| Semantic Integrity | does meaning stay clear |
| Reusability | can existing capability carry it |
| Compatibility | does it affect existing consumers |
| Maintainability | will the next person understand it |
| Risk | data or regression risk |
| Scope | real change and deployment cost |
| Validation | can it be proven |

**Where several projects already use the same effective strategy, that is strong
evidence for recommending it** - but weight of numbers alone does not decide: business
need, compatibility, data integrity and risk still apply. Where a minority of projects
differ, say whether that difference is a real requirement, historical compatibility,
or an unnecessary divergence.

**None of these alone makes an option best**: not the fewest lines changed, not "the
frontend needs no change", not "the API shape is unchanged", not "it passes the tests
quickly". Where the smaller option creates semantic confusion, state the technical
debt and the long-term risk explicitly. Conversely, a larger refactor being tidier is
not a reason to recommend it - decide on requirement, existing design, risk and
long-term maintenance cost together.

### L3 output block

```
GATE 7 - CODEBASE CONSISTENCY            Tier: L3
Existing Patterns     <what exists, path:line, and whether it is reusable>
Semantic Consistency  <meaning before -> meaning after, per field touched>
Solution Comparison   <the real options, against the aspects above>
Consistency Recommend <the option that best fits this project's design, and why>
Open Questions        <unconfirmed contract, risk or decision - with the question>
Verdict               PASS | PASS WITH CONDITIONS | NEEDS HUMAN DECISION | BLOCKED
```

| Verdict | Means | Effect on the approval flow |
|---|---|---|
| `PASS` | consistent with existing design; no meaning changed, or the change is explicit and justified | does not constrain §7's verdict |
| `PASS WITH CONDITIONS` | sound, but conditional on something nameable - a rename, a conversion layer, a consumer confirmation | those conditions become §7's `APPROVE WITH CONDITIONS` conditions |
| `NEEDS HUMAN DECISION` | semantic or identity question with two defensible answers, or an unreachable consumer that matters | §7 cannot be `APPROVE`; it becomes `NEEDS HUMAN DECISION` |
| `BLOCKED` | would overload a field's meaning, break an identifier, or silently change a contract - and no accepted alternative exists | §7 is `NOT RECOMMENDED` until resolved |

The gate **recommends**; it never self-approves and never bypasses Approval Gate #1.
A `NEEDS HUMAN DECISION` or `BLOCKED` verdict is stated with the exact question to
answer - the agent does not choose a business rule for the user (HARD RULE 12).
