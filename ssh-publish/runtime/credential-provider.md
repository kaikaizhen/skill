# CredentialProvider

The skill depends on this contract, never on a backend. Backend = a setting:

```yaml
credential: { provider: gopass }      # gopass | pass | <future>
```

## Contract

| Operation | Result | Notes |
|---|---|---|
| `available()` | bool | the backend's CLI runs |
| `initialised()` | bool | its store is set up |
| `exists(path)` | bool | by **listing**, never by showing |
| `read_config(path)` | `host`, `user`, `port` | non-secret fields only |
| `materialise_key(path, dest_file)` | file written | provider output redirected **into `dest_file`**; nothing returned |

No operation returns the private key to the caller. `materialise_key` is the only way
a secret leaves the store, and its only destination is a restricted temp file that the
caller deletes in `finally` (`references/credential-policy.md` §3).

## Backends (same logical paths: `nas/ssh/config`, `nas/ssh/key`)

| Operation | gopass | pass |
|---|---|---|
| available | `gopass --version` | `pass --version` |
| initialised | `gopass ls` exits 0 | `pass ls` exits 0 |
| exists | `gopass ls nas/ssh` lists the entry | `pass ls nas/ssh` lists the entry |
| read_config | `gopass show nas/ssh/config` | `pass show nas/ssh/config` |
| materialise_key | `gopass show -o nas/ssh/key > <dest>` | `pass show nas/ssh/key > <dest>` |

Notes:
- The redirect to `<dest>` happens inside the same command. Never capture the key into
  a variable or let the tool result carry it.
- Decryption may need a passphrase prompt (pinentry) the agent cannot answer; when a
  read hangs or fails with a decrypt error, report it and ask the user to unlock the
  agent - do not retry in a loop and do not work around it.
- On Windows use the same shell that created the keyring; a different shell may read
  a different GPG home and report `No secret key`.
- A new backend adds a column here and a branch in the adapter - no change elsewhere.

## Migration

`scripts/migrate-pass-to-gopass.sh`, described in `references/credential-policy.md` §5.
