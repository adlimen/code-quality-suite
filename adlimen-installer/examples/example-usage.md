# AdLimen Quality Code System - Usage Examples

Real-world examples of installing and using the AdLimen Quality Code System across different project types and team structures.

## 📋 Installation Examples

### Example 1: Simple React App

```bash
# Project structure
my-react-app/
├── src/
├── public/
├── package.json
└── README.md

# Installation
cd my-react-app
curl -sSL https://raw.githubusercontent.com/your-repo/adlimen-installer/main/install.sh | bash

# Interactive prompts and responses:
# Frontend directory [.]: src
# Backend directory (leave empty if none): [ENTER]
# Choose interface: 1 (npm scripts)
# Complexity threshold [10]: [ENTER]
# Maintainability threshold [70]: [ENTER]
# Enable security scanning? Y
# Setup git hooks? Y
# CI/CD provider: 1 (GitHub Actions)
```

**Result**: npm scripts installed, GitHub Actions workflow created, git hooks configured.

### Example 2: Full-Stack Next.js + Python

```bash
# Project structure
fullstack-app/
├── frontend/          # Next.js app
├── backend/           # FastAPI
├── shared/
└── docker-compose.yml

# Installation
cd fullstack-app
bash /path/to/adlimen-installer/install.sh

# Interactive configuration:
# Frontend directory [frontend]: [ENTER]
# Backend directory [backend]: [ENTER]
# Interface: 3 (Both npm and Make)
# Complexity threshold: 8
# Maintainability threshold: 75
# Security scanning: Y
# Git hooks: Y
# CI/CD: 1 (GitHub Actions)
```

**Result**: Both npm and Make interfaces, dual-language support, comprehensive CI/CD.

### Example 3: Enterprise Monorepo

```bash
# Project structure
enterprise-platform/
├── apps/
│   ├── web/           # React frontend
│   ├── mobile/        # React Native
│   └── admin/         # Admin dashboard
├── services/
│   ├── api/           # Node.js API
│   ├── worker/        # Python worker
│   └── ml/            # Python ML service
├── packages/
│   ├── ui/            # Shared UI components
│   ├── utils/         # Shared utilities
│   └── types/         # TypeScript types
└── tools/

# Installation with enterprise configuration
cd enterprise-platform

# Use enterprise config template
cp /path/to/adlimen-installer/config-templates/enterprise-config.json .adlimen.config.json

# Edit configuration for specific needs
vim .adlimen.config.json

# Run installer
bash /path/to/adlimen-installer/install.sh --use-existing-config
```

**Result**: Enterprise-grade configuration with team-specific thresholds and advanced integrations.

## 🎯 Usage Examples

### Daily Development Workflow

#### Frontend Developer
```bash
# Morning routine - quick check
npm run adlimen:format:fix

# Before committing
npm run adlimen:quality:fix
git add .
git commit -m "feat: add new component"  # Pre-commit hooks run automatically

# Before pushing
npm run adlimen:quality  # Full analysis
git push origin feature-branch
```

#### Backend Developer
```bash
# Development cycle
python scripts/adlimen/python_quality_check.py formatting
# Fix any issues
python scripts/adlimen/python_quality_check.py all

# Using Make interface
make adlimen-format-fix
make adlimen-quality
```

#### DevOps Engineer
```bash
# CI/CD pipeline maintenance
make adlimen-quality  # Local verification
docker build -t app .
docker run app npm run adlimen:quality  # Container verification

# Infrastructure code
cd infrastructure/
terraform fmt
make adlimen-quality  # If AdLimen supports Terraform
```

### Team Integration Examples

#### Sprint Planning Integration
```bash
# Generate quality reports for sprint review
npm run adlimen:quality > reports/sprint-quality.txt

# Check technical debt
node scripts/adlimen/quality-check.cjs complexity > reports/complexity.json
node scripts/adlimen/quality-check.cjs maintainability > reports/maintainability.json

# Share reports in sprint retrospective
```

#### Code Review Process
```bash
# Before creating PR
npm run adlimen:quality:fix
git add .
git commit -m "refactor: improve code quality"

# Reviewer checks
git checkout feature-branch
npm run adlimen:quality
# Review quality reports before approving
```

#### Release Process
```bash
# Pre-release quality gate
npm run adlimen:quality
# All checks must pass

# Generate release quality report
npm run adlimen:quality > releases/v1.2.0-quality-report.txt

# Deploy only if quality thresholds met
if npm run adlimen:quality --silent; then
    npm run deploy
else
    echo "Quality gate failed - deployment blocked"
    exit 1
fi
```

## ⚙️ Configuration Examples

### Relaxed Development Environment
```json
{
  "adlimen": {
    "thresholds": {
      "complexity": 15,
      "maintainability": 60,
      "duplication": 8
    },
    "features": {
      "security": false,
      "gitHooks": false
    }
  }
}
```

### Strict Production Environment
```json
{
  "adlimen": {
    "thresholds": {
      "complexity": 6,
      "maintainability": 85,
      "duplication": 2
    },
    "features": {
      "security": true,
      "gitHooks": true,
      "performanceAnalysis": true
    }
  }
}
```

### Team-Specific Configuration
```json
{
  "adlimen": {
    "teams": {
      "junior-developers": {
        "thresholds": {
          "complexity": 12,
          "maintainability": 65
        }
      },
      "senior-developers": {
        "thresholds": {
          "complexity": 8,
          "maintainability": 80
        }
      },
      "architects": {
        "thresholds": {
          "complexity": 6,
          "maintainability": 90
        }
      }
    }
  }
}
```

## 🔧 Custom Integration Examples

### GitHub Actions with Custom Thresholds
```yaml
name: Quality Gate
on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run Quality Checks
      run: |
        # Override thresholds for CI
        export ADLIMEN_COMPLEXITY_THRESHOLD=8
        export ADLIMEN_MAINTAINABILITY_THRESHOLD=75
        npm run adlimen:quality
    
    - name: Upload Quality Reports
      uses: actions/upload-artifact@v3
      with:
        name: quality-reports
        path: reports/
```

### Docker Integration
```dockerfile
# Dockerfile with quality checks
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Run quality checks during build
RUN npm run adlimen:quality

# Build application
RUN npm run build

# Runtime
EXPOSE 3000
CMD ["npm", "start"]
```

### Pre-commit Hook Customization
```bash
#!/bin/bash
# .husky/pre-commit

# Run AdLimen quality checks
echo "🔍 Running AdLimen quality checks..."

# Only check staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(js|jsx|ts|tsx)$")

if [ -n "$STAGED_FILES" ]; then
    # Format staged files
    npm run adlimen:format:fix
    
    # Lint staged files
    npm run adlimen:lint:fix
    
    # Add formatted files back to staging
    git add $STAGED_FILES
fi

# Run type checking on entire project
npm run adlimen:type-check

echo "✅ Pre-commit checks completed"
```

### VS Code Integration
```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "AdLimen: Quality Check",
            "type": "npm",
            "script": "adlimen:quality",
            "group": "build",
            "presentation": {
                "reveal": "always",
                "panel": "new"
            },
            "problemMatcher": "$eslint-stylish"
        },
        {
            "label": "AdLimen: Format & Fix",
            "type": "npm",
            "script": "adlimen:quality:fix",
            "group": "build",
            "presentation": {
                "reveal": "silent"
            }
        }
    ]
}
```

```json
// .vscode/settings.json
{
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "editor.formatOnSave": true,
    "npm.scriptHover": true,
    "npm.enableScriptExplorer": true
}
```

## 📊 Monitoring and Reporting Examples

### Quality Metrics Dashboard
```bash
#!/bin/bash
# generate-quality-dashboard.sh

echo "📊 Generating Quality Dashboard..."

# Run all quality checks and capture metrics
npm run adlimen:complexity > reports/complexity.json
npm run adlimen:maintainability > reports/maintainability.json
npm run adlimen:duplication > reports/duplication.json
npm run adlimen:security > reports/security.json

# Generate HTML dashboard
node scripts/generate-dashboard.js

echo "✅ Dashboard generated: reports/dashboard.html"
```

### Slack Integration
```bash
#!/bin/bash
# slack-quality-report.sh

WEBHOOK_URL="https://hooks.slack.com/your/webhook/url"

# Run quality check and get result
if npm run adlimen:quality --silent; then
    STATUS="✅ PASSED"
    COLOR="good"
else
    STATUS="❌ FAILED"
    COLOR="danger"
fi

# Send to Slack
curl -X POST -H 'Content-type: application/json' \
    --data "{
        \"attachments\": [{
            \"color\": \"$COLOR\",
            \"title\": \"Quality Check: $STATUS\",
            \"text\": \"Project: $(basename $(pwd))\nBranch: $(git branch --show-current)\nCommit: $(git rev-parse --short HEAD)\"
        }]
    }" \
    $WEBHOOK_URL
```

### Weekly Quality Report
```bash
#!/bin/bash
# weekly-quality-report.sh

echo "📈 Weekly Quality Report - $(date)"
echo "================================="

# Get metrics for the week
git log --since="1 week ago" --oneline | wc -l | xargs echo "Commits this week:"

# Run comprehensive analysis
npm run adlimen:quality

# Generate trend analysis
node scripts/quality-trends.js --weeks=4

# Email report to team
if command -v mail >/dev/null; then
    npm run adlimen:quality 2>&1 | mail -s "Weekly Quality Report - $(date +%Y-%m-%d)" team@company.com
fi
```

## 🎯 Best Practices Examples

### Gradual Quality Improvement
```bash
# Month 1: Establish baseline
npm run adlimen:quality > baseline-quality.txt

# Month 2: Improve formatting and basic linting
npm run adlimen:format:fix
npm run adlimen:lint:fix

# Month 3: Focus on complexity
# Update .adlimen.config.json to lower complexity threshold from 15 to 12

# Month 4: Improve maintainability
# Update threshold from 60 to 70

# Month 5: Add security scanning
# Enable security features in config
```

### Legacy Code Integration
```bash
# Phase 1: Install with relaxed thresholds
# .adlimen.config.json with high thresholds

# Phase 2: Format existing code
npm run adlimen:format:fix
git add .
git commit -m "style: apply consistent formatting"

# Phase 3: Fix basic linting issues
npm run adlimen:lint:fix
git add .
git commit -m "fix: resolve basic linting issues"

# Phase 4: Gradually tighten thresholds
# Lower complexity threshold by 1 every sprint
# Improve maintainability threshold by 5 every month
```

These examples demonstrate real-world usage patterns and show how the AdLimen Quality Code System can be adapted to different team sizes, project types, and organizational needs.