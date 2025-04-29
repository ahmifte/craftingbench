#!/usr/bin/env bash

# ================================================================
# CraftingBench - A utility for creating standardized project templates
# ================================================================
# Version: 0.2.0
# MIT License - Copyright (c) 2025 CraftingBench Contributors

# DESCRIPTION:
#   CraftingBench is a shell utility for quickly scaffolding various
#   project types with standardized, production-ready structures.
#   It streamlines project creation by automating the setup of
#   common development environments and best practices.

# USAGE:
#   source ./craftingbench.sh
#   setup_python_project <project_name>
#   setup_go_project <project_name>
#   setup_nodejs_backend <project_name>
#   setup_react_frontend <project_name>
#   setup_fullstack_project <project_name> (Next.js fullstack app with state management)

# For more information, visit: https://github.com/ahmifte/craftingbench
# ================================================================

# Get the directory of this script
CRAFTINGBENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  return 1
fi

# Source template modules - only source if they exist
for template in python nodejs go react fullstack; do
  template_path="$CRAFTINGBENCH_DIR/src/templates/${template}.sh"
  if [ -f "$template_path" ]; then
    source "$template_path"
  else
    echo "Warning: Template file not found: $template_path"
  fi
done

# Source shell completions
if [ -f "$CRAFTINGBENCH_DIR/src/completions/shell.sh" ]; then
  source "$CRAFTINGBENCH_DIR/src/completions/shell.sh"
else
  echo "Warning: Shell completions file not found"
fi

# Initialize shell completions if in Zsh
if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && type setup_zsh_completions >/dev/null 2>&1; then
  setup_zsh_completions
fi

# Show banner with available commands
if type show_banner >/dev/null 2>&1; then
  show_banner
fi
