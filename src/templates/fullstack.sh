#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_fullstack_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_fullstack_project <project_name> [--backend=nextjs|flask|golang]"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  local backend="nextjs" # Default backend
  
  # Parse options
  shift 1
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --backend=*) backend="${1#*=}" ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
    shift
  done
  
  case $backend in
    nextjs)
      setup_nextjs_fullstack "$project_name"
      ;;
    flask)
      setup_flask_fullstack "$project_name"
      ;;
    golang)
      setup_golang_fullstack "$project_name"
      ;;
    *)
      echo "Unsupported backend: $backend"
      echo "Supported backends: nextjs, flask, golang"
      return 1
      ;;
  esac
}

setup_nextjs_fullstack() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "nextjs"; then
    return 1
  fi
  
  echo "🚀 Setting up Next.js fullstack project: $project_name"
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1

  # Initialize git
  git init

  # Create GitHub repository if gh CLI is available
  if command_exists gh; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm || true
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Setup Next.js workflow
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/nextjs-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/nextjs-ci.yml
  else
    cat > .github/workflows/nextjs-ci.yml << EOF
name: Next.js CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    
    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type check
      run: pnpm typecheck
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
      
    - name: Cache Next.js build
      uses: actions/cache@v3
      with:
        path: |
          \${{ github.workspace }}/.next/cache
        key: \${{ runner.os }}-nextjs-\${{ hashFiles('**/pnpm-lock.yaml') }}-\${{ hashFiles('**.[jt]s', '**.[jt]sx') }}
        restore-keys: |
          \${{ runner.os }}-nextjs-\${{ hashFiles('**/pnpm-lock.yaml') }}-
EOF
  fi
}

setup_flask_fullstack() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "flask"; then
    return 1
  fi
  
  echo "🚀 Setting up Flask + React fullstack project: $project_name"
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1

  # Initialize git
  git init

  # Create GitHub repository if gh CLI is available
  if command_exists gh; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm || true
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Setup Flask+React workflow
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/flask-react-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/fullstack-ci.yml
  else
    cat > .github/workflows/fullstack-ci.yml << EOF
name: Flask + React CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']
    
    defaults:
      run:
        working-directory: backend
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
        cache: 'pip'
        cache-dependency-path: 'backend/requirements.txt'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        python -m pip install pytest pytest-cov flake8
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    
    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    
    - name: Test with pytest
      run: |
        pytest --cov=./ --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: backend/coverage.xml
        flags: backend
        fail_ci_if_error: false

  frontend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
        
    defaults:
      run:
        working-directory: frontend
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
        cache-dependency-path: 'frontend/pnpm-lock.yaml'
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type check
      run: pnpm typecheck
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
      
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: frontend-build
        path: frontend/dist/
        if-no-files-found: error
EOF
  fi
}

setup_golang_fullstack() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "golang"; then
    return 1
  fi
  
  echo "🚀 Setting up Go + React fullstack project: $project_name"
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1

  # Initialize git
  git init

  # Create GitHub repository if gh CLI is available
  if command_exists gh; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm || true
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Setup Go+React workflow
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/go-react-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/fullstack-ci.yml
  else
    cat > .github/workflows/fullstack-ci.yml << EOF
name: Go + React CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: ['1.19', '1.20', '1.21']
        
    defaults:
      run:
        working-directory: backend
    
    steps:
    - uses: actions/checkout@v3

    - name: Set up Go \${{ matrix.go-version }}
      uses: actions/setup-go@v4
      with:
        go-version: \${{ matrix.go-version }}
        cache: true
        cache-dependency-path: backend/go.sum

    - name: Install dependencies
      run: go mod download

    - name: Lint
      uses: golangci/golangci-lint-action@v3
      with:
        version: latest
        args: --timeout=5m
        working-directory: backend

    - name: Build
      run: go build -v ./...

    - name: Test
      run: go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: backend/coverage.txt
        flags: backend
        fail_ci_if_error: false

  frontend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
        
    defaults:
      run:
        working-directory: frontend
        
    steps:
    - uses: actions/checkout@v3
    
    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
        cache-dependency-path: 'frontend/pnpm-lock.yaml'
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type check
      run: pnpm typecheck
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
      
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: frontend-build
        path: frontend/dist/
        if-no-files-found: error
EOF
  fi
}
