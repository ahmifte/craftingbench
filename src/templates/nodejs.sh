#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_nodejs_backend() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_nodejs_backend <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "node npm"; then
    return 1
  fi
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Check if the repository already exists, and if so, clone it instead
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Repository already exists. Cloning existing repository..."
    cd ..
    rm -rf "$project_name"
    git clone "https://github.com/$github_username/$project_name.git"
    cd "$project_name" || return 1
  elif command_exists gh; then
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

  # Add CI badge to README
  sed -i.bak "1 s|# $project_name|# $project_name\n\n[![Node.js CI](https://github.com/$github_username/$project_name/actions/workflows/nodejs-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/nodejs-ci.yml)|" README.md
  rm -f README.md.bak
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Copy GitHub Actions workflow file
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/nodejs-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/nodejs-ci.yml
  else
    # Create GitHub Actions workflow file if template is not available
    cat > .github/workflows/nodejs-ci.yml << EOF
name: Node.js CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]

    steps:
    - uses: actions/checkout@v3
    
    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type check
      run: pnpm typecheck
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
EOF
  fi
  
  # Use pnpm if available, otherwise npm
  local npm_cmd="npm"
  if command_exists pnpm; then
    npm_cmd="pnpm"
    echo "Using pnpm for package management"
    # Create .npmrc to ensure consistent package management
    cat > .npmrc << EOF
engine-strict=true
resolution-mode=highest
save-exact=true
auto-install-peers=true
EOF
  fi
  
  # Initialize project with package.json
  echo "Initializing Node.js project..."
  
  # Create package.json with proper structure for TypeScript and Express
  cat > package.json << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "A TypeScript Node.js backend API",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "lint": "eslint . --ext .ts",
    "typecheck": "tsc --noEmit",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "helmet": "^7.0.0",
    "morgan": "^1.10.0",
    "zod": "^3.22.2"
  },
  "devDependencies": {
    "@types/cors": "^2.8.15",
    "@types/express": "^4.17.19",
    "@types/jest": "^29.5.5",
    "@types/morgan": "^1.9.6",
    "@types/node": "^20.8.4",
    "@types/supertest": "^2.0.14",
    "@typescript-eslint/eslint-plugin": "^6.7.5",
    "@typescript-eslint/parser": "^6.7.5",
    "eslint": "^8.51.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-import": "^2.28.1",
    "eslint-plugin-prettier": "^5.0.0",
    "jest": "^29.7.0",
    "prettier": "^3.0.3",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.1",
    "ts-node": "^10.9.1",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.2.2"
  }
}
EOF
  
  # Create .gitignore file
  cat > .gitignore << EOF
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*

# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
out/
.next/
.nuxt/
.output/

# Environment and config
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Testing
coverage/

# Misc
.DS_Store
*.pem
Thumbs.db

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
EOF

  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true,
    "sourceMap": true,
    "resolveJsonModule": true,
    "lib": ["ES2022"]
  },
  "include": ["src/**/*.ts"],
  "exclude": ["node_modules", "dist", "**/*.test.ts", "**/*.spec.ts"]
}
EOF

  # Create ESLint config
  cat > .eslintrc.json << EOF
{
  "env": {
    "node": true,
    "es2022": true,
    "jest": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:import/errors",
    "plugin:import/warnings",
    "plugin:import/typescript",
    "plugin:prettier/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "plugins": ["@typescript-eslint", "import", "prettier"],
  "rules": {
    "prettier/prettier": "error",
    "import/order": [
      "error",
      {
        "groups": ["builtin", "external", "internal", ["parent", "sibling"]],
        "newlines-between": "always",
        "alphabetize": {
          "order": "asc",
          "caseInsensitive": true
        }
      }
    ]
  }
}
EOF

  # Create Prettier config
  cat > .prettierrc << EOF
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2
}
EOF

  # Create Jest config
  cat > jest.config.js << EOF
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts'],
};
EOF

  # Create source directory
  mkdir -p src
  mkdir -p src/controllers
  mkdir -p src/models
  mkdir -p src/routes
  mkdir -p src/middleware
  mkdir -p src/utils
  mkdir -p src/config
  mkdir -p src/__tests__

  # Create example .env file
  cat > .env.example << EOF
PORT=3000
NODE_ENV=development
LOG_LEVEL=debug
EOF

  # Create main application file
  cat > src/index.ts << EOF
import cors from 'cors';
import dotenv from 'dotenv';
import express, { Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import morgan from 'morgan';

import { apiRoutes } from './routes';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Not found handler
app.use((req, res) => {
  res.status(404).json({ message: 'Not Found' });
});

// Error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal Server Error' });
});

// Start server
if (process.env.NODE_ENV !== 'test') {
  app.listen(port, () => {
    console.log(\`Server running on port \${port}\`);
  });
}

export default app;
EOF

  # Create routes file
  cat > src/routes/index.ts << EOF
import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.json({ message: 'Welcome to the API' });
});

export const apiRoutes = router;
EOF

  # Create a basic test
  cat > src/__tests__/app.test.ts << EOF
import request from 'supertest';

import app from '../index';

describe('API Endpoints', () => {
  it('should return a welcome message', async () => {
    const res = await request(app).get('/api');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('message');
    expect(res.body.message).toEqual('Welcome to the API');
  });

  it('should return health status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('status');
    expect(res.body.status).toEqual('UP');
  });

  it('should return 404 for unknown routes', async () => {
    const res = await request(app).get('/unknown-route');
    expect(res.statusCode).toEqual(404);
    expect(res.body).toHaveProperty('message');
    expect(res.body.message).toEqual('Not Found');
  });
});
EOF

  # Create README content
  cat > README.md << EOF
# $project_name

[![Node.js CI](https://github.com/$github_username/$project_name/actions/workflows/nodejs-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/nodejs-ci.yml)

A TypeScript Node.js backend API with Express.

## Features

- TypeScript for type safety
- Express for API endpoints
- Jest for unit and integration testing
- ESLint and Prettier for code quality
- GitHub Actions for CI/CD

## Getting Started

### Prerequisites

- Node.js v16 or higher
- npm or pnpm package manager

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies with pnpm (recommended)
pnpm install

# Or with npm
npm install
\`\`\`

### Development

\`\`\`bash
# Start development server with hot reload
pnpm dev

# Run tests
pnpm test

# Run linter
pnpm lint

# Type check
pnpm typecheck

# Build for production
pnpm build
\`\`\`

### Environment Variables

Copy the example environment file:

\`\`\`bash
cp .env.example .env
\`\`\`

Available environment variables:

- \`PORT\`: The port the server will run on (default: 3000)
- \`NODE_ENV\`: The environment mode (development, production, test)
- \`LOG_LEVEL\`: The logging level (debug, info, warn, error)

## Project Structure

\`\`\`
src/
├── __tests__/       # Tests
├── config/          # App configurations
├── controllers/     # Route controllers
├── middleware/      # Custom middleware
├── models/          # Data models
├── routes/          # API routes
├── utils/           # Utility functions
└── index.ts         # App entry point
\`\`\`

## API Documentation

### Endpoints

- \`GET /api\`: Welcome message
- \`GET /health\`: Health check endpoint

## License

MIT
EOF

  # Install packages using the selected package manager
  echo "Installing dependencies with $npm_cmd..."
  $npm_cmd install
  
  # Add all files to git
  git add .
  git commit -m "Setup Node.js backend with TypeScript and Express"
  
  echo "Node.js backend project has been set up successfully!"
  echo "To start development:"
  echo "  cd $project_name"
  echo "  $npm_cmd dev"
  
  # Push changes if GitHub repo was created
  if command_exists gh && gh repo view "$github_username/$project_name" &>/dev/null; then
    echo "Pushing changes to GitHub..."
    git push -u origin initial-setup
    echo "Creating pull request for initial setup..."
    gh pr create --title "Initial project setup" --body "Sets up Node.js backend with TypeScript and Express" || true
  fi
} 