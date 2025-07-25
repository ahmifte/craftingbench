#!/usr/bin/env bash

# ================================
# Helper Functions
# ================================

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if dependencies are installed
check_dependencies() {
  local deps="$1"
  local missing_deps=()

  # Check each dependency in the space-separated list
  for dep in $deps; do
    case "$dep" in
      python)
        # Check for python3 first, then python
        if command_exists python3; then
          continue
        elif command_exists python; then
          continue
        else
          missing_deps+=("python (try: python3)")
        fi
        ;;
      *)
        if ! command_exists "$dep"; then
          missing_deps+=("$dep")
        fi
        ;;
    esac
  done

  # Check GitHub CLI (optional)
  if ! command_exists gh; then
    echo "⚠️  Note: GitHub CLI (gh) is not installed. GitHub repository creation will be limited."
    echo "   To enable all GitHub features, install gh: https://cli.github.com/"
    echo ""
  fi

  # Report missing dependencies
  if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "❌ Error: The following dependencies are missing:"
    for dep in "${missing_deps[@]}"; do
      echo "   - $dep"
    done
    echo ""
    echo "Please install these dependencies and try again."
    return 1
  fi

  return 0
}
