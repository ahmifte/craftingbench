#!/usr/bin/env bash

# Setup Zsh completion if we're in Zsh
setup_zsh_completions() {
  if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && command -v compdef >/dev/null 2>&1; then
    # Register command completions
    function _craftingbench_completions() {
      local commands=(
        "setup_python_project:Create a Python project (library or backend)"
        "setup_python_library:Create a Python library"
        "setup_python_backend:Create a Flask API backend"
        "setup_nodejs_backend:Create a Node.js backend"
        "setup_react_frontend:Create a React frontend"
        "setup_go_project:Create a Golang project (library or backend)"
        "setup_go_library:Create a Golang library/module"
        "setup_go_backend:Create a Golang REST API backend"
        "setup_fullstack_project:Create a fullstack application with various backends"
      )
      _describe 'CraftingBench commands' commands
    }
    compdef _craftingbench_completions setup_python_project setup_python_library setup_python_backend setup_nodejs_backend setup_react_frontend setup_go_project setup_go_library setup_go_backend setup_fullstack_project
  fi
}

# Print a banner with available commands
show_banner() {
  echo "🛠️  CraftingBench loaded!"
  echo "Available commands:"
  echo ""
  echo "Python:"
  echo "  - setup_python_project <name> [--type=library|backend] : Create a Python project"
  echo "  - setup_python_library <name>                          : Create a Python library"
  echo "  - setup_python_backend <name>                          : Create a Flask API backend"
  echo ""
  echo "JavaScript/TypeScript:"
  echo "  - setup_nodejs_backend <name>                          : Create a Node.js backend"
  echo "  - setup_react_frontend <name>                          : Create a React frontend"
  echo ""
  echo "Go:"
  echo "  - setup_go_project <name> [--type=library|backend]     : Create a Golang project"
  echo "  - setup_go_library <name>                              : Create a Golang library/module"
  echo "  - setup_go_backend <name>                              : Create a Golang REST API backend"
  echo ""
  echo "Fullstack:"
  echo "  - setup_fullstack_project <name> [--backend=nextjs|flask|golang] : Create a fullstack application"
} 