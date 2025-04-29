#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_python_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_project <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python"; then
    return 1
  fi
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Check if the repository already exists, and if so, clone it instead
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Cloning existing repository..."
    cd ..
    rm -rf "$project_name"
    git clone "https://github.com/$github_username/$project_name.git"
    cd "$project_name" || return 1
  elif command_exists gh; then
    # Create a new GitHub repository if gh CLI is available
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private
    
    # Add remote
    git remote add origin "https://github.com/$github_username/$project_name.git"
    
    # Create a simple README.md for the initial commit
    echo "# $project_name" > README.md
    
    # Add README.md and make the initial commit
    git add README.md
    git commit -m "Initial commit: Add project README"
    
    # Push the initial commit to the main branch
    git push -u origin main
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "# $project_name" > README.md
    git add README.md
    git commit -m "Initial commit: Add project README"
  fi
  
  # Create and checkout a new branch for the project setup
  if [[ -n $(git branch --list main) ]]; then
    git checkout main
    git pull origin main 2>/dev/null || true
    git checkout -b initial-setup
  elif [[ -n $(git branch --list master) ]]; then
    git checkout master
    git pull origin master 2>/dev/null || true
    git checkout -b initial-setup
  else
    git checkout -b initial-setup
  fi
  
  # Expand README.md with more content
  echo -e "\n## Development\n\n### Setup\n\n\`\`\`bash\n# Install dependencies\nmake install\n\n# Update dependencies\nmake update\n\`\`\`" >> README.md
  
  # Add CI badge to README
  sed -i.bak "1 s|# $project_name|# $project_name\n\n[![Python CI](https://github.com/$github_username/$project_name/actions/workflows/python-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/python-ci.yml)|" README.md
  rm -f README.md.bak
  
  # Create .gitignore for Python
  cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
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
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.pytest_cache/
.coverage
htmlcov/

# IDEs and editors
.idea/
.vscode/
*.swp
*.swo
*~
EOF
  
  # Create pyproject.toml
  cat > pyproject.toml << EOF
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$project_name"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.8"
license = { text = "MIT" }
dependencies = [
]

[project.optional-dependencies]
dev = [
  "pytest>=7.0.0",
  "black>=23.0.0",
  "isort>=5.12.0",
  "flake8>=6.0.0",
]

[tool.black]
line-length = 88

[tool.isort]
profile = "black"
line_length = 88
EOF
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Copy GitHub Actions workflow file
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/python-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/python-ci.yml
  else
    # Create GitHub Actions workflow file if template is not available
    cat > .github/workflows/python-ci.yml << EOF
name: Python CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
        cache: 'pip'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        python -m pip install pytest pytest-cov
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        pip install -e .
    
    - name: Lint with flake8
      run: |
        pip install flake8
        # stop the build if there are Python syntax errors or undefined names
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        # exit-zero treats all errors as warnings
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    
    - name: Test with pytest
      run: |
        pytest --cov=./ --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
        fail_ci_if_error: false
EOF
  fi
  
  # Create main Python module
  mkdir -p "$project_name"
  touch "$project_name/__init__.py"
  
  # Create main.py
  cat > main.py << EOF
#!/usr/bin/env python3

def main():
    print("Hello from $project_name!")

if __name__ == "__main__":
    main()
EOF
  chmod +x main.py
  
  # Create Makefile with dependency commands (adapts to uv or pip)
  cat > Makefile << EOF
.PHONY: install update format lint test clean

# Detect if uv is available, otherwise use pip
PYTHON_PKG_MGR := \$(shell command -v uv 2>/dev/null && echo "uv" || echo "pip")

install:
	@echo "Installing dependencies with \$(PYTHON_PKG_MGR)..."
ifeq (\$(PYTHON_PKG_MGR), uv)
	uv venv
	uv pip install -e ".[dev]"
else
	python -m venv venv
	. venv/bin/activate && pip install -e ".[dev]"
endif

update:
	@echo "Updating dependencies..."
ifeq (\$(PYTHON_PKG_MGR), uv)
	uv pip compile pyproject.toml -o requirements.txt
	uv pip install -r requirements.txt
else
	pip install --upgrade pip-tools
	pip-compile pyproject.toml -o requirements.txt
	pip install -r requirements.txt
endif

format:
	@echo "Formatting code..."
	black .
	isort .

lint:
	@echo "Linting code..."
	flake8 .

test:
	@echo "Running tests..."
	pytest

clean:
	@echo "Cleaning up..."
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/
	find . -type d -name "__pycache__" -exec rm -rf {} +
EOF
  
  # Create a simple test
  mkdir -p "tests"
  cat > tests/test_main.py << EOF
def test_dummy():
    assert True
EOF
  
  # Create Python version file
  echo "3.10" > .python-version
  
  # Add all files and commit to the initial-setup branch
  git add .
  git commit -m "Set up Python project structure and scaffolding"
  
  # If GitHub CLI is available, try to push and create PR
  if command_exists gh && git remote -v | grep -q origin; then
    # Push the initial-setup branch
    git push -u origin initial-setup
    
    # Create pull request using GitHub CLI
    echo "Creating pull request..."
    gh pr create --title "Initial Project Setup" --body "This PR sets up the basic project structure including:

- Python package structure
- Development tools configuration
- Testing framework
- Makefile with common commands
- Basic documentation

Ready for review." --base main || echo "Failed to create PR. You may need to create it manually."
    
    echo "✓ Python project '$project_name' is ready!"
    echo "GitHub: https://github.com/$github_username/$project_name"
  else
    echo "✓ Python project '$project_name' is ready locally!"
  fi
  
  echo ""
  echo "Next steps:"
  if command_exists gh && git remote -v | grep -q origin; then
    echo "1. Review and merge the PR"
  fi
  echo "2. Run 'make install' to set up your environment"
  echo "3. Run 'make update' to generate requirements.txt"
} 