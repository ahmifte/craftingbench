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
  
  # Check for dependencies
  if ! check_dependencies "go git"; then
    return 1
  fi
  
  echo "🚀 Setting up Go library project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize Git repository
  git init

  # Check if GitHub repository exists
  if command -v gh &> /dev/null; then
    echo "Checking if GitHub repository exists: $github_username/$project_name"
    if gh repo view "$github_username/$project_name" &> /dev/null; then
      echo "GitHub repository exists. Cloning and setting up..."
      rm -rf .git
      gh repo clone "$github_username/$project_name" .
      git checkout -b main || git checkout main
    else
      echo "Creating new GitHub repository: $github_username/$project_name"
      gh repo create "$github_username/$project_name" --public --source=. --remote=origin
    fi
  else
    echo "GitHub CLI (gh) not found. Skipping GitHub repository setup."
    echo "Install GitHub CLI from https://cli.github.com/ for GitHub integration."
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Copy workflow template or create default workflow
  if [ -f "$CRAFTINGBENCH_PATH/src/templates/github-workflows/go-workflow.yml" ]; then
    cp "$CRAFTINGBENCH_PATH/src/templates/github-workflows/go-workflow.yml" .github/workflows/go-ci.yml
    # Replace placeholder with actual project name in workflow
    sed -i.bak "s/Go CI/$project_name CI/g" .github/workflows/go-ci.yml
    rm -f .github/workflows/go-ci.yml.bak
  else
    # Create a default workflow file
    cat > .github/workflows/go-ci.yml << EOF
name: $project_name CI

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
        go-version: ['1.19', '1.20', '1.21']
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: \${{ matrix.go-version }}
        cache: true
    
    - name: Install dependencies
      run: go mod download
    
    - name: Run tests
      run: go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.txt
        flags: unittests
        name: codecov-umbrella
        fail_ci_if_error: false
EOF
  fi

  # Initialize Go module
  go mod init "github.com/$github_username/$project_name"

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
	@if command -v golangci-lint > /dev/null; then \\
		golangci-lint run ./...; \\
	else \\
		echo "golangci-lint not installed, skipping"; \\
	fi

bench:
	go test -bench=. -benchmem ./...

coverage:
	go test -race -coverprofile=coverage.out -covermode=atomic ./...
	go tool cover -html=coverage.out -o coverage.html

clean:
	rm -f coverage.out coverage.html
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
  if ! check_dependencies "go git"; then
    return 1
  fi
  
  echo "🚀 Setting up Go REST API backend: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Create GitHub repository if gh CLI is available
  if command -v gh &> /dev/null; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm || true
  fi
  
  # Initialize Go module
  go mod init "github.com/$github_username/$project_name"
  
  # Create project structure
  mkdir -p cmd/$project_name
  mkdir -p internal/api
  mkdir -p internal/middleware
  mkdir -p internal/models
  mkdir -p internal/config
  mkdir -p pkg/logger
  mkdir -p pkg/database
  
  # Create main.go
  cat > cmd/$project_name/main.go << EOF
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/$github_username/$project_name/internal/api"
	"github.com/$github_username/$project_name/internal/config"
	"github.com/$github_username/$project_name/pkg/logger"
)

func main() {
	// Initialize logger
	log := logger.New()
	
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatal().Err(err).Msg("Failed to load configuration")
	}
	
	// Create router and register routes
	router := api.NewRouter(log)
	
	// Configure the server
	server := &http.Server{
		Addr:         cfg.Server.Address,
		Handler:      router,
		ReadTimeout:  cfg.Server.ReadTimeout,
		WriteTimeout: cfg.Server.WriteTimeout,
		IdleTimeout:  cfg.Server.IdleTimeout,
	}
	
	// Start server in a goroutine
	go func() {
		log.Info().Msgf("Starting server on %s", cfg.Server.Address)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal().Err(err).Msg("Server failed")
		}
	}()
	
	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	
	// Graceful shutdown
	log.Info().Msg("Shutting down server...")
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	if err := server.Shutdown(ctx); err != nil {
		log.Fatal().Err(err).Msg("Server forced to shutdown")
	}
	
	log.Info().Msg("Server exited properly")
}
EOF
  
  # Create router.go
  cat > internal/api/router.go << EOF
package api

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/rs/zerolog"

	"github.com/$github_username/$project_name/internal/api/handlers"
)

func NewRouter(log zerolog.Logger) http.Handler {
	r := chi.NewRouter()

	// Middleware
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Timeout(60 * time.Second))

	// Routes
	r.Get("/health", handlers.HealthCheck)
	
	// API routes
	r.Route("/api/v1", func(r chi.Router) {
		r.Get("/", handlers.Welcome)
		// Add more routes here
	})

	return r
}
EOF
  
  # Create handlers.go
  cat > internal/api/handlers/handlers.go << EOF
package handlers

import (
	"encoding/json"
	"net/http"
)

// Response represents a standard API response
type Response struct {
	Status  string      \`json:"status"\`
	Message string      \`json:"message,omitempty"\`
	Data    interface{} \`json:"data,omitempty"\`
}

// HealthCheck handles the health check endpoint
func HealthCheck(w http.ResponseWriter, r *http.Request) {
	resp := Response{
		Status:  "success",
		Message: "Service is healthy",
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

// Welcome handles the welcome endpoint
func Welcome(w http.ResponseWriter, r *http.Request) {
	resp := Response{
		Status:  "success",
		Message: "Welcome to the API",
		Data: map[string]string{
			"version": "1.0.0",
			"name":    "$project_name",
		},
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
EOF
  
  # Create config.go
  cat > internal/config/config.go << EOF
package config

import (
	"time"

	"github.com/spf13/viper"
)

type Config struct {
	Server ServerConfig
	Log    LogConfig
}

type ServerConfig struct {
	Address      string        \`mapstructure:"address"\`
	ReadTimeout  time.Duration \`mapstructure:"read_timeout"\`
	WriteTimeout time.Duration \`mapstructure:"write_timeout"\`
	IdleTimeout  time.Duration \`mapstructure:"idle_timeout"\`
}

type LogConfig struct {
	Level string \`mapstructure:"level"\`
}

func Load() (*Config, error) {
	viper.SetDefault("server.address", ":8080")
	viper.SetDefault("server.read_timeout", time.Second*15)
	viper.SetDefault("server.write_timeout", time.Second*15)
	viper.SetDefault("server.idle_timeout", time.Second*60)
	viper.SetDefault("log.level", "info")

	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AddConfigPath("./config")

	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, err
		}
	}

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, err
	}

	return &config, nil
}
EOF
  
  # Create logger.go
  cat > pkg/logger/logger.go << EOF
package logger

import (
	"os"
	"time"

	"github.com/rs/zerolog"
)

func New() zerolog.Logger {
	output := zerolog.ConsoleWriter{
		Out:        os.Stdout,
		TimeFormat: time.RFC3339,
	}

	return zerolog.New(output).
		Level(zerolog.InfoLevel).
		With().
		Timestamp().
		Caller().
		Logger()
}
EOF
  
  # Create config.yaml
  cat > config.yaml << EOF
server:
  address: ":8080"
  read_timeout: 15s
  write_timeout: 15s
  idle_timeout: 60s

log:
  level: "info"
EOF
  
  # Create .gitignore
  cat > .gitignore << EOF
# Binaries
bin/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary, built with \`go test -c\`
*.test

# Output of the go coverage tool
*.out
coverage.html

# Dependency directories
vendor/

# IDE directories
.idea/
.vscode/

# Environment files
.env
*.env

# Logs
*.log
EOF
  
  # Create Makefile
  cat > Makefile << EOF
.PHONY: build run test lint clean docker help

# Application name
APP_NAME = \$(shell basename \$(CURDIR))

# Main package path
MAIN_PKG = ./cmd/\$(APP_NAME)

# Build the application
build:
	@echo "Building application..."
	@go build -o bin/\$(APP_NAME) \$(MAIN_PKG)

# Run the application
run:
	@echo "Running application..."
	@go run \$(MAIN_PKG)

# Run tests
test:
	@echo "Running tests..."
	@go test -v -race -coverprofile=coverage.out ./...
	@go tool cover -func=coverage.out

# Run linter
lint:
	@echo "Running linter..."
	@if command -v golangci-lint > /dev/null; then \\
		golangci-lint run ./...; \\
	else \\
		echo "golangci-lint not installed. Installing..."; \\
		go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \\
		golangci-lint run ./...; \\
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf bin/
	@rm -f coverage.out coverage.html

# Build Docker image
docker-build:
	@echo "Building Docker image..."
	@docker build -t \$(APP_NAME) .

# Run Docker container
docker-run:
	@echo "Running Docker container..."
	@docker run -p 8080:8080 \$(APP_NAME)

# Show help
help:
	@echo "Available commands:"
	@echo "  make build        - Build the application"
	@echo "  make run          - Run the application"
	@echo "  make test         - Run tests"
	@echo "  make lint         - Run linter"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run   - Run Docker container"
	@echo "  make help         - Show this help message"
EOF
  
  # Create Dockerfile
  cat > Dockerfile << EOF
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/bin/server ./cmd/$project_name

# Final stage
FROM alpine:latest

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/bin/server .
COPY --from=builder /app/config.yaml .

# Expose port
EXPOSE 8080

# Run the application
CMD ["./server"]
EOF
  
  # Create README.md
  cat > README.md << EOF
# $project_name

A Go REST API backend created with CraftingBench.

## Features

- Modern project structure
- Chi router with middleware
- Configuration management with Viper
- Structured logging with Zerolog
- Graceful shutdown
- Docker support
- GitHub Actions CI/CD

## Getting Started

### Prerequisites

- Go 1.19 or later
- Make (optional, for using Makefile commands)
- Docker (optional, for containerization)

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies
go mod download
\`\`\`

### Development

\`\`\`bash
# Run the application
make run

# Run tests
make test

# Run linter
make lint

# Build the application
make build
\`\`\`

### Docker

\`\`\`bash
# Build Docker image
make docker-build

# Run Docker container
make docker-run
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── cmd/                    # Application entry points
│   └── $project_name/     # Main application
├── internal/              # Private application code
│   ├── api/              # API handlers and routes
│   ├── config/           # Configuration
│   ├── middleware/       # HTTP middleware
│   └── models/           # Data models
├── pkg/                  # Public libraries
│   ├── logger/          # Logging package
│   └── database/        # Database utilities
├── config.yaml          # Configuration file
├── Dockerfile          # Docker configuration
├── go.mod             # Go modules file
└── Makefile          # Build commands
\`\`\`

## API Endpoints

- \`GET /health\`: Health check endpoint
- \`GET /api/v1\`: Welcome endpoint

## License

MIT
EOF
  
  # Initialize git with all the files we've created
  git add .
  git commit -m "feat: Initial Go backend setup"
  
  # Install dependencies
  go mod tidy
  
  echo "✅ Go backend project created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. Build and run the application: make run"
  echo "  3. Visit http://localhost:8080/api/health to verify it's working"
  echo ""
} 