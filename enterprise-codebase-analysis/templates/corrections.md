# Corrections

> LOCAL ONLY. Append-only log of significant memory corrections.
> The memory file itself must also be corrected in place (targeted edit).
>
> How to read this file:
> - Apply only entries with `Status: CURRENT`.
> - `Status: OUTDATED` entries are history. Their rules must NOT be applied; follow
>   `Superseded by`.
> - Text under `Previous Understanding (OUTDATED - do not apply)` is never a rule.
> - The authoritative fact always lives in the memory file listed under
>   `Current Rule Location`, not in this log.
>
> Never delete an old entry. When a newer correction replaces it, set the old entry
> to `Status: OUTDATED` and fill `Superseded by` with the new entry's heading.

<!-- Entry format:

## YYYY-MM-DD - Topic

Status:
CURRENT / OUTDATED

Superseded by:
<later entry heading, or -> when CURRENT>

Current Rule Location:
- memory/<path>.md  (<section>)

Repository:

Issue:

Previous Understanding (OUTDATED - do not apply):

New Understanding:

Evidence:

Impact:

Memory Files Updated:
- workspace/memory/repositories/<Repo>/<file>.md  (<section>)
-->
