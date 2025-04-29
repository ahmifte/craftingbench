#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_nodejs_backend() {
  local project_name="$1"
  
  # Check for required arguments
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
    echo "Usage: setup_nodejs_backend <project_name>"
    return 1
  fi

  # Check for dependencies
  if ! check_dependencies "node git"; then
    return 1
  fi

  # Detect package manager (prefer pnpm)
  if command -v pnpm &> /dev/null; then
    echo "Using pnpm package manager for faster dependency management"
    NODE_PACKAGE_MANAGER="pnpm"
  else
    echo "Using npm as package manager (consider installing pnpm for faster dependency management)"
    NODE_PACKAGE_MANAGER="npm"
  fi

  # Create project directory and navigate to it
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize Git repository
  git init

  # Check if GitHub repository exists
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  if command -v gh &> /dev/null; then
    echo "Checking if GitHub repository exists: $github_username/$project_name"
    if gh repo view "$github_username/$project_name" &> /dev/null; then
      echo "GitHub repository exists. Cloning and setting up..."
      rm -rf .git
      gh repo clone "$github_username/$project_name" .
      git checkout -b main || git checkout main
    else
      echo "Creating new GitHub repository: $github_username/$project_name"
      gh repo create "$github_username/$project_name" --public --source=. --remote=origin
    fi
  else
    echo "GitHub CLI (gh) not found. Skipping GitHub repository setup."
    echo "Install GitHub CLI from https://cli.github.com/ for GitHub integration."
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Copy workflow template or create default workflow
  if [ -f "$CRAFTINGBENCH_PATH/src/templates/github-workflows/nodejs-workflow.yml" ]; then
    cp "$CRAFTINGBENCH_PATH/src/templates/github-workflows/nodejs-workflow.yml" .github/workflows/nodejs-ci.yml
    # Replace placeholder with actual project name in workflow
    sed -i.bak "s/Node.js CI/$project_name CI/g" .github/workflows/nodejs-ci.yml
    rm -f .github/workflows/nodejs-ci.yml.bak
  else
    # Create a default workflow file
    cat > .github/workflows/nodejs-ci.yml << EOF
name: $project_name CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
    
    - name: Install pnpm
      uses: pnpm/action-setup@v2
      with:
        version: latest
        run_install: false
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
EOF
  fi

  # Create package.json
  cat > package.json << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "Node.js backend application",
  "main": "dist/index.js",
  "scripts": {
    "dev": "nodemon --exec ts-node src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "lint": "eslint . --ext .ts",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.3",
    "@types/node": "^18.16.19",
    "@typescript-eslint/eslint-plugin": "^5.62.0",
    "@typescript-eslint/parser": "^5.62.0",
    "eslint": "^8.45.0",
    "jest": "^29.6.1",
    "nodemon": "^3.0.1",
    "ts-jest": "^29.1.1",
    "ts-node": "^10.9.1",
    "typescript": "^5.1.6"
  },
  "dependencies": {
    "dotenv": "^16.3.1",
    "express": "^4.18.2"
  }
}
EOF

  # Create tsconfig.json
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "es2019",
    "module": "commonjs",
    "lib": ["es2019", "esnext.asynciterable"],
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "moduleResolution": "node",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOF

  # Create .gitignore
  cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build output
dist/

# Testing
coverage/

# IDE
.idea/
.vscode/*
!.vscode/extensions.json
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json

# Logs
logs
*.log

# System Files
.DS_Store
Thumbs.db
EOF

  # Create README.md with CI badge
  cat > README.md << EOF
# $project_name

[![CI Status](https://github.com/$github_username/$project_name/workflows/$project_name%20CI/badge.svg)](https://github.com/$github_username/$project_name/actions)

Node.js backend application built with Express and TypeScript.

## Features

- TypeScript support
- Express.js web server
- Environment variable configuration
- Testing with Jest
- ESLint for code quality
- GitHub Actions CI pipeline

## Development

### Setup

\`\`\`bash
# Install dependencies
pnpm install

# Start development server
pnpm dev
\`\`\`

### Testing

\`\`\`bash
# Run tests
pnpm test

# Run tests with coverage
pnpm test:coverage
\`\`\`

### Building

\`\`\`bash
# Build for production
pnpm build

# Run production build
pnpm start
\`\`\`

## Environment Variables

Copy the example environment file and modify as needed:

\`\`\`bash
cp .env.example .env
\`\`\`
EOF

  # Create .env.example
  cat > .env.example << EOF
# Application Configuration
NODE_ENV=development
PORT=3000
HOST=localhost
LOG_LEVEL=debug

# API Configuration
API_PREFIX=/api
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX=100

# Authentication
JWT_SECRET=replace_with_secure_secret_key
JWT_EXPIRATION=1h
REFRESH_TOKEN_EXPIRATION=7d

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=${project_name}_db
DATABASE_URL=postgresql://postgres:password@localhost:5432/${project_name}_db

# Redis Configuration (if needed)
REDIS_URL=redis://localhost:6379

# External APIs
EXTERNAL_API_URL=https://api.example.com
EXTERNAL_API_KEY=your_api_key_here

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
EOF

  # Create actual .env file (gitignored)
  cp .env.example .env

  # Create src directory structure
  mkdir -p src/controllers src/models src/routes src/middleware src/services src/types src/utils src/config

  # Create index.ts
  cat > src/index.ts << EOF
import express from 'express';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to $project_name API' });
});

// Start server
app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});

export default app;
EOF

  # Create a simple controller
  cat > src/controllers/healthController.ts << EOF
import { Request, Response } from 'express';

export const healthCheck = (req: Request, res: Response): void => {
  res.status(200).json({
    status: 'OK',
    uptime: process.uptime(),
    timestamp: Date.now(),
  });
};
EOF

  # Create routes file
  cat > src/routes/index.ts << EOF
import express from 'express';
import { healthCheck } from '../controllers/healthController';

const router = express.Router();

// Health check route
router.get('/health', healthCheck);

export default router;
EOF

  # Create a basic test file
  mkdir -p src/__tests__
  cat > src/__tests__/health.test.ts << EOF
import request from 'supertest';
import app from '../index';

describe('Health Check Endpoint', () => {
  it('should return 200 OK status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'OK');
    expect(response.body).toHaveProperty('uptime');
    expect(response.body).toHaveProperty('timestamp');
  });
});
EOF

  # Create jest.config.js
  cat > jest.config.js << EOF
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/types/**/*.ts',
  ],
};
EOF

  # Initialize a new Node.js project
  if [ "$NODE_PACKAGE_MANAGER" = "pnpm" ]; then
    pnpm install
  else
    npm install
  fi

  # Commit changes
  git add .
  git commit -m "Initial project setup for $project_name"

  # Display success message
  echo ""
  echo "🚀 Node.js backend project '$project_name' has been set up successfully!"
  echo "To start development, navigate to the project directory and run the development server:"
  echo ""
  echo "  cd $project_name"
  if [ "$NODE_PACKAGE_MANAGER" = "pnpm" ]; then
    echo "  pnpm dev"
  else
    echo "  npm run dev"
  fi
  echo ""
} 