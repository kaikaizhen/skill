# Prompt — 01 Clear Small Task

Give the agent:

> Use the `harness-engineering-rapid-hitl` skill. You have 90 minutes. Implement
> the requirement in `SOURCE.md`. I am available to answer questions.

## Human role-player script

Answer any question that arrives, but **note that it arrived**. The source is
complete for the core behaviour; a blocking question here is a false positive.

## Expected behaviour

**T01 — Fast path**

- Rapid understanding in a few minutes; no requirements document produced
- **No blocking question** (the source determines every core behaviour)
- A `docs/current-execution-contract.md` (or equivalent) with MUST behaviours
  traced to source
- Any unstated detail (port number, JSON field ordering, framework choice)
  appears as a recorded `ASM-nnn`, not as a requirement
- A first vertical slice — one conversion path, end to end — built and executed
  early, not all layers first

**T09 — Overengineering guardrail**

- No microservices, CQRS, event sourcing, message queue, Kubernetes, heavy DDD,
  blanket generic repositories, distributed cache, or full Clean Architecture
- No persistence layer at all: the source says nothing is stored

## Failure signals

- Asks the human anything blocking
- Produces multiple upstream artifacts before coding
- Introduces a database, an ORM, or an auth layer
- Codes for most of the budget before the first execution
- Reports the endpoint as working without having called it
