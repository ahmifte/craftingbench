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
  local backend_type="nextjs"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')

  # Parse arguments
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --backend=*)
        backend_type="${1#*=}"
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: setup_fullstack_project <project_name> [--backend=nextjs|flask|golang]"
        return 1
        ;;
    esac
  done

  # Verify that backend type is valid
  case "$backend_type" in
    nextjs|flask|golang)
      ;;
    *)
      echo "Error: Invalid backend type: $backend_type"
      echo "Valid options are: nextjs, flask, golang"
      return 1
      ;;
  esac

  # Use pnpm if available, otherwise npm
  local npm_cmd="npm"
  if command_exists pnpm; then
    npm_cmd="pnpm"
  fi

  # Create project directory
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

  # Setup appropriate workflow file based on backend type
  case "$backend_type" in
    nextjs)
      # Copy or create Next.js workflow
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
      ;;
      
    flask)
      # Copy or create Flask+React workflow
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
      ;;
      
    golang)
      # Copy or create Go+React workflow
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
      ;;
  esac

  # Create README with CI badge
  local badge_path=""
  case "$backend_type" in
    nextjs)
      badge_path="nextjs-ci.yml"
      badge_name="Next.js CI"
      ;;
    *)
      badge_path="fullstack-ci.yml"
      badge_name="Fullstack CI"
      ;;
  esac

  cat > README.md << EOF
# $project_name

[![$badge_name](https://github.com/$github_username/$project_name/actions/workflows/$badge_path/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/$badge_path)

A fullstack application with ${backend_type} backend and TypeScript React frontend.

## Tech Stack

- **Frontend**: React, TypeScript, Material UI
- **Backend**: ${backend_type^}
- **Package Manager**: ${npm_cmd}
- **CI/CD**: GitHub Actions

## Project Structure
EOF

  # Set up the project based on backend type
  case "$backend_type" in
    nextjs)
      # Set up Next.js project (unified frontend and backend)
      echo "Setting up Next.js fullstack project..."
      
      # Create Next.js app with pnpm or npm
      if [ "$npm_cmd" = "pnpm" ]; then
        pnpm create next-app . --typescript --eslint --no-src-dir --app --import-alias="@/*"
        
        # Configure pnpm
        cat > .npmrc << EOF
engine-strict=true
resolution-mode=highest
save-exact=true
auto-install-peers=true
EOF
      else
        npx create-next-app . --typescript --eslint --no-src-dir --app --import-alias="@/*"
      fi
      
      # Install Material UI
      $npm_cmd add @mui/material @mui/icons-material @emotion/react @emotion/styled
      
      # Add testing dependencies
      $npm_cmd add -D jest @testing-library/react @testing-library/jest-dom jest-environment-jsdom
      
      # Create jest.config.js
      cat > jest.config.js << EOF
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
  },
};

module.exports = createJestConfig(customJestConfig);
EOF

      # Create jest.setup.js
      cat > jest.setup.js << EOF
import '@testing-library/jest-dom';
EOF

      # Update package.json to include test scripts
      # Use temporary file to avoid issues with sed on different platforms
      cat > package.json.new << EOF
$(cat package.json | sed 's/"scripts": {/"scripts": {\n    "test": "jest",\n    "test:watch": "jest --watch",\n    "test:coverage": "jest --coverage",\n    "typecheck": "tsc --noEmit",/')
EOF
      mv package.json.new package.json
      
      # Update README
      cat >> README.md << EOF

\`\`\`
$project_name/
├── app/                # Next.js app router
├── components/         # React components
├── public/             # Static assets
├── styles/             # CSS styles
├── lib/                # Shared utilities
└── api/                # API routes
\`\`\`

## Getting Started

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies
$npm_cmd install
\`\`\`

### Development

\`\`\`bash
# Start development server
$npm_cmd dev

# Run tests
$npm_cmd test

# Type check
$npm_cmd typecheck

# Build for production
$npm_cmd build

# Start production server
$npm_cmd start
\`\`\`
EOF
      ;;
      
    flask)
      # Set up Flask backend and React frontend
      echo "Setting up Flask backend and React frontend..."
      
      # Create frontend and backend directories
      mkdir -p frontend backend
      
      # Setup React frontend with Material UI
      cd frontend || return 1
      
      if [ "$npm_cmd" = "pnpm" ]; then
        pnpm create vite@latest . --template react-ts
        
        # Configure pnpm
        cat > .npmrc << EOF
engine-strict=true
resolution-mode=highest
save-exact=true
auto-install-peers=true
EOF
      else
        npm create vite@latest . -- --template react-ts
      fi
      
      # Install Material UI
      $npm_cmd add @mui/material @mui/icons-material @emotion/react @emotion/styled
      
      # Add testing dependencies
      $npm_cmd add -D vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
      
      # Create vite.config.ts with vitest configuration
      cat > vite.config.ts << EOF
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/setupTests.ts',
  },
});
EOF

      # Create test setup file
      cat > src/setupTests.ts << EOF
import '@testing-library/jest-dom';
EOF

      # Update package.json to include test scripts
      # Use temporary file to avoid issues with sed on different platforms
      cat > package.json.new << EOF
$(cat package.json | sed 's/"scripts": {/"scripts": {\n    "test": "vitest run",\n    "test:watch": "vitest",\n    "test:coverage": "vitest run --coverage",\n    "typecheck": "tsc --noEmit",\n    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",/')
EOF
      mv package.json.new package.json
      
      # Go back to project root
      cd ..
      
      # Set up Flask backend
      cd backend || return 1
      
      # Create virtual environment
      python -m venv venv
      
      # Create requirements.txt
      cat > requirements.txt << EOF
flask==2.3.3
flask-cors==4.0.0
python-dotenv==1.0.0
pytest==7.4.0
pytest-cov==4.1.0
gunicorn==21.2.0
EOF

      # Create app.py
      cat > app.py << EOF
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/api/hello')
def hello():
    return jsonify(message="Hello from Flask!")

@app.route('/api/health')
def health():
    return jsonify(status="UP")

if __name__ == '__main__':
    app.run(debug=True)
EOF

      # Create .env file
      cat > .env.example << EOF
FLASK_APP=app
FLASK_ENV=development
FLASK_DEBUG=1
EOF

      # Create a simple test
      mkdir -p tests
      
      cat > tests/test_app.py << EOF
import json
import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_hello_endpoint(client):
    response = client.get('/api/hello')
    assert response.status_code == 200
    assert json.loads(response.data)['message'] == 'Hello from Flask!'

def test_health_endpoint(client):
    response = client.get('/api/health')
    assert response.status_code == 200
    assert json.loads(response.data)['status'] == 'UP'
EOF

      # Create python package configuration
      cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "${project_name}-backend"
version = "0.1.0"
authors = [
  { name = "Your Name", email = "your.email@example.com" },
]
description = "Flask backend for ${project_name}"
readme = "README.md"
requires-python = ">=3.9"
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
]

[project.urls]
"Homepage" = "https://github.com/${github_username}/${project_name}"
"Bug Tracker" = "https://github.com/${github_username}/${project_name}/issues"
EOF

      # Go back to project root
      cd ..
      
      # Create Docker Compose file for local development
      cat > docker-compose.yml << EOF
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    volumes:
      - ./backend:/app
    environment:
      - FLASK_APP=app
      - FLASK_ENV=development
      - FLASK_DEBUG=1

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend
EOF

      # Create Docker files
      cat > backend/Dockerfile << EOF
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
EOF

      cat > frontend/Dockerfile << EOF
FROM node:20-alpine

WORKDIR /app

COPY package.json .
COPY pnpm-lock.yaml .
RUN npm install -g pnpm && pnpm install

COPY . .

EXPOSE 3000

CMD ["pnpm", "dev", "--host"]
EOF

      # Update README
      cat >> README.md << EOF

\`\`\`
$project_name/
├── frontend/              # React frontend
│   ├── src/               # Frontend source code
│   └── ...                # Other frontend files
├── backend/               # Flask backend
│   ├── app.py             # Main Flask application
│   ├── requirements.txt   # Python dependencies
│   └── tests/             # Backend tests
└── docker-compose.yml     # Docker Compose configuration
\`\`\`

## Getting Started

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Set up frontend
cd frontend
$npm_cmd install

# Set up backend
cd ../backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate
pip install -r requirements.txt
cp .env.example .env
\`\`\`

### Development

\`\`\`bash
# Start frontend (from frontend directory)
$npm_cmd dev

# Start backend (from backend directory)
flask run

# Alternatively, use Docker Compose (from root directory)
docker-compose up
\`\`\`

### Testing

\`\`\`bash
# Frontend tests
cd frontend
$npm_cmd test

# Backend tests
cd backend
pytest
\`\`\`
EOF
      ;;
      
    golang)
      # Set up Go backend and React frontend
      echo "Setting up Go backend and React frontend..."
      
      # Create frontend and backend directories
      mkdir -p frontend backend
      
      # Setup React frontend with Material UI
      cd frontend || return 1
      
      if [ "$npm_cmd" = "pnpm" ]; then
        pnpm create vite@latest . --template react-ts
        
        # Configure pnpm
        cat > .npmrc << EOF
engine-strict=true
resolution-mode=highest
save-exact=true
auto-install-peers=true
EOF
      else
        npm create vite@latest . -- --template react-ts
      fi
      
      # Install Material UI
      $npm_cmd add @mui/material @mui/icons-material @emotion/react @emotion/styled
      $npm_cmd add axios  # For API calls
      
      # Add testing dependencies
      $npm_cmd add -D vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
      
      # Create vite.config.ts with vitest configuration
      cat > vite.config.ts << EOF
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/setupTests.ts',
  },
});
EOF

      # Create test setup file
      cat > src/setupTests.ts << EOF
import '@testing-library/jest-dom';
EOF

      # Update package.json to include test scripts
      # Use temporary file to avoid issues with sed on different platforms
      cat > package.json.new << EOF
$(cat package.json | sed 's/"scripts": {/"scripts": {\n    "test": "vitest run",\n    "test:watch": "vitest",\n    "test:coverage": "vitest run --coverage",\n    "typecheck": "tsc --noEmit",\n    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",/')
EOF
      mv package.json.new package.json
      
      # Go back to project root
      cd ..
      
      # Set up Go backend
      cd backend || return 1
      
      # Initialize go module
      go mod init "$project_name/backend"
      
      # Create main.go
      cat > main.go << EOF
package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	// Create a new ServeMux
	mux := http.NewServeMux()

	// Register API routes
	mux.HandleFunc("/api/hello", helloHandler)
	mux.HandleFunc("/api/health", healthHandler)

	// Configure the HTTP server
	server := &http.Server{
		Addr:    ":8080",
		Handler: corsMiddleware(mux),
	}

	// Start server in a goroutine
	go func() {
		log.Println("Starting server on :8080")
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Create shutdown context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown server
	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited properly")
}

// helloHandler returns a JSON greeting
func helloHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"message": "Hello from Go API!",
	}
	sendJSON(w, response)
}

// healthHandler returns API health status
func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"status": "UP",
	}
	sendJSON(w, response)
}

// corsMiddleware adds CORS headers to responses
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// sendJSON sends a JSON response
func sendJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error encoding JSON: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}
EOF

      # Create a simple test
      mkdir -p handlers
      
      cat > handlers/handlers_test.go << EOF
package handlers_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHelloHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/api/hello", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"message": "Hello from Go API!",
		})
	})

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	expected := map[string]string{"message": "Hello from Go API!"}
	var got map[string]string
	err = json.Unmarshal(rr.Body.Bytes(), &got)
	if err != nil {
		t.Fatal(err)
	}

	if got["message"] != expected["message"] {
		t.Errorf("handler returned unexpected body: got %v want %v", got, expected)
	}
}
EOF

      # Create a Makefile
      cat > Makefile << EOF
.PHONY: build run test clean

build:
	go build -o server

run:
	go run main.go

test:
	go test -v ./...

clean:
	rm -f server
EOF

      # Go back to project root
      cd ..
      
      # Create Docker Compose file for local development
      cat > docker-compose.yml << EOF
version: '3.8'

services:
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    volumes:
      - ./backend:/app
    working_dir: /app

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    depends_on:
      - backend
EOF

      # Create Docker files
      cat > backend/Dockerfile << EOF
FROM golang:1.21-alpine

WORKDIR /app

COPY go.mod .
COPY go.sum* .
RUN go mod download

COPY . .

EXPOSE 8080

CMD ["go", "run", "main.go"]
EOF

      cat > frontend/Dockerfile << EOF
FROM node:20-alpine

WORKDIR /app

COPY package.json .
COPY pnpm-lock.yaml* .
RUN npm install -g pnpm && pnpm install

COPY . .

EXPOSE 3000

CMD ["pnpm", "dev", "--host"]
EOF

      # Update README
      cat >> README.md << EOF

\`\`\`
$project_name/
├── frontend/             # React frontend
│   ├── src/              # Frontend source code
│   └── ...               # Other frontend files
├── backend/              # Go backend
│   ├── main.go           # Main Go application
│   ├── handlers/         # API handlers
│   └── Makefile          # Build commands
└── docker-compose.yml    # Docker Compose configuration
\`\`\`

## Getting Started

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Set up frontend
cd frontend
$npm_cmd install

# Set up backend
cd ../backend
go mod download
\`\`\`

### Development

\`\`\`bash
# Start frontend (from frontend directory)
$npm_cmd dev

# Start backend (from backend directory)
go run main.go

# Alternatively, use Docker Compose (from root directory)
docker-compose up
\`\`\`

### Testing

\`\`\`bash
# Frontend tests
cd frontend
$npm_cmd test

# Backend tests
cd backend
go test ./...
\`\`\`
EOF
      ;;
  esac

  # Add license
  cat > LICENSE << EOF
MIT License

Copyright (c) $(date +%Y) ${github_username}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

  # Add all files to git and commit
  git add .
  git commit -m "Initial fullstack project setup with $backend_type backend"
  
  # Push to GitHub if repo was created
  if command_exists gh && gh repo list | grep -q "$project_name"; then
    git push -u origin main
  fi
  
  echo "Fullstack project with $backend_type backend has been set up successfully!"
  echo "To start development:"
  echo "  cd $project_name"
  
  case "$backend_type" in
    nextjs)
      echo "  $npm_cmd run dev"
      ;;
    *)
      echo "  cd frontend && $npm_cmd dev"
      echo "  cd backend && ..." # The specific command depends on the backend type
      ;;
  esac
} 