# Complete Quality Suite - JavaScript/TypeScript Edition

Comprehensive quality assurance tools and workflows for JavaScript and TypeScript projects featuring a **11-Step Modular Quality Workflow** with unified command interface.

## 🛠️ 11-Step Modular Quality Workflow

### **Step 1: Formatting** 🎨
- **Prettier**: Code formatting and style consistency

### **Step 2: Import Sorting** 📦
- **ESLint Import Plugin**: Automatic import organization and cleanup

### **Step 3: Linting** 🔍
- **ESLint + SonarJS**: Code quality rules and best practices

### **Step 4: Type Checking** 🔧
- **TypeScript Compiler**: Type validation and static analysis

### **Step 5: Security Scanning** 🔒
- **ESLint Security Plugin**: Code security vulnerability detection

### **Step 6: Vulnerability Checking** 🛡️
- **npm audit**: Dependency vulnerability scanning

### **Step 7: Dead Code Detection** 💀
- **ts-prune**: Unused code identification

### **Step 8: Duplication Analysis** 🔄
- **jscpd**: Code duplication detection and reporting

### **Step 9: Complexity Analysis** 📊
- **ESLint Complexity Rules**: Cyclomatic complexity measurement

### **Step 10: Maintainability** 📈
- **ESComplex**: Maintainability index calculation

### **Step 11: Dependency Analysis** 🔗
- **dependency-cruiser**: Dependency graph analysis and validation

## 🎯 Unified Command Interface

All quality tools are accessible through a single, unified interface:

```bash
# Individual Steps (1-11)
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

# Quality Suites
node scripts/quality-check.cjs all                   # Complete 11-step workflow
node scripts/quality-check.cjs all --fix             # With auto-fix where possible
node scripts/quality-check.cjs required              # Essential checks only
node scripts/quality-check.cjs security              # Security analysis only
node scripts/quality-check.cjs analysis              # Code analysis tools only

# With Auto-Fix
node scripts/quality-check.cjs prettier --fix        # Auto-format code
node scripts/quality-check.cjs import-sorting --fix  # Auto-fix import organization
node scripts/quality-check.cjs linting --fix         # Auto-fix linting issues
```

## 📁 Components Overview

```
editions/javascript/
├── 📜 Scripts (3 files)
│   ├── quality-check.cjs           # Main orchestrator (11-step workflow)
│   ├── maintainability-check.js    # Maintainability analysis (ES modules)
│   └── duplication-check.js        # Code duplication detection (ES modules)
├── ⚙️ Configurations (5 directories)
│   ├── .eslint-configs/            # Modular ESLint configurations
│   │   ├── base.js                 # Base configuration
│   │   ├── import-sorting.js       # Import organization rules
│   │   ├── linting.js              # Code quality rules
│   │   ├── security.js             # Security rules
│   │   └── complexity.js           # Complexity rules
│   ├── .dependency-cruiser.cjs     # Dependency analysis configuration
│   ├── package-template.json       # Package.json template with npm scripts
│   └── Makefile-template           # Makefile template with make commands
├── 🪝 Git Hooks Templates
│   ├── pre-commit                  # Pre-commit quality checks
│   ├── pre-push                    # Pre-push validations
│   └── commit-msg                  # Commit message validation
└── 🔄 CI/CD Workflows
    ├── javascript-quality.yml      # Quality checks workflow
    ├── javascript-tests.yml        # Testing workflow
    └── pre-merge.yml               # Pre-merge validations
```

## 🚀 Quick Start - Choose Your Interface

**Choose your preferred development interface:**

📋 **[npm Scripts Interface](README-npm.md)** - Perfect for Node.js teams  
🔧 **[Make Commands Interface](README-make.md)** - Ideal for Unix-like systems  
⚖️ **[Interface Comparison](README-comparison.md)** - Help choosing the right interface  

### 1. Copy Files to Your Project

```bash
# Copy the JavaScript edition to your project
cp -r complete-quality-suite/editions/javascript/scripts ./scripts
cp -r complete-quality-suite/editions/javascript/.eslint-configs ./.eslint-configs
cp complete-quality-suite/editions/javascript/.dependency-cruiser.cjs ./.dependency-cruiser.cjs

# Copy template files
cp complete-quality-suite/editions/javascript/package-template.json ./package.json.new
cp complete-quality-suite/editions/javascript/Makefile-template ./Makefile

# Choose your interface (npm or make or both)
```

### 2. Interface-Specific Setup

**For detailed setup instructions, see the interface-specific guides:**

- **npm Scripts**: See [README-npm.md](README-npm.md) for package.json configuration
- **Make Commands**: See [README-make.md](README-make.md) for Makefile setup  
- **Both Interfaces**: See [README-comparison.md](README-comparison.md) for dual setup

**Quick Setup Examples:**

#### npm Interface
```bash
# See complete setup in README-npm.md
npm install --save-dev [quality-tools...]
# Update package.json with npm scripts
npm run quality
```

#### Make Interface
```bash
# See complete setup in README-make.md
make setup-env            # Automated environment setup
make quality              # Run quality checks
```

### 3. Install Dependencies

**Automated Installation (Make):**
```bash
make install-tools        # Install all quality dependencies automatically
```

**Manual Installation (npm):**
```bash
# See README-npm.md for complete dependency list
npm install --save-dev [quality-tools...]
```

**Dependency list available in interface-specific guides.**

## ⚙️ Configuration

### ESLint Configuration

Copy and customize the ESLint configuration:

```bash
cp complete-quality-suite/editions/javascript/.eslintrc.example.js .eslintrc.js
```

The configuration includes:
- **TypeScript Support**: Full TypeScript parsing and rules
- **Security Rules**: Security vulnerability detection
- **Import Organization**: Automatic import sorting
- **Complexity Rules**: Cyclomatic complexity limits
- **Best Practices**: React, Node.js, and general JavaScript best practices

### Git Hooks Setup

Git hooks are automatically configured during setup. Manual setup:

```bash
# Copy hooks
cp complete-quality-suite/editions/javascript/hooks/* .husky/

# Make hooks executable
chmod +x .husky/*
```

### CI/CD Workflows

Copy GitHub Actions workflows:

```bash
mkdir -p .github/workflows
cp complete-quality-suite/editions/javascript/workflows/* .github/workflows/
```

## 🔄 GitHub Actions Workflows

### 1. JavaScript Quality Workflow (`javascript-quality.yml`)

**Features:**
- ✅ Multi-Node.js version testing (18, 20)
- ✅ Advanced dependency caching
- ✅ ESLint caching for faster runs
- ✅ Parallel job execution
- ✅ Security analysis integration
- ✅ Performance analysis
- ✅ Artifact upload for reports

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests with JS/TS file changes
- Configuration file changes

**Caching Strategy:**
```yaml
# npm dependencies caching
key: ${{ runner.os }}-npm-${{ matrix.node-version }}-${{ hashFiles('**/package-lock.json') }}

# ESLint cache
key: ${{ runner.os }}-eslint-${{ hashFiles('**/.eslintrc*', '**/package-lock.json') }}
```

### 2. JavaScript Tests Workflow (`javascript-tests.yml`)

**Features:**
- ✅ Separate unit and integration test jobs
- ✅ E2E test support (Playwright/Cypress)
- ✅ Coverage reporting with Codecov
- ✅ Test artifact collection
- ✅ Quality gate enforcement
- ✅ Comprehensive test summary

**Test Matrix:**
- **Unit Tests**: Node.js 18, 20
- **Integration Tests**: Node.js 18, 20  
- **E2E Tests**: Node.js 20 (on PRs and main)

**Quality Gate Criteria:**
- ✅ Unit tests must pass
- ✅ E2E tests pass or can be skipped
- ✅ Coverage thresholds met

## 📊 Usage Examples

### Daily Development Workflow

```bash
# Quick quality check with auto-fix
npm run quality:fix
# OR
make quality-fix

# Full 11-step analysis
npm run quality
# OR  
make quality

# Essential checks only (fast)
npm run quality:fast
# OR
make quality-fast

# Individual steps
npm run format:fix            # Step 1: Format code
npm run import-sorting:fix    # Step 2: Fix imports
npm run lint:fix              # Step 3: Fix linting issues
npm run type-check            # Step 4: Check types
npm run security              # Step 5-6: Security analysis
npm run dead-code             # Step 7: Find unused code
npm run duplication           # Step 8: Check duplicates
npm run complexity            # Step 9: Check complexity
npm run maintainability       # Step 10: Maintainability score
npm run dependencies          # Step 11: Dependency analysis
```

### Pre-commit Workflow

```bash
# Automatic (via git hooks) - runs the essential checks
git commit -m "feat: add new feature"

# Manual pre-commit check
npm run quality:fix && npm test
# OR
make pre-commit
```

### CI/CD Integration

The workflows automatically run on:
- ✅ **Push**: Quality checks + tests
- ✅ **Pull Request**: Full quality gate + E2E tests
- ✅ **Main Branch**: Performance analysis + deployment checks

## 🎯 Quality Metrics

### Code Quality Thresholds

```javascript
// ESLint Complexity Rules
'complexity': ['error', { max: 10 }]
'max-depth': ['error', 4]
'max-nested-callbacks': ['error', 3]

// Duplication Thresholds
minLines: 5           // Minimum lines for duplication
minTokens: 50         // Minimum tokens for duplication
threshold: 0.1        // 10% duplication threshold

// Maintainability Index
threshold: 70         // Minimum maintainability score
```

### Coverage Requirements

```javascript
// Jest/Vitest Coverage
coverageThreshold: {
  global: {
    branches: 80,
    functions: 80,
    lines: 80,
    statements: 80
  }
}
```

## 🔧 Customization

### Adding Custom Rules

1. **ESLint Rules**: Modify `.eslintrc.js`
2. **Prettier Config**: Add `.prettierrc`
3. **TypeScript**: Customize `tsconfig.json`
4. **Quality Thresholds**: Edit quality check scripts

### Framework-Specific Setup

#### React Projects
```bash
npm install --save-dev \
  eslint-plugin-react \
  eslint-plugin-react-hooks \
  eslint-plugin-jsx-a11y
```

#### Next.js Projects
```bash
npm install --save-dev \
  @next/eslint-config-next \
  eslint-config-next
```

#### Node.js Projects
```bash
npm install --save-dev \
  eslint-plugin-node \
  eslint-plugin-security
```

## 📈 Reports and Analytics

### Generated Reports

- **📊 HTML Reports**: Coverage, duplication, complexity
- **📄 JSON Data**: Machine-readable metrics
- **📝 Markdown**: CI/CD summaries
- **🔍 Console**: Real-time developer feedback

### Report Locations

```
reports/
├── coverage/              # Test coverage reports
├── duplication/           # Code duplication analysis
├── maintainability/       # Maintainability metrics
├── eslint/               # ESLint results
└── summary/              # Overall quality summary
```

## 🚨 Troubleshooting

### Common Issues

1. **ESLint Cache Issues**
   ```bash
   rm .eslintcache
   npm run lint
   ```

2. **TypeScript Errors**
   ```bash
   npm run type-check
   # Fix errors, then:
   npm run quality
   ```

3. **Node Modules Cache**
   ```bash
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **Git Hooks Not Working**
   ```bash
   chmod +x .husky/*
   git config core.hooksPath .husky
   ```

### Performance Optimization

1. **Enable ESLint Cache**
   ```bash
   npm run lint -- --cache
   ```

2. **Parallel Execution**
   ```bash
   npm run quality -- --parallel
   ```

3. **Incremental TypeScript**
   ```json
   {
     "compilerOptions": {
       "incremental": true,
       "tsBuildInfoFile": ".tsbuildinfo"
     }
   }
   ```

## 🔗 Integration Examples

### VS Code Integration

```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
```

### Package.json Scripts Integration

```json
{
  "scripts": {
    "dev": "npm run quality:fix && next dev",
    "build": "npm run quality && npm run test && next build",
    "test:watch": "jest --watch --coverage",
    "pre-commit": "npm run quality:fix && npm run test:unit"
  }
}
```

## 📞 Support

For help with the JavaScript/TypeScript edition:

1. **Check Configuration**: Ensure all config files are properly set up
2. **Verify Dependencies**: Check that all required packages are installed
3. **Review Logs**: Check workflow logs in GitHub Actions
4. **Validate Setup**: Run `node complete-quality-suite/setup.js` again

## 🎯 Best Practices

### Development Workflow
1. **Enable git hooks** for automatic quality checks
2. **Run quality checks** before committing
3. **Fix issues incrementally** rather than all at once
4. **Monitor reports** for quality trends

### CI/CD Optimization
1. **Use caching** for faster builds
2. **Parallelize jobs** when possible
3. **Fail fast** on critical issues
4. **Cache test results** for quicker feedback

### Team Collaboration
1. **Shared configuration** via version control
2. **Quality metrics** in PR reviews
3. **Regular maintenance** of quality thresholds
4. **Documentation** of custom rules and exceptions

---

## 🎖️ Features

✅ **11-Step Modular Workflow** - Comprehensive quality assurance  
✅ **Unified Command Interface** - Single entry point for all tools  
✅ **ES Modules + CommonJS** - Future-proof architecture  
✅ **Auto-Fix Capabilities** - Intelligent issue resolution  
✅ **Triple Interface** - npm scripts, make commands, direct execution  
✅ **Modular ESLint Configs** - Organized by concern  
✅ **Zero Conflicts** - Tools work together seamlessly  
✅ **Performance Optimized** - Caching and parallel execution  
✅ **CI/CD Ready** - GitHub Actions workflows included  
✅ **Framework Agnostic** - Works with any JavaScript/TypeScript project  

---

**Last Updated**: July 10, 2025  
**Architecture**: 11-Step Modular Quality Workflow  
**Compatible with**: Node.js 18+, TypeScript 5.4+, ESLint 9+  
**Frameworks**: React, Next.js, Vue.js, Node.js, Express, Nest.js  
**ES Modules**: ✅ Future-proof with CommonJS compatibility 