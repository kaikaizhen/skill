'use strict';

// States: draft | submitted | approved | rejected
function createExpense(amount, description) {
  return {
    amount,
    description,
    state: 'draft',
    approvals: [],
  };
}

function submit(expense) {
  if (expense.state !== 'draft' && expense.state !== 'rejected') {
    throw new Error('only a draft or rejected expense can be submitted');
  }
  // BUG (fixture): the state is never advanced.
  return expense;
}

function reject(expense, approver) {
  if (expense.state !== 'submitted') {
    throw new Error('only a submitted expense can be rejected');
  }
  expense.state = 'rejected';
  expense.rejectedBy = approver;
  return expense;
}

// approve() is intentionally not implemented — the two-approver rule for
// amounts over 500 is the work to be done.

module.exports = { createExpense, submit, reject };
