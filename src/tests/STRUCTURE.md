### Shell Tests (BATS)

Shell tests use the Bash Automated Testing System (BATS) to validate that the shell scripts work as expected. These tests check:

- Template scripts can be successfully sourced
- Template functions execute without errors
- Expected directories and files are created

### Documentation Validation Tests (Jest/TypeScript)

Documentation validation tests use Jest and TypeScript to verify that:

- Generated projects match the structure described in documentation
- README.md accurately describes the available templates and options
- Version information is consistent across documentation and code
- Package dependencies match what's described in the documentation 