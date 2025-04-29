#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_react_frontend() {
  local project_name="$1"
  
  # Check for required arguments
  if [ -z "$project_name" ]; then
    echo "Error: Project name is required"
    echo "Usage: setup_react_frontend <project_name>"
    return 1
  fi

  # Check for dependencies
  if ! check_dependencies "node git"; then
    return 1
  fi

  # Detect package manager (prefer pnpm)
  if command -v pnpm &> /dev/null; then
    echo "Using pnpm package manager for faster dependency management"
    NODE_PACKAGE_MANAGER="pnpm"
  else
    echo "Using npm as package manager (consider installing pnpm for faster dependency management)"
    NODE_PACKAGE_MANAGER="npm"
  fi

  # Create project directory and navigate to it
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize Git repository
  git init

  # Check if GitHub repository exists
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  if command -v gh &> /dev/null; then
    echo "Checking if GitHub repository exists: $github_username/$project_name"
    if gh repo view "$github_username/$project_name" &> /dev/null; then
      echo "GitHub repository exists. Cloning and setting up..."
      rm -rf .git
      gh repo clone "$github_username/$project_name" .
      git checkout -b main || git checkout main
    else
      echo "Creating new GitHub repository: $github_username/$project_name"
      gh repo create "$github_username/$project_name" --public --source=. --remote=origin
    fi
  else
    echo "GitHub CLI (gh) not found. Skipping GitHub repository setup."
    echo "Install GitHub CLI from https://cli.github.com/ for GitHub integration."
  fi

  # Create GitHub Actions workflow directory
  mkdir -p .github/workflows

  # Copy workflow template or create default workflow
  if [ -f "$CRAFTINGBENCH_PATH/src/templates/github-workflows/react-workflow.yml" ]; then
    cp "$CRAFTINGBENCH_PATH/src/templates/github-workflows/react-workflow.yml" .github/workflows/react-ci.yml
    # Replace placeholder with actual project name in workflow
    sed -i.bak "s/React CI/$project_name CI/g" .github/workflows/react-ci.yml
    rm -f .github/workflows/react-ci.yml.bak
  else
    # Create a default workflow file
    cat > .github/workflows/react-ci.yml << EOF
name: $project_name CI

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
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'pnpm'
    
    - name: Install pnpm
      uses: pnpm/action-setup@v2
      with:
        version: latest
        run_install: false
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Lint
      run: pnpm lint
    
    - name: Type Check
      run: pnpm type-check
    
    - name: Test
      run: pnpm test
    
    - name: Build
      run: pnpm build
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: build
        path: dist/
EOF
  fi

  # Create project using Vite with React, TypeScript, and Material UI
  echo "Creating React project with Vite template..."
  if [ "$NODE_PACKAGE_MANAGER" = "pnpm" ]; then
    pnpm create vite . --template react-ts
    pnpm add @mui/material @mui/icons-material @emotion/react @emotion/styled
    pnpm add -D vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
  else
    npm create vite . -- --template react-ts
    npm install @mui/material @mui/icons-material @emotion/react @emotion/styled
    npm install -D vitest jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
  fi

  # Update package.json to include test scripts
  cat > package.json << EOF
{
  "name": "$project_name",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@emotion/react": "^11.11.1",
    "@emotion/styled": "^11.11.0",
    "@mui/icons-material": "^5.14.0",
    "@mui/material": "^5.14.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@testing-library/jest-dom": "^5.16.5",
    "@testing-library/react": "^14.0.0",
    "@testing-library/user-event": "^14.4.3",
    "@types/react": "^18.2.14",
    "@types/react-dom": "^18.2.6",
    "@typescript-eslint/eslint-plugin": "^5.61.0",
    "@typescript-eslint/parser": "^5.61.0",
    "@vitejs/plugin-react": "^4.0.1",
    "eslint": "^8.44.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.1",
    "jsdom": "^22.1.0",
    "typescript": "^5.0.2",
    "vite": "^4.4.0",
    "vitest": "^0.33.0"
  }
}
EOF

  # Create vitest.config.ts file
  cat > vitest.config.ts << EOF
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/setupTests.ts'],
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/'],
    },
  },
})
EOF

  # Create setupTests.ts
  cat > src/setupTests.ts << EOF
import '@testing-library/jest-dom'
EOF

  # Create .gitignore file
  cat > .gitignore << EOF
# Dependencies
node_modules
.pnp
.pnp.js

# Testing
coverage
.nyc_output

# Production
dist
build

# Misc
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*

# Editor directories and files
.vscode/*
!.vscode/extensions.json
.idea
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?
EOF

  # Create README.md with CI badge
  cat > README.md << EOF
# $project_name

[![CI Status](https://github.com/$github_username/$project_name/workflows/$project_name%20CI/badge.svg)](https://github.com/$github_username/$project_name/actions)

React frontend application built with Vite, TypeScript, and Material UI.

## Features

- ⚡️ Fast development with Vite
- 🔍 Strong typing with TypeScript
- 🎨 Material UI components
- 📊 Vitest for testing
- 🚦 GitHub Actions CI pipeline

## Development

### Setup

\`\`\`bash
# Install dependencies
pnpm install

# Start development server
pnpm dev
\`\`\`

### Testing

\`\`\`bash
# Run tests
pnpm test

# Run tests with coverage
pnpm test:coverage
\`\`\`

### Building

\`\`\`bash
# Type check
pnpm type-check

# Build for production
pnpm build

# Preview production build
pnpm preview
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── src/               # Source files
│   ├── assets/        # Static assets
│   ├── components/    # Reusable components
│   ├── hooks/         # Custom React hooks
│   ├── pages/         # Page components
│   ├── services/      # API services
│   ├── styles/        # Global styles
│   ├── types/         # TypeScript types
│   ├── App.tsx        # Main app component
│   ├── main.tsx       # Entry point
│   └── vite-env.d.ts  # Vite type declarations
├── public/            # Public assets
├── .github/           # GitHub Actions workflows
├── index.html         # HTML template
├── tsconfig.json      # TypeScript configuration
├── vite.config.ts     # Vite configuration
└── README.md          # This file
\`\`\`
EOF

  # Create folder structure
  mkdir -p src/components
  mkdir -p src/pages
  mkdir -p src/hooks
  mkdir -p src/services
  mkdir -p src/styles
  mkdir -p src/types
  mkdir -p public

  # Create a sample Button component
  cat > src/components/Button/Button.tsx << EOF
import { Button as MuiButton, ButtonProps } from '@mui/material';

interface CustomButtonProps extends ButtonProps {
  variant?: 'contained' | 'outlined' | 'text';
  color?: 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning';
}

const Button: React.FC<CustomButtonProps> = ({ 
  children, 
  variant = 'contained', 
  color = 'primary',
  ...props 
}) => {
  return (
    <MuiButton 
      variant={variant} 
      color={color} 
      data-testid="custom-button"
      {...props}
    >
      {children}
    </MuiButton>
  );
};

export default Button;
EOF

  # Create test for Button component
  mkdir -p src/components/Button
  cat > src/components/Button/Button.test.tsx << EOF
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import Button from './Button';

describe('Button component', () => {
  it('renders correctly with default props', () => {
    render(<Button>Click me</Button>);
    
    const button = screen.getByTestId('custom-button');
    expect(button).toBeInTheDocument();
    expect(button).toHaveTextContent('Click me');
  });

  it('handles click events', async () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    const button = screen.getByTestId('custom-button');
    await userEvent.click(button);
    
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies variant and color correctly', () => {
    render(<Button variant="outlined" color="secondary">Styled Button</Button>);
    
    const button = screen.getByTestId('custom-button');
    expect(button).toHaveClass('MuiButton-outlined');
    expect(button).toHaveClass('MuiButton-outlinedSecondary');
  });
});
EOF

  # Create index.ts for Button component
  cat > src/components/Button/index.ts << EOF
export { default } from './Button';
EOF

  # Create an improved App.tsx with Material UI
  cat > src/App.tsx << EOF
import { useState } from 'react';
import { 
  CssBaseline, 
  ThemeProvider, 
  createTheme, 
  Container, 
  Typography, 
  Box, 
  useMediaQuery 
} from '@mui/material';
import Button from './components/Button';

function App() {
  const prefersDarkMode = useMediaQuery('(prefers-color-scheme: dark)');
  const [darkMode, setDarkMode] = useState(prefersDarkMode);

  const theme = createTheme({
    palette: {
      mode: darkMode ? 'dark' : 'light',
      primary: {
        main: '#1976d2',
      },
      secondary: {
        main: '#dc004e',
      },
    },
  });

  const toggleTheme = () => {
    setDarkMode(!darkMode);
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="md">
        <Box 
          sx={{ 
            my: 4, 
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center' 
          }}
        >
          <Typography variant="h3" component="h1" gutterBottom>
            Welcome to $project_name
          </Typography>
          
          <Typography variant="h5" component="h2" gutterBottom>
            A React application with Material UI
          </Typography>
          
          <Box sx={{ mt: 4 }}>
            <Button 
              onClick={toggleTheme} 
              variant="contained" 
              color="primary"
              sx={{ mr: 2 }}
            >
              {darkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
            </Button>
            
            <Button 
              variant="outlined" 
              color="secondary" 
              href="https://mui.com/material-ui/getting-started/overview/"
              target="_blank"
              rel="noopener"
            >
              Material UI Docs
            </Button>
          </Box>
        </Box>
      </Container>
    </ThemeProvider>
  );
}

export default App;
EOF

  # Install dependencies
  if [ "$NODE_PACKAGE_MANAGER" = "pnpm" ]; then
    pnpm install
  else
    npm install
  fi

  # Commit changes
  git add .
  git commit -m "Initial project setup for $project_name"

  # Display success message
  echo ""
  echo "🚀 React frontend with Material UI '$project_name' has been set up successfully!"
  echo "To start development, navigate to the project directory and run the development server:"
  echo ""
  echo "  cd $project_name"
  if [ "$NODE_PACKAGE_MANAGER" = "pnpm" ]; then
    echo "  pnpm dev"
  else
    echo "  npm run dev"
  fi
  echo ""
} 