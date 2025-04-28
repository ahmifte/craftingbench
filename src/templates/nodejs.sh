#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_nodejs_backend() {
  local project_name=$1
  
  # Check dependencies
  if ! check_dependencies "nodejs"; then
    return 1
  fi
  
  if [ -z "$project_name" ]; then
    echo "❌ Error: Project name is required"
    echo "Usage: setup_nodejs_backend <project_name>"
    return 1
  fi
  
  echo "🚀 Creating Node.js backend project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository if git exists
  if command_exists git; then
    git init .
  fi
  
  # Initialize npm project
  npm init -y
  
  # Update package.json with better defaults
  sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "node src\/index.js",\n    "dev": "nodemon src\/index.js",\n    "test": "jest",\n    "lint": "eslint .",/g' package.json
  rm package.json.bak
  
  # Install common dependencies
  npm install express dotenv cors helmet mongoose
  
  # Install development dependencies
  npm install --save-dev nodemon jest eslint eslint-config-airbnb-base eslint-plugin-import
  
  # Create project structure
  mkdir -p src/{config,controllers,models,routes,middleware,utils,tests}
  
  # Create .env file
  cat > .env << EOF
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/$project_name
# Add other environment variables here
EOF

  # Create .gitignore
  cat > .gitignore << EOF
# Dependencies
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Build output
/dist
/build

# Logs
logs
*.log

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory
coverage

# IDEs and editors
/.idea
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json

# Misc
.DS_Store
.AppleDouble
.LSOverride
EOF

  # Create main application file
  cat > src/index.js << EOF
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

// Import routes
const apiRoutes = require('./routes');

// Initialize express app
const app = express();

// Set port
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'UP' });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// Start the server
app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});

module.exports = app; // For testing
EOF

  # Create routes index file
  cat > src/routes/index.js << EOF
const express = require('express');
const router = express.Router();

// Import other route modules
// const userRoutes = require('./user.routes');

// Define routes
// router.use('/users', userRoutes);

// Default route
router.get('/', (req, res) => {
  res.json({ message: 'Welcome to $project_name API!' });
});

module.exports = router;
EOF

  # Create sample controller
  cat > src/controllers/sample.controller.js << EOF
/**
 * Sample controller with common CRUD operations
 */

// Get all items
exports.getAll = async (req, res) => {
  try {
    // Replace with your actual data fetching logic
    const items = [{ id: 1, name: 'Sample Item' }];
    return res.status(200).json(items);
  } catch (error) {
    console.error('Error in getAll:', error);
    return res.status(500).json({ message: 'Failed to retrieve items' });
  }
};

// Get single item by ID
exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    // Replace with your actual data fetching logic
    const item = { id: parseInt(id), name: 'Sample Item' };
    return res.status(200).json(item);
  } catch (error) {
    console.error('Error in getById:', error);
    return res.status(500).json({ message: 'Failed to retrieve item' });
  }
};

// Create new item
exports.create = async (req, res) => {
  try {
    const newItem = req.body;
    // Replace with your actual data creation logic
    return res.status(201).json({ id: Date.now(), ...newItem });
  } catch (error) {
    console.error('Error in create:', error);
    return res.status(500).json({ message: 'Failed to create item' });
  }
};

// Update item
exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    const updates = req.body;
    // Replace with your actual update logic
    return res.status(200).json({ id: parseInt(id), ...updates });
  } catch (error) {
    console.error('Error in update:', error);
    return res.status(500).json({ message: 'Failed to update item' });
  }
};

// Delete item
exports.delete = async (req, res) => {
  try {
    const { id } = req.params;
    // Replace with your actual delete logic
    return res.status(200).json({ message: 'Item deleted successfully' });
  } catch (error) {
    console.error('Error in delete:', error);
    return res.status(500).json({ message: 'Failed to delete item' });
  }
};
EOF

  # Create a readme file
  cat > README.md << EOF
# $project_name

A Node.js backend application built with Express.

## Features

- RESTful API architecture
- Express.js web framework
- MongoDB integration with Mongoose
- Environment configuration with dotenv
- Security middleware with Helmet
- CORS support
- Structured project layout
- Error handling middleware

## Installation

\`\`\`bash
# Clone the repository
git clone <repository-url>
cd $project_name

# Install dependencies
npm install

# Create .env file (example provided in .env.example)
cp .env.example .env

# Start the development server
npm run dev
\`\`\`

## Project Structure

\`\`\`
src/
├── config/        # Configuration files
├── controllers/   # Route controllers
├── middleware/    # Custom middleware
├── models/        # Database models
├── routes/        # API routes
├── utils/         # Utility functions
├── tests/         # Test files
└── index.js       # Application entry point
\`\`\`

## Available Scripts

- \`npm start\`: Start the production server
- \`npm run dev\`: Start the development server with hot reloading
- \`npm test\`: Run tests
- \`npm run lint\`: Run linting

## API Endpoints

- \`GET /health\`: Health check endpoint
- \`GET /api\`: Welcome message

## License

[MIT](LICENSE)
EOF

  # Create a .eslintrc.js file
  cat > .eslintrc.js << EOF
module.exports = {
  env: {
    node: true,
    commonjs: true,
    es2021: true,
    jest: true,
  },
  extends: 'airbnb-base',
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'warn',
  },
};
EOF

  # If GitHub CLI exists, create a repo
  if command_exists gh; then
    echo "🔍 Checking if GitHub repository already exists..."
    if ! gh repo view "$project_name" &>/dev/null; then
      echo "🔨 Creating GitHub repository: $project_name"
      gh repo create "$project_name" --private --source=. --remote=origin
      git add .
      git commit -m "Initial commit: Node.js backend project structure"
      git push -u origin main || git push -u origin master
      echo "✅ Created and pushed to GitHub repository: $project_name"
    else
      echo "⚠️ GitHub repository already exists: $project_name"
    fi
  fi

  echo "✅ Node.js backend project '$project_name' created successfully!"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. npm install"
  echo "  3. npm run dev"
  echo ""
  echo "Happy coding! ��"
  
  return 0
} 