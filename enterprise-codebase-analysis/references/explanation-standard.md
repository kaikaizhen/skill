# Response & Explanation Standard

How every human-facing output is written - any chat reply, a Mode C answer, a Mode B
summary, a Mode R review, the reply that presents a Mode A report. Load whenever a
reply is being written, not when deciding what is true (that is the gates and the
evidence rules).

```
Full analysis is the agent's job.  Being easy to understand is the output's job.
After reading, the user knows: current state -> where the problem is
-> how to fix it -> what to do next.  Without re-organising the answer themselves.
```

This file governs **presentation only**. It never lowers scan depth, skips a gate,
drops an evidence label or a HARD RULE line. Gate records still live in the local
issue file (`usage.md` -> Output Locations); the reply shows the digest.

---

## 1. Base rules (every reply, every mode)

1. **Conclusion first.** Line one answers the question. No background, purpose
   statement or analysis narrative before it.
2. **Short by default.** Show what matters most; never a multi-page report unasked.
3. **Tables first - not tables always.** Use one when comparing, listing states,
   problems or steps. A one-line answer stays one line.
4. **Visuals only when they carry meaning.** Arrows, a small Mermaid flow, ✅ ❌ ❓
   for a complex flow - never decoration.
5. **Concrete and executable.** Never "improve validation" / "optimise the logic".
   Name the API, method or mechanism: `value.trim()`, `int.TryParse()`, an
   `isSubmitting` guard, `path:line`.
6. **No repetition.** What is already clear is not explained again.
7. **Do not widen the scope.** One question -> one answer. No unasked research
   report, no unasked "while I was there" list.
8. **Format follows the question**, not the mode's maximum template.

## 2. No cross-references - every item stands alone

Forbidden in reader-facing output:

```
"C-01 affects C-02"        "see B-02 above for the reason"
"same handling as C-05"    "per section 3.2"      "see finding #3"
"see Gate 5 row 4"         "as discussed earlier"
```

Each row / finding states its own problem, cause and fix in full. IDs are allowed
as labels, never as a substitute for content. If two items share a cause, say the
cause in both (one short phrase) or merge them into one row.

## 3. Length

| Question | Default size |
|---|---|
| Simple fact ("which table", "is it called") | 1-3 sentences |
| Ordinary technical question | conclusion + only the necessary explanation |
| Review / analysis | the 3-5 most important items; say how many more exist and that the full list is in the file / on request |
| Complex problem | summary + handling order first, then the needed detail |
| The user asks for detail | expand fully |

These are defaults, not word limits. **Never cut a key fact, a blocker, a HIGH
regression, an evidence label or a required approval line to save space.**

## 4. Shape by task

Pick the one that fits; mix only when the question really spans two.

**Status / progress** (Mode B summary, ticket status, "where are we")

| 狀態 | 項目 | 目前結果 | 下一步 |
|---|---|---|---|
| ✅ / ❌ / ❓ | | | |

✅ done · ❌ has a problem · ❓ to confirm.

**Code review / code analysis** (Mode R, Gate 6 findings, a review inside Mode A)

Three axes, kept apart - **severity is not a verification state, and neither is
"new or pre-existing"**. A finding row carries all three:

| 嚴重度 | 驗證 | 新舊 | 程式來源 | 原因／風險 | 建議修改方式 |
|---|---|---|---|---|---|
| 🔴 建議修正 | ✅ 已驗證 | 本次新增 | `path:line` | trigger -> impact | the concrete API / method / mechanism |

| Axis | Values |
|---|---|
| **嚴重度** (how bad if real) | 🔴 建議修正 - clear defect or major risk, fix before this change goes out · 🟡 建議改善 - a real but narrower problem, or maintainability / performance / readability worth fixing · 🟢 小問題或備註 - minor point or note, no action required |
| **驗證狀態** (how sure we are) | ✅ 已驗證 - confirmed from the evidence at `path:line` · ❓ 待確認 - the evidence is not reachable here; the row moves to 待確認事項 and its severity is stated conditionally ("if A -> 🔴") |
| **新舊** (where it came from) | 本次新增 `INTRODUCED` · 既有 `PRE-EXISTING` · 既有但本次擴大 `AGGRAVATED` |

A ❓ row never counts toward the 🔴 / 🟡 totals, and "probably a bug" is not a
severity. In a chat reply the 驗證 and 新舊 cells may be merged into one
(`✅ 本次新增`) to keep the table readable; the review file keeps all three
columns. The fix column names the method / API / approach; full code only when
asked.

**Execution / change plan** (Mode A proposal, "how would you change this")

| 需求 | 目標 | 修改位置 | 修改方式 | 可安全執行 |
|---|---|---|---|---|
| AC #1 / the ticket's own words | the observable result after the change | `path:line` / method | the concrete change: API, method, condition, column | ✅ 可實作 / ❓ 待確認 / ❌ 需決策 |

- One row = one requirement -> one change. The row itself shows which requirement
  it serves; no "because the requirement says ..., therefore ..." prose.
- 可安全執行 is the per-row verdict: ✅ evidence confirmed, the agent can
  implement it; ❓ a fact is missing; ❌ a business / compatibility decision only
  the user can make.
- Every ❓ / ❌ row gets a follow-up row telling the user exactly how to supply
  what is missing - the command, SQL, file, log or config key, ready to run:

| 待確認項目 | 請你提供 | 查法（直接執行） |
|---|---|---|
| does column `X` allow NULL in prod | the query result | `SELECT COUNT(*) FROM T WHERE X IS NULL` |
| which value `Y` has in QA config | the setting value | `appsettings.QA.json` -> `Section:Key` |

  Never "please confirm the business rule" without saying what to check and where.

**Test plan** (Validation Plan, acceptance, "how do I test this")

| 測試案例 | 操作 | 預期結果 |
|---|---|---|

Operation = executable steps with concrete input. Expected = observable,
verifiable result (value, status code, message, row). No strategy essay.

**Concept / architecture** (Mode C, "what is X here")

Short prose answering, in order: what it is · what it does in **this** system · how
it actually runs. Several components -> one arrow chain or small Mermaid flow.
Never a full architecture report for a single question.

**Troubleshooting** (root cause, "why does X happen")

| 檢查項目 | 發現結果 | 處理方式 |
|---|---|---|

Confirmed problems and their direct fix first. Not enough evidence -> `❓ 待確認`
plus the **one next concrete check** (command, query, log, file). Never a long
list of unverified possible causes.

## 5. Clarity rules (keep the reader from chasing)

Written for a reader who may meet this system for the first time - applied briefly,
only where the reader would otherwise get stuck.

- **A project-specific term gets one short gloss on first use** - its role in
  *this* system, not a dictionary translation. Common terms (Controller, DTO, API)
  need none unless the question is about them.
- **A program name is not a business name.** `Top`, `Boost`, `Rank`, `Bucket` are
  not mapped to business vocabulary without evidence; say "behaves as X, business
  name not confirmed".
- **Every action names its actor.** Never "系統自己判斷 / 自動處理 / 內部處理 / the
  system handles it" without saying *which* component, service or layer.
- **A value / field gets its provenance when it matters**: who produces it, who
  reads it. A derived number gets its origin (`offset = 40 returned - 30 page size
  = 10`); a formula gets its variables defined first.
- **Flows are numbered steps with actors** (`1 <Caller> builds query -> 2 <Engine>
  returns rows -> ...`); old vs new is shown as two such chains plus one line on
  what actually changed.
- **Localise before blaming**: name the first layer where two runs diverge, not
  "the new API is broken".
- **Evidence labels stay**: load-bearing statements carry `CONFIRMED` / `INFERRED`
  / `UNKNOWN` (definitions: `memory-system.md` §5). In a table, a ✅ / ❓ cell or a
  short tag is enough; never present an inference as fact.

Concise is fine; vague is not. Never drop a causal link to save space.

## 6. Chat reply vs local file

| | Chat reply | Local issue / review file |
|---|---|---|
| Purpose | the user understands and decides now | audit record of the gates and evidence |
| Content | digest: conclusion, top items, decision / next step, required approval line | the template, proportional - sections that do not apply are deleted |
| Gate names, dimension blocks, parity tables | only a row that is ❌ / ❓ / HIGH, stated in plain words | full |

The reply ends with the file path when one was written, never with the file pasted.

## 7. Self-check before sending

```
1 Can the user find the answer in the first lines?
2 Is the current state visible at a glance?
3 Is the cause stated, not implied?
4 Is the fix concrete (API / method / path), not generic?
5 Is the next step explicit?
6 Any background, repetition or unasked scope to delete?
7 Does any item need another paragraph to be understood?  -> rewrite it to stand alone
```

Too long -> cut it before sending.
