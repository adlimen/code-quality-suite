#!/usr/bin/env node

/**
 * Setup script for AdLimen Code Quality Suite
 * Automates integration into existing projects with multi-language support
 */

const fs = require('fs');
const path = require('path');

const colors = {
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  red: '\x1b[31m',
  blue: '\x1b[34m',
  reset: '\x1b[0m',
  bold: '\x1b[1m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`✅ ${message}`, colors.green);
}

function logWarning(message) {
  log(`⚠️  ${message}`, colors.yellow);
}

function logError(message) {
  log(`❌ ${message}`, colors.red);
}

function logInfo(message) {
  log(`ℹ️  ${message}`, colors.blue);
}

function fileExists(filePath) {
  return fs.existsSync(filePath);
}

function copyFile(source, destination) {
  try {
    if (!fs.existsSync(path.dirname(destination))) {
      fs.mkdirSync(path.dirname(destination), { recursive: true });
    }
    fs.copyFileSync(source, destination);
    return true;
  } catch (error) {
    logError(`Failed to copy ${source} to ${destination}: ${error.message}`);
    return false;
  }
}

function mergePackageJson() {
  const templatePath = './package-template.json';
  const projectPackagePath = '../package.json';

  if (!fileExists(templatePath)) {
    logError('package-template.json not found');
    return false;
  }

  const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));

  let projectPackage = {};
  if (fileExists(projectPackagePath)) {
    projectPackage = JSON.parse(fs.readFileSync(projectPackagePath, 'utf8'));
    logInfo('Found existing package.json, merging dependencies and scripts');
  } else {
    logInfo('No existing package.json found, creating new one');
  }

  // Merge devDependencies
  projectPackage.devDependencies = {
    ...projectPackage.devDependencies,
    ...template.devDependencies,
  };

  // Merge scripts, but don't overwrite existing ones
  projectPackage.scripts = {
    ...template.scripts,
    ...projectPackage.scripts,
  };

  // Add husky configuration if not present
  if (!projectPackage.husky) {
    projectPackage.husky = template.husky;
  }

  // Save merged package.json
  fs.writeFileSync(projectPackagePath, JSON.stringify(projectPackage, null, 2));
  logSuccess('package.json updated');
  return true;
}

function setupConfigurations() {
  const configs = [
    {
      source: './configs/.jscpd.json',
      destination: '../.jscpd.json',
    },
    {
      source: './configs/.lintstagedrc.js',
      destination: '../.lintstagedrc.js',
    },
  ];

  let success = true;
  configs.forEach(({ source, destination }) => {
    if (fileExists(destination)) {
      logWarning(`${destination} already exists, skipping`);
    } else {
      if (copyFile(source, destination)) {
        logSuccess(`Copied ${source} to ${destination}`);
      } else {
        success = false;
      }
    }
  });

  return success;
}

function setupScripts() {
  const scriptsPath = '../scripts';

  // Create scripts directory if it doesn't exist
  if (!fs.existsSync(scriptsPath)) {
    fs.mkdirSync(scriptsPath, { recursive: true });
  }

  const scripts = [
    'quality-check.js',
    'maintainability-check.js',
    'duplication-check.js',
    'setup-hooks.js',
  ];

  let success = true;
  scripts.forEach((script) => {
    const source = `./scripts/${script}`;
    const destination = `${scriptsPath}/${script}`;

    if (fileExists(destination)) {
      logWarning(`${destination} already exists, skipping`);
    } else {
      if (copyFile(source, destination)) {
        logSuccess(`Copied ${script} to scripts/`);
      } else {
        success = false;
      }
    }
  });

  return success;
}

function setupGitHooks() {
  const hooksPath = '../.husky';

  // Create .husky directory if it doesn't exist
  if (!fs.existsSync(hooksPath)) {
    fs.mkdirSync(hooksPath, { recursive: true });
  }

  const hooks = ['pre-commit', 'pre-push', 'commit-msg'];

  let success = true;
  hooks.forEach((hook) => {
    const source = `./hooks/${hook}`;
    const destination = `${hooksPath}/${hook}`;

    if (fileExists(destination)) {
      logWarning(`${destination} already exists, skipping`);
    } else {
      if (copyFile(source, destination)) {
        // Make hook executable
        fs.chmodSync(destination, '755');
        logSuccess(`Copied ${hook} hook to .husky/`);
      } else {
        success = false;
      }
    }
  });

  return success;
}

function setupGitHubWorkflows() {
  const workflowsPath = '../.github/workflows';

  // Create workflows directory if it doesn't exist
  if (!fs.existsSync(workflowsPath)) {
    fs.mkdirSync(workflowsPath, { recursive: true });
  }

  const workflows = ['quality-checks.yml', 'pre-merge.yml'];

  let success = true;
  workflows.forEach((workflow) => {
    const source = `./workflows/${workflow}`;
    const destination = `${workflowsPath}/${workflow}`;

    if (fileExists(destination)) {
      logWarning(`${destination} already exists, skipping`);
    } else {
      if (copyFile(source, destination)) {
        logSuccess(`Copied ${workflow} to .github/workflows/`);
      } else {
        success = false;
      }
    }
  });

  return success;
}

function setupDirectories() {
  const directories = ['../reports', '../reports/jscpd'];

  directories.forEach((dir) => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      logSuccess(`Created directory ${dir}`);
    }
  });
}

function main() {
  log(`${colors.bold}🚀 AdLimen Code Quality Suite Setup - Multi-Language Ready${colors.reset}\n`);

  let allSuccess = true;

  // Check if we're in the right directory
  if (!fileExists('./package-template.json')) {
    logError(
      'Please run this script from the adlimen-code-quality-suite directory'
    );
    process.exit(1);
  }

  logInfo('Setting up AdLimen Code Quality Suite for your project...\n');
  logInfo('📁 Available editions:');
  logInfo('  📘 JavaScript/TypeScript - Complete quality assurance');
  logInfo('  🐍 Python - Enhanced 11-step workflow with Safety handling');
  logInfo('🔧 To add new languages: See integration guide in README.md\n');

  // Setup package.json
  logInfo('📦 Setting up package.json...');
  if (!mergePackageJson()) {
    allSuccess = false;
  }

  // Setup configuration files
  logInfo('\n⚙️  Setting up configuration files...');
  if (!setupConfigurations()) {
    allSuccess = false;
  }

  // Setup scripts
  logInfo('\n📜 Setting up scripts...');
  if (!setupScripts()) {
    allSuccess = false;
  }

  // Setup git hooks
  logInfo('\n🪝 Setting up git hooks...');
  if (!setupGitHooks()) {
    allSuccess = false;
  }

  // Setup GitHub workflows
  logInfo('\n🔄 Setting up GitHub workflows...');
  if (!setupGitHubWorkflows()) {
    allSuccess = false;
  }

  // Setup directories
  logInfo('\n📁 Setting up directories...');
  setupDirectories();

  if (allSuccess) {
    log(
      `\n${colors.bold}${colors.green}✅ Setup completed successfully!${colors.reset}\n`
    );

    logInfo('Next steps:');
    log('1. Run: npm install');
    log('2. Run: npm run setup-hooks');
    log('3. Run: npm run quality');
    log('\nYour project is now ready with comprehensive quality checks!');
  } else {
    log(
      `\n${colors.bold}${colors.yellow}⚠️  Setup completed with warnings${colors.reset}\n`
    );
    logInfo('Some files were skipped because they already exist.');
    logInfo(
      'Please review the warnings above and manually merge any needed changes.'
    );
  }
}

if (require.main === module) {
  main();
}

module.exports = {
  mergePackageJson,
  setupConfigurations,
  setupScripts,
  setupGitHooks,
  setupGitHubWorkflows,
};
