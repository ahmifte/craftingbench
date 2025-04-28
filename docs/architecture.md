# 🏗️ Architecture

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
| `nodejs.sh` | 🚀 Node.js backend setup |
| `go.sh` | 🔷 Go project setup |
| `react.sh` | ⚛️ React frontend setup |
| `fullstack.sh` | 🌐 Next.js fullstack setup |

### 🔄 Shell Completions (`src/completions/`)

**Provides shell completion functionality for supported shells.**

- Zsh completion for all template commands
- Bash completion support (planned) 