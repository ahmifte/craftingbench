#!/usr/bin/env bash

# Source common helper functions
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/common.sh" 2>/dev/null || source "${CRAFTINGBENCH_DIR}/src/helpers/common.sh"

setup_fullstack_project() {
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a project name"
    echo "Usage: setup_fullstack_project <project_name>"
    return 1
  fi

  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  local backend="nextjs" # Default backend
  
  # Parse options
  shift 1
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --backend=*) backend="${1#*=}" ;;
      *) echo "Unknown parameter: $1"; return 1 ;;
    esac
    shift
  done
  
  case $backend in
    nextjs)
      setup_nextjs_fullstack "$project_name"
      ;;
    flask)
      setup_flask_fullstack "$project_name"
      ;;
    golang)
      setup_golang_fullstack "$project_name"
      ;;
    *)
      echo "Unsupported backend: $backend"
      echo "Supported backends: nextjs, flask, golang"
      return 1
      ;;
  esac
}

setup_nextjs_fullstack() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "nextjs"; then
    return 1
  fi
  
  echo "🚀 Setting up Next.js fullstack project: $project_name"
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Initialize Next.js project with TypeScript (without Tailwind)
  npx create-next-app@latest . --typescript --eslint --app --src-dir --import-alias="@/*" --no-tailwind
  
  # Add additional dependencies
  npm install axios zustand @tanstack/react-query zod react-hook-form @hookform/resolvers
  
  # UI libraries - Material UI
  npm install @mui/material @mui/icons-material @emotion/react @emotion/styled

  # Create a better project structure
  mkdir -p src/app/api
  mkdir -p src/lib
  mkdir -p src/components/ui
  mkdir -p src/components/layout
  mkdir -p src/features
  mkdir -p src/hooks
  mkdir -p src/stores
  mkdir -p src/types

  # Create useful utility files
  cat > src/lib/api.ts << EOF
import axios from 'axios';

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

export default api;
EOF

  # Create zustand store
  cat > src/stores/store.ts << EOF
import { create } from 'zustand';

interface AppState {
  isLoading: boolean;
  setLoading: (isLoading: boolean) => void;
}

export const useAppStore = create<AppState>((set) => ({
  isLoading: false,
  setLoading: (isLoading: boolean) => set({ isLoading }),
}));
EOF

  # Enhance the README with better documentation
  cat > README.md << EOF
# $project_name

A fullstack Next.js application with TypeScript.

## Tech Stack

- **Framework**: Next.js 14
- **Language**: TypeScript
- **Styling**: CSS-in-JS with Emotion
- **UI Components**: Material UI
- **State Management**: Zustand
- **API Client**: Axios
- **Form Handling**: React Hook Form + Zod
- **Server State**: React Query

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Run the development server
npm run dev
\`\`\`

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Project Structure

\`\`\`
$project_name/
├── .next/
├── node_modules/
├── public/
├── src/
│   ├── app/             # Next.js App Router
│   │   ├── api/         # API Routes
│   │   └── ...          # Page Routes
│   ├── components/
│   │   ├── layout/      # Layout components
│   │   └── ui/          # Reusable UI components
│   ├── features/        # Feature-based modules
│   ├── hooks/           # Custom React hooks
│   ├── lib/             # Utility functions, libraries
│   ├── stores/          # Zustand state stores
│   └── types/           # TypeScript type definitions
├── .eslintrc.json
├── .gitignore
├── next.config.js
├── package.json
└── tsconfig.json
\`\`\`

## Scripts

- \`npm run dev\`: Start the development server
- \`npm run build\`: Build the application for production
- \`npm start\`: Start the production server
- \`npm run lint\`: Lint the codebase

## License

MIT
EOF

  # Create Material UI theme setup
  mkdir -p src/lib/theme
  
  cat > src/lib/theme/theme.ts << EOF
import { createTheme, responsiveFontSizes } from '@mui/material/styles';
import { red, blue, grey } from '@mui/material/colors';

// Create a theme instance
let theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: blue[700],
      light: blue[500],
      dark: blue[900],
    },
    secondary: {
      main: '#f50057',
      light: '#ff4081',
      dark: '#c51162',
    },
    error: {
      main: red[500],
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
    ].join(','),
    h1: {
      fontSize: '2.5rem',
      fontWeight: 500,
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 500,
    },
    h3: {
      fontSize: '1.75rem',
      fontWeight: 500,
    },
  },
  shape: {
    borderRadius: 8,
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: '0px 1px 3px rgba(0, 0, 0, 0.12)',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0px 2px 4px rgba(0, 0, 0, 0.05)',
        },
      },
    },
  },
});

// Apply responsive font sizes
theme = responsiveFontSizes(theme);

export default theme;
EOF

  # Create better Theme Registry with color mode switching
  cat > src/components/layout/ThemeRegistry.tsx << EOF
'use client';
import { createContext, useState, useMemo, ReactNode } from 'react';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { PaletteMode } from '@mui/material';
import { blue, grey } from '@mui/material/colors';
import baseTheme from '@/lib/theme/theme';

// Create color mode context
export const ColorModeContext = createContext({
  toggleColorMode: () => {},
  mode: 'light',
});

export default function ThemeRegistry({ children }: { children: ReactNode }) {
  // State for theme mode
  const [mode, setMode] = useState<PaletteMode>('light');

  // Color mode toggle handler
  const colorMode = useMemo(
    () => ({
      toggleColorMode: () => {
        setMode((prevMode) => (prevMode === 'light' ? 'dark' : 'light'));
      },
      mode,
    }),
    [mode]
  );

  // Create dynamic theme based on mode
  const theme = useMemo(() => {
    const updatedTheme = createTheme({
      ...baseTheme,
      palette: {
        mode,
        ...(mode === 'light'
          ? {
              // Light mode palette
              primary: baseTheme.palette.primary,
              secondary: baseTheme.palette.secondary,
              background: {
                default: '#f5f5f5',
                paper: '#ffffff',
              },
              text: {
                primary: grey[900],
                secondary: grey[700],
              },
            }
          : {
              // Dark mode palette
              primary: {
                main: blue[300],
              },
              background: {
                default: '#121212',
                paper: '#1e1e1e',
              },
              text: {
                primary: '#fff',
                secondary: grey[400],
              },
            }),
      },
    });

    return updatedTheme;
  }, [mode]);

  return (
    <ColorModeContext.Provider value={colorMode}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        {children}
      </ThemeProvider>
    </ColorModeContext.Provider>
  );
}
EOF

  # Create a responsive layout component
  mkdir -p src/components/layout/Dashboard
  cat > src/components/layout/Dashboard/DashboardLayout.tsx << EOF
'use client';
import { useState, useContext } from 'react';
import { styled, useTheme } from '@mui/material/styles';
import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import List from '@mui/material/List';
import Typography from '@mui/material/Typography';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import ChevronLeftIcon from '@mui/icons-material/ChevronLeft';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import BarChartIcon from '@mui/icons-material/BarChart';
import SettingsIcon from '@mui/icons-material/Settings';
import Brightness4Icon from '@mui/icons-material/Brightness4';
import Brightness7Icon from '@mui/icons-material/Brightness7';
import { ColorModeContext } from '../ThemeRegistry';

const drawerWidth = 240;

const Main = styled('main', { shouldForwardProp: (prop) => prop !== 'open' })<{
  open?: boolean;
}>(({ theme, open }) => ({
  flexGrow: 1,
  padding: theme.spacing(3),
  transition: theme.transitions.create('margin', {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.leavingScreen,
  }),
  marginLeft: 0,
  ...(open && {
    transition: theme.transitions.create('margin', {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
    marginLeft: drawerWidth,
  }),
}));

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const theme = useTheme();
  const colorMode = useContext(ColorModeContext);
  const [open, setOpen] = useState(false);

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  const menuItems = [
    { text: 'Dashboard', icon: <DashboardIcon />, path: '/' },
    { text: 'Users', icon: <PeopleIcon />, path: '/users' },
    { text: 'Analytics', icon: <BarChartIcon />, path: '/analytics' },
    { text: 'Settings', icon: <SettingsIcon />, path: '/settings' },
  ];

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          zIndex: (theme) => theme.zIndex.drawer + 1,
          transition: theme.transitions.create(['width', 'margin'], {
            easing: theme.transitions.easing.sharp,
            duration: theme.transitions.duration.leavingScreen,
          }),
          ...(open && {
            marginLeft: drawerWidth,
            width: \`calc(100% - \${drawerWidth}px)\`,
            transition: theme.transitions.create(['width', 'margin'], {
              easing: theme.transitions.easing.sharp,
              duration: theme.transitions.duration.enteringScreen,
            }),
          }),
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            onClick={handleDrawerOpen}
            edge="start"
            sx={{ mr: 2, ...(open && { display: 'none' }) }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            $project_name
          </Typography>
          <IconButton onClick={colorMode.toggleColorMode} color="inherit">
            {theme.palette.mode === 'dark' ? <Brightness7Icon /> : <Brightness4Icon />}
          </IconButton>
        </Toolbar>
      </AppBar>
      <Drawer
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: drawerWidth,
            boxSizing: 'border-box',
          },
        }}
        variant="persistent"
        anchor="left"
        open={open}
      >
        <Toolbar
          sx={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'flex-end',
            px: [1],
          }}
        >
          <IconButton onClick={handleDrawerClose}>
            {theme.direction === 'ltr' ? <ChevronLeftIcon /> : <ChevronRightIcon />}
          </IconButton>
        </Toolbar>
        <Divider />
        <List>
          {menuItems.map((item) => (
            <ListItem key={item.text} disablePadding>
              <ListItemButton>
                <ListItemIcon>{item.icon}</ListItemIcon>
                <ListItemText primary={item.text} />
              </ListItemButton>
            </ListItem>
          ))}
        </List>
      </Drawer>
      <Main open={open}>
        <Toolbar /> {/* This empty toolbar pushes content below the app bar */}
        <Box sx={{ p: 3 }}>{children}</Box>
      </Main>
    </Box>
  );
}
EOF

  # Update the app layout to use the dashboard layout for better structure
  cat > src/app/layout.tsx << EOF
import { Inter } from 'next/font/google';
import ThemeRegistry from '@/components/layout/ThemeRegistry';

const inter = Inter({ subsets: ['latin'] });

export const metadata = {
  title: '$project_name',
  description: 'A Next.js application with Material UI',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <ThemeRegistry>
          {children}
        </ThemeRegistry>
      </body>
    </html>
  );
}
EOF

  # Create a more comprehensive home page with Material UI components
  cat > src/app/page.tsx << EOF
'use client';
import { useState } from 'react';
import DashboardLayout from '@/components/layout/Dashboard/DashboardLayout';
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Card from '@mui/material/Card';
import CardContent from '@mui/material/CardContent';
import CardActions from '@mui/material/CardActions';
import CardHeader from '@mui/material/CardHeader';
import Divider from '@mui/material/Divider';
import Stack from '@mui/material/Stack';
import Chip from '@mui/material/Chip';
import TextField from '@mui/material/TextField';
import AddIcon from '@mui/icons-material/Add';
import RefreshIcon from '@mui/icons-material/Refresh';
import DownloadIcon from '@mui/icons-material/Download';
import Alert from '@mui/material/Alert';
import AlertTitle from '@mui/material/AlertTitle';
import LinearProgress from '@mui/material/LinearProgress';

export default function Home() {
  const [count, setCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [showAlert, setShowAlert] = useState(false);

  const handleIncrement = () => {
    setCount(count + 1);
  };

  const handleReset = () => {
    setCount(0);
  };

  const handleLoadDemo = () => {
    setLoading(true);
    setShowAlert(false);
    
    // Simulate loading
    setTimeout(() => {
      setLoading(false);
      setShowAlert(true);
    }, 1500);
  };

  return (
    <DashboardLayout>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Dashboard
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Welcome to your $project_name dashboard
        </Typography>
      </Box>

      {loading && <LinearProgress sx={{ mb: 3 }} />}

      {showAlert && (
        <Alert 
          severity="success" 
          sx={{ mb: 3 }}
          onClose={() => setShowAlert(false)}
        >
          <AlertTitle>Success</AlertTitle>
          Data loaded successfully
        </Alert>
      )}

      <Box sx={{ mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item>
            <Button 
              variant="contained" 
              startIcon={<RefreshIcon />}
              onClick={handleLoadDemo}
            >
              Refresh Data
            </Button>
          </Grid>
          <Grid item>
            <Button 
              variant="outlined" 
              startIcon={<AddIcon />}
            >
              Add New
            </Button>
          </Grid>
          <Grid item>
            <Button 
              variant="outlined" 
              startIcon={<DownloadIcon />}
              color="secondary"
            >
              Export
            </Button>
          </Grid>
        </Grid>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card>
            <CardHeader 
              title="Overview" 
              subheader="Performance indicators"
            />
            <Divider />
            <CardContent>
              <Typography variant="body1" paragraph>
                This is a Next.js application with Material UI integration. 
                Use this as a starting point for your project.
              </Typography>
              <Paper elevation={0} variant="outlined" sx={{ p: 2, mb: 2 }}>
                <Stack direction="row" spacing={1} sx={{ mb: 2 }}>
                  <Chip label="React" color="primary" />
                  <Chip label="Next.js" color="secondary" />
                  <Chip label="Material UI" />
                </Stack>
                <Typography variant="body2" color="text.secondary">
                  Edit <code>src/app/page.tsx</code> to modify this page. The layout
                  uses Material UI's responsive design principles to adapt to different screen sizes.
                </Typography>
              </Paper>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={4}>
          <Stack spacing={3}>
            <Card>
              <CardHeader title="Counter Example" />
              <CardContent>
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2 }}>
                  <Typography variant="h3" component="div">
                    {count}
                  </Typography>
                </Box>
                <Typography variant="body2" color="text.secondary">
                  Simple state management example with React hooks
                </Typography>
              </CardContent>
              <CardActions>
                <Button 
                  variant="contained" 
                  onClick={handleIncrement}
                  size="small"
                >
                  Increment
                </Button>
                <Button 
                  variant="outlined" 
                  onClick={handleReset}
                  size="small"
                >
                  Reset
                </Button>
              </CardActions>
            </Card>

            <Card>
              <CardHeader title="Quick Form" />
              <CardContent>
                <TextField
                  label="Name"
                  fullWidth
                  margin="normal"
                  variant="outlined"
                  size="small"
                />
                <TextField
                  label="Email"
                  fullWidth
                  margin="normal"
                  variant="outlined"
                  size="small"
                />
              </CardContent>
              <CardActions>
                <Button 
                  variant="contained" 
                  size="small"
                >
                  Submit
                </Button>
              </CardActions>
            </Card>
          </Stack>
        </Grid>
      </Grid>
    </DashboardLayout>
  );
}
EOF

  # Initial git commit
  git add .
  git commit -m "Initial commit: Next.js fullstack project setup"
  
  echo "✅ Next.js fullstack project created: $project_name"
  echo ""
  echo "📋 Next steps:"
  echo "  1. cd $project_name"
  echo "  2. npm run dev"
  echo "  3. Open http://localhost:3000 in your browser"
  echo ""
}

setup_flask_fullstack() {
  local project_name="$1"
  local github_username=$(git config user.name | tr -d ' ' | tr '[:upper:]' '[:lower:]')
  
  # Check dependencies
  if ! check_dependencies "python"; then
    return 1
  fi
  
  echo "🚀 Setting up Flask + TypeScript fullstack project: $project_name"
  
  # Create project directory if it doesn't exist
  mkdir -p "$project_name"
  cd "$project_name" || return 1
  
  # Initialize git repository
  git init
  
  # Create backend directory
  mkdir -p backend
  
  # Create Flask backend structure
  mkdir -p backend/app/api
  mkdir -p backend/app/models
  mkdir -p backend/app/services
  mkdir -p backend/app/utils
  mkdir -p backend/tests
  mkdir -p backend/migrations
  mkdir -p backend/config

  # Create Flask app
  cat > backend/app/__init__.py << EOF
from flask import Flask
from flask_cors import CORS
from config import config
import logging
import os
from logging.handlers import RotatingFileHandler, SMTPHandler

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Enable CORS
    CORS(app)
    
    # Configure logging
    configure_logging(app)
    
    # Register blueprints
    from app.api import api as api_blueprint
    app.register_blueprint(api_blueprint, url_prefix='/api')
    
    return app

def configure_logging(app):
    """Configure logging for the application."""
    if not os.path.exists('logs'):
        os.mkdir('logs')
        
    # Set up file handler for INFO level
    file_handler = RotatingFileHandler(
        'logs/app.log', 
        maxBytes=10240, 
        backupCount=10
    )
    file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    file_handler.setLevel(logging.INFO)
    app.logger.addHandler(file_handler)
    
    # Set up file handler for ERROR level
    error_file_handler = RotatingFileHandler(
        'logs/error.log', 
        maxBytes=10240, 
        backupCount=10
    )
    error_file_handler.setFormatter(logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    ))
    error_file_handler.setLevel(logging.ERROR)
    app.logger.addHandler(error_file_handler)
    
    # Set up email handler for ERROR level in production
    if not app.debug and not app.testing:
        if app.config.get('MAIL_SERVER'):
            auth = None
            if app.config.get('MAIL_USERNAME') or app.config.get('MAIL_PASSWORD'):
                auth = (app.config.get('MAIL_USERNAME'), app.config.get('MAIL_PASSWORD'))
            secure = None
            if app.config.get('MAIL_USE_TLS'):
                secure = ()
            mail_handler = SMTPHandler(
                mailhost=(app.config.get('MAIL_SERVER'), app.config.get('MAIL_PORT')),
                fromaddr=app.config.get('MAIL_DEFAULT_SENDER'),
                toaddrs=app.config.get('ADMINS', []),
                subject='Application Error',
                credentials=auth,
                secure=secure
            )
            mail_handler.setLevel(logging.ERROR)
            app.logger.addHandler(mail_handler)
    
    # Set overall log level
    app.logger.setLevel(logging.INFO)
    app.logger.info('Application startup')
EOF

  # Create API blueprint
  cat > backend/app/api/__init__.py << EOF
from flask import Blueprint

api = Blueprint('api', __name__)

from . import routes
EOF

  cat > backend/app/api/routes.py << EOF
from flask import jsonify, current_app, request
from . import api
import logging

logger = logging.getLogger(__name__)

@api.before_request
def before_request():
    logger.info(f"Request: {request.method} {request.path} from {request.remote_addr}")

@api.after_request
def after_request(response):
    logger.info(f"Response: {response.status_code}")
    return response

@api.route('/hello', methods=['GET'])
def hello():
    logger.info("Hello endpoint called")
    return jsonify({"message": "Hello from Flask API!"})

@api.route('/health', methods=['GET'])
def health():
    logger.info("Health check endpoint called")
    return jsonify({"status": "healthy"})

@api.route('/error', methods=['GET'])
def error_test():
    logger.error("Error endpoint called - testing error logging")
    return jsonify({"error": "This is a test error"}), 500
EOF

  # Create config file
  cat > backend/config.py << EOF
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'hard-to-guess-string'
    LOG_LEVEL = os.environ.get('LOG_LEVEL') or 'INFO'
    
    # Mail settings
    MAIL_SERVER = os.environ.get('MAIL_SERVER')
    MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
    MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
    MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    MAIL_DEFAULT_SENDER = os.environ.get('MAIL_DEFAULT_SENDER')
    ADMINS = os.environ.get('ADMINS', '').split(',') if os.environ.get('ADMINS') else []
    
    @staticmethod
    def init_app(app):
        pass

class DevelopmentConfig(Config):
    DEBUG = True
    LOG_LEVEL = 'DEBUG'

class TestingConfig(Config):
    TESTING = True
    LOG_LEVEL = 'DEBUG'

class ProductionConfig(Config):
    DEBUG = False
    LOG_LEVEL = 'INFO'
    
    @classmethod
    def init_app(cls, app):
        Config.init_app(app)
        
        # Log to stderr in production
        import logging
        from logging import StreamHandler
        file_handler = StreamHandler()
        file_handler.setLevel(logging.INFO)
        app.logger.addHandler(file_handler)

config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}
EOF

  # Create requirements.txt
  cat > backend/requirements.txt << EOF
flask==2.3.3
flask-cors==4.0.0
python-dotenv==1.0.0
gunicorn==21.2.0
PyJWT==2.8.0
pytest==7.4.0
# For logging and error handling
sentry-sdk[flask]==1.37.1
EOF

  # Create a .env.example file
  cat > backend/.env.example << EOF
# Flask settings
FLASK_APP=wsgi.py
FLASK_ENV=development
SECRET_KEY=your-secret-key-here

# Logging
LOG_LEVEL=INFO

# Mail settings for error reporting
# MAIL_SERVER=smtp.example.com
# MAIL_PORT=587
# MAIL_USE_TLS=True
# MAIL_USERNAME=your-email@example.com
# MAIL_PASSWORD=your-password
# MAIL_DEFAULT_SENDER=noreply@example.com
# ADMINS=admin1@example.com,admin2@example.com
EOF

  # Frontend improvements
  # Create Material UI theme
  mkdir -p frontend/src/theme
  cat > frontend/src/theme/theme.ts << EOF
import { createTheme, responsiveFontSizes, alpha } from '@mui/material/styles';
import { blue, teal, blueGrey, grey, red } from '@mui/material/colors';

// Create a base theme
let theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      light: blue[500],
      main: blue[700],
      dark: blue[900],
      contrastText: '#fff',
    },
    secondary: {
      light: teal[300],
      main: teal[500],
      dark: teal[700],
      contrastText: '#fff',
    },
    background: {
      default: '#f7f9fc',
      paper: '#ffffff',
    },
    error: {
      main: red[500],
    },
    text: {
      primary: blueGrey[900],
      secondary: blueGrey[600],
    },
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
    ].join(','),
    h1: {
      fontSize: '2.5rem',
      fontWeight: 600,
    },
    h2: {
      fontSize: '2rem',
      fontWeight: 600, 
    },
    h3: {
      fontSize: '1.5rem',
      fontWeight: 600,
    },
    h4: {
      fontSize: '1.25rem',
      fontWeight: 600,
      lineHeight: 1.4,
    },
    h5: {
      fontSize: '1.1rem',
      fontWeight: 500,
    },
    h6: {
      fontSize: '1rem',
      fontWeight: 500,
    },
    body1: {
      fontSize: '1rem',
      lineHeight: 1.6,
    },
    body2: {
      fontSize: '0.875rem',
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  shape: {
    borderRadius: 8,
  },
  shadows: [
    'none',
    '0px 2px 1px -1px rgba(0,0,0,0.05),0px 1px 1px 0px rgba(0,0,0,0.03),0px 1px 3px 0px rgba(0,0,0,0.05)',
    '0px 3px 3px -2px rgba(0,0,0,0.05),0px 2px 6px 0px rgba(0,0,0,0.04),0px 1px 8px 0px rgba(0,0,0,0.04)',
    '0px 3px 4px -2px rgba(0,0,0,0.06),0px 3px 8px 0px rgba(0,0,0,0.04),0px 1px 10px 0px rgba(0,0,0,0.04)',
    // ... rest of the shadows remain unchanged
    ...Array(21).fill(''),
  ],
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 6,
          padding: '8px 16px',
          transition: 'background-color 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms, box-shadow 250ms cubic-bezier(0.4, 0, 0.2, 1) 0ms',
          textTransform: 'none',
        },
        contained: {
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0 3px 8px rgba(0, 0, 0, 0.1)',
          },
        },
        outlined: {
          borderWidth: 1.5,
          '&:hover': {
            borderWidth: 1.5,
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          boxShadow: '0 2px 12px 0 rgba(0, 0, 0, 0.05)',
          overflow: 'visible',
        },
      },
    },
    MuiCardHeader: {
      styleOverrides: {
        root: {
          padding: '24px 24px 8px',
        },
        title: {
          fontSize: '1.125rem',
          fontWeight: 500,
        },
      },
    },
    MuiCardContent: {
      styleOverrides: {
        root: {
          padding: '16px 24px 24px',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.07)',
        },
      },
    },
    MuiDrawer: {
      styleOverrides: {
        paper: {
          border: 'none',
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        elevation1: {
          boxShadow: '0 1px 3px 0 rgba(0, 0, 0, 0.07), 0 1px 2px 0 rgba(0, 0, 0, 0.05)',
        },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderBottom: `1px solid ${alpha(grey[300], 0.5)}`,
          padding: '16px 16px',
        },
        head: {
          fontWeight: 600,
          color: blueGrey[700],
        },
      },
    },
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 6,
          fontWeight: 500,
        },
        filled: {
          '&.MuiChip-colorPrimary': {
            backgroundColor: alpha(blue[500], 0.12),
            color: blue[700],
          },
          '&.MuiChip-colorSecondary': {
            backgroundColor: alpha(teal[500], 0.12),
            color: teal[700],
          },
        },
      },
    },
  },
});

// Apply responsive font sizes
theme = responsiveFontSizes(theme);

export default theme;
EOF

  # Create Layout component
  mkdir -p frontend/src/components/layout
  cat > frontend/src/components/layout/Layout.tsx << EOF
import { ReactNode } from 'react';
import { Box, AppBar, Toolbar, Typography, Container, Paper } from '@mui/material';
import { styled } from '@mui/material/styles';

const AppWrapper = styled(Box)(({ theme }) => ({
  display: 'flex',
  flexDirection: 'column',
  minHeight: '100vh',
  backgroundColor: theme.palette.background.default,
}));

const Main = styled(Box)(({ theme }) => ({
  flexGrow: 1,
  padding: theme.spacing(3),
  paddingTop: theme.spacing(10),
}));

const Footer = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(2),
  textAlign: 'center',
  marginTop: 'auto',
  backgroundColor: theme.palette.background.paper,
}));

interface LayoutProps {
  children: ReactNode;
  title?: string;
}

export default function Layout({ children, title = 'Flask + React App' }: LayoutProps) {
  return (
    <AppWrapper>
      <AppBar position="fixed">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            {title}
          </Typography>
        </Toolbar>
      </AppBar>
      
      <Main>
        <Container maxWidth="lg">
          {children}
        </Container>
      </Main>
      
      <Footer elevation={0}>
        <Typography variant="body2" color="text.secondary">
          © {new Date().getFullYear()} Flask + React Application
        </Typography>
      </Footer>
    </AppWrapper>
  );
}
EOF

  # Create a more robust frontend App.tsx
  cat > frontend/src/App.tsx << EOF
import { useState, useEffect } from 'react'
import axios from 'axios'
import Container from '@mui/material/Container'
import Box from '@mui/material/Box'
import Typography from '@mui/material/Typography'
import Paper from '@mui/material/Paper'
import CircularProgress from '@mui/material/CircularProgress'
import Card from '@mui/material/Card'
import CardContent from '@mui/material/CardContent'
import AppBar from '@mui/material/AppBar'
import Toolbar from '@mui/material/Toolbar'

function App() {
  const [message, setMessage] = useState<string>('')
  const [loading, setLoading] = useState<boolean>(true)

  useEffect(() => {
    // Fetch data from Flask backend
    axios.get('http://localhost:5000/api/hello')
      .then(response => {
        setMessage(response.data.message)
        setLoading(false)
      })
      .catch(error => {
        console.error('Error fetching data:', error)
        setMessage('Error connecting to backend')
        setLoading(false)
      })
  }, [])

  return (
    <Container maxWidth="md">
      <Box sx={{ my: 4 }}>
        <Typography variant="h3" component="h1" gutterBottom align="center">
          $project_name
        </Typography>
        
        <Paper elevation={3} sx={{ p: 3, mb: 4 }}>
          <Typography variant="body1">
            Flask backend + React frontend with Material UI
          </Typography>
        </Paper>
        
        <Card sx={{ minWidth: 275, mt: 2 }}>
          <CardContent>
            <Typography variant="h5" component="div" gutterBottom>
              Backend Response
            </Typography>
            {loading ? (
              <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
                <CircularProgress />
              </Box>
            ) : (
              <Typography variant="body1">{message}</Typography>
            )}
          </CardContent>
        </Card>
      </Box>
    </Container>
  )
}

export default App 