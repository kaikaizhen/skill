# Notes (fixture state)

A small notes service. Plain Node, no dependencies, no framework.

## Conventions

- One module per concern, plain exported functions.
- Persistence: a single JSON file via `store.js`. Do not add another store.
- Every record carries `ownerId`; reads are always filtered by owner.
- Tests colocated as `*.test.js`, run with `node --test`.

## Commands

```sh
node --test        # tests
node index.js      # run
```
