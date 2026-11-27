# Ticket Fit Check - does the ticket match today's reality, before any code

Runs **unasked, at the start of every Mode A ticket** (inside Gate 1, before the
plan), and again whenever new facts arrive mid-work. The ticket (UA card, issue,
acceptance criteria, planner copy) is the scope authority, but it is written from
memory of how the system behaves. The user must not be the one who discovers, halfway
through, that a line of the ticket contradicts the code, another line, another
screen, or leaves a case undefined. Find it first and hand it over as a question.

This applies to **every layer and every kind of problem**: frontend, backend, data,
APP / other clients, and the non-code parts - copy, labels, error messages, flows
the planner described.

## 1. What to compare - each ticket line against the current facts

Take each requirement line and test it against the repository, runtime and the other
lines. Report a line only when a check below **fails with evidence**:

| Check | The question | Typical finding |
|---|---|---|
| Already true / already false | does the system already do this, or assume something that does not exist? | the ticket says "add field X"; X exists under another name / the ticket says "keep the existing check"; there is none |
| Contradicts current behaviour | does the line change a rule other code or screens depend on? | a range, required-ness or format that another screen, the APP or a report relies on |
| Contradicts itself | do two lines (or the AC and the description) disagree? | "required" in one line, "optional" in another; a field shown in the mock but absent from the AC |
| Undefined case | which entry path, user type or state does the ticket not describe? | the redirect / campaign entry, post-back after an error, an already-registered member, the other client |
| Undefined value | is a number, range, code, wording or default missing? | "reasonable range", an unnamed option list, no error text |
| Wording / copy | is user-facing text missing, inconsistent with existing terms, or impossible to fit the control? | two names for one concept; a label longer than the field; an error message with no trigger |
| Cross-layer parity | would front end, back end, DB, APP and preview all apply the same rule? | the web validates, the APP cannot; the page restricts, the profile page does not |
| Dependency / contract | does it need something outside this repository's control? | an external system, a planner decision, a release order between two tickets |
| Compatibility | what happens to existing data and old clients? | stored values that the new rule rejects |

A **non-code** problem (a missing definition, an unclear wording, a decision nobody
made) is raised exactly like a code problem: it is a finding, with an owner.

## 2. How a finding is reported - one self-contained row, ready to send

```
Ticket line      the exact sentence / AC number
Current fact     what the system does today, path:line (or "no evidence found: <where looked>")
Why it matters   the concrete wrong outcome, one sentence
Ask              who decides (planner / front-end / APP / DBA / owner) + the question, worded so it can be pasted as is
If unanswered    the default I will implement, and whether work can proceed
```

- **Only confirmed doubts.** A suspicion is traced to evidence or dropped. No generic
  caveats, no restating the ticket, no list of lines that were fine - one line "ticket
  matches current state" when nothing failed.
- **Blocking vs not.** A doubt that makes safe implementation impossible stops that
  part (`STATUS: BLOCKED` for it only). Every other doubt is non-blocking: implement
  the stated default, keep the question open, and make the default easy to change.
- **Never silently choose.** Implementing one reading without saying it is the same
  failure as not noticing.
- **Do not decide for the owner.** A scope or policy question goes to its owner with a
  recommendation (`design-review-lens.md` §1 for external-contract questions).

## 3. When to run it again

- the ticket text, AC or mock changes;
- a reply from the planner / front end / APP changes an assumption;
- implementation meets a case the ticket did not describe (add it as a new row, do
  not decide it quietly);
- before the completion report: re-read the ticket once more against what was built
  and list any line that is no longer true.
