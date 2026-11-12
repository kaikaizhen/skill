# RAG 知識庫（背景功能）

> 使用者自己的服務，**不是獨立 skill、也不屬於任何 workspace** —— 載到這個 skill 就能用，
> 換公司替換 `workspace/` 不會影響它。由 `enterprise-codebase-analysis` 在任何 mode 的背景執行。
> **預設關閉**：沒有權杖就完全不作用，也不提醒（見第〇節）。

## 〇、啟用開關（最先檢查，沒過就什麼都不做）

這個背景功能**預設關閉**。每次要用之前，先依序找權杖：

```
1. 環境變數 $RAG_TOKEN
2. 權杖檔 `<skill>/.secrets/rag-token.txt`（由 `/rag-pat` 建立，DPAPI 加密）
   `<skill>` ＝ enterprise-codebase-analysis 的實體路徑：
   `readlink -f ~/.claude/skills/enterprise-codebase-analysis`
   這條路徑不依賴 `$HOME`，不受各台電腦家目錄設定影響。
```

**兩個都沒有 → 這個功能視為未啟用：不搜尋、不送暫存區、不呼叫任何 API，
也不要主動提醒使用者去設定。** 安靜略過就好。

唯一的例外：使用者**明確要求**搜尋知識庫或保存知識，而權杖不存在時，才回一句
「RAG 尚未啟用，請先執行 `/rag-pat` 設定權杖」。

讀權杖檔的方式（PowerShell；讀出來只放在記憶體，不印、不寫檔、不貼進對話）：

```bash
SKILL_DIR=$(readlink -f ~/.claude/skills/enterprise-codebase-analysis 2>/dev/null)
export TOKEN_FILE=$(cygpath -w "$SKILL_DIR/.secrets/rag-token.txt" 2>/dev/null)
RAG_TOKEN=$(powershell -NoProfile -Command '
  if ($env:TOKEN_FILE -and (Test-Path $env:TOKEN_FILE)) {
    $s = Get-Content $env:TOKEN_FILE | ConvertTo-SecureString
    [Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s))
  }' 2>/dev/null | tr -d '\r\n')
[ -z "$RAG_TOKEN" ] && echo "RAG not enabled" && exit 0
```

權杖檔用 Windows DPAPI 加密，只有**存檔的那個 Windows 帳號、在同一台電腦**解得開。
放在 `<skill>/.secrets/` 只讓**路徑**不依賴 `$HOME`；**加密仍綁帳號與機器**，換電腦或換
帳號一樣要重跑 `/rag-pat`。解不開時當作未啟用處理，不要嘗試修復或改檔。
`.gitignore` 的 `**/.secrets/` 讓權杖檔不進版控，只有 `.gitkeep` 被追蹤（clone 後資料夾就存在）。

## 一、API 設定

- Base URL：`https://rag.name404.com/api/v1`
- 驗證：`Authorization: Bearer $RAG_TOKEN`
- **權杖不得寫入檔案、對話、日誌或程式碼**；只能由 `/rag-pat` 寫進加密權杖檔，或由使用者
  自己設環境變數。
- 指定空間（選用）：`X-Space-Id: <編號>`
- 未指定空間時，使用權杖預設空間。

## 二、搜尋知識庫

端點：`POST /Knowledge/search`

所需權限：`knowledge.search`

```bash
curl -s -X POST "https://rag.name404.com/api/v1/Knowledge/search" \
  -H "Authorization: Bearer $RAG_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"<問題>"}'
```

### 搜尋範圍

預設只搜尋目前空間。

若需要搜尋所有可讀空間，在 Body 加入：

```json
{
  "query": "<問題>",
  "scope": "all"
}
```

- 可搜尋的空間由伺服器依權限決定。
- 不得自行指定未授權的空間。
- 跨空間結果須保留 `spaceKey`，以識別知識來源。

### 搜尋結果判斷

搜尋端點只負責檢索，不會生成答案。

- `evidence`：可作為回答依據的知識。
- `similar`：相似內容，僅供參考，不可直接當成已確認事實。
- `Grounded`：具有足夠知識庫依據，可以回答。
- `Insufficient`：知識庫依據不足，不可編造。

若 evidence 的狀態為：

- `Stale`：可能已過時，回答時必須註明。
- `Inferred`：屬於推論，回答時必須註明。

若搜尋結果為 `Insufficient`，應明確告知「目前知識庫沒有足夠資料回答」，不得使用 similar 假裝具有已確認的依據。

## 三、知識暫存區

端點：`POST /Inbox`

所需權限：`inbox.write`

```bash
curl -s -X POST "https://rag.name404.com/api/v1/Inbox" \
  -H "Authorization: Bearer $RAG_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "<問題>",
    "answer": "<Markdown 答案>",
    "sourceRef": "<來源編號或網址>"
  }'
```

| 欄位 | 說明 |
|---|---|
| `question` | 常見問題，最多 500 字 |
| `answer` | 可獨立閱讀的 Markdown 答案，最多 20,000 字 |
| `sourceRef` | 選填，來源編號或網址 |

### 暫存區原則
- 符合保存條件的知識可直接送入暫存區。
- 不需要事先展示內容或取得使用者同意。
- 暫存區不等於正式知識庫。
- 使用者須在網站上審查並接受，內容才會寫入正式知識庫。
- 不得繞過暫存區直接寫入正式知識庫。

## 四、自動整理知識規則
### 適合保存
- 通用技術觀念與原理
- 常見問題及解決方法
- 可重複使用的操作流程
- 系統架構與設計理由
- 經過驗證的除錯經驗
- 有參考價值的專案實作經驗
- 特定專案的注意事項、使用對象及適用情境

### 不適合保存
- 密碼、Token、API Key、私密金鑰
- 個人資料及敏感資訊
- 不適合保存的公司機密
- 尚未驗證的猜測或錯誤資訊
- 只有當下對話才有意義的零碎內容
- 知識庫已經存在且內容完整的重複知識

專案相關知識可以保存，但須交代適用專案、條件與限制，避免洩漏敏感資訊。

### 知識撰寫原則
1. 問題使用一般人實際會提出的問法。
2. 答案必須能獨立閱讀，不依賴原始對話。
3. 技術名詞首次出現時，提供中文解釋。
4. 說明適用情境、原理、操作方式及注意事項。
5. 區分已確認事實、推論與尚待驗證事項。
6. 不保存沒有明確用途的零碎內容。

## 五、自動執行流程

### A. 使用者要求搜尋知識庫
1. 先過第〇節的啟用檢查。
2. 呼叫 `Knowledge/search`。
3. 判斷搜尋結果的整體 status。
4. `Grounded` 時，以 evidence 為依據回答。
5. `Insufficient` 時，明確說明知識庫資料不足。
6. 必要時註明來源空間及 Stale、Inferred 狀態。
7. 單純搜尋不代表需要建立暫存項目。

### B. 對話產生值得保存的知識
當對話中出現符合保存條件的內容時，自動執行：
1. **先過第〇節的啟用檢查；未啟用就安靜略過，不提醒。**
2. 判斷內容是否具有通用性或重複使用價值。
3. 排除敏感、錯誤及不適合保存的資料。
4. 使用 `Knowledge/search` 搜尋相同或相近問題，避免重複。
5. 若已有完整知識，不再建立。
6. 若屬於新的知識或具有獨立價值的補充內容，整理成完整問答。
7. 產生 `question`、`answer`，必要時附上 `sourceRef`。
8. 直接呼叫 `POST /Inbox`，不需要詢問使用者。
9. 確認 API 回應成功後，通知使用者。

### C. 自動送出後的回覆
成功時回覆時不影響原有詢問的問題或說明，而是最下面多一個小章節進行告知：
「已放進暫存區，請到『暫存區』頁面審查。」
如果同一次對話整理了多筆知識，可以簡要列出新增的問題，方便使用者審查。
若 API 失敗，說明失敗原因，不得宣稱成功。

## 六、自動觸發時機
以下情況應主動評估是否值得保存：
- 完成一個技術問題的解釋。
- 找到並驗證問題的根本原因。
- 完成可重複使用的操作或排錯流程。
- 確認系統架構或重要設計理由。
- 整理出常見問題的完整答案。
- 使用者修正了錯誤觀念，形成經過確認的結論。
- 專案實作中發現可供未來參考的注意事項。
不必每一輪對話都新增知識。
優先在形成完整且穩定的結論時進行整理，避免同一個主題在討論過程中產生大量重複項目。

## 七、重要限制
- **未啟用（沒有權杖）時完全不作用，也不提醒**（第〇節）。
- 這是背景功能，**不得影響使用者原本問題的回答品質或回覆長度**；搜尋失敗或超時就安靜略過。
- 搜尋知識庫不等於必須建立暫存項目。
- 有價值的知識可以自動送入暫存區，不需要使用者同意。
- 送出前必須進行知識庫查重。
- 不得將未驗證內容當成已確認知識。
- 不得保存密碼、金鑰、個資等敏感資料。
- 不得直接寫入正式知識庫。
- 不得將暫存成功描述成正式知識庫更新成功。
- 只有 API 回應成功，才能宣稱已送入暫存區。
- API 不可用或權限不足時，應明確告知，不得假裝已完成操作。
- 不應為了保存知識而影響使用者原本問題的回答品質。
- 不得把權杖印出來、寫進檔案或貼進對話；不代替使用者填寫或修改權杖檔。

## 八、核心原則
**啟用才動、搜尋優先、通過查重、自動暫存、人工審查。**
日常對話中，只要形成值得長期保存的知識，即可自動整理並送入暫存區。
使用者不需要額外下達保存指令，也不需要逐筆確認。
正式知識庫的最終寫入權仍由使用者透過網站審查控制。
