# CraftingBench User Guide

This guide provides detailed information on how to use CraftingBench effectively for your development workflow.

[![Version](https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg)](../CHANGELOG.md)

> **⚠️ BETA NOTICE:** CraftingBench v0.2.0 is currently in beta. Features, APIs, and usage patterns may change before the stable 1.0.0 release. Please read the [Security Policy](../SECURITY.md) for important information.

## Table of Contents

- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Shell Integration](#shell-integration)
  - [Command Completion](#command-completion)
- [Project Templates](#project-templates)
  - [TypeScript Node.js Backend](#typescript-nodejs-backend)
  - [TypeScript React Frontend](#typescript-react-frontend)
  - [Go Projects](#go-projects)
  - [Python Projects](#python-projects)
  - [Fullstack Projects](#fullstack-projects)
- [Development Workflow](#development-workflow)
  - [Using with TypeScript](#using-with-typescript)
  - [Testing Your Projects](#testing-your-projects)
  - [Linting and Formatting](#linting-and-formatting)
- [Customizing Templates](#customizing-templates)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Installation

CraftingBench can be installed using the automated installer script or manually.

#### Automated Installation (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ahmifte/craftingbench/v0.2.0/install.sh | bash
```

This script will:
1. Download CraftingBench v0.2.0
2. Install it to `~/.craftingbench`
3. Configure your shell by adding the necessary source line to your `.bashrc` or `.zshrc`

#### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/ahmifte/craftingbench.git
   ```

2. Make the script executable:
   ```bash
   chmod +x /path/to/craftingbench/craftingbench.sh
   ```

3. Add to your shell configuration file:
   ```bash
   # For Bash (.bashrc)
   source /path/to/craftingbench/craftingbench.sh
   
   # For Zsh (.zshrc)
   source /path/to/craftingbench/craftingbench.sh
   ```

### Shell Integration

After installation, restart your terminal or reload your shell configuration:

```bash
# For Bash
source ~/.bashrc

# For Zsh
source ~/.zshrc
```

You should see the CraftingBench banner when your shell starts, indicating successful installation:

```
🛠️  CraftingBench loaded!
Available commands:
  - setup_python_project <name>       : Create a Python project
  - setup_nodejs_backend <name>       : Create a TypeScript Node.js backend
  - setup_react_frontend <name>       : Create a TypeScript React frontend with Material UI
  - setup_go_project <name>           : Create a Golang project
  - setup_fullstack_project <name>    : Create a TypeScript fullstack app
    Options:
      --backend=nextjs                : Use Next.js (default)
      --backend=flask                 : Use Flask backend + TypeScript React frontend
      --backend=golang                : Use Go backend + TypeScript React frontend

Development tools:
  - lint                              : Run ESLint on TypeScript code
  - format                            : Format code with Prettier
  - typecheck                         : Run TypeScript type checking
```

### Command Completion

CraftingBench provides command completion for Zsh shells. When you type a partial command and press Tab, it will show available options.

For example:
```bash
setup_fullstack_project myapp --backend=[TAB]
# Will show: nextjs flask golang
```

## Project Templates

CraftingBench offers several project templates designed with best practices and modern tooling.

### TypeScript Node.js Backend

Create a new TypeScript Node.js backend project:

```bash
setup_nodejs_backend my_api
```

This creates a complete Express API with:
- TypeScript configuration
- Project structure with controllers, routes, models, and middleware
- Testing setup with Jest
- ESLint and Prettier configuration
- Environment variable management with dotenv

After creation, navigate to your project and start development:

```bash
cd my_api
npm install
npm run dev
```

### TypeScript React Frontend

Create a TypeScript React frontend project with Material UI:

```bash
setup_react_frontend my_web_app
```

This creates a React application with:
- TypeScript support
- Material UI components
- Project structure for components, hooks, and pages
- ESLint and Prettier configuration
- Testing setup

After creation, navigate to your project and start development:

```bash
cd my_web_app
npm install
npm run dev
```

### Go Projects

Create a Go project with standardized structure:

```bash
setup_go_project my_go_service
```

This creates a Go project with:
- Standard Go project layout
- Basic HTTP server setup
- Configuration management
- Makefile for common tasks

After creation, navigate to your project and run:

```bash
cd my_go_service
go mod tidy
go run cmd/my_go_service/main.go
```

### Python Projects

Create a Python project with modern tooling:

```bash
setup_python_project my_python_lib
```

This creates a Python project with:
- Modern pyproject.toml configuration
- Testing setup with pytest
- Linting with flake8
- Formatting with black and isort
- Virtual environment management

After creation, navigate to your project and set up the environment:

```bash
cd my_python_lib
make install  # Creates virtual environment and installs dependencies
```

### Fullstack Projects

Create a fullstack project with different backend options:

```bash
# Next.js (default)
setup_fullstack_project my_nextjs_app

# Flask backend + React frontend
setup_fullstack_project my_flask_app --backend=flask

# Go backend + React frontend
setup_fullstack_project my_go_app --backend=golang
```

These create fullstack applications with:
- TypeScript throughout the stack
- Material UI for consistent UI
- Backend and frontend in a single repository
- API integration between backend and frontend

After creation, follow the README instructions in the created project for setup.

## Development Workflow

### Using with TypeScript

All JavaScript-based templates use TypeScript exclusively. Common TypeScript workflows include:

```bash
# Type checking
npm run typecheck

# Running the development server
npm run dev

# Building for production
npm run build
```

### Testing Your Projects

Each template includes testing setup appropriate for the language:

```bash
# TypeScript/JavaScript projects
npm test

# Python projects
make test

# Go projects
make test
```

### Linting and Formatting

Maintain code quality with built-in linting and formatting:

```bash
# TypeScript/JavaScript projects
npm run lint
npm run format

# Python projects
make lint
make format

# Go projects
make lint
make fmt
```

## Customizing Templates

CraftingBench templates are designed as starting points. To customize:

1. Generate a project using the appropriate template
2. Modify the generated files to fit your needs
3. Consider creating a fork of CraftingBench with your customizations if you need reusable templates

Advanced users can modify the template scripts directly at `src/templates/`.

## Troubleshooting

### Common Issues

**Issue**: Command not found error
**Solution**: Ensure that you've properly sourced the script in your shell configuration. Try running `source ~/.craftingbench/craftingbench.sh` manually.

**Issue**: Permission denied when running scripts
**Solution**: Ensure the script is executable with `chmod +x craftingbench.sh`

**Issue**: Dependencies missing error
**Solution**: CraftingBench checks for required dependencies before creating projects. Install any missing dependencies mentioned in the error message.

### Getting Help

If you encounter issues:

1. Check the [GitHub Issues](https://github.com/ahmifte/craftingbench/issues) for similar problems
2. Read the documentation in `docs/` directory
3. Create a new issue if you can't find a solution

---

For more information, see the [architecture documentation](architecture.md) and [template documentation](templates/README.md). 