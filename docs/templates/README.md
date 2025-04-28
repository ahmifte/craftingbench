# CraftingBench Templates

CraftingBench provides several project templates to jumpstart your development. Each template is designed to follow best practices for that specific technology stack.

## Available Templates

| Template | Command | Source File | Description |
|----------|---------|-------------|-------------|
| Python | `setup_python_project` | [python.sh](../../src/templates/python.sh) | Modern Python package with testing, linting, and CI/CD setup |
| Node.js Backend | `setup_nodejs_backend` | [nodejs.sh](../../src/templates/nodejs.sh) | Express-based API with best practices |
| Go | `setup_go_project` | [go.sh](../../src/templates/go.sh) | Go-based application with standard project layout |

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