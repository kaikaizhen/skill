# <RepoName> - Patterns & Conventions

> Scope: REPOSITORY. What a new scenario in THIS repository should look like.
> Used to keep a new script small and consistent - not a target for refactoring.

## Script Template Shape

Fact:
<!-- the lifecycle hooks this tool expects (init / setup / default / teardown /
     handleSummary or equivalent) and what each is used for here -->

Status:

Evidence:
-

## Execution Profile Pattern

Fact:
<!-- how load/concurrency is declared: stages/ramping, constant, iteration-based
     - and which pattern each kind of scenario in this repo actually uses -->

Status:

Evidence:
-

## Request-Building Pattern

Fact:
<!-- how a request body/params is assembled: fixed, randomised, combinatorial.
     Cite the actual generator, not just "randomised" -->

Status:

Evidence:
-

## Data-Loading Pattern

Fact:
<!-- when/how fixture data is read (e.g. once at init, cached module-level) and
     why - a tool-specific constraint (e.g. "file I/O only allowed at init")
     belongs here, cited from the tool's own docs or observed behaviour -->

Status:

Evidence:
-

## Environment / Target Switching

Fact:
<!-- how the target environment is selected (env var, CLI flag, config file)
     and what changes per environment -->

Status:

Evidence:
-

## Stats / Output Contract

Fact:
<!-- what a scenario is expected to report at the end, and through which
     mechanism. If some fields a report claims to include are never actually
     populated (a stats hook defined but never called), record that here as
     the gap it is - not silently matched to the report's own claim. -->

Status:

Evidence:
-

## Reference Implementations

<!-- Known-good scripts to copy the shape of when adding a similar scenario -->

- <scenario kind> -> `path/to/reference-script.js`
