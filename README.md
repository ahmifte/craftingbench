# 🛠️ CraftingBench

A powerful utility for quickly scaffolding various project types with standardized, production-ready structures.

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash Script](https://img.shields.io/badge/language-bash-green.svg)](craftingbench.sh)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/yourusername/craftingbench/pulls)

<div align="center">
  <img src="https://via.placeholder.com/150?text=CraftingBench" alt="CraftingBench Logo" width="150" height="150">
  <p><em>Craft your projects with precision and speed</em></p>
</div>

---

## ✨ Features

CraftingBench provides templates for various project types:

- **Python Projects**: Modern Python package with testing, linting, and CI/CD setup
- **Node.js Backend**: Express-based API with TypeScript and testing framework
- **React Frontend**: TypeScript + React application with modern tooling
- **Golang API**: Go-based REST API with standard project layout
- **Full-Stack Web**: Combined backend/frontend setup with best practices
- **Docker Containerized**: Projects with Docker and Docker Compose configuration

## 🚀 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/craftingbench.git
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
compdef _gnu_generic setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project setup_plain_project
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

Each project template is created with a single command:

### Python Project

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

### Node.js Backend (Express + TypeScript)

```bash
setup_nodejs_backend my_api_service
```

Generated structure:
```
my_api_service/
├── .eslintrc.js
├── .gitignore
├── .prettierrc
├── README.md
├── jest.config.js
├── package.json
├── src/
│   ├── app.ts
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   └── server.ts
├── tests/
│   └── app.test.ts
└── tsconfig.json
```

### React Frontend (TypeScript)

```bash
setup_react_frontend my_web_app
```

Generated structure:
```
my_web_app/
├── .eslintrc.js
├── .gitignore
├── .prettierrc
├── README.md
├── index.html
├── package.json
├── public/
├── src/
│   ├── App.tsx
│   ├── components/
│   ├── hooks/
│   ├── pages/
│   └── main.tsx
├── tests/
└── tsconfig.json
```

### Golang API

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
│   └── server/
│       └── main.go
├── go.mod
├── go.sum
├── internal/
│   ├── api/
│   ├── config/
│   └── models/
└── test/
```

### Full-Stack Web Application

```bash
setup_fullstack_project my_web_platform
```

### Basic Project (Minimal Setup)

```bash
setup_plain_project my_simple_project
```

Generated structure:
```
my_simple_project/
├── .gitignore
├── Makefile
├── README.md
└── tests/
    └── .gitkeep
```

## 🔧 What's Included

Each template includes:

- **Git Integration**: Initialized repository with sensible .gitignore
- **GitHub Automation**: Repository creation and PR workflow (if GitHub CLI is available)
- **Testing Framework**: Language-appropriate testing setup
- **Code Quality Tools**: Linting and formatting configured
- **Documentation**: Basic README and usage examples
- **CI/CD**: GitHub Actions workflows for testing and deployment
- **Dependency Management**: Modern package management approaches

## 📦 Requirements

- Git
- Language-specific tools depending on project type:
  - Python 3.8+ for Python projects
  - Node.js 16+ for JavaScript/TypeScript projects
  - Go 1.18+ for Golang projects
- GitHub CLI (optional, for GitHub integration)

## 🧪 Testing and Quality Assurance

Each project template includes built-in testing capabilities:

### Python Projects

```bash
cd my_python_project
make test      # Runs pytest
make lint      # Runs flake8
make format    # Runs black and isort
```

### Node.js/React Projects

```bash
cd my_node_project
npm run test       # Runs Jest tests
npm run lint       # Runs ESLint
npm run format     # Runs Prettier
```

### Go Projects

```bash
cd my_go_project
make test      # Runs go test
make lint      # Runs golangci-lint
```

### Plain Projects

```bash
cd my_simple_project
make help      # Shows available commands
make test      # Runs basic tests
```

## 📝 Project Structure Conventions

CraftingBench follows these conventions for all projects:

1. **Separation of Concerns**: Code is organized to separate business logic, interfaces, and data.
2. **Configuration Management**: Environment-specific settings are separated from application code.
3. **Testing Strategy**: Tests are organized by type (unit, integration, e2e).
4. **Documentation**: All projects include comprehensive README and inline documentation.

## 🤝 Contributing

Contributions are welcome! Feel free to add new project templates or improve existing ones.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-template`)
3. Commit your changes (`git commit -m 'Add amazing template'`)
4. Push to the branch (`git push origin feature/amazing-template`)
5. Open a Pull Request

### Development

To add a new template:

1. Create a new function in `craftingbench.sh` following the naming pattern `setup_[platform]_project`
2. Follow the existing patterns for parameter validation and GitHub integration
3. Add documentation to this README
4. Test your template thoroughly

## 🔍 Troubleshooting

Common issues and their solutions:

- **Permission Denied**: Make sure `craftingbench.sh` is executable (`chmod +x craftingbench.sh`)
- **Command Not Found**: Ensure your shell configuration file is properly sourced
- **GitHub Authentication**: Run `gh auth login` if GitHub integration isn't working
- **Repository Creation Failed**: Check your GitHub token and permissions
- **Zsh Completion Not Working**: Make sure you have compinit loaded in your `.zshrc` file

## 📚 Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [React Project Structure](https://reactjs.org/docs/faq-structure.html)
- [Go Project Layout](https://github.com/golang-standards/project-layout)
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)

## 📜 License

MIT 