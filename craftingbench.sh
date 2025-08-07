#!/usr/bin/env bash

# ================================================================
# CraftingBench - A utility for creating standardized project templates
# ================================================================
# Version: 0.3.0
# MIT License - Copyright (c) 2025 CraftingBench Contributors

# DESCRIPTION:
#   CraftingBench is a shell utility for quickly scaffolding various
#   project types with standardized, production-ready structures.
#   It streamlines project creation by automating the setup of
#   common development environments and best practices.

# USAGE:
#   source ./craftingbench.sh
#
#   Python:
#   setup_python_project <project_name> [--type=library|backend]
#   setup_python_library <project_name>
#   setup_python_backend <project_name>
#
#   Python with Docker:
#   setup_python_docker_project <project_name> [--type=api|cli] [--ai-ready]
#   setup_python_docker_api <project_name>
#   setup_python_docker_cli <project_name>
#
#   Go:
#   setup_go_project <project_name> [--type=library|backend]
#   setup_go_library <project_name>
#   setup_go_backend <project_name>
#
#   JavaScript/TypeScript:
#   setup_nodejs_backend <project_name>
#   setup_react_frontend <project_name>
#
#   Fullstack:
#   setup_fullstack_project <project_name> [--backend=nextjs|flask|golang]

# For more information, visit: https://github.com/ahmifte/craftingbench
# ================================================================

# Get the directory of this script
# Handle both sourcing and direct execution
if [ -n "${BASH_SOURCE[0]}" ]; then
CRAFTINGBENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$0" ] && [ "$0" != "-bash" ] && [ "$0" != "-zsh" ]; then
  CRAFTINGBENCH_DIR="$(cd "$(dirname "$0")" && pwd)"
else
  # Fallback: assume we're in the craftingbench directory
  if [ -f "./craftingbench.sh" ]; then
    CRAFTINGBENCH_DIR="$(pwd)"
  else
    echo "Error: Cannot determine CraftingBench directory"
    echo "Please run this script from the CraftingBench directory or use an absolute path"
    return 1 2>/dev/null || exit 1
  fi
fi

# Export this variable so template scripts can use it
export CRAFTINGBENCH_DIR
export CRAFTINGBENCH_PATH="$CRAFTINGBENCH_DIR"

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="bash"
else
  CRAFTINGBENCH_SHELL="other"
fi

# Source helper functions
if [ -f "$CRAFTINGBENCH_DIR/src/helpers/common.sh" ]; then
  source "$CRAFTINGBENCH_DIR/src/helpers/common.sh"
else
  echo "Error: Helper file not found at $CRAFTINGBENCH_DIR/src/helpers/common.sh"
  echo "CRAFTINGBENCH_DIR is set to: $CRAFTINGBENCH_DIR"
  echo "Current working directory: $(pwd)"
  echo "Script source: ${BASH_SOURCE[0]:-$0}"
  echo "Please ensure you're running from the correct directory or the script path is correct"
  return 1 2>/dev/null || exit 1
fi

# Source utility functions
if [ -f "$CRAFTINGBENCH_DIR/src/helpers/utils.sh" ]; then
  source "$CRAFTINGBENCH_DIR/src/helpers/utils.sh"
else
  echo "Warning: Utility file not found at $CRAFTINGBENCH_DIR/src/helpers/utils.sh"
fi

# Source template modules - only source if they exist
for template in python python-docker nodejs go react fullstack flask-react nextjs-fastapi pre-commit; do
  template_path="$CRAFTINGBENCH_DIR/src/templates/${template}.sh"
  if [ -f "$template_path" ]; then
    # shellcheck disable=SC1090
    source "$template_path"
  else
    echo "Warning: Template file not found: $template_path"
  fi
done

# Source shell completions
if [ -f "$CRAFTINGBENCH_DIR/src/completions/shell.sh" ]; then
  # shellcheck disable=SC1090
  source "$CRAFTINGBENCH_DIR/src/completions/shell.sh"
else
  echo "Warning: Shell completions file not found"
fi

# Initialize shell completions if in Zsh
if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && type setup_zsh_completions >/dev/null 2>&1; then
  setup_zsh_completions
fi

# The show_banner call has been removed to prevent duplication when the CLI is used
