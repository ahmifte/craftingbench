# 🏗️ CraftingBench Architecture

<div align="center">

**CraftingBench is designed with a modular architecture to promote maintainability, extensibility, and code reuse.**

</div>

---

## 📂 Project Structure

```
craftingbench/
├── craftingbench.sh         # Main entry point script
├── src/                     # Source code
│   ├── helpers/             # Helper functions
│   │   └── common.sh        # Common utility functions
│   ├── templates/           # Project templates
│   │   ├── python.sh        # Python project template
│   │   ├── nodejs.sh        # Node.js backend template
│   │   ├── go.sh            # Go project template
│   │   ├── react.sh         # React frontend template
│   │   └── fullstack.sh     # Next.js fullstack template
│   └── completions/         # Shell completions
│       └── shell.sh         # Zsh/Bash completion definitions
├── docs/                    # Documentation
│   ├── architecture.md      # Architecture documentation
│   └── templates/           # Template-specific documentation
└── README.md                # Main documentation
```

---

## 🧩 Component Overview

### 🔍 Main Script (`craftingbench.sh`)

<div align="center">

**The main script serves as the entry point for CraftingBench.**

</div>

- 📥 Loads helper functions
- 🔌 Sources project templates
- 🛠️ Sets up shell completions
- 🖥️ Provides the main banner/interface

### 🛠️ Helper Functions (`src/helpers/`)

<div align="center">

**Common utility functions used across multiple templates.**

</div>

- ✅ Dependency checking
- 🔍 Command existence verification
- 🔗 GitHub integration helpers

### 📦 Project Templates (`src/templates/`)

<div align="center">

**Each template is contained in its own file for better separation of concerns.**

</div>

| File | Description |
|------|-------------|
| `python.sh` | 🐍 Python project setup |
| `nodejs.sh` | 🚀 Node.js backend setup |
| `go.sh` | 🔷 Go project setup |
| `react.sh` | ⚛️ React frontend setup |
| `fullstack.sh` | 🌐 Next.js fullstack setup |

### 🔄 Shell Completions (`src/completions/`)

<div align="center">

**Provides shell completion functionality for supported shells.**

</div>

- Zsh completion for all template commands
- Bash completion support (planned) 