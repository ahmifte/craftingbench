#!/usr/bin/env bash
# Shell completion for CraftingBench commands

# Setup Zsh completions
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

      # Different completions for different command stages
      # shellcheck disable=SC2154
      if [[ "${words[1]}" == "setup_fullstack_project" ]]; then
        # shellcheck disable=SC2034
        local -a backend_options
        # Export backend_options for Zsh completion
        export backend_options=(
          "--backend=nextjs:Use Next.js (default)"
          "--backend=flask:Use Flask backend + TypeScript React frontend"
          "--backend=golang:Use Go backend + TypeScript React frontend"
        )
        _describe "backend option" backend_options
        return
      fi

      # First argument: complete command name
      if (( CURRENT == 1 )); then
        _describe "craftingbench commands" commands
        return
      fi

      # Handle tool subcommands (lint, format, etc.)
      # shellcheck disable=SC2034
      local -a tools
      # Export tools for Zsh completion
      export tools=(
        "lint:Run ESLint on TypeScript code"
        "format:Format code with Prettier"
        "typecheck:Run TypeScript type checking"
        "test:Run tests"
        "build:Build production version"
        "dev:Start development server"
      )

      case "${words[1]}" in
        lint|format|typecheck|test|build|dev)
          _describe "tool options" tools
          ;;
        *)
          # Fall back to file completion
          _files
          ;;
      esac
    }
    
    compdef _craftingbench_completions setup_python_project setup_python_library setup_python_backend setup_nodejs_backend setup_react_frontend setup_go_project setup_go_library setup_go_backend setup_fullstack_project
    compdef _craftingbench_project_tools lint format typecheck
  fi
}

# Initialize banner tracking variable
CRAFTINGBENCH_BANNER_SHOWN=0

# Print a banner with available commands
show_banner() {
  # Only show banner once per session
  if [ "$CRAFTINGBENCH_BANNER_SHOWN" -eq 0 ]; then
    echo "🛠️  CraftingBench loaded!"
    echo "Available commands:"
    echo ""
    echo "Python:"
    echo "  - setup_python_project <n> [--type=library|backend] : Create a Python project"
    echo "  - setup_python_library <n>                          : Create a Python library"
    echo "  - setup_python_backend <n>                          : Create a Flask API backend"
    echo ""
    echo "JavaScript/TypeScript:"
    echo "  - setup_nodejs_backend <n>                          : Create a Node.js backend"
    echo "  - setup_react_frontend <n>                          : Create a React frontend"
    echo ""
    echo "Go:"
    echo "  - setup_go_project <n> [--type=library|backend]     : Create a Golang project"
    echo "  - setup_go_library <n>                              : Create a Golang library/module"
    echo "  - setup_go_backend <n>                              : Create a Golang REST API backend"
    echo ""
    echo "Fullstack:"
    echo "  - setup_fullstack_project <n> [--backend=nextjs|flask|golang] : Create a fullstack application"
    echo ""
    echo "Development tools:"
    echo "  - lint                              : Run ESLint on TypeScript code"
    echo "  - format                            : Format code with Prettier"
    echo "  - typecheck                         : Run TypeScript type checking"
    
    # Set the flag so it won't be shown again
    CRAFTINGBENCH_BANNER_SHOWN=1
  fi
}
