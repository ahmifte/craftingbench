# CraftingBench User Guide

This guide provides detailed information on how to use CraftingBench effectively for your development workflow.

[![Version](<https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg>)](../CHANGELOG.md)

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
- [UI Framework](#ui-framework)
- [Technology Stack](#technology-stack)
- [Package Management](#package-management)
- [Development Workflow](#development-workflow)
  - [Using with TypeScript](#using-with-typescript)
  - [Testing Your Projects](#testing-your-projects)
  - [Linting and Formatting](#linting-and-formatting)
  - [Development Tools](#development-tools)
- [Customizing Templates](#customizing-templates)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

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
  - setup_python_project <n>       : Create a Python project
  - setup_nodejs_backend <n>       : Create a TypeScript Node.js backend
  - setup_react_frontend <n>       : Create a TypeScript React frontend with Material UI
  - setup_go_project <n>           : Create a Golang project
  - setup_fullstack_project <n>    : Create a TypeScript fullstack app
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
pnpm install
pnpm dev
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
pnpm install
pnpm dev
```

Generated structure:

```
my_web_app/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── App.tsx
│   ├── index.tsx
│   ├── components/
│   └── styles/
└── tsconfig.json
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

Generated structure:

```
my_go_service/
├── .gitignore
├── Makefile
├── README.md
├── cmd/
│   └── my_go_service/
│       └── main.go
├── go.mod
├── internal/
│   ├── app/
│   └── pkg/
├── pkg/
└── test/
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

Generated structure:

```
my_python_lib/
├── .gitignore
├── .python-version
├── Makefile
├── README.md
├── main.py
├── my_python_lib/
│   └── __init__.py
├── pyproject.toml
└── tests/
    └── test_main.py
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
- Responsive layouts with theme customization
- Dark/light mode support
- Best practices for project structure and code organization

Generated structure (Next.js example):

```
my_nextjs_app/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── public/
│   └── favicon.ico
├── src/
│   ├── app/             # Next.js App Router
│   ├── components/      # Reusable UI components with Material UI
│   ├── lib/             # Utility functions and theme configuration
│   ├── stores/          # State management
│   └── types/           # TypeScript types
└── tsconfig.json
```

After creation, follow the README instructions in the created project for setup.

## UI Framework

CraftingBench utilizes **Material UI** for all frontend templates, providing:

- Beautiful, customizable components based on Material Design
- Responsive layouts that work well on all devices
- Optimized performance with Next.js integration
- Comprehensive theming system
- Dark/light mode support out of the box

Material UI provides a solid foundation for building professional user interfaces with minimal effort. All components are built with accessibility in mind and follow best practices for responsive design.

## Technology Stack

CraftingBench templates leverage the following technologies:

| Category             | Technologies                            |
| -------------------- | --------------------------------------- |
| **Frontend**         | React, TypeScript, Material UI, Emotion |
| **Backend**          | Next.js, Flask, Go, Express             |
| **State Management** | React Query, Zustand                    |
| **API Integration**  | Axios, Fetch API                        |
| **Tooling**          | ESLint, Prettier, Jest                  |

## Package Management

CraftingBench uses [pnpm](https://pnpm.io/) as the preferred package manager for TypeScript projects. PNPM offers several advantages:

- **Disk space efficiency**: Stores all package versions in a single place on disk
- **Strict dependency management**: Prevents phantom dependencies
- **Faster installation**: Up to 2x faster than npm and yarn
- **Optimized for monorepos**: Built-in workspace support

### PNPM Configuration

All TypeScript templates include optimal pnpm configuration:

```
# .npmrc file included in templates
public-hoist-pattern[]=*@mui/*
public-hoist-pattern[]=*@emotion/*
public-hoist-pattern[]=*types*
```

### Using PNPM with Templates

All TypeScript templates (React, Node.js, and Fullstack) are configured to use pnpm:

```bash
cd my_react_app
pnpm dev    # Start development server
pnpm build  # Build for production
pnpm test   # Run tests
```

To manually install dependencies:

```bash
pnpm install  # Install all dependencies
pnpm add package-name  # Add a new dependency
pnpm add -D package-name  # Add a dev dependency
```

## Development Workflow

### Using with TypeScript

All JavaScript-based templates use TypeScript exclusively. Common TypeScript workflows include:

```bash
# Type checking
pnpm typecheck

# Running the development server
pnpm dev

# Building for production
pnpm build
```

### Testing Your Projects

Each template includes testing setup appropriate for the language:

```bash
# TypeScript/JavaScript projects
pnpm test

# Python projects
make test

# Go projects
make test
```

### Linting and Formatting

Maintain code quality with built-in linting and formatting:

```bash
# TypeScript/JavaScript projects
pnpm lint
pnpm format

# Python projects
make lint
make format

# Go projects
make lint
make fmt
```

### Development Tools

CraftingBench includes a comprehensive set of development tools for both frontend and backend templates:

#### ESLint Configuration

All TypeScript templates are preconfigured with ESLint using the modern flat config format:

```bash
# Run linting on the project
pnpm lint
```

Features include:

- TypeScript integration with strict type checking
- React and React Hooks rules
- Import order enforcement
- Proper compatibility with Prettier

#### Prettier Integration

Consistent code formatting across all templates:

```bash
# Format all files
pnpm format
```

#### TypeScript Support

TypeScript configuration that works for both frontend and backend:

- Modern ES2022 target
- Path aliases for cleaner imports (`@/components/Button` instead of `../../components/Button`)
- Strict type checking enabled by default
- JSX support for React projects

#### Template-specific Development Tools

Each project template includes these development tools out of the box:

**TypeScript Frontend (React):**

```bash
pnpm lint         # Run ESLint
pnpm format       # Run Prettier
pnpm typecheck    # TypeScript type checking
```

**TypeScript Backend (Node.js):**

```bash
pnpm lint         # Run ESLint
pnpm format       # Run Prettier
pnpm typecheck    # TypeScript type checking
pnpm dev          # Run with hot reloading
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

## Resources

Here are some useful resources for working with the technologies used in CraftingBench templates:

| Resource                                                                           | Description                                 |
| ---------------------------------------------------------------------------------- | ------------------------------------------- |
| [GitHub CLI Documentation](https://cli.github.com/manual/)                         | Documentation for the GitHub CLI            |
| [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/) | Best practices for Python project structure |
| [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)        | Comprehensive guide for Node.js projects    |
| [Go Project Layout](https://github.com/golang-standards/project-layout)            | Standard Go project structure               |
| [Zsh Documentation](https://zsh.sourceforge.io/Doc/)                               | Documentation for Zsh shell                 |
| [Material UI Documentation](https://mui.com/material-ui/)                          | Complete guide to Material UI components    |
| [pnpm Documentation](https://pnpm.io/)                                             | Official pnpm documentation                 |

---

For more information, see the [architecture documentation](architecture.md) and [template documentation](templates/README.md).
