# 🏗️ Architecture

[![Version](https://img.shields.io/badge/Version-0.2.0%20(Beta)-orange.svg)](../CHANGELOG.md)

This document outlines the architectural design of CraftingBench v0.2.0.

## 📂 Project Structure

```
craftingbench/
├── craftingbench.sh         # Main entry point script
├── src/                     # Source code
│   ├── helpers/             # Helper functions
│   │   └── common.sh        # Common utility functions
│   ├── templates/           # Project templates
│   │   ├── python.sh        # Python project template
│   │   ├── nodejs.sh        # TypeScript Node.js backend template
│   │   ├── go.sh            # Go project template
│   │   ├── react.sh         # TypeScript React frontend template
│   │   └── fullstack.sh     # TypeScript fullstack template (Next.js/Flask/Go)
│   └── completions/         # Shell completions
│       └── shell.sh         # Zsh/Bash completion definitions
├── docs/                    # Documentation
│   ├── USER_GUIDE.md        # Comprehensive user guide
│   ├── RELEASING.md         # Release process documentation
│   ├── architecture.md      # Architecture documentation
│   └── templates/           # Template-specific documentation
├── SECURITY.md              # Security policy
├── CHANGELOG.md             # Version changelog
└── README.md                # Main documentation
```

______________________________________________________________________

## 🧩 Component Overview

### 🔍 Main Script (`craftingbench.sh`)

**The main script serves as the entry point for CraftingBench.**

- 📥 Loads helper functions
- 🔌 Sources project templates
- 🛠️ Sets up shell completions
- 🖥️ Provides the main banner/interface

### 🛠️ Helper Functions (`src/helpers/`)

**Common utility functions used across multiple templates.**

- ✅ Dependency checking
- 🔍 Command existence verification
- 🔗 GitHub integration helpers

### 📦 Project Templates (`src/templates/`)

**Each template is contained in its own file for better separation of concerns.**

| File | Description |
|------|-------------|
| `python.sh` | 🐍 Python project setup |
| `nodejs.sh` | 🚀 TypeScript Node.js backend setup |
| `go.sh` | 🔷 Go project setup |
| `react.sh` | ⚛️ TypeScript React frontend with Material UI |
| `fullstack.sh` | 🌐 TypeScript fullstack setup with Material UI (Next.js/Flask/Go) |

### 🔄 Shell Completions (`src/completions/`)

**Provides shell completion functionality for supported shells.**

- Zsh completion for all template commands
- Command and option completion for fullstack backends

## 🔄 Installation & Release Workflow

CraftingBench uses GitHub Releases for distribution:

1. Versioned releases are tagged with `v*` format (e.g., `v0.2.0`)
2. GitHub Actions automatically build release assets
3. The `install.sh` script downloads the appropriate release

For detailed information on the release process, see [RELEASING.md](RELEASING.md).

## 📖 Documentation

CraftingBench documentation is structured as follows:

- **README.md**: Project overview and quick start
- **USER_GUIDE.md**: Comprehensive usage instructions
- **architecture.md**: This document, explaining the system design
- **templates/README.md**: Detailed information about each template
- **SECURITY.md**: Security policy and vulnerability reporting
- **CHANGELOG.md**: Version history and changes

## 🔒 Security Considerations

- Template scripts run with user privileges
- External dependencies are verified before installation
- GitHub integration is optional

For detailed security information, see [SECURITY.md](../SECURITY.md).

## 📚 Additional Resources

- [User Guide](USER_GUIDE.md): Detailed usage instructions
- [Template Documentation](templates/README.md): In-depth template details
