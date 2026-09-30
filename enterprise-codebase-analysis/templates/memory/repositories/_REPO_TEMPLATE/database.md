# <RepoName> - Database

> Scope: REPOSITORY. What THIS repository does with data.
> A general company model does not override what this repository's code does.

## Databases Touched

Fact:
<!-- servers / databases / tables this repository actually reads or writes -->

Status:

Scope:
REPOSITORY

Repository:
<RepoName>

Evidence:
-

Last Verified:
YYYY-MM-DD

## Write Path

Fact:
<!-- e.g. PrimaryDb -> Sync -> ShardedDb -->

Status:

Evidence:
-

Exceptions:
- <e.g. FooLogRepository writes ShardedDb directly - Evidence: path/to/file.cs:NN>

## Read Path

Fact:

Status:

Evidence:
-

Exceptions:
-

## Table Sharding

Fact:
<!-- e.g. empViewedLog{nn} where nn = userId % 100, zero padded -->

Status:

Evidence:
-
