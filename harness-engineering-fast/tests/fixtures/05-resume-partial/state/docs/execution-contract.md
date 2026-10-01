# Execution Contract

Task: Reading List API
Source: ../SOURCE.md
Time budget: 90 minutes | T+0 = 09:00
Status: FROZEN
REQUIREMENT_FAST_GATE: PASS

---

## Goal

An HTTP API for adding books to a reading list, listing them, and marking them
finished.

---

## MUST Requirements

| ID | Requirement | Source |
|---|---|---|
| MUST-001 | POST /books creates a book with title and author, returns it with an id | "POST /books adds a book" |
| MUST-002 | GET /books returns all books | "GET /books returns all books" |
| MUST-003 | POST /books/:id/finish marks a book finished and records the finish date | "marks a book as finished and records the date" |
| MUST-004 | The list survives a server restart | "must survive a server restart" |

---

## Critical Business Rules

| ID | Rule | Source | Why critical |
|---|---|---|---|
| RULE-001 | A finished book remains in the list | "stays in the list. It is not removed" | Removing it looks like success in a demo and is wrong |

---

## Blocking Ambiguities

None.

---

## Safe Assumptions

```
ASSUMPTION A-001 — Finish date is recorded as an ISO 8601 date string in UTC.
Source: silent on format.
Why safe: no stated rule depends on the format; localized to one field; no
acceptance check involves the representation.
```

---

## Out of Scope

```
OUT-001 — Deleting a book.
Source support: absent.
Reason: not required.
```

---

## Critical Acceptance Checks

| ID | Check | Protects | How it will be verified |
|---|---|---|---|
| CHECK-001 | POST then GET returns the created book | MUST-001, MUST-002 | API |
| CHECK-002 | Finished book still appears in GET /books | RULE-001 | API |
| CHECK-003 | Books persist across a restart | MUST-004 | API + restart |
