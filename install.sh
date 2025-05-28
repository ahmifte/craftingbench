#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
CLEAR='\033[0m'

# Configuration
CRAFTINGBENCH_VERSION="0.3.0"
REPO_URL="https://github.com/ahmifte/craftingbench"
INSTALL_DIR="$HOME/.craftingbench"
SHELL_CONFIG=""

# Determine appropriate shell config file
detect_shell_config() {
  if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
    SHELL_NAME="Zsh"
  elif [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      SHELL_CONFIG="$HOME/.bashrc"
    else
      SHELL_CONFIG="$HOME/.bash_profile"
    fi
    SHELL_NAME="Bash"
  else
    echo -e "${YELLOW}Unknown shell. You'll need to manually configure your shell to source craftingbench.sh${CLEAR}"
  fi
}

# Print banner
print_banner() {
  echo -e "${CYAN}"
  echo -e "  _____              __ _   _                ____                  _     "
  echo -e " / ____|            / _| | (_)              |  _ \                | |    "
  echo -e "| |     _ __ __ _  | |_| |_ _ _ __   __ _   | |_) | ___ _ __   __ | |__  "
  echo -e "| |    | '__/ _\` | |  _| __| | '_ \ / _\` |  |  _ < / _ \ '_ \ / __| '_ \ "
  echo -e "| |____| | | (_| | | | | |_| | | | | (_| |  | |_) |  __/ | | | (__| | | |"
  echo -e " \_____|_|  \__,_| |_|  \__|_|_| |_|\__, |  |____/ \___|_| |_|\___|_| |_|"
  echo -e "                                     __/ |                               "
  echo -e "                                    |___/                                "
  echo -e "${CLEAR}"
  echo -e "${PURPLE}CraftingBench Installer v${CRAFTINGBENCH_VERSION}${CLEAR}"
  echo -e "A powerful CLI utility for TypeScript project templates"
  echo ""
}

# Check for prerequisites
check_prerequisites() {
  echo -e "${BLUE}Checking prerequisites...${CLEAR}"
  
  # Check for curl
  if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is required but not installed.${CLEAR}"
    exit 1
  fi
  
  # Check for git
  if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Warning: git is not installed. Some features may not work correctly.${CLEAR}"
  fi
  
  # Check for node/npm (optional)
  if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Warning: Node.js is not installed. Some templates may not work correctly.${CLEAR}"
  fi
  
  # Check for pnpm (optional)
  if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}Warning: pnpm is not installed. TypeScript templates require pnpm.${CLEAR}"
    echo -e "${YELLOW}Install pnpm: curl -fsSL https://get.pnpm.io/install.sh | sh -${CLEAR}"
  fi
  
  echo -e "${GREEN}✓ Prerequisites checked${CLEAR}"
}

# Download CraftingBench
download_craftingbench() {
  echo -e "${BLUE}Downloading CraftingBench v${CRAFTINGBENCH_VERSION}...${CLEAR}"
  
  # Create installation directory
  mkdir -p "$INSTALL_DIR"
  
  # Download latest release
  local download_url="${REPO_URL}/archive/refs/tags/v${CRAFTINGBENCH_VERSION}.tar.gz"
  
  # Download and extract
  curl -sL "$download_url" | tar -xz --strip-components=1 -C "$INSTALL_DIR"
  
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Successfully downloaded CraftingBench${CLEAR}"
    
    # Setup CLI tools
    setup_cli_tools
  else
    echo -e "${RED}Error: Failed to download CraftingBench.${CLEAR}"
    exit 1
  fi
}

# Setup CLI tools and aliases
setup_cli_tools() {
  echo -e "${BLUE}Setting up CLI tools...${CLEAR}"
  
  # Create bin directory if needed
  if [ -d "$HOME/bin" ]; then
    BIN_DIR="$HOME/bin"
  elif [ -d "$HOME/.local/bin" ]; then
    BIN_DIR="$HOME/.local/bin"
  else
    # Create a bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    BIN_DIR="$HOME/.local/bin"
    
    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "$BIN_DIR"; then
      echo -e "${YELLOW}Note: Adding $BIN_DIR to your PATH in $SHELL_CONFIG${CLEAR}"
      echo "" >> "$SHELL_CONFIG"
      echo "# Add local bin directory to PATH" >> "$SHELL_CONFIG"
      echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"
    fi
  fi
  
  # Make CLI scripts executable
  chmod +x "$INSTALL_DIR/src/bin/craftingbench"
  chmod +x "$INSTALL_DIR/src/bin/cb"
  
  # Create symlinks to the CLI wrapper in user's bin directory
  ln -sf "$INSTALL_DIR/src/bin/craftingbench" "$BIN_DIR/craftingbench"
  ln -sf "$INSTALL_DIR/src/bin/cb" "$BIN_DIR/cb"
  echo -e "${GREEN}✓ Created 'craftingbench' and 'cb' commands in $BIN_DIR${CLEAR}"
  
  # Setup completions based on shell
  if [ "$SHELL_NAME" = "Bash" ]; then
    if ! grep -q "craftingbench.bash" "$SHELL_CONFIG"; then
      echo "" >> "$SHELL_CONFIG"
      echo "# CraftingBench command completion" >> "$SHELL_CONFIG"
      echo "[ -f \"$INSTALL_DIR/src/completions/craftingbench.bash\" ] && source \"$INSTALL_DIR/src/completions/craftingbench.bash\"" >> "$SHELL_CONFIG"
      echo -e "${GREEN}✓ Added command completion to $SHELL_CONFIG${CLEAR}"
    fi
  elif [ "$SHELL_NAME" = "Zsh" ]; then
    if ! grep -q "craftingbench.bash" "$SHELL_CONFIG"; then
      echo "" >> "$SHELL_CONFIG"
      echo "# CraftingBench command completion" >> "$SHELL_CONFIG"
      echo "autoload -U +X compinit && compinit" >> "$SHELL_CONFIG"
      echo "autoload -U +X bashcompinit && bashcompinit" >> "$SHELL_CONFIG"
      echo "[ -f \"$INSTALL_DIR/src/completions/craftingbench.bash\" ] && source \"$INSTALL_DIR/src/completions/craftingbench.bash\"" >> "$SHELL_CONFIG"
      echo -e "${GREEN}✓ Added command completion to $SHELL_CONFIG${CLEAR}"
    fi
  fi
}

# Configure shell
configure_shell() {
  echo -e "${BLUE}Configuring shell...${CLEAR}"
  
  # Check if already configured
  if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
    if grep -q "source.*craftingbench.sh" "$SHELL_CONFIG"; then
      echo -e "${YELLOW}CraftingBench is already configured in $SHELL_CONFIG${CLEAR}"
    else
      # Add to shell config
      echo "" >> "$SHELL_CONFIG"
      echo "# CraftingBench Configuration" >> "$SHELL_CONFIG"
      echo "source $INSTALL_DIR/craftingbench.sh" >> "$SHELL_CONFIG"
      echo -e "${GREEN}✓ Added CraftingBench to $SHELL_CONFIG${CLEAR}"
    fi
  else
    echo -e "${YELLOW}Could not determine shell configuration file. You'll need to manually configure your shell.${CLEAR}"
    echo -e "Add the following line to your shell configuration file:"
    echo -e "${CYAN}source $INSTALL_DIR/craftingbench.sh${CLEAR}"
  fi
}

# Main installation
install_craftingbench() {
  print_banner
  detect_shell_config
  check_prerequisites
  download_craftingbench
  configure_shell
  
  echo ""
  echo -e "${GREEN}✅ CraftingBench v${CRAFTINGBENCH_VERSION} installed successfully!${CLEAR}"
  echo ""
  echo -e "${BLUE}Next steps:${CLEAR}"
  echo -e "1. Restart your terminal or run: ${CYAN}source $SHELL_CONFIG${CLEAR}"
  echo -e "2. Use CraftingBench in two ways:"
  echo -e "   a. With commands: ${CYAN}craftingbench setup_nodejs_backend my_project${CLEAR}"
  echo -e "   b. Or shorter: ${CYAN}cb setup_nodejs_backend my_project${CLEAR}"
  echo -e "   c. Or source it first: ${CYAN}source $INSTALL_DIR/craftingbench.sh${CLEAR}"
  echo -e "      Then run functions directly: ${CYAN}setup_nodejs_backend my_project${CLEAR}"
  echo ""
  echo -e "For more information, visit: ${CYAN}${REPO_URL}${CLEAR}"
}

# Execute main function
install_craftingbench 