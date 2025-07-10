# AdLimen Code Quality Suite - Implementation Guide

Comprehensive guide for implementing the AdLimen Code Quality Suite in any development project with support for multiple programming languages and project structures.

## 🎯 Overview

The AdLimen Code Quality Suite provides a unified, multi-language code quality system that can be integrated into any development workflow. This guide covers everything from basic setup to advanced customization for complex, multi-language projects.

### Supported Architectures

- **Frontend-only projects** (React, Vue, Angular, etc.)
- **Backend-only projects** (Node.js, Python Flask/Django, etc.)
- **Full-stack applications** (JavaScript frontend + Python backend)
- **Microservices architectures** (multiple languages and services)
- **Monorepo structures** (multiple projects in single repository)

## 🚀 Installation Methods

### Method 1: Interactive Installation (Recommended)

The interactive installer uses a **global + local hybrid approach** for maximum efficiency and flexibility.

```bash
# Option A: Download installer only (recommended for most users)
curl -fsSL https://raw.githubusercontent.com/matteocervelli/code-quality-suite/main/adlimen-installer/install.sh -o install.sh
chmod +x install.sh
./install.sh

# Option B: Clone repository first (for development/offline use)
git clone https://github.com/matteocervelli/code-quality-suite.git ~/tools/code-quality-suite
~/tools/code-quality-suite/adlimen-installer/install.sh

# Option C: Global installation for convenience
git clone https://github.com/matteocervelli/code-quality-suite.git ~/tools/code-quality-suite
sudo ln -s ~/tools/code-quality-suite/adlimen-installer/install.sh /usr/local/bin/adlimen-install
# Then from anywhere: adlimen-install

# The installer will interactively ask:
# 1. Global installation directory (default: ~/.adlimen)
# 2. "Do you want to configure a project now?" 
# 3. If yes: "Which project directory to configure?"
# 4. Project-specific configuration (languages, structure, etc.)
# 5. Quality thresholds, git hooks, CI/CD setup
# 3. Project structure detection (monorepo/standard)
# 4. Language selection (JavaScript/TypeScript, Python)
# 5. Directory structure configuration (frontend/backend)
# 6. Interface preference (npm/make/both)
# 7. Quality threshold settings (complexity, maintainability)
# 8. Git hooks configuration (pre-commit/pre-push)
# 9. CI/CD provider selection (GitHub/GitLab/CircleCI)
```

**🌍 Global System Setup:**
- **One-time installation** at `~/.adlimen/code-quality-suite/`
- **Automatic updates** via git pull when requested
- **Shared cache** and configurations across projects
- **Centralized maintenance** and upgrades

**🏠 Per-Project Configuration:**
- **Lightweight setup** in each project
- **Custom configurations** (.adlimen-config.json)
- **Project-specific scripts** (wrapper scripts pointing to global system)
- **Local git hooks** configured for the project
- **Isolated settings** and thresholds

**What the installer does:**
- **Global**: Installs/updates AdLimen system globally
- **Local**: Creates project-specific configuration and scripts
- **Integration**: Sets up git hooks, CI/CD workflows, .gitignore entries
- **Documentation**: Generates ADLIMEN-README.md with usage instructions

### Method 2: Global System + Manual Project Setup

For advanced users who want to set up the global system once and then manually configure projects.

#### Step 1: Global System Installation

```bash
# Install global AdLimen system
mkdir -p ~/.adlimen
git clone https://github.com/matteocervelli/code-quality-suite.git ~/.adlimen/code-quality-suite

# Verify installation
ls ~/.adlimen/code-quality-suite/editions/
```

#### Step 2: Project-Specific Setup

**JavaScript/TypeScript Projects:**

```bash
# Navigate to your project
cd /path/to/your/project

# Create AdLimen configuration
cat > .adlimen-config.json << 'EOF'
{
  "adlimen": {
    "version": "1.0.0",
    "languages": ["javascript"],
    "structure": {
      "type": "standard",
      "frontendDir": "src",
      "isMonorepo": false
    },
    "interface": "npm",
    "thresholds": {
      "complexity": 10,
      "maintainability": 70,
      "duplication": 5
    },
    "features": {
      "security": true,
      "gitHooks": true
    },
    "paths": {
      "globalSuiteDir": "~/.adlimen/code-quality-suite"
    }
  }
}
EOF

# Create wrapper scripts
mkdir -p scripts/adlimen
cat > scripts/adlimen/quality-check.cjs << 'EOF'
#!/usr/bin/env node
const { execSync } = require('child_process');
const path = require('path');
const os = require('os');

const globalSuite = path.join(os.homedir(), '.adlimen', 'code-quality-suite');
const scriptPath = path.join(globalSuite, 'editions', 'javascript', 'quality-check.cjs');

try {
  execSync(`node "${scriptPath}" ${process.argv.slice(2).join(' ')}`, { stdio: 'inherit' });
} catch (error) {
  process.exit(error.status || 1);
}
EOF

chmod +x scripts/adlimen/quality-check.cjs

# Add npm scripts to package.json
npm pkg set scripts.adlimen:quality="node scripts/adlimen/quality-check.cjs all"
npm pkg set scripts.adlimen:quality:fix="node scripts/adlimen/quality-check.cjs all --fix"
npm pkg set scripts.adlimen:lint="node scripts/adlimen/quality-check.cjs linting"
npm pkg set scripts.adlimen:lint:fix="node scripts/adlimen/quality-check.cjs linting --fix"

# Install dependencies
npm install --save-dev \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  eslint \
  eslint-plugin-sonarjs \
  prettier \
  typescript \
  husky \
  lint-staged

# Setup git hooks (optional)
npx husky install
npx husky add .husky/pre-commit "npm run adlimen:quality:fix"
npx husky add .husky/pre-push "npm run adlimen:quality"
```

**Python Projects:**

```bash
# Navigate to your project
cd /path/to/your/project

# Create AdLimen configuration
cat > .adlimen-config.json << 'EOF'
{
  "adlimen": {
    "version": "1.0.0",
    "languages": ["python"],
    "structure": {
      "type": "standard",
      "backendDir": "src",
      "isMonorepo": false
    },
    "interface": "make",
    "thresholds": {
      "complexity": 10,
      "maintainability": 70,
      "duplication": 5
    },
    "features": {
      "security": true,
      "gitHooks": true
    },
    "paths": {
      "globalSuiteDir": "~/.adlimen/code-quality-suite"
    }
  }
}
EOF

# Create wrapper scripts
mkdir -p scripts/adlimen
cat > scripts/adlimen/python-quality-check.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
import subprocess
from pathlib import Path

global_suite = Path.home() / '.adlimen' / 'code-quality-suite'
script_path = global_suite / 'editions' / 'python' / 'quality-check.py'

try:
    result = subprocess.run([sys.executable, str(script_path)] + sys.argv[1:])
    sys.exit(result.returncode)
except Exception as e:
    print(f"Error running quality check: {e}")
    sys.exit(1)
EOF

chmod +x scripts/adlimen/python-quality-check.py

# Create Makefile (optional)
cat > Makefile << 'EOF'
.PHONY: adlimen-quality adlimen-quality-fix adlimen-lint adlimen-security

adlimen-quality:
	python scripts/adlimen/python-quality-check.py all

adlimen-quality-fix:
	python scripts/adlimen/python-quality-check.py all --fix

adlimen-lint:
	python scripts/adlimen/python-quality-check.py linting --fix

adlimen-security:
	python scripts/adlimen/python-quality-check.py security
EOF

# Install dependencies
pip install -r ~/.adlimen/code-quality-suite/editions/python/requirements.template.txt

# Setup git hooks (optional)
mkdir -p .git/hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔍 Running AdLimen Python quality checks..."
python scripts/adlimen/python-quality-check.py required --fix
EOF

chmod +x .git/hooks/pre-commit
```

### Method 3: Configuration-Driven Setup

Create a configuration file first and let the system configure itself:

```bash
# 1. Create project configuration
cat > .adlimen-config.json << EOF
{
  "adlimen": {
    "version": "1.0.0",
    "languages": ["javascript", "python"],
    "structure": {
      "frontendDir": "frontend/src",
      "backendDir": "backend/src"
    },
    "interface": "both",
    "thresholds": {
      "complexity": 10,
      "maintainability": 70,
      "duplication": 5
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github"
    }
  }
}
EOF

# 2. Run configuration-based setup
./code-quality-suite/scripts/configure-project.sh

# 3. Install dependencies
npm install && pip install -r requirements-quality.txt

# 4. Run quality checks
npm run quality:all
```

## 🏗️ Project Structure Configuration

### Single Language Projects

#### Frontend-Only (React/Vue/Angular)

```json
{
  "adlimen": {
    "languages": ["javascript"],
    "structure": {
      "frontendDir": "src",
      "backendDir": ""
    },
    "thresholds": {
      "complexity": 8,
      "maintainability": 75,
      "duplication": 5
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github"
    }
  }
}
```

#### Backend-Only (Python Flask/Django)

```json
{
  "adlimen": {
    "languages": ["python"],
    "structure": {
      "frontendDir": "",
      "backendDir": "src"
    },
    "thresholds": {
      "complexity": 6,
      "maintainability": 80,
      "duplication": 3
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github"
    }
  }
}
```

### Multi-Language Projects

#### Full-Stack Application

```json
{
  "adlimen": {
    "languages": ["javascript", "python"],
    "structure": {
      "frontendDir": "frontend/src",
      "backendDir": "backend/src",
      "sharedDir": "shared/src"
    },
    "thresholds": {
      "javascript": {
        "complexity": 10,
        "maintainability": 70,
        "duplication": 5
      },
      "python": {
        "complexity": 8,
        "maintainability": 75,
        "duplication": 3
      }
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github",
      "parallelExecution": true
    }
  }
}
```

#### Microservices Architecture

```json
{
  "adlimen": {
    "languages": ["javascript", "python"],
    "structure": {
      "services": {
        "api-gateway": {
          "language": "javascript",
          "path": "services/api-gateway/src"
        },
        "user-service": {
          "language": "python",
          "path": "services/user-service/src"
        },
        "payment-service": {
          "language": "python",
          "path": "services/payment-service/src"
        },
        "notification-service": {
          "language": "javascript",
          "path": "services/notification-service/src"
        }
      }
    },
    "thresholds": {
      "global": {
        "complexity": 8,
        "maintainability": 75,
        "duplication": 4
      }
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github",
      "parallelExecution": true,
      "serviceIsolation": true
    }
  }
}
```

#### Monorepo Structure

```json
{
  "adlimen": {
    "languages": ["javascript", "python"],
    "structure": {
      "monorepo": true,
      "packages": {
        "web-app": {
          "language": "javascript",
          "path": "packages/web-app/src",
          "framework": "react"
        },
        "mobile-app": {
          "language": "javascript",
          "path": "packages/mobile-app/src",
          "framework": "react-native"
        },
        "api-server": {
          "language": "javascript",
          "path": "packages/api-server/src",
          "framework": "express"
        },
        "ml-service": {
          "language": "python",
          "path": "packages/ml-service/src",
          "framework": "flask"
        },
        "data-pipeline": {
          "language": "python",
          "path": "packages/data-pipeline/src",
          "framework": "airflow"
        }
      }
    },
    "thresholds": {
      "default": {
        "complexity": 10,
        "maintainability": 70,
        "duplication": 5
      },
      "overrides": {
        "ml-service": {
          "complexity": 12,
          "duplication": 8
        }
      }
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "ciProvider": "github",
      "parallelExecution": true,
      "workspaceIsolation": true
    }
  }
}
```

## ⚙️ Configuration Customization

### Quality Thresholds

#### Complexity Thresholds

```json
{
  "thresholds": {
    "complexity": {
      "cyclomatic": 10,        // Maximum cyclomatic complexity
      "cognitive": 15,         // Maximum cognitive complexity
      "nesting": 4,           // Maximum nesting depth
      "parameters": 4,        // Maximum function parameters
      "statements": 20,       // Maximum statements per function
      "lines": 50            // Maximum lines per function
    }
  }
}
```

#### Maintainability Index

```json
{
  "thresholds": {
    "maintainability": {
      "minimum": 70,          // Minimum maintainability score
      "excellent": 90,        // Excellent threshold
      "good": 80,            // Good threshold
      "acceptable": 70,      // Acceptable threshold
      "needsImprovement": 60 // Needs improvement threshold
    }
  }
}
```

#### Code Duplication

```json
{
  "thresholds": {
    "duplication": {
      "percentage": 5,        // Maximum duplication percentage
      "minLines": 5,         // Minimum lines for duplication detection
      "minTokens": 50,       // Minimum tokens for duplication detection
      "ignoreComments": true, // Ignore comments in duplication
      "ignoreStrings": false // Include strings in duplication detection
    }
  }
}
```

### Tool-Specific Configuration

#### JavaScript/TypeScript Tools

```json
{
  "tools": {
    "javascript": {
      "prettier": {
        "semi": true,
        "trailingComma": "es5",
        "singleQuote": true,
        "printWidth": 80,
        "tabWidth": 2
      },
      "eslint": {
        "extends": [
          "./.eslint-configs/base.js",
          "./.eslint-configs/import-sorting.js",
          "./.eslint-configs/linting.js",
          "./.eslint-configs/security.js",
          "./.eslint-configs/complexity.js"
        ],
        "rules": {
          "complexity": ["error", { "max": 10 }],
          "max-depth": ["error", 4],
          "max-lines-per-function": ["error", 50]
        }
      },
      "typescript": {
        "strict": true,
        "noImplicitAny": true,
        "strictNullChecks": true
      }
    }
  }
}
```

#### Python Tools

```json
{
  "tools": {
    "python": {
      "black": {
        "line-length": 88,
        "target-version": ["py38", "py39", "py310", "py311"],
        "include": "\\.pyi?$"
      },
      "ruff": {
        "select": ["E", "F", "W", "I", "N", "UP", "B", "C4", "S", "T20"],
        "ignore": ["E501"],
        "fixable": ["I", "F401"],
        "line-length": 88
      },
      "mypy": {
        "strict": true,
        "check_untyped_defs": true,
        "warn_redundant_casts": true,
        "warn_unused_ignores": true,
        "show_error_codes": true
      },
      "bandit": {
        "exclude_dirs": ["tests", "test_*"],
        "skips": ["B101", "B601"]
      }
    }
  }
}
```

## 🔄 Workflow Integration

### Git Hooks Configuration

#### Pre-commit Hook

```bash
#!/bin/sh
# .git/hooks/pre-commit

# Load project configuration
config_file=".adlimen-config.json"
if [ -f "$config_file" ]; then
    languages=$(jq -r '.adlimen.languages[]' "$config_file")
else
    echo "Warning: .adlimen-config.json not found, using default settings"
    languages="javascript"
fi

# Run quality checks for each language
for lang in $languages; do
    case $lang in
        "javascript")
            echo "Running JavaScript/TypeScript quality checks..."
            npm run quality:fast || exit 1
            ;;
        "python")
            echo "Running Python quality checks..."
            python quality-tools/python-quality-check.py required || exit 1
            ;;
    esac
done

echo "✅ Pre-commit quality checks passed"
```

#### Pre-push Hook

```bash
#!/bin/sh
# .git/hooks/pre-push

# Load project configuration
config_file=".adlimen-config.json"
if [ -f "$config_file" ]; then
    languages=$(jq -r '.adlimen.languages[]' "$config_file")
    security_enabled=$(jq -r '.adlimen.features.security' "$config_file")
else
    echo "Warning: .adlimen-config.json not found, using default settings"
    languages="javascript"
    security_enabled="true"
fi

# Run comprehensive quality checks for each language
for lang in $languages; do
    case $lang in
        "javascript")
            echo "Running comprehensive JavaScript/TypeScript quality checks..."
            npm run quality || exit 1
            ;;
        "python")
            echo "Running comprehensive Python quality checks..."
            python quality-tools/python-quality-check.py all || exit 1
            ;;
    esac
done

# Run security checks if enabled
if [ "$security_enabled" = "true" ]; then
    echo "Running security analysis..."
    for lang in $languages; do
        case $lang in
            "javascript")
                npm run security || exit 1
                ;;
            "python")
                python quality-tools/python-quality-check.py security || exit 1
                ;;
        esac
    done
fi

echo "✅ Pre-push quality checks passed"
```

### CI/CD Integration

#### GitHub Actions Workflow

```yaml
# .github/workflows/quality-checks.yml
name: Multi-Language Quality Checks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  detect-languages:
    runs-on: ubuntu-latest
    outputs:
      languages: ${{ steps.detect.outputs.languages }}
      matrix: ${{ steps.detect.outputs.matrix }}
    steps:
      - uses: actions/checkout@v4
      - name: Detect project languages
        id: detect
        run: |
          if [ -f ".adlimen-config.json" ]; then
            languages=$(jq -r '.adlimen.languages[]' .adlimen-config.json | jq -R . | jq -s .)
            matrix=$(jq -r '.adlimen.languages' .adlimen-config.json)
          else
            # Default detection based on file presence
            languages='["javascript"]'
            matrix='["javascript"]'
            [ -f "package.json" ] && languages='["javascript"]'
            [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] && languages='["python"]'
            [ -f "package.json" ] && ([ -f "pyproject.toml" ] || [ -f "requirements.txt" ]) && languages='["javascript","python"]'
          fi
          echo "languages=$languages" >> $GITHUB_OUTPUT
          echo "matrix=$matrix" >> $GITHUB_OUTPUT

  quality-checks:
    runs-on: ubuntu-latest
    needs: detect-languages
    strategy:
      matrix:
        language: ${{ fromJson(needs.detect-languages.outputs.matrix) }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        if: matrix.language == 'javascript'
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Setup Python
        if: matrix.language == 'python'
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install JavaScript dependencies
        if: matrix.language == 'javascript'
        run: npm ci
      
      - name: Install Python dependencies
        if: matrix.language == 'python'
        run: |
          pip install -r quality-tools/requirements.template.txt
      
      - name: Run JavaScript quality checks
        if: matrix.language == 'javascript'
        run: |
          npm run quality
      
      - name: Run Python quality checks
        if: matrix.language == 'python'
        run: |
          python quality-tools/python-quality-check.py all
      
      - name: Upload quality reports
        uses: actions/upload-artifact@v4
        with:
          name: quality-reports-${{ matrix.language }}
          path: reports/
```

#### GitLab CI Configuration

```yaml
# .gitlab-ci.yml
stages:
  - detect
  - quality
  - security

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.cache/pip"
  NPM_CACHE_DIR: "$CI_PROJECT_DIR/.cache/npm"

cache:
  paths:
    - .cache/pip
    - .cache/npm
    - node_modules/

detect-languages:
  stage: detect
  script:
    - |
      if [ -f ".adlimen-config.json" ]; then
        languages=$(jq -r '.adlimen.languages[]' .adlimen-config.json)
      else
        languages="javascript"
        [ -f "pyproject.toml" ] && languages="$languages python"
      fi
      echo "DETECTED_LANGUAGES=$languages" > languages.env
  artifacts:
    reports:
      dotenv: languages.env

javascript-quality:
  stage: quality
  image: node:20-alpine
  needs: ["detect-languages"]
  rules:
    - if: $DETECTED_LANGUAGES =~ /javascript/
  before_script:
    - npm ci
  script:
    - npm run quality
  artifacts:
    reports:
      junit: reports/javascript/junit.xml
    paths:
      - reports/javascript/

python-quality:
  stage: quality
  image: python:3.11-alpine
  needs: ["detect-languages"]
  rules:
    - if: $DETECTED_LANGUAGES =~ /python/
  before_script:
    - pip install -r quality-tools/requirements.template.txt
  script:
    - python quality-tools/python-quality-check.py all
  artifacts:
    reports:
      junit: reports/python/junit.xml
    paths:
      - reports/python/

security-scan:
  stage: security
  needs: ["detect-languages"]
  script:
    - |
      if echo "$DETECTED_LANGUAGES" | grep -q "javascript"; then
        npm run security
      fi
      if echo "$DETECTED_LANGUAGES" | grep -q "python"; then
        python quality-tools/python-quality-check.py security
      fi
  artifacts:
    paths:
      - reports/security/
```

## 📊 Advanced Configuration Examples

### Enterprise Configuration

```json
{
  "adlimen": {
    "version": "1.0.0",
    "profile": "enterprise",
    "languages": ["javascript", "python"],
    "structure": {
      "monorepo": true,
      "packages": {
        "frontend": {
          "language": "javascript",
          "path": "apps/frontend/src",
          "framework": "react"
        },
        "backend": {
          "language": "python",
          "path": "apps/backend/src",
          "framework": "django"
        },
        "shared": {
          "language": "javascript",
          "path": "packages/shared/src",
          "framework": "typescript"
        }
      }
    },
    "thresholds": {
      "strict": true,
      "javascript": {
        "complexity": 8,
        "maintainability": 80,
        "duplication": 3,
        "coverage": 90
      },
      "python": {
        "complexity": 6,
        "maintainability": 85,
        "duplication": 2,
        "coverage": 95
      }
    },
    "features": {
      "security": {
        "enabled": true,
        "level": "strict",
        "sast": true,
        "dependencyScanning": true
      },
      "gitHooks": {
        "enabled": true,
        "preCommit": true,
        "prePush": true,
        "commitMsg": true
      },
      "ciProvider": "github",
      "reporting": {
        "format": ["json", "html", "junit"],
        "destination": "reports/",
        "upload": true
      },
      "notifications": {
        "slack": {
          "webhook": "${SLACK_WEBHOOK_URL}",
          "channel": "#code-quality"
        },
        "email": {
          "recipients": ["team@company.com"]
        }
      }
    },
    "customRules": {
      "javascript": {
        "files": [".eslint-configs/enterprise.js"],
        "overrides": {
          "no-console": "error",
          "no-debugger": "error"
        }
      },
      "python": {
        "files": ["enterprise-rules.toml"],
        "overrides": {
          "max-line-length": 100,
          "max-complexity": 6
        }
      }
    }
  }
}
```

### Development Team Configuration

```json
{
  "adlimen": {
    "version": "1.0.0",
    "profile": "development",
    "languages": ["javascript", "python"],
    "structure": {
      "frontendDir": "client/src",
      "backendDir": "server/src",
      "testsDir": "tests"
    },
    "thresholds": {
      "lenient": true,
      "javascript": {
        "complexity": 12,
        "maintainability": 65,
        "duplication": 8,
        "coverage": 70
      },
      "python": {
        "complexity": 10,
        "maintainability": 70,
        "duplication": 6,
        "coverage": 75
      }
    },
    "features": {
      "security": {
        "enabled": true,
        "level": "standard"
      },
      "gitHooks": {
        "enabled": true,
        "preCommit": true,
        "prePush": false
      },
      "autoFix": true,
      "parallelExecution": true,
      "fastMode": true
    },
    "development": {
      "skipOnError": false,
      "verboseOutput": true,
      "progressIndicator": true,
      "colorOutput": true
    }
  }
}
```

## 🛠️ Troubleshooting Guide

### Common Installation Issues

#### Node.js/NPM Issues

```bash
# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Fix permission issues
sudo chown -R $(whoami) ~/.npm
```

#### Python Issues

```bash
# Create virtual environment
python -m venv quality-env
source quality-env/bin/activate  # On Windows: quality-env\Scripts\activate

# Install dependencies in virtual environment
pip install -r quality-tools/requirements.template.txt

# Fix permission issues
sudo chown -R $(whoami) ~/.cache/pip
```

#### Git Hooks Issues

```bash
# Make hooks executable
chmod +x .git/hooks/*

# Reset git hooks path
git config core.hooksPath .git/hooks

# Reinstall husky (for JavaScript projects)
npx husky install
```

### Configuration Issues

#### Invalid Configuration File

```bash
# Validate JSON configuration
jq . .adlimen-config.json

# Use schema validation
npx ajv-cli validate -s .adlimen-config.schema.json -d .adlimen-config.json
```

#### Missing Dependencies

```bash
# Check for missing JavaScript tools
npx eslint --version
npx prettier --version
npx tsc --version

# Check for missing Python tools
python -m black --version
python -m ruff --version
python -m mypy --version
```

### Performance Issues

#### Large Codebase Optimization

```json
{
  "performance": {
    "parallelExecution": true,
    "incrementalAnalysis": true,
    "excludePatterns": [
      "node_modules/**",
      "dist/**",
      "build/**",
      "__pycache__/**",
      "*.min.js",
      "*.bundle.js"
    ],
    "chunkSize": 100,
    "maxWorkers": 4
  }
}
```

#### Memory Usage Optimization

```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=4096"

# Use Python memory profiling
python -m memory_profiler quality-tools/python-quality-check.py all

# Run tools individually to isolate issues
npm run lint
npm run type-check
npm run security
```

## 📚 Best Practices

### Code Organization

1. **Separate configurations by concern**
   - Keep ESLint configs modular
   - Use separate pyproject.toml sections for each tool
   - Organize quality scripts by language

2. **Use consistent naming conventions**
   - Follow established patterns for each language
   - Use descriptive names for custom configurations
   - Document any deviations from standards

3. **Maintain configuration documentation**
   - Document custom rules and their rationale
   - Keep configuration comments up to date
   - Provide examples for team members

### Team Collaboration

1. **Establish quality standards**
   - Define and document quality thresholds
   - Regular team reviews of quality metrics
   - Continuous improvement of standards

2. **Automate quality checks**
   - Use git hooks for immediate feedback
   - Integrate with CI/CD pipelines
   - Set up automated reporting

3. **Training and onboarding**
   - Provide quality tools training
   - Document common issues and solutions
   - Regular knowledge sharing sessions

### Continuous Improvement

1. **Monitor quality metrics**
   - Track quality trends over time
   - Identify areas for improvement
   - Adjust thresholds based on team capabilities

2. **Tool updates and maintenance**
   - Regular updates of quality tools
   - Review and update configurations
   - Test changes in development environment

3. **Feedback and iteration**
   - Collect team feedback on quality processes
   - Iterate on configurations and thresholds
   - Share learnings across projects

## 🔗 Resources

### Documentation Links

- [JavaScript Edition Guide](./editions/javascript/README.md)
- [Python Edition Guide](./editions/python/README.md)
- [Configuration Schema](./adlimen-installer/config-schema.json)
- [Troubleshooting FAQ](./docs/FAQ.md)

### Tool Documentation

#### JavaScript/TypeScript Tools
- [ESLint](https://eslint.org/docs/)
- [Prettier](https://prettier.io/docs/)
- [TypeScript](https://www.typescriptlang.org/docs/)
- [Husky](https://typicode.github.io/husky/)

#### Python Tools
- [Black](https://black.readthedocs.io/)
- [Ruff](https://docs.astral.sh/ruff/)
- [MyPy](https://mypy.readthedocs.io/)
- [Bandit](https://bandit.readthedocs.io/)

### Community and Support

- [GitHub Issues](https://github.com/adlimen/code-quality-suite/issues)
- [Discussion Forum](https://github.com/adlimen/code-quality-suite/discussions)
- [Contributing Guide](./CONTRIBUTING.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)

---

**Last Updated**: 2025-07-10  
**Version**: 1.0.0  
**Architecture**: Multi-Language Quality Suite with 11-Step Workflow