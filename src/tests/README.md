# CraftingBench Tests

This directory contains tests to validate that CraftingBench templates are working correctly and that the output matches the documentation.

## Test Structure

- `shell-tests/`: BATS (Bash Automated Testing System) tests for shell script functionality
- `*.test.ts`: Jest tests written in TypeScript to validate documentation against actual template output
- `test-output/`: Directory where test projects are created (gitignored)

## Running Tests Locally

1. Install dependencies:
   ```bash
   npm install
   npm install -g bats-core
   ```

2. Run all tests:
   ```bash
   ./run-tests.sh
   ```

3. Run only shell tests:
   ```bash
   bats ./shell-tests/*.bats
   ```

4. Run only documentation validation tests:
   ```bash
   npm test
   ```

## Test Coverage

The test suite validates:

1. Basic functionality of each template script
2. Consistency between actual template output and documentation
3. Project structure validation for each template type
4. Expected files and configuration in generated projects

## GitHub Actions Integration

These tests run automatically in GitHub Actions whenever:
- Code is pushed to the main branch
- A pull request is opened or updated
- The workflow is manually triggered

The workflow file can be found at `.github/workflows/test.yml`. 