#!/usr/bin/env bash

# ================================================================
# CraftingBench - A utility for creating standardized project templates
# ================================================================
# Version: 1.0.0
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

# For more information, visit: https://github.com/yourusername/craftingbench
# ================================================================

# Get the directory of this script
CRAFTINGBENCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="bash"
else
  CRAFTINGBENCH_SHELL="other"
fi

# Source helper functions
source "$CRAFTINGBENCH_DIR/src/helpers/common.sh"

# Source template modules
source "$CRAFTINGBENCH_DIR/src/templates/python.sh"
source "$CRAFTINGBENCH_DIR/src/templates/nodejs.sh"
source "$CRAFTINGBENCH_DIR/src/templates/go.sh"
source "$CRAFTINGBENCH_DIR/src/templates/react.sh"
source "$CRAFTINGBENCH_DIR/src/templates/fullstack.sh"

# Source shell completions
source "$CRAFTINGBENCH_DIR/src/completions/shell.sh"

# Initialize shell completions if in Zsh
setup_zsh_completions

# Show banner with available commands
show_banner
