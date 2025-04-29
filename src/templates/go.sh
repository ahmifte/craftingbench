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
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Copy GitHub Actions workflow file
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/go-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/go-ci.yml
  else
    # Create GitHub Actions workflow file if template is not available
    cat > .github/workflows/go-ci.yml << EOF
name: Go CI

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

    - name: Set up Go \${{ matrix.go-version }}
      uses: actions/setup-go@v4
      with:
        go-version: \${{ matrix.go-version }}
        cache: true

    - name: Install dependencies
      run: go mod download

    - name: Lint
      uses: golangci/golangci-lint-action@v3
      with:
        version: latest
        args: --timeout=5m

    - name: Build
      run: go build -v ./...

    - name: Test
      run: go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.txt
        fail_ci_if_error: false
EOF
  fi
  
  # Initialize go module
  go mod init "$project_name"
  
  # Create project structure
  mkdir -p cmd/"$project_name"
  mkdir -p internal/{app,config,pkg,server}
  mkdir -p pkg/{logger,models,utils}
  mkdir -p api/{handlers,middleware,routes}
  
  # Create a main.go file in cmd directory
  cat > cmd/"$project_name"/main.go << EOF
package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"$project_name/internal/config"
	"$project_name/internal/server"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize server
	srv := server.New(cfg)

	// Start server in a goroutine
	go func() {
		if err := srv.Start(); err != nil {
			log.Printf("Server error: %v", err)
		}
	}()
	log.Printf("Server started on %s", cfg.ServerAddress)

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("Shutting down server...")

	// Create shutdown context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown server
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("Server exited properly")
}
EOF
  
  # Create config package
  cat > internal/config/config.go << EOF
package config

import (
	"os"
	"strconv"
)

// Config holds the application configuration
type Config struct {
	// Server config
	ServerAddress string
	ReadTimeout   int
	WriteTimeout  int
	IdleTimeout   int

	// Database config
	DBHost     string
	DBPort     string
	DBUser     string
	DBPassword string
	DBName     string
	DBSSLMode  string

	// Logger config
	LogLevel string
}

// Load loads configuration from environment variables
func Load() (*Config, error) {
	// Set defaults
	cfg := &Config{
		ServerAddress: getEnv("SERVER_ADDR", ":8080"),
		ReadTimeout:   getEnvAsInt("READ_TIMEOUT", 10),
		WriteTimeout:  getEnvAsInt("WRITE_TIMEOUT", 10),
		IdleTimeout:   getEnvAsInt("IDLE_TIMEOUT", 120),
		DBHost:        getEnv("DB_HOST", "localhost"),
		DBPort:        getEnv("DB_PORT", "5432"),
		DBUser:        getEnv("DB_USER", "postgres"),
		DBPassword:    getEnv("DB_PASSWORD", "postgres"),
		DBName:        getEnv("DB_NAME", "$project_name"),
		DBSSLMode:     getEnv("DB_SSLMODE", "disable"),
		LogLevel:      getEnv("LOG_LEVEL", "info"),
	}

	return cfg, nil
}

// Helper functions

// getEnv gets an environment variable or a default value
func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

// getEnvAsInt gets an environment variable as an integer
func getEnvAsInt(key string, defaultValue int) int {
	if value, exists := os.LookupEnv(key); exists {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}
EOF
  
  # Create server package
  cat > internal/server/server.go << EOF
package server

import (
	"context"
	"net/http"
	"time"

	"$project_name/api/routes"
	"$project_name/internal/config"
)

// Server represents the HTTP server
type Server struct {
	server *http.Server
}

// New creates a new server instance
func New(cfg *config.Config) *Server {
	// Initialize router
	r := routes.NewRouter()

	// Configure HTTP server
	srv := &http.Server{
		Addr:         cfg.ServerAddress,
		Handler:      r,
		ReadTimeout:  time.Duration(cfg.ReadTimeout) * time.Second,
		WriteTimeout: time.Duration(cfg.WriteTimeout) * time.Second,
		IdleTimeout:  time.Duration(cfg.IdleTimeout) * time.Second,
	}

	return &Server{server: srv}
}

// Start starts the server
func (s *Server) Start() error {
	return s.server.ListenAndServe()
}

// Shutdown gracefully shuts down the server
func (s *Server) Shutdown(ctx context.Context) error {
	return s.server.Shutdown(ctx)
}
EOF
  
  # Create routes package
  cat > api/routes/router.go << EOF
package routes

import (
	"encoding/json"
	"net/http"
)

// NewRouter creates a new HTTP router
func NewRouter() http.Handler {
	// Create a new ServeMux
	mux := http.NewServeMux()

	// Register routes
	mux.HandleFunc("/", handleIndex)
	mux.HandleFunc("/health", handleHealth)

	return mux
}

// handleIndex handles the index route
func handleIndex(w http.ResponseWriter, r *http.Request) {
	// Ensure request is for root path only
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}

	response := map[string]string{
		"message": "Welcome to $project_name API",
		"version": "1.0.0",
	}

	respondJSON(w, http.StatusOK, response)
}

// handleHealth handles the health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"status": "UP",
	}

	respondJSON(w, http.StatusOK, response)
}

// respondJSON sends a JSON response
func respondJSON(w http.ResponseWriter, status int, payload interface{}) {
	response, err := json.Marshal(payload)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	w.Write(response)
}
EOF
  
  # Create a basic Dockerfile
  cat > Dockerfile << EOF
# Build stage
FROM golang:1.21-alpine AS build

WORKDIR /app

# Copy go.mod and go.sum files to download dependencies
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/$project_name

# Final stage
FROM alpine:3.18

WORKDIR /app

# Copy the binary from the build stage
COPY --from=build /app/server .

# Run the binary
ENTRYPOINT ["./server"]
EOF
  
  # Create .gitignore
  cat > .gitignore << EOF
# Binaries for programs and plugins
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

# Operating system files
.DS_Store
Thumbs.db

# IDE and editor files
.idea/
.vscode/
*.swp
*.swo
*~

# Environment variables
.env
.env.local
EOF

  # Create README.md
  cat > README.md << EOF
# $project_name

[![Go CI](https://github.com/$github_username/$project_name/actions/workflows/go-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/go-ci.yml)

A Go API with a clean architecture.

## Features

- Clean architecture with separation of concerns
- Environment-based configuration
- Graceful server shutdown
- Docker support

## Getting Started

### Prerequisites

- Go 1.18 or higher
- Docker (optional)

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
# Run locally
go run ./cmd/$project_name

# Run tests
go test -v ./...

# Build binary
go build -o $project_name ./cmd/$project_name
\`\`\`

### Docker

\`\`\`bash
# Build Docker image
docker build -t $project_name:latest .

# Run Docker container
docker run -p 8080:8080 $project_name:latest
\`\`\`

## Project Structure

\`\`\`
├── api/                  # API layer
│   ├── handlers/         # HTTP handlers
│   ├── middleware/       # HTTP middleware
│   └── routes/           # HTTP routes
├── cmd/                  # Command-line applications
│   └── $project_name/    # Main application entry point
├── internal/             # Internal packages
│   ├── app/              # Application core logic
│   ├── config/           # Configuration
│   ├── pkg/              # Internal packages
│   └── server/           # HTTP server
├── pkg/                  # Public packages
│   ├── logger/           # Logging utilities
│   ├── models/           # Shared data models
│   └── utils/            # Utility functions
├── Dockerfile            # Docker configuration
├── go.mod                # Go module definition
└── README.md             # Project documentation
\`\`\`

## Environment Variables

- \`SERVER_ADDR\`: Server address (default: ":8080")
- \`READ_TIMEOUT\`: HTTP read timeout in seconds (default: 10)
- \`WRITE_TIMEOUT\`: HTTP write timeout in seconds (default: 10)
- \`IDLE_TIMEOUT\`: HTTP idle timeout in seconds (default: 120)
- \`LOG_LEVEL\`: Logging level (default: "info")

## License

MIT
EOF

  # Create a Makefile
  cat > Makefile << EOF
.PHONY: build run test clean lint docker-build docker-run

BINARY_NAME=$project_name
MAIN_PKG=./cmd/$project_name

# Build the application
build:
	go build -o \$(BINARY_NAME) \$(MAIN_PKG)

# Run the application
run:
	go run \$(MAIN_PKG)

# Run tests
test:
	go test -v ./...

# Run tests with coverage
test-coverage:
	go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...
	go tool cover -html=coverage.txt -o coverage.html

# Clean build artifacts
clean:
	rm -f \$(BINARY_NAME)
	rm -f coverage.*

# Lint the code
lint:
	golangci-lint run ./...

# Build Docker image
docker-build:
	docker build -t \$(BINARY_NAME):latest .

# Run Docker container
docker-run:
	docker run -p 8080:8080 \$(BINARY_NAME):latest
EOF

  # Create a .env.example file
  cat > .env.example << EOF
# Server configuration
SERVER_ADDR=:8080
READ_TIMEOUT=10
WRITE_TIMEOUT=10
IDLE_TIMEOUT=120

# Database configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=$project_name
DB_SSLMODE=disable

# Logger configuration
LOG_LEVEL=info
EOF

  # Create GitHub repository if gh CLI is available
  if command_exists gh; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm
    
    # Make initial commit
    git add .
    git commit -m "Initial Go project setup"
    
    # Push to GitHub
    git push -u origin main
  else
    # Just make a local commit
    git add .
    git commit -m "Initial Go project setup"
  fi
  
  echo "Go project has been set up successfully!"
  echo "To start development:"
  echo "  cd $project_name"
  echo "  go run ./cmd/$project_name"
} 