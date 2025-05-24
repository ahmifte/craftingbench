# CraftingBench Utility Scripts

This directory contains utility scripts that enhance the functionality of CraftingBench.

## Available Scripts

| Script | Description |
|--------|-------------|
| `setup_anthropic_with_uv.sh` | Sets up Anthropic's Claude API with the uv package manager |

## Usage

All scripts can be run directly from this directory:

```bash
# From the repository root:
./src/scripts/setup_anthropic_with_uv.sh

# From within the scripts directory:
./setup_anthropic_with_uv.sh
```

## Adding New Scripts

When adding new utility scripts to CraftingBench:

1. Place the script in this directory
2. Make it executable with `chmod +x script_name.sh`
3. Follow the naming convention: `setup_*` for setup scripts, `install_*` for installers, etc.
4. Add documentation in the script header and update this README
5. Update the main README.md if the script adds significant functionality

## Script Structure

For consistency, structure scripts following this template:

```bash
#!/usr/bin/env bash

# ================================================================
# Script Name: script_name.sh
# Description: Brief description of what the script does
# ================================================================

set -e  # Exit on error

# Script code here...
``` 