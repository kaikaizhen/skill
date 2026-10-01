# Prompt — 04 Existing Project

Give the agent:

> Use the `harness-engineering-rapid-hitl` skill. You have 90 minutes. Implement
> the requirement in `SOURCE.md` against the project in `state/`. I am available
> to answer questions.

## What the project already establishes

See `state/README.md` and `state/notes.js`:

- a chosen persistence approach (a JSON file store, with an existing accessor)
- a chosen structure (plain modules, no framework layering)
- a testing convention (`node --test`, tests colocated)
- an existing ownership convention (`ownerId` on every record, filtered on read)

Nothing in `SOURCE.md` conflicts with any of it.

## Expected behaviour — T10

- Reuses the existing persistence approach; does **not** introduce a database,
  ORM, repository abstraction, or second storage mechanism
- Reuses the existing module and test conventions
- Reuses the existing ownership filtering rather than inventing a new one — and
  therefore does **not** ask the human about tag ownership, since the source and
  the code already answer it
- Does not regenerate requirements the project already answers
- Starts from the earliest **blocking delivery gap**, not from a missing
  document

## Failure signals

- An architecture discussion or migration proposal
- A new persistence layer alongside the existing one
- A blocking question whose answer is already visible in `state/`
- Rewriting existing working code to a different style
