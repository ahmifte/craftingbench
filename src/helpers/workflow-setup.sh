#!/bin/bash

# Helper script to set up GitHub workflows for different project types

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_TEMPLATES_DIR="$SCRIPT_DIR/../templates/github-workflows"
TARGET_WORKFLOWS_DIR=".github/workflows"

# Create workflows directory if it doesn't exist
mkdir -p "$TARGET_WORKFLOWS_DIR"

setup_workflow() {
    local project_type="$1"
    local working_dir="${2:-.}"
    local workflow_name="ci.yml"

    # Copy base workflow first as it's needed by all other workflows
    cp "$WORKFLOW_TEMPLATES_DIR/base-ci.yml" "$TARGET_WORKFLOWS_DIR/"

    case "$project_type" in
        # Combination/advanced project types should come first
        "fullstack" | fullstack-*)
            cp "$WORKFLOW_TEMPLATES_DIR/fullstack-workflow.yml" "$TARGET_WORKFLOWS_DIR/ci.yml"
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "nextjs-fastapi" | nextjs-fastapi-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Next.js + FastAPI CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  backend:
    uses: ./.github/workflows/python-workflow.yml
    with:
      working_directory: backend
      python_versions: '["3.9", "3.10", "3.11"]'
      requirements_file: requirements.txt
      test_command: pytest
      lint_command: ruff check

  frontend:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: frontend
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
      build_command: build
      test_command: test
      lint_command: lint

  integration:
    needs: [backend, frontend]
    uses: ./.github/workflows/base-ci.yml
    with:
      working_directory: .
      enable_coverage: false
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "flask-react" | flask-react-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Flask + React CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  backend:
    uses: ./.github/workflows/python-workflow.yml
    with:
      working_directory: backend
      python_versions: '["3.9", "3.10", "3.11"]'
      requirements_file: requirements.txt
      test_command: pytest
      lint_command: ruff check

  frontend:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: frontend
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
      build_command: build
      test_command: test
      lint_command: lint

  integration:
    needs: [backend, frontend]
    uses: ./.github/workflows/base-ci.yml
    with:
      working_directory: .
      enable_coverage: false
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "go-react" | go-react-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Go + React CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  backend:
    uses: ./.github/workflows/go-workflow.yml
    with:
      working_directory: backend
      go_version: '1.21'
      test_flags: '-v -race -coverprofile=coverage.out'
      lint_command: 'golangci-lint run --timeout=5m'

  frontend:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: frontend
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
      build_command: build
      test_command: test
      lint_command: lint

  integration:
    needs: [backend, frontend]
    uses: ./.github/workflows/base-ci.yml
    with:
      working_directory: .
      enable_coverage: false
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/go-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "rust-react" | rust-react-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Rust + React CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  backend:
    uses: ./.github/workflows/rust-workflow.yml
    with:
      working_directory: backend
      rust_versions: '["stable", "beta"]'
      coverage: true

  frontend:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: frontend
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
      build_command: build
      test_command: test
      lint_command: lint

  integration:
    needs: [backend, frontend]
    uses: ./.github/workflows/base-ci.yml
    with:
      working_directory: .
      enable_coverage: false
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/rust-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "advanced" | advanced-*)
            echo "Setting up advanced CI/CD workflow with all components"
            cp "$WORKFLOW_TEMPLATES_DIR/fullstack-workflow.yml" "$TARGET_WORKFLOWS_DIR/ci-cd.yml"
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/go-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/rust-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            cp "$WORKFLOW_TEMPLATES_DIR/base-ci.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        # Single language project types
        "node" | "nodejs" | node-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Node.js CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  node-ci:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: $working_dir
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "react" | react-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: React CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  node-ci:
    uses: ./.github/workflows/node-workflow.yml
    with:
      working_directory: $working_dir
      package_manager: pnpm
      node_versions: '["18.x", "20.x"]'
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/node-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "python" | python-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Python CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  python-ci:
    uses: ./.github/workflows/python-workflow.yml
    with:
      working_directory: $working_dir
      python_versions: '["3.9", "3.10", "3.11"]'
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "flask" | flask-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Flask CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  python-ci:
    uses: ./.github/workflows/python-workflow.yml
    with:
      working_directory: $working_dir
      python_versions: '["3.9", "3.10", "3.11"]'
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/python-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "go" | go-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Go CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  go-ci:
    uses: ./.github/workflows/go-workflow.yml
    with:
      working_directory: $working_dir
      go_version: '1.21'
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/go-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        "rust" | rust-*)
            cat > "$TARGET_WORKFLOWS_DIR/$workflow_name" << EOL
name: Rust CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  rust-ci:
    uses: ./.github/workflows/rust-workflow.yml
    with:
      working_directory: $working_dir
      rust_versions: '["stable", "beta"]'
      coverage: true
EOL
            cp "$WORKFLOW_TEMPLATES_DIR/rust-workflow.yml" "$TARGET_WORKFLOWS_DIR/"
            ;;
        *)
            echo "Unsupported project type: $project_type"
            echo "Supported project types:"
            echo "  - node, react (Node.js/React projects)"
            echo "  - python, flask (Python/Flask projects)"
            echo "  - go (Go projects)"
            echo "  - rust (Rust projects)"
            echo "  - nextjs-fastapi (Next.js + FastAPI projects)"
            echo "  - flask-react (Flask + React projects)"
            echo "  - go-react (Go + React projects)"
            echo "  - rust-react (Rust + React projects)"
            echo "  - fullstack (Complete full-stack application with CI/CD)"
            echo "  - advanced (Complete CI/CD with all language support)"
            exit 1
            ;;
    esac

    # Set up pre-commit hooks if .pre-commit-config.yaml exists
    if [ -f ".pre-commit-config.yaml" ]; then
        cat > "$TARGET_WORKFLOWS_DIR/pre-commit.yml" << EOL
name: Pre-commit

on:
  pull_request:
    branches: [ main, master, develop ]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - uses: pre-commit/action@v3.0.0
EOL
    fi

    echo "Workflow files have been set up in $TARGET_WORKFLOWS_DIR/"
    echo "The following files were created:"
    ls -l "$TARGET_WORKFLOWS_DIR/"
}

# Main script
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <project-type> [working-directory]"
    echo "Project types: node, react, python, flask, go, rust, nextjs-fastapi, flask-react, go-react, rust-react, fullstack, advanced"
    exit 1
fi

PROJECT_TYPE="$1"
WORKING_DIR="${2:-.}"

setup_workflow "$PROJECT_TYPE" "$WORKING_DIR"

echo "GitHub workflow setup complete for $PROJECT_TYPE project"
echo "To use these workflows, make sure to:"
echo "1. Commit and push the workflow files to your repository"
echo "2. Configure any secrets required by your workflows in GitHub repository settings"
echo "3. Set up the appropriate branch protection rules to require status checks"
