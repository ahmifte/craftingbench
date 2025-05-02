#!/usr/bin/env bash
# Common utility functions extracted from templates

# Source other helper files
source "$(dirname "${BASH_SOURCE[0]}")/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

# ==============================
# Repository Setup Functions
# ==============================

# Setup git repository and optionally GitHub remote
setup_git_repository() {
  local project_dir="$1"
  local project_name="$2"
  local github_username="$3"
  local create_github_repo="${4:-false}"

  # Validate required parameters
  if [ -z "$project_dir" ] || [ -z "$project_name" ]; then
    echo "Error: Project directory and name are required for repository setup"
    return 1
  fi

  # Initialize git repository if not already initialized
  if [ ! -d "$project_dir/.git" ]; then
    (cd "$project_dir" && git init)
  fi

  # Create README if it doesn't exist
  if [ ! -f "$project_dir/README.md" ]; then
    echo "# $project_name" > "$project_dir/README.md"
    (cd "$project_dir" && git add README.md)
  fi

  # Handle GitHub repository creation if requested
  if [ "$create_github_repo" = true ]; then
    if command_exists gh; then
      # Check if repo already exists
      if gh repo view "$github_username/$project_name" &>/dev/null; then
        echo "Repository already exists at github.com/$github_username/$project_name"
      else
        echo "Creating new GitHub repository '$project_name'..."
        (cd "$project_dir" && gh repo create "$project_name" --private)
        (cd "$project_dir" && git remote add origin "https://github.com/$github_username/$project_name.git")
      fi
    else
      echo "GitHub CLI (gh) not found. Repository will be set up locally only."
      echo "To create a GitHub repository, install the GitHub CLI: https://cli.github.com/"
    fi
  fi

  # Make initial commit if needed
  if ! (cd "$project_dir" && git log -1 &>/dev/null); then
    (cd "$project_dir" && git add . && git commit -m "Initial commit")
  fi

  # Setup feature branch for project setup
  (cd "$project_dir" && git checkout -b initial-setup 2>/dev/null || git checkout initial-setup)

  return 0
}

# ==============================
# GitHub Workflow Functions
# ==============================

# Copy a GitHub workflow file to the project
setup_github_workflow() {
  local project_dir="$1"
  local workflow_type="$2"
  local project_name="$3"
  local github_username="${4:-}"

  # Validate required parameters
  if [ -z "$project_dir" ] || [ -z "$workflow_type" ]; then
    echo "Error: Project directory and workflow type are required"
    return 1
  fi

  # Create workflows directory
  mkdir -p "$project_dir/.github/workflows"

  # Determine template path
  local template_path="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/${workflow_type}-workflow.yml"
  if [ ! -f "$template_path" ]; then
    echo "Workflow template not found: $template_path"
    return 1
  fi

  # Copy and customize the workflow file
  local workflow_file="$project_dir/.github/workflows/${project_name}-ci.yml"
  cp "$template_path" "$workflow_file"

  # Update the workflow name if project_name is provided
  if [ -n "$project_name" ]; then
    sed -i.bak "s/name: .*/name: $project_name CI/" "$workflow_file"
    rm -f "${workflow_file}.bak"
  fi

  # Add CI badge to README if GitHub username is provided
  if [ -n "$github_username" ] && [ -f "$project_dir/README.md" ]; then
    # Only add badge if it doesn't already exist
    if ! grep -q "badge.svg" "$project_dir/README.md"; then
      local badge_line="[![CI Status](https://github.com/$github_username/$project_name/actions/workflows/${project_name}-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/${project_name}-ci.yml)"
      sed -i.bak "1s|# $project_name|# $project_name\n\n$badge_line|" "$project_dir/README.md"
      rm -f "${project_dir}/README.md.bak"
    fi
  fi

  echo "GitHub workflow setup complete: .github/workflows/${project_name}-ci.yml"
  return 0
}

# ==============================
# Pre-commit Setup Functions
# ==============================

# Setup pre-commit configuration for different language types
setup_pre_commit() {
  local project_dir="$1"
  local lang_types="$2" # comma-separated list: python,js,go

  echo "Setting up pre-commit configuration..."

  # Create the pre-commit config file
  cat > "$project_dir/.pre-commit-config.yaml" << EOF
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: check-yaml
    -   id: check-json
    -   id: check-case-conflict
    -   id: check-added-large-files
    -   id: mixed-line-ending
        args: ['--fix=lf']
    -   id: detect-private-key

-   repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
    -   id: shellcheck
EOF

  # Add Python-specific hooks if needed
  if [[ "$lang_types" == *"python"* ]]; then
    cat >> "$project_dir/.pre-commit-config.yaml" << EOF

-   repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
    -   id: isort
        files: "\\.(py)$"

-   repo: https://github.com/psf/black
    rev: 24.1.1
    hooks:
    -   id: black
        files: "\\.(py)$"

-   repo: https://github.com/charliermarsh/ruff-pre-commit
    rev: v0.1.8
    hooks:
    -   id: ruff
        args: [--fix]
EOF
  fi

  # Add JavaScript/TypeScript hooks if needed
  if [[ "$lang_types" == *"js"* ]]; then
    cat >> "$project_dir/.pre-commit-config.yaml" << EOF

-   repo: https://github.com/pre-commit/mirrors-eslint
    rev: v8.54.0
    hooks:
    -   id: eslint
        files: "\\.(js|ts|tsx)$"
        additional_dependencies:
        -   eslint@8.54.0
        -   typescript@5.3.2
        -   '@typescript-eslint/eslint-plugin@6.12.0'
        -   '@typescript-eslint/parser@6.12.0'

-   repo: https://github.com/pre-commit/mirrors-prettier
    rev: v3.1.0
    hooks:
    -   id: prettier
        files: "\\.(js|ts|tsx|css|less|json|markdown|md|yaml|yml)$"
EOF
  fi

  # Add Go-specific hooks if needed
  if [[ "$lang_types" == *"go"* ]]; then
    cat >> "$project_dir/.pre-commit-config.yaml" << EOF

-   repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
    -   id: go-fmt
    -   id: go-vet
    -   id: go-imports
    -   id: go-critic
    -   id: validate-toml
EOF
  fi

  echo "Created pre-commit configuration in $project_dir"

  # Add pre-commit setup instructions to the README
  if [ -f "$project_dir/README.md" ]; then
    if ! grep -q "pre-commit" "$project_dir/README.md"; then
      cat >> "$project_dir/README.md" << EOF

## Code Quality with Pre-commit Hooks

This project uses pre-commit hooks to maintain code quality. To set up:

1. Install pre-commit:
   \`\`\`
   pip install pre-commit
   \`\`\`

2. Install the git hooks:
   \`\`\`
   pre-commit install
   \`\`\`

3. Now checks will run automatically on every commit.

You can manually run all hooks with:
\`\`\`
pre-commit run --all-files
\`\`\`
EOF
    fi
  fi

  return 0
}

# ==============================
# Common .gitignore setup
# ==============================

# Create a .gitignore file with appropriate entries for the project type
create_gitignore() {
  local project_dir="$1"
  local project_type="$2" # python, node, go, etc.

  echo "Creating .gitignore file for $project_type project..."

  # Common entries for all projects
  cat > "$project_dir/.gitignore" << EOF
# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
.DS_Store

# Environment files
.env
.env.local
.env.*.local

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
EOF

  # Python-specific entries
  if [[ "$project_type" == "python" ]]; then
    cat >> "$project_dir/.gitignore" << EOF

# Python
__pycache__/
*.py[cod]
*.\$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/

# Virtual environments
venv/
env/
ENV/
.env/
.venv/
EOF
  fi

  # Node.js/JavaScript/TypeScript entries
  if [[ "$project_type" == "node" ]]; then
    cat >> "$project_dir/.gitignore" << EOF

# Node.js
node_modules/
dist/
dist-ssr/
coverage/
*.local

# TypeScript
*.tsbuildinfo
next-env.d.ts
EOF
  fi

  # Go-specific entries
  if [[ "$project_type" == "go" ]]; then
    cat >> "$project_dir/.gitignore" << EOF

# Go
/vendor/
/Godeps/
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out
*.o
*.a
go.work

# Output of the go coverage tool
*.out
EOF
  fi

  echo "Created .gitignore file in $project_dir"
  return 0
}

# ==============================
# Package Manager Detection
# ==============================

# Detect package manager for node projects
detect_node_package_manager() {
  if command -v pnpm &> /dev/null; then
    echo "pnpm"
  elif command -v yarn &> /dev/null; then
    echo "yarn"
  else
    echo "npm"
  fi
}

# Detect python package manager
detect_python_package_manager() {
  if command -v uv &> /dev/null; then
    echo "uv"
  else
    echo "pip"
  fi
}

# Execute package manager command with appropriate syntax
run_package_manager_command() {
  local package_manager="$1"
  local command="$2"
  local args="${3:-}"

  case "$package_manager" in
    npm)
      npm "$command" $args
      ;;
    yarn)
      yarn "$command" $args
      ;;
    pnpm)
      pnpm "$command" $args
      ;;
    pip)
      pip "$command" $args
      ;;
    uv)
      uv pip "$command" $args
      ;;
    *)
      echo "Unsupported package manager: $package_manager"
      return 1
      ;;
  esac

  return $?
}
