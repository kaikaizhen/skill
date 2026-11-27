# Secret Handling

**Hard rule 17.** A secret is never shown, repeated, stored or committed by the agent.
Secrets live in a secret store; the agent consumes them at run time and never prints them.

```
CHECK FOR A SECRET STORE FIRST
NEVER ECHO A SECRET
PASTED SECRET -> SHOW THE NOTICE, DO NOT REPEAT THE VALUE
```

## What counts as a secret

Passwords, API / access tokens, personal access tokens, AES / signing / encryption keys,
private keys (`-----BEGIN ... PRIVATE KEY-----`), `Authorization` / cookie / session
headers, connection strings that carry `Pwd=` / `Password=` / `User Id=`, OAuth client
secrets, webhook URLs that embed a token, and verification codes that unlock an account.
Personal data (national ID, phone, email) is not a credential but follows the same
"do not copy it into notes, memory or commits" discipline.

## 1. Check the host for a secret store (once per task that needs a secret)

Look for `gopass` first, then `pass`. Read-only checks, no output of any entry:

```
Windows (PowerShell):  Get-Command gopass, pass, gpg -ErrorAction SilentlyContinue
macOS / Linux:         command -v gopass pass gpg
```

| Result | What the agent does |
|---|---|
| `gopass` or `pass` present | Ask the user for the **entry name** (not the value). Use it as in section 3. |
| Neither present | Recommend one (section 2). Do not install it without the user's consent. Until then, take the value only as an interactive prompt the user types into their own shell, never as chat text. |

## 2. Recommended setup (Windows; the user runs these)

```
1. winget install -e --id GnuPG.Gpg4win --force
2. scoop install gopass
3. gpg --full-generate-key          # create the key pair
4. gopass setup                     # initialise the store with that key
5. gopass edit <store>/<name>       # opens the editor; type the secret there, it is saved encrypted
```

macOS / Linux: install `gopass` or `pass` with the system package manager, then
`gpg --full-generate-key`, `gopass setup` (or `pass init <gpg-id>`), `gopass edit <name>` (or `pass edit <name>`).

The user types the secret into `gopass edit` themselves. The agent never runs
`gopass edit` / `gopass insert` with a value it was given in chat.

## 3. Using a stored secret

- Read it **inside the consuming command**, so it never reaches the transcript:
  PowerShell `$env:TOKEN = gopass show -o <name>` then use `$env:TOKEN`; bash
  `TOKEN="$(gopass show -o <name>)" cmd`. Do not `echo`, `Write-Host`, log, or return it.
- Never run `gopass show` / `pass show` / `gopass cat` as a bare command whose output is
  displayed, and never copy an entry to the clipboard on the user's behalf.
- Never write the value into a file the agent creates: scripts, Postman environments,
  `.env`, markdown, memory, commit messages, MR text. Write the **entry name** instead.
- When a tool needs a value from a config file the repository already uses (for example a
  local connection-string file), read it at run time inside the script, never print it,
  and say only that it was read from that file.
- Mask any secret that must appear in an error or log excerpt (`***`); never show a
  prefix or suffix of it.

## 4. When the user pastes a secret

Do **not** repeat, quote or summarise the value. Reply with this notice first, in the
user's language (shown in Traditional Chinese):

> 偵測到您貼上了疑似機敏資料（密碼／金鑰／權杖／連線字串）。為避免外洩，我不會重複或儲存它。
> 建議改用 gopass 或 pass 這類機敏資料存放工具（`gopass edit <名稱>`），之後只告訴我項目名稱，
> 我會在執行時讀取，不會顯示出來。若這是正式環境或長期有效的值，建議視為已外洩並更換。

Then:

1. If a secret store is installed, offer the entry-name path; if not, give section 2.
2. Treat the pasted value as exposed to this conversation. Use it only if the task cannot
   continue otherwise **and** the user says to proceed; use it in-session only, never write
   it anywhere, never echo it.
3. If it is a production or long-lived credential, recommend rotating it.
4. Never save it to memory, workspace files, issue files, Postman files or commits.

## 5. Findings in existing files

If a secret is found in a file while working (a committed key, a plaintext password in a
document), report **where** (`path:line`, key name) and that it should be rotated and
removed; do not paste the value into the report. Existing repository conventions that
already embed a key (for example a hard-coded key the code reads) are noted as a risk,
not copied.

## Boundary

- This rule never widens what the agent may do: DB writes, remote Git and environment
  access still follow `database-safety.md`, `git-safety.md` and the workspace testing
  restrictions.
- The `rag-pat` skill has its own encrypted store for the RAG token; it is the one
  exception where the agent runs a tool that stores a secret, and only on the user's
  explicit invocation.
