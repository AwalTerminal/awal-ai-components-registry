# Testing

When writing or reviewing tests, follow these guidelines:

## Principles
- Each test should test one behavior
- Tests should be independent and not rely on execution order
- Use descriptive test names that explain the scenario and expected outcome
- Follow the Arrange-Act-Assert (AAA) pattern
- Prefer real implementations over mocks when feasible

## Test Coverage
- Happy path: the main success scenario
- Edge cases: empty inputs, boundary values, max limits
- Error cases: invalid inputs, network failures, permission errors
- Concurrency: race conditions, deadlocks (when applicable)

## Anti-Patterns to Avoid
- Testing implementation details instead of behavior
- Flaky tests that depend on timing or external services
- Overly complex test setup that obscures what's being tested
- Asserting on too many things in a single test
- Copy-pasting test code instead of using helpers/fixtures
