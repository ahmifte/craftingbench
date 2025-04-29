import js from '@eslint/js';
import { FlatCompat } from '@eslint/eslintrc';
import path from 'path';
import { fileURLToPath } from 'url';

// Convert the URL to a file path for Node.js
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Create a compatibility instance
const compat = new FlatCompat({
    baseDirectory: __dirname,
});

export default [
    // Base JS configuration
    js.configs.recommended,

    // Add TypeScript support (primary language for all projects)
    ...compat.config({
        extends: [
            'plugin:@typescript-eslint/recommended',
        ],
        parser: '@typescript-eslint/parser',
        plugins: ['@typescript-eslint'],
        rules: {
            '@typescript-eslint/no-unused-vars': 'warn',
            '@typescript-eslint/no-explicit-any': 'warn',
        },
    }),

    // Add React support (for frontend templates)
    ...compat.config({
        extends: [
            'plugin:react/recommended',
            'plugin:react-hooks/recommended',
        ],
        plugins: ['react', 'react-hooks'],
        settings: {
            react: {
                version: 'detect',
            },
        },
        rules: {
            'react/prop-types': 'off',
            'react/react-in-jsx-scope': 'off',
            'react-hooks/rules-of-hooks': 'error',
            'react-hooks/exhaustive-deps': 'warn',
        },
    }),

    // Add import rules (helpful for both frontend and backend)
    ...compat.config({
        plugins: ['import'],
        rules: {
            'import/no-unresolved': 'off', // TypeScript handles this
            'import/order': [
                'warn',
                {
                    groups: [
                        'builtin',
                        'external',
                        'internal',
                        'parent',
                        'sibling',
                        'index',
                    ],
                    'newlines-between': 'always',
                },
            ],
        },
    }),

    // Add Prettier compatibility
    ...compat.config({
        extends: ['prettier'],
    }),

    // Specific overrides for different file types
    {
        files: ['**/*.ts', '**/*.tsx', '**/*.mts', '**/*.cts'],
        languageOptions: {
            parser: compat.languageOptions.parser,
            parserOptions: {
                ecmaVersion: 'latest',
                sourceType: 'module',
                ecmaFeatures: {
                    jsx: true,
                },
            },
        },
    },

    // Legacy JavaScript files (only used when necessary)
    {
        files: ['**/*.js', '**/*.mjs', '**/*.cjs'],
        languageOptions: {
            ecmaVersion: 'latest',
            sourceType: 'module',
        },
    },

    // Shell scripts in src/templates
    {
        files: ['src/templates/**/*.sh'],
        rules: {
            // Disable ESLint for shell scripts
            'no-undef': 'off',
            'no-unused-vars': 'off',
        },
    },
];
