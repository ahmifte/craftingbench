#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_go_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_go_project <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "go"; then
    return 1
  fi
  
  echo "🚀 Setting up Go project: $project_name"
  
  # Create project directory
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
  
  # Initialize Go module
  go mod init "github.com/$github_username/$project_name"
  
  # Create .gitignore for Go
  cat > .gitignore << EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib
**/bin/

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out
*.prof
coverage.html

# IDE files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Icon?
ehthumbs.db
Thumbs.db

# Go workspace file
go.work
EOF
  
  # Create standard Go project directory structure
  mkdir -p cmd/$project_name
  mkdir -p internal/app internal/pkg
  mkdir -p pkg
  mkdir -p api/rest
  mkdir -p configs
  mkdir -p scripts
  mkdir -p test
  mkdir -p docs
  
  # Create main.go
  cat > cmd/$project_name/main.go << EOF
package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/$github_username/$project_name/internal/app"
)

func main() {
	// Initialize application
	application, err := app.New()
	if err != nil {
		log.Fatalf("Failed to initialize application: %v", err)
	}

	// Start the application
	if err := application.Start(); err != nil {
		log.Fatalf("Failed to start application: %v", err)
	}
	
	// Set up graceful shutdown
	shutdownCh := make(chan os.Signal, 1)
	signal.Notify(shutdownCh, syscall.SIGINT, syscall.SIGTERM)
	
	// Wait for shutdown signal
	sig := <-shutdownCh
	fmt.Printf("Received signal: %v\n", sig)
	
	// Shutdown the application
	if err := application.Stop(); err != nil {
		log.Fatalf("Failed to stop application: %v", err)
	}
	
	fmt.Println("Application shutdown successfully")
}
EOF
  
  # Create app.go
  cat > internal/app/app.go << EOF
package app

import (
	"context"
	"fmt"
	"net/http"
	"time"
)

// App represents the application.
type App struct {
	server *http.Server
}

// New creates a new instance of the application.
func New() (*App, error) {
	// Create a new app
	app := &App{
		server: &http.Server{
			Addr:         ":8080",
			ReadTimeout:  10 * time.Second,
			WriteTimeout: 10 * time.Second,
			IdleTimeout:  120 * time.Second,
		},
	}
	
	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/", app.homeHandler)
	mux.HandleFunc("/health", app.healthHandler)
	app.server.Handler = mux
	
	return app, nil
}

// Start starts the application.
func (a *App) Start() error {
	fmt.Println("Starting application on :8080")
	
	// Start HTTP server in a goroutine
	go func() {
		if err := a.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			fmt.Printf("HTTP server error: %v\n", err)
		}
	}()
	
	return nil
}

// Stop gracefully shuts down the application.
func (a *App) Stop() error {
	fmt.Println("Shutting down server...")
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	if err := a.server.Shutdown(ctx); err != nil {
		return fmt.Errorf("server shutdown failed: %w", err)
	}
	
	return nil
}

// homeHandler handles the home route.
func (a *App) homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Welcome to %s!\n", "$project_name")
}

// healthHandler handles the health check route.
func (a *App) healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, \`{"status":"UP"}\`)
}
EOF
  
  # Create a simple README.md
  cat > README.md << EOF
# $project_name

A Go application with a standard project layout.

## Project Structure

\`\`\`
$project_name/
├── api/            # API definitions (OpenAPI/Swagger specs, protocol definitions)
├── cmd/            # Command line entry points
│   └── $project_name/    # Main application
├── configs/               # Configuration files
├── internal/              # Private application code
│   ├── app/               # Application core
│   └── pkg/               # Private packages
├── pkg/                   # Public packages
├── scripts/        # Scripts for dev, CI, build, etc.
└── test/           # Additional external test applications and test data
\`\`\`

## Getting Started

### Prerequisites

- Go 1.18 or later

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Build the project
go build -o bin/$project_name ./cmd/$project_name

# Run the project
./bin/$project_name
\`\`\`

### Development

\`\`\`bash
# Run tests
go test ./...

# Format code
go fmt ./...

# Lint code
go vet ./...
\`\`\`

## API Endpoints

- \`GET /\` - Home page
- \`GET /health\` - Health check endpoint

## License

MIT
EOF
  
  # Create a Makefile
  cat > Makefile << EOF
# Project variables
BINARY_NAME=$(shell basename $(CURDIR))
MAIN_PACKAGE=./cmd/$(BINARY_NAME)
BUILD_DIR=./bin
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS=-ldflags "-X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME)"

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

.PHONY: all build clean run test vet fmt

all: build

# Build the application
build:
	mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE)

# Run the application
run: build
	$(BUILD_DIR)/$(BINARY_NAME)

# Run tests
test:
	$(GOTEST) ./...

# Lint code
vet:
	$(GOCMD) vet ./...

# Format code
fmt:
	$(GOFMT) ./...

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -rf $(BUILD_DIR)
EOF

  # Add all files and commit
  git add .
  git commit -m "Set up Go project structure"
  
  # If GitHub CLI is available, try to push and create PR
  if command_exists gh && git remote -v | grep -q origin; then
    # Push the initial-setup branch
    git push -u origin initial-setup
    
    # Create pull request using GitHub CLI
    echo "Creating pull request..."
    gh pr create --title "Initial Go Project Setup" --body "This PR sets up a Go project with:

- Standard Go project layout
- HTTP server with graceful shutdown
- Health check endpoint
- Application configuration
- Makefile for common commands
- Documentation

Ready for review." --base main || echo "Failed to create PR. You may need to create it manually."
    
    echo "✓ Go project '$project_name' is ready!"
    echo "GitHub: https://github.com/$github_username/$project_name"
  else
    echo "✓ Go project '$project_name' is ready locally!"
  fi
  
  echo ""
  echo "Next steps:"
  echo "1. cd $project_name"
  echo "2. make build"
  echo "3. make run"
} 