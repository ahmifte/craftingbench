#!/usr/bin/env bash
# Shell completion for CraftingBench commands

# Setup Zsh completions
setup_zsh_completions() {
  if [ -n "$ZSH_VERSION" ]; then
    # Define completions for different commands
    _craftingbench_completions() {
      # Zsh completion uses these arrays with _describe, but shellcheck can't detect the connection
      # These arrays appear unused to shellcheck but are necessary for Zsh completion
      # shellcheck disable=SC2034

      # The following allows shellcheck to know that 'words' is defined in Zsh
      # shellcheck disable=SC2154
      local -a commands
      # Export commands for Zsh completion
      export commands=(
        "setup_python_project:Create a Python project"
        "setup_nodejs_backend:Create a TypeScript Node.js backend"
        "setup_react_frontend:Create a TypeScript React frontend with Material UI"
        "setup_go_project:Create a Golang project"
        "setup_fullstack_project:Create a TypeScript fullstack app"
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

    # Register the completion function
    compdef _craftingbench_completions setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project lint format typecheck
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
