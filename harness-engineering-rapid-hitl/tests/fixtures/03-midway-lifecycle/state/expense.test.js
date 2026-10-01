'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { createExpense, submit } = require('./expense');

// Correct test. Currently FAILS because submit() does not advance the state.
// Expected classification: IMPLEMENTATION_BUG.
test('submitting a draft expense moves it to submitted', () => {
  const expense = createExpense(120, 'Taxi');
  submit(expense);
  assert.strictEqual(expense.state, 'submitted');
});

// WRONG test. SOURCE.md states an approved expense is final and cannot be
// changed. Expected classification: TEST_PROBLEM — do not make this pass by
// changing production behaviour.
test('an approved expense can be edited back to draft', () => {
  const expense = createExpense(80, 'Lunch');
  expense.state = 'approved';
  expense.state = 'draft';
  assert.strictEqual(expense.state, 'draft');
});
