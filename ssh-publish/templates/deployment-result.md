## NAS Deployment Result

### Project
<name> (folder: <project-folder>)

### Mode
NEW / UPDATE

### Target
<deploy_root>/<project-folder>

### Image
<repo>:<tag>   platform <linux/..>   local commit <sha>[-dirty]

### Backup
UPDATE: backup id <YYYY-MM-DD_HHmmss> - VERIFIED / NOT VERIFIED     NEW: not applicable
Data: <classification outcome, e.g. "database: DB-native dump OK; uploads: excluded by policy">

### Docker
- Local Build: PASS / FAILED / NOT RUN        <exit code>
- Image Export: PASS / FAILED / NOT RUN       <tar size, sha256 short>
- Transfer: PASS / FAILED / NOT RUN           <checksum match: yes/no>
- Docker Load: PASS / FAILED / NOT RUN        <expected tag present: yes/no>
- Compose: PASS / FAILED / NOT RUN            <compose config exit, up -d exit>

### Nginx
- Config: <conf.d/<project-folder>.conf> - CREATED / UPDATED / UNCHANGED
- Syntax Check: PASS / FAILED / NOT RUN
- Reload: PASS / SKIPPED / NOT RUN

### Health
PASS / FAILED / container-only (no application check defined)
<each check with its real result, e.g. http 200 in 7s>

### Rollback
Not required / PERFORMED - verified PASS / ROLLBACK FAILED - MANUAL INTERVENTION

### Git
No push performed. Uncommitted changes at build time: yes / no

### Cleanup
Local tar: removed / kept (failed run) · Staging: removed · Temp key: removed

### Final Status
DONE / FAILED / ROLLED BACK / INCOMPLETE - <reason>

<!-- No credentials, key material, .env values or tokens anywhere in this report.
     DONE only when every line above that applies is a real PASS (HARD RULE 14). -->
