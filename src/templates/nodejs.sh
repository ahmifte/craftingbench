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
  
  echo "🚀 Creating TypeScript Node.js backend project: $project_name"
  
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
  sed -i.bak 's/"scripts": {/"scripts": {\n    "start": "node dist\/index.js",\n    "dev": "ts-node-dev --respawn src\/index.ts",\n    "build": "tsc",\n    "test": "jest",\n    "lint": "eslint src --ext .ts",\n    "typecheck": "tsc --noEmit",/g' package.json
  rm package.json.bak
  
  # Install common dependencies
  npm install express dotenv cors helmet mongoose

  # Install TypeScript and type definitions
  npm install --save-dev typescript ts-node ts-node-dev @types/node @types/express @types/cors @types/helmet @types/mongoose
  
  # Install development dependencies
  npm install --save-dev nodemon jest ts-jest @types/jest eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser
  
  # Create TypeScript configuration
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "declaration": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOF
  
  # Create project structure
  mkdir -p src/{config,controllers,models,routes,middleware,utils,tests,types}
  
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

  # Create main application file with TypeScript
  cat > src/index.ts << EOF
import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { Server } from 'http';

// Import routes
import apiRoutes from './routes';

// Initialize environment variables
dotenv.config();

// Initialize express app
const app = express();

// Set port
const PORT: number = parseInt(process.env.PORT || '3000', 10);

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({ status: 'UP' });
});

// Error interface
interface AppError extends Error {
  status?: number;
}

// Error handling middleware
app.use((err: AppError, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ message: err.message || 'Something went wrong!' });
});

// Start the server
const server: Server = app.listen(PORT, () => {
  console.log(\`Server running on port \${PORT}\`);
});

export default app; // For testing
EOF

  # Create routes index file with TypeScript
  cat > src/routes/index.ts << EOF
import express, { Request, Response } from 'express';
const router = express.Router();

// Import other route modules
// import userRoutes from './user.routes';

// Define routes
// router.use('/users', userRoutes);

// Default route
router.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Welcome to $project_name API!' });
});

export default router;
EOF

  # Create sample controller with TypeScript
  cat > src/controllers/sample.controller.ts << EOF
import { Request, Response } from 'express';

// Sample item interface
interface Item {
  id: number;
  name: string;
}

/**
 * Sample controller with common CRUD operations
 */

// Get all items
export const getAll = async (req: Request, res: Response): Promise<Response> => {
  try {
    // Replace with your actual data fetching logic
    const items: Item[] = [{ id: 1, name: 'Sample Item' }];
    return res.status(200).json(items);
  } catch (error) {
    console.error('Error in getAll:', error);
    return res.status(500).json({ message: 'Failed to retrieve items' });
  }
};

// Get single item by ID
export const getById = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { id } = req.params;
    // Replace with your actual data fetching logic
    const item: Item = { id: parseInt(id), name: 'Sample Item' };
    return res.status(200).json(item);
  } catch (error) {
    console.error('Error in getById:', error);
    return res.status(500).json({ message: 'Failed to retrieve item' });
  }
};
EOF

  # Create a sample model with TypeScript
  cat > src/models/sample.model.ts << EOF
import mongoose, { Schema, Document } from 'mongoose';

// Define the interface for the document
export interface ISample extends Document {
  name: string;
  description?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

// Create the schema
const SampleSchema: Schema = new Schema({
  name: { type: String, required: true },
  description: { type: String },
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

// Create and export the model
export default mongoose.model<ISample>('Sample', SampleSchema);
EOF

  # Create a type definition file
  cat > src/types/index.ts << EOF
export interface APIResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface PaginatedResponse<T = any> extends APIResponse<T[]> {
  total: number;
  page: number;
  limit: number;
  pages: number;
}

export interface UserContext {
  id: string;
  email: string;
  roles: string[];
}
EOF

  # Create environment variables type file
  cat > src/types/environment.d.ts << EOF
declare global {
  namespace NodeJS {
    interface ProcessEnv {
      NODE_ENV: 'development' | 'production' | 'test';
      PORT: string;
      MONGODB_URI: string;
      // Add more environment variables as needed
    }
  }
}

// This file needs to be a module
export {};
EOF

  # Create jest config
  cat > jest.config.js << EOF
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  testRegex: '(/__tests__/.*|(\\.|/)(test|spec))\\.tsx?$',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  coverageDirectory: 'coverage',
};
EOF

  # Create a sample test
  mkdir -p src/tests
  cat > src/tests/sample.test.ts << EOF
describe('Sample Test', () => {
  it('should pass', () => {
    expect(2 + 2).toBe(4);
  });
});
EOF

  echo "✅ TypeScript Node.js backend created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. npm install"
  echo "  3. npm run dev"
  echo ""
} 