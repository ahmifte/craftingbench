#!/usr/bin/env bash

# Setup Zsh completion if we're in Zsh
setup_zsh_completions() {
  if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && command -v compdef >/dev/null 2>&1; then
    # Register command completions
    function _craftingbench_completions() {
      local commands=(
        "setup_python_project:Create a Python project"
        "setup_nodejs_backend:Create a Node.js backend"
        "setup_react_frontend:Create a React frontend"
        "setup_go_project:Create a Golang project"
        "setup_fullstack_project:Create a Next.js fullstack app with state management"
      )
      _describe 'CraftingBench commands' commands
    }
    compdef _craftingbench_completions setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project
  fi
}

# Print a banner with available commands
show_banner() {
  echo "🛠️  CraftingBench loaded!"
  echo "Available commands:"
  echo "  - setup_python_project <name>     : Create a Python project"
  echo "  - setup_nodejs_backend <name>     : Create a Node.js backend"
  echo "  - setup_react_frontend <name>     : Create a React frontend (coming soon)"
  echo "  - setup_go_project <name>         : Create a Golang project"
  echo "  - setup_fullstack_project <name>  : Create a Next.js fullstack app (coming soon)"
} 