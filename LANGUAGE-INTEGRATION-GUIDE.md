# Complete Quality Suite - Language Integration Guide

This guide explains how to add support for new programming languages to the Complete Quality Suite.

## 🎯 Overview

The Complete Quality Suite uses a modular architecture where each programming language has its own "edition" containing language-specific tools, configurations, and scripts.

## 📁 Architecture Overview

```
complete-quality-suite/
├── 📁 editions/                    # Language-specific editions
│   ├── javascript/                 # JavaScript/TypeScript edition (reference)
│   │   ├── *.js                   # Quality runners (4 scripts)
│   │   ├── *.json, *.js           # Configuration templates (3 files)
│   │   ├── hooks/                 # Git hooks (3 files)
│   │   └── workflows/             # CI/CD workflows (2 files)
│   └── [your-language]/           # Your new language edition
├── 🚀 setup.js                     # Setup orchestrator
├── 📄 README.md                    # Main documentation
└── 📄 LANGUAGE-INTEGRATION-GUIDE.md # This guide
```

## 🔧 Step-by-Step Integration Process

### Step 1: Create Edition Directory Structure

```bash
# Navigate to the Complete Quality Suite directory
cd complete-quality-suite

# Create your language edition structure
mkdir -p editions/[language-name]/{hooks,workflows}

# Example for Python:
mkdir -p editions/python/{hooks,workflows}
```

### Step 2: Create Quality Scripts

Create language-specific quality runners directly in `editions/[language]/`:

#### Required Scripts:

1. **Main Quality Runner** - `[language]-quality-check.{ext}`
2. **Formatting Script** - `[language]-format.{ext}`  
3. **Linting Script** - `[language]-lint.{ext}`
4. **Security Scanner** - `[language]-security.{ext}`

#### Example Python Structure:
```
editions/python/
├── python-quality-check.py        # Main orchestrator
├── python-format.py               # Black, isort, autopep8
├── python-lint.py                 # Pylint, flake8, ruff
├── python-security.py             # Bandit, safety, pip-audit
├── .pylintrc.template              # Configuration files
├── pyproject.toml.template         # Dependencies & settings
├── hooks/                          # Git hooks
└── workflows/                      # CI/CD workflows
```

#### Script Template Pattern:

Each script should follow this pattern:

```python
#!/usr/bin/env python3
"""
Complete Quality Suite - [Language] [Tool Type]
"""

import subprocess
import sys
import argparse

def run_tool(tool_name, args):
    """Run a quality tool with error handling"""
    try:
        result = subprocess.run([tool_name] + args, 
                              capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {tool_name}: PASSED")
            return True
        else:
            print(f"❌ {tool_name}: FAILED")
            print(result.stdout)
            print(result.stderr)
            return False
    except FileNotFoundError:
        print(f"⚠️  {tool_name}: NOT INSTALLED")
        return False

def main():
    parser = argparse.ArgumentParser(description='[Language] Quality Checks')
    parser.add_argument('--fix', action='store_true', help='Auto-fix issues')
    parser.add_argument('--quiet', action='store_true', help='Quiet output')
    args = parser.parse_args()
    
    # Add your quality tool logic here
    success = True
    
    # Example: Run formatter
    if not run_tool('black', ['--check', '.'] if not args.fix else ['.']):
        success = False
    
    # Example: Run linter  
    if not run_tool('pylint', ['src/']):
        success = False
        
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
```

### Step 3: Create Configuration Templates

Add configuration templates directly in `editions/[language]/`:

#### Configuration Files Needed:

1. **Linter Configuration** - `.pylintrc.template`, `.eslintrc.template`, etc.
2. **Formatter Configuration** - `pyproject.toml.template`, `.prettierrc.template`, etc.
3. **Security Configuration** - `bandit.yaml.template`, etc.
4. **Type Checker Configuration** - `mypy.ini.template`, `tsconfig.json.template`, etc.

#### Template Naming Convention:
- Use `.template` suffix for all configuration files
- The setup process will copy these and remove the `.template` suffix
- Support merging with existing configurations

### Step 4: Create Dependencies File

Create a dependencies file for your language:

```bash
# Python
touch editions/python/requirements.template.txt

# Ruby  
touch editions/ruby/Gemfile.template

# Go
touch editions/go/go.mod.template

# Node.js (additional packages)
touch editions/javascript/package.additions.json
```

#### Example Python requirements.template.txt:
```
# Complete Quality Suite - Python Edition
black>=23.0.0
isort>=5.12.0
pylint>=3.0.0
flake8>=6.0.0
bandit>=1.7.5
mypy>=1.8.0
pytest>=7.4.0
```

### Step 5: Add Language Detection

Update `setup.js` to detect your language:

```javascript
// Find this section in setup.js and add your detection logic

function detectProjectLanguages() {
    const languages = [];
    
    // Existing JavaScript detection...
    if (fileExists('package.json') || hasFiles(['.js', '.ts'])) {
        languages.push('javascript');
    }
    
    // ADD YOUR LANGUAGE DETECTION HERE:
    
    // Python detection
    if (fileExists('requirements.txt') || 
        fileExists('pyproject.toml') || 
        hasFiles(['.py'])) {
        languages.push('python');
    }
    
    // Go detection
    if (fileExists('go.mod') || hasFiles(['.go'])) {
        languages.push('go');
    }
    
    // Ruby detection
    if (fileExists('Gemfile') || hasFiles(['.rb'])) {
        languages.push('ruby');
    }
    
    return languages;
}
```

### Step 6: Create Edition README

Create `editions/[language]/README.md` with:

1. **Tool Overview**: What quality tools are included
2. **Installation**: How to install language-specific dependencies  
3. **Configuration**: How to customize settings
4. **Usage**: How to run quality checks
5. **Integration**: How it works with existing tools

#### README Template:
```markdown
# Complete Quality Suite - [Language] Edition

Quality assurance tools for [Language] projects.

## 🛠️ Tools Included

### Formatting
- **[Tool]**: Description

### Linting  
- **[Tool]**: Description

### Security
- **[Tool]**: Description

## 🚀 Usage

```bash
# Install dependencies
[package-manager] install -r requirements.template.txt

# Run quality checks
[language] editions/[language]/scripts/[language]-quality-check.[ext]
```

## ⚙️ Configuration

Configuration files are automatically copied when the edition is enabled:
- `[config-file]` - Description

## 🔧 Integration

This edition integrates with existing [Language] tooling by:
- Preserving existing configurations
- Merging with existing setups
- Working with existing workflows
```

### Step 7: Update Package Scripts

Add npm scripts for your language in `package.template.json`:

```json
{
  "scripts": {
    "[language]:quality": "[language] editions/[language]/scripts/[language]-quality-check.[ext]",
    "[language]:format": "[language] editions/[language]/scripts/[language]-format.[ext]",
    "[language]:lint": "[language] editions/[language]/scripts/[language]-lint.[ext]",
    "[language]:security": "[language] editions/[language]/scripts/[language]-security.[ext]"
  }
}
```

### Step 8: Create Git Hooks Integration

Update git hooks to include your language:

```bash
# In .husky/pre-commit
#!/usr/bin/env sh

# Existing JavaScript checks...
npm run javascript:quality:fast

# ADD YOUR LANGUAGE:
# Check if [language] edition is configured
if [ -f "editions/[language]/scripts/[language]-quality-check.[ext]" ]; then
  echo "🔍 Running [language] quality checks..."
  [language] editions/[language]/scripts/[language]-quality-check.[ext] --fast
fi
```

### Step 9: Add CI/CD Support

Create workflow templates in `editions/[language]/workflows/`:

```yaml
# .github/workflows/[language]-quality.yml
name: [Language] Quality Checks

on:
  push:
    paths:
      - '**/*.[ext]'
      - 'editions/[language]/**'

jobs:
  [language]-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup [Language]
        uses: actions/setup-[language]@v3
        with:
          [language]-version: '[version]'
      
      - name: Install dependencies
        run: [install-command]
      
      - name: Run quality checks
        run: npm run [language]:quality
```

## 🧪 Testing Your Integration

### Basic Testing

1. **Create Test Project**:
   ```bash
   mkdir test-[language]-project
   cd test-[language]-project
   
   # Create sample files for your language
   echo "print('hello')" > main.[ext]
   ```

2. **Copy Quality Suite**:
   ```bash
   cp -r /path/to/complete-quality-suite .
   ```

3. **Run Setup**:
   ```bash
   cd complete-quality-suite
   node setup.js
   ```

4. **Test Quality Checks**:
   ```bash
   cd ..
   npm run [language]:quality
   ```

### Integration Testing

- Test with existing projects in your language
- Verify configuration merging works correctly
- Test git hooks integration
- Verify CI/CD workflows

## 📚 Reference: JavaScript Edition

Use the existing JavaScript edition as a reference:

```
editions/javascript/
├── scripts/
│   ├── quality-check.js           # Main runner (633 lines)
│   ├── maintainability-check.js   # Maintainability analysis (468 lines)
│   ├── duplication-check.js       # Code duplication (341 lines)
│   └── setup-hooks.js             # Git hooks setup (497 lines)
├── configs/
│   ├── .eslintrc.example.js       # ESLint configuration (169 lines)
│   ├── .jscpd.json                # Duplication config (30 lines)
│   └── .lintstagedrc.js           # Lint-staged config (30 lines)
├── hooks/                          # Git hooks
└── workflows/                      # GitHub Actions
```

## 🎯 Best Practices for Language Integration

### 1. Tool Selection
- **Choose mature tools**: Select well-established tools for your language
- **Cover all aspects**: Formatting, linting, security, testing
- **Consider alternatives**: Provide options for different preferences

### 2. Configuration Philosophy
- **Sensible defaults**: Start with reasonable default configurations
- **Customizable**: Allow easy customization for specific needs
- **Non-intrusive**: Don't break existing setups

### 3. Performance Considerations
- **Fast feedback**: Optimize for quick developer feedback
- **Incremental checks**: Support checking only changed files
- **Parallel execution**: Run independent checks in parallel

### 4. Error Handling
- **Graceful degradation**: Handle missing tools gracefully
- **Clear messages**: Provide clear error messages and suggestions
- **Exit codes**: Use proper exit codes for CI/CD integration

### 5. Documentation
- **Complete examples**: Provide working examples
- **Migration guides**: Help users migrate from existing setups
- **Troubleshooting**: Document common issues and solutions

## 🚀 Contribution Guidelines

When contributing a new language edition:

1. **Follow the architecture**: Use the standardized structure
2. **Test thoroughly**: Test with real projects
3. **Document completely**: Provide comprehensive documentation
4. **Consider maintainability**: Write maintainable, readable code
5. **Version compatibility**: Support reasonable version ranges

## 📞 Support

For help with language integration:

1. **Study the JavaScript edition** as a reference implementation
2. **Check existing issues** for similar integrations
3. **Create detailed documentation** for your integration
4. **Test with real projects** before contributing

---

**Last updated**: 2025-07-09  
**Compatible with**: Complete Quality Suite v1.0.0  
**Reference implementation**: JavaScript/TypeScript Edition 