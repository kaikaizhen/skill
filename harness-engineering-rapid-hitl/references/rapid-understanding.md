# Rapid Understanding

Goal: in **1-5 minutes**, know enough to start safely. Not enough to be
comprehensive — enough to name the goal, the first slice, and the unknowns.

Producing a full analysis document before touching code is a failure mode here,
not diligence.

## Inspection order

Stop as soon as you can state the goal, the first slice, and the unknown list.

1. **User requirement / source** — the literal ask. Quote it; do not paraphrase
   it into something more convenient.
2. **README** — declared purpose, setup, run instructions.
3. **Project structure** — top-level layout, where code actually lives.
4. **Entry point** — how the application starts.
5. **Existing architecture** — layering, framework, conventions in use.
6. **Existing domain model** — entities and their relationships.
7. **Existing related feature** — the closest thing to what you are asked to
   build. This is usually the single highest-value read.
8. **Build command** — and whether it currently succeeds.
9. **Test command** — and whether tests currently pass.
10. **Current git / workspace state** — uncommitted work, branch, half-done
    changes.
11. **Existing conventions** — naming, error handling, validation, logging.
12. **Authentication / persistence** — only if the requirement touches them.

## Rules

- **Read the closest existing feature before designing a new one.** Matching an
  existing pattern is faster and safer than inventing one.
- **Run the build early.** An already-broken build is evidence you need before
  the first slice, not a surprise for minute 50.
- **Historical evidence != current state.** A README, comment, or old doc
  describes what someone once intended. Verify against the code and the build.
- **Artifact exists != artifact trusted.** A design document in the repo is
  input, not authority.
- **Do not extrapolate.** If the source says "a list of items", the source did
  not say pagination, sorting, search, export, or auth. Unstated ≠ implied.
- **Timebox.** If understanding has run past ~5 minutes, you are probably
  analysing instead of collecting: write down what you have, classify the
  unknowns, and move.

## Output

Feed directly into the Working Model:

- **Goal** — one or two sentences.
- **Current understanding** — evidence-backed, with where each item came from.
- **Candidate MUST behaviours** — sourced only.
- **Unknown list** — raw, unclassified; classification is the next stage.
- **Build/test commands** — and their observed current status.
- **First candidate slice** — the smallest end-to-end thing worth doing.

## Anti-patterns

| Anti-pattern | Why it fails here |
|---|---|
| Reading every file before starting | Burns the budget; most files never matter |
| Writing a requirements document | Rapid HITL replaces volume with human answers |
| Inferring requirements from directory names | Inference is not evidence |
| Skipping the build check | Hides an environment problem until it is expensive |
| Assuming the previous project's domain applies | Fresh domain, fresh evidence |
