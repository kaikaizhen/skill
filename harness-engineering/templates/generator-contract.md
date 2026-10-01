# Generator Contract Template

Every generation step declares this contract before it runs. Fill every field.
An unfilled field is an undefined permission, and undefined permissions are where
integrity failures come from.

---

## Generator

Stage:
`<lifecycle stage this generator belongs to>`

Purpose:
`<what artifact this produces, in one sentence>`

---

## Input

Primary Input:
`<the upstream artifact this derives from — path>`

Upstream Gate Required:
`<GATE_NAME> = PASS`

Upstream Gate Evidence:
`<path to the evaluation declaring that gate>`

The generator verifies the upstream gate before producing anything. If the
upstream gate is absent or not PASS, the generator stops. See Stop Condition.

---

## Allowed Reads

Enumerate every path this generator may read. No wildcards over directories that
contain artifacts from later stages.

- `<path>`
- `<path>`

Reading anything not listed is a contract violation.

---

## Protected Inputs

Enumerate every artifact that must not change. These are typically the upstream
authority chain and the original source material.

- `<path>` — read-only
- `<path>` — read-only

Modification of any protected input is a critical integrity failure.

---

## Allowed Writes

Enumerate the exact paths this generator may create or modify. Full paths, no
remainders.

- `<path>`

Do **not** express this as a prohibition on "other files." Positive enumeration
only — see `references/lessons-learned.md`, L-001.

---

## Expected Output

Artifact:
`<canonical path>`

Required Sections:

- `<section>`
- `<section>`

Required Identifier Family:
`<prefix and numbering scheme>`

Every generated unit cites at least one upstream identifier that actually exists.

---

## Forbidden Output

Enumerate what this generator must never produce. Be specific to the stage.

- content with no upstream support
- answers to any preserved open question
- `<stage-specific prohibitions — e.g. technology selections, schema design,
  component structure, decisions the human owns>`
- any file outside Allowed Writes

---

## Source Authority

Declare the precedence order this generator operates under, and what governs on
conflict:

```
<upstream> -> <upstream> -> <this artifact>
```

On conflict with an upstream artifact, the upstream artifact governs. The
generator does not resolve upstream contradictions — it stops and reports them.

---

## Self Check

The generator ends by checking its own output against the contract:

| Check | Question |
|---|---|
| CHECK-001 | Does every generated unit cite an upstream identifier that exists? |
| CHECK-002 | Was anything produced that Forbidden Output prohibits? |
| CHECK-003 | Were any writes made outside Allowed Writes? |
| CHECK-004 | Were any Protected Inputs modified? |
| CHECK-005 | Is every required section present? |
| CHECK-006 | Are all identifiers unique and correctly parented? |
| CHECK-007 | Was any preserved unknown answered? |
| CHECK-008 | Is the authority declaration present and correct? |
| `<...>` | `<stage-specific checks>` |

**The self check is a drafting aid. It is not a gate and does not authorize
promotion.** The artifact remains UNVERIFIED until an independent evaluation
passes. See `references/gate-model.md`.

---

## Stop Condition

The generator stops and reports, rather than proceeding, when:

- the upstream gate is absent or not PASS
- a required input is missing — record the absence; never substitute a different
  artifact and describe it as the expected one (L-014)
- the upstream artifacts contradict each other
- producing the output would require answering a preserved open question
- producing the output would require a decision owned by a human
- producing the output would require writing outside Allowed Writes

On stop, report: what was expected, what was found, and what is needed to proceed.
Produce no partial artifact that a later reader could mistake for a complete one.
