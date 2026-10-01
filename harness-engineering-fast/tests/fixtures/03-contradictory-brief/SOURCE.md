# Brief — Support Ticket Queue

Build a small service for tracking support tickets.

## Overview

Agents pick up tickets from a shared queue. A ticket has a subject, a body, a
status, and an assignee.

## Requirements

- A ticket starts in status `open` with no assignee.
- An agent can claim an open ticket. Claiming sets the assignee to that agent and
  the status to `in_progress`.
- An agent can close a ticket they are assigned to. Status becomes `closed`.
- **A closed ticket cannot be reopened.** Once closed, it is final; this is
  important for our reporting.
- Tickets are listed newest first.

## Appendix — Agent workflow notes

When a customer replies to a ticket that has already been closed, the ticket is
**reopened automatically** and returns to `open` status with the assignee
cleared, so that it re-enters the queue.

Agents should also be able to reopen a ticket manually from the ticket detail
view if they closed it by mistake.
