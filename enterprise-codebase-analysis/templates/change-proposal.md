# [Issue Number] - Change Proposal (continues the analysis)

> The second half of ONE report. Append to `<issue-number>.md` after
> `templates/issue-analysis.md`: head + evidence, then the decision layer below.
> Rules: `change-proposal.md`. Mode A stops after this - no code, no branch,
> no commit, no MR/PR, no DB change, no deployment.

## Gate 7 - Codebase Consistency

```
Tier: L1 | L2 | L3        <!-- set at steps 7-9 by real risk and reach, not diff size -->
Escalated: NO | L<x> -> L<y>: <trigger, path:line>
Early exit: <stage n - why> | N/A
```

<!-- L1: three lines (follows existing practice? / any meaning changed? / obvious
     compatibility problem?) and delete the rest of this block.
     L2: the four points - similar implementations found, reusable or not, is the new
     approach justified, does it create an unnecessary design difference.
     L3: fill in everything below (consistency-gate.md §6). -->

Existing Patterns:
<!-- what already implements this, path:line, and whether it is reusable. Reuse only
     when business meaning, data source/lifecycle and use case all match - finding
     similar code is not a reason to reuse it. -->
-

Existing Data Strategy Comparison:
<!-- Required when the change touches identification / update / delete / copy /
     restructuring of data (data-strategy.md §1). Only the repositories and functions
     actually affected - filled from code, never guessed. A column existing does not
     mean the function depends on it; a batch-update method existing does not mean a
     single-row feature can be removed. -->

| Repository | 功能／API | 目前處理方式 | 是否依賴原識別碼 | 是否有替代的既有處理方式 | 證據 |
|---|---|---|---|---|---|
| | | 主鍵 / rowguid / 業務組合鍵 / 順序或 Index / 整批刪除後新增 / 其他 | 是 / 否 / 待確認 | 已有 / 無 / 待確認 | `path:line` |

<!-- 若已有「整批刪除後重新新增」流程，先依 data-strategy.md §2 的八項前提評估沿用，
     再考慮新增 GUID／Hash／Index。整批寫入 ≠ 單筆識別。
     要新增識別機制前，先回答：為什麼現有策略不能滿足需求？ -->

Semantic Consistency:
<!-- one row per field / value touched. Same data type does NOT mean same semantics. -->

| 欄位／值 | 修改前語意 | 修改後語意 | 誰產生 | 用於識別／排序／關聯／顯示 | 判定 |
|---|---|---|---|---|---|
| | | | | | 不變 / 明確變更（已說明） / **語意重載（禁止）** |

Identifier Lifecycle:
NOT APPLICABLE
<!-- only when an ID / GUID / key / index / hash / sequence / token is involved; then
     mandatory: what it identifies (row / entity / screen item), scope and lifetime,
     delete-then-recreate, re-ordering, identical content, content edit, frontend ↔
     backend ↔ external mapping, concurrency, and whether a mechanism already exists.
     A hash is not uniqueness; a GUID shape is not meaning; an index is not durable. -->

Cross-Layer Contract:
NOT APPLICABLE
<!-- produced -> stored -> queried -> transformed -> API output -> consumer -> next.
     Unreachable consumer = UNKNOWN or NEEDS HUMAN CONFIRMATION, never silence.
     Not finding a consumer is not proof there is none. -->

Consistency Recommendation:
<!-- which option best fits this project's design, and why. -->

Open Questions:
<!-- unconfirmed contract, risk or decision - each with the exact question to answer. -->
- NONE

```
Gate 7 Verdict: PASS | PASS WITH CONDITIONS | NEEDS HUMAN DECISION | BLOCKED
Conditions:     <none, or each one named>
```
<!-- PASS WITH CONDITIONS -> those become the conditions in Approval Recommendation.
     NEEDS HUMAN DECISION -> Approval Recommendation cannot be APPROVE.
     BLOCKED -> Approval Recommendation is NOT RECOMMENDED until resolved. -->

## Candidate Solutions

<!-- Only when a real choice exists, minimal/existing-capability option first. Do NOT
     manufacture a second option - one defensible approach means one line saying so.
     A qualifying SOLID alternative makes this the PATTERN CHOICE block (§3b, silence
     = Option A) -> end with AWAITING USER PATTERN CHOICE. `change-proposal.md` §4.
     Optimization/Refactor: this is the mandatory Design & Implementation Strategy
     (§3a) - concrete problem at `path:line` -> candidates vs readability /
     maintainability / testability / coupling / reuse and this repo's convention ->
     chosen approach + why a pattern earns its place against a PRESENT need -> what
     stays untouched. -->

### Option A - Minimal / existing capability
What / Files / Benefits / Risks / Blast radius:

### Option B - Structural change
What / Files / Benefits / Risks / Extra abstractions / Blast radius:

## Recommended Change

Recommendation:
Why this option:
Why not the alternatives:

## Proposed Code Changes

<!-- One row per requirement -> change; the row shows which requirement it serves,
     no "because ..., therefore ..." prose. 可安全執行: ✅ 可實作 / ❓ 待確認 /
     ❌ 需決策. List `No change` rows too - the deliberately untouched boundaries.
     Pseudocode only where the change is not obvious from the table. -->

| 需求 | 目標 | 修改位置 | 修改方式 | 可安全執行 |
|---|---|---|---|---|
| AC #<n> | <observable result> | `<path:line>` / <method> | <concrete change: API / condition / column> | ✅ 可實作 |
| - | <boundary kept> | `<path>` | **No change** | ✅ |

```
```

## Regression Risk

<!-- WITH the reason; must agree with Gate 5's risk rows. `change-proposal.md` §5.
     Renaming a literal and changing its value are separate lines - a value change is
     a behaviour change, not a cleanup (`encoded-values.md` §9). -->
Risk: Low / Medium / High
Because:

## Validation Plan

<!-- Include a before/after comparison per non-`unchanged` Gate 5 row. -->

<!-- 操作 = concrete, executable steps with input; 預期結果 = observable and
     verifiable (value, status code, message, row). explanation-standard.md §4. -->

| 測試案例 | 操作 | 預期結果 |
|---|---|---|
| Build | `<build command>` | PASS |
| Existing tests (related set) | `<test command + filter>` | all pass, counts reported |
| <ticket behaviour> | <steps + input> | <observable result> |
| Before / after: <behaviour that must stay> | <same steps on baseline and change> | identical <value / status / row> |

DB writes required: NO / YES -> requires Database Mutation Approval

## Implementation Scope

In Scope:      -
Out of Scope:  -

## Unknowns / Questions

<!-- Only what affects implementation correctness. One row per ❓ / ❌ plan row:
     tell the user exactly what to run or open - never "please confirm". -->

| 待確認項目 | 請你提供 | 查法（直接執行） | 阻擋實作 |
|---|---|---|---|
| | | `<command / SQL / file -> key / log path>` | YES / NO |

## Memory Delta Candidate

NONE / ADD / UPDATE / CORRECT / PROMOTE / DEMOTE

## Consistency Pass

<!-- GATE 4 - a recompute: superseded conclusions DELETED not annotated; every plan
     item traces to a level-1 requirement; every MISSING meets Gate 3's threshold;
     Regression Risk agrees with Gate 5. -->

No superseded content.

## Approval Recommendation

<!-- `change-proposal.md` §7. APPROVE needs ALL of: clear requirement, confirmed flow,
     bounded scope, preservable contract, validation plan, no unresolved high-risk
     business decision. -->

```
Recommendation:            APPROVE | APPROVE WITH CONDITIONS | NEEDS HUMAN DECISION | NOT RECOMMENDED
Reason:
Implementation Confidence: High | Medium | Low
Estimated Blast Radius:    Small | Medium | Large
Production Risk:           Low | Medium | High
Human Decisions Required:  None | <list>
Agent Can Implement:       Yes | Yes after clarification | No
```

## Implementation Handoff

<!-- APPROVE / APPROVE WITH CONDITIONS only. Producing it is NOT implementing. -->

```
Goal:
Files expected to change:
Behaviors that must not change:
Encoded values that must remain unchanged:
  <e.g. JobStatus.Active = 3 · AccountFlag.Email = 2 · RequiredMask = 3>
  Do not change persisted numeric values.
Implementation constraints:
Tests required:
Do not change:
Stop conditions:
```

## Approval

AWAITING USER APPROVAL TO IMPLEMENT
