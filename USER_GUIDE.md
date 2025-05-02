<div align="center">

# CraftingBench User Guide

**A modern scaffolding tool for TypeScript developers**

[![Version](<https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg>)](./CHANGELOG.md)

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

Or report issues at [GitHub Issues](https://github.com/ahmifte/craftingbench/issues)
