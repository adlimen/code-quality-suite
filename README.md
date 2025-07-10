# AdLimen Code Quality Suite

A comprehensive, enterprise-grade code quality assurance system designed for modern development workflows. This modular system provides dedicated quality tooling for multiple programming languages with consistent patterns and practices.

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support%20Development-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/matteocervelli)

## 🚀 Quick Start

### Interactive Installation (Recommended)

```bash
# Clone the AdLimen Code Quality Suite
git clone https://github.com/adlimen/code-quality-suite.git

# Run the interactive installer
cd code-quality-suite
./adlimen-installer/install.sh

# The installer will:
# - Detect your project structure and languages
# - Configure for monorepo or standard projects
# - Setup quality tools and git hooks automatically
# - Create customized configuration files
```

### Quick Commands

```bash
# Run complete quality analysis
npm run adlimen:quality
# or
make adlimen-quality
# or 
node scripts/adlimen/quality-check.cjs all

# With auto-fix
npm run adlimen:quality:fix
python python-quality-check.py all --fix
```

## 🛠️ 11-Step Quality Workflow

The AdLimen Code Quality Suite implements a comprehensive 11-step quality workflow with specialized tools for each language:

| Step | Category | JavaScript/TypeScript | Python |
|------|----------|----------------------|--------|
| **1** | **Code Formatting** | Prettier | Black |
| **2** | **Import Sorting** | ESLint + Import plugins | isort |
| **3** | **Code Linting** | ESLint | Ruff |
| **4** | **Type Checking** | TypeScript Compiler (tsc) | MyPy |
| **5** | **Security Scanning** | ESLint Security | Bandit |
| **6** | **Vulnerability Checking** | npm audit | Safety |
| **7** | **Dead Code Detection** | ts-prune | Vulture |
| **8** | **Code Duplication** | jscpd | Custom AST-based analyzer |
| **9** | **Complexity Analysis** | typhonjs-escomplex | Radon (Cyclomatic Complexity) |
| **10** | **Maintainability** | Custom maintainability scorer | Radon (Maintainability Index) |
| **11** | **Dependency Analysis** | dependency-cruiser | pipdeptree |

### 🎯 Tool Selection Rationale

- **Language-Native Tools**: Each tool is selected for optimal integration with its target language ecosystem
- **Performance**: Fast execution for development workflow integration
- **Accuracy**: High-precision analysis with minimal false positives
- **Configurability**: Flexible thresholds and customization options
- **Industry Standard**: Widely adopted tools with strong community support

## 🌟 Available Editions

### 📘 JavaScript/TypeScript Edition
- **Location**: `editions/javascript/`
- **Features**: Complete quality assurance for JS/TS projects, monorepo support
- **Status**: ✅ Available

### 🐍 Python Edition
- **Location**: `editions/python/`
- **Features**: 11-step modular workflow with AST-based duplication analysis
- **Status**: ✅ Available (Enhanced!)

### 🔮 Future Editions
- **Go Edition**: Planned
- **Rust Edition**: Planned
- **Java Edition**: Planned

## 🎯 Key Features

- 🪝 **Smart Git Hooks**: Pre-commit, pre-push automation with monorepo support
- ⚙️ **CI/CD Integration**: GitHub Actions, GitLab CI, CircleCI workflows
- 📊 **Unified Reporting**: Consistent quality metrics across languages
- 🎛️ **Configurable Thresholds**: Customizable quality standards
- 🏗️ **Monorepo Support**: Intelligent detection and configuration for monorepo structures
- 🔧 **Auto-Fix Capabilities**: Automatic fixing where possible
- 🛡️ **Security-First**: Comprehensive security scanning and vulnerability detection

## 📦 Usage Examples

### JavaScript/TypeScript Projects

```bash
# Complete quality analysis
npm run adlimen:quality

# With auto-fix
npm run adlimen:quality:fix

# Specific checks
npm run adlimen:lint:fix
npm run adlimen:type-check
npm run adlimen:security
```

### Python Projects

```bash
# Complete quality analysis
python python-quality-check.py all

# With auto-fix
python python-quality-check.py all --fix

# Specific categories
python python-quality-check.py formatting --fix
python python-quality-check.py security
python python-quality-check.py analysis
```

### Mixed Language Projects

```bash
# Run quality checks for all languages
./run-all-quality-checks.sh

# Language-specific with custom directories
node scripts/quality-check.cjs all --source-dir="frontend/src"
python python-quality-check.py all --source-dir="backend/src"
```

## ⚙️ Configuration

### Project Configuration (`.adlimen-config.json`)

```json
{
  "adlimen": {
    "version": "1.0.0",
    "languages": ["javascript", "python"],
    "structure": {
      "type": "monorepo",
      "frontendDir": "frontend/src",
      "backendDir": "backend/src",
      "packagesDir": "packages",
      "isMonorepo": true
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
```

### Monorepo Support

The installer automatically detects monorepo structures and provides:
- **Unified quality standards** across packages
- **Centralized configuration** and tooling
- **Consistent git hooks** for all packages
- **Cross-package dependency analysis**

## 🔧 Project Structure Examples

### Full-Stack Project

```bash
my-fullstack-app/
├── frontend/                    # React/Next.js frontend
├── backend/                     # Python API backend
├── .adlimen-code-quality-suite/ # Quality suite configuration
├── .adlimen-config.json         # Project configuration
└── package.json                 # Root scripts
```

### Monorepo Structure

```bash
monorepo/
├── packages/
│   ├── web-app/          # React TypeScript
│   ├── mobile-app/       # React Native TypeScript
│   ├── api-gateway/      # Node.js TypeScript
│   ├── user-service/     # Python
│   └── data-service/     # Python
└── tools/
    └── quality-suite/
```

## 📊 Quality Metrics

### Maintainability Score (0-100)
- **90-100**: Excellent maintainability
- **80-89**: Good maintainability
- **70-79**: Acceptable maintainability
- **60-69**: Needs improvement
- **Below 60**: Requires refactoring

### Duplication Thresholds
- **Minimum lines**: 5-10 (configurable)
- **Minimum tokens**: 50-70 (configurable)
- **Maximum percentage**: 5-10% (configurable)

### Security Analysis
- Known vulnerabilities detection
- Security anti-patterns identification
- Code complexity security issues

## 🚀 CI/CD Integration

### GitHub Actions

```yaml
name: AdLimen Quality Checks
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
      run: node scripts/adlimen/quality-check.cjs all
```

### Other CI Systems

```bash
# Basic CI pipeline
npm ci
npm run adlimen:quality
npm run test
npm run build
```

## 📚 Best Practices

### Development Workflow
1. **Setup**: Run interactive installer after cloning
2. **Development**: Let pre-commit hooks catch issues early  
3. **Before PR**: Run complete quality check
4. **CI/CD**: Automate with provided workflows

### Quality Standards
- **Complexity**: Keep cyclomatic complexity under 10
- **Function length**: Maximum 50 lines per function
- **File length**: Maximum 300 lines per file
- **Duplication**: Keep below 10% duplication threshold
- **Security**: Address all security warnings

## 🔍 Troubleshooting

### Common Issues

**"Command not found" errors:**
```bash
npm install  # Ensure dependencies are installed
npx eslint --version  # Check tool availability
```

**Git hooks not running:**
```bash
npm run setup-hooks  # Reinstall hooks
chmod +x .husky/pre-commit  # Check permissions
```

**Performance issues:**
```bash
node scripts/quality-check.js all --quiet  # Use quiet mode
npm run pre-commit  # Check only changed files
```

## 🤝 Contributing

To improve this quality system:
1. Test with different project types
2. Add new quality tools as needed
3. Improve configuration templates
4. Enhance documentation

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

Copyright (c) 2025 Matteo Cervelli - Ad Limen S.r.l.

## ☕ Support the Project

If you find this quality system valuable for your projects, consider supporting its development:

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support%20Development-orange?style=for-the-badge&logo=buy-me-a-coffee)](https://buymeacoffee.com/matteocervelli)

Your support helps maintain and improve this open-source quality system for the entire development community.

---

**Version**: 1.0.0  
**Editions**: JavaScript/TypeScript + Python (Multi-Language Support)  
**Architecture**: 11-Step Modular Quality Workflow  
**Last updated**: 2025-07-10