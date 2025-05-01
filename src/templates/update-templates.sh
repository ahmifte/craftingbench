#!/usr/bin/env bash

# =====================================
# Template Update Utility
# =====================================
# Script to update all template scripts to use the common utilities
# and reusable workflows
# =====================================

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRAFTINGBENCH_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Import common utilities
source "$CRAFTINGBENCH_DIR/src/helpers/template-utils.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log messages
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Update a template script to use the common utilities and reusable workflow
update_template() {
  local template_file="$1"
  local template_name
  template_name=$(basename "$template_file" .sh)

  log_info "Updating $template_name template..."

  # Add template-utils.sh import if not present
  if ! grep -q "template-utils.sh" "$template_file"; then
    log_info "Adding template-utils.sh import to $template_name..."

    # Create a temporary file
    temp_file=$(mktemp)

    # Add the import statement after the common.sh import
    awk '
      /source.*common.sh/ {
        print $0;
        print "# Import template utilities";
        print "source \"$(dirname \"${BASH_SOURCE[0]}\")/../helpers/template-utils.sh\" 2>/dev/null || source \"${CRAFTINGBENCH_DIR}/src/helpers/template-utils.sh\"";
        next;
      }
      { print $0 }
    ' "$template_file" > "$temp_file"

    # Replace the original file
    mv "$temp_file" "$template_file"
    log_success "Added template-utils.sh import to $template_name"
  else
    log_info "Template-utils.sh import already present in $template_name"
  fi

  # Update workflow creation to use reusable workflow
  if grep -q "github-workflows" "$template_file"; then
    log_info "Updating workflow creation in $template_name..."

    # Determine project type based on template name
    local project_type=""
    case "$template_name" in
      *flask* | *python*)
        project_type="python"
        ;;
      *react* | *node*)
        project_type="node"
        ;;
      *go*)
        project_type="go"
        ;;
      *)
        project_type="other"
        ;;
    esac

    # Create a temporary file
    temp_file=$(mktemp)

    # Update workflow creation
    awk -v project_type="$project_type" '
      /mkdir.*github-workflows/ {
        print $0;
        print "  # Create workflow that uses reusable workflow";
        print "  cat > \"$project_dir/.github/workflows/ci.yml\" << EOF";
        print "name: CI";
        print "";
        print "on:";
        print "  push:";
        print "    branches: [ main ]";
        print "  pull_request:";
        print "    branches: [ main ]";
        print "";
        print "jobs:";
        print "  call-reusable-workflow:";
        print "    uses: ./.github/workflows/reusable-workflow.yml";
        print "    with:";
        print "      project_type: \"" project_type "\"";
        print "      working_directory: \"$project_dir\"";
        print "      test_command: \"echo \\\"Add test command here\\\"\"";
        print "      build_command: \"echo \\\"Add build command here\\\"\"";
        print "      lint_command: \"echo \\\"Add lint command here\\\"\"";
        print "EOF";
        next;
      }
      { print $0 }
    ' "$template_file" > "$temp_file"

    # Replace the original file
    mv "$temp_file" "$template_file"
    log_success "Updated workflow creation in $template_name"
  fi

  # Make the script executable
  chmod +x "$template_file"

  log_success "Updated $template_name template"
}

# Main function
main() {
  log_info "Starting template update utility..."

  # Find all template scripts
  template_files=("$SCRIPT_DIR"/*.sh)

  # Exclude this script
  for template_file in "${template_files[@]}"; do
    if [ "$(basename "$template_file")" != "update-templates.sh" ]; then
      update_template "$template_file"
    fi
  done

  log_success "All templates updated successfully!"
  log_info "Next steps:"
  log_info "1. Test each template with: setup_<template_name> test_project"
  log_info "2. Check the pre-commit hooks with: pre-commit run --all-files"
  log_info "3. Commit your changes: git add . && git commit -m 'Update templates to use common utilities and reusable workflows'"
}

# Run the main function
main
