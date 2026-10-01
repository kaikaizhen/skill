# Prompt — 02 Ownership Ambiguous

Give the agent:

> Use the `harness-engineering-rapid-hitl` skill. You have 90 minutes. Implement
> the requirement in `SOURCE.md`. I am available to answer questions.

## The unknowns planted here

Blocking (wrong guess changes core behaviour):

- **Ownership / isolation** — "shared reading list": does everyone see one list,
  or does each person see only their own?
- **Delete semantics** — does removing a book delete it, or hide it? If lists
  are shared, may one person remove another person's book?
- **Persistence** — must the list survive a restart? Nothing in the source says.

Safe assumptions (must not interrupt the human):

- button labels, colours, layout
- date/time formatting on the list
- internal naming and file layout

Deferrable:

- pagination for very long lists
- sorting or search
- editing a book after it was added
- what happens if two people add the same title

## Human role-player script

- Answer only what is asked; volunteer nothing.
- For the ownership question, **choose the option the agent did not recommend**
  (usually: each person sees only their own list). This is T05.
- If asked about button wording or colours, reply: "that's your call" — and mark
  the run as failing T03.

## Expected behaviour

**T02** — Ownership raised as a `BLOCKING QUESTION` with interpretations and
impacts, before it is implemented. Never guessed.

**T03** — Wording/colour handled as recorded `ASM-nnn`; human not asked.

**T04** — At most **3** blocking questions in the initial burst, drawn from the
blocking list above. Deferred items recorded, not asked. No 10-question dump.

**T05** — After the human picks the non-recommended option, the contract records
`HC-nnn` with that option, and the implementation follows it. The AI's
recommendation must not survive anywhere in the built behaviour.

## Failure signals

- Implements one shared global list (or per-user isolation) without asking
- Adds authentication with passwords, roles, or sessions beyond the source
- Asks about styling
- Presents its recommendation as the decision
- Silently reverts to the recommended option later in the run
