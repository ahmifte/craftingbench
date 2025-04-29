#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

# Direct command aliases for specialized project types
setup_go_library() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_go_library <project_name>"
    return 1
  fi
  
  setup_go_project "$project_name" --type=library
}

setup_go_backend() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_go_backend <project_name>"
    return 1
  fi
  
  setup_go_project "$project_name" --type=backend
}

# Help function for Go commands
show_go_help() {
  echo "Go Project Setup Commands:"
  echo ""
  echo "  setup_go_project <project_name> --type=<type>"
  echo "      Creates a new Go project with the specified type"
  echo "      Required: --type=library|backend"
  echo ""
  echo "  setup_go_library <project_name>"
  echo "      Creates a new Go library/module project"
  echo ""
  echo "  setup_go_backend <project_name>"
  echo "      Creates a new Go REST API backend"
  echo ""
  echo "Examples:"
  echo "  setup_go_project myproject --type=library"
  echo "  setup_go_library mylib"
  echo "  setup_go_backend myapi"
}

setup_go_project() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_go_help
    return 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_go_project <project_name> --type=<type>"
    echo "Run 'setup_go_project --help' for more information"
    return 1
  fi

  local project_name="$1"
  local project_type=""
  
  # Parse options
  shift 1
  local type_specified=false
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --type=*) 
        project_type="${1#*=}"
        type_specified=true
        ;;
      *) 
        echo "Unknown parameter: $1"
        echo "Run 'setup_go_project --help' for usage information"
        return 1 
        ;;
    esac
    shift
  done
  
  # Ensure project_type is specified
  if [[ "$type_specified" == "false" ]]; then
    echo "Error: Project type must be specified using --type=<type>"
    echo "Supported types: library, backend"
    echo "Example: setup_go_project $project_name --type=library"
    echo "Run 'setup_go_project --help' for more information"
    return 1
  fi
  
  case "$project_type" in
    library)
      _setup_go_library "$project_name"
      ;;
    backend)
      _setup_go_backend "$project_name"
      ;;
    *)
      echo "Error: Unsupported project type: $project_type"
      echo "Supported types: library, backend"
      echo "Run 'setup_go_project --help' for more information"
      return 1
      ;;
  esac
}

_setup_go_library() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "go"; then
    return 1
  fi
  
  echo "🚀 Setting up Go library project: $project_name"
  
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
  
  # Create README.md with more content
  cat > README.md << EOF
# $project_name

A Go library created with CraftingBench.

## Installation

\`\`\`bash
go get github.com/$github_username/$project_name
\`\`\`

## Usage

\`\`\`go
package main

import (
	"fmt"

	"github.com/$github_username/$project_name"
)

func main() {
	// Use the library
	message := $project_name.Hello()
	fmt.Println(message)
}
\`\`\`

## Development

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Run tests
make test
\`\`\`

## License

MIT
EOF
  
  # Create library package
  mkdir -p pkg
  
  # Create main library file
  cat > $project_name.go << EOF
// Package $project_name provides functionality for...
package $project_name

// Hello returns a friendly greeting.
func Hello() string {
	return "Hello from $project_name!"
}
EOF
  
  # Create test file
  cat > ${project_name}_test.go << EOF
package $project_name

import "testing"

func TestHello(t *testing.T) {
	want := "Hello from $project_name!"
	if got := Hello(); got != want {
		t.Errorf("Hello() = %q, want %q", got, want)
	}
}
EOF
  
  # Create example usage
  mkdir -p examples
  cat > examples/main.go << EOF
package main

import (
	"fmt"

	"github.com/$github_username/$project_name"
)

func main() {
	// Example usage of the library
	message := $project_name.Hello()
	fmt.Println(message)
}
EOF
  
  # Create Makefile
  cat > Makefile << EOF
.PHONY: build test lint clean

test:
	go test -v ./...

lint:
	go vet ./...
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed, skipping"; \
	fi

bench:
	go test -bench=. -benchmem ./...

coverage:
	go test -race -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html

clean:
	rm -f coverage.out coverage.html
EOF
  
  # Initialize git with all the files we've created
  git add .
  git commit -m "feat: Initial Go library setup"
  
  echo "✅ Go library project created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. Run tests: make test"
  echo ""
}

_setup_go_backend() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "go"; then
    return 1
  fi
  
  echo "🚀 Setting up Go backend project: $project_name"
  
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
bin/
tmp/

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

# Environment variables
.env
.env.*
!.env.example

# Go workspace file
go.work
EOF
  
  # Create standard Go project directory structure
  mkdir -p cmd/$project_name
  mkdir -p internal/api
  mkdir -p internal/middleware
  mkdir -p internal/models
  mkdir -p internal/services
  mkdir -p internal/config
  mkdir -p pkg
  mkdir -p scripts
  mkdir -p configs
  
  # Create README.md with more detailed information
  cat > README.md << EOF
# $project_name

A Go backend API created with CraftingBench.

## Features

- RESTful API with standard Go HTTP package
- Graceful shutdown
- Structured logging
- Configuration management
- Middleware support (CORS, logging, recovery)
- Docker support

## Development

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Build and run the application
make run
\`\`\`

## API Endpoints

- GET /api/health - Health check endpoint
- GET /api/version - API version information

## Project Structure

\`\`\`
$project_name/
├── cmd/                 # Application entrypoints
│   └── $project_name/   # Main application
├── internal/            # Private application code
│   ├── api/             # API handlers
│   ├── middleware/      # HTTP middleware
│   ├── models/          # Data models
│   ├── services/        # Business logic
│   └── config/          # Configuration
├── pkg/                 # Public libraries
├── configs/             # Configuration files
├── scripts/             # Build and deployment scripts
├── Dockerfile           # Docker build instructions
├── docker-compose.yml   # Docker compose configuration
├── go.mod               # Go module definition
└── Makefile             # Build commands
\`\`\`

## License

MIT
EOF
  
  # Create main.go
  cat > cmd/$project_name/main.go << EOF
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/$github_username/$project_name/internal/api"
	"github.com/$github_username/$project_name/internal/config"
	"github.com/$github_username/$project_name/internal/middleware"
)

func main() {
	// Load configuration
	cfg := config.Load()
	
	// Create a new router
	router := api.NewRouter()

	// Apply middlewares
	handler := middleware.Chain(
		router,
		middleware.Logging,
		middleware.CORS,
		middleware.Recovery,
	)

	// Create server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.Port),
		Handler:      handler,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	// Run server in a goroutine
	go func() {
		log.Printf("Server starting on port %d", cfg.Port)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server error: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	// Shutdown server gracefully
	log.Println("Server shutting down...")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("Server shutdown error: %v", err)
	}

	log.Println("Server exited properly")
}
EOF
  
  # Create config
  cat > internal/config/config.go << EOF
package config

import (
	"log"
	"os"
	"strconv"
)

// Config holds application configuration
type Config struct {
	// Server settings
	Port int
	
	// Environment
	Env string
	
	// API settings
	APIVersion string
}

// Load loads configuration from environment variables
func Load() *Config {
	// Default configuration
	cfg := &Config{
		Port:       8080,
		Env:        "development",
		APIVersion: "1.0.0",
	}
	
	// Override with environment variables if present
	if port := os.Getenv("PORT"); port != "" {
		if p, err := strconv.Atoi(port); err == nil {
			cfg.Port = p
		} else {
			log.Printf("Invalid PORT value: %s", port)
		}
	}
	
	if env := os.Getenv("ENV"); env != "" {
		cfg.Env = env
	}
	
	if version := os.Getenv("API_VERSION"); version != "" {
		cfg.APIVersion = version
	}
	
	return cfg
}
EOF
  
  # Create router.go
  cat > internal/api/router.go << EOF
package api

import (
	"encoding/json"
	"net/http"
)

// Response is a generic API response
type Response struct {
	Success bool        \`json:"success"\`
	Message string      \`json:"message,omitempty"\`
	Data    interface{} \`json:"data,omitempty"\`
}

// NewRouter creates a new HTTP router
func NewRouter() http.Handler {
	mux := http.NewServeMux()

	// Register routes
	mux.HandleFunc("/api/health", healthHandler)
	mux.HandleFunc("/api/version", versionHandler)

	return mux
}

// healthHandler responds with service health
func healthHandler(w http.ResponseWriter, r *http.Request) {
	respond(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]string{
			"status": "healthy",
		},
	})
}

// versionHandler responds with API version info
func versionHandler(w http.ResponseWriter, r *http.Request) {
	respond(w, http.StatusOK, Response{
		Success: true,
		Data: map[string]string{
			"version": "1.0.0",
			"name":    "$project_name",
		},
	})
}

// respond sends a JSON response
func respond(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	
	if payload != nil {
		if err := json.NewEncoder(w).Encode(payload); err != nil {
			http.Error(w, "Error encoding response", http.StatusInternalServerError)
		}
	}
}
EOF
  
  # Create middleware chain
  cat > internal/middleware/middleware.go << EOF
package middleware

import (
	"log"
	"net/http"
	"runtime/debug"
	"time"
)

// Middleware function type
type Middleware func(http.Handler) http.Handler

// Chain applies a list of middleware onto a http.Handler
func Chain(h http.Handler, middleware ...Middleware) http.Handler {
	for _, m := range middleware {
		h = m(h)
	}
	return h
}

// CORS adds CORS headers to responses
func CORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Set CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}

		next.ServeHTTP(w, r)
	})
}

// Logging logs each request
func Logging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		
		// Call the next handler
		next.ServeHTTP(w, r)
		
		// Log the request
		log.Printf(
			"%s %s %s %s",
			r.Method,
			r.RequestURI,
			r.RemoteAddr,
			time.Since(start),
		)
	})
}

// Recovery recovers from panics
func Recovery(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if err := recover(); err != nil {
				log.Printf("panic: %v\n%s", err, debug.Stack())
				http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			}
		}()
		
		next.ServeHTTP(w, r)
	})
}
EOF
  
  # Create Dockerfile
  cat > Dockerfile << EOF
FROM golang:1.20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY go.mod .
COPY go.sum* .
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $project_name ./cmd/$project_name

# Use a minimal alpine image
FROM alpine:3.17

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/$project_name .

# Create a non-root user and switch to it
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the application port
EXPOSE 8080

# Run the binary
CMD ["./$(project_name)"]
EOF
  
  # Create docker-compose.yml
  cat > docker-compose.yml << EOF
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ENV=development
      - PORT=8080
    restart: unless-stopped
EOF
  
  # Create .env.example
  cat > .env.example << EOF
# Server settings
PORT=8080
ENV=development

# API settings
API_VERSION=1.0.0
EOF
  
  # Create Makefile
  cat > Makefile << EOF
.PHONY: build run test lint clean docker-build docker-run docker-stop

build:
	go build -o bin/$project_name ./cmd/$project_name

run: build
	./bin/$project_name

test:
	go test -v ./...

lint:
	go vet ./...
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run; \
	else \
		echo "golangci-lint not installed, skipping"; \
	fi

clean:
	rm -rf bin/

docker-build:
	docker-compose build

docker-run:
	docker-compose up

docker-stop:
	docker-compose down
EOF
  
  # Initialize git with all the files we've created
  git add .
  git commit -m "feat: Initial Go backend setup"
  
  echo "✅ Go backend project created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. Build and run the application: make run"
  echo "  3. Visit http://localhost:8080/api/health to verify it's working"
  echo ""
} 