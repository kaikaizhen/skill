# [Ticket] 驗收標準

> Save as `<workspace>/issue/<RepoName>/<Ticket>驗收標準.md` - the same directory as
> `<Ticket>.md` (e.g. `<workspace-root>/issue/<Repo>/<Ticket>驗收標準.md`).
> LOCAL ONLY - never inside the repository, never staged, never committed.
> Create this file only after: implementation done + build passed + **使用者明確確認功能成功**.
> Source: ticket acceptance criteria -> final implementation -> regression requirements.
> Keep it executable by someone who did not write the code. Delete sections that do not apply.

## 驗收資訊

| | |
|---|---|
| Ticket | |
| Repository / Branch | |
| 驗收環境 | local / qa / stg |
| 實作範圍 | <one line: what actually changed> |
| 使用者確認完成日期 | |

## 前置準備

<!-- Accounts, test data, feature switches, cache/搜尋索引狀態, 必要權限.
     DB 寫入需求一律標註；實際寫入仍需 Database Mutation Approval。 -->

-

## 一、Ticket 需求驗收

<!-- One row per acceptance criterion the ticket actually states. -->

| # | 驗收項目 | 前置條件 / 測試資料 | 操作步驟 | 預期結果 | 對應需求 | 結果 |
|---|---|---|---|---|---|---|
| 1 | | | | | Ticket AC #<n> | ☐ Pass ☐ Fail |

## 二、實作行為驗收

<!-- What the final diff actually does, where it is observable but not spelled out
     in the ticket's AC: 新增/調整的欄位、錯誤訊息、狀態碼、log、cache 行為等。
     Only what was implemented - not wishes. -->

| # | 驗收項目 | 操作步驟 | 預期結果 | 對應變更 (file/method) | 結果 |
|---|---|---|---|---|---|
| 1 | | | | | ☐ Pass ☐ Fail |

## 三、例外 / 邊界驗收

<!-- 預期業務失敗（走該 repo 原生 failure/回傳契約）與邊界值。
     非預期例外的處理方式以該 repo 的 global handler 為準。 -->

| # | 情境 | 操作步驟 | 預期結果（含狀態碼 / 錯誤訊息 / 回傳契約） | 結果 |
|---|---|---|---|---|
| 1 | | | | ☐ Pass ☐ Fail |

## 四、Regression 驗收

<!-- 既有行為不得被破壞。來源：Contract Parity 表（Gate 5 run 2）每一列非
     `unchanged` 的 delta + 被保留的既有測試所保護的需求 + Impact Scope 列出的
     caller / 共用 Service / 其他 carrier / 背景作業。「改 A 壞 B」在這裡被擋下。
     七個構面：security/auth/CSRF、server-side validation、data integrity、
     transaction/ACID、side effects（成功與失敗）、logging/audit、caller 相容性。
     side effect 與 audit 記錄要實際驗證有發生／沒發生，不能只看畫面成功。 -->

| # | 既有功能 / Contract 構面 | 為何相關（共用元件 / caller / 同一流程） | 操作步驟 | 預期結果（維持原行為） | 結果 |
|---|---|---|---|---|---|
| 1 | | | | | ☐ Pass ☐ Fail |

## 五、自動化測試對照

| 測試專案 / 檔案 | 測試名稱 | 涵蓋上表哪幾項 | 本次狀態 |
|---|---|---|---|
| | | | 既有保留 / 本次新增 / 本次調整 |

<!-- 無法在本機執行者（需要容器 / DB / 網路）標註 NOT RUN 與原因，不得標為 Pass。 -->

## 參考 / 非本次驗收範圍

<!-- Ticket 未要求、但分析過程中出現的項目。列在這裡，不進入上面的驗收表。 -->

-

## 驗收結論

```
ALL PASS        -> 可送測 / 送 QA
PARTIAL / FAIL  -> 列出失敗項目編號與現象
```
