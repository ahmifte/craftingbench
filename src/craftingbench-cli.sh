#!/usr/bin/env bash

# ================================================================
# CraftingBench CLI Wrapper
# ================================================================
# Version: 0.2.0
# MIT License - Copyright (c) 2025 CraftingBench Contributors

# Get the installation directory
CRAFTINGBENCH_INSTALL_DIR="$HOME/.craftingbench"

# Check if CraftingBench is installed
if [ ! -d "$CRAFTINGBENCH_INSTALL_DIR" ] || [ ! -f "$CRAFTINGBENCH_INSTALL_DIR/craftingbench.sh" ]; then
    echo "Error: CraftingBench is not installed or installation is corrupted."
    echo "Please install CraftingBench by running: ./install.sh"
    exit 1
fi

# Source the main script to load all functions
source "$CRAFTINGBENCH_INSTALL_DIR/craftingbench.sh"

# Check if a command was provided
if [ $# -eq 0 ]; then
    # Show banner with available commands if no arguments
    if type show_banner >/dev/null 2>&1; then
        show_banner
    else
        echo "Usage: craftingbench <command> [arguments]"
        echo "For example: craftingbench setup_nodejs_backend my_project"
    fi
    exit 0
fi

# Process the command
command="$1"
shift  # Remove the command from the arguments

# Execute the command with the remaining arguments
if type "$command" >/dev/null 2>&1; then
    "$command" "$@"
else
    echo "Error: Unknown command '$command'"
    echo "Run 'craftingbench' without arguments to see available commands."
    exit 1
fi
