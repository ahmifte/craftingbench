# Templates

This directory contains documentation for the templates available in CraftingBench.

## Structure

All templates in CraftingBench follow a standardized structure:

```
src/templates/
├── template_name.sh            # Main template script
├── common.sh                   # Common utilities shared across templates
└── assets/                     # Template-specific assets
    └── template_name/          # Assets organized by template
```

## Available Templates

| Template | Description | Key Features |
|----------|-------------|--------------|
| **nodejs** | TypeScript Node.js backend | Express, MongoDB, structured architecture |
| **react** | TypeScript React frontend | Material UI, responsive layouts |
| **go** | Go backend service | Clean architecture, testing setup |
| **python** | Python application | Package structure, virtual environments |
| **fullstack** | Full-stack applications | Multiple backend options with TypeScript frontend |

## Fullstack

The fullstack template supports three backend options:

1. **Next.js** - Full TypeScript stack with API routes
2. **Flask** - Python backend with TypeScript React frontend
3. **Go** - Go backend with TypeScript React frontend

All fullstack templates include:

- Material UI integration with theme customization
- API client for backend communication
- Responsive layouts and components
- Development and production configurations

## Creating a New Template

To create a new template:

1. Create a new script in `src/templates/` named `your_template.sh`
2. Implement the required functions:
   - `setup_your_template_project()`
   - `create_your_template_files()`
   - Any helper functions needed

3. Add template-specific assets to `src/templates/assets/your_template/`
4. Update `src/helpers/common.sh` to include your template
5. Add documentation for your template

### Template Script Structure

```bash
#!/bin/bash

# Source common utilities
source "$(dirname "$0")/../helpers/common.sh"

# Main setup function
setup_your_template_project() {
    local project_name=$1
    local project_dir=$2
    
    # Template implementation
}

# Create project files
create_your_template_files() {
    local project_dir=$1
    
    # Create files and directories
}

# Initialize your template
setup_your_template_project "$@"
```

## Material UI Integration

All frontend templates now use Material UI instead of Tailwind CSS. To ensure consistent Material UI implementation:

1. Include the core Material UI packages:
   ```bash
   pnpm add @mui/material @mui/icons-material @emotion/react @emotion/styled
   ```

2. Set up a theme with light/dark mode support:
   ```typescript
   // theme.ts
   import { createTheme, responsiveFontSizes } from '@mui/material/styles';
   
   export const theme = responsiveFontSizes(createTheme({
     palette: {
       primary: {
         main: '#1976d2',
       },
       secondary: {
         main: '#dc004e',
       },
     },
   }));
   ```

3. Create reusable layout components that use Material UI

## TypeScript Configuration

Ensure all JavaScript templates use TypeScript by default:

1. Include TypeScript and necessary dependencies:
   ```bash
   pnpm add -D typescript @types/node @types/react @types/express
   ```

2. Create proper `tsconfig.json` with recommended settings
3. Set up proper type definitions for all components and functions

## Testing Your Template

To test your template:

```bash
# Development testing
./craftingbench.sh create test-project your_template

# Verify all files are created correctly
ls -la test-project/

# Test the project functionality
cd test-project && pnpm dev  # Or appropriate command
```
