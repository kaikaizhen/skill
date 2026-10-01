# Brief — Expense Split Calculator (CLI)

Build a command-line tool that splits a group expense.

Input: a JSON file listing participants and the amounts each of them paid.

```json
{
  "participants": ["alice", "bob", "carol"],
  "payments": [
    { "by": "alice", "amount": 60.00 },
    { "by": "bob",   "amount": 30.00 }
  ]
}
```

Behavior:

1. The total is split **equally** among all listed participants, including those
   who paid nothing.
2. The tool prints, for each participant, the amount they owe or are owed.
3. Amounts are rounded to 2 decimal places. The printed amounts must sum to zero
   after rounding.
4. If a payment names a participant not in the participants list, the tool exits
   with a non-zero status and an error message. It does not compute a result.
5. There is no persistence. Each run is independent.

Usage: `split <path-to-json>`

No UI. No network. Single user.
