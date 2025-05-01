#!/usr/bin/env bash

# =====================================================
# CraftingBench Installer
# =====================================================
# This script installs CraftingBench, a utility for
# creating standardized project templates.
# =====================================================

set -e

# Default installation directory
DEFAULT_INSTALL_DIR="$HOME/.craftingbench"

# Parse command line arguments
INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Determine the shell configuration file
if [ -n "$ZSH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
  SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
  SHELL_TYPE="bash"
else
  SHELL_CONFIG="$HOME/.profile"
  SHELL_TYPE="unknown"
fi

echo -e "${BLUE}CraftingBench Installer${NC}"
echo "========================================"
echo "This will install CraftingBench to: $INSTALL_DIR"
echo "Shell configuration: $SHELL_CONFIG"
echo "Shell type: $SHELL_TYPE"
echo "========================================"

# Check if the installation directory already exists
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Installation directory already exists.${NC}"
  read -p "Would you like to update the existing installation? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation aborted.${NC}"
    exit 1
  fi

  echo -e "${BLUE}Updating existing installation...${NC}"
  cd "$INSTALL_DIR" && git pull
  echo -e "${GREEN}CraftingBench has been updated.${NC}"
  exit 0
fi

# Check for required dependencies
for cmd in git curl; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "${RED}Error: '$cmd' is not installed. Please install it and try again.${NC}"
    exit 1
  fi
done

# Create the installation directory
mkdir -p "$INSTALL_DIR"

# Clone the repository
echo -e "${BLUE}Cloning CraftingBench repository...${NC}"
git clone https://github.com/ahmifte/craftingbench.git "$INSTALL_DIR"

# Make the script executable
chmod +x "$INSTALL_DIR/craftingbench.sh"

# Add to shell configuration if not already present
if ! grep -q "source.*craftingbench.sh" "$SHELL_CONFIG"; then
  echo -e "${BLUE}Adding CraftingBench to $SHELL_CONFIG...${NC}"
  echo "" >> "$SHELL_CONFIG"
  echo "# CraftingBench - Project Template Creator" >> "$SHELL_CONFIG"
  echo "source \"$INSTALL_DIR/craftingbench.sh\"" >> "$SHELL_CONFIG"
else
  echo -e "${YELLOW}CraftingBench is already in your shell configuration.${NC}"
fi

echo -e "${GREEN}CraftingBench has been installed successfully!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'source $SHELL_CONFIG' to start using CraftingBench.${NC}"
