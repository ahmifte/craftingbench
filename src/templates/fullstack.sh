#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"
# Import template utilities
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/template-utils.sh"

# Default values
DEFAULT_BACKEND="nextjs"

setup_fullstack_project() {
  local project_name="$1"
  shift

  # Parse additional arguments
  local backend_type="$DEFAULT_BACKEND"

  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --backend=*) backend_type="${1#*=}" ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
    shift
  done

  # Prepare variables
  local github_username
  github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')

  # Output the configuration
  echo "Creating fullstack project with configuration:"
  echo "- Project name: $project_name"
  echo "- Backend type: $backend_type"

  case "$backend_type" in
    nextjs)
      echo "Setting up Next.js fullstack project..."
      setup_nextjs_fullstack "$project_name" "$github_username"
      ;;
    flask)
      echo "Setting up Flask + React fullstack project..."
      setup_flask_react_project "$project_name"
      ;;
    golang|go)
      echo "Setting up Go + React fullstack project..."
      setup_go_react_fullstack "$project_name"
      ;;
    *)
      echo "Error: Unknown backend type: $backend_type"
      echo "Available backend types: nextjs, flask, golang"
      return 1
      ;;
  esac

  return 0
}
