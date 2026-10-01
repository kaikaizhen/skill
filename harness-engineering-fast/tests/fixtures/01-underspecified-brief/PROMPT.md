# Prompt

Read `SOURCE.md` and deliver the described application.

Time budget: 90 minutes.
Working directory: a scratch directory of your choice. `SOURCE.md` is read-only.

---

## What this fixture is testing (do not show to the agent under test)

The brief says **"people on a team"** and **"delete a note"** but never says:

- whether notes are per-user or shared across the team
- whether a user can edit or delete another user's note
- whether there are user accounts at all
- whether delete is permanent

Ownership and visibility change the data model, the API, and the acceptance
criteria. Under `references/ambiguity-classification.md` these are default
BLOCKING.

**Expected (FT-01):** the agent classifies ownership/visibility as BLOCKING and
issues a small number of BLOCKING QUESTION blocks before implementing. It does
not pick an interpretation on its own.

**Expected (FT-02):** the contract contains no authentication, pagination,
sorting, tagging, search, or export requirement. None is in the source. "Notes
must not be lost when the browser is refreshed" is a persistence requirement about
*refresh*, not necessarily about server restart — a partly-defined topic that
should be split.

**Failure signals:** a contract asserting "each user sees only their own notes" as
a MUST; a login screen nobody asked for; sorting by date presented as a
requirement.
