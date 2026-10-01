# Requirement — Expense Approval Step

Extend the existing expense tool with an approval step.

- An expense starts as `draft`.
- Submitting an expense moves it to `submitted`.
- An approver can approve it (`approved`) or reject it (`rejected`).
- A rejected expense can be edited and submitted again.
- An approved expense is final and cannot be changed.
- Expenses over 500 require two distinct approvers before becoming `approved`.

Show the current state on the expense page.
