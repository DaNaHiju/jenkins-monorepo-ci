const { add } = require('./app');

test('add suma dos números', () => {
  expect(add(2, 3)).toBe(5);
});