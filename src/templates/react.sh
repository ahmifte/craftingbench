#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh"

setup_react_frontend() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_react_frontend <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "nodejs"; then
    return 1
  fi
  
  echo "🚀 Setting up React frontend project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  echo "⚠️ The React frontend template is still in development."
  echo "This is a placeholder until the full implementation is ready."
  
  # Create a basic README.md
  cat > README.md << EOF
# $project_name

A React frontend application created with CraftingBench.

## Getting Started

This is a placeholder. The full React template will be implemented soon.

## Project Structure

This template will include:
- React with TypeScript
- Modern tooling (Vite)
- Component organization
- State management
- Routing
- API integration

## License

MIT
EOF

  # Create a package.json
  cat > package.json << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "private": true,
  "description": "React frontend application",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [
    "react",
    "frontend"
  ],
  "author": "",
  "license": "MIT"
}
EOF

  # Initial git commit
  git add .
  git commit -m "Initial commit: React project skeleton"
  
  echo "✅ React frontend placeholder created: $project_name"
  echo ""
  echo "🚧 Note: This template is still under development."
  echo "📋 Next steps:"
  echo "  1. Check back for the full implementation"
  echo "  2. Consider contributing to the template development"
  echo ""
} 