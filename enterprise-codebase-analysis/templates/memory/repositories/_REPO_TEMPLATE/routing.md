# <RepoName> - Shard / Connection Routing

> Scope: REPOSITORY. Confirming routing here does NOT confirm it anywhere else.

## Connection Factory

Fact:
<!-- class name and location -->

Status:

Scope:
REPOSITORY

Repository:
<RepoName>

Evidence:
- <path/to/DbConnectionFactory.cs:NN>

Last Verified:
YYYY-MM-DD

## Shard Selection

Fact:
<!-- e.g. shard = userId % 10; server = shard <= 4 ? SQL10 : SQL11 -->

Status:

Evidence:
-

Exceptions:
-

## Connection Strings / Secrets

Fact:
<!-- where they come from; count if known -->

Status:

Evidence:
-

## Promotion Note

Do not copy this section into `workspace/memory/shared/` on the strength of this repository
alone. Promotion requires a shared library, the same evidence in another
repository, official documentation, or DBA / developer confirmation.
