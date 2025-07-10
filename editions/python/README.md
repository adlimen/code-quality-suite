# AdLimen Code Quality Suite - Python Edition

Comprehensive quality orchestrator with 11-step modular workflow for Python projects. Enterprise-grade quality assurance with enhanced Safety vulnerability handling and auto-fix capabilities.

## 🛠️ 11-Step Quality Workflow

### Step 1: 🎨 Code Formatting
- **Black**: Code formatting and style consistency (PEP 8 compliant)

### Step 2: ✨ Import Sorting
- **isort**: Import sorting and organization (compatible with Black)

### Step 3: 🔍 Code Linting
- **Ruff**: Fast Python linter (replaces flake8, pylint with better performance)

### Step 4: ⚙️ Type Checking
- **MyPy**: Static type checking with strict mode configuration

### Step 5: 🔒 Security Scanning
- **Bandit**: Security vulnerability scanner for Python code

### Step 6: 🔒 Vulnerability Checking
- **Safety**: Dependency vulnerability checker with enhanced warning handling

### Step 7: 🔍 Dead Code Detection
- **Vulture**: Dead code detection and cleanup

### Step 8: 🎯 Code Duplication
- **Custom Duplication Check**: Python-based code duplication detection

### Step 9: 📊 Complexity Analysis
- **Radon CC**: Cyclomatic complexity measurement

### Step 10: 🏆 Maintainability Analysis
- **Radon MI**: Maintainability index calculation

### Step 11: ⚙️ Dependency Analysis
- **pipdeptree**: Dependency tree analysis and validation

### 🧪 Additional Features
- **Enhanced Safety Handling**: Treats vulnerability findings as warnings rather than failures
- **Auto-fix Support**: Automatic fixing for Black, isort, and Ruff
- **Modular Architecture**: Run individual steps or complete suites
- **Public Repo Friendly**: Uses `safety check` instead of requiring authentication

## 📁 Components Overview

```
editions/python/
├── 📜 Scripts (2 files)
│   ├── python-quality-check.py        # Enhanced 11-step orchestrator
│   └── python-duplication-check.py    # Code duplication analysis
├── ⚙️ Configuration Templates (2 files)
│   ├── pyproject.toml.template         # Complete tool configuration
│   └── requirements.template.txt       # Quality tool dependencies
├── 🪝 Git Hooks (3 files)
│   ├── pre-commit                     # Pre-commit quality checks
│   ├── pre-push                       # Pre-push validations
│   └── commit-msg                     # Commit message validation
└── 🔄 CI/CD Workflows (2 files)
    ├── python-quality.yml             # Quality checks workflow
    └── python-tests.yml               # Testing workflow
```

## 🚀 Quick Start

### 1. Setup in Your Project

```bash
# Copy the AdLimen Code Quality Suite to your project
cp -r adlimen-code-quality-suite /path/to/your/project/

# Navigate to the Python edition
cd adlimen-code-quality-suite/editions/python/

# Make scripts executable
chmod +x python-quality-check.py python-duplication-check.py
```

### 2. Install Quality Tools

```bash
# Option 1: Install from requirements template
pip install -r requirements.template.txt

# Option 2: Install development dependencies (if using pyproject.toml)
pip install -e ".[dev]"

# Option 3: Install individual tools
pip install black isort ruff mypy bandit safety vulture radon
```

### 3. Configure Your Project

```bash
# Copy configuration template
cp pyproject.toml.template /path/to/your/project/pyproject.toml

# Edit the template to match your project
# Update project name, dependencies, and paths as needed
```

### 4. Run Quality Checks

```bash
# Run all quality checks
python python-quality-check.py all

# Run with auto-fix where possible
python python-quality-check.py all --fix

# Run specific categories
python python-quality-check.py formatting --fix
python python-quality-check.py linting
python python-quality-check.py security
python python-quality-check.py analysis

# Run individual tools
python python-quality-check.py black --fix
python python-quality-check.py mypy
```

## ⚙️ Configuration

### Tool Configurations

The `pyproject.toml.template` includes optimized configurations for all quality tools:

**Black Configuration:**
- Line length: 88 characters
- Target Python versions: 3.8-3.12
- Exclude patterns for common directories

**Ruff Configuration:**
- Comprehensive rule set covering:
  - pycodestyle (E, W)
  - pyflakes (F)
  - isort (I)
  - flake8-bugbear (B)
  - pyupgrade (UP)
  - And many more modern Python practices
- Maximum complexity: 10
- Per-file ignores for tests and `__init__.py`

**MyPy Configuration:**
- Strict type checking enabled
- Check untyped definitions
- Warn on redundant casts and unused ignores
- Show error codes for better debugging

**Bandit Configuration:**
- Exclude test directories
- Skip common false positives
- Focus on real security vulnerabilities

### Project Structure Support

The Python edition works with various project structures:

```python
# Standard structure
your-project/
├── src/your_package/    # Source code
├── tests/              # Test files
├── pyproject.toml      # Configuration
└── README.md

# Alternative structure
your-project/
├── your_package/       # Source code
├── tests/             # Test files
├── setup.py           # Legacy setup
└── requirements.txt   # Dependencies
```

## 📊 Usage Examples

### Daily Development Workflow

```bash
# Quick formatting and linting
python python-quality-check.py formatting --fix
python python-quality-check.py linting

# Full quality check before commit
python python-quality-check.py all

# Security analysis before release
python python-quality-check.py security
```

### Continuous Integration

```bash
# Install tools
pip install -r requirements.template.txt

# Run quality checks (no auto-fix in CI)
python python-quality-check.py all --quiet

# Run with specific source directory
python python-quality-check.py all --source-dir=src/mypackage
```

### Code Analysis and Metrics

```bash
# Analyze code duplication
python python-duplication-check.py --verbose

# Set custom duplication threshold
python python-duplication-check.py --threshold=5

# Generate detailed reports
python python-duplication-check.py --format=json
```

## 🎯 Quality Metrics and Thresholds

### Default Quality Standards

```python
# Complexity Thresholds
MAX_CYCLOMATIC_COMPLEXITY = 10    # Radon CC
MAX_FUNCTION_LENGTH = 50          # Lines per function
MAX_FILE_LENGTH = 500             # Lines per file

# Duplication Thresholds
MIN_DUPLICATE_LINES = 5           # Minimum lines for duplication
MAX_DUPLICATION_PERCENTAGE = 10   # Maximum allowed duplication

# Type Coverage
MYPY_STRICT_MODE = True           # Enforce type annotations
```

### Quality Categories and Scoring

**🎨 Formatting (Required)**
- Black compliance: 100% required
- Import organization: isort standards
- Line length: 88 characters (Black standard)

**🔍 Linting (Required)**
- Ruff rules: Comprehensive modern Python practices
- Type hints: MyPy strict mode
- Complexity: Cyclomatic complexity ≤ 10

**🔒 Security (Critical)**
- No security vulnerabilities: Bandit scan
- Safe dependencies: Safety vulnerability check
- Input validation: Secure coding practices

**📊 Analysis (Recommended)**
- Code duplication: ≤ 10%
- Dead code: Minimal unused code
- Maintainability: High maintainability index

## 🔧 Advanced Configuration

### Custom Source Directories

```bash
# Analyze specific package
python python-quality-check.py all --source-dir=src/mypackage

# Multiple source directories (modify script or run multiple times)
python python-quality-check.py all --source-dir=src
python python-quality-check.py all --source-dir=lib
```

### Integration with Existing Tools

**Pre-commit Integration:**
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: python-quality
        name: Python Quality Checks
        entry: python complete-quality-suite/editions/python/python-quality-check.py
        args: [required, --fix]
        language: system
        types: [python]
```

**Make Integration:**
```makefile
# Makefile
quality:
	python complete-quality-suite/editions/python/python-quality-check.py all

quality-fix:
	python complete-quality-suite/editions/python/python-quality-check.py all --fix

duplication:
	python complete-quality-suite/editions/python/python-duplication-check.py
```

### IDE Integration

**VS Code Settings:**
```json
{
    "python.formatting.provider": "black",
    "python.linting.enabled": true,
    "python.linting.ruffEnabled": true,
    "python.linting.mypyEnabled": true,
    "python.linting.banditEnabled": true,
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.organizeImports": true
    }
}
```

## 📈 Reports and Analytics

### Generated Reports

The Python edition generates comprehensive reports:

```
reports/python/
├── quality-summary.json          # Overall quality metrics
├── duplication/
│   └── duplication-report.json   # Code duplication analysis
├── security/
│   ├── bandit-report.json        # Security vulnerabilities
│   └── safety-report.json        # Dependency vulnerabilities
└── coverage/                     # Test coverage reports (if enabled)
    ├── htmlcov/
    └── coverage.xml
```

### Metrics Tracked

- **Code Quality Score**: Composite score from all tools
- **Security Risk Level**: Based on vulnerability findings
- **Maintainability Index**: Radon-calculated maintainability
- **Test Coverage**: Percentage of code covered by tests
- **Complexity Metrics**: Cyclomatic complexity distribution
- **Duplication Percentage**: Amount of duplicated code

## 🚨 Troubleshooting

### Common Issues

1. **Tool Not Found Errors**
   ```bash
   # Install missing tools
   pip install black isort ruff mypy bandit safety vulture radon
   
   # Verify installation
   python python-quality-check.py --help
   ```

2. **MyPy Type Errors**
   ```bash
   # Install type stubs for common packages
   pip install types-requests types-PyYAML types-setuptools
   
   # Run MyPy with less strict settings initially
   mypy --ignore-missing-imports src/
   ```

3. **Bandit False Positives**
   ```python
   # Add to pyproject.toml
   [tool.bandit]
   skips = ["B101", "B601"]  # Skip specific checks
   
   # Or use inline comments
   password = input("Password: ")  # nosec B101
   ```

4. **Performance Issues**
   ```bash
   # Run on specific directories only
   python python-quality-check.py all --source-dir=src/core
   
   # Skip slow tools for development
   python python-quality-check.py required --fix
   ```

### Integration with Different Project Types

**Django Projects:**
```python
# pyproject.toml additions
[tool.ruff.per-file-ignores]
"*/migrations/*" = ["ALL"]
"*/settings/*" = ["F405", "F403"]

[tool.bandit]
exclude_dirs = ["migrations", "static"]
```

**Flask Projects:**
```python
# pyproject.toml additions
[tool.mypy.overrides]
module = "app.*"
ignore_missing_imports = true

[tool.vulture]
ignore_decorators = ["@app.route", "@bp.route"]
```

**Data Science Projects:**
```python
# pyproject.toml additions
[tool.ruff.extend-ignore]
ignore = ["T201"]  # Allow print statements

[tool.vulture]
ignore_names = ["plt", "pd", "np"]  # Common data science aliases
```

## 🎯 Best Practices

### Development Workflow
1. **Setup**: Install quality tools and configure pyproject.toml
2. **Development**: Run `formatting --fix` frequently
3. **Pre-commit**: Use `required --fix` for essential checks
4. **Pre-push**: Run `all` for comprehensive validation
5. **CI/CD**: Automate with `all --quiet` in pipelines

### Code Quality Standards
- **Complexity**: Keep functions under 10 cyclomatic complexity
- **Length**: Limit functions to 50 lines, files to 500 lines
- **Types**: Use type hints consistently (MyPy strict mode)
- **Security**: Address all Bandit and Safety warnings
- **Duplication**: Keep code duplication under 10%

### Team Collaboration
- **Shared Configuration**: Use pyproject.toml in version control
- **Quality Gates**: Enforce quality checks in CI/CD
- **Documentation**: Document custom rules and exceptions
- **Training**: Ensure team understands quality standards

## 📞 Support

For help with the Python edition:

1. **Check Configuration**: Ensure pyproject.toml is properly configured
2. **Verify Dependencies**: Check that all required tools are installed
3. **Review Logs**: Run with `--verbose` for detailed output
4. **Validate Setup**: Use `--help` to see available options

## 🔗 Integration Examples

### GitHub Actions

```yaml
name: Python Quality Checks

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r complete-quality-suite/editions/python/requirements.template.txt
      - name: Run quality checks
        run: |
          python complete-quality-suite/editions/python/python-quality-check.py all
```

### Docker Integration

```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install quality tools
COPY complete-quality-suite/editions/python/requirements.template.txt /tmp/
RUN pip install -r /tmp/requirements.template.txt

# Copy source code
COPY . /app
WORKDIR /app

# Run quality checks
RUN python complete-quality-suite/editions/python/python-quality-check.py all
```

---

**Last Updated**: July 10, 2025  
**Compatible with**: Python 3.8+, Complete Quality Suite v1.0.0  
**Based on**: Levero backend quality infrastructure