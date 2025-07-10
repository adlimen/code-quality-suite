# AdLimen Quality Code System - Universal Installer

🚀 **Transform any codebase with enterprise-grade quality controls**

The AdLimen Quality Code System is a universal installer that brings comprehensive quality assurance to any JavaScript/TypeScript or Python project with intelligent detection and configurable options.

## 🎯 Features

✅ **Auto-Detection** - Intelligent project structure and language detection  
✅ **Multi-Language** - JavaScript/TypeScript and Python support  
✅ **Configurable** - Customizable complexity, maintainability, and duplication thresholds  
✅ **Dual Interface** - Choose between npm scripts or Make commands  
✅ **CI/CD Ready** - GitHub Actions, GitLab CI, CircleCI integration  
✅ **Git Hooks** - Automatic pre-commit and pre-push quality checks  
✅ **Enterprise-Grade** - 11-step quality workflow with industry standards  

## 🚀 Quick Install

```bash
# Clone or download the installer
curl -sSL https://raw.githubusercontent.com/your-repo/adlimen-installer/main/install.sh | bash

# OR run directly in your project
cd your-project
bash /path/to/adlimen-installer/install.sh
```

## 📋 Interactive Installation

The installer will guide you through:

### 1. **Project Detection**
- Automatically detects JavaScript/TypeScript and Python
- Identifies frontend/backend directory structure
- Recognizes common project patterns

### 2. **Configuration Options**
```bash
Frontend directory [src/frontend]: 
Backend directory [src/backend]: 
Preferred interface:
  1) npm scripts (recommended for Node.js teams)
  2) Make commands (recommended for Unix/DevOps teams)  
  3) Both (dual interface)
Choice [1-3]: 
```

### 3. **Quality Thresholds**
```bash
Complexity threshold [10]: 
Maintainability threshold [70]: 
Duplication threshold (min lines) [5]: 
Enable security scanning? (Y/n): 
Setup git hooks? (Y/n): 
```

### 4. **CI/CD Integration**
```bash
Select CI/CD provider:
  1) GitHub Actions
  2) GitLab CI
  3) CircleCI
  4) None/Skip
Choice [1-4]: 
```

## 🛠️ What Gets Installed

### JavaScript/TypeScript Projects
- **Quality Scripts** - Complete 11-step quality workflow
- **ESLint Configs** - Modular, optimized configurations
- **Dependencies** - All required quality tools
- **npm Scripts** - Ready-to-use package.json scripts
- **Makefile** - Traditional Unix interface (optional)

### Python Projects
- **Quality Scripts** - Python-specific quality tools
- **Dependencies** - black, ruff, mypy, bandit, radon
- **Requirements** - requirements-adlimen.txt
- **Integration** - Works with existing Python workflows

### CI/CD Integration
- **GitHub Actions** - `.github/workflows/adlimen-quality.yml`
- **GitLab CI** - `.gitlab-ci.yml` configuration
- **CircleCI** - `.circleci/config.yml` setup

### Git Hooks
- **Pre-commit** - Essential quality checks with auto-fix
- **Pre-push** - Complete quality validation
- **Husky Integration** - For Node.js projects

## 🎯 Usage After Installation

### npm Scripts Interface
```bash
npm run adlimen:quality              # Complete 11-step analysis
npm run adlimen:quality:fix          # Analysis with auto-fix
npm run adlimen:format               # Code formatting
npm run adlimen:format:fix           # Formatting with auto-fix
npm run adlimen:lint                 # Code quality linting
npm run adlimen:lint:fix             # Linting with auto-fix
npm run adlimen:type-check           # TypeScript type checking
npm run adlimen:security             # Security analysis
```

### Make Commands Interface
```bash
make adlimen-quality                 # Complete quality analysis
make adlimen-quality-fix             # Analysis with auto-fix
make adlimen-format                  # Code formatting
make adlimen-format-fix              # Formatting with auto-fix
make adlimen-lint                    # Code quality linting
make adlimen-lint-fix                # Linting with auto-fix
make adlimen-type-check              # TypeScript type checking
make adlimen-security                # Security analysis
```

### Direct Execution
```bash
# JavaScript/TypeScript
node scripts/adlimen/quality-check.cjs all
node scripts/adlimen/quality-check.cjs all --fix
node scripts/adlimen/quality-check.cjs prettier
node scripts/adlimen/quality-check.cjs linting --fix

# Python
python scripts/adlimen/python_quality_check.py all
python scripts/adlimen/python_quality_check.py formatting
python scripts/adlimen/python_quality_check.py security
```

## ⚙️ Configuration

The installer creates `.adlimen.config.json` with your settings:

```json
{
  "adlimen": {
    "version": "1.0.0",
    "languages": ["javascript", "python"],
    "structure": {
      "frontendDir": "src/frontend",
      "backendDir": "src/backend"
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

## 🔧 Customization

### Modify Thresholds
Edit `.adlimen.config.json` to adjust quality standards:
- **Complexity**: Maximum cyclomatic complexity
- **Maintainability**: Minimum maintainability score
- **Duplication**: Minimum lines to consider duplication

### Add Custom Tools
Extend `scripts/adlimen/quality-check.cjs` with project-specific tools:
```javascript
const tools = {
  // ... existing tools
  'custom-tool': {
    name: 'Custom Tool',
    description: 'Custom quality check',
    commands: {
      check: ['your-tool', '--check'],
      fix: ['your-tool', '--fix']
    }
  }
};
```

### Environment-Specific Settings
Create environment-specific configurations:
- `.adlimen.config.dev.json` - Development settings
- `.adlimen.config.prod.json` - Production settings
- `.adlimen.config.ci.json` - CI/CD settings

## 📊 Quality Workflow (11 Steps)

1. **Code Formatting** - Prettier for consistent styling
2. **Import Sorting** - Organized import statements
3. **Code Linting** - ESLint/Ruff for quality rules
4. **Type Checking** - TypeScript/MyPy for type safety
5. **Security Scanning** - Vulnerability detection
6. **Dependency Audit** - Package security checks
7. **Dead Code Detection** - Unused code identification
8. **Duplication Analysis** - Code duplication detection
9. **Complexity Analysis** - Cyclomatic complexity measurement
10. **Maintainability** - Code maintainability scoring
11. **Dependency Analysis** - Dependency graph validation

## 📈 Team Integration

### For Frontend Teams
```json
{
  "scripts": {
    "dev": "npm run adlimen:format:fix && next dev",
    "build": "npm run adlimen:quality && next build",
    "pre-commit": "npm run adlimen:quality:fix"
  }
}
```

### For Backend Teams
```bash
# Makefile integration
dev: adlimen-format-fix
	python manage.py runserver

deploy: adlimen-quality
	docker build -t app .
```

### For Full-Stack Teams
```bash
# Use both interfaces
npm run adlimen:quality           # Frontend
python scripts/adlimen/python_quality_check.py all  # Backend
```

## 🚨 Prerequisites

The installer will check for and guide you to install:

- **Node.js 18+** - For JavaScript/TypeScript projects
- **Python 3.8+** - For Python projects
- **npm/pip** - Package managers
- **Git** - Version control
- **Make** - For Make interface (optional)
- **jq** - JSON processing

## 🎯 Project Structure Support

### Monorepo
```
project/
├── frontend/          # Auto-detected
├── backend/           # Auto-detected
├── .adlimen.config.json
└── scripts/adlimen/
```

### Simple Structure
```
project/
├── src/               # Single directory
├── .adlimen.config.json
└── scripts/adlimen/
```

### Custom Structure
```
project/
├── web/               # Custom frontend
├── api/               # Custom backend
├── .adlimen.config.json
└── scripts/adlimen/
```

## 📞 Support

### Troubleshooting
1. **Permission Issues**: Run `chmod +x install.sh`
2. **Missing Tools**: Installer guides through prerequisite installation
3. **Configuration**: Check `.adlimen.config.json` for settings

### Getting Help
- Review generated `ADLIMEN-README.md` for project-specific usage
- Check installation logs for error details
- Validate configuration with `node scripts/adlimen/quality-check.cjs`

### Advanced Usage
- **Custom Workflows**: Extend quality suites in the orchestrator
- **Integration**: Use direct scripts in custom build systems
- **Scaling**: Configure different thresholds per environment

## 🎖️ Benefits

✅ **Zero Configuration** - Works out of the box with intelligent defaults  
✅ **Team Consistency** - Unified quality standards across projects  
✅ **Productivity** - Catch issues early with automated checks  
✅ **Maintainability** - Improve code quality over time  
✅ **Security** - Built-in security scanning and dependency auditing  
✅ **Flexibility** - Adapts to any project structure and workflow  
✅ **Enterprise Ready** - Scales from small teams to large organizations  

---

**AdLimen Quality Code System**: Transform your codebase with enterprise-grade quality controls  
**Version**: 1.0.0  
**Last Updated**: July 10, 2025  
**License**: MIT  