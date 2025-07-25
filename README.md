<div align="center">

# 🛠️ Crafting Bench 🛠️

<p>Made with ❤️ by <a href="https://github.com/ahmifte">ahmifte</a></p>

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25.svg?logo=gnu-bash&logoColor=white)](craftingbench.sh)
[![Version](<https://img.shields.io/badge/Version-0.3.0%20(Beta)-orange.svg>)](CHANGELOG.md)
[![Dependabot](https://img.shields.io/badge/Dependabot-Active-brightgreen.svg)](https://github.com/features/security)
[![Made with Love](https://img.shields.io/badge/Made%20with-Love-ff69b4.svg)](https://github.com/ahmifte/craftingbench)

</div>

> **⚠️ BETA STATUS:** CraftingBench v0.3.0 is currently in beta. APIs and usage may change before the stable 1.0.0 release. Please review our [Security Policy](SECURITY.md) for important information.

______________________________________________________________________

<div align="center">
<h3>Craft your projects with precision and speed</h3>

_A powerful CLI utility for quickly scaffolding various project types with standardized, production-ready structures._

<pre align="center">
  _____              __ _   _                ____                 _     
 / ____|            / _| | (_)              |  _ \               | |    
| |     _ __ __ _  | |_| |_ _ _ __   __ _   | |_) | ___ _ __   __| |__  
 | |    | '__/ _` | |  _| __| | '_ \ / _` |  |  _ < / _ \ '_ \ / __| '_ \ 
 | |____| | | (_| | | | | |_| | | | | (_| |  | |_) |  __/ | | | (__| | | |
  \_____|_|  \__,_| |_|  \__|_|_| |_|\__, |  |____/ \___|_| |_|\___|_| |_|
                                     __/ |                               
                                    |___/                                
                                                                           
      #@@++++++++++++++++++++++++++++++++++++++++++++++++++++==-+*@@@      
    :@@*+++++++++++++++++++++++++++++++++++++++++++++++++++++++===*#@@#    
   @@#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==-+*#@@   
 @@*-:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.-=*@@ 
 @@@@@@@@%%@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@%%%@@@@@@ 
 @@@@@@@@*@@#@%@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@*@@*@@@@@@@ 
        %.@  -#@                                            =@@  @:#       
       =@-@  @@@                                            +@@  @=@=      
       %%:@  @@#                                            .@@  @+@*      
       @*-@  @@.                                             @@  @*#%      
       @++@  @@                                              @@. @%*@      
       @+%@ .@@                                              @@= #@+@      
       @=@% *@@                                              @@# -@=@      
       @-@: @@@                                              @@@  @-@      
       @=@  @@@                                              @@@  @-@      
      -@=@  @@@                                              %@@  @=@:     
      +@=@  @@=                                               @@  @=@#     
      #%+@                                                        @*#@     
      @##@                                                        @%+@     
      @+@@                                                        @@=@     
      @=@*                                                        %@-@     
      @-@:                                                        =@-@     
                                                                           
</pre>

</div>

______________________________________________________________________

<br />

## Table of Contents

- [Features](#-features)
- [Project Structure](#-project-structure)
- [Installation](#-installation)
- [Usage](#-usage)
  - [Python Project](#-python-project)
  - [Node.js Backend](#-nodejs-backend)
  - [Golang API](#-golang-api)
  - [React Frontend](#-react-frontend)
  - [Next.js Projects](#-nextjs-projects)
  - [Full-Stack Web Applications](#-full-stack-web-applications)
  - [Command Completion](#command-completion)
- [UI Framework](#-ui-framework)
- [Technology Stack](#-technology-stack)
- [Package Management](#-package-management)
- [Testing and Quality Assurance](#-testing-and-quality-assurance)
- [Development Tools](#-development-tools)
- [Customizing Templates](#customizing-templates)
- [Troubleshooting](#troubleshooting)
- [Contributing](#-contributing)
- [Resources](#-resources)
- [License](#-license)
- [AI Integration](#-ai-integration)

## ✨ Features

<p align="center"><strong>CraftingBench provides templates for various project types:</strong></p>

<div align="center">

| Icon | Template            | Description                                                          |
| :--: | ------------------- | -------------------------------------------------------------------- |
|  🐍  | **Python Projects** | Modern Python package with testing, linting, and CI/CD setup         |
|  🐳  | **Python Docker**   | Python API/CLI with Docker, comprehensive CI/CD, and AI/ML options   |
|  🚀  | **Node.js Backend** | Express-based API with TypeScript and testing framework              |
|  🔷  | **Golang API**      | Go-based REST API with standard project layout                       |
|  ⚛️  | **React Frontend**  | TypeScript + React application with Material UI components           |
|  🌐  | **Full-Stack Web**  | Fullstack applications with multiple backend options and Material UI |

</div>

## 📂 Project Structure

CraftingBench has been organized into a modular structure for better maintainability:

```
craftingbench/
├── craftingbench.sh         # Main entry point script
├── src/                     # Source code
│   ├── bin/                 # Binary scripts
│   ├── helpers/             # Helper functions
│   ├── scripts/             # Utility scripts
│   ├── templates/           # Project templates
│   └── completions/         # Shell completions
├── docs/                    # Documentation
│   ├── RELEASING.md         # Release process documentation
│   ├── architecture.md      # Architecture documentation
│   ├── anthropic-integration.md # Anthropic Claude integration docs
│   └── templates/           # Template-specific documentation
└── README.md                # Main documentation
```

## 🚀 Installation

### Option 1: Automated Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ahmifte/craftingbench/v0.3.0/install.sh | bash
```

This script will:

- Download CraftingBench v0.3.0
- Install it to ~/.craftingbench
- Configure your shell by adding the necessary source line to your .bashrc or .zshrc
- Create command line tools: `craftingbench` and `cb` (shorthand alias)
- Set up command autocompletion

### Option 2: Manual Installation

1. Clone this repository:

```bash
git clone https://github.com/ahmifte/craftingbench.git
```

2. Make the script executable:

```bash
chmod +x /path/to/craftingbench/craftingbench.sh
```

3. Add the following to your shell configuration file:

**For Bash users** (`.bashrc`):

```bash
source /path/to/craftingbench/craftingbench.sh	
```

**For Zsh users** (`.zshrc`):

```zsh
# Load CraftingBench	
source /path/to/craftingbench/craftingbench.sh	

# Optional: Enable Zsh completion for CraftingBench commands	
compdef _gnu_generic setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project	
```

4. Reload your shell configuration:

**For Bash users**:

```bash
source ~/.bashrc	
```

**For Zsh users**:

```zsh
source ~/.zshrc	
# Or use the shorthand	
. ~/.zshrc	
```

### Shell Integration

After installation, you should see the CraftingBench banner when your shell starts, indicating successful installation:

```
🛠️  CraftingBench loaded!
Available commands:
  - setup_python_project <n>       : Create a Python project
  - setup_python_docker_project <n>: Create a Python project with Docker & CI/CD
    Options:
      --type=api                      : Create API project with FastAPI (required)
      --type=cli                      : Create CLI project with Click (required)
      --ai-ready                      : Include AI/ML integrations (optional)
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

## 📋 Usage

<strong>Each project template is created with a single command:</strong>

### Command-Line Interface

CraftingBench provides three ways to use its functionality:

1. **Using the `craftingbench` command**:
   ```bash
   craftingbench setup_python_project my_awesome_package
   
   # Create a Python API with Docker and CI/CD
   craftingbench setup_python_docker_api my_api_service
   ```

2. **Using the shorthand alias `cb`**:
   ```bash
   cb setup_nodejs_backend my_api_service
   ```

3. **Sourcing the script and calling functions directly**:
   ```bash
   source ~/.craftingbench/craftingbench.sh
   setup_react_frontend my_frontend_app
   ```

### Command Completion

CraftingBench provides command completion for both Bash and Zsh shells. When you type a partial command and press Tab, it will show available options.

For example:

```bash
craftingbench setup_fullstack_project myapp --backend=[TAB]
# Will show: nextjs flask golang
```

This also works with the shorthand alias:
```bash
cb setup_fullstack_project myapp --backend=[TAB]
# Will show: nextjs flask golang
```

### 🐍 Python Project

```bash
setup_python_project my_awesome_package	
```

This creates a Python project with:

- Modern pyproject.toml configuration
- Testing setup with pytest
- Linting with flake8
- Formatting with black and isort
- Virtual environment management

Generated structure:

```
my_awesome_package/	
├── .gitignore	
├── .python-version	
├── Makefile	
├── README.md	
├── main.py	
├── my_awesome_package/	
│   └── __init__.py	
├── pyproject.toml	
└── tests/	
    └── test_main.py	
```

### 🚀 Node.js Backend

```bash
setup_nodejs_backend my_api_service	
```

This creates a complete Express API with:

- TypeScript configuration
- Project structure with controllers, routes, models, and middleware
- Testing setup with Jest
- ESLint and Prettier configuration
- Environment variable management with dotenv

Generated structure:

```
my_api_service/	
├── .eslintrc.js	
├── .gitignore	
├── README.md	
├── package.json	
├── src/	
│   ├── index.js	
│   ├── controllers/	
│   ├── models/	
│   ├── routes/	
│   └── middleware/	
└── tests/	
```

### 🔷 Golang API

```bash
setup_go_project my_go_service	
```

This creates a Go project with:

- Standard Go project layout
- Basic HTTP server setup
- Configuration management
- Makefile for common tasks

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

### ⚛️ React Frontend

```bash
setup_react_frontend my_react_app
```

This creates a React application with:

- TypeScript support
- Material UI components
- Project structure for components, hooks, and pages
- ESLint and Prettier configuration
- Testing setup

Generated structure:

```
my_react_app/
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

### 🌐 Next.js Projects

After creating a Next.js project, you can use these commands:

```bash
cd my_nextjs_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
pnpm dev    # Starts development server
```

### 🌐 Full-Stack Web Applications

Create complete fullstack applications with various backend options, all featuring Material UI for consistent, beautiful interfaces.

```bash
# Create with Next.js (default)
setup_fullstack_project my_nextjs_app

# Create with Flask backend
setup_fullstack_project my_flask_app --backend=flask

# Create with Go backend
setup_fullstack_project my_go_app --backend=golang
```

Each fullstack template includes:

- Modern React frontend with Material UI components
- Responsive layouts with theme customization
- Dark/light mode support
- Proper API integration between frontend and backend
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

## 🎨 UI Framework

CraftingBench utilizes **Material UI** for all frontend templates, providing:

- Beautiful, customizable components based on Material Design
- Responsive layouts that work well on all devices
- Optimized performance with Next.js integration
- Comprehensive theming system
- Dark/light mode support out of the box

Material UI provides a solid foundation for building professional user interfaces with minimal effort. All components are built with accessibility in mind and follow best practices for responsive design.

## 💻 Technology Stack

| Category             | Technologies                            |
| -------------------- | --------------------------------------- |
| **Frontend**         | React, TypeScript, Material UI, Emotion |
| **Backend**          | Next.js, Flask, Go, Express             |
| **State Management** | React Query, Zustand                    |
| **API Integration**  | Axios, Fetch API                        |
| **Tooling**          | ESLint, Prettier, Jest                  |

## 🧪 Testing and Quality Assurance

<p align="center"><strong>Each project template includes built-in testing capabilities:</strong></p>

### 🐍 Python Projects

```bash
cd my_python_project	
make test      # Runs pytest	
make lint      # Runs flake8	
make format    # Runs black and isort	
```

### 🚀 Node.js Projects

```bash
cd my_node_project	
pnpm test      # Runs tests	
pnpm lint      # Runs ESLint	
```

### 🔷 Go Projects

```bash
cd my_go_project	
make test      # Runs go test	
make vet       # Runs go vet	
make fmt       # Runs go fmt	
```

### ⚛️ React Projects

```bash
cd my_react_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
```

### 🌐 Next.js Projects

```bash
cd my_nextjs_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
pnpm dev    # Starts development server
```

## 📦 Package Management

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

## 🛠️ Development Tools

CraftingBench includes a comprehensive set of development tools for both frontend and backend templates:

### ESLint Configuration

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

### Prettier Integration

Consistent code formatting across all templates:

```bash
# Format all files
pnpm format
```

### TypeScript Support

TypeScript configuration that works for both frontend and backend:

- Modern ES2022 target
- Path aliases for cleaner imports (`@/components/Button` instead of `../../components/Button`)
- Strict type checking enabled by default
- JSX support for React projects

### Template-specific Development Tools

Each project template includes these development tools out of the box:

#### TypeScript Frontend (React):

```bash
pnpm lint         # Run ESLint
pnpm format       # Run Prettier
pnpm typecheck    # TypeScript type checking
```

#### TypeScript Backend (Node.js):

```bash
pnpm lint         # Run ESLint
pnpm format       # Run Prettier
pnpm typecheck    # TypeScript type checking
pnpm dev          # Run with hot reloading
```

## Customizing Templates

CraftingBench templates are designed as starting points. To customize:

1. Generate a project using the appropriate template
1. Modify the generated files to fit your needs
1. Consider creating a fork of CraftingBench with your customizations if you need reusable templates

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
1. Read the documentation in `docs/` directory
1. Create a new issue if you can't find a solution

## 🤝 Contributing

<div align="center">

**Contributions are welcome!** Feel free to add new project templates or improve existing ones.

</div>

1. Fork the repository
1. Create your feature branch (`git checkout -b feature/amazing-template`)
1. Commit your changes (`git commit -m 'Add amazing template'`)
1. Push to the branch (`git push origin feature/amazing-template`)
1. Open a Pull Request

### Development

To add a new template, see our [Template Documentation](docs/templates/README.md).

## 📚 Resources

| Resource                                                                           | Description                                 |
| ---------------------------------------------------------------------------------- | ------------------------------------------- |
| [GitHub CLI Documentation](https://cli.github.com/manual/)                         | Documentation for the GitHub CLI            |
| [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/) | Best practices for Python project structure |
| [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)        | Comprehensive guide for Node.js projects    |
| [Go Project Layout](https://github.com/golang-standards/project-layout)            | Standard Go project structure               |
| [Zsh Documentation](https://zsh.sourceforge.io/Doc/)                               | Documentation for Zsh shell                 |
| [Material UI Documentation](https://mui.com/material-ui/)                          | Complete guide to Material UI components    |
| [pnpm Documentation](https://pnpm.io/)                                             | Official pnpm documentation                 |

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤖 AI Integration

CraftingBench provides integration with AI services like Anthropic's Claude:

### Anthropic Claude Setup

To set up Anthropic Claude integration:

```bash
./src/scripts/setup_anthropic_with_uv.sh
```

This will set up a Python environment with the Anthropic SDK. See the [Anthropic Integration Documentation](docs/anthropic-integration.md) for more details.
