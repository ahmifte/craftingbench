#!/usr/bin/env bats

setup() {
  # Load CraftingBench
  source "$(pwd)/craftingbench.sh"
  
  # Create a temp directory for tests
  export TEST_TEMP_DIR="$(mktemp -d)"
  
  # Original directory
  export ORIGINAL_DIR="$(pwd)"
}

teardown() {
  # Remove the temp directory
  rm -rf "$TEST_TEMP_DIR"
  # Return to original directory
  cd "$ORIGINAL_DIR"
}

# Test that the main script can be sourced
@test "craftingbench.sh can be sourced" {
  run bash -c "source \"$ORIGINAL_DIR/craftingbench.sh\" && echo 'SUCCESS'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SUCCESS"* ]]
}

# Test Python project template
@test "setup_python_project creates valid Python project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_python_project "test-python-project"
  [ "$status" -eq 0 ]
  
  # Check for key files
  [ -d "test-python-project" ]
  [ -f "test-python-project/pyproject.toml" ]
  [ -f "test-python-project/README.md" ]
  [ -d "test-python-project/tests" ]
  [ -d "test-python-project/test_python_project" ] # Module dir
}

# Test Node.js backend template
@test "setup_nodejs_backend creates valid Node.js project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_nodejs_backend "test-nodejs-project"
  [ "$status" -eq 0 ]
  
  # Check for key files
  [ -d "test-nodejs-project" ]
  [ -f "test-nodejs-project/package.json" ]
  [ -f "test-nodejs-project/README.md" ]
  [ -f "test-nodejs-project/tsconfig.json" ]
  [ -d "test-nodejs-project/src" ]
  [ -d "test-nodejs-project/tests" ]
}

# Test Go project template
@test "setup_go_project creates valid Go project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_go_project "test-go-project"
  [ "$status" -eq 0 ]
  
  # Check for key files
  [ -d "test-go-project" ]
  [ -f "test-go-project/go.mod" ]
  [ -f "test-go-project/README.md" ]
  [ -d "test-go-project/cmd" ]
  [ -d "test-go-project/internal" ]
  [ -d "test-go-project/pkg" ]
}

# Test React frontend template
@test "setup_react_frontend creates valid React project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_react_frontend "test-react-project"
  [ "$status" -eq 0 ]
  
  # Check for key files
  [ -d "test-react-project" ]
  [ -f "test-react-project/package.json" ]
  [ -f "test-react-project/README.md" ]
  [ -f "test-react-project/tsconfig.json" ]
  [ -d "test-react-project/src" ]
  [ -d "test-react-project/public" ]
}

# Test fullstack project (Next.js)
@test "setup_fullstack_project with Next.js creates valid project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_fullstack_project "test-fullstack-nextjs" --backend=nextjs
  [ "$status" -eq 0 ]
  
  # Check for key files
  [ -d "test-fullstack-nextjs" ]
  [ -f "test-fullstack-nextjs/package.json" ]
  [ -f "test-fullstack-nextjs/README.md" ]
  [ -f "test-fullstack-nextjs/tsconfig.json" ]
  [ -d "test-fullstack-nextjs/src" ]
  [ -d "test-fullstack-nextjs/public" ]
}

# Test fullstack project (Flask backend)
@test "setup_fullstack_project with Flask creates valid project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_fullstack_project "test-fullstack-flask" --backend=flask
  [ "$status" -eq 0 ]
  
  # Check for key files in frontend
  [ -d "test-fullstack-flask/frontend" ]
  [ -f "test-fullstack-flask/frontend/package.json" ]
  [ -f "test-fullstack-flask/frontend/tsconfig.json" ]
  
  # Check for key files in backend
  [ -d "test-fullstack-flask/backend" ]
  [ -f "test-fullstack-flask/backend/pyproject.toml" ]
  [ -f "test-fullstack-flask/backend/requirements.txt" ]
  
  # Check root files
  [ -f "test-fullstack-flask/README.md" ]
}

# Test fullstack project (Go backend)
@test "setup_fullstack_project with Go creates valid project structure" {
  cd "$TEST_TEMP_DIR"
  run setup_fullstack_project "test-fullstack-go" --backend=golang
  [ "$status" -eq 0 ]
  
  # Check for key files in frontend
  [ -d "test-fullstack-go/frontend" ]
  [ -f "test-fullstack-go/frontend/package.json" ]
  [ -f "test-fullstack-go/frontend/tsconfig.json" ]
  
  # Check for key files in backend
  [ -d "test-fullstack-go/backend" ]
  [ -f "test-fullstack-go/backend/go.mod" ]
  
  # Check root files
  [ -f "test-fullstack-go/README.md" ]
} 