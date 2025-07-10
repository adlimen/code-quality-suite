#!/usr/bin/env node

/**
 * Setup script for Husky hooks and development environment - Standalone Version
 * Run this after npm install to configure git hooks
 * Adapted from the Nutry project for general reuse.
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Colors for output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

const emojis = {
  success: '✅',
  error: '❌',
  warning: '⚠️',
  info: 'ℹ️',
  rocket: '🚀',
  gear: '⚙️',
  hook: '🪝',
};

// Configuration
let SOURCE_DIR = 'src';
let PROJECT_NAME = 'Project';

function log(message, color = colors.cyan) {
  console.log(`${color}${message}${colors.reset}`);
}

function success(message) {
  console.log(`${colors.green}${emojis.success} ${message}${colors.reset}`);
}

function error(message) {
  console.log(`${colors.red}${emojis.error} ${message}${colors.reset}`);
}

function warning(message) {
  console.log(`${colors.yellow}${emojis.warning} ${message}${colors.reset}`);
}

function info(message) {
  console.log(`${colors.blue}${emojis.info} ${message}${colors.reset}`);
}

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    sourceDir: SOURCE_DIR,
    projectName: PROJECT_NAME,
    verbose: args.includes('--verbose'),
  };

  // Check for custom source directory
  const sourceDirIndex = args.findIndex((arg) =>
    arg.startsWith('--source-dir=')
  );
  if (sourceDirIndex !== -1) {
    options.sourceDir = args[sourceDirIndex].split('=')[1];
    SOURCE_DIR = options.sourceDir;
  }

  // Check for custom project name
  const projectNameIndex = args.findIndex((arg) =>
    arg.startsWith('--project-name=')
  );
  if (projectNameIndex !== -1) {
    options.projectName = args[projectNameIndex].split('=')[1];
    PROJECT_NAME = options.projectName;
  }

  return options;
}

/**
 * Run a command and return promise
 */
function runCommand(command, args = [], options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      stdio: 'inherit',
      ...options,
    });

    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Command failed with code ${code}`));
      }
    });
  });
}

/**
 * Make file executable
 */
function makeExecutable(filePath) {
  try {
    fs.chmodSync(filePath, 0o755);
    return true;
  } catch (err) {
    return false;
  }
}

/**
 * Check if file exists
 */
function fileExists(filePath) {
  return fs.existsSync(filePath);
}

/**
 * Create file with content
 */
function createFile(filePath, content) {
  try {
    const dir = path.dirname(filePath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, content);
    return true;
  } catch (err) {
    return false;
  }
}

/**
 * Setup Husky hooks
 */
async function setupHuskyHooks() {
  info('Setting up Husky git hooks...');

  try {
    // Install husky
    await runCommand('npx', ['husky', 'install']);
    success('Husky installed successfully');

    // Create hooks if they don't exist
    const hooks = [
      {
        name: 'pre-commit',
        content: `#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
`,
      },
      {
        name: 'pre-push',
        content: `#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npm run quality:fast
`,
      },
      {
        name: 'commit-msg',
        content: `#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

# Basic commit message validation
# Add your own rules here

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
  echo "Invalid commit message format!"
  echo "Format: type(scope): description"
  echo "Types: feat, fix, docs, style, refactor, test, chore"
  echo "Example: feat(auth): add login validation"
  exit 1
fi
`,
      },
    ];

    for (const hook of hooks) {
      const hookPath = `.husky/${hook.name}`;
      if (!fileExists(hookPath)) {
        if (createFile(hookPath, hook.content)) {
          makeExecutable(hookPath);
          success(`Created ${hook.name} hook`);
        } else {
          warning(`Could not create ${hook.name} hook`);
        }
      } else {
        if (makeExecutable(hookPath)) {
          success(`Made ${hook.name} hook executable`);
        } else {
          warning(`Could not make ${hook.name} hook executable`);
        }
      }
    }

    success('Husky hooks setup completed');
  } catch (err) {
    error(`Failed to setup Husky hooks: ${err.message}`);
    throw err;
  }
}

/**
 * Verify environment
 */
async function verifyEnvironment() {
  info('Verifying development environment...');

  const requiredTools = [
    { command: 'node', args: ['--version'] },
    { command: 'npm', args: ['--version'] },
    { command: 'npx', args: ['--version'] },
    { command: 'git', args: ['--version'] },
  ];

  for (const tool of requiredTools) {
    try {
      await runCommand(tool.command, tool.args, { stdio: 'ignore' });
      success(`${tool.command} is available`);
    } catch (err) {
      error(`${tool.command} is not available`);
      throw new Error(`Missing required tool: ${tool.command}`);
    }
  }

  success('Environment verification completed');
}

/**
 * Setup development environment
 */
async function setupDevelopmentEnvironment() {
  info('Setting up development environment...');

  // Create necessary directories
  const directories = ['reports', 'coverage', `${SOURCE_DIR}`];

  for (const dir of directories) {
    if (!fileExists(dir)) {
      try {
        fs.mkdirSync(dir, { recursive: true });
        success(`Created directory: ${dir}`);
      } catch (err) {
        warning(`Could not create directory ${dir}: ${err.message}`);
      }
    }
  }

  // Create .jscpd.json if it doesn't exist
  if (!fileExists('.jscpd.json')) {
    const jscpdConfig = {
      threshold: 0.1,
      reporters: ['html', 'json', 'console'],
      absolute: true,
      gitignore: true,
      ignore: [
        'node_modules/**',
        '.next/**',
        'coverage/**',
        'dist/**',
        'build/**',
        '**/*.min.js',
        '**/*.map',
        '**/*.test.{js,ts,tsx}',
        '**/*.spec.{js,ts,tsx}',
        '**/*.stories.{js,ts,tsx}',
        'reports/**',
        'docs/**',
      ],
      formats: ['javascript', 'typescript', 'jsx', 'tsx'],
      minLines: 10,
      minTokens: 70,
      maxLines: 500,
      maxSize: '30kb',
      output: './reports/jscpd',
    };

    if (createFile('.jscpd.json', JSON.stringify(jscpdConfig, null, 2))) {
      success('Created .jscpd.json configuration');
    } else {
      warning('Could not create .jscpd.json configuration');
    }
  }

  // Create .lintstagedrc.js if it doesn't exist
  if (!fileExists('.lintstagedrc.js')) {
    const lintStagedConfig = `module.exports = {
  // TypeScript and JavaScript files
  '**/*.{ts,tsx,js,jsx}': [
    'prettier --write',
    'eslint --fix',
  ],

  // JSON files
  '**/*.json': ['prettier --write'],

  // Markdown files
  '**/*.md': ['prettier --write'],

  // CSS files
  '**/*.{css,scss}': ['prettier --write'],

  // Configuration files
  '**/*.{yml,yaml}': ['prettier --write'],
};
`;

    if (createFile('.lintstagedrc.js', lintStagedConfig)) {
      success('Created .lintstagedrc.js configuration');
    } else {
      warning('Could not create .lintstagedrc.js configuration');
    }
  }

  success('Development environment setup completed');
}

/**
 * Setup linting tools configuration
 */
async function setupLintingTools() {
  info('Setting up linting tools...');

  try {
    // Check if .eslintrc exists
    const eslintConfigs = [
      '.eslintrc.js',
      '.eslintrc.json',
      'eslint.config.js',
      'eslint.config.mjs',
    ];

    const hasEslintConfig = eslintConfigs.some((config) => fileExists(config));

    if (!hasEslintConfig) {
      warning('No ESLint configuration found');
      info(
        'Please create .eslintrc.js with appropriate rules for your project'
      );
    } else {
      success('ESLint configuration found');
    }

    // Check if .prettierrc exists
    const prettierConfigs = [
      '.prettierrc',
      '.prettierrc.json',
      '.prettierrc.js',
      'prettier.config.js',
    ];

    const hasPrettierConfig = prettierConfigs.some((config) =>
      fileExists(config)
    );

    if (!hasPrettierConfig) {
      const prettierConfig = {
        semi: true,
        trailingComma: 'es5',
        singleQuote: true,
        printWidth: 80,
        tabWidth: 2,
      };

      if (createFile('.prettierrc', JSON.stringify(prettierConfig, null, 2))) {
        success('Created .prettierrc configuration');
      } else {
        warning('Could not create .prettierrc configuration');
      }
    } else {
      success('Prettier configuration found');
    }

    success('Linting tools setup completed');
  } catch (err) {
    error(`Failed to setup linting tools: ${err.message}`);
  }
}

/**
 * Run initial quality check
 */
async function runInitialQualityCheck() {
  info('Running initial quality check...');

  try {
    if (fileExists('scripts/quality-check.js')) {
      await runCommand('node', ['scripts/quality-check.js', 'env']);
      success('Initial quality check completed');
    } else {
      warning('Quality check script not found - skipping initial check');
    }
  } catch (err) {
    warning(`Initial quality check failed: ${err.message}`);
    info('This is normal for new projects - continue with development');
  }
}

/**
 * Show help
 */
function showHelp() {
  console.log(
    `${colors.bright}${PROJECT_NAME} - Development Environment Setup${colors.reset}`
  );
  console.log('='.repeat(60));
  console.log('');
  console.log('Usage: node scripts/setup-hooks.js [options]');
  console.log('');
  console.log('Options:');
  console.log(
    '  --source-dir=<path>    Specify source directory (default: src)'
  );
  console.log('  --project-name=<name>  Specify project name');
  console.log('  --verbose              Verbose output');
  console.log('  --help                 Show this help message');
  console.log('');
  console.log('This script will:');
  console.log('  • Install and configure Husky git hooks');
  console.log('  • Create necessary directories');
  console.log('  • Set up configuration files (.jscpd.json, .lintstagedrc.js)');
  console.log('  • Verify development environment');
  console.log('  • Run initial quality checks');
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.includes('--help') || args.includes('-h')) {
    showHelp();
    return;
  }

  const options = parseArgs();

  console.log(
    `${colors.bright}${emojis.rocket} Setting up ${PROJECT_NAME} development environment${colors.reset}\n`
  );

  try {
    await verifyEnvironment();
    await setupDevelopmentEnvironment();
    await setupLintingTools();
    await setupHuskyHooks();
    await runInitialQualityCheck();

    console.log(
      `\n${colors.green}${emojis.success} Development environment setup completed!${colors.reset}`
    );
    console.log(
      `${colors.cyan}${emojis.info} You can now start development with quality checks enabled${colors.reset}`
    );
    console.log(
      `${colors.cyan}${emojis.info} Run 'npm run quality' to check code quality anytime${colors.reset}`
    );
  } catch (error) {
    error(`Setup failed: ${error.message}`);
    console.log(
      `\n${colors.yellow}${emojis.warning} Setup incomplete. Please resolve the issues above and run again.${colors.reset}`
    );
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  setupHuskyHooks,
  verifyEnvironment,
  setupDevelopmentEnvironment,
  setupLintingTools,
  runInitialQualityCheck,
};
