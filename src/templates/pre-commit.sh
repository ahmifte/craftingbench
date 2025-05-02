#!/usr/bin/env bash
# Pre-commit template generator

# Source helper functions
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/../helpers/utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/utils.sh"

generate_pre_commit_config() {
  local project_dir="$1"
  local lang_types="$2" # Comma-separated list of languages: python,js,go

  if [ -z "$project_dir" ]; then
    echo "Error: Project directory is required"
    echo "Usage: generate_pre_commit_config <project_dir> [<lang_types>]"
    return 1
  fi

  if [ -z "$lang_types" ]; then
    # Try to detect project type based on files in the directory
    if [ -f "$project_dir/package.json" ]; then
      lang_types="${lang_types:+$lang_types,}js"
    fi

    if [ -f "$project_dir/requirements.txt" ] || [ -f "$project_dir/setup.py" ] || find "$project_dir" -name "*.py" -print -quit | grep -q .; then
      lang_types="${lang_types:+$lang_types,}python"
    fi

    if [ -f "$project_dir/go.mod" ] || find "$project_dir" -name "*.go" -print -quit | grep -q .; then
      lang_types="${lang_types:+$lang_types,}go"
    fi

    # Default to basic configuration if no specific language is detected
    if [ -z "$lang_types" ]; then
      lang_types="basic"
    fi
  fi

  echo "Generating pre-commit configuration for: $lang_types"
  setup_pre_commit "$project_dir" "$lang_types"

  # Provide instructions for using pre-commit
  echo ""
  echo "To use pre-commit hooks:"
  echo "1. Install pre-commit: pip install pre-commit"
  echo "2. Install hooks in your repo: pre-commit install"
  echo "3. Run manually: pre-commit run --all-files"

  return 0
}

# If script is executed directly, run the generator function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <project_dir> [<lang_types>]"
    echo "  <project_dir>: Path to the project directory"
    echo "  <lang_types>: Comma-separated list of languages (python,js,go)"
    exit 1
  fi

  project_dir="$1"
  lang_types="${2:-}"

  generate_pre_commit_config "$project_dir" "$lang_types"
fi
