#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"
# Import template utilities
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/template-utils.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/template-utils.sh"

# Direct command aliases for specialized project types
setup_python_library() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_library <project_name>"
    return 1
  fi
  
  setup_python_project "$project_name" --type=library
}

setup_python_backend() {
  local project_name="$1"
  
  if [[ -z "$project_name" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_backend <project_name>"
    return 1
  fi
  
  setup_python_project "$project_name" --type=backend
}

# Help function for Python commands
show_python_help() {
  echo "Python Project Setup Commands:"
  echo ""
  echo "  setup_python_project <project_name> --type=<type>"
  echo "      Creates a new Python project with the specified type"
  echo "      Required: --type=library|backend"
  echo ""
  echo "  setup_python_library <project_name>"
  echo "      Creates a new Python library project"
  echo ""
  echo "  setup_python_backend <project_name>"
  echo "      Creates a new Python Flask API backend"
  echo ""
  echo "Examples:"
  echo "  setup_python_project myproject --type=library"
  echo "  setup_python_library mylib"
  echo "  setup_python_backend myapi"
}

setup_python_project() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_python_help
    return 0
  fi

  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_python_project <project_name> --type=<type>"
    echo "Run 'setup_python_project --help' for more information"
    return 1
  fi
  
  local project_name="$1"
  local project_type=""
  
  # Parse options
  shift 1
  local type_specified=false
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --type=*) 
        project_type="${1#*=}"
        type_specified=true
        ;;
      *) 
        echo "Unknown parameter: $1"
        echo "Run 'setup_python_project --help' for usage information"
        return 1 
        ;;
    esac
    shift
  done
  
  # Ensure project_type is specified
  if [[ "$type_specified" == "false" ]]; then
    echo "Error: Project type must be specified using --type=<type>"
    echo "Supported types: library, backend"
    echo "Example: setup_python_project $project_name --type=library"
    echo "Run 'setup_python_project --help' for more information"
    return 1
  fi
  
  case "$project_type" in
    library)
      _setup_python_library "$project_name"
      ;;
    backend)
      _setup_python_backend "$project_name"
      ;;
    *)
      echo "Error: Unsupported project type: $project_type"
      echo "Supported types: library, backend"
      echo "Run 'setup_python_project --help' for more information"
      return 1
      ;;
  esac
}

_setup_python_library() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python"; then
    return 1
  fi
  
  echo "🚀 Setting up Python library project: $project_name"
  
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
  
  # Create README.md with more content
  cat > README.md << EOF
# $project_name

A Python library created with CraftingBench.

## Installation

\`\`\`bash
pip install $project_name
\`\`\`

## Development

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies
make install

# Update dependencies
make update
\`\`\`

## Usage

\`\`\`python
import $project_name

# Add your usage examples here
\`\`\`

## License

MIT
EOF
  
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
description = "A Python library"
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
  cat > "$project_name/main.py" << EOF
def hello():
    """Return a friendly greeting."""
    return "Hello from $project_name!"
EOF
  
  # Create tests directory and an example test
  mkdir -p tests
  cat > tests/__init__.py << EOF
# Tests package
EOF

  cat > tests/test_main.py << EOF
import pytest
from $project_name.main import hello

def test_hello():
    assert hello() == "Hello from $project_name!"
EOF
  
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
	flake8 $project_name tests

test:
	@echo "Running tests..."
	pytest

clean:
	@echo "Cleaning up..."
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
EOF

  # Initialize git with all the files we've created
  git add .
  git commit -m "feat: Initial Python library setup"
  
  echo "✅ Python library project created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. Initialize a virtual environment: make install"
  echo "  3. Run tests: make test"
  echo ""
}

_setup_python_backend() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python"; then
    return 1
  fi
  
  echo "🚀 Setting up Python Flask backend project: $project_name"
  
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

  # Expand README.md with more content
  cat > README.md << EOF
# $project_name

A Flask backend API created with CraftingBench.

## Features

- RESTful API structure with Flask
- Environment-based configuration
- Pytest for testing
- Logging setup
- Docker support
- OpenAPI documentation

## Development

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies
make install

# Run the development server
make run
\`\`\`

## API Endpoints

- GET /api/health - Health check endpoint
- GET /api/version - API version information

## License

MIT
EOF
  
  # Add CI badge to README
  sed -i.bak "1 s|# $project_name|# $project_name\n\n[![$project_name CI](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/$project_name-ci.yml)|" README.md
  rm -f README.md.bak
  
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
.env.*
!.env.example

# Logs
logs/
*.log

# Docker
.dockerignore
docker-compose.override.yml

# IDEs and editors
.idea/
.vscode/
*.swp
*.swo
*~
EOF
  
  # Create app structure
  mkdir -p app
  mkdir -p app/api
  mkdir -p app/core
  mkdir -p app/models
  mkdir -p app/services
  mkdir -p app/utils
  mkdir -p tests
  mkdir -p logs
  mkdir -p scripts
  mkdir -p config
  
  # Create __init__.py files
  touch app/__init__.py
  touch app/api/__init__.py
  touch app/core/__init__.py
  touch app/models/__init__.py
  touch app/services/__init__.py
  touch app/utils/__init__.py
  touch tests/__init__.py
  
  # Create app factory
  cat > app/__init__.py << EOF
import logging
import os
from logging.handlers import RotatingFileHandler

from flask import Flask
from flask_cors import CORS

from app.api import api_bp


def create_app(config_name=None):
    """Application factory pattern."""
    app = Flask(__name__)

    # Load configuration based on environment
    if config_name is None:
        config_name = os.environ.get("FLASK_ENV", "development")

    # Initialize config
    if config_name == "production":
        app.config.from_object("config.ProductionConfig")
    elif config_name == "testing":
        app.config.from_object("config.TestingConfig")
    else:
        app.config.from_object("config.DevelopmentConfig")

    # Override config from environment variables (if any)
    app.config.from_envvar("APP_CONFIG_FILE", silent=True)

    # Setup logging
    setup_logging(app)

    # Register extensions
    register_extensions(app)

    # Register blueprints
    register_blueprints(app)

    return app


def register_extensions(app):
    """Register Flask extensions."""
    CORS(app)
    return None


def register_blueprints(app):
    """Register Flask blueprints."""
    app.register_blueprint(api_bp, url_prefix="/api")
    return None


def setup_logging(app):
    """Setup logging for the application."""
    # Ensure logs directory exists
    if not os.path.exists("logs"):
        os.makedirs("logs")

    # Set log level
    log_level = app.config.get("LOG_LEVEL", logging.INFO)

    # Create handler for rotating file
    file_handler = RotatingFileHandler(
        "logs/app.log", maxBytes=10240, backupCount=10
    )
    file_handler.setFormatter(
        logging.Formatter(
            "%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]"
        )
    )
    file_handler.setLevel(log_level)

    # Add to app logger
    app.logger.addHandler(file_handler)
    app.logger.setLevel(log_level)
    app.logger.info("$project_name startup")
EOF
  
  # Create API blueprint
  cat > app/api/__init__.py << EOF
from flask import Blueprint

api_bp = Blueprint("api", __name__)

from app.api import routes  # noqa
EOF
  
  # Create API routes
  cat > app/api/routes.py << EOF
import logging
from flask import jsonify, current_app

from app.api import api_bp


@api_bp.route("/health", methods=["GET"])
def health_check():
    """Health check endpoint."""
    return jsonify({"status": "healthy"})


@api_bp.route("/version", methods=["GET"])
def version():
    """Return API version."""
    return jsonify({
        "version": current_app.config.get("API_VERSION", "1.0.0"),
        "name": "$project_name"
    })
EOF
  
  # Create config file
  cat > config.py << EOF
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    """Base config."""
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-key-please-change-in-production")
    API_VERSION = "1.0.0"
    LOG_LEVEL = "INFO"
    
    # SQLAlchemy
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # API settings
    JSON_SORT_KEYS = False
    JSONIFY_PRETTYPRINT_REGULAR = True


class DevelopmentConfig(Config):
    """Development config."""
    DEBUG = True
    TESTING = False
    LOG_LEVEL = "DEBUG"
    
    # Database - uncomment to use SQLAlchemy
    # SQLALCHEMY_DATABASE_URI = 'sqlite:///dev.db'


class TestingConfig(Config):
    """Testing config."""
    DEBUG = False
    TESTING = True
    
    # Use in-memory database for testing
    # SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'


class ProductionConfig(Config):
    """Production config."""
    DEBUG = False
    TESTING = False
    
    # Override these in environment variables or .env file
    SECRET_KEY = os.environ.get("SECRET_KEY")
    
    # Database connection
    # SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL")
EOF
  
  # Create wsgi.py
  cat > wsgi.py << EOF
#!/usr/bin/env python3
import os
from app import create_app

app = create_app(os.environ.get("FLASK_ENV", "development"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
EOF
  chmod +x wsgi.py
  
  # Create .env.example
  cat > .env.example << EOF
# Flask settings
FLASK_APP=wsgi.py
FLASK_ENV=development
SECRET_KEY=your-secret-key-here
PORT=5000

# Database settings (uncomment if using a database)
# DATABASE_URL=postgresql://user:password@localhost/dbname
EOF

  # Create Dockerfile
  cat > Dockerfile << EOF
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Run as non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \\
    PYTHONUNBUFFERED=1 \\
    FLASK_APP=wsgi.py \\
    FLASK_ENV=production

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app"]
EOF
  
  # Create docker-compose.yml
  cat > docker-compose.yml << EOF
version: '3.8'

services:
  api:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/app
    environment:
      - FLASK_APP=wsgi.py
      - FLASK_ENV=development
      - FLASK_DEBUG=1
    command: flask run --host=0.0.0.0
    restart: unless-stopped
    # Uncomment the following if using a database
    # depends_on:
    #   - db
  
  # Uncomment to add a database
  # db:
  #   image: postgres:14-alpine
  #   volumes:
  #     - postgres_data:/var/lib/postgresql/data
  #   environment:
  #     - POSTGRES_USER=postgres
  #     - POSTGRES_PASSWORD=postgres
  #     - POSTGRES_DB=$project_name
  #   ports:
  #     - "5432:5432"

# volumes:
#   postgres_data:
EOF
  
  # Create requirements.txt
  cat > requirements.txt << EOF
flask==2.3.3
flask-cors==4.0.0
python-dotenv==1.0.0
gunicorn==21.2.0
pytest==7.4.0
# Flask extensions
# flask-sqlalchemy==3.0.5
# flask-migrate==4.0.4
# flask-jwt-extended==4.5.3
EOF
  
  # Create tests
  cat > tests/test_api.py << EOF
import pytest
from app import create_app


@pytest.fixture
def client():
    """Create a test client for the app."""
    app = create_app("testing")
    with app.test_client() as client:
        yield client


def test_health_check(client):
    """Test the health check endpoint."""
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_version(client):
    """Test the version endpoint."""
    response = client.get("/api/version")
    assert response.status_code == 200
    assert "version" in response.json
    assert "name" in response.json
    assert response.json["name"] == "$project_name"
EOF
  
  # Create Makefile
  cat > Makefile << EOF
.PHONY: install dev-install lint test clean build-docs serve-docs help

# Auto-detect package manager (prefer uv, fallback to pip)
PACKAGE_MANAGER := \$(shell command -v uv 2>/dev/null && echo "uv" || echo "pip")

help:
	@echo "Available commands:"
	@echo "  make install      - Install dependencies"
	@echo "  make dev-install  - Install development dependencies"
	@echo "  make lint         - Run linters (flake8, mypy)"
	@echo "  make test         - Run tests with pytest"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make build-docs   - Build documentation"
	@echo "  make serve-docs   - Serve documentation locally"

install:
	\$(PACKAGE_MANAGER) install -e .

dev-install:
	\$(PACKAGE_MANAGER) install -e ".[dev,test]"

lint:
	flake8 .
	mypy .

test:
	pytest --cov=./ --cov-report=term

clean:
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info
	rm -rf .pytest_cache
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

build-docs:
	cd docs && make html

serve-docs:
	cd docs/_build/html && python -m http.server 8000
EOF

  # Initialize git with all the files we've created
  git add .
  git commit -m "feat: Initial Flask API backend setup"
  
  echo "✅ Python Flask backend created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. Copy .env.example to .env and configure"
  echo "  3. Initialize a virtual environment: make install"
  echo "  4. Run the development server: make run"
  echo "  5. Visit http://localhost:5000/api/health to verify it's working"
  echo ""
}
