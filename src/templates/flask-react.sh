#!/bin/bash

# Source the utility functions
if [ -f "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh" ]; then
  source "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh"
elif [ -n "$CRAFTINGBENCH_DIR" ] && [ -f "$CRAFTINGBENCH_DIR/src/helpers/template-utils.sh" ]; then
  source "$CRAFTINGBENCH_DIR/src/helpers/template-utils.sh"
else
  echo "Error: Cannot find template-utils.sh helper file"
  exit 1
fi

setup_flask_react_project() {
  local project_name="$1"

  # Check for required arguments
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
    echo "Usage: setup_flask_react_project <project_name>"
    return 1
  fi

  # Check for dependencies
  echo "Checking for required dependencies..."
  if ! check_dependencies "python node git"; then
    echo "Missing required dependencies. Please install them and try again."
    return 1
  fi

  # Detect package managers
  echo "Detecting package managers..."
  local python_pkg_manager
  python_pkg_manager=$(detect_python_package_manager)
  local node_pkg_manager
  node_pkg_manager=$(detect_node_package_manager)

  echo "Using $python_pkg_manager for Python dependencies"
  echo "Using $node_pkg_manager for Node.js dependencies"

  # Create project directory structure
  echo "Creating project structure for $project_name..."
  local project_dir
  project_dir="$(pwd)/$project_name"

  # Create main project directory
  mkdir -p "$project_dir"

  # Create backend and frontend directories
  mkdir -p "$project_dir/backend"
  mkdir -p "$project_dir/frontend"

  # Create a README.md
  cat > "$project_dir/README.md" << EOF
# $project_name

A fullstack web application with Flask backend and React frontend.

## Project Structure

\`\`\`
$project_name/
├── backend/         # Flask API server
└── frontend/        # React frontend
\`\`\`

## Development Setup

### Backend (Flask)

\`\`\`bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate
pip install -r requirements.txt
flask run
\`\`\`

### Frontend (React)

\`\`\`bash
cd frontend
$node_pkg_manager install
$node_pkg_manager run dev
\`\`\`
EOF

  # Add GitHub workflow for CI
  mkdir -p "$project_dir/.github/workflows"
  local template_path
  template_path="$(dirname "${BASH_SOURCE[0]}")/github-workflows/flask-react-workflow.yml"
  cp "$template_path" "$project_dir/.github/workflows/ci.yml"
  echo "Added GitHub CI workflow"

  # Setup Flask backend
  setup_flask_backend "$project_dir/backend" "$project_name"

  # Setup React frontend
  setup_react_frontend "$project_dir/frontend" "$project_name"

  # Initialize Git repository
  cd "$project_dir" || return 1
  git init

  # Create .gitignore file
  cat > "$project_dir/.gitignore" << EOF
# Python
__pycache__/
*.py[cod]
*.\$py.class
*.so
.Python
env/
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
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
.env/
.venv/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# Build artifacts
/build
/dist
/.out/

# Local env files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
.DS_Store
EOF

  # Create initial git commit
  git add .
  git commit -m "Initial commit: Flask + React project setup"

  echo "Flask + React project '$project_name' created successfully!"
  echo ""
  echo "To start development:"
  echo ""
  echo "Backend (Flask):"
  echo "  cd $project_name/backend"
  echo "  python -m venv venv"
  echo "  source venv/bin/activate  # On Windows: venv\\Scripts\\activate"
  echo "  pip install -r requirements.txt"
  echo "  flask run"
  echo ""
  echo "Frontend (React):"
  echo "  cd $project_name/frontend"
  echo "  $node_pkg_manager install"
  echo "  $node_pkg_manager run dev"

  return 0
}

setup_flask_backend() {
  local project_dir="$1"
  local python_pkg_manager="$2"
  local backend_dir="$project_dir/backend"

  log_info "Setting up Flask backend..."

  # Create Flask application structure
  mkdir -p "$backend_dir/app"
  mkdir -p "$backend_dir/app/api"
  mkdir -p "$backend_dir/app/models"
  mkdir -p "$backend_dir/app/config"
  mkdir -p "$backend_dir/tests"

  # Create Flask backend files
  create_flask_app "$backend_dir"
  create_flask_config "$backend_dir"
  create_flask_requirements "$backend_dir"
  create_flask_tests "$backend_dir"
  create_flask_gitignore "$backend_dir"

  log_success "Flask backend setup complete"
}

create_flask_app() {
  local backend_dir="$1"

  # Create __init__.py files
  touch "$backend_dir/app/__init__.py"
  touch "$backend_dir/app/api/__init__.py"
  touch "$backend_dir/app/models/__init__.py"
  touch "$backend_dir/app/config/__init__.py"
  touch "$backend_dir/tests/__init__.py"

  # Create app/__init__.py
  cat > "$backend_dir/app/__init__.py" << EOF
from flask import Flask
from flask_cors import CORS
from app.config.config import Config

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Enable CORS
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    # Register blueprints
    from app.api.routes import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')

    @app.route('/health')
    def health():
        return {"status": "ok"}

    return app
EOF

  # Create app/api/routes.py
  cat > "$backend_dir/app/api/routes.py" << EOF
from flask import Blueprint, jsonify

api_bp = Blueprint('api', __name__)

@api_bp.route('/hello', methods=['GET'])
def hello():
    return jsonify({"message": "Hello from Flask Backend!"})
EOF

  # Create main.py
  cat > "$backend_dir/main.py" << EOF
from app import create_app

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
EOF
}

create_flask_config() {
  local backend_dir="$1"

  # Create config.py
  cat > "$backend_dir/app/config/config.py" << EOF
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'hard-to-guess-string'
    DEBUG = os.environ.get('FLASK_DEBUG', '0') == '1'

    # Database
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///app.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # API keys and external services
    API_KEY = os.environ.get('API_KEY')
EOF

  # Create .env.example
  local env_content="# Flask Configuration
FLASK_APP=main.py
FLASK_DEBUG=1
SECRET_KEY=your-secret-key-here

# Database
DATABASE_URL=sqlite:///app.db

# API Keys
API_KEY=your-api-key-here"

  create_env_example "$backend_dir" "$env_content"

  # Create gitignore
  create_gitignore "$backend_dir" "python"

  # Create tests directory
}

create_flask_requirements() {
  local backend_dir="$1"

  # Create requirements.txt
  cat > "$backend_dir/requirements.txt" << EOF
flask==2.3.3
flask-cors==4.0.0
python-dotenv==1.0.0
pytest==7.4.0
pytest-cov==4.1.0
flake8==6.1.0
SQLAlchemy==2.0.20
EOF
}

create_flask_tests() {
  local backend_dir="$1"

  # Create test_app.py
  cat > "$backend_dir/tests/test_app.py" << EOF
import pytest
from app import create_app

@pytest.fixture
def app():
    app = create_app()
    app.config.update({
        "TESTING": True,
    })
    yield app

@pytest.fixture
def client(app):
    return app.test_client()

def test_health_endpoint(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "ok"

def test_hello_endpoint(client):
    response = client.get("/api/hello")
    assert response.status_code == 200
    assert "message" in response.json
EOF

  # Create pytest.ini
  cat > "$backend_dir/pytest.ini" << EOF
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
python_classes = Test*
addopts = --cov=app --cov-report=term-missing
EOF
}

create_flask_gitignore() {
  local backend_dir="$1"

  # Create .gitignore for Python
  cat > "$backend_dir/.gitignore" << EOF
# Python
__pycache__/
*.py[cod]
*.\$py.class
*.so
.Python
env/
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
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
.env/
.venv/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
.pnpm-store/

# Build artifacts
/build
/dist
/.out/

# Local env files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
.DS_Store
EOF
}

setup_react_frontend() {
  local project_dir="$1"
  local node_pkg_manager="$2"
  local frontend_dir="$project_dir/frontend"

  log_info "Setting up React frontend..."

  # Create package.json
  cat > "$frontend_dir/package.json" << EOF
{
  "name": "frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "typecheck": "tsc --noEmit",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  },
  "dependencies": {
    "@emotion/react": "^11.11.1",
    "@emotion/styled": "^11.11.0",
    "@mui/material": "^5.14.8",
    "axios": "^1.5.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.15.0"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^6.1.3",
    "@testing-library/react": "^14.0.0",
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.3",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "jsdom": "^22.1.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.5",
    "vitest": "^0.34.3"
  }
}
EOF

  # Create tsconfig.json
  cat > "$frontend_dir/tsconfig.json" << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,

    /* Paths */
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
EOF

  # Create tsconfig.node.json
  cat > "$frontend_dir/tsconfig.node.json" << EOF
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
  cat > "$frontend_dir/vite.config.ts" << EOF
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.ts'],
  },
})
EOF

  # Create project structure
  mkdir -p "$frontend_dir/src/components"
  mkdir -p "$frontend_dir/src/pages"
  mkdir -p "$frontend_dir/src/services"
  mkdir -p "$frontend_dir/src/hooks"
  mkdir -p "$frontend_dir/src/types"
  mkdir -p "$frontend_dir/src/assets"
  mkdir -p "$frontend_dir/public"

  # Create index.html
  cat > "$frontend_dir/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Flask + React App</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

  # Create setup files
  cat > "$frontend_dir/src/main.tsx" << EOF
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
EOF

  cat > "$frontend_dir/src/App.tsx" << EOF
import { useState, useEffect } from 'react'
import { Container, Typography, Box, CircularProgress } from '@mui/material'
import { apiService } from './services/apiService'
import { Message } from './types/message'

function App() {
  const [message, setMessage] = useState<Message | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)
        const response = await apiService.getHello()
        setMessage(response)
      } catch (err) {
        setError('Failed to fetch data from API')
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4, textAlign: 'center' }}>
        <Typography variant="h2" component="h1" gutterBottom>
          Flask + React App
        </Typography>

        {loading ? (
          <CircularProgress />
        ) : error ? (
          <Typography color="error">{error}</Typography>
        ) : (
          <Box sx={{ mt: 4, p: 2, bgcolor: 'background.paper', borderRadius: 1 }}>
            <Typography variant="h5">
              Message from backend: {message?.message}
            </Typography>
          </Box>
        )}
      </Box>
    </Container>
  )
}

export default App
EOF

  cat > "$frontend_dir/src/index.css" << EOF
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

body {
  margin: 0;
  min-height: 100vh;
}

@media (prefers-color-scheme: light) {
  :root {
    color: #213547;
    background-color: #ffffff;
  }
}
EOF

  # Create types
  cat > "$frontend_dir/src/types/message.ts" << EOF
export interface Message {
  message: string;
}
EOF

  # Create services
  cat > "$frontend_dir/src/services/apiService.ts" << EOF
import axios from 'axios';
import { Message } from '../types/message';

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export const apiService = {
  getHello: async (): Promise<Message> => {
    const response = await api.get<Message>('/hello');
    return response.data;
  },
};
EOF

  # Create test setup
  cat > "$frontend_dir/src/setupTests.ts" << EOF
import { expect, afterEach } from 'vitest';
import { cleanup } from '@testing-library/react';
import * as matchers from '@testing-library/jest-dom/matchers';

// Extend Vitest's expect method with methods from react-testing-library
expect.extend(matchers);

// Run cleanup after each test case
afterEach(() => {
  cleanup();
});
EOF

  # Create test file
  cat > "$frontend_dir/src/App.test.tsx" << EOF
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import App from './App';
import { apiService } from './services/apiService';

// Mock the API service
vi.mock('./services/apiService', () => ({
  apiService: {
    getHello: vi.fn(),
  },
}));

describe('App', () => {
  it('renders the app title', () => {
    // Mock API response
    vi.mocked(apiService.getHello).mockResolvedValue({ message: 'Hello from Flask Backend!' });

    render(<App />);

    // Check if the title is rendered
    expect(screen.getByText(/Flask \+ React App/i)).toBeInTheDocument();
  });
});
EOF

  # Create .env.example
  local env_content="# API Configuration
VITE_API_BASE_URL=http://localhost:5000
VITE_ENV=development"

  create_env_example "$frontend_dir" "$env_content"

  # Create .gitignore
  create_gitignore "$frontend_dir" "react"

  log_success "React frontend setup complete"
}

create_default_flask_react_workflow() {
  local project_dir="$1"
  local workflow_file="$project_dir/.github/workflows/flask-react-ci.yml"

  log_info "Creating default Flask+React workflow"

  cat > "$workflow_file" << EOF
name: Flask + React CI

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
        python-version: ['3.9', '3.10', '3.11']

    defaults:
      run:
        working-directory: backend

    steps:
    - uses: actions/checkout@v4

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
        cache: 'pip'
        cache-dependency-path: 'backend/requirements.txt'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        python -m pip install pytest pytest-cov flake8
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

    - name: Lint with flake8
      run: |
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

    - name: Test with pytest
      run: |
        pytest --cov=./ --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: backend/coverage.xml
        flags: backend
        fail_ci_if_error: false

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

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'pnpm'
        cache-dependency-path: 'frontend/pnpm-lock.yaml'

    - name: Install dependencies
      run: pnpm install

    - name: Lint
      run: pnpm lint

    - name: Type check
      run: pnpm typecheck

    - name: Test
      run: pnpm test

    - name: Build
      run: |
        cd frontend
        pnpm build
EOF
}

create_project_readme() {
  local project_dir="$1"
  local project_name="$2"

  cat > "$project_dir/README.md" << EOF
# $project_name

A modern web application with Flask backend and React frontend

## Project Structure

\`\`\`
├── backend/          # Flask backend
│   ├── app/          # Application code
│   │   ├── api/      # API routes
│   │   ├── config/   # Configuration
│   │   └── models/   # Data models
│   ├── tests/        # Test files
│   └── main.py       # Application entry point
└── frontend/         # React frontend
    ├── public/       # Static files
    └── src/          # Source code
        ├── components/   # Reusable components
        ├── pages/        # Page components
        ├── services/     # API services
        ├── hooks/        # Custom hooks
        └── types/        # TypeScript types
\`\`\`

## Features

- ⚡️ Flask backend with RESTful API
- 🔥 React frontend with TypeScript
- 📦 Material UI components
- 🦺 Type checking with TypeScript
- 🧪 Testing with pytest and Vitest
- 📝 ESLint for code quality
- 🚀 GitHub Actions CI pipeline

## Development

### Prerequisites

- Python 3.9 or higher
- Node.js 16 or higher
- Git

### Backend Setup

\`\`\`bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: .\\venv\\Scripts\\activate
pip install -r requirements.txt
\`\`\`

Run the Flask development server:

\`\`\`bash
flask run
# or
python main.py
\`\`\`

The backend will be available at http://localhost:5000

### Frontend Setup

\`\`\`bash
cd frontend
npm install  # or: pnpm install
\`\`\`

Run the React development server:

\`\`\`bash
npm run dev  # or: pnpm dev
\`\`\`

The frontend will be available at http://localhost:5173 and will proxy API requests to the Flask backend.

### Environment Variables

Both backend and frontend have their own environment configuration:

- Backend: Copy \`.env.example\` to \`.env\` in the backend directory
- Frontend: Copy \`.env.example\` to \`.env.local\` in the frontend directory

## Testing

### Backend Testing

\`\`\`bash
cd backend
pytest
# or for coverage
pytest --cov=app
\`\`\`

### Frontend Testing

\`\`\`bash
cd frontend
npm run test       # or: pnpm test
npm run test:watch # or: pnpm test:watch
\`\`\`

## Building for Production

### Backend

The Flask backend can be deployed using WSGI servers like Gunicorn:

\`\`\`bash
pip install gunicorn
gunicorn -w 4 "main:app"
\`\`\`

### Frontend

\`\`\`bash
cd frontend
npm run build  # or: pnpm build
\`\`\`

The build output will be in the \`frontend/dist\` directory.

## License

MIT
EOF
}

# If the script is executed directly, run the setup function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  setup_flask_react_project "$@"
fi
