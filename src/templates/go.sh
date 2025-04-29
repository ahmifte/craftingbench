#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_go_project() {
  local project_name="$1"
  
  # Check for required arguments
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
    echo "Usage: setup_go_project <project_name>"
    return 1
  fi
  
  # Check for dependencies
  if ! check_dependencies "go git"; then
    return 1
  fi

  # Create project directory and navigate to it
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize Git repository
  git init

  # Check if GitHub repository exists
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
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
    
    - name: Verify dependencies
      run: go mod verify
    
    - name: Install golangci-lint
      run: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    
    - name: Lint
      run: golangci-lint run ./...
    
    - name: Build
      run: go build -v ./...
    
    - name: Test with coverage
      run: go test -race -coverprofile=coverage.txt -covermode=atomic ./...
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.txt
        flags: unittests
        name: codecov-$project_name
        fail_ci_if_error: false
EOF
  fi

  # Initialize Go module
  go mod init "github.com/$github_username/$project_name"

  # Create basic project structure
  mkdir -p cmd/$project_name
  mkdir -p internal/app/api
  mkdir -p internal/app/config
  mkdir -p internal/app/middleware
  mkdir -p internal/app/models
  mkdir -p internal/app/services
  mkdir -p internal/pkg/database
  mkdir -p internal/pkg/logger
  mkdir -p pkg
  mkdir -p api/routes
  mkdir -p scripts
  mkdir -p docs

  # Create main Go file
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

	"github.com/$github_username/$project_name/internal/app/api"
	"github.com/$github_username/$project_name/internal/app/config"
	"github.com/$github_username/$project_name/internal/pkg/logger"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	// Initialize logger
	logger := logger.New(cfg.LogLevel)
	logger.Info("Starting $project_name server...")

	// Create router
	router := api.NewRouter(cfg, logger)

	// Configure server
	server := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.Server.Port),
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Start server in goroutine to allow graceful shutdown
	go func() {
		logger.Info(fmt.Sprintf("Server listening on port %d", cfg.Server.Port))
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal(fmt.Sprintf("Server error: %v", err))
		}
	}()

	// Wait for interrupt signal to gracefully shut down the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	logger.Info("Shutting down server...")

	// Create context with timeout for shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown server
	if err := server.Shutdown(ctx); err != nil {
		logger.Fatal(fmt.Sprintf("Server forced to shutdown: %v", err))
	}

	logger.Info("Server exited")
}
EOF

  # Create configuration
  cat > internal/app/config/config.go << EOF
package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

// Config holds all configuration for the application
type Config struct {
	Environment string
	LogLevel    string
	Server      ServerConfig
	Database    DatabaseConfig
}

// ServerConfig holds server-specific configuration
type ServerConfig struct {
	Port int
	Host string
}

// DatabaseConfig holds database-specific configuration
type DatabaseConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	Name     string
	SSLMode  string
}

// Load reads configuration from environment variables
func Load() (*Config, error) {
	// Load .env file if it exists
	_ = godotenv.Load()

	// Default port if not specified
	port := 8080
	if portStr := os.Getenv("PORT"); portStr != "" {
		var err error
		port, err = strconv.Atoi(portStr)
		if err != nil {
			return nil, fmt.Errorf("invalid PORT: %w", err)
		}
	}

	dbPort := 5432
	if dbPortStr := os.Getenv("DB_PORT"); dbPortStr != "" {
		var err error
		dbPort, err = strconv.Atoi(dbPortStr)
		if err != nil {
			return nil, fmt.Errorf("invalid DB_PORT: %w", err)
		}
	}

	return &Config{
		Environment: getEnv("ENVIRONMENT", "development"),
		LogLevel:    getEnv("LOG_LEVEL", "info"),
		Server: ServerConfig{
			Port: port,
			Host: getEnv("HOST", "0.0.0.0"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     dbPort,
			User:     getEnv("DB_USER", "postgres"),
			Password: getEnv("DB_PASSWORD", ""),
			Name:     getEnv("DB_NAME", "$project_name"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
	}, nil
}

// getEnv reads an environment variable or returns a default value
func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}
EOF

  # Create router
  cat > internal/app/api/router.go << EOF
package api

import (
	"net/http"
	"time"

	"github.com/$github_username/$project_name/api/routes"
	"github.com/$github_username/$project_name/internal/app/config"
	"github.com/$github_username/$project_name/internal/app/middleware"
	"github.com/$github_username/$project_name/internal/pkg/logger"
	"github.com/gorilla/mux"
)

// NewRouter creates and configures a new router
func NewRouter(cfg *config.Config, logger logger.Logger) http.Handler {
	router := mux.NewRouter()

	// Add middleware
	router.Use(middleware.LoggingMiddleware(logger))
	router.Use(middleware.RecoveryMiddleware(logger))

	// Health check route
	router.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(\`{"status":"ok","time":"\` + time.Now().Format(time.RFC3339) + \`"}\`))
	}).Methods(http.MethodGet)

	// Register API routes
	apiRouter := router.PathPrefix("/api").Subrouter()
	routes.RegisterRoutes(apiRouter, cfg, logger)

	return router
}
EOF

  # Create API routes
  cat > api/routes/routes.go << EOF
package routes

import (
	"github.com/$github_username/$project_name/internal/app/config"
	"github.com/$github_username/$project_name/internal/pkg/logger"
	"github.com/gorilla/mux"
)

// RegisterRoutes registers all API routes
func RegisterRoutes(router *mux.Router, cfg *config.Config, logger logger.Logger) {
	// Example:
	// userHandler := handlers.NewUserHandler(services.NewUserService(repository.NewUserRepository(db)))
	// router.HandleFunc("/users", userHandler.GetUsers).Methods(http.MethodGet)
	// router.HandleFunc("/users/{id}", userHandler.GetUser).Methods(http.MethodGet)
	// router.HandleFunc("/users", userHandler.CreateUser).Methods(http.MethodPost)
}
EOF

  # Create middleware
  cat > internal/app/middleware/logging.go << EOF
package middleware

import (
	"net/http"
	"time"

	"github.com/$github_username/$project_name/internal/pkg/logger"
)

// LoggingMiddleware logs request details
func LoggingMiddleware(logger logger.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()

			// Call the next handler
			next.ServeHTTP(w, r)

			// Log after request is handled
			logger.Info("Request",
				"method", r.Method,
				"path", r.URL.Path,
				"remote_addr", r.RemoteAddr,
				"user_agent", r.UserAgent(),
				"duration", time.Since(start),
			)
		})
	}
}
EOF

  # Create recovery middleware
  cat > internal/app/middleware/recovery.go << EOF
package middleware

import (
	"net/http"
	"runtime/debug"

	"github.com/$github_username/$project_name/internal/pkg/logger"
)

// RecoveryMiddleware recovers from panics and logs the error
func RecoveryMiddleware(logger logger.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			defer func() {
				if err := recover(); err != nil {
					logger.Error("Recovered from panic",
						"error", err,
						"stack", string(debug.Stack()),
					)
					http.Error(w, "Internal Server Error", http.StatusInternalServerError)
				}
			}()
			next.ServeHTTP(w, r)
		})
	}
}
EOF

  # Create logger
  cat > internal/pkg/logger/logger.go << EOF
package logger

import (
	"log/slog"
	"os"
	"strings"
)

// Logger is an interface for logging
type Logger interface {
	Debug(msg string, args ...interface{})
	Info(msg string, args ...interface{})
	Warn(msg string, args ...interface{})
	Error(msg string, args ...interface{})
	Fatal(msg string, args ...interface{})
}

// SlogLogger implements Logger using slog
type SlogLogger struct {
	logger *slog.Logger
}

// New creates a new logger
func New(level string) Logger {
	var logLevel slog.Level
	switch strings.ToLower(level) {
	case "debug":
		logLevel = slog.LevelDebug
	case "info":
		logLevel = slog.LevelInfo
	case "warn":
		logLevel = slog.LevelWarn
	case "error":
		logLevel = slog.LevelError
	default:
		logLevel = slog.LevelInfo
	}

	handler := slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
		Level: logLevel,
	})

	return &SlogLogger{
		logger: slog.New(handler),
	}
}

// Debug logs a debug level message
func (l *SlogLogger) Debug(msg string, args ...interface{}) {
	l.logger.Debug(msg, args...)
}

// Info logs an info level message
func (l *SlogLogger) Info(msg string, args ...interface{}) {
	l.logger.Info(msg, args...)
}

// Warn logs a warning level message
func (l *SlogLogger) Warn(msg string, args ...interface{}) {
	l.logger.Warn(msg, args...)
}

// Error logs an error level message
func (l *SlogLogger) Error(msg string, args ...interface{}) {
	l.logger.Error(msg, args...)
}

// Fatal logs a fatal level message and exits
func (l *SlogLogger) Fatal(msg string, args ...interface{}) {
	l.logger.Error(msg, args...)
	os.Exit(1)
}
EOF

  # Create .env.example
  cat > .env.example << EOF
# Application Configuration
ENVIRONMENT=development
LOG_LEVEL=debug
PORT=8080
HOST=0.0.0.0

# API Configuration
API_PREFIX=/api
RATE_LIMIT=100

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=${project_name}_db
DB_SSLMODE=disable

# JWT Configuration (if needed)
JWT_SECRET=replace_with_secure_secret_key
JWT_EXPIRATION=24h

# External Services (if needed)
EXTERNAL_API_URL=https://api.example.com
EXTERNAL_API_KEY=your_api_key_here

# Monitoring (if needed)
ENABLE_METRICS=true
METRICS_PORT=9090
EOF

  # Create actual .env file (gitignored)
  cp .env.example .env

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
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $project_name ./cmd/$project_name

# Final stage
FROM alpine:latest

WORKDIR /app

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

# Copy binary from builder stage
COPY --from=builder /app/$project_name .
COPY --from=builder /app/.env.example ./.env

# Expose application port
EXPOSE 8080

# Run the application
CMD ["./$(echo $project_name | tr '[:upper:]' '[:lower:]')"]
EOF

  # Create .gitignore
  cat > .gitignore << EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib
$(echo $project_name | tr '[:upper:]' '[:lower:]')

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out
coverage.txt

# Dependency directories
vendor/

# Go workspace file
go.work

# IDE files
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Environment variables
.env

# OS specific files
.DS_Store
*.swp
*.swo

# Log files
*.log
EOF

  # Create README.md
  cat > README.md << EOF
# $project_name

[![CI Status](https://github.com/$github_username/$project_name/workflows/$project_name%20CI/badge.svg)](https://github.com/$github_username/$project_name/actions)

A Go backend application built with modern practices.

## Features

- Modern Go application structure
- Configuration using environment variables
- Structured logging
- Graceful shutdown
- Middleware support
- Docker support
- GitHub Actions CI pipeline

## Development

### Prerequisites

- Go 1.18 or newer
- Docker (optional)

### Setup

1. Clone the repository:
   \`\`\`bash
   git clone https://github.com/$github_username/$project_name.git
   cd $project_name
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   go mod download
   \`\`\`

3. Configure environment variables:
   \`\`\`bash
   cp .env.example .env
   # Edit .env with your desired configuration
   \`\`\`

4. Run the application:
   \`\`\`bash
   go run cmd/$project_name/main.go
   \`\`\`

### Running with Docker

1. Build the Docker image:
   \`\`\`bash
   docker build -t $project_name .
   \`\`\`

2. Run the container:
   \`\`\`bash
   docker run -p 8080:8080 -e ENVIRONMENT=development $project_name
   \`\`\`

## Environment Variables

The application can be configured using environment variables:

| Variable       | Description            | Default       |
|----------------|------------------------|---------------|
| ENVIRONMENT    | Runtime environment    | development   |
| LOG_LEVEL      | Logging level          | info          |
| PORT           | Server port            | 8080          |
| HOST           | Server host            | 0.0.0.0       |
| DB_HOST        | Database host          | localhost     |
| DB_PORT        | Database port          | 5432          |
| DB_USER        | Database user          | postgres      |
| DB_PASSWORD    | Database password      |               |
| DB_NAME        | Database name          | $project_name |
| DB_SSLMODE     | Database SSL mode      | disable       |

## API Endpoints

- GET /health - Health check endpoint
- GET /api/... - API endpoints (add more as needed)

## Project Structure

\`\`\`
$project_name/
├── api/                    # API route definitions
├── cmd/                    # Application entry points
│   └── $project_name/      # Main application
├── docs/                   # Documentation
├── internal/               # Private application code
│   ├── app/                # Application core
│   │   ├── api/            # API handlers and router
│   │   ├── config/         # Configuration
│   │   ├── middleware/     # HTTP middleware
│   │   ├── models/         # Data models
│   │   └── services/       # Business logic
│   └── pkg/                # Private libraries
│       ├── database/       # Database utilities
│       └── logger/         # Logger implementation
├── pkg/                    # Public libraries
├── scripts/                # Scripts for development
├── .env.example            # Example environment variables
├── Dockerfile              # Docker build instructions
├── go.mod                  # Go module definition
└── README.md               # This file
\`\`\`

## Makefile commands

Run \`make help\` to see available commands:

\`\`\`bash
make build      # Build the application
make run        # Run the application
make test       # Run tests
make lint       # Run linter
make docker     # Build Docker image
\`\`\`

## License

MIT
EOF

  # Create Makefile
  cat > Makefile << EOF
.PHONY: build run test lint clean docker help

# Application name
APP_NAME = $(echo $project_name | tr '[:upper:]' '[:lower:]')

# Directory containing main package
MAIN_DIR = cmd/$project_name

# Build the application
build:
	@echo "Building application..."
	@go build -o \$(APP_NAME) \$(MAIN_DIR)

# Run the application
run:
	@echo "Running application..."
	@go run \$(MAIN_DIR)/main.go

# Run tests with coverage
test:
	@echo "Running tests with coverage..."
	@go test -race -coverprofile=coverage.txt -covermode=atomic ./...
	@go tool cover -func=coverage.txt

# Run linter
lint:
	@echo "Running linter..."
	@if command -v golangci-lint &> /dev/null; then \
		golangci-lint run ./...; \
	else \
		echo "golangci-lint not installed. Installing..."; \
		go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
		golangci-lint run ./...; \
	fi

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -f \$(APP_NAME)
	@rm -f coverage.txt

# Build Docker image
docker:
	@echo "Building Docker image..."
	@docker build -t \$(APP_NAME) .

# Show help
help:
	@echo "Available commands:"
	@echo "  make build      - Build the application"
	@echo "  make run        - Run the application"
	@echo "  make test       - Run tests with coverage"
	@echo "  make lint       - Run linter"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make docker     - Build Docker image"
	@echo "  make help       - Show this help message"
EOF

  # Initialize go.mod file with required dependencies
  go get github.com/gorilla/mux
  go get github.com/joho/godotenv
  go mod tidy

  # Commit changes
  git add .
  git commit -m "Initial project setup for $project_name"

  # Display success message
  echo ""
  echo "🚀 Go backend project '$project_name' has been set up successfully!"
  echo "To start development, navigate to the project directory and run:"
  echo ""
  echo "  cd $project_name"
  echo "  go mod download"
  echo "  go run cmd/$project_name/main.go"
  echo ""
} 