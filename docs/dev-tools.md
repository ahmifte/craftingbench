# Development Tools

This document outlines the development tools included in CraftingBench, how to use them, and how they work together.

## Pre-commit Hooks

CraftingBench includes a pre-configured setup for [pre-commit](https://pre-commit.com/), a framework for managing git pre-commit hooks. These hooks run automatically before each commit to catch issues early.

### Setup

1. Install pre-commit:

```bash
pip install pre-commit
```

2. Install the hooks:

```bash
pre-commit install
```

### Available Hooks

CraftingBench includes the following pre-commit hooks:

| Hook                      | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `trailing-whitespace`     | Removes trailing whitespace                               |
| `end-of-file-fixer`       | Ensures files end with a newline                          |
| `check-yaml`              | Validates YAML syntax                                     |
| `check-json`              | Validates JSON syntax                                     |
| `check-added-large-files` | Prevents committing large files                           |
| `check-case-conflict`     | Checks for case conflicts on case-insensitive filesystems |
| `mixed-line-ending`       | Normalizes line endings to LF                             |
| `detect-private-key`      | Prevents accidental commit of private keys                |
| `shellcheck`              | Lints shell scripts using shellcheck                      |
| `isort`                   | Sorts Python imports                                      |
| `black`                   | Formats Python code                                       |
| `eslint`                  | Lints JavaScript/TypeScript code                          |
| `prettier`                | Formats code for multiple languages                       |

### Using Pre-commit

The hooks run automatically on `git commit`. If any issues are found, the commit is prevented, and you'll need to fix the issues before committing.

You can manually run the hooks on all files:

```bash
pre-commit run --all-files
```

Or on specific hooks:

```bash
pre-commit run <hook-id>
```

### Configuration

The pre-commit configuration is stored in `.pre-commit-config.yaml` in the root directory. You can customize it by:

1. Adding new hooks
2. Changing hook options
3. Updating hook versions

## GitHub Actions

All project templates in CraftingBench include GitHub Actions workflows for continuous integration and delivery. These workflows are stored in `.github/workflows/` in the generated projects.

### Common Workflow Features

- Multiple language version testing (Python, Node.js, Go)
- Dependency caching for faster builds
- Linting and type checking
- Unit tests with coverage reporting
- Optional Codecov integration
- Build artifact uploads

### Customizing Workflows

You can customize the GitHub Actions workflows for your projects:

1. Edit the workflow templates in `src/templates/github-workflows/`
2. Run the update-templates script to apply changes: `./src/templates/update-templates.sh`

## Package Management

CraftingBench uses modern package managers for different languages:

### Python

- Default: Uses pip
- Enhanced: Uses [uv](https://github.com/astral-sh/uv) if available
- Includes virtual environment management

### Node.js

- Default: npm
- Preferred: [pnpm](https://pnpm.io/) for faster, disk-space efficient dependency management
- Setup with proper lockfile management

### Go

- Uses standard Go modules
- Includes dependency verification
- Vendor directory support

## Additional Development Tools

Each project template includes additional development tools:

### Node.js and React

```bash
# Linting
pnpm lint

# Type checking
pnpm type-check

# Testing
pnpm test
pnpm test:watch
pnpm test:coverage

# Building
pnpm build
```

### Python

```bash
# Using Makefile commands
make install       # Install dependencies
make test          # Run tests
make lint          # Run linting
make format        # Format code
make clean         # Clean build artifacts
```

### Go

```bash
# Using Makefile commands
make build         # Build the application
make run           # Run the application
make test          # Run tests
make lint          # Run linter
make clean         # Clean build artifacts
```

## Editor Integration

CraftingBench projects include configuration for popular editors:

### VS Code

- `.vscode/extensions.json`: Recommended extensions
- `.vscode/settings.json`: Editor settings for consistent formatting

### JetBrains IDEs

- `.idea/` settings for consistent formatting and code style

## Adding Custom Development Tools

To add custom development tools:

1. Edit the template scripts in `src/templates/`
2. Add your custom tools and configurations
3. Update this documentation to reflect the changes
