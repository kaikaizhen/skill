# <RepoName> - Test Data

> Scope: REPOSITORY.
> Never store an actual secret value here (cookie, token, connection string) -
> a file path and a caution note are enough; see repository-onboarding.md ->
> Allowed / Forbidden.

## Data Files

Fact:
<!-- file -> what it holds -> which script(s) read it -->

Status:

Scope:
REPOSITORY

Repository:
<RepoName>

Evidence:
-

Last Verified:
YYYY-MM-DD

## Generation Pipeline

Fact:
<!-- for each data file: hand-maintained, or derived from a raw source file by
     a checked-in generator script? If a generator exists, cite it. If a
     sibling data file has NO generator despite looking derived, say so -
     that inconsistency is itself a fact worth recording, not an assumption
     to paper over. -->

Status:

Evidence:
-

## Ratio / Distribution Parameters

Fact:
<!-- config values that encode test intent, not just data volume - e.g. a
     logged-in:logged-out ratio, a scenario-combination split. State WHERE the
     value lives (one config file, or duplicated per script) -->

Status:

Evidence:
-

## Secrets Caution

<!-- File path + whether it is protected (.gitignore entry, no git repo at all,
     an untracked path). Never the value. -->

-
