#!/usr/bin/env bash

# ================================================================
# CraftingBench - A utility for creating standardized project templates
# ================================================================
# Version: 1.0.0
# MIT License - Copyright (c) 2025 CraftingBench Contributors
#
# DESCRIPTION:
#   CraftingBench is a shell utility for quickly scaffolding various
#   project types with standardized, production-ready structures.
#   It streamlines project creation by automating the setup of
#   common development environments and best practices.
#
# USAGE:
#   source ./craftingbench.sh
#   setup_python_project <project_name>
#   setup_go_project <project_name>
#   setup_plain_project <project_name>
#   setup_nodejs_backend <project_name> (coming soon)
#   setup_react_frontend <project_name> (coming soon)
#   setup_fullstack_project <project_name> (coming soon)
#
# REQUIREMENTS:
#   - Git
#   - bash/zsh shell
#   - Language-specific tools depending on the template:
#     - Python (3.8+) for Python projects
#     - Go (1.18+) for Go projects
#     - Node.js (16+) for JavaScript/TypeScript projects
#   - GitHub CLI (optional, for GitHub integration)
#
# For more information, visit: https://github.com/yourusername/craftingbench
# ================================================================

# ================================
# Shell Compatibility
# ================================
# This script is compatible with both Bash and Zsh shells.
# For Zsh users, it's recommended to add the following to your .zshrc:
#
# compdef _gnu_generic setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project setup_plain_project
#
# This enables command-line completion for CraftingBench commands.
# ================================

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
  CRAFTINGBENCH_SHELL="bash"
else
  CRAFTINGBENCH_SHELL="other"
fi

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

setup_python_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_project <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Check if the repository already exists, and if so, clone it instead
  if command -v gh &>/dev/null && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Cloning existing repository..."
    cd ..
    rm -rf "$project_name"
    git clone "https://github.com/$github_username/$project_name.git"
    cd "$project_name" || return 1
  elif command -v gh &>/dev/null; then
    # Create a new GitHub repository if gh CLI is available
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private
    
    # Add remote
    git remote add origin "https://github.com/$github_username/$project_name.git"
    
    # Create a simple README.md for the initial commit
    echo "# $project_name" > README.md
    
    # Add README.md and make the initial commit
    git add README.md
    git commit -m "Initial commit: Add project README"
    
    # Push the initial commit to the main branch
    git push -u origin main
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "# $project_name" > README.md
    git add README.md
    git commit -m "Initial commit: Add project README"
  fi
  
  # Create and checkout a new branch for the project setup
  if [[ -n $(git branch --list main) ]]; then
    git checkout main
    git pull origin main 2>/dev/null || true
    git checkout -b initial-setup
  elif [[ -n $(git branch --list master) ]]; then
    git checkout master
    git pull origin master 2>/dev/null || true
    git checkout -b initial-setup
  else
    git checkout -b initial-setup
  fi
  
  # Expand README.md with more content
  echo -e "\n## Development\n\n### Setup\n\n\`\`\`bash\n# Install dependencies\nmake install\n\n# Update dependencies\nmake update\n\`\`\`" >> README.md
  
  # Create .gitignore for Python
  cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.pytest_cache/
.coverage
htmlcov/

# IDEs and editors
.idea/
.vscode/
*.swp
*.swo
*~
EOF
  
  # Create pyproject.toml
  cat > pyproject.toml << EOF
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$project_name"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.8"
license = { text = "MIT" }
dependencies = [
]

[project.optional-dependencies]
dev = [
  "pytest>=7.0.0",
  "black>=23.0.0",
  "isort>=5.12.0",
  "flake8>=6.0.0",
]

[tool.black]
line-length = 88

[tool.isort]
profile = "black"
line_length = 88
EOF
  
  # Create main Python module
  mkdir -p "$project_name"
  touch "$project_name/__init__.py"
  
  # Create main.py
  cat > main.py << EOF
#!/usr/bin/env python3

def main():
    print("Hello from $project_name!")

if __name__ == "__main__":
    main()
EOF
  chmod +x main.py
  
  # Create Makefile with dependency commands (adapts to uv or pip)
  cat > Makefile << EOF
.PHONY: install update format lint test clean

# Detect if uv is available, otherwise use pip
PYTHON_PKG_MGR := \$(shell command -v uv 2>/dev/null && echo "uv" || echo "pip")

install:
	@echo "Installing dependencies with \$(PYTHON_PKG_MGR)..."
ifeq (\$(PYTHON_PKG_MGR), uv)
	uv venv
	uv pip install -e ".[dev]"
else
	python -m venv venv
	. venv/bin/activate && pip install -e ".[dev]"
endif

update:
	@echo "Updating dependencies..."
ifeq (\$(PYTHON_PKG_MGR), uv)
	uv pip compile pyproject.toml -o requirements.txt
	uv pip install -r requirements.txt
else
	pip install --upgrade pip-tools
	pip-compile pyproject.toml -o requirements.txt
	pip install -r requirements.txt
endif

format:
	@echo "Formatting code..."
	black .
	isort .

lint:
	@echo "Linting code..."
	flake8 .

test:
	@echo "Running tests..."
	pytest

clean:
	@echo "Cleaning up..."
	rm -rf build/ dist/ *.egg-info/ .pytest_cache/ .coverage htmlcov/
	find . -type d -name "__pycache__" -exec rm -rf {} +
EOF
  
  # Create a simple test
  mkdir -p "tests"
  cat > tests/test_main.py << EOF
def test_dummy():
    assert True
EOF
  
  # Create Python version file
  echo "3.10" > .python-version
  
  # Add all files and commit to the initial-setup branch
  git add .
  git commit -m "Set up Python project structure and scaffolding"
  
  # If GitHub CLI is available, try to push and create PR
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    # Push the initial-setup branch
    git push -u origin initial-setup
    
    # Create pull request using GitHub CLI
    echo "Creating pull request..."
    gh pr create --title "Initial Project Setup" --body "This PR sets up the basic project structure including:

- Python package structure
- Development tools configuration
- Testing framework
- Makefile with common commands
- Basic documentation

Ready for review." --base main || echo "Failed to create PR. You may need to create it manually."
    
    echo "✓ Python project '$project_name' is ready!"
    echo "GitHub: https://github.com/$github_username/$project_name"
  else
    echo "✓ Python project '$project_name' is ready locally!"
  fi
  
  echo ""
  echo "Next steps:"
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    echo "1. Review and merge the PR"
  fi
  echo "2. Run 'make install' to set up your environment"
  echo "3. Run 'make update' to generate requirements.txt"
}

# Setup a Node.js backend project
setup_nodejs_backend() {
  local project_name=$1
  
  # Check dependencies
  if ! check_dependencies "nodejs"; then
    return 1
  fi
  
  if [ -z "$project_name" ]; then
    echo "❌ Error: Project name is required"
    echo "Usage: setup_nodejs_backend <project_name>"
    return 1
  fi
  
  echo "🚀 Creating Node.js backend project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository if git exists
  if command_exists git; then
    git init .
  fi
  
  # Initialize npm project
  npm init -y
  
  # Update package.json with better defaults
  sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "node src\/index.js",\n    "dev": "nodemon src\/index.js",\n    "test": "jest",\n    "lint": "eslint .",/g' package.json
  rm package.json.bak
  
  # Install common dependencies
  npm install express dotenv cors helmet mongoose
  
  # Install development dependencies
  npm install --save-dev nodemon jest eslint eslint-config-airbnb-base eslint-plugin-import
  
  # Create project structure
  mkdir -p src/{config,controllers,models,routes,middleware,utils,tests}
  
  # Create .env file
  cat > .env << EOF
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/$project_name
# Add other environment variables here
EOF

  # Create .gitignore
  cat > .gitignore << EOF
# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build output
/dist
/build

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory
coverage

# IDEs and editors
/.idea
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Misc
.DS_Store
.AppleDouble
.LSOverride
EOF

  # Create main application file
  cat > src/index.js << EOF
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

// Import routes
const apiRoutes = require('./routes');

// Initialize express app
const app = express();

// Set port
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// Start the server
app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});

module.exports = app; // For testing
EOF

  # Create routes index file
  cat > src/routes/index.js << EOF
const express = require('express');
const router = express.Router();

// Import other route modules
// const userRoutes = require('./user.routes');

// Define routes
// router.use('/users', userRoutes);

// Default route
router.get('/', (req, res) => {
  res.json({ message: 'Welcome to $project_name API!' });
});

module.exports = router;
EOF

  # Create sample controller
  cat > src/controllers/sample.controller.js << EOF
/**
 * Sample controller with common CRUD operations
 */

// Get all items
exports.getAll = async (req, res) => {
  try {
    // Replace with your actual data fetching logic
    const items = [{ id: 1, name: 'Sample Item' }];
    return res.status(200).json(items);
  } catch (error) {
    console.error('Error in getAll:', error);
    return res.status(500).json({ message: 'Failed to retrieve items' });
  }
};

// Get single item by ID
exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    // Replace with your actual data fetching logic
    const item = { id: parseInt(id), name: 'Sample Item' };
    return res.status(200).json(item);
  } catch (error) {
    console.error('Error in getById:', error);
    return res.status(500).json({ message: 'Failed to retrieve item' });
  }
};

// Create new item
exports.create = async (req, res) => {
  try {
    const newItem = req.body;
    // Replace with your actual data creation logic
    return res.status(201).json({ id: Date.now(), ...newItem });
  } catch (error) {
    console.error('Error in create:', error);
    return res.status(500).json({ message: 'Failed to create item' });
  }
};

// Update item
exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    // Replace with your actual update logic
    return res.status(200).json({ id: parseInt(id), ...updates });
  } catch (error) {
    console.error('Error in update:', error);
    return res.status(500).json({ message: 'Failed to update item' });
  }
};

// Delete item
exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    // Replace with your actual delete logic
    return res.status(200).json({ message: 'Item deleted successfully' });
  } catch (error) {
    console.error('Error in delete:', error);
    return res.status(500).json({ message: 'Failed to delete item' });
  }
};
EOF

  # Create a readme file
  cat > README.md << EOF
# $project_name

A Node.js backend application built with Express.

## Features

- RESTful API architecture
- Express.js web framework
- MongoDB integration with Mongoose
- Environment configuration with dotenv
- Security middleware with Helmet
- CORS support
- Structured project layout
- Error handling middleware

## Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Install dependencies
npm install

# Create .env file (example provided in .env.example)
cp .env.example .env

# Start the development server
npm run dev
\`\`\`

## Project Structure

\`\`\`
src/
├── config/        # Configuration files
├── controllers/   # Route controllers
├── middleware/    # Custom middleware
├── models/        # Database models
├── routes/        # API routes
├── utils/         # Utility functions
├── tests/         # Test files
└── index.js       # Application entry point
\`\`\`

## Available Scripts

- \`npm start\`: Start the production server
- \`npm run dev\`: Start the development server with hot reloading
- \`npm test\`: Run tests
- \`npm run lint\`: Run linting

## API Endpoints

- \`GET /health\`: Health check endpoint
- \`GET /api\`: Welcome message

## License

[MIT](LICENSE)
EOF

  # Create a .eslintrc.js file
  cat > .eslintrc.js << EOF
module.exports = {
  env: {
    node: true,
    commonjs: true,
    es2021: true,
    jest: true,
  },
  extends: 'airbnb-base',
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
  },
};
EOF

  # If GitHub CLI exists, create a repo
  if command_exists gh; then
    echo "🔍 Checking if GitHub repository already exists..."
    if ! gh repo view "$project_name" &>/dev/null; then
      echo "🔨 Creating GitHub repository: $project_name"
      gh repo create "$project_name" --private --source=. --remote=origin
      git add .
      git commit -m "Initial commit: Node.js backend project structure"
      git push -u origin main || git push -u origin master
      echo "✅ Created and pushed to GitHub repository: $project_name"
    else
      echo "⚠️ GitHub repository already exists: $project_name"
    fi
  fi

  echo "✅ Node.js backend project '$project_name' created successfully!"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. npm install"
  echo "  3. npm run dev"
  echo ""
  echo "Happy coding! 🎉"
  
  return 0
}

# Function to set up a React frontend project with TypeScript
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
  
  # Check if the repository already exists, and if so, clone it instead
  if command -v gh &>/dev/null && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Cloning existing repository..."
    cd ..
    rm -rf "$project_name"
    git clone "https://github.com/$github_username/$project_name.git"
    cd "$project_name" || return 1
  elif command -v gh &>/dev/null; then
    # Create a new GitHub repository if gh CLI is available
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private
    
    # Add remote
    git remote add origin "https://github.com/$github_username/$project_name.git"
    
    # Create a simple README.md for the initial commit
    echo "# $project_name" > README.md
    
    # Add README.md and make the initial commit
    git add README.md
    git commit -m "Initial commit: Add project README"
    
    # Push the initial commit to the main branch
    git push -u origin main
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "# $project_name" > README.md
    git add README.md
    git commit -m "Initial commit: Add project README"
  fi
  
  # Create and checkout a new branch for the project setup
  if [[ -n $(git branch --list main) ]]; then
    git checkout main
    git pull origin main 2>/dev/null || true
    git checkout -b initial-setup
  elif [[ -n $(git branch --list master) ]]; then
    git checkout master
    git pull origin master 2>/dev/null || true
    git checkout -b initial-setup
  else
    git checkout -b initial-setup
  fi
  
  # Initialize project with npm (creates package.json)
  npm init -y
  
  # Update package.json with better defaults
  sed -i.bak 's/"name": ".*"/"name": "'$project_name'"/g' package.json
  sed -i.bak 's/"version": ".*"/"version": "0.1.0"/g' package.json
  sed -i.bak 's/"description": ".*"/"description": "React frontend for '$project_name'"/g' package.json
  sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "vite",\n    "build": "tsc && vite build",\n    "serve": "vite preview",\n    "test": "vitest run",\n    "test:watch": "vitest",\n    "lint": "eslint src --ext ts,tsx",\n    "lint:fix": "eslint src --ext ts,tsx --fix",/g' package.json
  rm package.json.bak
  
  # Install dependencies
  npm install react react-dom react-router-dom @tanstack/react-query axios
  
  # Install dev dependencies
  npm install --save-dev typescript @types/react @types/react-dom @types/node @vitejs/plugin-react vite vitest jsdom @testing-library/react @testing-library/jest-dom eslint eslint-plugin-react eslint-plugin-react-hooks @typescript-eslint/parser @typescript-eslint/eslint-plugin
  
  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF
  
  # Create tsconfig.node.json
  cat > tsconfig.node.json << EOF
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF
  
  # Create vite.config.ts
  cat > vite.config.ts << EOF
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 3000,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    css: true,
  },
});
EOF
  
  # Create .gitignore
  cat > .gitignore << EOF
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*

# Dependencies
node_modules
dist
dist-ssr
*.local

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
.DS_Store
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# Testing
coverage
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
EOF
  
  # Create .eslintrc.json
  cat > .eslintrc.json << EOF
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:react/recommended",
    "plugin:react-hooks/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "plugins": [
    "react",
    "react-hooks",
    "@typescript-eslint"
  ],
  "rules": {
    "react/react-in-jsx-scope": "off"
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
EOF
  
  # Create directory structure
  mkdir -p src/{components,pages,assets,hooks,services,utils,context,types,test}
  
  # Create test setup file
  cat > src/test/setup.ts << EOF
import '@testing-library/jest-dom';
EOF
  
  # Create main.tsx
  cat > src/main.tsx << EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import App from './App';
import './index.css';

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <QueryClientProvider client={queryClient}>
        <App />
      </QueryClientProvider>
    </BrowserRouter>
  </React.StrictMode>
);
EOF
  
  # Create index.css
  cat > src/index.css << EOF
:root {
  font-family: Inter, system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;

  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  margin: 0;
  display: flex;
  min-width: 320px;
  min-height: 100vh;
}

#root {
  width: 100%;
}

a {
  font-weight: 500;
  color: #646cff;
  text-decoration: inherit;
}
a:hover {
  color: #535bf2;
}

button {
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 0.6em 1.2em;
  font-size: 1em;
  font-weight: 500;
  font-family: inherit;
  background-color: #1a1a1a;
  cursor: pointer;
  transition: border-color 0.25s;
}
button:hover {
  border-color: #646cff;
}
button:focus,
button:focus-visible {
  outline: 4px auto -webkit-focus-ring-color;
}

@media (prefers-color-scheme: light) {
  :root {
    color: #213547;
    background-color: #ffffff;
  }
  a:hover {
    color: #747bff;
  }
  button {
    background-color: #f9f9f9;
  }
}
EOF
  
  # Create App.tsx
  cat > src/App.tsx << EOF
import { Routes, Route } from 'react-router-dom';
import Home from './pages/Home';
import About from './pages/About';
import Layout from './components/Layout';
import './App.css';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<Home />} />
        <Route path="about" element={<About />} />
      </Route>
    </Routes>
  );
}

export default App;
EOF
  
  # Create App.css
  cat > src/App.css << EOF
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.page {
  padding: 2rem 0;
}

h1 {
  font-size: 2.5rem;
  margin-bottom: 1rem;
}

h2 {
  font-size: 2rem;
  margin-bottom: 0.75rem;
}
EOF
  
  # Create Layout component
  cat > src/components/Layout.tsx << EOF
import { Outlet, Link } from 'react-router-dom';
import Navbar from './Navbar';
import Footer from './Footer';

const Layout = () => {
  return (
    <div className="app">
      <Navbar />
      <main className="container">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
};

export default Layout;
EOF
  
  # Create Navbar component
  cat > src/components/Navbar.tsx << EOF
import { Link } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
  return (
    <nav className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-logo">
          $project_name
        </Link>
        <ul className="nav-menu">
          <li className="nav-item">
            <Link to="/" className="nav-link">
              Home
            </Link>
          </li>
          <li className="nav-item">
            <Link to="/about" className="nav-link">
              About
            </Link>
          </li>
        </ul>
      </div>
    </nav>
  );
};

export default Navbar;
EOF
  
  # Create Navbar.css
  cat > src/components/Navbar.css << EOF
.navbar {
  background-color: #333;
  color: white;
  height: 80px;
  display: flex;
  justify-content: center;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
}

.navbar-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  max-width: 1200px;
  padding: 0 2rem;
}

.navbar-logo {
  color: white;
  font-size: 1.5rem;
  font-weight: bold;
  text-decoration: none;
}

.nav-menu {
  display: flex;
  list-style: none;
  gap: 1.5rem;
}

.nav-link {
  color: white;
  text-decoration: none;
  padding: 0.5rem;
}

.nav-link:hover {
  color: #646cff;
  transition: color 0.3s ease;
}
EOF
  
  # Create Footer component
  cat > src/components/Footer.tsx << EOF
import './Footer.css';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="footer-content">
        <p>© {new Date().getFullYear()} $project_name. All rights reserved.</p>
      </div>
    </footer>
  );
};

export default Footer;
EOF
  
  # Create Footer.css
  cat > src/components/Footer.css << EOF
.footer {
  margin-top: auto;
  padding: 1.5rem 0;
  background-color: #333;
  color: white;
  text-align: center;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}
EOF
  
  # Create Home page
  cat > src/pages/Home.tsx << EOF
import './Home.css';

const Home = () => {
  return (
    <div className="page home-page">
      <h1>Welcome to $project_name</h1>
      <p>This is a React application scaffold created with CraftingBench.</p>
      <div className="card">
        <h2>Features</h2>
        <ul>
          <li>React with TypeScript</li>
          <li>Vite for fast development</li>
          <li>React Router for navigation</li>
          <li>React Query for data fetching</li>
          <li>ESLint for code quality</li>
          <li>Vitest for testing</li>
        </ul>
      </div>
    </div>
  );
};

export default Home;
EOF
  
  # Create Home.css
  cat > src/pages/Home.css << EOF
.home-page {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.card {
  padding: 1.5rem;
  border-radius: 8px;
  background-color: #1a1a1a;
  margin-top: 1rem;
}

.card ul {
  margin-top: 1rem;
  margin-left: 1.5rem;
}

.card li {
  margin-bottom: 0.5rem;
}

@media (prefers-color-scheme: light) {
  .card {
    background-color: #f9f9f9;
  }
}
EOF
  
  # Create About page
  cat > src/pages/About.tsx << EOF
import './About.css';

const About = () => {
  return (
    <div className="page about-page">
      <h1>About</h1>
      <p>
        This is the about page of the $project_name application.
        Edit this page to provide information about your project.
      </p>
      <div className="card">
        <h2>Getting Started</h2>
        <p>To start developing:</p>
        <ol>
          <li>Edit the components in <code>src/components</code></li>
          <li>Add more pages in <code>src/pages</code></li>
          <li>Configure routes in <code>src/App.tsx</code></li>
          <li>Add API services in <code>src/services</code></li>
          <li>Create custom hooks in <code>src/hooks</code></li>
        </ol>
      </div>
    </div>
  );
};

export default About;
EOF
  
  # Create About.css
  cat > src/pages/About.css << EOF
.about-page {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.card {
  padding: 1.5rem;
  border-radius: 8px;
  background-color: #1a1a1a;
  margin-top: 1rem;
}

.card ol {
  margin-top: 1rem;
  margin-left: 1.5rem;
}

.card li {
  margin-bottom: 0.5rem;
}

code {
  padding: 0.2em 0.4em;
  background-color: rgba(100, 108, 255, 0.12);
  border-radius: 3px;
}

@media (prefers-color-scheme: light) {
  .card {
    background-color: #f9f9f9;
  }
  
  code {
    background-color: rgba(100, 108, 255, 0.1);
  }
}
EOF

  # Create a sample API service
  cat > src/services/api.ts << EOF
import axios from 'axios';

// Create an axios instance with default configuration
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3001/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor for auth
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer \${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized error (e.g., redirect to login)
      console.error('Unauthorized access');
    }
    return Promise.reject(error);
  }
);

export default api;
EOF

  # Create a sample hook
  cat > src/hooks/useLocalStorage.ts << EOF
import { useState, useEffect } from 'react';

function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  // Get stored value from localStorage
  const readValue = (): T => {
    if (typeof window === 'undefined') {
      return initialValue;
    }

    try {
      const item = window.localStorage.getItem(key);
      return item ? (JSON.parse(item) as T) : initialValue;
    } catch (error) {
      console.warn(\`Error reading localStorage key "\${key}":, error\`);
      return initialValue;
    }
  };

  // State to store our value
  const [storedValue, setStoredValue] = useState<T>(readValue);

  // Return a wrapped version of useState's setter function that
  // persists the new value to localStorage.
  const setValue = (value: T) => {
    try {
      // Allow value to be a function so we have same API as useState
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      
      // Save state
      setStoredValue(valueToStore);
      
      // Save to localStorage
      if (typeof window !== 'undefined') {
        window.localStorage.setItem(key, JSON.stringify(valueToStore));
      }
    } catch (error) {
      console.warn(\`Error setting localStorage key "\${key}":, error\`);
    }
  };

  useEffect(() => {
    setStoredValue(readValue());
  }, [key]);

  return [storedValue, setValue];
}

export default useLocalStorage;
EOF

  # Create vite-env.d.ts
  cat > src/vite-env.d.ts << EOF
/// <reference types="vite/client" />
EOF

  # Create index.html
  cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/src/assets/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="$project_name - React Frontend Application" />
    <title>$project_name</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

  # Create favicon.svg
  mkdir -p src/assets
  cat > src/assets/favicon.svg << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M20.24 12.24a6 6 0 0 0-8.49-8.49L5 10.5V19h8.5l6.74-6.76z"></path>
  <line x1="16" y1="8" x2="2" y2="22"></line>
  <line x1="17.5" y1="15" x2="9" y2="15"></line>
</svg>
EOF

  # Create a sample test
  cat > src/App.test.tsx << EOF
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import App from './App';

describe('App', () => {
  it('renders the home page by default', () => {
    render(
      <MemoryRouter initialEntries={['/']}>
        <App />
      </MemoryRouter>
    );
    
    expect(screen.getByText(/Welcome to $project_name/i)).toBeInTheDocument();
  });

  it('renders about page when navigated to /about', () => {
    render(
      <MemoryRouter initialEntries={['/about']}>
        <App />
      </MemoryRouter>
    );
    
    expect(screen.getByText(/About/i)).toBeInTheDocument();
  });
});
EOF

  # Create a complete README.md
  cat > README.md << EOF
# $project_name

A modern React frontend application built with TypeScript and Vite.

## Features

- ⚡️ **Fast Development** with [Vite](https://vitejs.dev/)
- 🦾 **Type Safety** with [TypeScript](https://www.typescriptlang.org/)
- 🧭 **Routing** with [React Router](https://reactrouter.com/)
- 🎬 **State Management** with [React Query](https://tanstack.com/query/latest)
- 🧪 **Testing** with [Vitest](https://vitest.dev/) and [Testing Library](https://testing-library.com/)
- 🔍 **Linting** with [ESLint](https://eslint.org/)
- 📱 **Responsive Design** ready

## Getting Started

### Prerequisites

- Node.js (v16+)
- npm or yarn

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Install dependencies
npm install
\`\`\`

### Development

\`\`\`bash
# Start development server
npm run start
\`\`\`

This will start the development server at [http://localhost:3000](http://localhost:3000).

### Building for Production

\`\`\`bash
# Build for production
npm run build

# Preview production build
npm run serve
\`\`\`

### Testing

\`\`\`bash
# Run tests
npm run test

# Run tests in watch mode
npm run test:watch
\`\`\`

### Linting

\`\`\`bash
# Run linter
npm run lint

# Fix linting issues
npm run lint:fix
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── public/              # Static files
├── src/                 # Source files
│   ├── assets/          # Media files
│   ├── components/      # Reusable components
│   ├── context/         # React contexts
│   ├── hooks/           # Custom hooks
│   ├── pages/           # Page components
│   ├── services/        # API services
│   ├── types/           # TypeScript type definitions
│   ├── utils/           # Utility functions
│   ├── App.tsx          # Main App component
│   ├── main.tsx         # Application entry point
│   └── index.css        # Global styles
├── index.html           # HTML template
├── tsconfig.json        # TypeScript configuration
├── vite.config.ts       # Vite configuration
├── .eslintrc.json       # ESLint configuration
└── package.json         # Dependencies and scripts
\`\`\`

## Connecting to Backend API

By default, the application is configured to connect to a backend API at `http://localhost:3001/api`. You can change this by setting the `VITE_API_URL` environment variable.

Create a `.env` file in the root directory:

\`\`\`
VITE_API_URL=http://your-api-url
\`\`\`

## License

MIT
EOF
  
  # Add all files and commit
  git add .
  git commit -m "Set up React frontend project structure with TypeScript"
  
  # If GitHub CLI is available, try to push and create PR
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    # Push the initial-setup branch
    git push -u origin initial-setup
    
    # Create pull request using GitHub CLI
    echo "Creating pull request..."
    gh pr create --title "Initial React Frontend Setup" --body "This PR sets up the React frontend project structure including:

- TypeScript configuration
- Component architecture
- Routing setup
- State management
- API service configuration
- Testing framework
- Styling structure
- Development tooling

Ready for review." --base main || echo "Failed to create PR. You may need to create it manually."
    
    echo "✓ React frontend '$project_name' is ready!"
    echo "GitHub: https://github.com/$github_username/$project_name"
  else
    echo "✓ React frontend '$project_name' is ready locally!"
  fi
  
  echo ""
  echo "Next steps:"
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    echo "1. Review and merge the PR"
  fi
  echo "2. Run 'npm install' to install dependencies"
  echo "3. Run 'npm start' to start the development server"
  echo "1. Update the README.md with your project details"
  echo "2. Start building your project!"
}

# Function to set up a Go project
setup_go_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_go_project <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "go"; then
    return 1
  fi
  
  echo "🚀 Setting up Go project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Check if the repository already exists, and if so, clone it instead
  if command -v gh &>/dev/null && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Cloning existing repository..."
    cd ..
    rm -rf "$project_name"
    git clone "https://github.com/$github_username/$project_name.git"
    cd "$project_name" || return 1
  elif command -v gh &>/dev/null; then
    # Create a new GitHub repository if gh CLI is available
    echo "Creating new GitHub repository '$project_name'..."
    gh repo create "$project_name" --private
    
    # Add remote
    git remote add origin "https://github.com/$github_username/$project_name.git"
    
    # Create a simple README.md for the initial commit
    echo "# $project_name" > README.md
    
    # Add README.md and make the initial commit
    git add README.md
    git commit -m "Initial commit: Add project README"
    
    # Push the initial commit to the main branch
    git push -u origin main
  else
    # Without GitHub CLI, just set up the local repository
    echo "GitHub CLI not found. Setting up local repository only."
    echo "# $project_name" > README.md
    git add README.md
    git commit -m "Initial commit: Add project README"
  fi
  
  # Create and checkout a new branch for the project setup
  if [[ -n $(git branch --list main) ]]; then
    git checkout main
    git pull origin main 2>/dev/null || true
    git checkout -b initial-setup
  elif [[ -n $(git branch --list master) ]]; then
    git checkout master
    git pull origin master 2>/dev/null || true
    git checkout -b initial-setup
  else
    git checkout -b initial-setup
  fi
  
  # Initialize Go module
  go mod init "github.com/$github_username/$project_name"
  
  # Create .gitignore for Go
  cat > .gitignore << EOF
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.so
*.dylib
**/bin/

# Test binary, built with 'go test -c'
*.test

# Output of the go coverage tool
*.out
*.prof
coverage.html

# IDE files
.idea/
.vscode/
*.swp
*.swo

# OS specific files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Icon?
ehthumbs.db
Thumbs.db

# Go workspace file
go.work
EOF
  
  # Create standard Go project directory structure
  mkdir -p cmd/$project_name
  mkdir -p internal/app internal/pkg
  mkdir -p pkg
  mkdir -p api/rest
  mkdir -p configs
  mkdir -p scripts
  mkdir -p test
  mkdir -p docs
  
  # Create main.go
  cat > cmd/$project_name/main.go << EOF
package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/$github_username/$project_name/internal/app"
)

func main() {
	// Initialize application
	application, err := app.New()
	if err != nil {
		log.Fatalf("Failed to initialize application: %v", err)
	}

	// Start the application
	if err := application.Start(); err != nil {
		log.Fatalf("Failed to start application: %v", err)
	}
	
	// Set up graceful shutdown
	shutdownCh := make(chan os.Signal, 1)
	signal.Notify(shutdownCh, syscall.SIGINT, syscall.SIGTERM)
	
	// Wait for shutdown signal
	sig := <-shutdownCh
	fmt.Printf("Received signal: %v\n", sig)
	
	// Shutdown the application
	if err := application.Stop(); err != nil {
		log.Fatalf("Failed to stop application: %v", err)
	}
	
	fmt.Println("Application shutdown successfully")
}
EOF
  
  # Create app.go
  cat > internal/app/app.go << EOF
package app

import (
	"context"
	"fmt"
	"net/http"
	"time"
)

// App represents the application.
type App struct {
	server *http.Server
}

// New creates a new instance of the application.
func New() (*App, error) {
	// Create a new app
	app := &App{
		server: &http.Server{
			Addr:         ":8080",
			ReadTimeout:  10 * time.Second,
			WriteTimeout: 10 * time.Second,
			IdleTimeout:  120 * time.Second,
		},
	}
	
	// Set up routes
	mux := http.NewServeMux()
	mux.HandleFunc("/", app.homeHandler)
	mux.HandleFunc("/health", app.healthHandler)
	app.server.Handler = mux
	
	return app, nil
}

// Start starts the application.
func (a *App) Start() error {
	fmt.Println("Starting application on :8080")
	
	// Start HTTP server in a goroutine
	go func() {
		if err := a.server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			fmt.Printf("HTTP server error: %v\n", err)
		}
	}()
	
	return nil
}

// Stop gracefully shuts down the application.
func (a *App) Stop() error {
	fmt.Println("Shutting down server...")
	
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	
	if err := a.server.Shutdown(ctx); err != nil {
		return fmt.Errorf("server shutdown failed: %w", err)
	}
	
	return nil
}

// homeHandler handles the home route.
func (a *App) homeHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Welcome to %s!\n", "$project_name")
}

// healthHandler handles the health check route.
func (a *App) healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, \`{"status":"UP"}\`)
}
EOF
  
  # Create a simple README.md
  cat > README.md << EOF
# $project_name

A Go application with a standard project layout.

## Project Structure

\`\`\`
$project_name/
├── api/            # API definitions (OpenAPI/Swagger specs, protocol definitions)
├── cmd/            # Command line entry points
│   └── $project_name/    # Main application
├── configs/               # Configuration files
├── internal/              # Private application code
│   ├── app/               # Application core
│   └── pkg/               # Private packages
├── pkg/                   # Public packages
├── scripts/        # Scripts for dev, CI, build, etc.
└── test/           # Additional external test applications and test data
\`\`\`

## Getting Started

### Prerequisites

- Go 1.18 or later

### Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Build the project
go build -o bin/$project_name ./cmd/$project_name

# Run the project
./bin/$project_name
\`\`\`

### Development

\`\`\`bash
# Run tests
go test ./...

# Format code
go fmt ./...

# Lint code
go vet ./...
\`\`\`

## API Endpoints

- \`GET /\` - Home page
- \`GET /health\` - Health check endpoint

## License

MIT
EOF
  
  # Create a Makefile
  cat > Makefile << EOF
# Project variables
BINARY_NAME=$(shell basename $(CURDIR))
MAIN_PACKAGE=./cmd/$(BINARY_NAME)
BUILD_DIR=./bin
FRONTEND_DIR=./web
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS=-ldflags "-X main.version=$(VERSION) -X main.buildTime=$(BUILD_TIME)"

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=$(GOCMD) fmt

.PHONY: all build clean run dev test install-deps frontend-deps backend-deps frontend-build

all: build

# Build backend and frontend
build: backend-build frontend-build

# Install all dependencies
install-deps: backend-deps frontend-deps

# Backend dependencies
backend-deps:
	$(GOCMD) mod tidy

# Frontend dependencies
frontend-deps:
	cd $(FRONTEND_DIR) && npm install

# Build backend
backend-build:
	mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PACKAGE)

# Build frontend
frontend-build:
	cd $(FRONTEND_DIR) && npm run build

# Run in development mode
dev:
	@echo "Starting frontend development server..."
	cd $(FRONTEND_DIR) && npm run dev & \
	echo "Starting backend development server..." && \
	go run $(MAIN_PACKAGE) -dev

# Run tests
test:
	$(GOTEST) -v ./...

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(FRONTEND_DIR)/dist

# Run in production mode
run: build
	$(BUILD_DIR)/$(BINARY_NAME)
EOF
  
  # Create an improved README.md
  cat > README.md << EOF
# $project_name

A fullstack web application with Go backend and React frontend.

## Features

- **Go Backend API** - High-performance backend with Go
- **React Frontend** - Modern React with TypeScript
- **Webpack** - Advanced asset management with hot reloading
- **Development Mode** - Easy local development with hot reloading
- **Production Ready** - Optimized builds for deployment

## Project Structure

\`\`\`
$project_name/
├── api/                   # API definitions
├── cmd/                   # Command line entry points
│   └── $project_name/     # Main application
├── configs/               # Configuration files
├── internal/              # Private application code
│   ├── app/               # Application core
│   └── pkg/               # Private packages
├── pkg/                   # Public packages
├── scripts/        # Scripts for dev, CI, build, etc.
└── test/           # Additional external test applications and test data
\`\`\`

## Getting Started

### Prerequisites

- Go 1.18 or later
- Node.js 16 or later
- npm or yarn

### Installation

1. Clone the repository
\`\`\`bash
git clone <repository-url>
cd $project_name
\`\`\`

2. Install dependencies
\`\`\`bash
make install-deps
\`\`\`

### Development

Run the application in development mode:
\`\`\`bash
make dev
\`\`\`

This will start:
- Go backend on http://localhost:8080
- React frontend with webpack-dev-server on http://localhost:3000

### Building for Production

Build both backend and frontend:
\`\`\`bash
make build
\`\`\`

Run the production build:
\`\`\`bash
make run
\`\`\`

## API Endpoints

- \`GET /api/health\` - Health check endpoint

## License

MIT
EOF
  
  # Create GitHub Actions workflow file
  mkdir -p .github/workflows
  cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  backend:
    name: Backend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.20'
          
      - name: Install backend dependencies
        run: go mod tidy
          
      - name: Run backend tests
        run: go test ./...
  
  frontend:
    name: Frontend Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install frontend dependencies
        run: cd web && npm install
          
      - name: Build frontend
        run: cd web && npm run build
EOF
  
  # Add all files and commit
  git add .
  git commit -m "Set up fullstack project with Go backend and React frontend"
  
  # If GitHub CLI is available, try to push and create PR
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    # Push the initial-setup branch
    git push -u origin initial-setup
    
    # Create pull request using GitHub CLI
    echo "Creating pull request..."
    gh pr create --title "Initial Fullstack Project Setup" --body "This PR sets up a fullstack application with:

- Go backend API
- React frontend with TypeScript
- Webpack for asset bundling
- Development mode with hot reloading
- Production-ready builds
- GitHub Actions CI setup

Ready for review." --base main || echo "Failed to create PR. You may need to create it manually."
    
    echo "✓ Fullstack project '$project_name' is ready!"
    echo "GitHub: https://github.com/$github_username/$project_name"
  else
    echo "✓ Fullstack project '$project_name' is ready locally!"
  fi
  
  echo ""
  echo "Next steps:"
  if command -v gh &>/dev/null && git remote -v | grep -q origin; then
    echo "1. Review and merge the PR"
  fi
  echo "2. Install dependencies: make install-deps"
  echo "3. Start development servers: make dev"
  echo "4. Access the frontend at: http://localhost:3000"
  echo "5. API is available at: http://localhost:8080/api"
}

# Setup Zsh completion if we're in Zsh
if [ "$CRAFTINGBENCH_SHELL" = "zsh" ] && command -v compdef >/dev/null 2>&1; then
  # Register command completions
  function _craftingbench_completions() {
    local commands=(
      "setup_python_project:Create a Python project"
      "setup_nodejs_backend:Create a Node.js backend (Express + TypeScript)"
      "setup_react_frontend:Create a React frontend (TypeScript)"
      "setup_go_project:Create a Golang project"
      "setup_fullstack_project:Create a Go backend with webpack frontend"
      "setup_plain_project:Create a basic project"
    )
    _describe 'CraftingBench commands' commands
  }
  compdef _craftingbench_completions setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project setup_plain_project
fi

# Print a banner with available commands when the script is sourced
echo "🛠️  CraftingBench loaded!"
echo "Available commands:"
echo "  - setup_python_project <name>     : Create a Python project"
echo "  - setup_nodejs_backend <name>     : Create a Node.js backend (Express + TypeScript)"
echo "  - setup_react_frontend <name>     : Create a React frontend (TypeScript)"
echo "  - setup_go_project <name>         : Create a Golang project"
echo "  - setup_fullstack_project <name>  : Create a Go backend with webpack frontend"
echo "  - setup_plain_project <name>      : Create a basic project" 