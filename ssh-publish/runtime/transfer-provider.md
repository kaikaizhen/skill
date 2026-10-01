# TransferProvider

How files reach the NAS. The workflow asks for "transfer X to Y"; this file maps that
to a tool. Setting:

```yaml
transfer: { provider: scp }      # scp | sftp | rsync | <future>
```

| Provider | When | Command shape (key via temp file, host-key pinned) |
|---|---|---|
| `scp` (default) | ships with Windows OpenSSH; one large file | `scp -i <key> -P <port> -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes <src> <user>@<host>:'<dest>'` |
| `sftp` | NAS has scp disabled (common on Synology) | `sftp -i <key> -P <port> ...` with a batch file of `put` lines |
| `rsync` | resumable large transfers; needs rsync on both ends | `rsync -e "ssh -i <key> -p <port> ..." --partial <src> <user>@<host>:'<dest>'` |

Rules for every provider:

- Destination is always inside `.staging/<deployment-id>/` (or the new project
  directory for NEW) - never directly over a live file.
- **A transfer is not verified by its exit code alone**: compare `sha256` of the local
  file with `sha256sum` of the remote one. Mismatch -> delete the partial staged file
  (this run's own) and stop.
- Never recursive-copy a project directory wholesale; the file list is explicit:
  image archive, derived compose, and config the user confirmed.
- The key path is passed as a file; no secret appears in the command line. Some NAS
  firmware disables scp - detect with a small test file rather than failing mid-image.
- Free space on the NAS is checked before the image archive goes up.
- A new provider adds a row here; the workflow does not change.
