# 📚 Templates

<div align="center">

**Crafting Bench provides powerful templates to jumpstart your development journey.**  
Each template follows industry best practices and modern architecture patterns.

</div>

---

## 🧰 Available Templates

| Icon | Template | Command | Source | Description |
|:----:|----------|---------|--------|-------------|
| 🐍 | **Python** | `setup_python_project` | [python.sh](../../src/templates/python.sh) | Modern Python package with testing, linting, and CI/CD setup |
| 🚀 | **Node.js Backend** | `setup_nodejs_backend` | [nodejs.sh](../../src/templates/nodejs.sh) | Express-based API with best practices |
| 🔷 | **Go** | `setup_go_project` | [go.sh](../../src/templates/go.sh) | Go-based application with standard project layout |
| ⚛️ | **React Frontend** | `setup_react_frontend` | [react.sh](../../src/templates/react.sh) | TypeScript + React application with modern tooling |
| 🌐 | **Full-Stack Web** | `setup_fullstack_project` | [fullstack.sh](../../src/templates/fullstack.sh) | Next.js app with built-in API routes and state management |

---

## 🔍 Template Details


<summary><h3>🐍 Python Project</h3></summary>

The Python template creates a modern Python package with best practices for professional development.

#### ✨ Features

- 📁 Project structure following Python packaging standards
- 📄 Modern `pyproject.toml` configuration
- 🧪 Testing with pytest
- 🧹 Linting with flake8, black, and isort
- 📦 Dependency management
- 🛠️ Makefile for common tasks

#### 📊 Generated Structure

```
project_name/
├── .gitignore
├── .python-version
├── Makefile
├── README.md
├── main.py
├── project_name/
│   └── __init__.py
├── pyproject.toml
└── tests/
    └── test_main.py
```

---


<summary><h3>🚀 Node.js Backend</h3></summary>

The Node.js backend template sets up an Express-based API ready for rapid development.

#### ✨ Features

- 🏗️ MVC architecture with controllers, models, and routes
- 🔄 Middleware integration
- 🧪 Testing setup with Jest
- 🧹 ESLint configuration
- 🔐 Environment variable management
- ⚠️ Error handling

#### 📊 Generated Structure

```
project_name/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── src/
│   ├── index.js
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── middleware/
│   └── utils/
└── tests/
```

---


<summary><h3>🔷 Go Project</h3></summary>

The Go template follows the standard Go project layout for maintainable applications.

#### ✨ Features

- 📁 Command and package separation
- 🔒 Internal and external package organization
- 🧪 Testing structure
- 🛠️ Makefile for build, test, and other tasks
- 📦 Proper module configuration

#### 📊 Generated Structure

```
project_name/
├── .gitignore
├── Makefile
├── README.md
├── cmd/
│   └── project_name/
│       └── main.go
├── go.mod
├── internal/
│   ├── app/
│   └── pkg/
├── pkg/
└── test/
```

---


<summary><h3>⚛️ React Frontend</h3></summary>

The React frontend template provides a TypeScript-based React application scaffold.

#### ✨ Features

- ⚛️ React with TypeScript setup
- ⚡ Modern tooling with Vite
- 🧩 Component organization
- 🗃️ State management
- 🧭 Routing
- 🔄 API integration

> 🚧 **Note**: This template is currently in development.

#### 📊 Generated Structure

```
project_name/
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

---


<summary><h3>🌐 Full-Stack Web (Next.js)</h3></summary>

The Next.js template delivers a complete full-stack application environment.

#### ✨ Features

- 📱 Next.js with App Router
- 🔷 TypeScript configuration
- 🎨 TailwindCSS integration
- 🚀 API Routes
- 🗃️ State Management with Zustand
- 🔄 Server State with React Query
- 🔐 Authentication system
- 🗂️ Database integration

> 🚧 **Note**: This template is currently in development.

#### 📊 Generated Structure

```
project_name/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── public/
│   └── favicon.ico
├── src/
│   ├── pages/
│   │   ├── index.tsx
│   │   ├── _app.tsx
│   │   └── api/
│   ├── components/
│   └── styles/
└── tsconfig.json
```

---

---

## 🛠️ Creating a New Template

<div align="center">

**Want to contribute a new template?** Follow these steps:

</div>

1. Create a new shell script in the `src/templates/` directory
2. Make sure it sources the common helper functions
3. Implement a single main function named `setup_<technology>_project`
4. Add the template to the main `craftingbench.sh` file
5. Update documentation and shell completions

### 📝 Template Structure

All templates should follow this basic structure:

```bash
#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh"

setup_<technology>_project() {
  # 1. Validate arguments
  # 2. Check dependencies
  # 3. Create project structure
  # 4. Generate configuration files
  # 5. Initialize version control
  # 6. Display next steps
} 