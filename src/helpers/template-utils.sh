#!/bin/bash
# Common utility functions for project templates

# IMPORTANT: This file is maintained for backward compatibility.
# For new projects, please use the functions in utils.sh instead.

# Source the new utilities file to ensure all functions are available
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/utils.sh"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log messages with different levels
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
  exit 1
}

# DEPRECATED FUNCTIONS - Proxies to utils.sh
# The following functions are now maintained in utils.sh.
# These proxies ensure backward compatibility with existing scripts.

# Function to check dependencies using the new implementation
check_dependencies() {
  if command -v utils_check_dependencies &> /dev/null; then
    log_warning "check_dependencies in template-utils.sh is deprecated. Use the function from utils.sh instead."
    utils_check_dependencies "$@"
  else
    local missing_deps=()

    for dep in "$@"; do
      if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
      fi
    done

    if [ ${#missing_deps[@]} -ne 0 ]; then
      log_error "Missing required dependencies: ${missing_deps[*]}"
      log_info "Please install them and try again."
      return 1
    fi

    return 0
  fi
}

# Detect package manager for node projects - proxy to the new function
detect_node_package_manager() {
  log_warning "detect_node_package_manager in template-utils.sh is deprecated. Use the function from utils.sh instead."
  # Just use the function from utils.sh
  "$(dirname "${BASH_SOURCE[0]}")/utils.sh" &> /dev/null && detect_node_package_manager || {
    if command -v pnpm &> /dev/null; then
      echo "pnpm"
    elif command -v yarn &> /dev/null; then
      echo "yarn"
    else
      echo "npm"
    fi
  }
}

# Detect python package manager - proxy to the new function
detect_python_package_manager() {
  log_warning "detect_python_package_manager in template-utils.sh is deprecated. Use the function from utils.sh instead."
  # Just use the function from utils.sh
  "$(dirname "${BASH_SOURCE[0]}")/utils.sh" &> /dev/null && detect_python_package_manager || {
    if command -v uv &> /dev/null; then
      echo "uv"
    else
      echo "pip"
    fi
  }
}

# Setup github workflow dir - proxy to the new function
setup_github_workflow_dir() {
  log_warning "setup_github_workflow_dir in template-utils.sh is deprecated. Use setup_github_workflow from utils.sh instead."
  setup_github_workflow "$@"
}

# Setup pre-commit - proxy to the new function
setup_pre_commit() {
  log_warning "setup_pre_commit in template-utils.sh is deprecated. Use the function from utils.sh instead."
  # Call the implementation from utils.sh
  "$(dirname "${BASH_SOURCE[0]}")/utils.sh" &> /dev/null && setup_pre_commit "$@" || true
}

# Function to create standardized .gitignore files
create_gitignore() {
  local project_dir="$1"
  local project_type="$2" # python, node, react, go, fullstack

  log_info "Creating .gitignore for $project_type project"

  # Base common patterns for all projects
  local common_patterns="# OS specific
.DS_Store
*.swp
*.swo
*~
Thumbs.db

# Editor directories and files
.idea/
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json

# Environment variables
.env
.env.local
.env.*.local

# Logs
logs/
*.log
"

  # Create or overwrite .gitignore file with common patterns
  echo "$common_patterns" > "$project_dir/.gitignore"

  # Add language-specific patterns
  case "$project_type" in
    python)
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
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Environments
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Tests
.pytest_cache/
.coverage
htmlcov/
coverage.xml

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Jupyter Notebooks
.ipynb_checkpoints
EOF
      ;;
    node)
      cat >> "$project_dir/.gitignore" << EOF
# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# Build outputs
dist/
build/
*.local

# Testing
coverage/
.nyc_output/

# Cache
.eslintcache
.stylelintcache
EOF
      ;;
    react)
      cat >> "$project_dir/.gitignore" << EOF
# React/Frontend
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# Build outputs
dist/
build/
*.local

# Testing
coverage/
.nyc_output/

# Cache
.eslintcache
.stylelintcache
.cache/
public/
EOF
      ;;
    go)
      cat >> "$project_dir/.gitignore" << EOF
# Go
/bin/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out
coverage.txt

# Dependency directories
vendor/

# Go workspace file
go.work
EOF
      ;;
    fullstack)
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
.venv/
venv/
ENV/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# Build outputs
dist/
build/
*.local

# Testing
coverage/
.nyc_output/
.pytest_cache/
.coverage
htmlcov/

# Database
*.sqlite3
*.db

# mypy
.mypy_cache/
.dmypy.json
dmypy.json
EOF
      ;;
    *)
      log_warning "Unknown project type: $project_type. Creating a basic .gitignore."
      ;;
  esac

  log_success "Created .gitignore file for $project_type project"
}

# Function to create .env.example file
create_env_example() {
  local project_dir="$1"
  local env_content="$2"

  echo "$env_content" > "$project_dir/.env.example"
  log_info "Created .env.example file"

  echo "# Local environment variables - DO NOT COMMIT THIS FILE" > "$project_dir/.env"
  log_info "Created empty .env file"

  if [ -f "$project_dir/.gitignore" ]; then
    if ! grep -q "^\.env$" "$project_dir/.gitignore"; then
      echo ".env" >> "$project_dir/.gitignore"
      log_info "Added .env to .gitignore"
    fi
  fi
}

# Add CI badge to README
add_ci_badge() {
  local readme_file="$1"
  local repo_name="$2"
  local workflow_name="$3"

  # Extract the first line which is the title
  local first_line
  first_line=$(head -n 1 "$readme_file")

  # Create a badge line
  local badge_line="[![CI Status](https://github.com/$repo_name/actions/workflows/$workflow_name/badge.svg)](https://github.com/$repo_name/actions)"

  # Create a temporary file with the badge under the title
  {
    echo "$first_line"
    echo ""
    echo "$badge_line"
    tail -n +2 "$readme_file"
  } > "${readme_file}.tmp"

  # Replace the original file
  mv "${readme_file}.tmp" "$readme_file"
  log_info "Added CI badge to README.md"
}

# Initialize git repository
init_git_repo() {
  local project_dir="$1"
  local initial_commit_msg="${2:-Initial commit}"

  git init "$project_dir" > /dev/null 2>&1
  log_info "Initialized git repository"

  (
    cd "$project_dir" || exit
    git add . > /dev/null 2>&1
    git commit -m "$initial_commit_msg" > /dev/null 2>&1
  )
  log_success "Created initial commit"
}

# Setup GitHub repository
setup_github_repo() {
  local project_dir="$1"
  local project_name="$2"
  local repo_description="${3:-A project created with CraftingBench}"

  if ! command -v gh &> /dev/null; then
    log_warning "GitHub CLI not installed. Skipping GitHub repository setup."
    return 1
  fi

  # Check if the repository already exists
  if gh repo view "$project_name" &> /dev/null; then
    log_info "GitHub repository '$project_name' already exists."

    # Clone existing repository
    rm -rf "$project_dir"
    gh repo clone "$project_name" "$project_dir"
    return 0
  else
    # Create a new repository
    (
      cd "$project_dir" || exit
      gh repo create "$project_name" --public --description "$repo_description" --source=. --push
    )
    log_success "Created and pushed to GitHub repository: $project_name"
    return 0
  fi
}

# Create editor configuration
setup_editor_config() {
  local project_dir="$1"

  # Create .editorconfig
  cat > "$project_dir/.editorconfig" << EOF
root = true

[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
trim_trailing_whitespace = true
indent_style = space
indent_size = 2

[*.{py,pyi}]
indent_size = 4

[*.md]
trim_trailing_whitespace = false

[Makefile]
indent_style = tab
EOF
  log_info "Created .editorconfig file"

  # Create VS Code settings
  mkdir -p "$project_dir/.vscode"

  cat > "$project_dir/.vscode/settings.json" << EOF
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true
}
EOF
  log_info "Created VS Code settings"
}

# Clean up temporary files from project setup
cleanup_temp_files() {
  local project_dir="$1"

  find "$project_dir" -name "*.tmp" -delete
  find "$project_dir" -name ".DS_Store" -delete

  log_info "Cleaned up temporary files"
}

# Print setup completion message
print_completion_message() {
  local project_name="$1"
  local project_type="$2"
  local next_steps="$3"

  echo ""
  log_success "Project '$project_name' ($project_type) has been successfully set up!"
  echo ""
  echo "Next steps:"
  echo "$next_steps"
  echo ""
  echo "Additional features:"
  echo "- Pre-commit hooks for code quality (run 'pip install pre-commit && pre-commit install')"
  echo "- Standardized .gitignore files for different project types"
  echo "- GitHub Actions workflow for CI/CD"
  echo ""
}
