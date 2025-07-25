#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"
# Import template utilities
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/template-utils.sh"

# Direct command aliases for specialized project types
setup_python_docker_api() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_docker_api <project_name>"
    return 1
  fi
  
  setup_python_docker_project "$project_name" --type=api
}

setup_python_docker_cli() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_docker_cli <project_name>"
    return 1
  fi
  
  setup_python_docker_project "$project_name" --type=cli
}

# Help function for Python Docker commands
show_python_docker_help() {
  echo "Python Docker Project Setup Commands:"
  echo ""
  echo "  setup_python_docker_project <project_name> --type=<type> [--ai-ready]"
  echo "      Creates a new Python project with Docker and CI/CD"
  echo "      Required: --type=api|cli"
  echo "      Optional: --ai-ready (includes AI/ML dependencies and patterns)"
  echo ""
  echo "  setup_python_docker_api <project_name>"
  echo "      Creates a new Python API project with Docker"
  echo ""
  echo "  setup_python_docker_cli <project_name>"
  echo "      Creates a new Python CLI project with Docker"
  echo ""
  echo "Examples:"
  echo "  setup_python_docker_project myapi --type=api"
  echo "  setup_python_docker_project myai --type=api --ai-ready"
  echo "  setup_python_docker_api myservice"
  echo "  setup_python_docker_cli mytool"
}

setup_python_docker_project() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_python_docker_help
    return 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_docker_project <project_name> --type=<type>"
    echo "Run 'setup_python_docker_project --help' for more information"
    return 1
  fi
  
  local project_name="$1"
  local project_type=""
  local ai_ready=false
  
  # Parse options
  shift 1
  local type_specified=false
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --type=*) 
        project_type="${1#*=}"
        type_specified=true
        ;;
      --ai-ready)
        ai_ready=true
        ;;
      *) 
        echo "Unknown parameter: $1"
        echo "Run 'setup_python_docker_project --help' for usage information"
        return 1 
        ;;
    esac
    shift
  done
  
  # Ensure project_type is specified
  if [[ "$type_specified" == "false" ]]; then
    echo "Error: Project type must be specified using --type=<type>"
    echo "Supported types: api, cli"
    echo "Example: setup_python_docker_project $project_name --type=api"
    echo "Run 'setup_python_docker_project --help' for more information"
    return 1
  fi
  
  case "$project_type" in
    api)
      _setup_python_docker_api "$project_name" "$ai_ready"
      ;;
    cli)
      _setup_python_docker_cli "$project_name" "$ai_ready"
      ;;
    *)
      echo "Error: Unsupported project type: $project_type"
      echo "Supported types: api, cli"
      echo "Run 'setup_python_docker_project --help' for more information"
      return 1
      ;;
  esac
}

_setup_python_docker_api() {
  local project_name="$1"
  local ai_ready="$2"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python docker"; then
    return 1
  fi
  
  echo "🚀 Setting up Python Docker API project: $project_name"
  if [[ "$ai_ready" == "true" ]]; then
    echo "   Including AI/ML dependencies and patterns"
  fi
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Create an initial empty README.md
  echo "# $project_name" > README.md
  git add README.md
  git commit -m "Initial commit"
  
  # Check if the repository already exists
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Please choose a different name."
    cd ..
    rm -rf "$project_name"
    return 1
  elif command_exists gh; then
    # Create a new GitHub repository
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private --source=. --remote=origin --push
    
    # Create and checkout feature branch
    git checkout -b feat/initial-setup
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "To create a GitHub repository, install gh CLI: https://cli.github.com/"
    
    # Create and checkout feature branch
    git checkout -b feat/initial-setup
  fi
  
  # Create project structure
  mkdir -p src tests docs scripts
  mkdir -p src/api src/core src/services src/models src/utils
  
  # Create comprehensive README.md
  cat > README.md << EOF
# $project_name

A Python API project with Docker support, comprehensive CI/CD, and production-ready architecture.

## 🚀 Features

- **Framework**: FastAPI with async support for high-performance APIs
- **Container**: Multi-stage Docker builds producing minimal production images
- **CI/CD**: GitHub Actions with automated testing, security scanning, and multi-platform builds
- **Testing**: pytest with coverage reporting and integration test support
- **Code Quality**: Pre-commit hooks with black, ruff, mypy for consistent code
- **Documentation**: Auto-generated OpenAPI docs with ReDoc and Swagger UI
- **Monitoring**: Built-in health checks, structured logging, and Prometheus metrics
- **Security**: Automated vulnerability scanning with Trivy, bandit, and safety
$(if [[ "$ai_ready" == "true" ]]; then echo "- **AI/ML Ready**: OpenAI/Anthropic integrations with prompt management system"; fi)

## 📋 Prerequisites

- Python 3.11 or higher
- Docker and Docker Compose
- Make (optional but recommended)
- GitHub CLI (optional, for repository creation)

## 🏃‍♂️ Quick Start

### Using Docker (Recommended)

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Build and run with Docker Compose
make docker-up

# Or manually:
docker-compose up --build
\`\`\`

The API will be available at:
- API Endpoint: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Health Check: http://localhost:8000/health
- Metrics: http://localhost:8000/metrics

### Local Development

\`\`\`bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate

# Install development dependencies
make install-dev

# Run development server with auto-reload
make dev
\`\`\`

## 🐳 Docker Commands

\`\`\`bash
# Build Docker image
make docker-build

# Run Docker container
docker run -p 8000:8000 --env-file .env ${project_name}:latest

# Run with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
\`\`\`

## 🧪 Testing

\`\`\`bash
# Run all tests with coverage
make test

# Run specific test file
pytest tests/test_health.py -v

# Run tests in Docker
make docker-test

# Run integration tests
docker-compose up -d
pytest tests/integration -v
docker-compose down
\`\`\`

## 🛠️ Development Workflow

1. **Setup**: Fork and clone the repository
2. **Branch**: Create a feature branch (\`git checkout -b feature/amazing-feature\`)
3. **Develop**: Make your changes with TDD approach
4. **Lint**: Run \`make lint\` to check code quality
5. **Test**: Run \`make test\` to ensure all tests pass
6. **Commit**: Commit with conventional commits (\`feat:`, \`fix:`, \`docs:\`, etc.)
7. **Push**: Push to your fork and create a Pull Request

## 📁 Project Structure

\`\`\`
$project_name/
├── src/                      # Application source code
│   ├── api/                  # API endpoints and routes
│   │   ├── v1/              # API version 1
│   │   └── health.py        # Health check endpoints
│   ├── core/                # Core application components
│   │   ├── config.py        # Configuration management
│   │   └── logging.py       # Logging configuration
│   ├── models/              # Pydantic models
│   ├── services/            # Business logic layer
│   └── utils/               # Utility functions
├── tests/                   # Test suite
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── conftest.py         # Pytest configuration
├── docker/                  # Docker configurations
├── scripts/                 # Utility scripts
├── .github/                 # GitHub configurations
│   └── workflows/          # CI/CD pipelines
├── Dockerfile              # Multi-stage Docker build
├── docker-compose.yml      # Local development setup
├── Makefile               # Common commands
├── pyproject.toml         # Python package configuration
└── README.md              # This file
\`\`\`

## ⚙️ Configuration

### Environment Variables

Create a \`.env\` file based on \`.env.example\`:

\`\`\`env
# Application Settings
APP_NAME=$project_name
APP_ENV=development  # development, staging, production
DEBUG=true
LOG_LEVEL=info      # debug, info, warning, error, critical
LOG_FORMAT=json     # json or text

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=1       # Number of Uvicorn workers

# Redis Cache (optional)
REDIS_URL=redis://localhost:6379/0

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML Configuration
OPENAI_API_KEY=sk-...      # Your OpenAI API key
ANTHROPIC_API_KEY=sk-...   # Your Anthropic API key
MODEL_NAME=gpt-4          # Default model to use
MAX_TOKENS=1000           # Maximum tokens for completion
TEMPERATURE=0.7           # Model temperature (0.0-2.0)

# Prompt Engineering Best Practices
# 1. System prompts are defined in src/prompts/*.j2
# 2. Use temperature 0.0-0.3 for consistent/factual outputs
# 3. Use temperature 0.7-1.0 for creative outputs
# 4. Always validate and sanitize LLM outputs
# 5. Implement retry logic with exponential backoff
# 6. Monitor token usage and implement rate limiting"; fi)
\`\`\`

## 📝 API Documentation

Once the application is running, you can access:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

### Example API Usage

\`\`\`bash
# Health check
curl http://localhost:8000/health

# Create an example
curl -X POST http://localhost:8000/api/v1/examples \\
  -H "Content-Type: application/json" \\
  -d '{"name": "Test", "description": "Test example"}'

# Get all examples
curl http://localhost:8000/api/v1/examples
\`\`\`

$(if [[ "$ai_ready" == "true" ]]; then echo "## 🤖 AI/ML Features

### Prompt Management

Prompts are managed using Jinja2 templates in the \`prompts/\` directory:

\`\`\`python
from src.ai.prompts import get_prompt_manager

prompt_mgr = get_prompt_manager()
prompt = prompt_mgr.load_prompt(\"example\", 
    app_name=\"$project_name\",
    context=\"User asking about features\",
    query=\"What can you do?\"
)
\`\`\`

### Using the LLM Service

\`\`\`python
from src.ai.llm import get_llm_service

llm = get_llm_service()
response = await llm.complete(
    prompt=\"Explain quantum computing\",
    system_prompt=\"You are a helpful physics teacher\",
    temperature=0.7
)
\`\`\`

### Prompt Engineering Best Practices

1. **Be Specific**: Clear, detailed prompts yield better results
2. **Set Context**: Always provide relevant context via system prompts
3. **Temperature Control**: Use low temperature (0.0-0.3) for factual tasks
4. **Output Format**: Specify desired output format explicitly
5. **Validation**: Always validate LLM outputs before using them
6. **Token Optimization**: Monitor and optimize token usage
7. **Error Handling**: Implement robust error handling for API failures

### Example Prompt Template

\`\`\`jinja2
{# prompts/analysis.j2 #}
You are an expert {{ role }} assistant for {{ app_name }}.

{% if context %}
Context: {{ context }}
{% endif %}

Task: {{ task }}

Requirements:
- Provide clear, actionable insights
- Use specific examples when possible
- Format output as {{ output_format }}

User Query: {{ query }}
\`\`\`"; fi)

## 🔧 Make Commands

Run \`make help\` to see all available commands:

\`\`\`bash
make help         # Show this help message
make install      # Install production dependencies
make install-dev  # Install development dependencies
make dev          # Run development server
make test         # Run tests with coverage
make lint         # Run linting checks
make format       # Format code
make clean        # Clean build artifacts
make docker-build # Build Docker image
make docker-up    # Start services with Docker Compose
make docker-down  # Stop Docker services
make docker-test  # Run tests in Docker
\`\`\`

## 🚀 Deployment

### GitHub Actions CI/CD

The project includes comprehensive CI/CD pipelines that run on every push:

1. **Linting & Type Checking**: Ensures code quality
2. **Testing**: Runs unit and integration tests
3. **Security Scanning**: Checks for vulnerabilities
4. **Docker Build**: Builds multi-platform images
5. **Container Scanning**: Scans Docker images for vulnerabilities

### Production Deployment

For production deployment:

1. Tag a release: \`git tag v1.0.0 && git push --tags\`
2. GitHub Actions will automatically:
   - Run all tests and checks
   - Build and push Docker images
   - Create a GitHub release
   - Publish to PyPI (if configured)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Code Style

- We use \`black\` for code formatting
- We use \`ruff\` for linting
- We use \`mypy\` for type checking
- All code must have type hints
- All code must have docstrings
- All code must have tests

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [FastAPI](https://fastapi.tiangolo.com/)
- Containerized with [Docker](https://www.docker.com/)
- CI/CD with [GitHub Actions](https://github.com/features/actions)
$(if [[ "$ai_ready" == "true" ]]; then echo "- AI powered by [OpenAI](https://openai.com/) and [Anthropic](https://anthropic.com/)"; fi)

---

Made with ❤️ by $github_username
EOF

  # Create .gitignore
  cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
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

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml

# Project specific
*.db
logs/
temp/
EOF

  # Create pyproject.toml with modern Python packaging
  cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=65", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "A Python API project with Docker support"
readme = "README.md"
requires-python = ">=3.11"
license = {text = "MIT"}
authors = [
    {name = "$github_username"},
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "fastapi>=0.109.0",
    "uvicorn[standard]>=0.27.0",
    "pydantic>=2.5.0",
    "pydantic-settings>=2.1.0",
    "python-dotenv>=1.0.0",
    "httpx>=0.26.0",
    "structlog>=24.1.0",
    "prometheus-client>=0.19.0",
$(if [[ "$ai_ready" == "true" ]]; then echo '    "openai>=1.10.0",
    "anthropic>=0.18.0",
    "langchain>=0.1.0",
    "tiktoken>=0.5.0",'; fi)
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "pytest-asyncio>=0.23.0",
    "pytest-env>=1.1.0",
    "black>=23.12.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
    "pre-commit>=3.6.0",
    "httpx>=0.26.0",
    "faker>=22.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
pythonpath = ["src"]
addopts = [
    "--strict-markers",
    "--tb=short",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-report=xml",
    "--cov-fail-under=80",
]
env = [
    "APP_ENV=testing",
]

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
precision = 2
show_missing = true
skip_covered = false

[tool.black]
line-length = 88
target-version = ["py311"]
include = '\\.pyi?$'

[tool.ruff]
target-version = "py311"
line-length = 88
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (handled by black)
    "B008",  # do not perform function calls in argument defaults
]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = false
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_optional = true
ignore_missing_imports = true
EOF

  # Create Makefile
  cat > Makefile << 'EOF'
.PHONY: help install install-dev dev test lint format clean docker-build docker-up docker-down docker-test

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
APP_NAME := $(shell grep '^name = ' pyproject.toml | cut -d'"' -f2)
VERSION := $(shell grep '^version = ' pyproject.toml | cut -d'"' -f2)

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install production dependencies
	$(PIP) install -e .

install-dev: ## Install development dependencies
	$(PIP) install -e ".[dev]"
	pre-commit install

dev: ## Run development server
	uvicorn src.main:app --reload --host 0.0.0.0 --port 8000

test: ## Run tests with coverage
	pytest

lint: ## Run linting checks
	ruff check src tests
	mypy src
	black --check src tests

format: ## Format code
	black src tests
	ruff check --fix src tests

clean: ## Clean build artifacts
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf build dist *.egg-info
	rm -rf .coverage htmlcov coverage.xml
	rm -rf .pytest_cache .mypy_cache .ruff_cache

docker-build: ## Build Docker image
	docker build -t $(APP_NAME):$(VERSION) -t $(APP_NAME):latest .

docker-up: ## Start services with Docker Compose
	docker-compose up -d

docker-down: ## Stop Docker services
	docker-compose down

docker-test: ## Run tests in Docker
	docker-compose run --rm app pytest

docker-logs: ## Show Docker logs
	docker-compose logs -f
EOF

  # Create Dockerfile with multi-stage build
  cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1

# Build stage
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy dependency files
COPY pyproject.toml ./
COPY src ./src

# Install dependencies and build wheel
RUN pip install --no-cache-dir build && \
    python -m build --wheel

# Runtime stage
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy wheel from builder
COPY --from=builder /build/dist/*.whl /tmp/

# Install the application
RUN pip install --no-cache-dir /tmp/*.whl && \
    rm -rf /tmp/*.whl

# Copy application code
COPY src ./src

# Create necessary directories and set permissions
RUN mkdir -p /app/logs && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Run the application
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

  # Create docker-compose.yml
  cat > docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: ${project_name}:latest
    container_name: ${project_name}_app
    ports:
      - "8000:8000"
    environment:
      - APP_ENV=development
      - LOG_LEVEL=debug
    env_file:
      - .env
    volumes:
      - ./src:/app/src:ro
      - ./logs:/app/logs
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Add Redis for caching (optional)
  redis:
    image: redis:7-alpine
    container_name: ${project_name}_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped
    command: redis-server --appendonly yes

volumes:
  redis_data:
EOF

  # Create .dockerignore
  cat > .dockerignore << 'EOF'
# Git
.git/
.gitignore

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Project
*.log
.env
.env.*
!.env.example
docker-compose.override.yml
Makefile
README.md
docs/
tests/
scripts/
.github/
.pre-commit-config.yaml
EOF

  # Create main application file
  cat > src/main.py << EOF
"""Main application entry point."""

import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import make_asgi_app
import structlog

from src.core.config import settings
from src.core.logging import configure_logging
from src.api import health, v1

# Configure structured logging
configure_logging()
logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle application lifecycle."""
    logger.info("Starting application", app_name=settings.APP_NAME, environment=settings.APP_ENV)
    yield
    logger.info("Shutting down application")


# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Add Prometheus metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Include routers
app.include_router(health.router, tags=["health"])
app.include_router(v1.router, prefix="/api/v1")


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "version": "0.1.0",
        "docs": "/docs",
    }
EOF

  # Create core configuration
  mkdir -p src/core
  cat > src/core/__init__.py << 'EOF'
"""Core application modules."""
EOF

  cat > src/core/config.py << EOF
"""Application configuration."""

from functools import lru_cache
from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )
    
    # Application
    APP_NAME: str = "$project_name"
    APP_ENV: str = "development"
    DEBUG: bool = True
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_WORKERS: int = 1
    
    # Logging
    LOG_LEVEL: str = "info"
    LOG_FORMAT: str = "json"  # json or text
    
    # Redis (optional)
    REDIS_URL: Optional[str] = None
    
$(if [[ "$ai_ready" == "true" ]]; then echo '    # AI/ML Configuration
    OPENAI_API_KEY: Optional[str] = None
    ANTHROPIC_API_KEY: Optional[str] = None
    MODEL_NAME: str = "gpt-4"
    MAX_TOKENS: int = 1000
    TEMPERATURE: float = 0.7
    
    # Prompt configuration
    SYSTEM_PROMPT: Optional[str] = None
    PROMPT_TEMPLATE_DIR: str = "prompts"'; fi)


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
EOF

  # Create logging configuration
  cat > src/core/logging.py << 'EOF'
"""Logging configuration."""

import logging
import sys

import structlog


def configure_logging():
    """Configure structured logging."""
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer(),
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
    
    # Configure standard logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=logging.INFO,
    )
EOF

  # Create API structure
  mkdir -p src/api/v1
  cat > src/api/__init__.py << 'EOF'
"""API modules."""

from . import health, v1

__all__ = ["health", "v1"]
EOF

  cat > src/api/health.py << 'EOF'
"""Health check endpoints."""

from fastapi import APIRouter, status
from pydantic import BaseModel

router = APIRouter()


class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    service: str


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
)
async def health_check() -> HealthResponse:
    """Health check endpoint."""
    return HealthResponse(status="healthy", service="api")


@router.get("/ready")
async def readiness_check():
    """Readiness check endpoint."""
    # Add any readiness checks here (database, external services, etc.)
    return {"status": "ready"}
EOF

  cat > src/api/v1/__init__.py << EOF
"""API v1 module."""

from fastapi import APIRouter

from . import examples

router = APIRouter()
router.include_router(examples.router, prefix="/examples", tags=["examples"])
EOF

  cat > src/api/v1/examples.py << EOF
"""Example API endpoints."""

from typing import List

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
import structlog

router = APIRouter()
logger = structlog.get_logger()


class ExampleRequest(BaseModel):
    """Example request model."""
    name: str
    description: str


class ExampleResponse(BaseModel):
    """Example response model."""
    id: int
    name: str
    description: str


# In-memory storage for examples
examples_db: List[ExampleResponse] = []


@router.get("/", response_model=List[ExampleResponse])
async def get_examples():
    """Get all examples."""
    logger.info("Fetching all examples", count=len(examples_db))
    return examples_db


@router.post("/", response_model=ExampleResponse, status_code=status.HTTP_201_CREATED)
async def create_example(example: ExampleRequest):
    """Create a new example."""
    example_id = len(examples_db) + 1
    new_example = ExampleResponse(
        id=example_id,
        name=example.name,
        description=example.description,
    )
    examples_db.append(new_example)
    logger.info("Created example", example_id=example_id, name=example.name)
    return new_example


@router.get("/{example_id}", response_model=ExampleResponse)
async def get_example(example_id: int):
    """Get a specific example."""
    for example in examples_db:
        if example.id == example_id:
            return example
    
    logger.warning("Example not found", example_id=example_id)
    raise HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=f"Example with id {example_id} not found",
    )
EOF

  # Create tests
  cat > tests/__init__.py << 'EOF'
"""Test package."""
EOF

  cat > tests/conftest.py << 'EOF'
"""Pytest configuration and fixtures."""

import pytest
from fastapi.testclient import TestClient

from src.main import app


@pytest.fixture
def client():
    """Create test client."""
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def mock_example_data():
    """Mock example data."""
    return {
        "name": "Test Example",
        "description": "This is a test example",
    }
EOF

  cat > tests/test_health.py << 'EOF'
"""Test health endpoints."""

import pytest
from fastapi import status


def test_health_check(client):
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "api"


def test_readiness_check(client):
    """Test readiness check endpoint."""
    response = client.get("/ready")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["status"] == "ready"
EOF

  cat > tests/test_examples.py << 'EOF'
"""Test example endpoints."""

import pytest
from fastapi import status


def test_get_examples_empty(client):
    """Test getting examples when none exist."""
    response = client.get("/api/v1/examples/")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == []


def test_create_example(client, mock_example_data):
    """Test creating an example."""
    response = client.post("/api/v1/examples/", json=mock_example_data)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["id"] == 1
    assert data["name"] == mock_example_data["name"]
    assert data["description"] == mock_example_data["description"]


def test_get_example(client, mock_example_data):
    """Test getting a specific example."""
    # Create an example first
    create_response = client.post("/api/v1/examples/", json=mock_example_data)
    example_id = create_response.json()["id"]
    
    # Get the example
    response = client.get(f"/api/v1/examples/{example_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == example_id
    assert data["name"] == mock_example_data["name"]


def test_get_example_not_found(client):
    """Test getting a non-existent example."""
    response = client.get("/api/v1/examples/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
EOF

  # Create GitHub Actions workflow
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  PYTHON_VERSION: '3.11'
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"
      
      - name: Run black
        run: black --check src tests
      
      - name: Run ruff
        run: ruff check src tests
      
      - name: Run mypy
        run: mypy src

  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"
      
      - name: Run tests with coverage
        run: pytest
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

  build:
    name: Build Docker Image
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  integration-test:
    name: Integration Test
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Docker Compose tests
        run: |
          docker-compose run --rm app pytest
      
      - name: Test health endpoint
        run: |
          docker-compose up -d
          sleep 10
          curl -f http://localhost:8000/health || exit 1
          docker-compose down
EOF

  # Create pre-commit configuration
  cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.11
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]
EOF

  # Create .env.example
  cat > .env.example << EOF
# Application
APP_NAME=$project_name
APP_ENV=development
DEBUG=true
LOG_LEVEL=info

# API
API_HOST=0.0.0.0
API_PORT=8000
API_WORKERS=1

# Redis (optional)
REDIS_URL=redis://localhost:6379/0

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML Configuration
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
MODEL_NAME=gpt-4
MAX_TOKENS=1000
TEMPERATURE=0.7"; fi)
EOF

  # Copy .env.example to .env
  cp .env.example .env

  # Create additional directories and files for AI-ready projects
  if [[ "$ai_ready" == "true" ]]; then
    mkdir -p src/ai prompts
    
    # Create AI service module
    cat > src/ai/__init__.py << 'EOF'
"""AI/ML modules."""
EOF

    cat > src/ai/llm.py << 'EOF'
"""LLM integration module."""

from typing import Optional, List, Dict, Any
import os
from functools import lru_cache

import structlog
from openai import AsyncOpenAI
from anthropic import AsyncAnthropic

from src.core.config import settings

logger = structlog.get_logger()


class LLMService:
    """Service for interacting with LLMs."""
    
    def __init__(self):
        """Initialize LLM service."""
        self.openai_client = None
        self.anthropic_client = None
        
        if settings.OPENAI_API_KEY:
            self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        
        if settings.ANTHROPIC_API_KEY:
            self.anthropic_client = AsyncAnthropic(api_key=settings.ANTHROPIC_API_KEY)
    
    async def complete(
        self,
        prompt: str,
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None,
    ) -> str:
        """Get completion from LLM."""
        model = model or settings.MODEL_NAME
        max_tokens = max_tokens or settings.MAX_TOKENS
        temperature = temperature or settings.TEMPERATURE
        
        logger.info(
            "Generating completion",
            model=model,
            prompt_length=len(prompt),
            max_tokens=max_tokens,
        )
        
        try:
            if model.startswith("gpt") and self.openai_client:
                return await self._openai_complete(
                    prompt, system_prompt, model, max_tokens, temperature
                )
            elif model.startswith("claude") and self.anthropic_client:
                return await self._anthropic_complete(
                    prompt, system_prompt, model, max_tokens, temperature
                )
            else:
                raise ValueError(f"Unsupported model: {model}")
        except Exception as e:
            logger.error("LLM completion failed", error=str(e), model=model)
            raise
    
    async def _openai_complete(
        self,
        prompt: str,
        system_prompt: Optional[str],
        model: str,
        max_tokens: int,
        temperature: float,
    ) -> str:
        """Get completion from OpenAI."""
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        messages.append({"role": "user", "content": prompt})
        
        response = await self.openai_client.chat.completions.create(
            model=model,
            messages=messages,
            max_tokens=max_tokens,
            temperature=temperature,
        )
        
        return response.choices[0].message.content
    
    async def _anthropic_complete(
        self,
        prompt: str,
        system_prompt: Optional[str],
        model: str,
        max_tokens: int,
        temperature: float,
    ) -> str:
        """Get completion from Anthropic."""
        message = await self.anthropic_client.messages.create(
            model=model,
            max_tokens=max_tokens,
            temperature=temperature,
            system=system_prompt,
            messages=[{"role": "user", "content": prompt}],
        )
        
        return message.content[0].text


@lru_cache()
def get_llm_service() -> LLMService:
    """Get cached LLM service instance."""
    return LLMService()
EOF

    cat > src/ai/prompts.py << 'EOF'
"""Prompt management module."""

import os
from typing import Dict, Any, Optional
from pathlib import Path

import structlog
from jinja2 import Environment, FileSystemLoader, select_autoescape

from src.core.config import settings

logger = structlog.get_logger()


class PromptManager:
    """Manage prompt templates."""
    
    def __init__(self, template_dir: Optional[str] = None):
        """Initialize prompt manager."""
        self.template_dir = template_dir or settings.PROMPT_TEMPLATE_DIR
        self.env = Environment(
            loader=FileSystemLoader(self.template_dir),
            autoescape=select_autoescape(['html', 'xml']),
            trim_blocks=True,
            lstrip_blocks=True,
        )
    
    def load_prompt(self, template_name: str, **kwargs) -> str:
        """Load and render a prompt template."""
        try:
            template = self.env.get_template(f"{template_name}.j2")
            return template.render(**kwargs)
        except Exception as e:
            logger.error(
                "Failed to load prompt template",
                template=template_name,
                error=str(e),
            )
            raise
    
    def list_prompts(self) -> list[str]:
        """List available prompt templates."""
        template_path = Path(self.template_dir)
        return [
            f.stem for f in template_path.glob("*.j2")
        ]


def get_prompt_manager() -> PromptManager:
    """Get prompt manager instance."""
    return PromptManager()
EOF

    # Create example prompt template
    cat > prompts/example.j2 << 'EOF'
You are a helpful AI assistant for {{ app_name }}.

{% if context %}
Context:
{{ context }}
{% endif %}

User Query: {{ query }}

Please provide a helpful and accurate response.
EOF
  fi

  # Create GitHub dependabot configuration
  mkdir -p .github
  cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
EOF

  # Add all project files and commit on feature branch
  git add .
  git commit -m "feat: Add Python Docker API project with comprehensive setup

- FastAPI application with async support
- Multi-stage Docker build for production
- GitHub Actions CI/CD pipeline
- pytest with coverage reporting
- Pre-commit hooks and code quality tools
- Structured logging and health checks
$(if [[ "$ai_ready" == "true" ]]; then echo "- AI/ML integrations with OpenAI and Anthropic"; fi)"
  
  # Push feature branch to GitHub if remote exists
  if git remote get-url origin &>/dev/null; then
    echo "Pushing feature branch to GitHub..."
    git push -u origin feat/initial-setup
    
    # Create PR if gh CLI is available
    if command_exists gh; then
      echo "Creating pull request..."
      gh pr create \
        --title "feat: Initial Python Docker API project setup" \
        --body "## Description

This PR contains the initial project setup for $project_name with:

### Features
- ✅ FastAPI framework with async support
- ✅ Multi-stage Docker builds for minimal production images
- ✅ Comprehensive GitHub Actions CI/CD pipeline
- ✅ Testing setup with pytest and coverage reporting
- ✅ Code quality tools (black, ruff, mypy, pre-commit)
- ✅ Structured logging and monitoring
- ✅ API documentation with Swagger/ReDoc
$(if [[ "$ai_ready" == "true" ]]; then echo "- ✅ AI/ML integrations with prompt management"; fi)

### Infrastructure
- Docker and Docker Compose configuration
- GitHub Actions workflows for testing and deployment
- Security scanning with Trivy, bandit, and safety
- Multi-platform Docker image builds

### Development Experience
- Makefile for common commands
- Pre-commit hooks for code quality
- Comprehensive README with setup instructions
- Environment-based configuration

## Testing
- Run \`make test\` for unit tests
- Run \`make docker-test\` for containerized tests
- All tests should pass before merging

## Next Steps
After merging, developers can:
1. Clone the repository
2. Run \`make install-dev\` to set up the development environment
3. Run \`make dev\` to start the development server
4. Access API docs at http://localhost:8000/docs" \
        --base main
    fi
  else
    echo ""
    echo "To push to GitHub later:"
    echo "1. Create a repository on GitHub"
    echo "2. Add remote: git remote add origin https://github.com/$github_username/$project_name.git"
    echo "3. Push: git push -u origin main && git push -u origin feat/initial-setup"
  fi
  
  log_success "Python Docker API project '$project_name' created successfully!"
  echo ""
  echo "Next steps:"
  echo "1. cd $project_name"
  echo "2. Review and update .env file with your configuration"
  echo "3. Run 'make install-dev' to install development dependencies"
  echo "4. Run 'make dev' to start the development server"
  echo "5. Run 'make docker-up' to start with Docker"
  echo ""
  echo "For more commands, run: make help"
}

_setup_python_docker_cli() {
  local project_name="$1"
  local ai_ready="$2"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python docker"; then
    return 1
  fi
  
  echo "🚀 Setting up Python Docker CLI project: $project_name"
  if [[ "$ai_ready" == "true" ]]; then
    echo "   Including AI/ML dependencies and patterns"
  fi
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Create an initial empty README.md
  echo "# $project_name" > README.md
  git add README.md
  git commit -m "Initial commit"
  
  # Check if the repository already exists
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Please choose a different name."
    cd ..
    rm -rf "$project_name"
    return 1
  elif command_exists gh; then
    # Create a new GitHub repository
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private --source=. --remote=origin --push
    
    # Create and checkout feature branch
    git checkout -b feat/initial-setup
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "To create a GitHub repository, install gh CLI: https://cli.github.com/"
    
    # Create and checkout feature branch
    git checkout -b feat/initial-setup
  fi
  
  # Create project structure
  mkdir -p src tests docs scripts
  mkdir -p src/commands src/core src/utils
  
  # Create comprehensive README.md
  cat > README.md << EOF
# $project_name

A Python CLI application with Docker support, comprehensive CI/CD, and production-ready architecture.

## 🚀 Features

- **Framework**: Click framework with rich terminal output and interactive prompts
- **Container**: Multi-stage Docker builds for minimal, secure images
- **CI/CD**: GitHub Actions with automated testing, releases, and multi-platform builds
- **Testing**: pytest with coverage reporting and CLI command testing
- **Code Quality**: Pre-commit hooks with black, ruff, mypy for consistent code
- **Distribution**: Installable via pip, Docker, or standalone executables
- **Configuration**: Flexible config via environment variables or YAML files
- **Documentation**: Auto-generated help text and command documentation
$(if [[ "$ai_ready" == "true" ]]; then echo "- **AI/ML Ready**: OpenAI/Anthropic integrations for AI-powered commands"; fi)

## 📋 Prerequisites

- Python 3.11 or higher
- Docker (optional, for containerized distribution)
- Make (optional but recommended)
- GitHub CLI (optional, for repository creation)

## 🏃‍♂️ Quick Start

### Installation Options

#### Via pip (Recommended)

\`\`\`bash
pip install $project_name
\`\`\`

#### Via Docker

\`\`\`bash
# Pull the latest image
docker pull ghcr.io/$github_username/${project_name}:latest

# Run with Docker
docker run --rm -it ghcr.io/$github_username/${project_name}:latest --help
\`\`\`

#### From Source

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install in development mode
pip install -e .
\`\`\`

## 📖 Usage

### Basic Commands

\`\`\`bash
# Show help and available commands
$project_name --help

# Show version information
$project_name version --full

# Run the hello command
$project_name hello --name "Your Name" --color cyan

# List all available commands
$project_name list-commands
\`\`\`

### Docker Usage

\`\`\`bash
# Run with Docker (using alias for convenience)
alias ${project_name}="docker run --rm -it ghcr.io/$github_username/${project_name}:latest"

# Now use normally
$project_name hello --name Docker

# Mount local files if needed
docker run --rm -it -v \$(pwd):/data ghcr.io/$github_username/${project_name}:latest process /data/input.txt
\`\`\`

### Configuration

\`\`\`bash
# Via environment variables
export ${project_name^^}_LOG_LEVEL=debug
export ${project_name^^}_LOG_FORMAT=text
$project_name hello

# Via config file
$project_name --config config.yaml hello
\`\`\`

$(if [[ "$ai_ready" == "true" ]]; then echo "### AI-Powered Commands

\`\`\`bash
# Get AI completion
$project_name ai complete -p \"Explain quantum computing\" -t 0.7

# Analyze a file with AI
$project_name ai analyze -f document.txt -q \"What are the key points?\"

# Configure AI settings via environment
export ${project_name^^}_OPENAI_API_KEY=sk-...
export ${project_name^^}_MODEL_NAME=gpt-4
\`\`\`"; fi)

## 🐳 Docker Commands

\`\`\`bash
# Build Docker image locally
make docker-build

# Run with custom arguments
make docker-run ARGS="hello --name Developer"

# Open shell in container for debugging
make docker-shell

# Push to registry
docker tag ${project_name}:latest ghcr.io/$github_username/${project_name}:latest
docker push ghcr.io/$github_username/${project_name}:latest
\`\`\`

## 🧪 Testing

\`\`\`bash
# Run all tests with coverage
make test

# Run specific test file
pytest tests/test_cli.py -v

# Run with different Python versions
tox

# Test the Docker image
docker run --rm ${project_name}:latest version --full
\`\`\`

## 🛠️ Development

### Setup Development Environment

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate

# Install in development mode with all dependencies
make install-dev

# Setup pre-commit hooks
pre-commit install
\`\`\`

### Development Workflow

1. **Create Feature Branch**: \`git checkout -b feature/new-command\`
2. **Add New Command**: Create file in \`src/commands/\`
3. **Write Tests**: Add tests in \`tests/\`
4. **Run Tests**: \`make test\`
5. **Format Code**: \`make format\`
6. **Lint**: \`make lint\`
7. **Commit**: Use conventional commits
8. **Push**: Create pull request

### Adding a New Command

1. Create command file \`src/commands/mycommand.py\`:

\`\`\`python
import click
from rich.console import Console

console = Console()

@click.command()
@click.option("--name", default="World", help="Name to greet")
def mycommand(name):
    \"\"\"My new command description.\"\"\"
    console.print(f"Hello from mycommand, {name}!")
\`\`\`

2. Register in \`src/cli.py\`:

\`\`\`python
from src.commands import mycommand

cli.add_command(mycommand.mycommand)
\`\`\`

3. Add tests in \`tests/test_mycommand.py\`

## 📁 Project Structure

\`\`\`
$project_name/
├── src/                      # Application source code
│   ├── __main__.py          # Entry point for python -m
│   ├── cli.py               # CLI application definition
│   ├── commands/            # CLI command implementations
│   │   ├── hello.py         # Example hello command
│   │   └── version.py       # Version information command
│   ├── core/                # Core functionality
│   │   ├── config.py        # Configuration management
│   │   └── logging.py       # Logging setup
│   └── utils/               # Utility functions
├── tests/                   # Test suite
│   ├── test_cli.py         # CLI tests
│   └── conftest.py         # Test configuration
├── scripts/                 # Utility scripts
├── .github/                 # GitHub configuration
│   └── workflows/          # CI/CD pipelines
│       └── ci.yml          # Main CI workflow
├── Dockerfile              # Multi-stage Docker build
├── Makefile               # Development commands
├── pyproject.toml         # Package configuration
├── .pre-commit-config.yaml # Code quality hooks
└── README.md              # This file
\`\`\`

## ⚙️ Configuration

### Configuration Hierarchy

1. Command line arguments (highest priority)
2. Environment variables
3. Configuration file
4. Default values (lowest priority)

### Environment Variables

\`\`\`bash
# Application settings
${project_name^^}_DEBUG=true           # Enable debug mode
${project_name^^}_LOG_LEVEL=info       # Log level: debug, info, warning, error
${project_name^^}_LOG_FORMAT=text      # Log format: text or json
${project_name^^}_CONFIG_FILE=config.yaml  # Path to config file

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML settings
${project_name^^}_OPENAI_API_KEY=sk-...     # OpenAI API key
${project_name^^}_ANTHROPIC_API_KEY=sk-...  # Anthropic API key
${project_name^^}_MODEL_NAME=gpt-4         # Model to use
${project_name^^}_MAX_TOKENS=1000          # Max tokens for completion
${project_name^^}_TEMPERATURE=0.7          # Temperature (0.0-2.0)"; fi)
\`\`\`

### Configuration File (config.yaml)

\`\`\`yaml
# Application configuration
log_level: info
log_format: text
debug: false

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML configuration
openai_api_key: sk-...
anthropic_api_key: sk-...
model_name: gpt-4
max_tokens: 1000
temperature: 0.7

# Prompt templates directory
prompt_template_dir: prompts"; fi)
\`\`\`

$(if [[ "$ai_ready" == "true" ]]; then echo "## 🤖 AI/ML Features

### AI Command Examples

\`\`\`bash
# Get AI completion with custom parameters
$project_name ai complete \\
  --prompt \"Write a haiku about Python\" \\
  --model gpt-4 \\
  --temperature 0.9

# Analyze a file
$project_name ai analyze \\
  --file code.py \\
  --question \"What does this code do?\"

# Use with system prompt
$project_name ai complete \\
  --prompt \"Explain Docker\" \\
  --system \"You are a DevOps expert. Be concise.\"
\`\`\`

### Prompt Engineering Best Practices

1. **Clear Instructions**: Be specific about what you want
2. **Context Setting**: Use system prompts to set behavior
3. **Temperature Tuning**:
   - 0.0-0.3: Deterministic, factual responses
   - 0.7-1.0: Creative, varied responses
4. **Output Formatting**: Request specific formats (JSON, markdown, etc.)
5. **Error Handling**: Always handle API failures gracefully
6. **Token Management**: Monitor usage to control costs
7. **Response Validation**: Verify AI outputs before using them

### Creating Custom AI Commands

\`\`\`python
from src.ai.llm import get_llm_service
import click

@click.command()
@click.option(\"--input\", required=True)
async def translate(input):
    \"\"\"Translate text using AI.\"\"\"
    llm = get_llm_service()
    
    prompt = f\"Translate to Spanish: {input}\"
    result = await llm.complete(prompt, temperature=0.3)
    
    click.echo(f\"Translation: {result}\")
\`\`\`"; fi)

## 🔧 Make Commands

\`\`\`bash
make help         # Show all available commands
make install      # Install production dependencies
make install-dev  # Install with development dependencies
make test         # Run tests with coverage
make lint         # Run code quality checks
make format       # Auto-format code
make clean        # Remove build artifacts
make docker-build # Build Docker image
make docker-run   # Run CLI in Docker
make docker-shell # Open shell in Docker
\`\`\`

## 🚀 Publishing & Distribution

### PyPI Release

1. Update version in \`pyproject.toml\`
2. Create git tag: \`git tag v1.0.0\`
3. Push tag: \`git push origin v1.0.0\`
4. GitHub Actions will automatically publish to PyPI

### Docker Distribution

The CI/CD pipeline automatically:
- Builds multi-platform images (amd64, arm64)
- Pushes to GitHub Container Registry
- Tags with version and latest

### Standalone Executables

Consider using PyInstaller for standalone executables:

\`\`\`bash
pip install pyinstaller
pyinstaller --onefile --name $project_name src/__main__.py
\`\`\`

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

### Code Style

- **Formatting**: black (line length 88)
- **Linting**: ruff
- **Type Checking**: mypy with strict mode
- **Docstrings**: Google style
- **Commits**: Conventional commits (feat:, fix:, docs:, etc.)

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Built with [Click](https://click.palletsprojects.com/)
- Terminal UI with [Rich](https://rich.readthedocs.io/)
- Containerized with [Docker](https://www.docker.com/)
- CI/CD with [GitHub Actions](https://github.com/features/actions)
$(if [[ "$ai_ready" == "true" ]]; then echo "- AI powered by [OpenAI](https://openai.com/) and [Anthropic](https://anthropic.com/)"; fi)

---

Made with ❤️ by $github_username
EOF

  # Create .gitignore (same as API project)
  cat > .gitignore << 'EOF'
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
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

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
.pybuilder/
target/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# pipenv
Pipfile.lock

# poetry
poetry.lock

# pdm
.pdm.toml

# PEP 582
__pypackages__/

# Celery stuff
celerybeat-schedule
celerybeat.pid

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# Pyre type checker
.pyre/

# pytype static type analyzer
.pytype/

# Cython debug symbols
cython_debug/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml

# Project specific
*.db
logs/
temp/
config.yaml
EOF

  # Create pyproject.toml for CLI
  cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools>=65", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "$project_name"
version = "0.1.0"
description = "A Python CLI application with Docker support"
readme = "README.md"
requires-python = ">=3.11"
license = {text = "MIT"}
authors = [
    {name = "$github_username"},
]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Environment :: Console",
]
dependencies = [
    "click>=8.1.0",
    "rich>=13.7.0",
    "pydantic>=2.5.0",
    "pydantic-settings>=2.1.0",
    "python-dotenv>=1.0.0",
    "pyyaml>=6.0",
    "structlog>=24.1.0",
$(if [[ "$ai_ready" == "true" ]]; then echo '    "openai>=1.10.0",
    "anthropic>=0.18.0",
    "tiktoken>=0.5.0",'; fi)
]

[project.scripts]
$project_name = "src.__main__:main"

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "pytest-mock>=3.12.0",
    "black>=23.12.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
    "pre-commit>=3.6.0",
    "faker>=22.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
pythonpath = ["src"]
addopts = [
    "--strict-markers",
    "--tb=short",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-report=xml",
    "--cov-fail-under=80",
]

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py", "*/__main__.py"]

[tool.coverage.report]
precision = 2
show_missing = true
skip_covered = false

[tool.black]
line-length = 88
target-version = ["py311"]
include = '\\.pyi?$'

[tool.ruff]
target-version = "py311"
line-length = 88
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (handled by black)
    "B008",  # do not perform function calls in argument defaults
]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = false
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_optional = true
ignore_missing_imports = true
EOF

  # Create Makefile
  cat > Makefile << 'EOF'
.PHONY: help install install-dev test lint format clean docker-build docker-run

# Default target
.DEFAULT_GOAL := help

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
APP_NAME := $(shell grep '^name = ' pyproject.toml | cut -d'"' -f2)
VERSION := $(shell grep '^version = ' pyproject.toml | cut -d'"' -f2)
ARGS ?= --help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Install production dependencies
	$(PIP) install -e .

install-dev: ## Install development dependencies
	$(PIP) install -e ".[dev]"
	pre-commit install

test: ## Run tests with coverage
	pytest

lint: ## Run linting checks
	ruff check src tests
	mypy src
	black --check src tests

format: ## Format code
	black src tests
	ruff check --fix src tests

clean: ## Clean build artifacts
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf build dist *.egg-info
	rm -rf .coverage htmlcov coverage.xml
	rm -rf .pytest_cache .mypy_cache .ruff_cache

docker-build: ## Build Docker image
	docker build -t $(APP_NAME):$(VERSION) -t $(APP_NAME):latest .

docker-run: ## Run CLI in Docker
	docker run --rm -it $(APP_NAME):latest $(ARGS)

docker-shell: ## Open shell in Docker container
	docker run --rm -it --entrypoint /bin/sh $(APP_NAME):latest
EOF

  # Create Dockerfile for CLI
  cat > Dockerfile << 'EOF'
# syntax=docker/dockerfile:1

# Build stage
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy dependency files
COPY pyproject.toml ./
COPY src ./src

# Install dependencies and build wheel
RUN pip install --no-cache-dir build && \
    python -m build --wheel

# Runtime stage
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy wheel from builder
COPY --from=builder /build/dist/*.whl /tmp/

# Install the application
RUN pip install --no-cache-dir /tmp/*.whl && \
    rm -rf /tmp/*.whl

# Copy any additional files if needed
COPY --chown=appuser:appuser scripts ./scripts

# Switch to non-root user
USER appuser

# Set entrypoint to the CLI command
ENTRYPOINT ["python", "-m", "src"]
CMD ["--help"]
EOF

  # Create .dockerignore (same as API)
  cat > .dockerignore << 'EOF'
# Git
.git/
.gitignore

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv/
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Project
*.log
.env
.env.*
!.env.example
docker-compose.override.yml
Makefile
README.md
docs/
tests/
scripts/
.github/
.pre-commit-config.yaml
EOF

  # Create CLI entry point
  cat > src/__main__.py << 'EOF'
"""CLI entry point."""

import sys
from .cli import cli


def main():
    """Main entry point."""
    cli()


if __name__ == "__main__":
    main()
EOF

  # Create CLI definition
  cat > src/cli.py << EOF
"""CLI application definition."""

import click
from rich.console import Console
from rich.table import Table
import structlog

from src.core.config import settings
from src.commands import hello, version

# Configure logging
from src.core.logging import configure_logging
configure_logging()

logger = structlog.get_logger()
console = Console()


@click.group()
@click.option(
    "--debug/--no-debug",
    default=False,
    help="Enable debug mode.",
)
@click.option(
    "--config",
    type=click.Path(exists=True),
    help="Path to configuration file.",
)
@click.pass_context
def cli(ctx, debug, config):
    """$project_name - A Python CLI application."""
    ctx.ensure_object(dict)
    ctx.obj["debug"] = debug
    ctx.obj["config"] = config
    
    if debug:
        logger.info("Debug mode enabled")
    
    if config:
        logger.info("Loading config", path=config)
        settings.load_config(config)


# Register commands
cli.add_command(hello.hello)
cli.add_command(version.version)


@cli.command()
def list_commands():
    """List all available commands."""
    table = Table(title="Available Commands")
    table.add_column("Command", style="cyan")
    table.add_column("Description", style="green")
    
    for name, command in cli.commands.items():
        table.add_row(name, command.help or "")
    
    console.print(table)
EOF

  # Create core modules
  mkdir -p src/core
  cat > src/core/__init__.py << 'EOF'
"""Core modules."""
EOF

  cat > src/core/config.py << EOF
"""Application configuration."""

import os
from pathlib import Path
from typing import Optional, Dict, Any

import yaml
from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    # Application
    app_name: str = "$project_name"
    debug: bool = False
    
    # Logging
    log_level: str = "info"
    log_format: str = "text"  # text or json
    
    # Config file
    config_file: Optional[str] = None
    
$(if [[ "$ai_ready" == "true" ]]; then echo '    # AI/ML Configuration
    openai_api_key: Optional[str] = None
    anthropic_api_key: Optional[str] = None
    model_name: str = "gpt-4"
    max_tokens: int = 1000
    temperature: float = 0.7'; fi)
    
    class Config:
        env_prefix = "${project_name^^}_"
        env_file = ".env"
        env_file_encoding = "utf-8"
    
    def load_config(self, config_path: str):
        """Load configuration from YAML file."""
        with open(config_path, "r") as f:
            config_data = yaml.safe_load(f)
        
        for key, value in config_data.items():
            if hasattr(self, key):
                setattr(self, key, value)


settings = Settings()
EOF

  cat > src/core/logging.py << 'EOF'
"""Logging configuration."""

import logging
import sys

import structlog


def configure_logging():
    """Configure structured logging."""
    processors = [
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
    ]
    
    # Use console renderer for text format
    from src.core.config import settings
    if settings.log_format == "json":
        processors.append(structlog.processors.JSONRenderer())
    else:
        processors.append(structlog.dev.ConsoleRenderer())
    
    structlog.configure(
        processors=processors,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )
    
    # Configure standard logging
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=getattr(logging, settings.log_level.upper()),
    )
EOF

  # Create commands
  mkdir -p src/commands
  cat > src/commands/__init__.py << 'EOF'
"""CLI commands."""

from . import hello, version

__all__ = ["hello", "version"]
EOF

  cat > src/commands/hello.py << 'EOF'
"""Hello command."""

import click
from rich.console import Console
from rich.panel import Panel
from rich.text import Text

console = Console()


@click.command()
@click.option(
    "--name",
    default="World",
    help="Name to greet.",
)
@click.option(
    "--color",
    default="cyan",
    help="Color for the greeting.",
)
def hello(name, color):
    """Say hello to someone."""
    greeting = Text(f"Hello, {name}! 👋", style=f"bold {color}")
    panel = Panel(
        greeting,
        title="Greeting",
        border_style=color,
        padding=(1, 2),
    )
    console.print(panel)
EOF

  cat > src/commands/version.py << EOF
"""Version command."""

import click
from rich.console import Console
from rich.table import Table
import platform
import sys

console = Console()


@click.command()
@click.option(
    "--full",
    is_flag=True,
    help="Show full version information.",
)
def version(full):
    """Show version information."""
    from src.core.config import settings
    
    if not full:
        console.print(f"$project_name version 0.1.0")
        return
    
    table = Table(title="Version Information")
    table.add_column("Component", style="cyan")
    table.add_column("Version", style="green")
    
    table.add_row("Application", "0.1.0")
    table.add_row("Python", sys.version.split()[0])
    table.add_row("Platform", platform.platform())
    table.add_row("Click", click.__version__)
    
    console.print(table)
EOF

  # Create tests
  cat > tests/__init__.py << 'EOF'
"""Test package."""
EOF

  cat > tests/conftest.py << 'EOF'
"""Pytest configuration and fixtures."""

import pytest
from click.testing import CliRunner


@pytest.fixture
def runner():
    """Create CLI test runner."""
    return CliRunner()


@pytest.fixture
def mock_config(tmp_path):
    """Create mock configuration file."""
    config_file = tmp_path / "config.yaml"
    config_file.write_text("""
log_level: debug
debug: true
""")
    return str(config_file)
EOF

  cat > tests/test_cli.py << 'EOF'
"""Test CLI commands."""

import pytest
from src.cli import cli


def test_cli_help(runner):
    """Test CLI help command."""
    result = runner.invoke(cli, ["--help"])
    assert result.exit_code == 0
    assert "A Python CLI application" in result.output


def test_hello_command(runner):
    """Test hello command."""
    result = runner.invoke(cli, ["hello"])
    assert result.exit_code == 0
    assert "Hello, World!" in result.output


def test_hello_with_name(runner):
    """Test hello command with custom name."""
    result = runner.invoke(cli, ["hello", "--name", "Alice"])
    assert result.exit_code == 0
    assert "Hello, Alice!" in result.output


def test_version_command(runner):
    """Test version command."""
    result = runner.invoke(cli, ["version"])
    assert result.exit_code == 0
    assert "version 0.1.0" in result.output


def test_version_full(runner):
    """Test version command with full flag."""
    result = runner.invoke(cli, ["version", "--full"])
    assert result.exit_code == 0
    assert "Version Information" in result.output
    assert "Python" in result.output


def test_list_commands(runner):
    """Test list-commands command."""
    result = runner.invoke(cli, ["list-commands"])
    assert result.exit_code == 0
    assert "Available Commands" in result.output


def test_debug_mode(runner):
    """Test debug mode."""
    result = runner.invoke(cli, ["--debug", "hello"])
    assert result.exit_code == 0


def test_config_loading(runner, mock_config):
    """Test configuration file loading."""
    result = runner.invoke(cli, ["--config", mock_config, "hello"])
    assert result.exit_code == 0
EOF

  # Create GitHub Actions workflow for CLI
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  release:
    types: [created]

env:
  PYTHON_VERSION: '3.11'
  DOCKER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"
      
      - name: Run black
        run: black --check src tests
      
      - name: Run ruff
        run: ruff check src tests
      
      - name: Run mypy
        run: mypy src

  test:
    name: Test Python ${{ matrix.python-version }}
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.11', '3.12']
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"
      
      - name: Run tests with coverage
        run: pytest
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        if: matrix.python-version == '3.11'
        with:
          file: ./coverage.xml
          fail_ci_if_error: true

  build:
    name: Build Distribution
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install build dependencies
        run: |
          python -m pip install --upgrade pip
          pip install build
      
      - name: Build distribution
        run: python -m build
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  docker:
    name: Build Docker Image
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.DOCKER_REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.DOCKER_REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  release:
    name: Release
    needs: [lint, test, build, docker]
    runs-on: ubuntu-latest
    if: github.event_name == 'release'
    steps:
      - uses: actions/checkout@v4
      
      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist/
      
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          password: ${{ secrets.PYPI_API_TOKEN }}
EOF

  # Create pre-commit configuration (same as API)
  cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-toml
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        language_version: python3.11

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.11
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [types-all]
        args: [--ignore-missing-imports]
EOF

  # Create .env.example
  cat > .env.example << EOF
# Application
${project_name^^}_DEBUG=false
${project_name^^}_LOG_LEVEL=info
${project_name^^}_LOG_FORMAT=text

# Configuration
${project_name^^}_CONFIG_FILE=

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML Configuration
${project_name^^}_OPENAI_API_KEY=your-openai-api-key
${project_name^^}_ANTHROPIC_API_KEY=your-anthropic-api-key
${project_name^^}_MODEL_NAME=gpt-4
${project_name^^}_MAX_TOKENS=1000
${project_name^^}_TEMPERATURE=0.7"; fi)
EOF

  # Copy .env.example to .env
  cp .env.example .env

  # Create example config.yaml
  cat > config.yaml.example << EOF
# Application configuration
log_level: info
log_format: text
debug: false

$(if [[ "$ai_ready" == "true" ]]; then echo "# AI/ML Configuration
openai_api_key: your-key-here
anthropic_api_key: your-key-here
model_name: gpt-4
max_tokens: 1000
temperature: 0.7"; fi)
EOF

  # Create additional modules for AI-ready CLI projects
  if [[ "$ai_ready" == "true" ]]; then
    mkdir -p src/ai
    
    # Create AI command
    cat > src/commands/ai.py << 'EOF'
"""AI-powered commands."""

import click
from rich.console import Console
from rich.panel import Panel
from rich.markdown import Markdown
import structlog

from src.ai.llm import get_llm_service

console = Console()
logger = structlog.get_logger()


@click.group()
def ai():
    """AI-powered commands."""
    pass


@ai.command()
@click.option(
    "--prompt",
    "-p",
    required=True,
    help="Prompt to send to the AI.",
)
@click.option(
    "--model",
    "-m",
    help="Model to use (e.g., gpt-4, claude-3).",
)
@click.option(
    "--system",
    "-s",
    help="System prompt to use.",
)
@click.option(
    "--temperature",
    "-t",
    type=float,
    help="Temperature for generation (0.0-2.0).",
)
def complete(prompt, model, system, temperature):
    """Get AI completion for a prompt."""
    llm = get_llm_service()
    
    with console.status("[bold green]Thinking..."):
        try:
            response = llm.complete_sync(
                prompt=prompt,
                system_prompt=system,
                model=model,
                temperature=temperature,
            )
            
            # Display response in a nice panel
            md = Markdown(response)
            panel = Panel(
                md,
                title="AI Response",
                border_style="green",
                padding=(1, 2),
            )
            console.print(panel)
            
        except Exception as e:
            logger.error("AI completion failed", error=str(e))
            console.print(f"[red]Error: {e}[/red]")


@ai.command()
@click.option(
    "--file",
    "-f",
    type=click.File("r"),
    required=True,
    help="File to analyze.",
)
@click.option(
    "--question",
    "-q",
    help="Specific question about the file.",
)
def analyze(file, question):
    """Analyze a file with AI."""
    content = file.read()
    
    prompt = f"Please analyze the following file:\n\n{content}"
    if question:
        prompt += f"\n\nSpecific question: {question}"
    
    llm = get_llm_service()
    
    with console.status("[bold green]Analyzing..."):
        try:
            response = llm.complete_sync(
                prompt=prompt,
                system_prompt="You are a helpful code analysis assistant.",
            )
            
            md = Markdown(response)
            panel = Panel(
                md,
                title=f"Analysis of {file.name}",
                border_style="blue",
                padding=(1, 2),
            )
            console.print(panel)
            
        except Exception as e:
            logger.error("File analysis failed", error=str(e))
            console.print(f"[red]Error: {e}[/red]")
EOF

    # Update CLI to include AI commands
    sed -i.bak '/from src.commands import hello, version/c\from src.commands import hello, version, ai' src/cli.py
    sed -i.bak '/cli.add_command(version.version)/a\cli.add_command(ai.ai)' src/cli.py
    rm -f src/cli.py.bak
    
    # Update commands __init__.py
    sed -i.bak '/from . import hello, version/c\from . import hello, version, ai' src/commands/__init__.py
    sed -i.bak '/__all__ = \["hello", "version"\]/c\__all__ = ["hello", "version", "ai"]' src/commands/__init__.py
    rm -f src/commands/__init__.py.bak
    
    # Create sync wrapper for LLM service
    cat >> src/ai/llm.py << 'EOF'

    def complete_sync(self, *args, **kwargs) -> str:
        """Synchronous wrapper for complete method."""
        import asyncio
        return asyncio.run(self.complete(*args, **kwargs))
EOF
  fi

  # Create command generator script
  cat > scripts/generate_command.py << 'EOF'
#!/usr/bin/env python3
"""Generate a new CLI command with boilerplate code and tests."""

import os
import sys
from pathlib import Path
from textwrap import dedent

def generate_command(name: str, description: str = ""):
    """Generate a new CLI command."""
    # Validate name
    if not name.replace("_", "").isalnum():
        print(f"Error: Command name '{name}' must contain only letters, numbers, and underscores.")
        sys.exit(1)
    
    # Convert to lowercase
    name = name.lower()
    
    # Default description
    if not description:
        description = f"Description for {name} command"
    
    # Create command file
    command_file = Path(f"src/commands/{name}.py")
    if command_file.exists():
        print(f"Error: Command '{name}' already exists at {command_file}")
        sys.exit(1)
    
    command_code = dedent(f'''
        """Command: {name} - {description}"""
        
        import click
        from rich.console import Console
        from rich.table import Table
        import structlog
        
        from src.core.config import settings
        
        console = Console()
        logger = structlog.get_logger()
        
        
        @click.command()
        @click.option(
            "--example",
            "-e",
            default="default",
            help="Example option for {name} command.",
        )
        @click.option(
            "--verbose",
            "-v",
            is_flag=True,
            help="Enable verbose output.",
        )
        @click.pass_context
        def {name}(ctx, example: str, verbose: bool):
            """{description}"""
            if verbose or ctx.obj.get("debug"):
                logger.info("Running {name} command", example=example)
            
            # TODO: Implement your command logic here
            table = Table(title="{name.title()} Results")
            table.add_column("Parameter", style="cyan")
            table.add_column("Value", style="green")
            
            table.add_row("Example", example)
            table.add_row("Debug Mode", str(ctx.obj.get("debug", False)))
            
            console.print(table)
            console.print(f"[green]✓[/green] {name.title()} command completed successfully!")
    ''').strip()
    
    command_file.write_text(command_code)
    print(f"✓ Created command file: {command_file}")
    
    # Create test file
    test_file = Path(f"tests/test_{name}.py")
    test_code = dedent(f'''
        """Tests for {name} command."""
        
        import pytest
        from click.testing import CliRunner
        from src.cli import cli
        
        
        def test_{name}_command(runner):
            """Test basic {name} command."""
            result = runner.invoke(cli, ["{name}"])
            assert result.exit_code == 0
            assert "{name.title()} command completed successfully!" in result.output
        
        
        def test_{name}_with_options(runner):
            """Test {name} command with options."""
            result = runner.invoke(cli, ["{name}", "--example", "test", "--verbose"])
            assert result.exit_code == 0
            assert "test" in result.output
        
        
        def test_{name}_help(runner):
            """Test {name} command help."""
            result = runner.invoke(cli, ["{name}", "--help"])
            assert result.exit_code == 0
            assert "{description}" in result.output
            assert "--example" in result.output
            assert "--verbose" in result.output
    ''').strip()
    
    test_file.write_text(test_code)
    print(f"✓ Created test file: {test_file}")
    
    # Update commands/__init__.py
    init_file = Path("src/commands/__init__.py")
    if init_file.exists():
        content = init_file.read_text()
        
        # Add import
        imports = content.split('\\n\\n')[0]
        if f"from . import {name}" not in imports:
            new_import = f"from . import {name}"
            imports_list = imports.split('\\n')
            imports_list.insert(-1, new_import)
            
            # Update __all__
            all_line = next((i for i, line in enumerate(imports_list) if line.startswith("__all__")), None)
            if all_line is not None:
                # Parse existing __all__
                import ast
                all_list = ast.literal_eval(imports_list[all_line].split(" = ")[1])
                all_list.append(name)
                all_list.sort()
                imports_list[all_line] = f'__all__ = {all_list}'
            
            new_content = '\\n'.join(imports_list)
            init_file.write_text(new_content)
            print(f"✓ Updated commands/__init__.py")
    
    # Update cli.py
    cli_file = Path("src/cli.py")
    if cli_file.exists():
        content = cli_file.read_text()
        
        # Add import
        import_line = f"from src.commands import {name}"
        if import_line not in content:
            # Find the last command import
            lines = content.split('\\n')
            import_idx = None
            for i, line in enumerate(lines):
                if line.startswith("from src.commands import"):
                    import_idx = i
            
            if import_idx is not None:
                # Update existing import
                existing = lines[import_idx]
                if ", " in existing:
                    modules = existing.split("import ")[1].split(", ")
                    modules.append(name)
                    modules.sort()
                    lines[import_idx] = f"from src.commands import {', '.join(modules)}"
                else:
                    lines[import_idx] = existing.replace("import ", "import ") + f", {name}"
            
            # Add command registration
            register_line = f"cli.add_command({name}.{name})"
            if register_line not in content:
                # Find last add_command
                last_add = None
                for i, line in enumerate(lines):
                    if "cli.add_command(" in line:
                        last_add = i
                
                if last_add is not None:
                    lines.insert(last_add + 1, register_line)
            
            cli_file.write_text('\\n'.join(lines))
            print(f"✓ Updated cli.py")
    
    print(f"""
✅ Successfully generated command '{name}'!

Next steps:
1. Implement your command logic in src/commands/{name}.py
2. Run tests: pytest tests/test_{name}.py
3. Try your command: python -m src {name} --help
""")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python scripts/generate_command.py <command_name> [description]")
        print("Example: python scripts/generate_command.py analyze 'Analyze files with AI'")
        sys.exit(1)
    
    name = sys.argv[1]
    description = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
    
    generate_command(name, description)
EOF

  chmod +x scripts/generate_command.py

  # Create GitHub dependabot configuration
  mkdir -p .github
  cat > .github/dependabot.yml << 'EOF'
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
    
  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
    
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
EOF

  # Add all project files and commit on feature branch
  git add .
  git commit -m "feat: Add Python Docker CLI project with comprehensive setup

- Click CLI framework with rich terminal output
- Multi-stage Docker build for minimal images
- GitHub Actions CI/CD pipeline with releases
- pytest with CLI command testing
- Pre-commit hooks and code quality tools
- Flexible configuration system
$(if [[ "$ai_ready" == "true" ]]; then echo "- AI-powered commands with OpenAI and Anthropic"; fi)"
  
  # Push feature branch to GitHub if remote exists
  if git remote get-url origin &>/dev/null; then
    echo "Pushing feature branch to GitHub..."
    git push -u origin feat/initial-setup
    
    # Create PR if gh CLI is available
    if command_exists gh; then
      echo "Creating pull request..."
      gh pr create \
        --title "feat: Initial Python Docker CLI project setup" \
        --body "## Description

This PR contains the initial project setup for $project_name CLI with:

### Features
- ✅ Click framework for rich CLI experience
- ✅ Multi-stage Docker builds for distribution
- ✅ Comprehensive GitHub Actions CI/CD pipeline
- ✅ Testing setup with pytest and CLI command tests
- ✅ Code quality tools (black, ruff, mypy, pre-commit)
- ✅ Flexible configuration via env vars or YAML
- ✅ Rich terminal output with colors and tables
$(if [[ "$ai_ready" == "true" ]]; then echo "- ✅ AI-powered commands with LLM integrations"; fi)

### Infrastructure
- Docker configuration for easy distribution
- GitHub Actions workflows for testing and releases
- Multi-platform Docker image builds
- PyPI publishing workflow

### Developer Experience
- Makefile for common commands
- Pre-commit hooks for code quality
- Comprehensive README with examples
- Well-structured command architecture

## Testing
- Run \`make test\` for unit tests
- Run \`make docker-test\` for containerized tests
- All tests should pass before merging

## Next Steps
After merging, developers can:
1. Install via pip: \`pip install -e .\`
2. Try the CLI: \`$project_name --help\`
3. Run example: \`$project_name hello --name World\`
4. Build Docker: \`make docker-build\`" \
        --base main
    fi
  else
    echo ""
    echo "To push to GitHub later:"
    echo "1. Create a repository on GitHub"
    echo "2. Add remote: git remote add origin https://github.com/$github_username/$project_name.git"
    echo "3. Push: git push -u origin main && git push -u origin feat/initial-setup"
  fi
  
  log_success "Python Docker CLI project '$project_name' created successfully!"
  echo ""
  echo "Next steps:"
  echo "1. cd $project_name"
  echo "2. Review and update .env file if needed"
  echo "3. Run 'make install-dev' to install development dependencies"
  echo "4. Try the CLI: '$project_name --help'"
  echo "5. Build Docker image: 'make docker-build'"
  echo "6. Run in Docker: 'make docker-run'"
  echo ""
  echo "For more commands, run: make help"
} 