# Time Budget

Default budget: **90 minutes**. Supported range: roughly 60-180.

## Indicative shape (90 min)

| Window | Focus |
|---|---|
| 00-05 | Rapid understanding |
| 05-10 | Initial blocking questions + contract |
| 10-15 | Minimum implementation direction |
| 15-65 | Vertical slice implementation |
| 65-82 | Critical verification + fixes |
| 82-90 | Final acceptance + cleanup |

**This is guidance, not law.** The distribution flexes with the task. One rule
does not flex:

> Reserve the last **15-20%** of the budget for verification.

Implementation does not borrow from the verification reserve. A feature finished
at minute 88 with no evidence is not delivered — it is unverified code.

## Scaling

| Budget | Understanding | Questions | Implementation | Verification reserve |
|---|---|---|---|---|
| 60 min | ~3 min | ≤2 initial | ~35 min | ~12 min |
| 90 min | ~5 min | ≤3 initial | ~50 min | ~17 min |
| 180 min | ~10 min | ≤3 initial | ~110 min | ~30 min |

Note the question budget does not scale with time. More time is not a licence to
interrogate the human; it is room for more slices.

## Human wait time

Waiting for a human answer is not idle time. While waiting:

- continue work that does **not** depend on the open question
- do not start work that the answer could invalidate
- do not adopt the AI recommendation to "save time"

If the human does not answer and the deadline arrives, the honest output is
`NEEDS_ATTENTION` with the open question — not a guess.

## Priority under pressure

When time is short, keep in this order:

1. MUST behaviours
2. Critical business rules
3. Critical verification
4. Failure handling
5. Optional features
6. Polish

Cut from the bottom. With ~20 minutes left (on a 90-minute budget): **stop
low-value optional coding and start critical verification.** An incomplete but
verified core beats a complete but unverified feature set.

## Checkpoints

Ask at each checkpoint, briefly:

| Checkpoint | Question |
|---|---|
| End of understanding | Do I know the first slice and the blocking unknowns? |
| First slice done | Did I get real feedback in under ~20 minutes? |
| Mid-implementation | Are the MUST behaviours ahead of the optional ones? |
| Verification reserve start | Is every critical rule executed, not just written? |
| Final gate | Does any fail-closed condition hold? |

## Reporting time honestly

If the budget ran out mid-slice, say so and say where. Do not present a partial
implementation as complete, and do not extend silently past a stated deadline
without telling the human.
