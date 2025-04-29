#!/usr/bin/env bash

# Setup Zsh completion if we're in Zsh
setup_zsh_completions() {
  if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && command -v compdef >/dev/null 2>&1; then
    # Register command completions
    function _craftingbench_completions() {
      local commands=(
        "setup_python_project:Create a Python project"
        "setup_nodejs_backend:Create a TypeScript Node.js backend"
        "setup_react_frontend:Create a TypeScript React frontend"
        "setup_go_project:Create a Golang project"
        "setup_fullstack_project:Create a TypeScript fullstack app with various backend options"
      )
      
      # Add options for fullstack_project
      if [[ $words[1] == "setup_fullstack_project" ]]; then
        local backend_options=(
          "--backend=nextjs:Use Next.js as the backend (default)"
          "--backend=flask:Use Flask as the backend"
          "--backend=golang:Use Go as the backend"
        )
        _describe 'Backend options' backend_options
      fi
      
      _describe 'CraftingBench commands' commands
    }
    
    # Register linting and formatting commands
    function _craftingbench_project_tools() {
      local tools=(
        "lint:Run ESLint on the TypeScript code"
        "format:Format code with Prettier"
        "typecheck:Run TypeScript type checking"
      )
      _describe 'Project tools' tools
    }
    
    compdef _craftingbench_completions setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project
    compdef _craftingbench_project_tools lint format typecheck
  fi
}

# Print a banner with available commands
show_banner() {
  echo "🛠️  CraftingBench loaded!"
  echo "Available commands:"
  echo "  - setup_python_project <name>       : Create a Python project"
  echo "  - setup_nodejs_backend <name>       : Create a TypeScript Node.js backend"
  echo "  - setup_react_frontend <name>       : Create a TypeScript React frontend with Material UI"
  echo "  - setup_go_project <name>           : Create a Golang project"
  echo "  - setup_fullstack_project <name>    : Create a TypeScript fullstack app"
  echo "    Options:"
  echo "      --backend=nextjs                : Use Next.js (default)"
  echo "      --backend=flask                 : Use Flask backend + TypeScript React frontend"
  echo "      --backend=golang                : Use Go backend + TypeScript React frontend"
  echo ""
  echo "Development tools:"
  echo "  - lint                              : Run ESLint on TypeScript code"
  echo "  - format                            : Format code with Prettier"
  echo "  - typecheck                         : Run TypeScript type checking"
} 