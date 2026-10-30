# Table Review Standard

This file defines **how to review a table change and how to present the result**. The
design rules are owned by `thinking/table-design.md` and are never restated here. Output
skeleton: `templates/table-review.md`.

This is not a new mode: it is **Mode A's fixed output format when a database structure
changes**. Everything else runs as before - scoped scan, the gates, Approval Gate #1
and #2, memory, git and DB safety. Application-code review still uses Mode R and
`thinking/code-review-checks.md`; this file does not replace it.

## 0. Trigger conditions (shared with `thinking/table-design.md`)

While analysing a requirement document, ticket, SQL or code, **once it is established**
that the work involves any of the following, the design checks and the review run by
default - the user does not have to ask:

`CREATE TABLE` · `ALTER TABLE` · adding, dropping or renaming a column · changing a
type, length, NULL or DEFAULT · changing a primary key, unique key, index or other
constraint · changing a table relation or refactoring a Schema · reviewing a table
design draft that is not implemented yet · a ticket asking for a new or changed
database structure · judging whether a Schema change affects existing behaviour.

**Does not trigger** (answer through the normal flow; never force the review
document):

- SQL syntax questions, explaining a `SELECT` / `JOIN`, reading data, reading a query
  plan -> Mode C.
- Reviewing ordinary code changes (service, controller, frontend) -> Mode R.
- General code analysis, call-chain tracing, dependency inventory -> existing Mode
  A / C behaviour.
- "What does this table do?" -> Mode C.

When one ticket contains **both** code changes and a table change, do both: code
through Mode R / Gate 6's table, Schema through this file's fixed tables, and
**merge all problems into the single list in §5** - never split them by origin.

## 1. Default procedure

```
1 Understand the requirement with the existing capabilities: scoped scan, related
  code, database facts (read-only)
2 Apply table-design.md §1-§5 - does the design fit the business need and the
  existing system?
3 Changing an existing table -> also run table-design.md §6-§8 (dependencies,
  Before/After, deployment compatibility)
4 Produce the fixed-format review document (the six sections of §3,
  templates/table-review.md)
5 For every established problem, give a concrete fix (the hard requirements in §5)
6 Business rules or external dependencies you cannot establish -> §6 open decisions
7 Only when the user asks for implementation do you touch SQL, code or any other
  file (Approval Gate #1)
```

The review itself is read-only analysis: **no DDL or DML, no change to application
code, nothing touched in a production environment** (HARD RULE 2,
`database-safety.md`). The document goes to that ticket's folder,
`<workspace>/issue/<RepoName>/<Ticket>/` - created before the first file - never
inside the repository (HARD RULE 3, `usage.md` -> Output Locations).

## 2. Evidence requirements

Every conclusion must trace to: the requirement document · code with `path:line` ·
the database schema · a stored procedure or other database object · a real test
result.

- **An established problem** carries its code, schema, SQL or requirement evidence.
- **An unverified risk** states exactly which information is missing and how to get
  it, and is marked 未驗證.
- **A business decision** moves to §6 with concrete candidate options.

**Never write an inference as an established defect, and never invent a schema, a
column or a line number.** Information you could not obtain is filled in as 待確認.
If nothing is wrong, say so plainly - **never manufacture a problem to fill a table**.

## 3. Document structure (fixed order, never rearranged)

```
一、資料表基本資訊          basic information
二、完整欄位設計表          full column table      <- always required
三、欄位修改對照表          change comparison      <- only when altering a table
                            (plus the Before / After functional comparison)
四、主鍵、索引及約束表      keys, indexes, constraints
五、DDL                     runnable DDL           <- always required
六、Review 問題清單         the one and only problem list
七、待確認事項（主管決策）  open decisions
```

Layout: Traditional Chinese Markdown; fixed column names and order; concise enough to
be reviewed directly; **never put a full call chain or a wall of SQL into the main
tables** (put what is needed after the change-comparison table); do not force a large
test matrix or a full deployment plan; expand technical detail only when the user asks
for implementation or a material risk needs explaining. The column table, index table,
DDL and problem list must be copyable straight into a ticket for a manager to read.

## 4. Rules for the fixed tables and the DDL

**一、Basic information**: table name / change type (新增·修改) / requirement source /
purpose / main consuming feature / blast radius / review status (已確認·待確認).
Anything not obtained is filled in as 待確認.

**二、Full column table** (`# · 欄位名稱 · 型別 · 是否可為 NULL · 預設值／自動產生 · 備註`)

- Required in **every** review, new table or altered. **List all columns - never only
  the changed ones.**
- Keep the existing column order; types include real length and precision.
- 是否可為 NULL uses 是 / 否 / 待確認.
- **A default and an auto-generated value are not the same thing**: `IDENTITY(1,1)` is
  not a DEFAULT constraint - keep them in separate statements.
- PK / FK / special rules go briefly in 備註. Never fill in column facts you have not
  verified.
- A table not yet implemented is marked 建議設計; an altered table shows the **post-
  change** full structure.
- If the full schema is unavailable, state what was not verified - **never pass a
  partial column list off as the complete structure**.

**三、Change comparison table**
(`欄位名稱 · 變更類型 · 修改前 · 修改後 · 修改原因 · 影響`)

- Only the columns that actually change; if the pre-change schema was not obtained,
  mark it 未驗證.
- When the change can affect existing behaviour, **add the Before / After functional
  table** (`功能／流程 · Before · After · 影響判定 · 建議調整`): whether the original
  feature survives, intended versus unintended behaviour changes, new errors and
  indirect side effects, and the pre-existing problems related to this change.
  **"可能有影響，建議確認" is not an acceptable entry** (source: `thinking/table-design.md` §7).
- This table shows the difference only; **the problems themselves still go to §5**.

**四、Keys, indexes and constraints** (`名稱 · 類型 · 欄位 · 用途 · 審查結果`)

- List the PK, unique indexes and the indexes / constraints actually needed;
  **always state clustered or nonclustered**; keep `CHECK` and `FOREIGN KEY` distinct
  from indexes.
- Say which business need or query predicate each index serves. Names and layout
  follow the project's real design - never copy an example.
- When the business unique key is unclear, give the candidate designs and their
  consequences in §6; **never pick one and present it as settled**.

### 五、DDL (always required)

A table cannot be approved from prose alone: a manager and a developer both need to
see the statement that will actually run. Emit it as a SQL code block, in SQL Server
syntax, after the index table.

- **A new table**: the full `CREATE TABLE` followed by its indexes, in the order they
  must execute. Label the block `建議設計（尚未實作）`.
- **An altered table**: the `ALTER TABLE` / `CREATE INDEX` / `DROP` statements in
  deployment order, each one labelled with the deployment phase it belongs to when
  §8's analysis requires phases. Add the rollback statement for each where one
  exists, and - when the table is small enough to be readable - the post-change full
  `CREATE TABLE` underneath as a reference, clearly marked `變更後完整結構（參考）`.
- **Every column carries an inline comment** giving its business meaning in
  Traditional Chinese, and for a coded column the **values themselves**: an enum
  lists every value (`0:Default, 1:Student, …`), a bitmask lists every bit plus what
  `0` and `NULL` mean. This is what makes the DDL readable to someone who does not
  know the schema, and it is not optional.
- **Name every constraint explicitly** - `PK_<table>_<col>`, `DF_<table>_<col>`,
  `UX_` / `IX_<table>_<cols>`, `CK_<table>_<rule>`, `FK_<table>_<ref>` - following
  the project's existing naming convention, and **state `CLUSTERED` /
  `NONCLUSTERED`** on the primary key and every index. An unnamed default constraint
  cannot be dropped predictably later.
- Keep it to the reviewed object: no `USE`, no `GO` batches that assume a tool, no
  unrelated grants, no sample `INSERT`s.
- **Anything not verified must be visible as such** - a `-- 未驗證：<what>` comment on
  that line, or the whole block marked `建議設計`. Never present inferred types,
  lengths or defaults as if they were read from the schema.
- Sharded tables: say which databases the DDL must run against, and that **verifying
  one shard proves one shard** (`thinking/table-design.md` §6).
- The DDL is **for review, not for execution**: it is run only after the user
  approves it (HARD RULE 2, Approval Gate #1), and this skill never executes it.

## 5. The problem list - the only place problems are collected

Four fixed columns: `等級 · 問題 · 原因／影響 · 建議調整`.

**Exactly three severities** (the same ladder the whole skill uses, defined in
`thinking/explanation-standard.md` §4):

| 等級 | When |
|---|---|
| 🔴 建議修正 | can lose, corrupt or desynchronise data · can create duplicate rows, privilege escalation or a security hole · can stop a required existing feature working · can make an API, SP or deployment fail · a clear, material compatibility problem that must be handled |
| 🟡 建議改善 | inconsistent with the existing system · performance, scalability or maintenance cost · existing logic could be better but is not proven to cause a material error · a more reasonable column, index or code design exists |
| 🟢 小問題或備註 | naming, comments, formatting, incomplete documentation · optional improvement with no effect on the main feature · worth flagging but not yet a defect |

**No other problem category may be created** - not "本次修改引入的問題", not
"原本就存在的問題", not "原有功能喪失", not "副作用問題", not any custom type. That
information is written **inside** the 問題 or 原因／影響 column (for example
"此問題在修改前即存在", "屬於本次異動可能造成的副作用") and **never as a separate block
or a second table**. This constraint governs the table review's problem list only;
Mode R's three-axis findings table is unaffected.

### Hard requirements for 建議調整

1. Say directly **what to change**.
2. **Banned**: 建議評估 · 確認是否需要 · 考慮修改 · 優化索引 - and anything equally
   abstract.
3. Name the concrete target: table, column, index, enum, entity, API, service or SP.
4. With sufficient evidence, give the proposed type, index column combination, SQL or
   code change outright.
5. With more than one option, compare them, **recommend one**, and say why.
6. Where the business rule is genuinely unsettled, give a conditional plan (if A then
   …; if B then …) - never decide the business rule yourself.
7. For a code change, include `path:line` or the method name where you can.
8. Add a **short** SQL / C# snippet when it is what makes the fix actionable.
9. State **how to verify** the fix.
10. The reader should be able to start fixing immediately, without asking "so what
    exactly do I change?".

## 6. Open decisions (for the manager)

Fixed columns: `# · 待確認問題 · 目前狀況 · 建議方向 · 確認對象`.

- Only items that genuinely need a decision; each states the established facts, the
  recommended direction and the consequence.
- **Never write "請確認" with no options**, and never quietly promote a business
  decision into a settled design.
- A material unresolved item must say whether it **blocks implementation or release**.
- This is a decision list, **not another problem category** - anything already
  established stays in §5.

## 7. Ownership map (so nothing is defined twice)

| Topic | Owner |
|---|---|
| table design rules (types, NULL, indexes, unique keys, dependencies, Before/After, deployment compatibility) | `thinking/table-design.md` |
| the three severities and table presentation rules | `thinking/explanation-standard.md` §4 |
| database access, read-only default, DDL / DML approval | `database-safety.md` |
| the seven contract dimensions and regression grading | `thinking/regression-validator.md` (Gate 5) |
| compatibility across existing data populations | `thinking/code-quality-gates.md` §2 |
| parameterised SQL, IDOR, N+1, transactions, concurrency | `thinking/code-review-checks.md` |
| bit flag / mask presentation | `thinking/encoded-values.md` §5 |
| schema fact vs code inference, one shard proves one shard, DBA SQL when access is missing | `e2e-investigation.md` Phase 2 |
| reuse judgement for an existing capability | `thinking/capability-reuse.md` (Gate 3) |
