#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_python_project() {
  local project_name="$1"
  
  # Check for required arguments
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
    echo "Usage: setup_python_project <project_name>"
    return 1
  fi

  # Check for dependencies
  if ! check_dependencies "python git"; then
    return 1
  fi
  
  # Detect package manager (prefer uv over pip)
  if command -v uv &> /dev/null; then
    echo "Using uv package manager for faster dependency management"
    PYTHON_PACKAGE_MANAGER="uv"
  else
    echo "Using pip as package manager (consider installing uv for faster dependency management: https://github.com/astral-sh/uv)"
    PYTHON_PACKAGE_MANAGER="pip"
  fi
  
  # Continue with project setup
  # Create project directory and navigate to it
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
  sed -i.bak "1 s|# $project_name|# $project_name\n\n[![$project_name CI](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml)|" README.md
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
requires = ["setuptools>=42", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "A Python project"
authors = [
    {name = "$(git config user.name)", email = "$(git config user.email)"}
]
readme = "README.md"
requires-python = ">=3.9"
dependencies = [
    "pydantic>=2.0.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.1.0",
    "flake8>=6.0.0",
    "black>=23.0.0",
    "isort>=5.12.0",
    "mypy>=1.0.0",
]

[tool.setuptools]
package-dir = {"" = "src"}

[tool.black]
line-length = 88
target-version = ["py39"]

[tool.isort]
profile = "black"
line_length = 88

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
EOF
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Copy GitHub Actions workflow file
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/python-workflow.yml"
  if [ -f "$workflow_template" ]; then
    # Copy and rename the workflow to include the project name
    cp "$workflow_template" ".github/workflows/$project_name-ci.yml"
    # Update the workflow name to include the project name
    sed -i.bak "1s/Python CI/$project_name CI/" ".github/workflows/$project_name-ci.yml"
    rm -f ".github/workflows/$project_name-ci.yml.bak"
  else
    # Create GitHub Actions workflow file if template is not available
    cat > ".github/workflows/$project_name-ci.yml" << EOF
name: $project_name CI

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
    
    - name: Set up uv
      if: \${{ !env.ACT }}  # Skip for local act runs
      run: |
        pip install uv
        
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if command -v uv &> /dev/null; then
          uv pip install -e ".[dev,test]"
        else
          pip install -e ".[dev,test]"  
        fi
        
    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
        
    - name: Run type checking
      run: |
        mypy .
        
    - name: Test with pytest
      run: |
        pytest --cov=./ --cov-report=xml
      env:
        # Environment variables for tests that use configuration
        APP_ENV: test
        DATABASE_URL: \${{ secrets.DATABASE_URL || 'sqlite:///db_test.sqlite3' }}
        API_KEY: \${{ secrets.API_KEY || 'test-api-key' }}
        
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        token: \${{ secrets.CODECOV_TOKEN }}
        file: ./coverage.xml
        flags: unittests
        name: codecov-$project_name
        fail_ci_if_error: false
EOF
  fi
  
  # Create a virtual environment
  echo "Creating Python virtual environment..."
  if [ $has_uv -eq 1 ]; then
    uv venv
  else
    python -m venv venv
  fi

  # Activate virtual environment
  if [ -d "venv/bin" ]; then
    source venv/bin/activate
  elif [ -d "venv/Scripts" ]; then
    source venv/Scripts/activate
  else
    echo "Error: Virtual environment not created properly"
    return 1
  fi
  
  # Create project structure
  mkdir -p src/$project_name
  mkdir -p tests
  
  # Create __init__.py files
  touch src/__init__.py
  touch src/$project_name/__init__.py
  touch tests/__init__.py
  
  # Create main.py
  cat > src/$project_name/main.py << EOF
"""Main module for the $project_name application."""
import os
from pathlib import Path
from typing import Dict, Any

from dotenv import load_dotenv


def load_config() -> Dict[str, Any]:
    """Load configuration from environment variables."""
    # Load .env file if it exists
    env_path = Path(__file__).parent.parent.parent / ".env"
    load_dotenv(env_path)
    
    return {
        "app_name": "$project_name",
        "debug": os.getenv("DEBUG", "False").lower() in ("true", "1", "t"),
        "log_level": os.getenv("LOG_LEVEL", "INFO"),
        "api_key": os.getenv("API_KEY", ""),
    }


def main() -> None:
    """Run the main application."""
    config = load_config()
    print(f"Starting {config['app_name']}")
    print(f"Debug mode: {config['debug']}")
    print(f"Log level: {config['log_level']}")


if __name__ == "__main__":
    main()
EOF

  # Create basic test file
  cat > tests/test_main.py << EOF
"""Tests for the main module."""
import os
from unittest import mock

from ${project_name//-/_}.main import load_config


def test_load_config_default():
    """Test loading default configuration."""
    with mock.patch.dict(os.environ, {}, clear=True):
        config = load_config()
        assert config["app_name"] == "$project_name"
        assert config["debug"] is False
        assert config["log_level"] == "INFO"
        assert config["api_key"] == ""


def test_load_config_custom():
    """Test loading custom configuration from environment."""
    with mock.patch.dict(os.environ, {
        "DEBUG": "true",
        "LOG_LEVEL": "DEBUG",
        "API_KEY": "test-key",
    }, clear=True):
        config = load_config()
        assert config["debug"] is True
        assert config["log_level"] == "DEBUG"
        assert config["api_key"] == "test-key"
EOF

  # Create .env.example file
  cat > .env.example << EOF
# Application Configuration
APP_ENV=development
DEBUG=True
FLASK_APP=$project_name.app
FLASK_ENV=development
SECRET_KEY=replace_this_with_a_secure_secret_key
PORT=5000
HOST=localhost
LOG_LEVEL=DEBUG
TESTING=False

# Database Configuration
DATABASE_URL=sqlite:///db.sqlite3
# Alternative DB URLs:
# DATABASE_URL=postgresql://user:password@localhost:5432/$project_name
# DATABASE_URL=mysql://user:password@localhost:3306/$project_name

# Authentication
JWT_SECRET_KEY=replace_this_with_a_secure_jwt_key
JWT_ACCESS_TOKEN_EXPIRES=3600  # 1 hour in seconds
JWT_REFRESH_TOKEN_EXPIRES=2592000  # 30 days in seconds

# API Credentials
API_KEY=your_api_key_here

# Third-party Services
REDIS_URL=redis://localhost:6379/0
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
AWS_REGION=us-west-2
S3_BUCKET=your-bucket-name

# Email Configuration
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password
MAIL_DEFAULT_SENDER=noreply@example.com

# Social Auth (if applicable)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
EOF

  # Create an actual .env file (excluded from git)
  cp .env.example .env
  
  # Add .env to .gitignore if it's not already there
  grep -q "^.env$" .gitignore || echo ".env" >> .gitignore
  
  # Add environment variables section to README.md
  cat >> README.md << EOF

## Environment Variables

This project uses environment variables for configuration. Copy the example file and modify it with your settings:

\`\`\`bash
cp .env.example .env
\`\`\`

### Important Security Note

The \`.env\` file contains sensitive information and is automatically excluded from version control.
Never commit your actual \`.env\` file to the repository. Use environment variables or secrets management
for production deployments.

EOF

  # Create Makefile
  cat > Makefile << EOF
.PHONY: install dev-install lint test clean build-docs serve-docs help

# Auto-detect package manager (prefer uv, fallback to pip)
PACKAGE_MANAGER := \$(shell command -v uv 2>/dev/null && echo "uv" || echo "pip")

help:
	@echo "Available commands:"
	@echo "  make install      - Install dependencies"
	@echo "  make dev-install  - Install development dependencies"
	@echo "  make lint         - Run linters (flake8, mypy)"
	@echo "  make test         - Run tests with pytest"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make build-docs   - Build documentation"
	@echo "  make serve-docs   - Serve documentation locally"

install:
	\$(PACKAGE_MANAGER) install -e .

dev-install:
	\$(PACKAGE_MANAGER) install -e ".[dev,test]"

lint:
	flake8 .
	mypy .

test:
	pytest --cov=./ --cov-report=term

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf .pytest_cache
	rm -rf .coverage
	rm -rf htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

build-docs:
	cd docs && make html

serve-docs:
	cd docs/_build/html && python -m http.server 8000
EOF

  # Update README with more detailed content
  cat > README.md << EOF
# $project_name

[![$project_name CI](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml)

A Python project with modern tooling.

## Features

- Modern Python project structure with src layout
- Configured for pytest, flake8, black, isort, and mypy
- GitHub Actions for CI/CD
- Comprehensive Makefile for common tasks
- Environment variable management with python-dotenv

## Development Setup

### Prerequisites

- Python 3.9+
- Make (for using the Makefile)

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Set up the development environment
make setup

# Activate the virtual environment
source venv/bin/activate  # On Windows: venv\\Scripts\\activate
\`\`\`

### Environment Variables

Copy the example environment file:

\`\`\`bash
cp .env.example .env
\`\`\`

Then edit .env to add your actual values. Available environment variables:

- \`DEBUG\`: Enable debug mode (true/false)
- \`LOG_LEVEL\`: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- \`API_KEY\`: API key for external services
- \`DB_HOST\`: Database host
- \`DB_PORT\`: Database port
- \`DB_USER\`: Database username
- \`DB_PASSWORD\`: Database password
- \`DB_NAME\`: Database name

## Available Commands

\`\`\`bash
# Run tests
make test

# Run tests with coverage report
make coverage

# Run linters
make lint

# Format code
make format

# Clean build artifacts
make clean

# Run the application
make run
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── .github/          # GitHub Actions workflows
├── src/              # Source code
│   └── $project_name/
│       ├── __init__.py
│       └── main.py   # Main application entry point
├── tests/            # Test files
│   ├── __init__.py
│   └── test_main.py
├── .env.example      # Example environment variables
├── .gitignore        # Files to ignore in Git
├── Makefile          # Commands for development
├── pyproject.toml    # Project metadata and dependencies
└── README.md         # This file
\`\`\`

## License

MIT
EOF

  # Install dependencies
  echo "Installing dependencies..."
  if [ $has_uv -eq 1 ]; then
    uv pip install -e ".[dev]"
  else
    pip install -e ".[dev]"
  fi
  
  # Add all files to git
  git add .
  git commit -m "Setup Python project structure and tooling"
  
  echo "Python project has been set up successfully!"
  echo "To start development:"
  echo "  cd $project_name"
  echo "  source venv/bin/activate  # On Windows: venv\\Scripts\\activate"
  echo "  cp .env.example .env      # Configure your environment variables"
  echo "  make run"
  
  # Push changes if GitHub repo was created
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Pushing changes to GitHub..."
    git push -u origin initial-setup
    echo "Creating pull request for initial setup..."
    gh pr create --title "Initial project setup" --body "Sets up Python project with modern tooling" || true
  fi
} 