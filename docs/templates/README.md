# CraftingBench Templates

CraftingBench provides several project templates to jumpstart your development. Each template is designed to follow best practices for that specific technology stack.

## Available Templates

| Template | Command | Source File | Description |
|----------|---------|-------------|-------------|
| Python | `setup_python_project` | [python.sh](../../src/templates/python.sh) | Modern Python package with testing, linting, and CI/CD setup |
| Node.js Backend | `setup_nodejs_backend` | [nodejs.sh](../../src/templates/nodejs.sh) | Express-based API with best practices |
| Go | `setup_go_project` | [go.sh](../../src/templates/go.sh) | Go-based application with standard project layout |
| React Frontend | `setup_react_frontend` | [react.sh](../../src/templates/react.sh) | TypeScript + React application with modern tooling |
| Full-Stack Web | `setup_fullstack_project` | [fullstack.sh](../../src/templates/fullstack.sh) | Next.js app with built-in API routes and state management |

## Template Details

### Python Project

The Python template creates a modern Python package with best practices:

- Project structure following Python packaging standards
- Modern `pyproject.toml` configuration
- Testing with pytest
- Linting with flake8, black, and isort
- Dependency management
- Makefile for common tasks

### Node.js Backend

The Node.js backend template sets up an Express-based API:

- MVC architecture with controllers, models, and routes
- Middleware integration
- Testing setup with Jest
- ESLint configuration
- Environment variable management
- Error handling

### Go Project

The Go template follows the standard Go project layout:

- Command and package separation
- Internal and external package organization
- Testing structure
- Makefile for build, test, and other tasks
- Proper module configuration

### React Frontend

The React frontend template (in development) will include:

- React with TypeScript setup
- Modern tooling with Vite
- Component organization
- State management
- Routing
- API integration

### Full-Stack Web (Next.js)

The Next.js template (in development) will provide:

- Next.js with App Router
- TypeScript configuration
- TailwindCSS integration
- API Routes
- State Management with Zustand
- Server State with React Query
- Authentication system
- Database integration

## Creating a New Template

To add a new template to CraftingBench:

1. Create a new shell script in the `src/templates/` directory
2. Make sure it sources the common helper functions
3. Implement a single main function named `setup_<technology>_project`
4. Add the template to the main `craftingbench.sh` file
5. Update documentation and shell completions

### Template Structure

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