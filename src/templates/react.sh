#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_react_frontend() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_react_frontend <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "node"; then
    return 1
  fi
  
  # Detect and use pnpm if available, otherwise npm
  local npm_cmd="npm"
  if command_exists pnpm; then
    npm_cmd="pnpm"
    echo "Using pnpm for package management"
  fi
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows
  
  # Copy GitHub Actions workflow file
  workflow_template="${CRAFTINGBENCH_DIR}/src/templates/github-workflows/react-workflow.yml"
  if [ -f "$workflow_template" ]; then
    cp "$workflow_template" .github/workflows/react-ci.yml
  else
    # Create GitHub Actions workflow file if template is not available
    cat > .github/workflows/react-ci.yml << EOF
name: React CI

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
    
    - name: Install pnpm
      uses: pnpm/action-setup@v4
      with:
        version: 8
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type check
      run: pnpm typecheck
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
      
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build
        path: dist/
        if-no-files-found: error
EOF
  fi

  # Create project using Vite + React + TypeScript + Material UI
  if [ "$npm_cmd" = "pnpm" ]; then
    pnpm create vite@latest . --template react-ts
    
    # Set up pnpm config
    cat > .npmrc << EOF
engine-strict=true
resolution-mode=highest
save-exact=true
auto-install-peers=true
EOF
  else
    # Fallback to npm if pnpm not available
    npm create vite@latest . -- --template react-ts
  fi
  
  # Install Material UI packages
  $npm_cmd add @mui/material @mui/icons-material @emotion/react @emotion/styled
  
  # Install development dependencies
  $npm_cmd add -D @testing-library/react @testing-library/jest-dom @testing-library/user-event vitest jsdom
  
  # Update package.json to include test scripts
  # Use temporary file to avoid issues with sed on different platforms
  cat > package.json.new << EOF
$(cat package.json | sed 's/"scripts": {/"scripts": {\n    "test": "vitest run",\n    "test:watch": "vitest",\n    "test:coverage": "vitest run --coverage",\n    "typecheck": "tsc --noEmit",\n    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",/')
EOF
  mv package.json.new package.json
  
  # Create vitest config file
  cat > vitest.config.ts << EOF
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/setupTests.ts'],
  },
})
EOF
  
  # Create test setup file
  cat > src/setupTests.ts << EOF
import '@testing-library/jest-dom'
EOF
  
  # Create GitHub repository if gh CLI is available
  if command_exists gh; then
    echo "Creating GitHub repository for $project_name..."
    gh repo create "$project_name" --private --confirm
    
    # Add CI badge to README
    cat > README.md << EOF
# $project_name

[![React CI](https://github.com/$github_username/$project_name/actions/workflows/react-ci.yml/badge.svg)](https://github.com/$github_username/$project_name/actions/workflows/react-ci.yml)

A React frontend application with TypeScript and Material UI.

## Features

- React with TypeScript
- Material UI components
- Vite for fast development and building
- Testing with Vitest and Testing Library
- GitHub Actions for CI/CD

## Development

### Installation

\`\`\`bash
# Clone the repository
git clone https://github.com/$github_username/$project_name.git
cd $project_name

# Install dependencies
$npm_cmd install
\`\`\`

### Available Scripts

\`\`\`bash
# Start development server
$npm_cmd run dev

# Build for production
$npm_cmd run build

# Run tests
$npm_cmd test

# Run tests with coverage
$npm_cmd run test:coverage

# Run linter
$npm_cmd run lint

# Type check
$npm_cmd run typecheck
\`\`\`

## Project Structure

\`\`\`
src/
├── assets/       # Static assets
├── components/   # Reusable UI components
├── hooks/        # Custom React hooks
├── pages/        # Page components
├── services/     # API services
├── styles/       # Global styles
├── types/        # TypeScript type definitions
└── App.tsx       # Main App component
\`\`\`
EOF
  else
    # Create a basic README if gh CLI is not available
    cat > README.md << EOF
# $project_name

A React frontend application with TypeScript and Material UI.

## Development

\`\`\`bash
# Install dependencies
$npm_cmd install

# Start development server
$npm_cmd run dev

# Build for production
$npm_cmd run build

# Run tests
$npm_cmd test
\`\`\`
EOF
  fi
  
  # Create project structure
  mkdir -p src/{components,pages,hooks,services,styles,types}
  
  # Create a sample Material UI component
  cat > src/components/Button.tsx << EOF
import { Button as MuiButton, ButtonProps } from '@mui/material';

interface CustomButtonProps extends ButtonProps {
  variant?: 'contained' | 'outlined' | 'text';
}

export const Button = ({ 
  children, 
  variant = 'contained', 
  color = 'primary',
  ...props 
}: CustomButtonProps) => {
  return (
    <MuiButton
      variant={variant}
      color={color}
      {...props}
    >
      {children}
    </MuiButton>
  );
};
EOF
  
  # Create a test for the button component
  cat > src/components/Button.test.tsx << EOF
import { render, screen } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders button with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });
  
  it('applies variant prop', () => {
    render(<Button variant="outlined">Outlined</Button>);
    const button = screen.getByRole('button', { name: /outlined/i });
    expect(button).toHaveClass('MuiButton-outlined');
  });
});
EOF
  
  # Create example App.tsx with Material UI
  cat > src/App.tsx << EOF
import { useState } from 'react';
import { ThemeProvider, createTheme, CssBaseline, Container, Box, Typography } from '@mui/material';
import { Button } from './components/Button';

// Create a theme
const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  const [count, setCount] = useState(0);

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="md">
        <Box
          sx={{
            my: 4,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'center',
            alignItems: 'center',
            textAlign: 'center',
          }}
        >
          <Typography variant="h2" component="h1" gutterBottom>
            Welcome to $project_name
          </Typography>
          
          <Typography variant="h4" component="h2" gutterBottom>
            Count: {count}
          </Typography>
          
          <Box sx={{ '& > button': { m: 1 } }}>
            <Button onClick={() => setCount(count + 1)}>
              Increment
            </Button>
            
            <Button variant="outlined" onClick={() => setCount(0)}>
              Reset
            </Button>
          </Box>
        </Box>
      </Container>
    </ThemeProvider>
  );
}

export default App;
EOF
  
  # Commit changes
  git add .
  git commit -m "Initial setup: React with TypeScript and Material UI"
  
  echo "React frontend with Material UI has been set up successfully!"
  echo "To start development:"
  echo "  cd $project_name"
  echo "  $npm_cmd run dev"
} 