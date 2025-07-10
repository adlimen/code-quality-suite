#!/bin/bash

#####################################################################
# AdLimen Quality Code System - Universal Installer
# Comprehensive quality assurance system for any codebase
# Supports JavaScript/TypeScript and Python with configurable options
#####################################################################

set -e  # Exit on any error

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Emojis
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
MAGNIFYING="🔍"
FOLDER="📁"
WRENCH="🔧"
SHIELD="🛡️"

# Default configuration
DEFAULT_CONFIG_FILE=".adlimen.config.json"
INSTALLER_VERSION="1.0.0"
INSTALLER_DATE="2025-07-10"

# Global variables
PROJECT_ROOT=""
LANGUAGES=()
FRONTEND_DIR=""
BACKEND_DIR=""
PREFERRED_INTERFACE=""
COMPLEXITY_THRESHOLD=10
MAINTAINABILITY_THRESHOLD=70
DUPLICATION_THRESHOLD=5
ENABLE_SECURITY=true
ENABLE_GIT_HOOKS=true
CI_PROVIDER=""
CONFIG_FILE=""

#####################################################################
# Utility Functions
#####################################################################

print_header() {
    echo -e "${CYAN}${WHITE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  AdLimen Quality Code System                  ║"
    echo "║              Universal Quality Assurance Installer            ║"
    echo "║                        Version ${INSTALLER_VERSION}                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${PURPLE}Transform your codebase with enterprise-grade quality controls${NC}"
    echo ""
}

print_message() {
    local level=$1
    local message=$2
    local emoji=""
    local color=""
    
    case $level in
        "success") emoji="${SUCCESS}"; color="${GREEN}" ;;
        "error") emoji="${ERROR}"; color="${RED}" ;;
        "warning") emoji="${WARNING}"; color="${YELLOW}" ;;
        "info") emoji="${INFO}"; color="${BLUE}" ;;
        *) emoji="${INFO}"; color="${WHITE}" ;;
    esac
    
    echo -e "${emoji} ${color}${message}${NC}"
}

print_step() {
    local step=$1
    local message=$2
    echo -e "${ROCKET} ${WHITE}Step ${step}: ${message}${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if directory exists and is not empty
dir_exists_and_not_empty() {
    [ -d "$1" ] && [ "$(ls -A "$1" 2>/dev/null)" ]
}

# Detect project type and structure
detect_project_structure() {
    print_step "1" "Detecting project structure..."
    
    PROJECT_ROOT=$(pwd)
    print_message "info" "Analyzing project at: ${PROJECT_ROOT}"
    
    # Detect languages
    if [ -f "package.json" ] || [ -f "tsconfig.json" ] || find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -1 | grep -q .; then
        LANGUAGES+=("javascript")
        print_message "success" "JavaScript/TypeScript detected"
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ] || find . -name "*.py" | head -1 | grep -q .; then
        LANGUAGES+=("python")
        print_message "success" "Python detected"
    fi
    
    if [ ${#LANGUAGES[@]} -eq 0 ]; then
        print_message "warning" "No supported languages detected. Supported: JavaScript/TypeScript, Python"
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Detect common directory structures
    local possible_frontend=("frontend" "client" "web" "ui" "app" "src/frontend" "packages/frontend")
    local possible_backend=("backend" "server" "api" "src/backend" "packages/backend")
    
    for dir in "${possible_frontend[@]}"; do
        if [ -d "$dir" ]; then
            FRONTEND_DIR="$dir"
            print_message "success" "Frontend directory detected: ${dir}"
            break
        fi
    done
    
    for dir in "${possible_backend[@]}"; do
        if [ -d "$dir" ]; then
            BACKEND_DIR="$dir"
            print_message "success" "Backend directory detected: ${dir}"
            break
        fi
    done
    
    # If no specific structure, assume monorepo or simple structure
    if [ -z "$FRONTEND_DIR" ] && [ -z "$BACKEND_DIR" ]; then
        if [ -f "package.json" ]; then
            FRONTEND_DIR="."
            print_message "info" "Using root directory as frontend"
        fi
        if [[ " ${LANGUAGES[@]} " =~ " python " ]]; then
            BACKEND_DIR="."
            print_message "info" "Using root directory as backend"
        fi
    fi
}

# Interactive configuration
interactive_configuration() {
    print_step "2" "Interactive configuration..."
    
    echo -e "${YELLOW}Please provide the following information:${NC}"
    echo ""
    
    # Confirm detected structure
    if [ -n "$FRONTEND_DIR" ]; then
        read -p "Frontend directory [$FRONTEND_DIR]: " input
        FRONTEND_DIR=${input:-$FRONTEND_DIR}
    else
        read -p "Frontend directory (leave empty if none): " FRONTEND_DIR
    fi
    
    if [ -n "$BACKEND_DIR" ]; then
        read -p "Backend directory [$BACKEND_DIR]: " input
        BACKEND_DIR=${input:-$BACKEND_DIR}
    else
        read -p "Backend directory (leave empty if none): " BACKEND_DIR
    fi
    
    # Interface preference
    echo ""
    echo "Choose your preferred interface:"
    echo "1) npm scripts (recommended for Node.js teams)"
    echo "2) Make commands (recommended for Unix/DevOps teams)"
    echo "3) Both (dual interface)"
    read -p "Choice [1-3]: " interface_choice
    
    case $interface_choice in
        1) PREFERRED_INTERFACE="npm" ;;
        2) PREFERRED_INTERFACE="make" ;;
        3) PREFERRED_INTERFACE="both" ;;
        *) PREFERRED_INTERFACE="npm" ;;
    esac
    
    # Quality thresholds
    echo ""
    echo -e "${YELLOW}Quality Thresholds (press Enter for defaults):${NC}"
    read -p "Complexity threshold [$COMPLEXITY_THRESHOLD]: " input
    COMPLEXITY_THRESHOLD=${input:-$COMPLEXITY_THRESHOLD}
    
    read -p "Maintainability threshold [$MAINTAINABILITY_THRESHOLD]: " input
    MAINTAINABILITY_THRESHOLD=${input:-$MAINTAINABILITY_THRESHOLD}
    
    read -p "Duplication threshold (min lines) [$DUPLICATION_THRESHOLD]: " input
    DUPLICATION_THRESHOLD=${input:-$DUPLICATION_THRESHOLD}
    
    # Security and git hooks
    echo ""
    read -p "Enable security scanning? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_SECURITY=false
    fi
    
    read -p "Setup git hooks? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_GIT_HOOKS=false
    fi
    
    # CI/CD integration
    echo ""
    echo "Select CI/CD provider (optional):"
    echo "1) GitHub Actions"
    echo "2) GitLab CI"
    echo "3) CircleCI"
    echo "4) None/Skip"
    read -p "Choice [1-4]: " ci_choice
    
    case $ci_choice in
        1) CI_PROVIDER="github" ;;
        2) CI_PROVIDER="gitlab" ;;
        3) CI_PROVIDER="circleci" ;;
        *) CI_PROVIDER="" ;;
    esac
    
    # Config file location
    read -p "Configuration file name [$DEFAULT_CONFIG_FILE]: " input
    CONFIG_FILE=${input:-$DEFAULT_CONFIG_FILE}
}

# Save configuration
save_configuration() {
    print_step "3" "Saving configuration..."
    
    cat > "$CONFIG_FILE" << EOF
{
  "adlimen": {
    "version": "$INSTALLER_VERSION",
    "installedDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "projectRoot": "$PROJECT_ROOT",
    "languages": $(printf '%s\n' "${LANGUAGES[@]}" | jq -R . | jq -s .),
    "structure": {
      "frontendDir": "$FRONTEND_DIR",
      "backendDir": "$BACKEND_DIR"
    },
    "interface": "$PREFERRED_INTERFACE",
    "thresholds": {
      "complexity": $COMPLEXITY_THRESHOLD,
      "maintainability": $MAINTAINABILITY_THRESHOLD,
      "duplication": $DUPLICATION_THRESHOLD
    },
    "features": {
      "security": $ENABLE_SECURITY,
      "gitHooks": $ENABLE_GIT_HOOKS,
      "ciProvider": "$CI_PROVIDER"
    },
    "paths": {
      "configFile": "$CONFIG_FILE",
      "scriptsDir": "scripts/adlimen",
      "reportsDir": "reports",
      "eslintConfigsDir": ".eslint-configs"
    }
  }
}
EOF
    
    print_message "success" "Configuration saved to ${CONFIG_FILE}"
}

# Check prerequisites
check_prerequisites() {
    print_step "4" "Checking prerequisites..."
    
    local missing_tools=()
    
    # Check Node.js for JavaScript projects
    if [[ " ${LANGUAGES[@]} " =~ " javascript " ]]; then
        if ! command_exists node; then
            missing_tools+=("Node.js")
        fi
        if ! command_exists npm; then
            missing_tools+=("npm")
        fi
    fi
    
    # Check Python for Python projects
    if [[ " ${LANGUAGES[@]} " =~ " python " ]]; then
        if ! command_exists python3; then
            missing_tools+=("Python 3")
        fi
        if ! command_exists pip3; then
            missing_tools+=("pip3")
        fi
    fi
    
    # Check Make if needed
    if [ "$PREFERRED_INTERFACE" = "make" ] || [ "$PREFERRED_INTERFACE" = "both" ]; then
        if ! command_exists make; then
            missing_tools+=("GNU Make")
        fi
    fi
    
    # Check jq for JSON processing
    if ! command_exists jq; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_message "error" "Missing required tools: ${missing_tools[*]}"
        echo ""
        echo "Installation instructions:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "Node.js"|"npm") echo "  - Install Node.js from https://nodejs.org/" ;;
                "Python 3"|"pip3") echo "  - Install Python 3 from https://python.org/" ;;
                "GNU Make") echo "  - Install build tools (apt-get install build-essential / xcode-select --install)" ;;
                "jq") echo "  - Install jq: apt-get install jq / brew install jq" ;;
            esac
        done
        exit 1
    fi
    
    print_message "success" "All prerequisites satisfied"
}

# Install JavaScript/TypeScript quality system
install_javascript_system() {
    if [[ ! " ${LANGUAGES[@]} " =~ " javascript " ]]; then
        return
    fi
    
    print_step "5a" "Installing JavaScript/TypeScript quality system..."
    
    local target_dir="${FRONTEND_DIR:-$PROJECT_ROOT}"
    cd "$target_dir"
    
    # Create scripts directory
    mkdir -p scripts/adlimen
    
    # Copy quality scripts
    print_message "info" "Installing quality scripts..."
    
    # Here we would copy from the complete-quality-suite
    # For this installer, we'll create the essential files
    
    # Create quality-check.cjs
    cat > scripts/adlimen/quality-check.cjs << 'EOF'
#!/usr/bin/env node

/**
 * AdLimen Quality Code System - JavaScript/TypeScript Edition
 * Universal quality orchestrator
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// Load configuration
const loadConfig = () => {
  try {
    const configFile = fs.readFileSync('.adlimen.config.json', 'utf8');
    return JSON.parse(configFile).adlimen;
  } catch {
    return {
      thresholds: { complexity: 10, maintainability: 70, duplication: 5 },
      features: { security: true }
    };
  }
};

const config = loadConfig();

// Tool definitions with configurable thresholds
const tools = {
  prettier: {
    name: 'Prettier',
    description: 'Code formatting',
    commands: {
      check: ['npx', 'prettier', '--check', '.'],
      fix: ['npx', 'prettier', '--write', '.']
    }
  },
  'import-sorting': {
    name: 'Import Sorting',
    description: 'Import organization',
    commands: {
      check: ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.', '--config', '.eslint-configs/import-sorting.js'],
      fix: ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.', '--config', '.eslint-configs/import-sorting.js', '--fix']
    }
  },
  linting: {
    name: 'ESLint',
    description: 'Code quality linting',
    commands: {
      check: ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.'],
      fix: ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.', '--fix']
    }
  },
  'type-checking': {
    name: 'TypeScript',
    description: 'Type checking',
    commands: {
      check: ['npx', 'tsc', '--noEmit']
    }
  },
  security: {
    name: 'Security Analysis',
    description: 'Security vulnerability scanning',
    commands: {
      check: config.features.security ? ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.', '--config', '.eslint-configs/security.js'] : null
    }
  },
  'dead-code': {
    name: 'Dead Code Detection',
    description: 'Unused code detection',
    commands: {
      check: ['npx', 'ts-prune']
    }
  },
  duplication: {
    name: 'Code Duplication',
    description: 'Duplication analysis',
    commands: {
      check: ['npx', 'jscpd', '--min-lines', config.thresholds.duplication.toString(), '.']
    }
  },
  complexity: {
    name: 'Complexity Analysis',
    description: 'Cyclomatic complexity',
    commands: {
      check: ['npx', 'eslint', '--ext', '.ts,.tsx,.js,.jsx', '.', '--config', '.eslint-configs/complexity.js']
    }
  },
  maintainability: {
    name: 'Maintainability',
    description: 'Maintainability analysis',
    commands: {
      check: ['node', 'scripts/adlimen/maintainability-check.js', `--threshold=${config.thresholds.maintainability}`]
    }
  },
  'dependency-check': {
    name: 'Dependencies',
    description: 'Dependency analysis',
    commands: {
      check: ['npx', 'dependency-cruiser', '--validate', '.dependency-cruiser.cjs', '.']
    }
  }
};

// Quality suites
const suites = {
  all: Object.keys(tools),
  required: ['prettier', 'linting', 'type-checking'],
  security: ['security', 'vulnerability-checking'],
  analysis: ['dead-code', 'duplication', 'complexity', 'maintainability', 'dependency-check']
};

// Execute tool
const executeTool = async (toolName, shouldFix = false) => {
  const tool = tools[toolName];
  if (!tool) {
    console.error(`❌ Unknown tool: ${toolName}`);
    return false;
  }

  const command = shouldFix && tool.commands.fix ? tool.commands.fix : tool.commands.check;
  if (!command) {
    console.log(`ℹ️ ${tool.name}: No ${shouldFix ? 'fix' : 'check'} command available`);
    return true;
  }

  console.log(`🔍 ${tool.name}: ${tool.description}`);
  
  return new Promise((resolve) => {
    const process = spawn(command[0], command.slice(1), { stdio: 'inherit' });
    process.on('close', (code) => {
      if (code === 0) {
        console.log(`✅ ${tool.name}: Success`);
        resolve(true);
      } else {
        console.log(`❌ ${tool.name}: Failed (exit code ${code})`);
        resolve(false);
      }
    });
  });
};

// Main execution
const main = async () => {
  const args = process.argv.slice(2);
  const toolOrSuite = args[0];
  const shouldFix = args.includes('--fix');

  if (!toolOrSuite) {
    console.log('AdLimen Quality Code System - JavaScript/TypeScript Edition');
    console.log('Usage: node scripts/adlimen/quality-check.cjs <tool|suite> [--fix]');
    console.log('\nAvailable tools:', Object.keys(tools).join(', '));
    console.log('Available suites:', Object.keys(suites).join(', '));
    return;
  }

  let success = true;
  
  if (suites[toolOrSuite]) {
    console.log(`🚀 Running ${toolOrSuite} suite...`);
    for (const tool of suites[toolOrSuite]) {
      const result = await executeTool(tool, shouldFix);
      if (!result) success = false;
    }
  } else {
    success = await executeTool(toolOrSuite, shouldFix);
  }

  process.exit(success ? 0 : 1);
};

main().catch(console.error);
EOF

    chmod +x scripts/adlimen/quality-check.cjs
    
    # Install npm scripts if requested
    if [ "$PREFERRED_INTERFACE" = "npm" ] || [ "$PREFERRED_INTERFACE" = "both" ]; then
        print_message "info" "Installing npm scripts..."
        install_npm_scripts
    fi
    
    # Install Makefile if requested
    if [ "$PREFERRED_INTERFACE" = "make" ] || [ "$PREFERRED_INTERFACE" = "both" ]; then
        print_message "info" "Installing Makefile..."
        install_makefile
    fi
    
    # Install dependencies
    print_message "info" "Installing JavaScript dependencies..."
    npm install --save-dev \
        eslint@^9.0.0 \
        prettier@^3.1.0 \
        typescript@^5.4.0 \
        jscpd@^4.0.5 \
        ts-prune@^0.10.0 \
        dependency-cruiser@^16.0.0 \
        @typescript-eslint/eslint-plugin@^8.15.0 \
        @typescript-eslint/parser@^8.15.0 \
        eslint-plugin-import@^2.30.0 \
        eslint-plugin-security@^3.0.1 \
        eslint-plugin-sonarjs@^2.0.4 \
        typhonjs-escomplex-module@^0.1.0
    
    print_message "success" "JavaScript/TypeScript system installed"
    cd "$PROJECT_ROOT"
}

# Install npm scripts
install_npm_scripts() {
    if [ ! -f "package.json" ]; then
        print_message "warning" "No package.json found, creating basic one..."
        cat > package.json << EOF
{
  "name": "$(basename "$PROJECT_ROOT")",
  "version": "1.0.0",
  "private": true,
  "type": "module"
}
EOF
    fi
    
    # Update package.json with AdLimen scripts
    local temp_package=$(mktemp)
    jq '. + {
      "scripts": (.scripts // {} | . + {
        "adlimen:format": "node scripts/adlimen/quality-check.cjs prettier",
        "adlimen:format:fix": "node scripts/adlimen/quality-check.cjs prettier --fix",
        "adlimen:lint": "node scripts/adlimen/quality-check.cjs linting",
        "adlimen:lint:fix": "node scripts/adlimen/quality-check.cjs linting --fix",
        "adlimen:type-check": "node scripts/adlimen/quality-check.cjs type-checking",
        "adlimen:security": "node scripts/adlimen/quality-check.cjs security",
        "adlimen:quality": "node scripts/adlimen/quality-check.cjs all",
        "adlimen:quality:fix": "node scripts/adlimen/quality-check.cjs all --fix"
      })
    }' package.json > "$temp_package" && mv "$temp_package" package.json
}

# Install Makefile
install_makefile() {
    if [ -f "Makefile" ]; then
        print_message "warning" "Makefile exists, backing up as Makefile.bak"
        cp Makefile Makefile.bak
    fi
    
    cat > Makefile << 'EOF'
# AdLimen Quality Code System - Makefile Interface
.PHONY: help adlimen-quality adlimen-quality-fix adlimen-format adlimen-lint adlimen-type-check

help:
	@echo "AdLimen Quality Code System"
	@echo "Usage: make <target>"
	@echo ""
	@echo "Quality Targets:"
	@echo "  adlimen-quality       Run complete quality analysis"
	@echo "  adlimen-quality-fix   Run quality analysis with auto-fix"
	@echo "  adlimen-format        Code formatting check"
	@echo "  adlimen-format-fix    Code formatting with auto-fix"
	@echo "  adlimen-lint          Code quality linting"
	@echo "  adlimen-lint-fix      Code linting with auto-fix"
	@echo "  adlimen-type-check    TypeScript type checking"
	@echo "  adlimen-security      Security analysis"

adlimen-quality:
	@node scripts/adlimen/quality-check.cjs all

adlimen-quality-fix:
	@node scripts/adlimen/quality-check.cjs all --fix

adlimen-format:
	@node scripts/adlimen/quality-check.cjs prettier

adlimen-format-fix:
	@node scripts/adlimen/quality-check.cjs prettier --fix

adlimen-lint:
	@node scripts/adlimen/quality-check.cjs linting

adlimen-lint-fix:
	@node scripts/adlimen/quality-check.cjs linting --fix

adlimen-type-check:
	@node scripts/adlimen/quality-check.cjs type-checking

adlimen-security:
	@node scripts/adlimen/quality-check.cjs security
EOF
}

# Install Python quality system
install_python_system() {
    if [[ ! " ${LANGUAGES[@]} " =~ " python " ]]; then
        return
    fi
    
    print_step "5b" "Installing Python quality system..."
    
    local target_dir="${BACKEND_DIR:-$PROJECT_ROOT}"
    cd "$target_dir"
    
    # Create Python quality script
    mkdir -p scripts/adlimen
    
    cat > scripts/adlimen/python_quality_check.py << 'EOF'
#!/usr/bin/env python3
"""
AdLimen Quality Code System - Python Edition
Universal quality orchestrator for Python projects
"""

import sys
import subprocess
import json
import os
from pathlib import Path

def load_config():
    """Load AdLimen configuration"""
    try:
        with open('.adlimen.config.json', 'r') as f:
            return json.load(f)['adlimen']
    except:
        return {
            'thresholds': {'complexity': 10, 'maintainability': 70},
            'features': {'security': True}
        }

def run_tool(tool_name, command, description):
    """Run a quality tool"""
    print(f"🔍 {tool_name}: {description}")
    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        print(f"✅ {tool_name}: Success")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {tool_name}: Failed")
        if e.stdout:
            print(e.stdout)
        if e.stderr:
            print(e.stderr)
        return False

def main():
    """Main execution"""
    config = load_config()
    
    if len(sys.argv) < 2:
        print("AdLimen Quality Code System - Python Edition")
        print("Usage: python scripts/adlimen/python_quality_check.py <tool|suite>")
        print("\nAvailable tools: formatting, linting, type-checking, security, complexity")
        print("Available suites: all, required, security")
        return
    
    tool_or_suite = sys.argv[1]
    
    tools = {
        'formatting': (['black', '--check', '.'], 'Code formatting'),
        'linting': (['ruff', 'check', '.'], 'Code quality linting'),
        'type-checking': (['mypy', '.'], 'Type checking'),
        'security': (['bandit', '-r', '.'], 'Security analysis'),
        'complexity': (['radon', 'cc', '-s', '.'], 'Complexity analysis')
    }
    
    suites = {
        'all': list(tools.keys()),
        'required': ['formatting', 'linting', 'type-checking'],
        'security': ['security']
    }
    
    success = True
    
    if tool_or_suite in suites:
        print(f"🚀 Running {tool_or_suite} suite...")
        for tool in suites[tool_or_suite]:
            if tool in tools:
                cmd, desc = tools[tool]
                if not run_tool(tool, cmd, desc):
                    success = False
    elif tool_or_suite in tools:
        cmd, desc = tools[tool_or_suite]
        success = run_tool(tool_or_suite, cmd, desc)
    else:
        print(f"❌ Unknown tool or suite: {tool_or_suite}")
        success = False
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
EOF

    chmod +x scripts/adlimen/python_quality_check.py
    
    # Create requirements file for quality tools
    cat > requirements-adlimen.txt << EOF
# AdLimen Quality Code System - Python Dependencies
black>=23.0.0
ruff>=0.1.0
mypy>=1.7.0
bandit>=1.7.0
radon>=6.0.0
isort>=5.12.0
safety>=2.3.0
vulture>=2.10.0
EOF
    
    print_message "info" "Installing Python dependencies..."
    pip3 install -r requirements-adlimen.txt
    
    print_message "success" "Python system installed"
    cd "$PROJECT_ROOT"
}

# Setup CI/CD integration
setup_cicd_integration() {
    if [ -z "$CI_PROVIDER" ]; then
        return
    fi
    
    print_step "6" "Setting up CI/CD integration for $CI_PROVIDER..."
    
    case $CI_PROVIDER in
        "github")
            mkdir -p .github/workflows
            cat > .github/workflows/adlimen-quality.yml << 'EOF'
name: AdLimen Quality Checks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run AdLimen Quality Checks
      run: node scripts/adlimen/quality-check.cjs all
EOF
            print_message "success" "GitHub Actions workflow created"
            ;;
        "gitlab")
            cat > .gitlab-ci.yml << 'EOF'
# AdLimen Quality Code System - GitLab CI

stages:
  - quality

quality-check:
  stage: quality
  image: node:18
  script:
    - npm ci
    - node scripts/adlimen/quality-check.cjs all
  only:
    - main
    - develop
    - merge_requests
EOF
            print_message "success" "GitLab CI configuration created"
            ;;
        "circleci")
            mkdir -p .circleci
            cat > .circleci/config.yml << 'EOF'
version: 2.1

jobs:
  quality-check:
    docker:
      - image: node:18
    steps:
      - checkout
      - run: npm ci
      - run: node scripts/adlimen/quality-check.cjs all

workflows:
  version: 2
  quality:
    jobs:
      - quality-check
EOF
            print_message "success" "CircleCI configuration created"
            ;;
    esac
}

# Setup git hooks
setup_git_hooks() {
    if [ "$ENABLE_GIT_HOOKS" != "true" ]; then
        return
    fi
    
    print_step "7" "Setting up git hooks..."
    
    if command_exists npm && [ -f "package.json" ]; then
        npm install --save-dev husky lint-staged
        npx husky install
        
        # Pre-commit hook
        npx husky add .husky/pre-commit "node scripts/adlimen/quality-check.cjs required --fix"
        
        # Pre-push hook
        npx husky add .husky/pre-push "node scripts/adlimen/quality-check.cjs all"
        
        print_message "success" "Git hooks configured with Husky"
    else
        # Manual git hooks
        mkdir -p .git/hooks
        
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔍 Running AdLimen pre-commit checks..."
node scripts/adlimen/quality-check.cjs required --fix
EOF
        
        chmod +x .git/hooks/pre-commit
        print_message "success" "Manual git hooks configured"
    fi
}

# Generate documentation
generate_documentation() {
    print_step "8" "Generating documentation..."
    
    cat > ADLIMEN-README.md << EOF
# AdLimen Quality Code System

This project uses the AdLimen Quality Code System for comprehensive code quality assurance.

## Installed Configuration

- **Languages**: ${LANGUAGES[*]}
- **Frontend Directory**: ${FRONTEND_DIR:-N/A}
- **Backend Directory**: ${BACKEND_DIR:-N/A}
- **Interface**: ${PREFERRED_INTERFACE}
- **Security Scanning**: ${ENABLE_SECURITY}
- **Git Hooks**: ${ENABLE_GIT_HOOKS}
- **CI/CD Provider**: ${CI_PROVIDER:-None}

## Quality Thresholds

- **Complexity**: ${COMPLEXITY_THRESHOLD}
- **Maintainability**: ${MAINTAINABILITY_THRESHOLD}
- **Duplication**: ${DUPLICATION_THRESHOLD} lines

## Usage

### npm Scripts Interface
\`\`\`bash
npm run adlimen:quality              # Complete quality analysis
npm run adlimen:quality:fix          # Quality analysis with auto-fix
npm run adlimen:format               # Code formatting
npm run adlimen:lint                 # Code linting
npm run adlimen:type-check           # Type checking
npm run adlimen:security             # Security analysis
\`\`\`

### Make Interface
\`\`\`bash
make adlimen-quality                 # Complete quality analysis
make adlimen-quality-fix             # Quality analysis with auto-fix
make adlimen-format                  # Code formatting
make adlimen-lint                    # Code linting
\`\`\`

### Direct Execution
\`\`\`bash
# JavaScript/TypeScript
node scripts/adlimen/quality-check.cjs all
node scripts/adlimen/quality-check.cjs all --fix

# Python
python scripts/adlimen/python_quality_check.py all
\`\`\`

## Configuration

Configuration is stored in \`${CONFIG_FILE}\`. Modify thresholds and settings as needed.

## Support

For help with the AdLimen Quality Code System:
- Check the configuration in \`${CONFIG_FILE}\`
- Review available commands with \`node scripts/adlimen/quality-check.cjs\`
- Visit: https://github.com/matteocervelli/adlimen-quality-system

---

**Installed**: $(date)  
**Version**: ${INSTALLER_VERSION}  
**AdLimen Quality Code System**: Transform your codebase with enterprise-grade quality controls
EOF
    
    print_message "success" "Documentation generated: ADLIMEN-README.md"
}

# Print installation summary
print_summary() {
    echo ""
    echo -e "${GREEN}${SUCCESS}${NC} ${WHITE}AdLimen Quality Code System installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}Installation Summary:${NC}"
    echo "  • Languages: ${LANGUAGES[*]}"
    echo "  • Interface: ${PREFERRED_INTERFACE}"
    echo "  • Configuration: ${CONFIG_FILE}"
    echo "  • Scripts: scripts/adlimen/"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    
    if [ "$PREFERRED_INTERFACE" = "npm" ] || [ "$PREFERRED_INTERFACE" = "both" ]; then
        echo "  • npm run adlimen:quality"
    fi
    
    if [ "$PREFERRED_INTERFACE" = "make" ] || [ "$PREFERRED_INTERFACE" = "both" ]; then
        echo "  • make adlimen-quality"
    fi
    
    echo "  • node scripts/adlimen/quality-check.cjs all"
    echo ""
    echo -e "${CYAN}📖 Documentation: ADLIMEN-README.md${NC}"
    echo -e "${PURPLE}🚀 Transform your codebase with enterprise-grade quality controls${NC}"
}

#####################################################################
# Main Installation Flow
#####################################################################

main() {
    print_header
    
    detect_project_structure
    interactive_configuration
    save_configuration
    check_prerequisites
    
    install_javascript_system
    install_python_system
    setup_cicd_integration
    setup_git_hooks
    generate_documentation
    
    print_summary
}

# Error handling
trap 'print_message "error" "Installation failed. Check the error messages above."; exit 1' ERR

# Run main installation
main "$@"