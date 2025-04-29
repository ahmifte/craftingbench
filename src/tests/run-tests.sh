#!/usr/bin/env bash

# Exit on error
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=== CraftingBench Test Runner ==="
echo "Repo Root: $REPO_ROOT"
echo "Test Directory: $SCRIPT_DIR"

# Source the craftingbench script
echo "Sourcing craftingbench.sh..."
cd "$REPO_ROOT"
source ./craftingbench.sh

# Create test output directory
TEST_OUTPUT_DIR="$SCRIPT_DIR/test-output"
mkdir -p "$TEST_OUTPUT_DIR"

echo "=== Running Shell Tests ==="
cd "$SCRIPT_DIR"
echo "Running BATS tests..."
bats ./shell-tests/*.bats

echo "=== Running Documentation Validation Tests ==="
cd "$SCRIPT_DIR"
echo "Running Jest tests..."
npm test

echo "=== All tests completed successfully! ===" 