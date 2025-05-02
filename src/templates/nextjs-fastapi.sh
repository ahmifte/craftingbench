#!/usr/bin/env bash

# shellcheck source=src/helpers/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

# shellcheck source=src/helpers/template-utils.sh
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/template-utils.sh"

setup_nextjs_fastapi_project() {
  local project_name="$1"

  # Check if project name is provided
  if [ -z "$project_name" ]; then
    log_error "Project name is required"
    echo "Usage: setup_nextjs_fastapi_project <project-name>"
    return 1
  fi

  # Check dependencies
  check_dependencies "node" "python" "git" || return 1

  # Detect package managers
  local node_pkg_manager
  node_pkg_manager=$(detect_node_package_manager)

  local python_pkg_manager
  python_pkg_manager=$(detect_python_package_manager)

  log_info "Using Node.js package manager: $node_pkg_manager"
  log_info "Using Python package manager: $python_pkg_manager"

  log_info "Setting up Next.js + FastAPI project: $project_name"

  # Create project directory and navigate into it
  mkdir -p "$project_name"
  cd "$project_name" || exit 1

  # Initialize git repository
  git init

  # Create main README.md
  cat > README.md << EOF
# $project_name

A full-stack application with Next.js frontend and FastAPI backend.

## Features

- **Frontend**: Next.js with TypeScript, TailwindCSS, and Material UI
- **Backend**: FastAPI with Python
- **CI/CD**: GitHub Actions workflow for testing and building
- **Containerization**: Docker setup for both frontend and backend
- **Code Quality**: Pre-commit hooks for linting and formatting

## Development Setup

### Prerequisites

- Node.js 16.x or later
- Python 3.9 or later
- pnpm (recommended) or npm
- Git

### Getting Started

1. Clone the repository
   \`\`\`
   git clone https://github.com/yourusername/$project_name.git
   cd $project_name
   \`\`\`

2. Set up the backend
   \`\`\`
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\\Scripts\\activate
   pip install -r requirements.txt
   cp .env.example .env  # Configure your environment variables
   \`\`\`

3. Set up the frontend
   \`\`\`
   cd frontend
   $node_pkg_manager install
   cp .env.example .env.local  # Configure your environment variables
   \`\`\`

4. Run the development servers
   - Backend: \`cd backend && uvicorn main:app --reload\`
   - Frontend: \`cd frontend && $node_pkg_manager run dev\`

## Environment Variables

- See \`.env.example\` files in both frontend and backend directories.

## Testing

- Backend: \`cd backend && pytest\`
- Frontend: \`cd frontend && $node_pkg_manager run test\`

## Building for Production

- Backend: See Dockerfile in the backend directory
- Frontend: \`cd frontend && $node_pkg_manager run build\`

## Deployment

See the deployment documentation for your specific hosting solution.

## CI/CD

This project includes a GitHub Actions workflow that:
- Tests and lints the backend (FastAPI)
- Tests, lints, and builds the frontend (Next.js)

[![CI Status](https://github.com/yourusername/$project_name/actions/workflows/nextjs-fastapi-ci.yml/badge.svg)](https://github.com/yourusername/$project_name/actions/workflows/nextjs-fastapi-ci.yml)

### Code Quality with Pre-commit Hooks

This project uses pre-commit hooks to maintain code quality. To set up:

1. Install pre-commit:
   \`\`\`
   pip install pre-commit
   \`\`\`

2. Install the git hooks:
   \`\`\`
   pre-commit install
   \`\`\`

3. Now checks will run automatically on every commit.

You can manually run all hooks with:
\`\`\`
pre-commit run --all-files
\`\`\`

## Project Structure

\`\`\`
.
├── backend/              # FastAPI backend
│   ├── app/              # Application code
│   ├── tests/            # Test files
│   ├── main.py           # Application entry point
│   ├── requirements.txt  # Python dependencies
│   └── Dockerfile        # Backend container definition
├── frontend/             # Next.js frontend
│   ├── public/           # Static assets
│   ├── src/              # Source code
│   │   ├── app/          # Next.js App Router
│   │   ├── components/   # React components
│   │   ├── services/     # API service layer
│   │   └── theme/        # Material UI theming
│   ├── package.json      # Node.js dependencies
│   └── Dockerfile        # Frontend container definition
├── .github/              # GitHub configuration
│   └── workflows/        # GitHub Actions CI/CD
├── docker-compose.yml    # Docker Compose configuration
├── Makefile              # Development commands
├── .pre-commit-config.yaml # Pre-commit hooks
└── README.md             # Project documentation
\`\`\`

## Development Workflow

This project provides a Makefile with helpful commands for development:

- \`make help\`: Show available commands
- \`make install\`: Install dependencies for backend and frontend
- \`make dev\`: Start both development servers
- \`make test\`: Run all tests
- \`make lint\`: Run linters for both codebases
- \`make format\`: Format all code
- \`make build\`: Build the applications for production
- \`make docker-up\`: Start containers with Docker Compose

## Backend Features

- Modern FastAPI with type checking
- Pydantic v2 for data validation and serialization
- SQLAlchemy for database ORM (configured for SQLite by default)
- Automatic API documentation with Swagger/ReDoc
- Environment-based configuration
- Testing with pytest
- Linting with Ruff and mypy

## Frontend Features

- Next.js App Router architecture
- TypeScript for static type checking
- Material UI for beautiful, responsive components
- Dark/light theme support
- API service layer for backend communication
- Jest for unit testing
- ESLint and Prettier for code quality
EOF

  # Create project structure
  mkdir -p frontend backend
  mkdir -p .github/workflows

  # Set up GitHub Actions workflow
  if [ -f "$CRAFT_TEMPLATE_DIR/github-workflows/nextjs-fastapi-workflow.yml" ]; then
    echo "Using existing Next.js + FastAPI workflow template"
    cp "$CRAFT_TEMPLATE_DIR/github-workflows/nextjs-fastapi-workflow.yml" .github/workflows/nextjs-fastapi-ci.yml
  else
    echo "Creating default Next.js + FastAPI workflow"
    cat > .github/workflows/nextjs-fastapi-ci.yml << EOF
name: Next.js + FastAPI CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.9", "3.10", "3.11"]
    defaults:
      run:
        working-directory: backend

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python \${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: \${{ matrix.python-version }}
        cache: 'pip'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install uv
        uv pip install pytest pytest-cov ruff mypy
        if [ -f requirements.txt ]; then uv pip install -r requirements.txt; fi

    - name: Lint with ruff
      run: |
        ruff .

    - name: Type check with mypy
      run: |
        mypy .

    - name: Test with pytest
      run: |
        pytest --cov=. --cov-report=xml
      env:
        DATABASE_URL: sqlite:///test.db
        SECRET_KEY: test_secret_key

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./backend/coverage.xml
        flags: backend

  frontend:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    defaults:
      run:
        working-directory: frontend

    steps:
    - uses: actions/checkout@v4

    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
        run_install: false

    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
        cache-dependency-path: frontend/pnpm-lock.yaml

    - name: Install dependencies
      run: pnpm install

    - name: Lint
      run: pnpm run lint

    - name: Type check
      run: pnpm run typecheck

    - name: Test
      run: pnpm run test

    - name: Build
      run: pnpm run build

    - name: Cache Next.js build
      uses: actions/cache@v3
      with:
        path: |
          frontend/.next/cache
        key: \${{ runner.os }}-nextjs-\${{ hashFiles('frontend/pnpm-lock.yaml') }}
EOF
  fi

  # Set up backend (FastAPI)
  cd backend || exit 1

  # Create Python virtual environment and requirements.txt

  # Create requirements.txt
  cat > requirements.txt << EOF
fastapi>=0.95.0
uvicorn>=0.21.0
pydantic>=2.0.0
sqlalchemy>=2.0.0
alembic>=1.10.0
python-dotenv>=1.0.0
pytest>=7.3.0
httpx>=0.24.0
pytest-cov>=4.1.0
ruff>=0.0.262
mypy>=1.3.0
EOF

  if [ "$python_pkg_manager" = "uv" ]; then
    log_info "Creating virtual environment with UV"
    uv venv .venv
    source .venv/bin/activate || exit 1

    # Install dependencies with UV
    log_info "Installing dependencies with UV"
    uv pip install -r requirements.txt
  else
    log_info "Creating virtual environment with standard venv"
    python -m venv venv
    source venv/bin/activate || exit 1

    # Install dependencies with pip
    log_info "Installing dependencies with pip"
    pip install -r requirements.txt
  fi

  # Create .env.example
  cat > .env.example << EOF
# Application
APP_NAME=$project_name
APP_ENV=development
DEBUG=true
SECRET_KEY=your_secret_key_here
ALLOWED_HOSTS=localhost,127.0.0.1

# Logging
LOG_LEVEL=INFO

# Database
DATABASE_URL=sqlite:///./app.db

# CORS
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000

# API
API_PREFIX=/api/v1
API_TITLE=$project_name API
API_DESCRIPTION=FastAPI backend for $project_name
API_VERSION=0.1.0

# Security
JWT_SECRET=your_jwt_secret_here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# External Services
# REDIS_URL=redis://localhost:6379/0
# EMAIL_HOST=smtp.example.com
# EMAIL_PORT=587
# EMAIL_USER=user@example.com
# EMAIL_PASSWORD=your_email_password
EOF

  # Set up pre-commit configuration with both Python and JavaScript
  setup_pre_commit "." "python,js"

  # Create standardized .gitignore file for fullstack project
  create_gitignore "." "fullstack"

  # Create main.py
  cat > main.py << EOF
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(
    title="$project_name API",
    description="FastAPI backend for $project_name",
    version="0.1.0",
)

# Configure CORS
origins = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Sample data models
class ItemBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = Field(None, max_length=1000)


class ItemCreate(ItemBase):
    pass


class Item(ItemBase):
    id: int

    class Config:
        from_attributes = True


# Sample database (in-memory for demo)
items_db = [
    {"id": 1, "title": "First Item", "description": "This is the first item"},
    {"id": 2, "title": "Second Item", "description": "This is the second item"},
]


@app.get("/")
def read_root():
    return {"message": f"Welcome to {os.getenv('APP_NAME', '$project_name')} API"}


@app.get("/api/v1/items", response_model=List[Item])
def read_items():
    return items_db


@app.get("/api/v1/items/{item_id}", response_model=Item)
def read_item(item_id: int):
    item = next((item for item in items_db if item["id"] == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@app.post("/api/v1/items", response_model=Item, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate):
    new_id = max(i["id"] for i in items_db) + 1 if items_db else 1
    new_item = {"id": new_id, **item.model_dump()}
    items_db.append(new_item)
    return new_item


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

  # Create test file
  mkdir -p tests
  cat > tests/test_main.py << EOF
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Welcome to $project_name API"}


def test_read_items():
    response = client.get("/api/v1/items")
    assert response.status_code == 200
    assert len(response.json()) > 0


def test_read_item():
    response = client.get("/api/v1/items/1")
    assert response.status_code == 200
    assert response.json()["id"] == 1


def test_read_item_not_found():
    response = client.get("/api/v1/items/999")
    assert response.status_code == 404


def test_create_item():
    response = client.post(
        "/api/v1/items",
        json={"title": "Test Item", "description": "This is a test item"},
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Test Item"
EOF

  # Create Dockerfile
  cat > Dockerfile << EOF
FROM python:3.11-slim

WORKDIR /app

# Install UV for faster package installation
RUN pip install --no-cache-dir uv

COPY requirements.txt .
RUN uv pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

  # Exit venv
  deactivate

  # Back to project root
  cd ..

  # Set up frontend (Next.js)
  cd frontend || exit 1

  # Initialize Next.js with TypeScript and TailwindCSS
  if [ "$node_pkg_manager" = "pnpm" ]; then
    pnpm create next-app . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git
    pnpm add -D @testing-library/react @testing-library/jest-dom @testing-library/user-event jest jest-environment-jsdom

    # Add Material UI
    log_info "Adding Material UI packages..."
    pnpm add @mui/material @emotion/react @emotion/styled @mui/icons-material
  else
    npx create-next-app . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --no-git
    npm install -D @testing-library/react @testing-library/jest-dom @testing-library/user-event jest jest-environment-jsdom

    # Add Material UI
    log_info "Adding Material UI packages..."
    npm install @mui/material @emotion/react @emotion/styled @mui/icons-material
  fi

  # Create .env.example
  cat > .env.example << EOF
# Application
NEXT_PUBLIC_APP_NAME=$project_name
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
EOF

  # Update package.json to add test script
  jq '.scripts.test = "jest" | .scripts.typecheck = "tsc --noEmit"' package.json > package.json.tmp
  mv package.json.tmp package.json

  # Configure Jest
  cat > jest.config.js << EOF
const nextJest = require('next/jest');

const createJestConfig = nextJest({
  dir: './',
});

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
};

module.exports = createJestConfig(customJestConfig);
EOF

  cat > jest.setup.js << EOF
import '@testing-library/jest-dom';
EOF

  # Create API service
  mkdir -p src/services
  cat > src/services/api.ts << EOF
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';

export interface Item {
  id: number;
  title: string;
  description?: string;
}

export const fetchItems = async (): Promise<Item[]> => {
  const response = await fetch(\`\${API_URL}/items\`);
  if (!response.ok) {
    throw new Error('Failed to fetch items');
  }
  return response.json();
};

export const fetchItem = async (id: number): Promise<Item> => {
  const response = await fetch(\`\${API_URL}/items/\${id}\`);
  if (!response.ok) {
    throw new Error('Failed to fetch item');
  }
  return response.json();
};

export const createItem = async (item: Omit<Item, 'id'>): Promise<Item> => {
  const response = await fetch(\`\${API_URL}/items\`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(item),
  });
  if (!response.ok) {
    throw new Error('Failed to create item');
  }
  return response.json();
};
EOF

  # Create a component
  mkdir -p src/components
  cat > src/components/ItemList.tsx << EOF
'use client';

import { useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Card,
  CardContent,
  List,
  ListItem,
  CircularProgress,
  Alert
} from '@mui/material';
import { fetchItems, Item } from '@/services/api';

export default function ItemList() {
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const getItems = async () => {
      try {
        setLoading(true);
        const data = await fetchItems();
        setItems(data);
        setError(null);
      } catch (err) {
        setError('Failed to fetch items');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    getItems();
  }, []);

  if (loading) return (
    <Box display="flex" justifyContent="center" my={4}>
      <CircularProgress />
    </Box>
  );

  if (error) return (
    <Box my={2}>
      <Alert severity="error">{error}</Alert>
    </Box>
  );

  return (
    <Box my={4}>
      <Typography variant="h5" component="h2" gutterBottom>
        Items
      </Typography>

      {items.length === 0 ? (
        <Typography color="textSecondary">No items found</Typography>
      ) : (
        <List>
          {items.map((item) => (
            <ListItem key={item.id} sx={{ px: 0 }}>
              <Card variant="outlined" sx={{ width: '100%' }}>
                <CardContent>
                  <Typography variant="h6">{item.title}</Typography>
                  {item.description && (
                    <Typography variant="body2" color="textSecondary">
                      {item.description}
                    </Typography>
                  )}
                </CardContent>
              </Card>
            </ListItem>
          ))}
        </List>
      )}
    </Box>
  );
}
EOF

  # Test for the component
  mkdir -p src/__tests__/components
  cat > src/__tests__/components/ItemList.test.tsx << EOF
import { render, screen, waitFor } from '@testing-library/react';
import ItemList from '@/components/ItemList';
import { fetchItems } from '@/services/api';

// Mock the API service
jest.mock('@/services/api');
const mockFetchItems = fetchItems as jest.MockedFunction<typeof fetchItems>;

describe('ItemList', () => {
  it('displays loading state initially', () => {
    mockFetchItems.mockImplementation(() => new Promise(() => {}));
    render(<ItemList />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('displays items when loaded successfully', async () => {
    mockFetchItems.mockResolvedValue([
      { id: 1, title: 'Test Item 1', description: 'Test Description 1' },
      { id: 2, title: 'Test Item 2' },
    ]);

    render(<ItemList />);

    await waitFor(() => {
      expect(screen.getByText('Test Item 1')).toBeInTheDocument();
      expect(screen.getByText('Test Description 1')).toBeInTheDocument();
      expect(screen.getByText('Test Item 2')).toBeInTheDocument();
    });
  });

  it('displays error message when fetch fails', async () => {
    mockFetchItems.mockRejectedValue(new Error('Failed to fetch'));

    render(<ItemList />);

    await waitFor(() => {
      expect(screen.getByText('Failed to fetch items')).toBeInTheDocument();
    });
  });
});
EOF

  # Update the home page
  cat > src/app/page.tsx << EOF
import { Container, Typography, Box, Paper } from '@mui/material';
import ItemList from '@/components/ItemList';

export default function Home() {
  return (
    <Container maxWidth="lg">
      <Box
        component="main"
        sx={{
          py: 8,
          minHeight: '100vh',
        }}
      >
        <Typography variant="h2" component="h1" gutterBottom>
          Welcome to {process.env.NEXT_PUBLIC_APP_NAME || '$project_name'}
        </Typography>
        <Typography variant="body1" paragraph>
          A full-stack application with Next.js frontend and FastAPI backend.
        </Typography>

        <Paper
          elevation={2}
          sx={{
            mt: 4,
            p: 3,
            borderRadius: 2
          }}
        >
          <ItemList />
        </Paper>
      </Box>
    </Container>
  );
}
EOF

  # Create Dockerfile
  cat > Dockerfile << EOF
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# Build the app
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set environment variables
ENV NEXT_TELEMETRY_DISABLED 1

# Build
RUN pnpm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Set the correct permission for prerendered pages
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
EOF

  # Back to project root
  cd ..

  # Create docker-compose.yml
  cat > docker-compose.yml << EOF
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_API_URL=http://backend:8000
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - DEBUG=True
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
EOF

  # Create a makefile in the project root
  cat > Makefile << EOF
.PHONY: help install dev clean test lint format build docker-build docker-up docker-down

help: ## Display this help screen
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-25s\033[0m %s\n", \$\$1, \$\$2}' \$(MAKEFILE_LIST)

install: ## Install dependencies for both frontend and backend
	@echo "Installing dependencies..."
	cd backend && \\
	if command -v uv &> /dev/null; then \\
		uv venv .venv && \\
		source .venv/bin/activate && \\
		uv pip install -r requirements.txt; \\
	else \\
		python -m venv venv && \\
		source venv/bin/activate && \\
		pip install -r requirements.txt; \\
	fi
	cd frontend && $node_pkg_manager install
	pip install pre-commit && pre-commit install

dev: ## Start development servers for both frontend and backend
	@echo "Starting development servers..."
	cd backend && \\
	if [ -d ".venv" ]; then \\
		source .venv/bin/activate; \\
	else \\
		source venv/bin/activate; \\
	fi && \\
	uvicorn main:app --reload --port 8000 &
	cd frontend && $node_pkg_manager run dev

test: test-backend test-frontend ## Run all tests

test-backend: ## Run backend tests
	@echo "Running backend tests..."
	cd backend && \\
	if [ -d ".venv" ]; then \\
		source .venv/bin/activate; \\
	else \\
		source venv/bin/activate; \\
	fi && \\
	pytest

test-frontend: ## Run frontend tests
	@echo "Running frontend tests..."
	cd frontend && $node_pkg_manager run test

lint: lint-backend lint-frontend ## Lint all code

lint-backend: ## Lint backend code
	@echo "Linting backend code..."
	cd backend && \\
	if [ -d ".venv" ]; then \\
		source .venv/bin/activate; \\
	else \\
		source venv/bin/activate; \\
	fi && \\
	ruff check . && \\
	mypy .

lint-frontend: ## Lint frontend code
	@echo "Linting frontend code..."
	cd frontend && $node_pkg_manager run lint
	cd frontend && $node_pkg_manager run typecheck

format: format-backend format-frontend ## Format all code

format-backend: ## Format backend code
	@echo "Formatting backend code..."
	cd backend && \\
	if [ -d ".venv" ]; then \\
		source .venv/bin/activate; \\
	else \\
		source venv/bin/activate; \\
	fi && \\
	ruff format . && \\
	isort .

format-frontend: ## Format frontend code
	@echo "Formatting frontend code..."
	cd frontend && npx prettier --write 'src/**/*.{ts,tsx,css,json}'

build: ## Build the frontend and backend for production
	@echo "Building for production..."
	cd frontend && $node_pkg_manager run build

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	rm -rf frontend/.next frontend/out frontend/build backend/__pycache__ backend/**/__pycache__ .pytest_cache backend/.pytest_cache

docker-build: ## Build Docker images
	@echo "Building Docker images..."
	docker-compose build

docker-up: ## Start services with Docker
	@echo "Starting Docker services..."
	docker-compose up -d

docker-down: ## Stop Docker services
	@echo "Stopping Docker services..."
	docker-compose down
EOF

  # Initial commit
  git add .
  git commit -m "Initial commit: Next.js + FastAPI project setup"

  echo "Next.js + FastAPI project '$project_name' has been set up successfully."
  echo "To start development:"
  echo "  cd $project_name"
  echo "  make install"
  echo "  make dev"
  echo ""
  echo "Backend API will be available at: http://localhost:8000"
  echo "Frontend will be available at: http://localhost:3000"

  # Create theme provider
  mkdir -p src/theme
  cat > src/theme/ThemeProvider.tsx << EOF
'use client';

import { createContext, useState, useMemo, useContext, ReactNode } from 'react';
import { createTheme, ThemeProvider as MUIThemeProvider, CssBaseline } from '@mui/material';
import { blue, orange } from '@mui/material/colors';

type Mode = 'light' | 'dark';

interface ColorModeContextType {
  toggleColorMode: () => void;
  mode: Mode;
}

const ColorModeContext = createContext<ColorModeContextType>({
  toggleColorMode: () => {},
  mode: 'light',
});

export function useColorMode() {
  return useContext(ColorModeContext);
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [mode, setMode] = useState<Mode>('light');

  const colorMode = useMemo(
    () => ({
      toggleColorMode: () => {
        setMode((prevMode) => (prevMode === 'light' ? 'dark' : 'light'));
      },
      mode,
    }),
    [mode]
  );

  const theme = useMemo(
    () =>
      createTheme({
        palette: {
          mode,
          primary: blue,
          secondary: orange,
        },
      }),
    [mode]
  );

  return (
    <ColorModeContext.Provider value={colorMode}>
      <MUIThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </MUIThemeProvider>
    </ColorModeContext.Provider>
  );
}
EOF

  # Create a theme registry
  mkdir -p src/app/components
  cat > src/app/components/ThemeRegistry.tsx << EOF
'use client';

import { ReactNode } from 'react';
import { ThemeProvider } from '@/theme/ThemeProvider';

export default function ThemeRegistry({ children }: { children: ReactNode }) {
  return <ThemeProvider>{children}</ThemeProvider>;
}
EOF

  # Update layout.tsx to use ThemeRegistry
  cat > src/app/layout.tsx << EOF
import { Inter } from 'next/font/google';
import ThemeRegistry from '@/app/components/ThemeRegistry';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: '$project_name',
  description: 'A full-stack application with Next.js frontend and FastAPI backend',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ThemeRegistry>{children}</ThemeRegistry>
      </body>
    </html>
  );
}
EOF

  # Set up pre-commit configuration with both Python and JavaScript
  setup_pre_commit "." "python,js"

  # Create ruff.toml for Python linting
  cat > ruff.toml << EOF
# Enable flake8-bugbear (`B`) rules.
select = ["E", "F", "B", "I"]

# Exclude a variety of commonly ignored directories.
exclude = [
    ".bzr",
    ".direnv",
    ".eggs",
    ".git",
    ".git-rewrite",
    ".hg",
    ".mypy_cache",
    ".nox",
    ".pants.d",
    ".pytype",
    ".ruff_cache",
    ".svn",
    ".tox",
    ".venv",
    "__pypackages__",
    "_build",
    "buck-out",
    "build",
    "dist",
    "node_modules",
    "venv",
]

# Same as Black.
line-length = 88

# Allow unused variables when underscore-prefixed.
dummy-variable-rgx = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$"

# Assume Python 3.10.
target-version = "py310"

[per-file-ignores]
"__init__.py" = ["E402", "F401"]
"tests/**/*.py" = ["E402", "F401", "F811"]

[isort]
known-first-party = ["app"]
EOF

  # Create mypy.ini for type checking
  cat > mypy.ini << EOF
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
strict_optional = True

[mypy.plugins.pydantic.*]
follow_imports = skip
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_return_any = True
warn_unreachable = True

[mypy.plugins.sqlalchemy.*]
follow_imports = skip
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_return_any = True
warn_unreachable = True
EOF

  check_dependencies() {
    for dep in "$@"; do
      if ! command -v "$dep" &> /dev/null; then
        echo "Error: $dep is not installed"
        return 1
      fi
    done
  }
}
