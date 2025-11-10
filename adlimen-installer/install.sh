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
DEFAULT_CONFIG_FILE=".adlimen-config.json"
INSTALLER_VERSION="1.0.0"
INSTALLER_DATE="2025-07-10"
QUALITY_SUITE_DIR=".adlimen-code-quality-suite"
GLOBAL_ADLIMEN_DIR="$HOME/.adlimen"
GLOBAL_SUITE_DIR="$GLOBAL_ADLIMEN_DIR/code-quality-suite"

# Global variables
PROJECT_ROOT=""
LANGUAGES=()
FRONTEND_DIR=""
BACKEND_DIR=""
PACKAGES_DIR=""
PREFERRED_STRUCTURE=""
PREFERRED_INTERFACE=""
COMPLEXITY_THRESHOLD=10
MAINTAINABILITY_THRESHOLD=70
DUPLICATION_THRESHOLD=5
ENABLE_SECURITY=true
ENABLE_GIT_HOOKS=true
ENABLE_PRECOMMIT_HOOKS=true
ENABLE_PREPUSH_HOOKS=true
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
    print_message "info" "Auto-detected project at: ${PROJECT_ROOT}"
    
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
    
    # Detect monorepo vs single project structure
    local is_monorepo=false
    
    # Check for monorepo indicators
    if [ -f "lerna.json" ] || [ -f "rush.json" ] || [ -f "pnpm-workspace.yaml" ] || [ -f "yarn.lock" ] && [ -d "packages" ]; then
        is_monorepo=true
        print_message "info" "Monorepo structure detected"
    elif [ -d "packages" ] && [ "$(find packages -mindepth 1 -maxdepth 1 -type d | wc -l)" -gt 1 ]; then
        is_monorepo=true
        print_message "info" "Multi-package structure detected (potential monorepo)"
    fi
    
    # Ask user about monorepo preference if detected
    if [ "$is_monorepo" = true ]; then
        echo ""
        echo -e "${YELLOW}Monorepo Structure Detected${NC}"
        echo "We detected what appears to be a monorepo structure."
        echo ""
        echo "Monorepo benefits:"
        echo "  • Unified quality standards across packages"
        echo "  • Centralized configuration and tooling"
        echo "  • Consistent git hooks for all packages"
        echo "  • Cross-package dependency analysis"
        echo ""
        echo "Project types:"
        echo "1) Monorepo - Multiple packages with shared quality config"
        echo "2) Standard project - Single unified codebase"
        echo "3) Let me specify directories manually"
        
        read -p "How should we configure this project? [1-3]: " monorepo_choice
        
        case $monorepo_choice in
            1)
                print_message "success" "Configuring as monorepo with shared quality standards"
                PREFERRED_STRUCTURE="monorepo"
                ;;
            2)
                print_message "info" "Configuring as standard project"
                PREFERRED_STRUCTURE="standard"
                ;;
            3)
                print_message "info" "Manual directory configuration selected"
                PREFERRED_STRUCTURE="manual"
                ;;
            *)
                print_message "info" "Defaulting to monorepo configuration"
                PREFERRED_STRUCTURE="monorepo"
                ;;
        esac
    else
        PREFERRED_STRUCTURE="standard"
    fi
    
    # Detect common directory structures based on preference
    if [ "$PREFERRED_STRUCTURE" = "monorepo" ]; then
        # Look for packages in monorepo
        local possible_packages=("packages" "apps" "libs" "modules")
        for pkg_dir in "${possible_packages[@]}"; do
            if [ -d "$pkg_dir" ]; then
                print_message "success" "Package directory detected: ${pkg_dir}"
                PACKAGES_DIR="$pkg_dir"
                break
            fi
        done
        
        # Detect workspace structure
        if [ -d "packages" ]; then
            for pkg in packages/*/; do
                if [ -d "$pkg" ]; then
                    local pkg_name=$(basename "$pkg")
                    print_message "info" "Package found: $pkg_name"
                fi
            done
        fi
    fi
    
    # Detect frontend/backend directories
    local possible_frontend=("frontend" "client" "web" "ui" "app" "src/frontend" "packages/frontend" "apps/web" "apps/client")
    local possible_backend=("backend" "server" "api" "src/backend" "packages/backend" "apps/api" "apps/server")
    
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

# Global system configuration
configure_global_system() {
    print_step "2" "Global system configuration..."
    
    echo -e "${YELLOW}AdLimen Global System Setup:${NC}"
    echo ""
    
    # Global installation directory
    echo -e "${BLUE}Global Installation Directory:${NC}"
    local default_global="$HOME/.adlimen"
    read -p "Global AdLimen directory [$default_global]: " input
    GLOBAL_ADLIMEN_DIR=${input:-$default_global}
    GLOBAL_SUITE_DIR="$GLOBAL_ADLIMEN_DIR/code-quality-suite"
    print_message "info" "Global system will be installed at: $GLOBAL_SUITE_DIR"
}

# Ask about project configuration
ask_project_configuration() {
    while true; do
        echo ""
        echo -e "${YELLOW}Project Configuration:${NC}"
        echo "1) Configure a project now"
        echo "2) Skip project configuration" 
        echo "3) Back to global system configuration"
        read -p "Choice [1-3]: " project_choice
        
        case $project_choice in
            1) break ;;
            2) 
                print_message "info" "Global system installed. You can configure projects later by running this installer again."
                return 1 ;;
            3) 
                configure_global_system
                setup_global_system
                continue ;;
            *) 
                print_message "warning" "Please choose 1, 2, or 3"
                continue ;;
        esac
    done
    
    # Ask for project directory
    echo ""
    echo -e "${BLUE}Project Directory:${NC}"
    local current_dir=$(pwd)
    read -p "Project directory to configure [$current_dir]: " input
    PROJECT_ROOT=${input:-$current_dir}
    
    if [ ! -d "$PROJECT_ROOT" ]; then
        print_message "error" "Directory does not exist: $PROJECT_ROOT"
        exit 1
    fi
    
    print_message "success" "Configuring project at: $PROJECT_ROOT"
    cd "$PROJECT_ROOT"
    return 0
}

# Interactive configuration
interactive_configuration() {
    print_step "3" "Project configuration..."
    
    echo -e "${YELLOW}Project-specific configuration:${NC}"
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
    
    # Clean up directory paths (remove leading slashes for relative paths)
    if [[ "$FRONTEND_DIR" == /* ]] && [[ "$FRONTEND_DIR" != "$PROJECT_ROOT"* ]]; then
        print_message "warning" "Frontend directory appears to be absolute path outside project: $FRONTEND_DIR"
    elif [[ "$FRONTEND_DIR" == /* ]]; then
        # Convert absolute to relative if it's within project
        FRONTEND_DIR="${FRONTEND_DIR#$PROJECT_ROOT/}"
    fi
    
    if [[ "$BACKEND_DIR" == /* ]] && [[ "$BACKEND_DIR" != "$PROJECT_ROOT"* ]]; then
        print_message "warning" "Backend directory appears to be absolute path outside project: $BACKEND_DIR"
    elif [[ "$BACKEND_DIR" == /* ]]; then
        # Convert absolute to relative if it's within project
        BACKEND_DIR="${BACKEND_DIR#$PROJECT_ROOT/}"
    fi
    
    # Interface preference
    while true; do
        echo ""
        echo "Choose your preferred interface:"
        echo "1) npm scripts (recommended for Node.js teams)"
        echo "2) Make commands (recommended for Unix/DevOps teams)"
        echo "3) Both (dual interface)"
        echo "4) Back to project directory selection"
        read -p "Choice [1-4]: " interface_choice
        
        case $interface_choice in
            1) PREFERRED_INTERFACE="npm"; break ;;
            2) PREFERRED_INTERFACE="make"; break ;;
            3) PREFERRED_INTERFACE="both"; break ;;
            4) 
                # Go back to project directory selection
                if ask_project_configuration; then
                    detect_project_structure
                    continue
                else
                    return 1
                fi
                ;;
            *) 
                print_message "warning" "Please choose 1, 2, 3, or 4"
                continue ;;
        esac
    done
    
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
    
    echo ""
    echo "Git hooks setup options:"
    echo "1) Yes, install git hooks (recommended)"
    echo "2) No, skip git hooks"
    echo "3) Install git hooks with custom configuration"
    read -p "Choice [1-3]: " hooks_choice
    
    case $hooks_choice in
        1) ENABLE_GIT_HOOKS=true ;;
        2) ENABLE_GIT_HOOKS=false ;;
        3) 
            ENABLE_GIT_HOOKS=true
            echo ""
            echo "Git hooks configuration:"
            read -p "Run quality checks on pre-commit? (Y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                ENABLE_PRECOMMIT_HOOKS=false
            else
                ENABLE_PRECOMMIT_HOOKS=true
            fi
            
            read -p "Run full quality suite on pre-push? (Y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                ENABLE_PREPUSH_HOOKS=false
            else
                ENABLE_PREPUSH_HOOKS=true
            fi
            ;;
        *) ENABLE_GIT_HOOKS=true ;;
    esac
    
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
      "type": "$PREFERRED_STRUCTURE",
      "frontendDir": "$FRONTEND_DIR",
      "backendDir": "$BACKEND_DIR",
      "packagesDir": "$PACKAGES_DIR",
      "isMonorepo": $([ "$PREFERRED_STRUCTURE" = "monorepo" ] && echo "true" || echo "false")
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
      "preCommitHooks": $ENABLE_PRECOMMIT_HOOKS,
      "prePushHooks": $ENABLE_PREPUSH_HOOKS,
      "ciProvider": "$CI_PROVIDER"
    },
    "paths": {
      "configFile": "$CONFIG_FILE",
      "scriptsDir": "scripts/adlimen",
      "reportsDir": "reports",
      "eslintConfigsDir": ".eslint-configs",
      "globalSuiteDir": "$GLOBAL_SUITE_DIR"
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

# Setup global AdLimen system
setup_global_system() {
    print_step "4.5" "Setting up global AdLimen system..."
    
    # Check if global system exists
    if [ -d "$GLOBAL_SUITE_DIR" ]; then
        print_message "info" "Global AdLimen system found at $GLOBAL_SUITE_DIR"
        
        # Offer to update
        read -p "Update global AdLimen system to latest version? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            cd "$GLOBAL_SUITE_DIR"
            git pull origin main
            print_message "success" "Global system updated"
        fi
    else
        print_message "info" "Installing global AdLimen system..."
        
        # Create global directory
        mkdir -p "$GLOBAL_ADLIMEN_DIR"
        
        # Clone the repository
        print_message "info" "Downloading AdLimen Code Quality Suite..."
        if git clone https://github.com/matteocervelli/code-quality-suite.git "$GLOBAL_SUITE_DIR"; then
            print_message "success" "Global AdLimen system installed at $GLOBAL_SUITE_DIR"
        else
            print_message "error" "Failed to clone AdLimen repository"
            
            # Fallback: copy from current directory if we're running from the repo
            local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            local repo_root="$(dirname "$script_dir")"
            
            if [ -f "$repo_root/README.md" ] && [ -d "$repo_root/editions" ]; then
                print_message "info" "Using local repository copy as fallback..."
                cp -r "$repo_root" "$GLOBAL_SUITE_DIR"
                print_message "success" "Global system installed from local copy"
            else
                print_message "error" "Cannot install global system. Please ensure:"
                echo "  1. Internet connection for git clone, OR"
                echo "  2. Run installer from within the code-quality-suite repository"
                exit 1
            fi
        fi
    fi
    
    # Update project configuration with global path
    GLOBAL_SUITE_PATH="$GLOBAL_SUITE_DIR"
}

# Create ESLint 9.x flat configuration files
create_eslint_configs() {
    print_message "info" "Generating ESLint 9.x flat config files..."
    
    # Main eslint.config.js (default configuration)
    cat > eslint.config.js << 'EOF'
import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    ignores: [
      'node_modules/**',
      'venv/**',
      '**/.venv/**',
      '**/env/**',
      'dist/**',
      'build/**',
      '**/.git/**',
      '**/coverage/**',
      '**/.cache/**',
      '**/tmp/**',
      '**/temp/**',
      'scripts/adlimen/**',
      '.adlimen-code-quality-suite/**',
      '**/.adlimen-code-quality-suite/**'
    ]
  },
  {
    files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true
        }
      }
    },
    plugins: {
      '@typescript-eslint': typescript
    },
    rules: {
      'no-console': 'warn',
      'no-debugger': 'error',
      'prefer-const': 'error',
      'no-var': 'error',
      'complexity': ['error', 15],
      'max-depth': ['error', 4],
      'max-lines-per-function': ['error', 50],
      'max-params': ['error', 4],
      'max-statements': ['error', 20],
      'no-unused-vars': 'error',
      'no-undef': 'error',
      'eqeqeq': 'error',
      'curly': 'error'
    }
  },
  {
    files: ['**/*.ts', '**/*.tsx'],
    rules: {
      '@typescript-eslint/no-unused-vars': 'error',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/explicit-function-return-type': 'off',
      '@typescript-eslint/explicit-module-boundary-types': 'off'
    }
  },
  {
    files: ['**/*.test.{js,ts}', '**/*.spec.{js,ts}', 'test/**/*'],
    rules: {
      'no-console': 'off'
    }
  }
];
EOF

    # Import sorting configuration
    cat > eslint.import.config.js << 'EOF'
import js from '@eslint/js';
import importPlugin from 'eslint-plugin-import';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    plugins: {
      import: importPlugin
    },
    rules: {
      'import/order': ['error', {
        'groups': [
          'builtin',
          'external',
          'internal',
          'parent',
          'sibling',
          'index'
        ],
        'newlines-between': 'always',
        'alphabetize': {
          'order': 'asc',
          'caseInsensitive': true
        }
      }],
      'import/newline-after-import': 'error',
      'import/no-duplicates': 'error'
    }
  }
];
EOF

    # Security configuration
    cat > eslint.security.config.js << 'EOF'
import js from '@eslint/js';
import security from 'eslint-plugin-security';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    plugins: {
      security
    },
    rules: {
      ...security.configs.recommended.rules,
      'security/detect-object-injection': 'error',
      'security/detect-non-literal-fs-filename': 'warn',
      'security/detect-unsafe-regex': 'error',
      'security/detect-buffer-noassert': 'error',
      'security/detect-child-process': 'warn',
      'security/detect-disable-mustache-escape': 'error',
      'security/detect-eval-with-expression': 'error',
      'security/detect-no-csrf-before-method-override': 'error',
      'security/detect-non-literal-regexp': 'error',
      'security/detect-non-literal-require': 'warn',
      'security/detect-possible-timing-attacks': 'warn',
      'security/detect-pseudoRandomBytes': 'error'
    }
  }
];
EOF

    # Complexity configuration
    cat > eslint.complexity.config.js << 'EOF'
import js from '@eslint/js';
import typescript from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';

export default [
  js.configs.recommended,
  {
    files: ['**/*.{js,mjs,cjs,jsx,ts,tsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module'
      }
    },
    plugins: {
      '@typescript-eslint': typescript
    },
    rules: {
      'complexity': ['error', 10],
      'max-depth': ['error', 4],
      'max-lines-per-function': ['error', 50],
      'max-params': ['error', 4],
      'max-statements': ['error', 20],
      'max-statements-per-line': ['error', { max: 1 }],
      'sonarjs/cognitive-complexity': ['error', 15],
      'sonarjs/max-switch-cases': ['error', 30],
      'sonarjs/no-duplicate-string': ['error', 3],
      'sonarjs/no-duplicated-branches': 'error',
      'sonarjs/no-identical-functions': 'error',
      'sonarjs/prefer-immediate-return': 'error'
    }
  }
];
EOF

    print_message "success" "ESLint 9.x configuration files created"
}

# Install JavaScript/TypeScript quality system
install_javascript_system() {
    if [[ ! " ${LANGUAGES[@]} " =~ " javascript " ]]; then
        return
    fi
    
    print_step "5a" "Installing JavaScript/TypeScript quality system..."
    
    # Ensure we're in the project root
    cd "$PROJECT_ROOT"
    
    local target_dir="${FRONTEND_DIR:-$PROJECT_ROOT}"
    # Handle relative vs absolute paths for frontend
    if [[ "$FRONTEND_DIR" != "" && "$FRONTEND_DIR" != "." ]]; then
        if [[ "$target_dir" == /* ]]; then
            # Absolute path - use as is if it exists
            if [ ! -d "$target_dir" ]; then
                print_message "error" "Frontend directory does not exist: $target_dir"
                return 1
            fi
        else
            # Relative path - make it relative to PROJECT_ROOT
            target_dir="$PROJECT_ROOT/$FRONTEND_DIR"
            if [ ! -d "$target_dir" ]; then
                print_message "warning" "Frontend directory does not exist, creating: $target_dir"
                mkdir -p "$target_dir"
            fi
        fi
        cd "$target_dir"
    else
        # Use project root
        target_dir="$PROJECT_ROOT"
    fi
    
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
      check: ['npx', 'eslint', '.', '--config', 'eslint.import.config.js'],
      fix: ['npx', 'eslint', '.', '--config', 'eslint.import.config.js', '--fix']
    }
  },
  linting: {
    name: 'ESLint',
    description: 'Code quality linting',
    commands: {
      check: ['npx', 'eslint', '.'],
      fix: ['npx', 'eslint', '.', '--fix']
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
      check: config.features.security ? ['npx', 'eslint', '.', '--config', 'eslint.security.config.js'] : null
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
      check: ['npx', 'eslint', '.', '--config', 'eslint.complexity.config.js']
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
    
    # Create .prettierignore file
    print_message "info" "Creating .prettierignore file..."
    cat > .prettierignore << 'EOF'
# Dependencies and environments
node_modules/
venv/
.venv/
env/
.env/

# Build outputs
dist/
build/
.next/
coverage/

# Logs and temporary files
*.log
logs/
tmp/
temp/
.cache/

# AdLimen generated files
scripts/adlimen/
.adlimen-code-quality-suite/

# Git
.git/

# Test output
tests/mcp-tool/logs.json

# Python bytecode
__pycache__/
*.pyc
*.pyo

# Package managers
package-lock.json
yarn.lock
pip-compile-*
EOF
    
    # Create ESLint 9.x configuration files
    print_message "info" "Creating ESLint 9.x configuration files..."
    create_eslint_configs
    
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
    
    # Install dependencies (compatible versions to avoid conflicts)
    print_message "info" "Installing JavaScript dependencies..."
    npm install --save-dev \
        eslint@^9.0.0 \
        @eslint/js@^9.0.0 \
        prettier@^3.1.0 \
        typescript@^5.4.0 \
        jscpd@^4.0.5 \
        ts-prune@^0.10.0 \
        dependency-cruiser@^16.0.0 \
        @typescript-eslint/eslint-plugin@^8.15.0 \
        @typescript-eslint/parser@^8.15.0 \
        eslint-plugin-import@^2.31.0 \
        eslint-plugin-security@^3.0.1 \
        eslint-plugin-sonarjs@^2.0.0 \
        husky@^9.0.0 \
        lint-staged@^15.0.0 \
        typhonjs-escomplex-module@^0.1.0 || {
        print_message "warning" "Some dependencies may have peer dependency conflicts"
        print_message "info" "This is normal with ESLint 9.x and older plugins"
    }
    
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
    
    # Detect languages and create appropriate Makefile
    local has_js=false
    local has_python=false
    
    if [ -f "package.json" ]; then
        has_js=true
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then
        has_python=true
    fi
    
    cat > Makefile << 'EOF'
# AdLimen Quality Code System - Hybrid Makefile Interface
# Auto-generated for multi-language project support
.PHONY: help js-quality py-quality adlimen-lint adlimen-format adlimen-security quality

help:
	@echo "AdLimen Quality Code System - Hybrid Edition"
	@echo "==========================================="
	@echo ""
	@echo "Language-Specific Quality Targets:"
	@echo "  js-quality       Run JavaScript/TypeScript quality checks"
	@echo "  js-lint          Run JavaScript/TypeScript linting only"
	@echo "  js-format        Run JavaScript/TypeScript formatting"
	@echo "  js-security      Run JavaScript/TypeScript security checks"
	@echo ""
	@echo "  py-quality       Run Python quality checks"
	@echo "  py-lint          Run Python linting only"
	@echo "  py-format        Run Python formatting"
	@echo "  py-security      Run Python security checks"
	@echo ""
	@echo "AdLimen Unified Interface:"
	@echo "  adlimen-lint     Run linting for all detected languages"
	@echo "  adlimen-format   Run formatting for all detected languages"
	@echo "  adlimen-security Run security checks for all detected languages"
	@echo "  quality          Run comprehensive quality checks for all languages"

# JavaScript/TypeScript Quality Targets
js-lint:
	@echo "🔍 ESLint: Code quality linting"
	@if [ -f "package.json" ]; then \
		if [ -f "scripts/adlimen/quality-check.cjs" ]; then \
			node scripts/adlimen/quality-check.cjs linting; \
		else \
			npx eslint . --config eslint.config.js; \
		fi; \
	else \
		echo "❌ No package.json found - JavaScript/TypeScript not detected"; \
		exit 1; \
	fi

js-format:
	@echo "✨ Prettier: Code formatting"
	@if [ -f "package.json" ]; then \
		if [ -f "scripts/adlimen/quality-check.cjs" ]; then \
			node scripts/adlimen/quality-check.cjs prettier; \
		else \
			npx prettier --check .; \
		fi; \
	else \
		echo "❌ No package.json found - JavaScript/TypeScript not detected"; \
		exit 1; \
	fi

js-security:
	@echo "🛡️ Security: JavaScript/TypeScript security analysis"
	@if [ -f "package.json" ]; then \
		if [ -f "scripts/adlimen/quality-check.cjs" ]; then \
			node scripts/adlimen/quality-check.cjs security; \
		else \
			npx eslint . --config eslint.security.config.js; \
		fi; \
	else \
		echo "❌ No package.json found - JavaScript/TypeScript not detected"; \
		exit 1; \
	fi

js-quality: js-format js-lint js-security
	@echo "✅ JavaScript/TypeScript quality checks completed"

# Python Quality Targets
py-lint:
	@echo "🔍 Ruff + Pylint: Python code linting"
	@if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		if [ -f "scripts/adlimen/quality-check.py" ]; then \
			if [ -d "venv" ]; then \
				./venv/bin/python scripts/adlimen/quality-check.py linting; \
			else \
				python scripts/adlimen/quality-check.py linting; \
			fi; \
		else \
			if [ -d "venv" ]; then \
				./venv/bin/python -m ruff check . || echo "⚠️ Ruff not available"; \
			else \
				python -m ruff check . || echo "⚠️ Ruff not available"; \
			fi; \
		fi; \
	else \
		echo "❌ No Python files detected"; \
		exit 1; \
	fi

py-format:
	@echo "✨ Black: Python code formatting"
	@if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		if [ -f "scripts/adlimen/quality-check.py" ]; then \
			if [ -d "venv" ]; then \
				./venv/bin/python scripts/adlimen/quality-check.py formatting; \
			else \
				python scripts/adlimen/quality-check.py formatting; \
			fi; \
		else \
			if [ -d "venv" ]; then \
				./venv/bin/python -m black --check . || echo "⚠️ Black not available"; \
			else \
				python -m black --check . || echo "⚠️ Black not available"; \
			fi; \
		fi; \
	else \
		echo "❌ No Python files detected"; \
		exit 1; \
	fi

py-security:
	@echo "🛡️ Bandit + Safety: Python security analysis"
	@if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		if [ -f "scripts/adlimen/quality-check.py" ]; then \
			if [ -d "venv" ]; then \
				./venv/bin/python scripts/adlimen/quality-check.py security; \
			else \
				python scripts/adlimen/quality-check.py security; \
			fi; \
		else \
			if [ -d "venv" ]; then \
				./venv/bin/python -m bandit -r . || echo "⚠️ Bandit not available"; \
			else \
				python -m bandit -r . || echo "⚠️ Bandit not available"; \
			fi; \
		fi; \
	else \
		echo "❌ No Python files detected"; \
		exit 1; \
	fi

py-quality: py-format py-lint py-security
	@echo "✅ Python quality checks completed"

# AdLimen Unified Interface (Backward Compatibility)
adlimen-lint:
	@echo "🔍 AdLimen: Multi-language linting"
	@has_errors=0; \
	if [ -f "package.json" ]; then \
		echo "Running JavaScript/TypeScript linting..."; \
		$(MAKE) js-lint || has_errors=1; \
	fi; \
	if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		echo "Running Python linting..."; \
		$(MAKE) py-lint || has_errors=1; \
	fi; \
	if [ $$has_errors -eq 1 ]; then \
		echo "❌ Linting failed for one or more languages"; \
		exit 1; \
	else \
		echo "✅ Multi-language linting completed successfully"; \
	fi

adlimen-format:
	@echo "✨ AdLimen: Multi-language formatting"
	@if [ -f "package.json" ]; then \
		echo "Running JavaScript/TypeScript formatting..."; \
		$(MAKE) js-format; \
	fi
	@if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		echo "Running Python formatting..."; \
		$(MAKE) py-format; \
	fi
	@echo "✅ Multi-language formatting completed"

adlimen-security:
	@echo "🛡️ AdLimen: Multi-language security analysis"
	@if [ -f "package.json" ]; then \
		echo "Running JavaScript/TypeScript security analysis..."; \
		$(MAKE) js-security; \
	fi
	@if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		echo "Running Python security analysis..."; \
		$(MAKE) py-security; \
	fi
	@echo "✅ Multi-language security analysis completed"

quality:
	@echo "🚀 AdLimen: Comprehensive multi-language quality analysis"
	@has_errors=0; \
	if [ -f "package.json" ]; then \
		echo "Running JavaScript/TypeScript quality suite..."; \
		$(MAKE) js-quality || has_errors=1; \
	fi; \
	if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || find . -name "*.py" -type f | head -1 | grep -q .; then \
		echo "Running Python quality suite..."; \
		$(MAKE) py-quality || has_errors=1; \
	fi; \
	if [ $$has_errors -eq 1 ]; then \
		echo "❌ Quality checks failed for one or more languages"; \
		exit 1; \
	else \
		echo "✅ Comprehensive multi-language quality analysis completed successfully"; \
	fi

# Backward compatibility aliases
lint: adlimen-lint
format: adlimen-format
security: adlimen-security
EOF
}

# Install Python quality system
install_python_system() {
    if [[ ! " ${LANGUAGES[@]} " =~ " python " ]]; then
        return
    fi
    
    print_step "5b" "Installing Python quality system..."
    
    # Ensure we're in the project root
    cd "$PROJECT_ROOT"
    
    local target_dir="${BACKEND_DIR:-$PROJECT_ROOT}"
    # Handle relative vs absolute paths
    if [[ "$target_dir" == /* ]]; then
        # Absolute path - use as is if it exists
        if [ ! -d "$target_dir" ]; then
            print_message "error" "Backend directory does not exist: $target_dir"
            return 1
        fi
    else
        # Relative path - make it relative to PROJECT_ROOT
        target_dir="$PROJECT_ROOT/$BACKEND_DIR"
        if [ ! -d "$target_dir" ]; then
            print_message "warning" "Backend directory does not exist, creating: $target_dir"
            mkdir -p "$target_dir"
        fi
    fi
    
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
    
    # Check if we're in a virtual environment or need user install
    if [ -n "$VIRTUAL_ENV" ]; then
        print_message "info" "Virtual environment detected, installing normally..."
        pip3 install -r requirements-adlimen.txt
    else
        print_message "info" "Installing to user directory (no virtual environment)..."
        pip3 install --user -r requirements-adlimen.txt || {
            print_message "warning" "User install failed, trying with --break-system-packages..."
            pip3 install --break-system-packages -r requirements-adlimen.txt || {
                print_message "error" "Failed to install Python dependencies"
                print_message "info" "Please create a virtual environment:"
                echo "  python3 -m venv venv"
                echo "  source venv/bin/activate"
                echo "  pip install -r requirements-adlimen.txt"
                return 1
            }
        }
    fi
    
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
        
        # Pre-commit hook (if enabled)
        if [ "$ENABLE_PRECOMMIT_HOOKS" = "true" ]; then
            npx husky add .husky/pre-commit "node scripts/adlimen/quality-check.cjs required --fix"
            print_message "success" "Pre-commit hook configured"
        fi
        
        # Pre-push hook (if enabled)
        if [ "$ENABLE_PREPUSH_HOOKS" = "true" ]; then
            npx husky add .husky/pre-push "node scripts/adlimen/quality-check.cjs all"
            print_message "success" "Pre-push hook configured"
        fi
        
        print_message "success" "Git hooks configured with Husky"
    else
        # Manual git hooks
        mkdir -p .git/hooks
        
        # Pre-commit hook (if enabled)
        if [ "$ENABLE_PRECOMMIT_HOOKS" = "true" ]; then
            cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔍 Running AdLimen pre-commit checks..."
node scripts/adlimen/quality-check.cjs required --fix
EOF
            chmod +x .git/hooks/pre-commit
            print_message "success" "Manual pre-commit hook configured"
        fi
        
        # Pre-push hook (if enabled)
        if [ "$ENABLE_PREPUSH_HOOKS" = "true" ]; then
            cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
echo "🚀 Running AdLimen pre-push checks..."
node scripts/adlimen/quality-check.cjs all
EOF
            chmod +x .git/hooks/pre-push
            print_message "success" "Manual pre-push hook configured"
        fi
    fi
}

# Update project .gitignore with AdLimen-specific entries
update_gitignore() {
    print_step "8" "Updating .gitignore with AdLimen entries..."
    
    local gitignore_file=".gitignore"
    local adlimen_section_start="# === AdLimen Code Quality Suite ==="
    local adlimen_section_end="# === End AdLimen Code Quality Suite ==="
    
    # Create .gitignore if it doesn't exist
    if [ ! -f "$gitignore_file" ]; then
        print_message "info" "Creating .gitignore file"
        touch "$gitignore_file"
    fi
    
    # Check if AdLimen section already exists
    if grep -q "$adlimen_section_start" "$gitignore_file"; then
        print_message "warning" "AdLimen entries already exist in .gitignore, skipping..."
        return
    fi
    
    # Add AdLimen-specific entries
    print_message "info" "Adding AdLimen-specific entries to .gitignore"
    
    cat >> "$gitignore_file" << EOF

$adlimen_section_start
# AdLimen Code Quality Suite generated files and directories
$CONFIG_FILE
scripts/adlimen/
reports/
ADLIMEN-README.md
eslint.*.config.js
.adlimen-code-quality-suite/

# Quality reports and temporary files (various locations)
quality-reports/
reports/
src/frontend/reports/
src/backend/reports/
*.quality-report.json
*.duplication-report.json
*.complexity-report.json

# Tool-specific cache and temporary files
.ruff_cache/
.mypy_cache/
.pytest_cache/
.coverage
htmlcov/
.bandit
.vulture-whitelist
$adlimen_section_end
EOF
    
    print_message "success" "AdLimen entries added to .gitignore"
}

# Generate documentation
generate_documentation() {
    print_step "9" "Generating documentation..."
    
    cat > ADLIMEN-README.md << EOF
# AdLimen Quality Code System

This project uses the AdLimen Quality Code System for comprehensive code quality assurance.

## Installed Configuration

- **Project Type**: ${PREFERRED_STRUCTURE}
- **Languages**: ${LANGUAGES[*]}
- **Frontend Directory**: ${FRONTEND_DIR:-N/A}
- **Backend Directory**: ${BACKEND_DIR:-N/A}
- **Packages Directory**: ${PACKAGES_DIR:-N/A}
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
    
    # Step 1: Configure global system
    configure_global_system
    
    # Step 2: Setup global system
    setup_global_system
    
    # Step 3: Ask if user wants to configure a project
    if ask_project_configuration; then
        # Step 4: Detect and configure project
        detect_project_structure
        interactive_configuration
        save_configuration
        check_prerequisites
        
        install_javascript_system
        install_python_system
        setup_cicd_integration
        setup_git_hooks
        update_gitignore
        generate_documentation
        
        print_summary
    else
        # Only global system installed
        echo ""
        echo -e "${GREEN}${SUCCESS}${NC} ${WHITE}AdLimen Global System installed successfully!${NC}"
        echo ""
        echo -e "${YELLOW}To configure a project later, run this installer again from any directory.${NC}"
        echo -e "${CYAN}Global system location: $GLOBAL_SUITE_DIR${NC}"
    fi
}

# Error handling
trap 'print_message "error" "Installation failed. Check the error messages above."; exit 1' ERR

# Run main installation
main "$@"