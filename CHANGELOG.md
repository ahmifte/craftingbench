# Changelog

All notable changes to CraftingBench will be documented in this file.

## [Unreleased]

### Added

- New `utils.sh` file with common utility functions extracted from templates
- New `pre-commit.sh` template for generating pre-commit configurations
- Pre-commit GitHub workflow template for running hooks in CI
- Added section to README and USER_GUIDE about utility functions
- Improved package manager detection with support for yarn
- Common functions for repository and GitHub workflow setup
- Better .gitignore generation with language-specific templates

### Changed

- Refactored duplicated code from templates into dedicated utility functions
- Updated `template-utils.sh` to use new utility functions while maintaining backward compatibility
- Enhanced pre-commit configuration with better language detection
- Improved documentation for standalone utility usage

## [0.2.0] - 2023-07-01

### Added

- Full-stack application templates with Next.js, Flask, and Go backends
- Next.js project template with TypeScript and API routes
- Material UI integration for all frontend templates
- Improved error handling in all templates
- Support for environment variables and configuration
- Structured database connections
- Basic authentication setup in backend templates

### Changed

- Better TypeScript configuration
- Updated ESLint rules
- Improved project structure for better organization
- Enhanced GitHub workflow templates
- More comprehensive README files for each project type

### Fixed

- Package manager detection on different platforms
- GitHub repository creation when user is not authenticated
- Path handling in template scripts

## [0.1.0] - 2025-01-01

### Added

- Initial release with basic project templates
- Support for Python, Node.js, Go, React, and fullstack projects
- Shell completions for Zsh
- Documentation and examples
