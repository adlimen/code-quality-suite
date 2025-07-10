# AdLimen Code Quality Suite

A comprehensive code quality assurance system designed to be easily integrated into any development workflow. This modular system provides dedicated quality tooling for multiple programming languages with consistent patterns and practices.

## 🌟 Available Editions

### 📘 JavaScript/TypeScript Edition
- **Location**: `editions/javascript/`
- **Description**: Complete quality assurance for JS/TS projects
- **Status**: ✅ Available

### 🐍 Python Edition
- **Location**: `editions/python/`
- **Description**: 11-step modular quality workflow with Safety vulnerability handling
- **Status**: ✅ Available (Enhanced!)

### 🔮 Future Editions
- **Go Edition**: Planned
- **Rust Edition**: Planned
- **Java Edition**: Planned

## 🎯 Overview

This system provides a complete quality assurance toolkit including:

- 🎨 **Formatting**: Prettier, ESLint import sorting
- 🔍 **Linting**: ESLint, TypeScript checking
- 🔒 **Security**: ESLint Security, npm audit, SonarJS
- 📊 **Analysis**: ts-prune (dead code), complexity analysis, dependency-cruiser, jscpd (duplication), typhonjs-escomplex (maintainability)
- 🚀 **Performance**: Lighthouse, Bundle analyzer
- 🪝 **Git Hooks**: Pre-commit, pre-push automation with Husky
- ⚙️ **CI/CD**: GitHub Actions workflows

## 🚀 Quick Start

### Option 1: Automatic Setup (Recommended)

Copy the entire `complete-quality-suite` folder to your project root and run:

```bash
# Navigate to the quality system folder
cd complete-quality-suite

# Run automatic setup
node setup.js
# or
./setup.js

# Install dependencies
cd ..
npm install

# Setup git hooks
npm run setup-hooks

# Run initial quality check
npm run quality
```

The automatic setup will:

- ✅ Merge package.json with required dependencies and scripts
- ✅ Copy configuration files (.jscpd.json, .lintstagedrc.js)
- ✅ Install quality check scripts in scripts/ folder
- ✅ Setup git hooks in .husky/ folder
- ✅ Add GitHub Actions workflows to .github/workflows/
- ✅ Create necessary directories (reports/, etc.)

### Option 2: Manual Integration

1. **Copy Files**: Copy all files from this folder to your project
2. **Merge package.json**: Add the devDependencies and scripts to your existing package.json
3. **Update Scripts**: Modify the source directory if different from `src/`
4. **Configure**: Adjust `.eslintrc`, `.jscpd.json`, and other configs as needed

### 3. Basic Usage

```bash
# Run all quality checks
make quality

# Run with auto-fix
make quality-fix

# Run specific checks
make lint
make format
make security-check
make complexity
```

## 📦 What's Included

### Core Scripts

- **`scripts/quality-check.js`** - Main runner for all quality tools
- **`scripts/maintainability-check.js`** - Maintainability analysis with scoring
- **`scripts/duplication-check.js`** - Code duplication detection
- **`scripts/setup-hooks.js`** - Development environment setup

### Configuration Files

- **`configs/.lintstagedrc.js`** - Lint-staged configuration for git hooks
- **`configs/.jscpd.json`** - jscpd duplication detection settings
- **`configs/.eslintrc.example.js`** - Example ESLint configuration with all quality rules

### Git Hooks Templates

- **`hooks/pre-commit`** - Pre-commit hook for staged files validation
- **`hooks/pre-push`** - Pre-push hook for comprehensive quality checks
- **`hooks/commit-msg`** - Commit message format validation

### Templates

- **`package-template.json`** - Template package.json with all required dependencies
- **`Makefile-template`** - Template Makefile with development commands
- **`setup.js`** - Automatic setup script for easy integration

### CI/CD Workflows

- **`workflows/quality-checks.yml`** - GitHub Actions for continuous quality checks
- **`workflows/pre-merge.yml`** - Comprehensive pre-merge validation workflow

## 🛠️ Available Commands

### NPM Scripts

```bash
# Quality checks
npm run quality          # Run all quality checks
npm run quality:fix      # Run all quality checks with auto-fix
npm run quality:fast     # Run essential quality checks only
npm run quality:security # Run security analysis only

# Individual tools
npm run format          # Format code with Prettier
npm run lint           # Run ESLint
npm run type-check     # TypeScript type checking
npm run dead-code      # Find dead code with ts-prune
npm run complexity     # Analyze code complexity
npm run security       # Security analysis
npm run maintainability # Maintainability analysis
npm run duplication    # Code duplication check

# Git hooks
npm run pre-commit     # Run pre-commit checks
npm run setup-hooks    # Setup git hooks and environment
```

### Make Commands

```bash
# Development
make install          # Install dependencies and setup
make quality          # Run all quality checks
make quality-fix      # Run quality checks with auto-fix
make quality-fast     # Run essential checks only

# Individual checks
make lint            # Run linting
make format          # Format code
make type-check      # Type checking
make security-check  # Security analysis
make dead-code      # Dead code detection
make complexity     # Complexity analysis
make dependencies   # Dependency analysis
```

### Node.js Direct

```bash
# Run quality checks directly
node scripts/quality-check.js all
node scripts/quality-check.js all --fix
node scripts/quality-check.js formatting --fix
node scripts/quality-check.js linting
node scripts/quality-check.js security

# Run maintainability analysis
node scripts/maintainability-check.js

# Run duplication check
node scripts/duplication-check.js

# Setup environment
node scripts/setup-hooks.js
```

## ⚙️ Configuration

### Source Directory

By default, the system analyzes the `src/` directory. To change this, you can:

1. **For quality-check.js**: Use the `--source-dir` flag:

   ```bash
   node scripts/quality-check.js all --source-dir="lib/"
   ```

2. **For other scripts**: Edit the scripts and update the source directory path

3. **For package.json scripts**: Update the scripts to include the source directory:
   ```json
   {
     "scripts": {
       "lint": "eslint --ext .ts,.tsx,.js,.jsx lib/"
     }
   }
   ```

### Project Name

The maintainability script can be configured with your project name:

```bash
node scripts/maintainability-check.js --project-name="My Project"
```

### ESLint Configuration

Create or update `.eslintrc.js`:

```javascript
module.exports = {
  extends: [
    'next/core-web-vitals', // For Next.js projects
    // or other base configs
  ],
  plugins: ['security', 'sonarjs', 'unused-imports'],
  rules: {
    // Complexity rules
    complexity: ['warn', 10],
    'max-depth': ['warn', 4],
    'max-lines': ['warn', 300],
    'max-lines-per-function': ['warn', 50],
    'max-params': ['warn', 4],
    'max-statements': ['warn', 20],

    // Security rules
    'security/detect-object-injection': 'error',

    // SonarJS rules
    'sonarjs/cognitive-complexity': ['error', 15],
    'sonarjs/no-duplicate-string': 'error',

    // Import rules
    'unused-imports/no-unused-imports': 'error',
  },
};
```

### Prettier Configuration

Create `.prettierrc`:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
```

## 🔧 Integration Examples

### For React/Next.js Projects

```json
{
  "devDependencies": {
    // Copy from package-template.json
  },
  "scripts": {
    // Add scripts from package-template.json
    "quality": "node scripts/quality-check.js all",
    "pre-commit": "npx lint-staged"
  }
}
```

### For Node.js/Express Projects

```bash
# Update source directory in scripts
node scripts/quality-check.js all --source-dir="src/"

# or for different structure
node scripts/quality-check.js all --source-dir="lib/"
```

### For Vue.js Projects

Update `.lintstagedrc.js`:

```javascript
module.exports = {
  '**/*.{ts,js,vue}': [
    'prettier --write',
    'eslint --fix',
    'npm run type-check',
  ],
  // ... other patterns
};
```

## 📊 Quality Metrics

### Maintainability Score

The maintainability check provides a score from 0-100 based on:

- Code complexity (cyclomatic complexity)
- Function length
- File length
- Nesting depth
- Parameter count
- Statement count

**Scoring:**

- **90-100**: Excellent maintainability
- **80-89**: Good maintainability
- **70-79**: Acceptable maintainability
- **60-69**: Needs improvement
- **Below 60**: Requires refactoring

### Duplication Threshold

The duplication check flags code blocks with:

- Minimum 10 lines
- Minimum 70 tokens
- Configurable threshold (default: 10%)

### Security Analysis

Includes checks for:

- Known vulnerabilities (npm audit)
- Security anti-patterns (ESLint security)
- Code complexity issues (SonarJS)

## 🚀 CI/CD Integration

### GitHub Actions

Copy the workflow files to `.github/workflows/`:

- `quality-checks.yml` - Runs on every push/PR
- `pre-merge.yml` - Comprehensive checks before merging

### Other CI Systems

The scripts can be integrated with any CI system:

```bash
# Basic CI pipeline
npm ci
npm run quality
npm run test
npm run build
```

## 🔍 Troubleshooting

### Common Issues

1. **"Command not found" errors**

   ```bash
   # Ensure all dependencies are installed
   npm install

   # Check if tools are available
   npx eslint --version
   npx prettier --version
   ```

2. **Git hooks not running**

   ```bash
   # Reinstall hooks
   npm run setup-hooks

   # Check hook files are executable
   chmod +x .husky/pre-commit
   chmod +x .husky/pre-push
   ```

3. **TypeScript errors**

   ```bash
   # Ensure TypeScript is configured
   npx tsc --init

   # Check tsconfig.json is properly configured
   npm run type-check
   ```

4. **ESLint configuration conflicts**
   - Check for multiple ESLint config files
   - Ensure the config extends the right base configurations
   - Verify plugin dependencies are installed

### Performance Issues

For large codebases:

1. **Exclude directories** in `.jscpd.json`:

   ```json
   {
     "ignore": ["node_modules/**", "dist/**", "coverage/**"]
   }
   ```

2. **Run checks in parallel**:

   ```bash
   # Use --quiet flag for faster execution
   node scripts/quality-check.js all --quiet
   ```

3. **Limit scope** for development:
   ```bash
   # Check only changed files
   npm run pre-commit
   ```

## 📚 Best Practices

### Development Workflow

1. **Setup**: Run `npm run setup-hooks` after cloning
2. **Development**: Let pre-commit hooks catch issues early
3. **Before PR**: Run `npm run quality` for full check
4. **CI/CD**: Automate with GitHub Actions or similar

### Code Quality Standards

- **Complexity**: Keep cyclomatic complexity under 10
- **Function length**: Maximum 50 lines per function
- **File length**: Maximum 300 lines per file
- **Duplication**: Keep below 10% duplication threshold
- **Security**: Address all security warnings

### Maintenance

- **Update dependencies** regularly: `npm update`
- **Review quality reports** weekly
- **Adjust thresholds** based on project needs
- **Monitor CI/CD** pipeline performance

## 🤝 Contributing

To improve this quality system:

1. Test with different project types
2. Add new quality tools as needed
3. Improve configuration templates
4. Enhance documentation

## 📄 License

This quality system is extracted from the Nutry project and is provided as-is for reuse in other projects.

## 🔗 Related Tools

- [ESLint](https://eslint.org/) - Linting
- [Prettier](https://prettier.io/) - Code formatting
- [Husky](https://typicode.github.io/husky/) - Git hooks
- [lint-staged](https://github.com/okonet/lint-staged) - Run linters on staged files
- [jscpd](https://github.com/kucherenko/jscpd) - Code duplication detection
- [ts-prune](https://github.com/nadeesha/ts-prune) - Dead code detection
- [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) - Dependency analysis

## 🌟 About AdLimen Code Quality Suite Family

This comprehensive quality system is designed with a modular architecture to easily support multiple programming languages. The system is structured to accommodate current and future language editions:

```
adlimen-code-quality-suite/
├── 📁 editions/
│   ├── javascript/           # JS/TS tools, configs, hooks, workflows
│   ├── python/              # Python 11-step workflow (Enhanced!)
│   ├── [go]/                # Future: Go quality tools
│   └── [any-language]/      # Future: Any language edition
├── 🚀 setup.js              # Multi-language setup orchestrator
├── 📄 README.md             # Integration documentation
└── 📄 LANGUAGE-INTEGRATION-GUIDE.md # Detailed integration guide
```

## 🔧 Adding New Language Editions

### Architecture for Language Integration

Each language edition follows this standardized structure:

```
editions/[language-name]/
├── scripts/                 # Language-specific quality runners
├── configs/                 # Configuration templates  
├── package.template.*       # Dependencies (requirements.txt, Gemfile, etc.)
└── README.md                # Language-specific documentation
```

### Integration Process

1. **Create Edition Directory**: `editions/your-language/`
2. **Add Quality Scripts**: Language-specific runners
3. **Configure Templates**: Linting, formatting, security configs
4. **Update Setup**: Modify `setup.js` for auto-detection
5. **Document Usage**: Create comprehensive README

### Example Integration Pattern

For any new language, follow this pattern:

```bash
# 1. Create structure
mkdir -p editions/python/{scripts,configs}

# 2. Add detection logic to setup.js
# 3. Create quality runner scripts
# 4. Add configuration templates
# 5. Test integration
```

**Supported integrations**: Any language with CLI quality tools can be integrated following this modular pattern.

📖 **For detailed integration instructions, see [LANGUAGE-INTEGRATION-GUIDE.md](./LANGUAGE-INTEGRATION-GUIDE.md)**

🔧 **For JavaScript/TypeScript usage, see [editions/javascript/README.md](./editions/javascript/README.md)**

🐍 **For Python usage, see [editions/python/README.md](./editions/python/README.md)**

## 📞 Support

For issues, questions, or contributions to the Complete Quality Suite:

1. **Documentation**: Check the comprehensive README and guides
2. **Issues**: Report bugs or request features
3. **Contributions**: Submit pull requests following the contribution guidelines
4. **Community**: Join discussions about quality practices

## 🎯 Quick Integration Example

For a typical Next.js project:

```bash
# 1. Copy Complete Quality Suite to your project
cp -r complete-quality-suite /path/to/your/nextjs-project/

# 2. Navigate and setup
cd /path/to/your/nextjs-project/complete-quality-suite
node setup.js

# 3. Install dependencies
cd ..
npm install

# 4. Run first quality check
npm run quality

# 5. Setup git hooks
npm run setup-hooks

# 6. You're ready to go!
git add .
git commit -m "feat: integrate Complete Quality Suite"
```

---

**Last updated**: 2025-07-09  
**Version**: 1.0.0  
**Edition**: JavaScript/TypeScript
