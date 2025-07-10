# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is the **AdLimen Code Quality Suite** - a comprehensive, multi-language code quality assurance system designed for easy integration into any development workflow. The project follows a modular, edition-based architecture that supports multiple programming languages.

### Project Structure

```
code-quality-suite/
├── setup.js                    # Automated setup orchestrator
├── package-template.json       # NPM dependencies and scripts template
├── Makefile-template           # Make commands template
├── editions/                   # Language-specific implementations
│   ├── javascript/             # JavaScript/TypeScript edition (11-step workflow)
│   │   ├── scripts/            # Quality check orchestrators
│   │   ├── .eslint-configs/    # Modular ESLint configurations
│   │   ├── hooks/              # Git hooks templates
│   │   └── workflows/          # GitHub Actions workflows
│   └── python/                 # Python edition (11-step workflow)
│       ├── python-quality-check.py      # Main quality orchestrator
│       ├── python-duplication-check.py  # Duplication analysis
│       ├── pyproject.toml.template       # Python tool configurations
│       ├── hooks/              # Git hooks templates
│       └── workflows/          # GitHub Actions workflows
└── adlimen-installer/          # Installation system
    ├── install.sh              # Automated installer
    └── config-templates/       # Pre-configured setups
```

## Development Commands

### Initial Setup
```bash
# Automated setup (recommended)
node setup.js                  # Auto-configure for your project

# Manual setup for specific languages
cp -r editions/javascript/scripts ./scripts  # Copy JS/TS edition
cp -r editions/python/ ./python-quality      # Copy Python edition
```

### JavaScript/TypeScript Edition Commands

**Quality Check Orchestrator (Unified Interface):**
```bash
# Complete 11-step workflow
node scripts/quality-check.cjs all
node scripts/quality-check.cjs all --fix    # With auto-fix

# Individual steps (1-11)
node scripts/quality-check.cjs prettier              # Step 1: Formatting
node scripts/quality-check.cjs import-sorting        # Step 2: Import sorting
node scripts/quality-check.cjs linting               # Step 3: Linting
node scripts/quality-check.cjs type-checking         # Step 4: Type checking
node scripts/quality-check.cjs security-scanning     # Step 5: Security scanning
node scripts/quality-check.cjs vulnerability-checking # Step 6: Vulnerability checking
node scripts/quality-check.cjs dead-code             # Step 7: Dead code detection
node scripts/quality-check.cjs duplication           # Step 8: Duplication analysis
node scripts/quality-check.cjs complexity            # Step 9: Complexity analysis
node scripts/quality-check.cjs maintainability       # Step 10: Maintainability
node scripts/quality-check.cjs dependency-check      # Step 11: Dependency analysis

# Quality suites
node scripts/quality-check.cjs required              # Essential checks only
node scripts/quality-check.cjs security              # Security analysis only
node scripts/quality-check.cjs analysis              # Code analysis tools only
```

**NPM Scripts Interface:**
```bash
npm run quality                 # Complete workflow
npm run quality:fix             # With auto-fix
npm run quality:fast            # Essential checks only
npm run format:fix              # Format code
npm run lint:fix                # Fix linting issues
npm run type-check              # TypeScript checking
npm run security                # Security analysis
npm run dead-code               # Find unused code
npm run duplication             # Check duplicates
npm run maintainability         # Maintainability score
```

**Make Commands Interface:**
```bash
make quality                    # Complete workflow
make quality-fix                # With auto-fix
make quality-fast               # Essential checks only
make format-fix                 # Format code
make lint-fix                   # Fix linting issues
make type-check                 # TypeScript checking
make security                   # Security analysis
make setup-env                  # Setup development environment
make install-tools              # Install quality dependencies
```

### Python Edition Commands

**Quality Check Orchestrator:**
```bash
# Complete 11-step workflow
python python-quality-check.py all
python python-quality-check.py all --fix    # With auto-fix

# Individual categories
python python-quality-check.py formatting --fix  # Black + isort
python python-quality-check.py linting           # Ruff
python python-quality-check.py security          # Bandit + Safety
python python-quality-check.py analysis          # Complexity + duplication

# Individual tools
python python-quality-check.py black --fix
python python-quality-check.py mypy
python python-quality-check.py bandit

# Duplication analysis
python python-duplication-check.py --verbose
```

## Key Architecture Concepts

### 11-Step Modular Quality Workflow

Both language editions implement the same comprehensive workflow:

1. **Formatting** - Code style consistency
2. **Import Sorting** - Import organization 
3. **Linting** - Code quality rules
4. **Type Checking** - Static type validation
5. **Security Scanning** - Code vulnerability detection
6. **Vulnerability Checking** - Dependency vulnerabilities
7. **Dead Code Detection** - Unused code identification
8. **Duplication Analysis** - Code duplication detection
9. **Complexity Analysis** - Cyclomatic complexity measurement
10. **Maintainability** - Maintainability index calculation
11. **Dependency Analysis** - Dependency graph validation

### Multi-Interface Support

The system provides three interfaces for maximum flexibility:

1. **Direct Script Execution** - `node scripts/quality-check.cjs [command]`
2. **NPM Scripts** - `npm run quality`, `npm run lint:fix`
3. **Make Commands** - `make quality`, `make lint-fix`

### Language Edition Pattern

Each language edition follows this standardized structure:
- **Orchestrator Script** - Main quality runner (`quality-check.cjs`, `python-quality-check.py`)
- **Configuration Templates** - Tool-specific configurations
- **Git Hooks** - Pre-commit, pre-push, commit-msg
- **CI/CD Workflows** - GitHub Actions workflows
- **Documentation** - Usage guides and integration examples

## Configuration Files

### JavaScript/TypeScript Configuration
- **ESLint Configs** - Modular configurations in `.eslint-configs/`
- **Package Template** - `package-template.json` with all dependencies
- **Dependency Cruiser** - `.dependency-cruiser.cjs` for dependency analysis
- **Makefile Template** - `Makefile-template` with all commands

### Python Configuration
- **pyproject.toml** - Unified Python tool configuration
- **requirements.template.txt** - Quality tool dependencies
- **Tool-specific sections** for Black, Ruff, MyPy, Bandit, etc.

## Integration Patterns

### Automated Setup
The `setup.js` script automatically:
- Detects project type and language
- Merges dependencies into existing package.json
- Copies configuration files
- Sets up git hooks
- Creates directory structure
- Installs GitHub Actions workflows

### Framework Integration
- **React/Next.js** - Includes React-specific ESLint rules
- **Node.js/Express** - Server-side JavaScript optimizations
- **Django/Flask** - Python web framework configurations
- **Data Science** - Jupyter notebook and data science tool support

### CI/CD Integration
- **GitHub Actions** - Pre-configured workflows for quality checks and testing
- **Docker Support** - Containerized quality checking
- **Quality Gates** - Configurable pass/fail criteria

## Quality Standards and Thresholds

### Code Quality Metrics
- **Complexity** - Cyclomatic complexity ≤ 10
- **Function Length** - ≤ 50 lines per function
- **File Length** - ≤ 500 lines per file (enforced by global standards)
- **Duplication** - ≤ 10% code duplication
- **Type Coverage** - 100% type annotations (strict mode)

### Security Standards
- **Vulnerability Scanning** - Zero high/critical vulnerabilities allowed
- **Dependency Security** - Regular security audits
- **Code Security** - Security anti-pattern detection

## Development Workflow

### Daily Development
1. **Quick Checks** - `npm run quality:fix` or `make quality-fix`
2. **Pre-commit** - Automatic via git hooks
3. **Full Analysis** - `npm run quality` or `make quality` before push

### Project Integration
1. **Copy Quality Suite** to your project
2. **Run Setup** - `node setup.js` for automated configuration
3. **Install Dependencies** - `npm install` or `pip install -r requirements.template.txt`
4. **Configure Tools** - Customize configurations for your project
5. **Setup Git Hooks** - `npm run setup-hooks` or `make setup-hooks`

### Customization
- **Modify Configurations** - Edit `.eslintrc.js`, `pyproject.toml`
- **Adjust Thresholds** - Update quality check scripts
- **Add Custom Rules** - Extend existing configurations
- **Framework-Specific Setup** - Use provided integration examples

## File Management Standards

- **500-Line Limit** - No file should exceed 500 lines (enforced by global development standards)
- **Automatic Splitting** - Split files by logical responsibilities when exceeding limit
- **Modular Design** - Prefer multiple focused files over single large files
- **Clean Separation** - Maintain clear interfaces between modules

## Troubleshooting

### Common Issues
- **Tool Not Found** - Run `make install-tools` or `npm install`
- **Git Hooks Not Working** - Ensure hooks are executable: `chmod +x .husky/*`
- **Type Errors** - Install type stubs: `pip install types-*` or `npm install @types/*`
- **Performance Issues** - Use `--source-dir` to limit scope or run specific categories

### Environment Verification
```bash
# JavaScript/TypeScript
make check-env                 # Verify all tools are available
node scripts/quality-check.cjs --help

# Python  
python python-quality-check.py --help
```

## Multi-Language Expansion

The system is designed for easy language addition:

1. **Create Edition Directory** - `editions/[language]/`
2. **Implement Quality Orchestrator** - Following the 11-step pattern
3. **Add Configuration Templates** - Language-specific tool configs
4. **Create Git Hooks** - Adapt templates for the language
5. **Update Setup Script** - Add language detection to `setup.js`
6. **Document Integration** - Language-specific README

The modular architecture ensures consistent quality standards across all supported languages while allowing language-specific optimizations.