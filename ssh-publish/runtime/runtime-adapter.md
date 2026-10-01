# Runtime Adapter

The skill states *what* to do; the adapter below is *how this host runs it*. Commands
in the references are conceptual - this file is where they become real, and where
host quirks live so the references stay clean.

## Local machine (where build / save run)

| Need | Note |
|---|---|
| Docker | `docker version` must reach a server. `--platform` is the NAS architecture, not the host's; cross-building needs buildx / QEMU emulation. Report if unavailable. |
| Scratch dir | per-run directory outside any repository and outside `workspace/`; holds the `.tar` and the temp key |
| Key file ACL | Windows: `icacls <f> /inheritance:r /grant:r "$env:USERNAME:R"`; POSIX: `chmod 600` |
| Shell | build commands from an argument array / quoted strings; no string-concatenated user input |
| Git | read-only subcommands only (`status`, `rev-parse --short HEAD`, `diff`) |
| Checksums | `Get-FileHash -Algorithm SHA256` / `sha256sum` |

## NAS (remote commands over SSH)

| Quirk | Handling |
|---|---|
| docker needs elevation | detect the working prefix in preflight (`docker` / `sudo docker` / full path) and use it for every docker call; configurable as `nas.docker_cmd` |
| `docker compose` vs `docker-compose` | detect once; use the one that works |
| non-interactive sudo | requires passwordless sudo for docker; if a prompt would appear, stop and report - never send a password |
| paths with non-ASCII / spaces | always single-quote remote paths |
| clock | the run's timestamp is the local machine's; used for ids only |
| shell | assume POSIX `sh`; avoid bashisms in remote one-liners |

## Operations the adapter must provide

```
run_local(cmd)            -> exit code, stdout, stderr (redacted)
run_remote(cmd)           -> same, over SSH with the temp key, host-key pinned
upload(src, dest)         -> per TransferProvider, checksum verified
with_key(fn)              -> create restricted temp key via CredentialProvider,
                             run fn, always clean up
```

Every result carries its **exit code** - that is what the report's `PASS` / `FAILED`
is built from (`references/safety-policy.md` §5). Output is redacted before display.
No operation here may log a secret, and none may run on the NAS something that
safety-policy §4 forbids.
