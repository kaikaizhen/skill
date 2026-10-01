# Runtime & Model Contract

This skill is a **methodology, not a model integration**. It never selects, names,
configures or calls a model. The host - VS Code, an agent runtime, a CLI - owns
model choice; this file is the only place the engine describes what it *assumes*
about whatever model is currently selected, and how it adapts its context use to
that model's declared limits without changing any rule above it.

Load this file when: the task is large enough that context budget matters, the
context is being trimmed or summarised, the model was switched mid-ticket, or
someone asks how this skill relates to a provider / endpoint / model.

---

## 1. The boundary

```
        enterprise-codebase-analysis          this engine - never model-aware
                      |
                      v
                Agent Runtime                 owns: model choice, HTTP, auth,
         context manager | tool executor      transport, retries, streaming
                      |
                 Current Model                interchangeable reasoning engine
```

The engine states **what** to analyse, which evidence counts, when to stop and
what must be verified. The runtime decides **who** reasons about it. Neither
reaches into the other.

Forbidden in `SKILL.md`, `references/` and `templates/`: a provider name, a model
name, a model family, an endpoint, a host, a port, a token count, an API key name,
or any instruction that only works on one of them. A sentence that would have to
be rewritten when the model picker changes does not belong here - it belongs in
the workspace runtime descriptor (§2) or nowhere.

**Objective evidence, not model assertion.** A model's own statement is never
evidence that a build compiled, a test passed, a flow works or a file changed.
Only a real tool run is (HARD RULE 10, `verification.md` §1). This is what makes
models interchangeable here: the facts come from the toolchain, not from the
reasoner.

**Tool execution is local, always.** Every read, search, symbol/AST lookup, edit,
`git`, build, test, lint and container command runs on the machine holding the
working tree, under this skill's gates. A remotely served model receives prepared
context and returns proposed actions; it never executes anything and never reaches
the repository directly. Where a model is hosted is a runtime deployment detail
with no bearing on any rule in this skill.

---

## 2. `CurrentModel` - what the engine may assume

The engine assumes the runtime can tell it this much, and nothing more:

```
send(messages)              deliver prepared context
receive(response)           return the model's output
context_limit               usable input+output window, in tokens
capabilities                supports_tools | supports_structured_output
                            supports_reasoning | supports_multimodal
```

Anything the runtime does not declare is `UNKNOWN`, which behaves like every other
non-blocking unknown in this skill: take the conservative branch, record it, do not
block. Specifically - an undeclared `context_limit` is treated as *small*, and an
undeclared capability as *absent*.

The engine never implements transport. If the host already has a model picker (a
chat model selector, an agent runtime's own registry), that **is** the mechanism -
do not build a parallel provider framework beside it.

### Adapting to capability, without changing method

Capabilities change *how much is carried per turn*, never what counts as evidence,
which gate runs, what blocks an approval gate, or when to stop.

| Declared | Permitted adaptation |
|---|---|
| small `context_limit` | tighter scope slices, earlier structured summary (§4), more rolling turns |
| large `context_limit` | keep more raw evidence in-turn, fewer summary hops |
| `supports_tools: false` | the runtime runs the commands and feeds results back; evidence requirements are identical |
| `supports_structured_output: false` | gate outputs stay the prose / table forms in `templates/`; no schema is required |
| `supports_reasoning` either way | no rule changes; a gate is written output, not hidden deliberation |

A gate is never skipped, shortened below its required output, or substituted
because the selected model is small. If the budget cannot hold a gate's evidence,
the scope is split (§4) - the gate is not dropped.

---

## 3. Context budget - derived, never hardcoded

Compute from what the runtime declares; never from a remembered number.

```
hard_limit      = CurrentModel.context_limit
soft_limit      = hard_limit x 0.70 ~ 0.80     working ceiling
reserved_output = hard_limit x 0.10 ~ 0.15     never spent on input
safety_buffer   = whatever remains
```

Crossing `soft_limit` triggers §4 - it is not a failure. Mode caps the budget too,
independently of the model: Mode C and analysis-only requests carry no diff, no
build output and no loop state; verification work (steps 21-21.5) loads the diff,
the failure output and the baseline contract rather than rescanning the repository;
a Mode A ticket never loads an onboarding corpus.

### Priority - loaded first, dropped last

```
1  Skill rules and the active gate's requirements
2  Current mode
3  Ticket / goal
4  Acceptance criteria
5  Current evidence              (including current failure output)
6  Relevant workspace knowledge
7  Relevant source
8  Current diff
9  Build / test / lint result
10 Minimal previous-loop state
```

### Eviction order, when the budget is tight

```
1  stale tool logs (superseded command output)
2  source the confirmed scope does not touch
3  duplicate evidence (same fact, second source)
4  previous loop history -> compress
5  produce a structured summary (§4) and drop what it replaces
6  re-retrieve on demand instead of holding
7  split the remainder into the next scope slice
```

**Never evicted, never compressed:** priority items 1-4, and the current failure
evidence. If those alone do not fit, the scope is wrong - re-scope per
`scoped-scan.md`; do not trim a rule to make room.

---

## 4. Rolling context - large tasks

Agent history is not allowed to accumulate without bound. A task too large for one
budget is cut into scope slices, each ending in a structured summary carried
forward **in place of** its raw material:

```
Scope A -> analyse -> structured summary
Scope B -> analyse -> structured summary
            integrate -> implement
```

Each hop carries forward exactly: goal · acceptance criteria · confirmed findings
with their evidence pointers (`file:line`, command, log) · decisions taken ·
current diff · current failures · unresolved questions.

Each hop drops: verbose earlier reasoning · superseded tool output · source outside
the confirmed scope · failures already resolved.

A summary keeps the trust labels (`CONFIRMED` / `INFERRED` / `UNKNOWN` /
`OUTDATED` / `CONFLICTING`) and the pointer that would let the fact be re-verified.
A summary that drops its evidence pointer has demoted that fact to `INFERRED` -
label it so rather than carrying it forward as confirmed. Writing a summary does
not admit it to workspace memory; that still goes through `memory-admission.md`.

---

## 5. Switching model mid-ticket

Switching the selected model is **not** a new session. Nothing is re-initialised:
not the workspace, not the repository memory, not the ticket.

```
Preserved   ticket state and current step | acceptance criteria | scope decisions
            (In / Out) | gate outputs already produced | current evidence |
            current diff | build / test / lint results | loop state | unknowns
Replaced    CurrentModel - and therefore only the budget arithmetic of §3
```

On a switch: recompute §3 against the new `context_limit`, re-read the new
`capabilities`, and if the budget shrank, summarise per §4 before continuing.
Approval gates already passed stay passed; gate outputs already produced are not
regenerated. Gate 5's baseline does not move because the model moved. A ticket may
be analysed by one model, implemented by another and verified by a third - the
record is the written output plus the tool results, both model-neutral.

---

## 6. `DecisionProvider` - reserved seam

The judgements this skill makes at its decision points -

```
evidence_sufficient | acceptance_criteria_met | regression_risk
continue_or_stop    | next_action
```

- are today decided by the rules in this engine, read and applied by whatever model
is selected. That is the default and needs no abstraction.

The seam is reserved so an external decision service can later supply these
verdicts instead. Three constraints hold whatever supplies them:

1. A provider returns a **verdict plus its evidence**, never a verdict alone. An
   unsupported verdict is `UNKNOWN`.
2. No provider may weaken a HARD RULE, clear an approval gate, or mark an
   unresolved HIGH regression acceptable. Human approval gates stay human.
3. No provider writes code. It judges; implementation remains this skill's.

Nothing is to be built for this seam before a provider actually exists.

---

## 7. Retrieval sources - ranked

Retrieval may grow; its ranking may not. Semantic / vector search is a *candidate
generator* and never the evidence itself (SKILL.md -> Memory Routing):

```
exact search (rg / grep)     evidence
symbol / AST / LSP           evidence
workspace memory             navigation + history, not current truth
vector / semantic retrieval  candidates only - confirmed by one of the two
                             evidence sources above before being cited
```

A candidate that cannot be confirmed in current code is `NOT OBSERVED IN TRACED
PATH`, never `CONFIRMED MISSING`, and never sets scope, carrier, root cause or a
data design. Embedding model, index and store are runtime infrastructure, declared
in the workspace, never here.
