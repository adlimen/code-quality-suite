# Complete Quality Suite - JavaScript/TypeScript Edition (npm Interface)

Comprehensive quality assurance tools and workflows for JavaScript and TypeScript projects featuring a **11-Step Modular Quality Workflow** with **npm scripts interface**.

## 🛠️ 11-Step Modular Quality Workflow

### **Step 1: Formatting** 🎨
```bash
npm run format                # Check code formatting
npm run format:fix            # Auto-format code
```

### **Step 2: Import Sorting** 📦
```bash
npm run import-sorting        # Check import organization
npm run import-sorting:fix    # Auto-fix import sorting
```

### **Step 3: Linting** 🔍
```bash
npm run lint                  # Code quality rules and best practices
npm run lint:fix              # Auto-fix linting issues
```

### **Step 4: Type Checking** 🔧
```bash
npm run type-check            # TypeScript type validation
```

### **Step 5: Security Scanning** 🔒
```bash
npm run security              # Security vulnerability detection
```

### **Step 6: Vulnerability Checking** 🛡️
```bash
npm run security              # Includes npm audit for dependencies
```

### **Step 7: Dead Code Detection** 💀
```bash
npm run dead-code             # Find unused code with ts-prune
```

### **Step 8: Duplication Analysis** 🔄
```bash
npm run duplication           # Code duplication detection with jscpd
```

### **Step 9: Complexity Analysis** 📊
```bash
npm run complexity            # Cyclomatic complexity measurement
```

### **Step 10: Maintainability** 📈
```bash
npm run maintainability       # Maintainability index calculation
```

### **Step 11: Dependency Analysis** 🔗
```bash
npm run dependencies          # Dependency graph analysis
```

## 🎯 Quality Suites (npm Interface)

### **Complete Workflow**
```bash
npm run quality               # All 11 steps
npm run quality:fix           # All 11 steps with auto-fix
```

### **Focused Suites**
```bash
npm run quality:fast          # Essential checks only
npm run quality:security      # Security analysis only
npm run quality:analysis      # Code analysis tools only
```

## 🚀 Quick Start (npm Scripts)

### 1. Copy Files to Your Project

```bash
# Copy the JavaScript edition to your project
cp -r complete-quality-suite/editions/javascript/scripts ./scripts
cp -r complete-quality-suite/editions/javascript/.eslint-configs ./.eslint-configs
cp complete-quality-suite/editions/javascript/.dependency-cruiser.cjs ./.dependency-cruiser.cjs
```

### 2. Install Dependencies

```bash
npm install --save-dev \
  @typescript-eslint/eslint-plugin@^8.15.0 \
  @typescript-eslint/parser@^8.15.0 \
  dependency-cruiser@^16.0.0 \
  eslint@^9.0.0 \
  eslint-plugin-import@^2.30.0 \
  eslint-plugin-security@^3.0.1 \
  eslint-plugin-sonarjs@^2.0.4 \
  eslint-plugin-unused-imports@^4.1.4 \
  husky@^9.0.0 \
  jscpd@^4.0.5 \
  lint-staged@^15.2.0 \
  prettier@^3.1.0 \
  ts-prune@^0.10.0 \
  typescript@^5.4.0 \
  typhonjs-escomplex-module@^0.1.0
```

### 3. Configure Package.json

Merge these scripts into your existing `package.json`:

```json
{
  "type": "module",
  "scripts": {
    "format": "node scripts/quality-check.cjs prettier",
    "format:fix": "node scripts/quality-check.cjs prettier --fix",
    "import-sorting": "node scripts/quality-check.cjs import-sorting",
    "import-sorting:fix": "node scripts/quality-check.cjs import-sorting --fix",
    "lint": "node scripts/quality-check.cjs linting",
    "lint:fix": "node scripts/quality-check.cjs linting --fix",
    "type-check": "node scripts/quality-check.cjs type-checking",
    "security": "node scripts/quality-check.cjs security",
    "dead-code": "node scripts/quality-check.cjs dead-code",
    "duplication": "node scripts/quality-check.cjs duplication",
    "complexity": "node scripts/quality-check.cjs complexity",
    "maintainability": "node scripts/quality-check.cjs maintainability",
    "dependencies": "node scripts/quality-check.cjs dependency-check",
    "quality": "node scripts/quality-check.cjs all",
    "quality:fix": "node scripts/quality-check.cjs all --fix",
    "quality:fast": "node scripts/quality-check.cjs required",
    "quality:security": "node scripts/quality-check.cjs security",
    "quality:analysis": "node scripts/quality-check.cjs analysis"
  },
  "lint-staged": {
    "**/*.{ts,tsx,js,jsx}": [
      "npm run format:fix",
      "npm run import-sorting:fix",
      "npm run lint:fix"
    ]
  }
}
```

## 📊 Daily Development Workflow (npm)

### Quick Quality Check with Auto-Fix
```bash
npm run quality:fix
```

### Individual Step-by-Step Workflow
```bash
# Step 1-2: Code formatting and imports
npm run format:fix
npm run import-sorting:fix

# Step 3-4: Code quality and types
npm run lint:fix
npm run type-check

# Step 5-6: Security analysis
npm run security

# Step 7-8: Dead code and duplication
npm run dead-code
npm run duplication

# Step 9-11: Complexity and maintainability
npm run complexity
npm run maintainability
npm run dependencies
```

### Pre-commit Workflow
```bash
# Essential quality checks with auto-fix
npm run quality:fix && npm test
```

### Full Quality Analysis
```bash
# Complete 11-step analysis
npm run quality
```

## 🔧 Integration with Development Scripts

### Enhanced Development Workflow
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

### Git Hooks Integration
```json
{
  "lint-staged": {
    "**/*.{ts,tsx,js,jsx}": [
      "npm run format:fix",
      "npm run import-sorting:fix",
      "npm run lint:fix"
    ]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run quality && npm test"
    }
  }
}
```

## 🎯 npm Scripts Architecture

### Command Structure
```bash
# Individual tools (Steps 1-11)
npm run <tool>              # Check only
npm run <tool>:fix          # Check + auto-fix (where available)

# Quality suites
npm run quality             # All checks
npm run quality:fix         # All checks + auto-fix
npm run quality:<subset>    # Focused check groups
```

### Available npm Scripts
- **Individual Steps**: `format`, `import-sorting`, `lint`, `type-check`, `security`, `dead-code`, `duplication`, `complexity`, `maintainability`, `dependencies`
- **With Auto-Fix**: `format:fix`, `import-sorting:fix`, `lint:fix`
- **Quality Suites**: `quality`, `quality:fix`, `quality:fast`, `quality:security`, `quality:analysis`

## 📈 Performance Optimization (npm)

### Enable Caching
```bash
# ESLint caching
npm run lint -- --cache

# TypeScript incremental compilation
# Add to tsconfig.json:
{
  "compilerOptions": {
    "incremental": true,
    "tsBuildInfoFile": ".tsbuildinfo"
  }
}
```

### Parallel Execution
```bash
# Run multiple checks in parallel (if your CI supports it)
npm run format & npm run lint & npm run type-check
```

## 🔗 IDE Integration

### VS Code Settings
```json
{
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "npm.packageManager": "npm"
}
```

### VS Code Tasks
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Quality Check",
      "type": "npm",
      "script": "quality:fix",
      "group": "build",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

## 🎖️ Features (npm Interface)

✅ **Unified npm Scripts** - Consistent naming and behavior  
✅ **Auto-Fix Support** - Intelligent issue resolution with `:fix` suffix  
✅ **Quality Suites** - Grouped commands for different use cases  
✅ **ES Modules Ready** - Future-proof with `"type": "module"`  
✅ **Lint-Staged Integration** - Seamless git hooks support  
✅ **Incremental Builds** - Performance optimized for large projects  
✅ **Framework Agnostic** - Works with React, Next.js, Vue.js, Node.js  
✅ **Zero Configuration** - Works out of the box with sensible defaults  

## 🚨 Troubleshooting (npm)

### Common npm Issues

1. **Script not found**
   ```bash
   npm run <script-name>
   # Error: Missing script
   # Solution: Check package.json scripts section
   ```

2. **Permission errors**
   ```bash
   npm config set prefix ~/.npm-global
   export PATH=~/.npm-global/bin:$PATH
   ```

3. **Cache issues**
   ```bash
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install
   ```

### Performance Issues
```bash
# Check npm configuration
npm config list

# Use npm ci in CI environments
npm ci  # Faster, reliable, reproducible builds

# Enable parallel execution
npm config set fund false
npm config set audit false  # Skip audits for faster installs
```

---

**Last Updated**: July 10, 2025  
**Interface**: npm scripts  
**Architecture**: 11-Step Modular Quality Workflow  
**Compatible with**: Node.js 18+, npm 8+, TypeScript 5.4+, ESLint 9+  