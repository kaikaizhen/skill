# Encoded Values (Magic Numbers / Strings)

Load when the code path a proposal touches - or a change being reviewed - contains a
literal that carries meaning the number itself does not show. This is an **auxiliary
analysis inside existing Mode A artifacts**, not a mode, not a gate, not a workflow:
it feeds Current Production Behavior, Candidate Solutions, Recommended Change,
Proposed Code Changes, Impact/Blast Radius and the Implementation Handoff.

Applies equally when the user brings their own change - "review this proposed diff",
"這樣改會不會有問題" - not only to a first proposal (§10).

---

## 1. What counts

> Does this literal carry domain / protocol / state / business meaning that the
> number alone does not reveal?

Yes -> analyse it. Typical carriers:

```
status code · bit flag · bit mask · business threshold · retry count · timeout
page / result limit · ranking weight · percentage · date window · special id
type code · mode code · legacy protocol code
```

```csharp
if (status == 3)                    if ((flags & 4) == 4)      Take(5)
if (retryCount > 7)                 if (score >= 60)
```
```sql
WHERE status = 2      (AccountFlag & 4) = 4      TOP 10
DATEDIFF(DAY, createdAt, GETDATE()) <= 30
```

## 2. What does not count

Self-evident literals with no hidden meaning are **not** reported. Do not pad the
table to satisfy the format:

```csharp
i + 1        index >= 0        items.Count == 0        Take(1)
DateTime.AddDays(1)   // when it genuinely means "the next day"
```

A literal whose surrounding method name or comment already states its meaning, used
once, is also not a finding - say nothing rather than manufacture one.

## 3. Evidence, and the UNKNOWN rule

A meaning is a claim and needs evidence. Before asserting what a value means, search:

```
enum · named constant · DTO / field comment · DB schema or column comment
stored procedure · nearby code · mapping table · frontend mapping
tests · existing switch/case · bitwise operations · legacy documentation
```

Label every row `CONFIRMED` / `INFERRED` / `UNKNOWN` (the five statuses in
`memory-system.md` §5 apply unchanged).

**`UNKNOWN` is never filled in with a guess.** With `WHERE upload & 4 = 4` and no
mapping found, the row says `Meaning: Unknown`, evidence `bit-mask behaviour only`.
Explaining the *mechanics* is still correct and useful:

```
4 = binary 0100 -> tests whether bit 2 is set
```

Inventing `EmailVerified` / `ResumeUploaded` / `MobileVerified` without repository
evidence is forbidden, and so is renaming such a value in a proposal
(`Recommendation: do not rename until the meaning is confirmed`).

## 4. Scope of the scan

Scoped, per `scoped-scan.md` - never a repository-wide literal audit:

```
directly affected files · nearby shared capability · relevant SQL / stored procedures
relevant DTO / enum / constants · relevant callers only when the value crosses them
```

## 5. Report section

Only when a relevant encoded value was actually found. **No finding -> the section
does not appear**; never emit an empty table.

```markdown
## Magic Numbers / Encoded Values

| Value | Location / Expression | Meaning | Encoding / Behavior | Evidence | Confidence | Recommendation |
|---|---|---|---|---|---|---|
```

Every row answers: what is the value · where · what it means · how the code actually
uses it · the evidence · whether it is worth changing.

### Bit flags and masks

A flag or mask row also gives decimal, binary, bit position, the operation, and the
combined meaning - then translates the expression into words:

```
1 = 0001   bit 0        (flags & 2) == 2   -> is bit 1 set?
2 = 0010   bit 1        (flags & 3)        -> keep only the lowest two bits
4 = 0100   bit 2
3 = 0011 = 1 | 2
```

If a bit's domain meaning is unconfirmed, explain the bit operation and stop there.

## 6. Quick Behavior Comparison

When the value matters for understanding the proposal, follow the table with short
pseudocode - so a reviewer need not read C# or SQL bit arithmetic:

```markdown
### Quick Behavior Comparison
```

```
Current:            Take upload, keep only bits 0 and 1
                    IF both bits are ON -> execute action
Semantic view:      IF MobileVerified AND EmailVerified -> execute action
```

The semantic line is written only for `CONFIRMED` meanings. Unconfirmed stays
mechanical - `IF status equals legacy code 7` and never `IF status is Completed`.

When the proposal actually changes how the value is expressed, add Before / Proposed:

```
Before:    IF status == 3                      -> publish job
Proposed:  IF status == JobStatus.Publishable  -> publish job

Before:    IF (upload AND 3) == 3              -> user has both required flags
Proposed:  requiredFlags = MobileVerified OR EmailVerified
           IF upload contains all requiredFlags -> user has both required flags
```

## 7. Recommendation vocabulary - finding one is not a mandate to refactor

| Recommendation | When |
|---|---|
| `REUSE EXISTING` | an enum / constant / option already defines this value (§8) |
| `KEEP AS IS` | single occurrence, meaning already evident from name or comment, no business rule - extracting would not improve readability |
| `EXTRACT NAMED VALUE` | repeated, a business rule, likely to change, hard to read, or shared across layers - and nothing existing covers it |
| `DO NOT RENAME YET` | meaning is `UNKNOWN` |

Judge on: repeated? · a business rule? · likely to change? · hard to understand? ·
shared across layers? · already has an enum/constant? A lone `Take(5)` next to a
method named `TopFiveRecommendations` is `KEEP AS IS`.

Extraction that is not required by the ticket is a **Recommended refactor**, filed as
such (`change-proposal.md` §3) - never silently added to the diff.

## 8. Reuse before defining (Gate 3)

A named value is an existing capability, so Existing Capability First applies
(`capability-reuse.md`). Search order:

```
existing enum -> existing named constant -> existing options/config
-> nearby mapping -> only then propose a new named value
```

If `JobStatus.Active = 3` exists and the code says `status == 3`, the recommendation
is to reuse it. Creating `NewJobConstants.Active = 3` alongside it - a second
definition of one value - is the failure this rule prevents.

## 9. Contract parity, and when a number is behaviour

The **numeric value itself is often production contract** - a DB status code, an
external protocol code, a legacy bitmask. Improving readability must not change it:

```csharp
enum JobStatus { Published = 3 }   // correct: readability improved, value preserved
enum JobStatus { Published = 1 }   // forbidden: silently breaks DB / API /
                                   // serialization / SP / legacy and external callers
```

This is assessed in **Gate 5 Contract Parity** (`regression-validator.md`) - rows 3
(data integrity) and 7 (caller compatibility). Do not build a second parity
mechanism for encoded values.

**Changing a numeric value is a behaviour change, not a cleanup.** Report the two
separately and never present the pair as "removing a magic number":

```
Structural cleanup:  30 -> DefaultTimeoutSeconds   (same value, named)
Behavior change:     30 seconds -> 60 seconds      (AC #n, Gate 5 delta, risk graded)
```

A reviewed change that alters numeric semantics is marked
`BEHAVIOR CHANGE / CONTRACT RISK` explicitly.

## 10. Where it appears in the report

| Artifact | What encoded values add |
|---|---|
| Current Production Behavior | the table + Quick Behavior Comparison - what today's numbers actually control |
| Candidate Solutions | **only when the encoding drives the choice** - e.g. keep numeric + comment vs reuse an existing enum vs introduce a domain enum/flags. Otherwise it stays an understanding aid, not an option |
| Proposed Code Changes | the named-value change, with the preserved numeric value stated |
| Impact / Blast Radius | every layer reading the same encoding - DB, SP, API, serialization, other callers |
| Implementation Handoff | `Encoded values that must remain unchanged:` listing each value, plus `Do not change persisted numeric values.` so a later agent does not "tidy" an enum into incompatibility |

## 11. Magic strings

The same rules cover an encoded string literal found in the same affected code -
`status == "A"`, `type == "01"`, `mode == "P"` - which is why the section is named
**Magic Numbers / Encoded Values**. This never widens into a repository-wide string
audit; the scope in §4 still binds.
