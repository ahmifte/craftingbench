#!/usr/bin/env bats

# Test for Python Docker template functionality

setup() {
  # Load the test helper
  load test_helper
  
  # Create a temporary directory for testing
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
  
  # Source craftingbench
  source "$CRAFTINGBENCH_DIR/craftingbench.sh"
}

teardown() {
  # Clean up the temporary directory
  cd /
  rm -rf "$TEST_DIR"
}

@test "python-docker template is loaded" {
  # Check that the main function exists
  run type setup_python_docker_project
  [ "$status" -eq 0 ]
}

@test "python-docker help function exists" {
  run type show_python_docker_help
  [ "$status" -eq 0 ]
}

@test "setup_python_docker_api function exists" {
  run type setup_python_docker_api
  [ "$status" -eq 0 ]
}

@test "setup_python_docker_cli function exists" {
  run type setup_python_docker_cli
  [ "$status" -eq 0 ]
}

@test "python-docker project requires project name" {
  run setup_python_docker_project
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Please provide a project name" ]]
}

@test "python-docker project requires type parameter" {
  run setup_python_docker_project test-project
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Project type must be specified" ]]
}

@test "python-docker project shows help" {
  run setup_python_docker_project --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Python Docker Project Setup Commands" ]]
}

@test "python-docker api shortcut requires project name" {
  run setup_python_docker_api
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Please provide a project name" ]]
}

@test "python-docker cli shortcut requires project name" {
  run setup_python_docker_cli
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Please provide a project name" ]]
}

@test "python-docker project validates type parameter" {
  run setup_python_docker_project test-project --type=invalid
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unsupported project type: invalid" ]]
}

@test "python-docker project accepts api type" {
  skip "Requires Python and Docker to be installed"
  run setup_python_docker_project test-api-project --type=api
  [ "$status" -eq 0 ]
}

@test "python-docker project accepts cli type" {
  skip "Requires Python and Docker to be installed"
  run setup_python_docker_project test-cli-project --type=cli
  [ "$status" -eq 0 ]
}

@test "python-docker project accepts ai-ready flag" {
  skip "Requires Python and Docker to be installed"
  run setup_python_docker_project test-ai-project --type=api --ai-ready
  [ "$status" -eq 0 ]
} 