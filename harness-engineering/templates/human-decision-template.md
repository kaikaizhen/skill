# Human Decision Template

Authored **only** on the human's explicit answer. Never generated in advance,
never filled in by inference, never completed from a recommendation.

```markdown
# DEC-0nn — Human Architecture Decision

## Decision Metadata

Decision ID:
DEC-0nn

Decision:
<title>

Decision Status:
Accepted | Rejected | Deferred

Decision Authority:
Human

Decision Date:
<date>

## Decision Question

<the question, as analyzed>

## Analysis Evidence

Decision Analysis:
`<path>`

Analysis Evaluation:
`<path>`

Decision Analysis Gate:
PASS

## AI Recommendation

Recommended Option:
<option>

Confidence:
<High | Medium | Low>

This recommendation is historical analysis evidence. It is not human decision
authority and did not decide anything.

## Human Decision

Decision:
ACCEPT | REJECT | DEFER

Selected Option:
<the option the human chose>

Decision Reason:

<The human's own rationale, in the human's terms.>

Accepted By:
<attribution>

Decision Date:
<date>

## Recommendation Alignment

Accepted AI Recommendation | Diverged from AI Recommendation

## Decision Consequences

### Positive Consequences
- <...>

### Negative Consequences
- <...>

### Future Constraints
- <what this constrains going forward>
- Accepting this option must not be read as deciding <adjacent open decisions>.

## Affected Decisions

<Other decisions whose eligibility, dependencies, or option space this changes,
or None>

## Gate Result

HUMAN_DECISION_GATE = PASS
```

## Rules

**The human's reason is recorded in the human's terms.** Do not substitute the
analysis's reasoning — even when the human agrees with it, and even when the
analysis put it better. The record must show what the deciding authority actually
weighed. A decision record that reproduces the analysis's rationale is
indistinguishable from a decision that was never made.

**Agreement is the dangerous case.** When the human's conclusion matches the
recommendation, the record must still make clear that the human decided. Otherwise
a later reader cannot tell a decision from a default.

**Divergence is normal.** When the human chooses against the recommendation,
record it plainly as `Diverged from AI Recommendation`. Do not argue, do not
re-litigate, do not add a note explaining why the recommendation was still sound.
The recommendation was advice; the human is the authority.

**`HUMAN_DECISION_GATE = PASS` means one thing only:** an explicit, attributed
human decision exists for this decision point. It does not mean anyone judged the
decision correct. There is no evaluator for human judgment.

## REJECT and DEFER

**REJECT** — the human rejects all analyzed options. No ADR follows. Record why,
and what would need to change. The decision stays `Unresolved` in the derived
state, and a fresh analysis with a revised option space may follow.

**DEFER** — the human declines to decide now. Record why, and what must be
resolved first. The decision stays `Unresolved`. Do not treat a deferral as
permission to proceed on an assumption; a deferred decision blocks exactly what
it blocked before.

## What Never Produces This Artifact

- silence, or absence of objection
- a general instruction to proceed with the work
- a strong or high-confidence recommendation
- agreement inferred from an earlier, related decision
- the analysis reaching `READY_FOR_HUMAN_DECISION`

Only an explicit human answer to this specific decision produces this artifact.
