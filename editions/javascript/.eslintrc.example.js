/**
 * ESLint Configuration Example
 * Copy and adapt this to your project as .eslintrc.js
 */

module.exports = {
  // For Next.js projects
  extends: [
    'next/core-web-vitals',
    // For React projects without Next.js, use:
    // '@next/eslint-config-next',
    // For vanilla TypeScript/JavaScript:
    // '@typescript-eslint/recommended',
  ],

  // Essential plugins for quality checks
  plugins: ['security', 'sonarjs', 'unused-imports', '@typescript-eslint'],

  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    ecmaFeatures: {
      jsx: true,
    },
  },

  rules: {
    // === COMPLEXITY RULES ===
    complexity: ['warn', 10],
    'max-depth': ['warn', 4],
    'max-lines': ['warn', 300],
    'max-lines-per-function': ['warn', 50],
    'max-params': ['warn', 4],
    'max-statements': ['warn', 20],
    'max-nested-callbacks': ['warn', 3],

    // === SECURITY RULES ===
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'warn',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-non-literal-fs-filename': 'warn',
    'security/detect-non-literal-require': 'warn',
    'security/detect-possible-timing-attacks': 'warn',
    'security/detect-pseudoRandomBytes': 'error',

    // === SONARJS RULES ===
    'sonarjs/cognitive-complexity': ['warn', 15],
    'sonarjs/no-duplicate-string': ['warn', 5],
    'sonarjs/no-duplicated-branches': 'error',
    'sonarjs/no-identical-conditions': 'error',
    'sonarjs/no-identical-expressions': 'error',
    'sonarjs/no-one-iteration-loop': 'error',
    'sonarjs/no-use-of-empty-return-value': 'error',
    'sonarjs/prefer-immediate-return': 'warn',
    'sonarjs/prefer-object-literal': 'warn',
    'sonarjs/prefer-single-boolean-return': 'warn',

    // === UNUSED IMPORTS ===
    'unused-imports/no-unused-imports': 'error',
    'unused-imports/no-unused-vars': [
      'warn',
      {
        vars: 'all',
        varsIgnorePattern: '^_',
        args: 'after-used',
        argsIgnorePattern: '^_',
      },
    ],

    // === CODE QUALITY ===
    'prefer-const': 'error',
    'no-var': 'error',
    'no-console': 'warn',
    'no-debugger': 'error',
    'no-alert': 'error',
    eqeqeq: ['error', 'always'],
    'no-duplicate-imports': 'error',
    'no-unreachable': 'error',
    'no-unused-expressions': 'error',
    'consistent-return': 'warn',
    'default-case': 'warn',
    'dot-notation': 'warn',
    'no-else-return': 'warn',
    'no-empty-function': 'warn',
    'no-magic-numbers': [
      'warn',
      {
        ignore: [-1, 0, 1, 2],
        ignoreArrayIndexes: true,
        ignoreDefaultValues: true,
      },
    ],

    // === TYPESCRIPT SPECIFIC ===
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/no-unused-vars': 'off', // Handled by unused-imports
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/prefer-nullish-coalescing': 'warn',
    '@typescript-eslint/prefer-optional-chain': 'warn',
    '@typescript-eslint/no-non-null-assertion': 'warn',

    // === REACT SPECIFIC (if using React) ===
    'react/prop-types': 'off', // Using TypeScript
    'react/react-in-jsx-scope': 'off', // Not needed in Next.js
    'react-hooks/exhaustive-deps': 'warn',
    'react/no-unescaped-entities': 'off',
  },

  // Environment configuration
  env: {
    browser: true,
    es2022: true,
    node: true,
  },

  // Global variables
  globals: {
    React: 'readonly',
    JSX: 'readonly',
  },

  // Override for specific file patterns
  overrides: [
    {
      files: ['**/*.test.{js,ts,tsx}', '**/*.spec.{js,ts,tsx}'],
      env: {
        jest: true,
      },
      rules: {
        'no-magic-numbers': 'off',
        'max-lines-per-function': 'off',
        'sonarjs/no-duplicate-string': 'off',
      },
    },
    {
      files: ['scripts/**/*.js', '*.config.js'],
      rules: {
        'no-console': 'off',
        '@typescript-eslint/no-var-requires': 'off',
      },
    },
    {
      files: ['**/*.d.ts'],
      rules: {
        'unused-imports/no-unused-vars': 'off',
      },
    },
  ],

  // Ignore patterns
  ignorePatterns: [
    'node_modules/',
    '.next/',
    'build/',
    'dist/',
    'coverage/',
    'reports/',
    '*.min.js',
    '*.bundle.js',
  ],
};
