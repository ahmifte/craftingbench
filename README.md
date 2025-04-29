<div align="center">

# 🛠️ Crafting Bench 🛠️

<p>Made with ❤️ by <a href="https://github.com/ahmifte">ahmifte</a></p>

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25.svg?logo=gnu-bash&logoColor=white)](craftingbench.sh)
[![Version](https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg)](CHANGELOG.md)
[![Made with Love](https://img.shields.io/badge/Made%20with-Love-ff69b4.svg)](https://github.com/ahmifte/craftingbench)

</div>

> **⚠️ BETA STATUS:** CraftingBench v0.2.0 is currently in beta. APIs and usage may change before the stable 1.0.0 release. Please review our [Security Policy](SECURITY.md) for important information.

______________________________________________________________________

<div align="center">
<h3>Craft your projects with precision and speed</h3>

_A powerful CLI utility for quickly scaffolding various project types with standardized, production-ready structures._

<pre align="center">
                                                                           
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

## ✨ Features

<p align="center"><strong>CraftingBench provides templates for various project types:</strong></p>

<div align="center">

| Icon | Template | Description |
|:----:|----------|-------------|
| 🐍 | **Python Projects** | Modern Python package with testing, linting, and CI/CD setup |
| 🚀 | **Node.js Backend** | Express-based API with TypeScript and testing framework |
| 🔷 | **Golang API** | Go-based REST API with standard project layout |
| ⚛️ | **React Frontend** | TypeScript + React application with Material UI components |
| 🌐 | **Full-Stack Web** | Fullstack applications with multiple backend options and Material UI |

</div>

## 📂 Project Structure

CraftingBench has been organized into a modular structure for better maintainability:

```
craftingbench/
├── craftingbench.sh         # Main entry point script
├── src/                     # Source code
│   ├── helpers/             # Helper functions
│   ├── templates/           # Project templates
│   └── completions/         # Shell completions
├── docs/                    # Documentation
│   ├── USER_GUIDE.md        # Comprehensive user guide
│   ├── RELEASING.md         # Release process documentation
│   ├── architecture.md      # Architecture documentation
│   └── templates/           # Template-specific documentation
└── README.md                # Main documentation
```

For detailed usage instructions, see the [User Guide](docs/USER_GUIDE.md).

## 🚀 Installation

<strong>Getting Started</strong>

### Option 1: Automated Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/ahmifte/craftingbench/v0.2.0/install.sh | bash
```

This script will:
- Download CraftingBench v0.2.0
- Install it to ~/.craftingbench
- Configure your shell by adding the necessary source line to your .bashrc or .zshrc

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

## 📋 Usage

<strong>Each project template is created with a single command:</strong>

<h3>🐍 Python Project</h3>

```bash
setup_python_project my_awesome_package	
```

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

<h3>🚀 Node.js Backend</h3>

```bash
setup_nodejs_backend my_api_service	
```

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

<h3>🔷 Golang API</h3>

```bash
setup_go_project my_go_service	
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

<h3>⚛️ React Frontend</h3>

```bash
setup_react_frontend my_react_app
```

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

<h3>🌐 Next.js Projects</h3>

```bash
cd my_nextjs_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
pnpm dev    # Starts development server
```

<h3>🌐 Full-Stack Web Applications</h3>

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

## 💻 Technology Stack

<div align="center">

| Category | Technologies |
|----------|--------------|
| **Frontend** | React, TypeScript, Material UI, Emotion |
| **Backend** | Next.js, Flask, Go, Express |
| **State Management** | React Query, Zustand |
| **API Integration** | Axios, Fetch API |
| **Tooling** | ESLint, Prettier, Jest |

</div>

## 🧪 Testing and Quality Assurance

<p align="center"><strong>Each project template includes built-in testing capabilities:</strong></p>

<h3>🐍 Python Projects</h3>

```bash
cd my_python_project	
make test      # Runs pytest	
make lint      # Runs flake8	
make format    # Runs black and isort	
```

<h3>🚀 Node.js Projects</h3>

```bash
cd my_node_project	
npm run test   # Runs tests	
npm run lint   # Runs ESLint	
```

<h3>🔷 Go Projects</h3>

```bash
cd my_go_project	
make test      # Runs go test	
make vet       # Runs go vet	
make fmt       # Runs go fmt	
```

<h3>⚛️ React Projects</h3>

```bash
cd my_react_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
```

<h3>🌐 Next.js Projects</h3>

```bash
cd my_nextjs_app
pnpm test   # Runs Jest tests
pnpm lint   # Runs ESLint
pnpm build  # Creates production build
pnpm dev    # Starts development server
```

## 📦 Package Management

CraftingBench now uses [pnpm](https://pnpm.io/) as the preferred package manager for TypeScript projects. PNPM offers several advantages:

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

For React and Next.js templates, commands automatically use pnpm:

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

| Resource | Description |
|----------|-------------|
| [GitHub CLI Documentation](https://cli.github.com/manual/) | Documentation for the GitHub CLI |
| [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/) | Best practices for Python project structure |
| [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices) | Comprehensive guide for Node.js projects |
| [Go Project Layout](https://github.com/golang-standards/project-layout) | Standard Go project structure |
| [Zsh Documentation](https://zsh.sourceforge.io/Doc/) | Documentation for Zsh shell |

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
