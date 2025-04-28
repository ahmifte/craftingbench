#!/usr/bin/env bash

# ================================
# Helper Functions
# ================================

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if dependencies are installed for a specific project type
check_dependencies() {
  local project_type="$1"
  local missing_deps=()
  
  # Common dependencies
  if ! command_exists git; then
    missing_deps+=("git")
  fi
  
  # Project-specific dependencies
  case "$project_type" in
    python)
      if ! command_exists python || ! command_exists python3; then
        missing_deps+=("python (3.8+ recommended)")
      fi
      ;;
    go)
      if ! command_exists go; then
        missing_deps+=("go (1.18+ recommended)")
      fi
      ;;
    nodejs)
      if ! command_exists node; then
        missing_deps+=("node.js (16+ recommended)")
      fi
      if ! command_exists npm; then
        missing_deps+=("npm")
      fi
      ;;
    nextjs)
      if ! command_exists node; then
        missing_deps+=("node.js (16+ recommended)")
      fi
      if ! command_exists npm; then
        missing_deps+=("npm")
      fi
      ;;
  esac
  
  # Check GitHub CLI (optional)
  if ! command_exists gh; then
    echo "⚠️  Note: GitHub CLI (gh) is not installed. GitHub repository creation will be skipped."
    echo "   To enable this feature, install gh: https://cli.github.com/"
    echo ""
  fi
  
  # Report missing dependencies
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "❌ Error: The following dependencies are missing for $project_type projects:"
    for dep in "${missing_deps[@]}"; do
      echo "   - $dep"
    done
    echo ""
    echo "Please install these dependencies and try again."
    return 1
  fi
  
  return 0
} 