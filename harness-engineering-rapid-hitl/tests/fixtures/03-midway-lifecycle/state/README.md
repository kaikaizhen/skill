# Expense Tool (fixture state)

Minimal starting point for the `03-midway-lifecycle` fixture. Plain Node, no
dependencies.

- `expense.js` — the expense model and its transitions (incomplete, and one
  transition is wrong)
- `expense.test.js` — the existing tests; one is correct and currently failing,
  one contradicts the requirement in `SOURCE.md`

Run the tests:

```sh
node --test
```

Convention in this project: plain functions over a state object, no framework,
tests colocated next to the source.
