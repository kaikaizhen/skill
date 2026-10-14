# [Issue Number] - Change Proposal (continues the analysis)

> The second half of ONE report. Append to `<issue-number>.md` after
> `templates/issue-analysis.md`: head + evidence, then the decision layer below.
> Rules: `change-proposal.md`. Mode A stops after this - no code, no branch,
> no commit, no MR/PR, no DB change, no deployment.

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
