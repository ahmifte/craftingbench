<div align="center">

# CraftingBench User Guide

**A modern scaffolding tool for TypeScript developers**

[![Version](<https://img.shields.io/badge/Version-0.3.0%20(Beta)-orange.svg>)](./CHANGELOG.md)

</div>

______________________________________________________________________

## 📋 Table of Contents

- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [Available Templates](#-available-templates)
- [Template Options](#-template-options)
- [Fullstack Development](#-fullstack-development)
- [Material UI Integration](#-material-ui-integration)
- [Common Commands](#-common-commands)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)

## 🚀 Installation

```bash
curl -fsSL https://raw.githubusercontent.com/ahmifte/craftingbench/main/install.sh | bash
```

After installation, restart your terminal or source your shell configuration:

```bash
source ~/.zshrc  # or ~/.bashrc
```

Verify the installation:

```bash
craftingbench --version
```

## 🏁 Getting Started

Create a new project with CraftingBench:

```bash
# Basic usage
craftingbench create [project_name] [template_type]

# Example: Create a TypeScript React project
craftingbench create my-app react

# Example: Create a TypeScript Node.js API
craftingbench create api-service nodejs
```

## 📦 Available Templates

CraftingBench offers several project templates with TypeScript integration:

| Template      | Description                               | Command                                     |
| ------------- | ----------------------------------------- | ------------------------------------------- |
| **nodejs**    | TypeScript Node.js backend with Express   | `craftingbench create my-api nodejs`        |
| **react**     | TypeScript React app with Material UI     | `craftingbench create my-ui react`          |
| **go**        | Go service with modern project structure  | `craftingbench create my-service go`        |
| **python**    | Python application with package structure | `craftingbench create my-app python`        |
| **python-docker** | Python with Docker & CI/CD           | `craftingbench create my-api python-docker` |
| **fullstack** | TypeScript fullstack application          | `craftingbench create my-project fullstack` |

## ⚙️ Template Options

### TypeScript Node.js

```bash
craftingbench create my-api nodejs
```

Features:

- TypeScript configuration
- Express.js setup
- Environment management
- Structured project with controllers, services, and routes
- Error handling middleware
- Database connection utilities (MongoDB)

### TypeScript React

```bash
craftingbench create my-ui react
```

Features:

- TypeScript React setup
- Material UI integration
- Responsive layout components
- Theme customization
- Component organization
- Form handling utilities

### Fullstack

```bash
craftingbench create my-project fullstack --backend [nextjs|flask|go]
```

Features:

- TypeScript frontend with Material UI
- Integrated API client
- Backend options:
  - Next.js (TypeScript)
  - Flask (Python)
  - Go

## 🌐 Fullstack Development

CraftingBench offers three fullstack templates with different backend options:

### Next.js Fullstack

```bash
craftingbench create my-app fullstack --backend nextjs
```

Structure:

- TypeScript throughout
- App Router architecture
- Server-side API routes
- Material UI theming system
- Responsive layouts

### Flask + React Fullstack

```bash
craftingbench create my-app fullstack --backend flask
```

Structure:

- Python Flask backend with structured API
- TypeScript React frontend
- Material UI components
- API client for backend communication
- Advanced logging configuration

### Go + React Fullstack

```bash
craftingbench create my-app fullstack --backend go
```

## 🐳 Python Docker Projects

CraftingBench provides comprehensive Python project templates with Docker containerization and CI/CD pipelines:

### Python Docker API

```bash
# Create a Python API with Docker and CI/CD
craftingbench setup_python_docker_api my-api

# Or use the full command with options
craftingbench setup_python_docker_project my-api --type=api

# Create an AI-ready API with LLM integrations
craftingbench setup_python_docker_project my-ai-api --type=api --ai-ready

# Create an API with RAG system, mock data, and context management
craftingbench setup_python_docker_project my-rag-api --type=api --with-mock-data
```

Features:
- **FastAPI** framework with async support
- **Multi-stage Docker** builds for minimal production images
- **GitHub Actions CI/CD** with testing, linting, and security scanning
- **pytest** with coverage reporting
- **Pre-commit hooks** with black, ruff, and mypy
- **Structured logging** with structlog
- **Health checks** and metrics endpoints
- **Docker Compose** for local development
- **AI/ML Ready** option includes OpenAI/Anthropic integrations

### Python Docker CLI

```bash
# Create a Python CLI with Docker
craftingbench setup_python_docker_cli my-cli

# Or use the full command
craftingbench setup_python_docker_project my-cli --type=cli

# Create an AI-powered CLI tool
craftingbench setup_python_docker_project my-ai-cli --type=cli --ai-ready

# Create a CLI with RAG capabilities and mock data
craftingbench setup_python_docker_project my-rag-cli --type=cli --with-mock-data
```

Features:
- **Click** framework with rich output
- **Docker packaging** for easy distribution
- **GitHub Actions** with multi-platform builds
- **PyPI publishing** workflow
- **Comprehensive testing** setup
- **Configuration management** via environment or YAML
- **AI/ML Ready** option for LLM-powered commands
- **RAG System** option with vector storage and context management
- **Mock Data Generation** for testing and demonstrations

Structure:

- Go backend with clean architecture
- TypeScript React frontend
- Material UI integration
- Type-safe API client
- Production-ready configurations

## 🎨 Material UI Integration

All frontend templates include Material UI with:

- Custom theme configuration
- Light/dark mode support
- Responsive layout components
- Common UI patterns
- Form controls and validation

Example usage in projects:

```tsx
import { Button, TextField, Card, CardContent } from '@mui/material';

function MyComponent() {
  return (
    <Card>
      <CardContent>
        <TextField label="Name" fullWidth margin="normal" />
        <Button variant="contained" color="primary">
          Submit
        </Button>
      </CardContent>
    </Card>
  );
}
```

## 🛠️ Common Commands

```bash
# List available templates
craftingbench list

# Get help
craftingbench help

# Format code in current project
craftingbench format

# Lint code in current project
craftingbench lint

# Run project
craftingbench run
```

## 🧰 Utility Functions

CraftingBench provides several utility functions that can be used independently in your own projects and scripts.

### Pre-commit Configuration

You can easily add pre-commit hooks to any existing project:

```bash
# Add pre-commit configuration to the current project
./src/templates/pre-commit.sh .

# Add pre-commit for a specific project with explicit language types
./src/templates/pre-commit.sh /path/to/project python,js,go
```

The pre-commit script will:

- Detect languages used in your project
- Configure appropriate linters and formatters
- Update README.md with usage instructions

Available language configurations:

- `python`: Includes black, isort, ruff
- `js`: Includes eslint, prettier
- `go`: Includes go-fmt, go-vet, go-imports

### GitHub Workflow Setup

You can add GitHub Actions workflows to your project using the utility functions:

```bash
# Source the utility functions
source /path/to/craftingbench/src/helpers/utils.sh

# Setup a workflow
setup_github_workflow . python my-project-name your-github-username
```

Available workflow templates:

- `python-workflow.yml`
- `nodejs-workflow.yml`
- `go-workflow.yml`
- `react-workflow.yml`
- `pre-commit-workflow.yml`
- `nextjs-workflow.yml`
- `flask-react-workflow.yml`
- `go-react-workflow.yml`

### Git Repository Setup

Initialize a git repository with standard configurations:

```bash
# Source the utility functions
source /path/to/craftingbench/src/helpers/utils.sh

# Basic repository setup
setup_git_repository . my-project-name

# With GitHub integration
setup_git_repository . my-project-name your-github-username true
```

### Common .gitignore Templates

Generate project-specific .gitignore files:

```bash
# Source the utility functions
source /path/to/craftingbench/src/helpers/utils.sh

# Create .gitignore for a Python project
create_gitignore . python

# Create .gitignore for a Node.js project
create_gitignore . node

# Create .gitignore for a Go project
create_gitignore . go
```

## 🔧 Configuration

CraftingBench can be configured through:

```bash
craftingbench config set key value
```

Common configuration options:

- `default_template`: Set your preferred template
- `author_name`: Your name for project metadata
- `author_email`: Your email for project metadata
- `github_username`: Your GitHub username

## ❓ Troubleshooting

**Template generation fails:**

- Ensure you have the required dependencies installed
- Check your network connection
- Verify you have the latest version of CraftingBench

**Package installation issues:**

- Ensure npm/yarn/go/pip is installed and in your PATH
- Check for conflicting versions in existing dependencies

**Command not found:**

- Make sure CraftingBench is properly installed
- Check that the installation directory is in your PATH

For more help, run:

```bash
craftingbench help
```

## 🤖 RAG-Enhanced AI Projects

### Overview

The `--with-mock-data` flag creates projects with a production-ready Retrieval-Augmented Generation (RAG) system. This includes:

- **Vector Database**: ChromaDB for storing and searching document embeddings
- **Context Management**: Session-based conversation tracking
- **Mock Data Generator**: 100+ realistic documents for testing
- **Advanced Prompt Engineering**: Templates and best practices

### Quick Start with RAG

```bash
# Create a RAG-enabled API
craftingbench setup_python_docker_project my-rag-api --type=api --with-mock-data

cd my-rag-api

# Initialize the RAG system with mock data
make init-rag

# Start the API server
make dev

# Test RAG endpoint
curl -X POST "http://localhost:8000/api/v1/rag/query" \
  -H "Content-Type: application/json" \
  -d '{"question": "How do I configure Docker?"}'
```

### RAG System Architecture

```
src/
├── rag/                    # RAG system components
│   ├── vectorstore.py      # ChromaDB integration
│   ├── context_manager.py  # Conversation management
│   └── pipeline.py         # RAG orchestration
├── data/                   # Data management
│   └── generator.py        # Mock data generation
└── api/v1/
    └── rag.py             # RAG API endpoints
```

### Key Features

1. **Vector Storage**
   - Automatic document chunking
   - Semantic search capabilities
   - Metadata filtering

2. **Context Management**
   - Multi-turn conversations
   - Session persistence
   - Context window optimization

3. **Mock Data**
   - Technical documentation
   - API references
   - Tutorials and FAQs
   - Best practices guides

4. **API Endpoints**
   ```
   POST   /api/v1/rag/query         # Query with context
   POST   /api/v1/rag/ingest        # Add documents
   GET    /api/v1/rag/sessions/{id} # Get history
   DELETE /api/v1/rag/sessions/{id} # Clear session
   ```

### Prompt Engineering Best Practices

The RAG system includes:

1. **Template Management**
   - Jinja2 templates in `prompts/`
   - Context-aware prompts
   - Multi-source synthesis

2. **Temperature Control**
   - 0.0-0.3 for factual queries
   - 0.7-1.0 for creative tasks

3. **Context Optimization**
   - Relevant document retrieval
   - Source attribution
   - Conversation continuity

### CLI with RAG

For CLI projects with `--with-mock-data`:

```bash
# Ask questions with context
my-rag-cli ask "How to troubleshoot Docker issues?"

# Ingest new documents
my-rag-cli ingest document.md --type technical

# View conversation history
my-rag-cli history --format table

# Run interactive demo
my-rag-cli demo --feature all
```

### Configuration

Key environment variables:

```env
# Vector Store
CHROMA_PERSIST_DIR=data/chroma
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2

# RAG Settings
RAG_TOP_K=5
RAG_SEARCH_TYPE=similarity

# Context Management
MAX_CONVERSATION_TURNS=10
CONTEXT_WINDOW_SIZE=4096
```

### Advanced Usage

See `docs/RAG_SETUP_GUIDE.md` in generated projects for:
- Custom document ingestion
- Fine-tuning embeddings
- Production deployment
- Performance optimization

Or report issues at [GitHub Issues](https://github.com/ahmifte/craftingbench/issues)
