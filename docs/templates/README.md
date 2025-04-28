<div align="center">

# 🧰 Templates

**Powerful templates to jumpstart your development journey with style and best practices**

</div>

______________________________________________________________________

## 📋 Available Templates

<div align="center">

| Icon | Template | Command | Description |
|:----:|:--------:|:-------:|:------------|
| 🐍 | **Python** | `setup_python_project` | Modern Python package with testing, linting, and CI/CD setup |
| 🚀 | **Node.js** | `setup_nodejs_backend` | Express-based API with TypeScript and testing framework |
| 🔷 | **Go** | `setup_go_project` | Go-based REST API with standard project layout |
| ⚛️ | **React** | `setup_react_frontend` | TypeScript + React application with modern tooling |
| 🌐 | **Next.js** | `setup_fullstack_project` | Next.js app with built-in API routes and state management |

</div>

______________________________________________________________________

## 🔍 Template Details

<h3>🐍 Python Project</h3>

<div align="center">

**A modern Python package scaffold with all the essential tools for professional development**

</div>

#### ✨ Features

- 📦 Project structure following Python packaging standards
- 🛠️ Modern `pyproject.toml` configuration
- 🧪 Testing with pytest
- 🧹 Linting with flake8, black, and isort
- 📊 Dependency management
- ⚙️ Makefile for common tasks

#### 📂 Generated Structure

```
my_python_project/
├── .gitignore
├── .python-version
├── Makefile
├── README.md
├── main.py
├── my_python_project/
│   └── __init__.py
├── pyproject.toml
└── tests/
    └── test_main.py
```

______________________________________________________________________

<h3>🚀 Node.js Backend</h3>

<div align="center">

**A robust Express-based API boilerplate with MVC architecture and best practices**

</div>

#### ✨ Features

- 🏗️ MVC architecture with controllers, models, and routes
- 🔄 Middleware integration
- 🧪 Testing setup with Jest
- 🧹 ESLint configuration
- 🔐 Environment variable management
- ⚠️ Error handling

#### 📂 Generated Structure

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

______________________________________________________________________

<h3>🔷 Go Project</h3>

<div align="center">

**A clean Go application structure following industry standard layout and practices**

</div>

#### ✨ Features

- 📁 Command and package separation
- 🔒 Internal and external package organization
- 🧪 Testing structure
- 🛠️ Makefile for build, test, and other tasks
- 📦 Proper module configuration

#### 📂 Generated Structure

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

______________________________________________________________________

<h3>⚛️ React Frontend</h3>

<div align="center">

**A modern React application with TypeScript, component organization, and development tools**

</div>

#### ✨ Features

- ⚛️ React with TypeScript setup
- ⚡ Modern tooling with Vite
- 🧩 Component organization
- 🗃️ State management
- 🧭 Routing
- 🔄 API integration

<div align="center">

> 🚧 **Note**: This template is currently in development.

</div>

#### 📂 Generated Structure

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

______________________________________________________________________

<h3>🌐 Full-Stack Web (Next.js)</h3>

<div align="center">

**A complete Next.js application with both frontend and backend capabilities in one project**

</div>

#### ✨ Features

- 📱 Next.js with App Router
- 🔷 TypeScript configuration
- 🎨 TailwindCSS integration
- 🚀 API Routes
- 🗃️ State Management with Zustand
- 🔄 Server State with React Query
- 🔐 Authentication system
- 🗂️ Database integration

<div align="center">

> 🚧 **Note**: This template is currently in development.

</div>

#### 📂 Generated Structure

```
my_nextjs_app/
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

______________________________________________________________________

## 🛠️ Creating a New Template

<div align="center">

**Want to contribute a new template? Follow these steps to expand CraftingBench.**

</div>

1. Create a new shell script in the `src/templates/` directory
1. Source the common helper functions
1. Implement a main function named `setup_<technology>_project`
1. Add the template to the main `craftingbench.sh` file
1. Update documentation and shell completions

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
```

<div align="center">

______________________________________________________________________

**Happy crafting!** 🛠️

</div>
