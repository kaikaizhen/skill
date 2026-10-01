# Credential Policy

HARD RULES 11-13. The skill never holds a secret: it asks a `CredentialProvider` to
materialise one for the duration of a command and then forget it.

```
gopass | pass  ->  CredentialProvider  ->  secure temp file  ->  ssh / scp  ->  cleanup
```

## 1. Logical paths (identical for every backend)

| Path | Holds |
|---|---|
| `nas/ssh/config` | text lines `host`, `user`, `port` (default 22) |
| `nas/ssh/key` | the SSH private key, OpenSSH format, whole secret |

`config` is not a secret but is still not echoed into reports. `key` is the secret.
Provider selection is a setting (`credential.provider: gopass | pass`); see
`runtime/credential-provider.md` for the contract.

## 2. Step 0 - credential check (existence, never content)

```
provider available          gopass --version | pass --version
store initialised            `gopass ls` | `pass ls` succeeds
entries exist                `gopass ls nas/ssh` shows `config` and `key`
config has the fields        host, user, port - checked by the adapter, values unprinted
```

Existence of the key is established by **listing**, never by showing it. Any miss
stops the run and names exactly what is missing. The skill never asks the user to
paste a key, password or token into the conversation, and never invents host / user.
A password instead of a key -> stop and say key authentication must be set up first.

## 3. Secure temp handling

The one rule that makes everything else hold: **the secret goes from the provider to
a file in a single command, with its output redirected to that file**, so it is never
returned to the agent's context.

1. Create the temp file in a per-run directory outside any repository and outside
   `workspace/`.
2. Restrict it to the current user **before** the key is written (`icacls` on
   Windows, `chmod 600` elsewhere).
3. Write: provider output redirected straight into the file. Not `echo`, not assigned
   to a variable that gets printed, not `set -x` / verbose tracing, not a CI log.
4. Use: `ssh -i <file> -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes`. The key
   path is a file path on the command line; the key itself never is.
5. **Cleanup in `finally`**, on success, failure, rollback and interrupt: overwrite
   then delete the file, then remove the per-run directory. Verify it is gone.

Host key: pinned through the user's `known_hosts`. Unknown host -> stop and have the
user verify the fingerprint; never `StrictHostKeyChecking=no`.

## 4. What may never contain a secret

Prompt · conversation · reports · logs / transcripts · the repository · `workspace/` ·
deployment metadata · `.deploy/` · command lines · error messages (redact before
quoting). A tool's failure output that echoes a secret is not quoted.

## 5. Migrating existing `pass` entries into gopass

Helper: `scripts/migrate-pass-to-gopass.sh`. It pipes each entry directly from one
store into the other - nothing printed, nothing logged, nothing written to a file:

```bash
pass show nas/ssh/config | gopass insert -m nas/ssh/config
pass show nas/ssh/key    | gopass insert -m nas/ssh/key
gopass ls nas/ssh            # expect: config, key   - and NEVER `gopass show nas/ssh/key`
```

- Needs both tools and the source GPG key on **one** machine; pass and gopass on
  different machines cannot be piped directly - run the helper where both exist.
- Refuses to overwrite an existing target entry without `--force`; never deletes the
  source; says nothing about content.
- After migration the `pass` entries stay as the user's own copy; deleting them is the
  user's decision.
- Modifying credentials or `authorized_keys` is an approval-gated action
  (`safety-policy.md` §3) - running the helper happens only because the user asked.
- If a key has ever been exposed (pasted into a chat, committed, printed), treat it as
  compromised: generate a new one, install the new public key, verify login, remove
  the old public key, store the new private key. That sequence is the user's.
