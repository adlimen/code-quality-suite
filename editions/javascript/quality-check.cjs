#!/usr/bin/env node

/**
 * Levero Frontend Quality Checks Runner
 * Comprehensive TypeScript/JavaScript quality assurance system
 * Based on Complete Quality Suite architecture
 */

const { spawn } = require("child_process");
const path = require("path");
const fs = require("fs");

// Colors and formatting
const colors = {
  reset: "\x1b[0m",
  bright: "\x1b[1m",
  red: "\x1b[31m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  blue: "\x1b[34m",
  magenta: "\x1b[35m",
  cyan: "\x1b[36m",
  white: "\x1b[37m",
};

const emojis = {
  success: "✅",
  error: "❌",
  warning: "⚠️",
  info: "ℹ️",
  rocket: "🚀",
  wrench: "🔧",
  shield: "🔒",
  magnifying: "🔍",
  art: "🎨",
  chart: "📊",
  gear: "⚙️",
};

// Configuration
let SOURCE_DIR = "src";
let PROJECT_NAME = "Complete Quality Suite";

// Tool definitions with commands and descriptions - 11-Step Modular Workflow
const tools = {
  // 1. Formatting
  prettier: {
    command: "npx",
    args: ["prettier", "--check", "."],
    fixArgs: ["prettier", "--write", "."],
    description: "Code formatting check (Prettier)",
    category: "formatting",
    icon: emojis.art,
    order: 1,
  },

  // 2. Import sorting
  "import-sorting": {
    command: "npx",
    args: ["eslint", ".", "--config", ".eslint-configs/import-sorting.js"],
    fixArgs: [
      "eslint",
      ".",
      "--config",
      ".eslint-configs/import-sorting.js",
      "--fix",
    ],
    description: "Import sorting and organization (ESLint + import plugin)",
    category: "import-sorting",
    icon: emojis.gear,
    order: 2,
  },

  // 3. Linting
  linting: {
    command: "npx",
    args: ["eslint", ".", "--config", ".eslint-configs/linting.js"],
    fixArgs: ["eslint", ".", "--config", ".eslint-configs/linting.js", "--fix"],
    description: "Code quality linting (ESLint + SonarJS)",
    category: "linting",
    icon: emojis.magnifying,
    order: 3,
  },

  // ESLint standalone tool
  eslint: {
    command: "npx",
    args: ["eslint", ".", "--config", ".eslint-configs/linting.js"],
    fixArgs: ["eslint", ".", "--config", ".eslint-configs/linting.js", "--fix"],
    description: "ESLint standalone execution",
    category: "linting",
    icon: emojis.magnifying,
    order: 3,
  },

  // 4. Type checking
  "type-check": {
    command: "npx",
    args: ["tsc", "--noEmit"],
    description: "TypeScript type checking",
    category: "type-checking",
    icon: emojis.gear,
    order: 4,
  },

  // 5. Security scanning
  "security-scanning": {
    command: "npx",
    args: ["eslint", ".", "--config", ".eslint-configs/security.js"],
    fixArgs: [
      "eslint",
      ".",
      "--config",
      ".eslint-configs/security.js",
      "--fix",
    ],
    description: "Security vulnerability scanning (ESLint security plugin)",
    category: "security-scanning",
    icon: emojis.shield,
    order: 5,
  },

  // 6. Vulnerability checking
  "vulnerability-checking": {
    command: "npm",
    args: ["audit", "--audit-level=moderate"],
    description: "Dependency vulnerability checking (npm audit)",
    category: "vulnerability-checking",
    icon: emojis.shield,
    order: 6,
  },

  // 7. Dead code detection
  "dead-code": {
    command: "npx",
    args: ["ts-prune"],
    description: "Dead code detection (ts-prune)",
    category: "dead-code",
    icon: emojis.chart,
    order: 7,
  },

  // 8. Duplication analysis
  duplication: {
    command: "npx",
    args: [
      "jscpd",
      ".",
      "--reporters",
      "console,html",
      "--output",
      "./reports/duplication",
      "--ignore",
      "**/node_modules/**,**/.next/**,**/dist/**",
    ],
    description: "Code duplication detection (jscpd)",
    category: "duplication",
    icon: emojis.chart,
    order: 8,
  },

  // 9. Complexity analysis
  complexity: {
    command: "npx",
    args: ["eslint", ".", "--config", ".eslint-configs/complexity.js"],
    description: "Code complexity analysis (ESLint complexity rules)",
    category: "complexity",
    icon: emojis.chart,
    order: 9,
  },

  // 10. Maintainability
  maintainability: {
    command: "node",
    args: ["scripts/maintainability-check.js"],
    description: "Maintainability index calculation (ESComplex)",
    category: "maintainability",
    icon: emojis.chart,
    order: 10,
  },

  // 11. Dependency analysis
  "dependency-check": {
    command: "npx",
    args: ["depcruise", "--validate", ".dependency-cruiser.cjs", "src/"],
    description: "Dependency analysis and validation (dependency-cruiser)",
    category: "dependency-check",
    icon: emojis.chart,
    order: 11,
  },
};

// Tool groups for batch execution - 11-Step Modular Workflow
const toolGroups = {
  // Individual categories (following the correct order)
  formatting: ["prettier"],
  "import-sorting": ["import-sorting"],
  linting: ["linting"],
  "type-checking": ["type-check"],
  "security-scanning": ["security-scanning"],
  "vulnerability-checking": ["vulnerability-checking"],
  "dead-code": ["dead-code"],
  duplication: ["duplication"],
  complexity: ["complexity"],
  maintainability: ["maintainability"],
  "dependency-check": ["dependency-check"],

  // Logical groupings
  security: ["security-scanning", "vulnerability-checking"],
  analysis: [
    "dead-code",
    "duplication",
    "complexity",
    "maintainability",
    "dependency-check",
  ],

  // Quick execution sets
  required: ["prettier", "import-sorting", "linting", "type-check"], // Essential checks
  fast: ["prettier", "import-sorting", "linting", "type-check"], // Alias for required
  essential: ["prettier", "linting", "type-check"], // Minimal essential

  // Complete workflow (all 11 steps in correct order)
  all: [
    "prettier", // 1. Formatting
    "import-sorting", // 2. Import sorting
    "linting", // 3. Linting
    "type-check", // 4. Type checking
    "security-scanning", // 5. Security scanning
    "vulnerability-checking", // 6. Vulnerability checking
    "dead-code", // 7. Dead code detection
    "duplication", // 8. Duplication analysis
    "complexity", // 9. Complexity analysis
    "maintainability", // 10. Maintainability
    "dependency-check", // 11. Dependency analysis
  ],
};

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    tool: args[0] || "help",
    fix: args.includes("--fix"),
    verbose: args.includes("--verbose") || args.includes("-v"),
    quiet: args.includes("--quiet") || args.includes("-q"),
    parallel: args.includes("--parallel"),
    sourceDir: null,
    projectName: null,
  };

  // Extract source directory
  const sourceDirIndex = args.findIndex((arg) => arg === "--source-dir");
  if (sourceDirIndex !== -1 && args[sourceDirIndex + 1]) {
    options.sourceDir = args[sourceDirIndex + 1];
    SOURCE_DIR = options.sourceDir;
  }

  // Extract project name
  const projectNameIndex = args.findIndex((arg) => arg === "--project-name");
  if (projectNameIndex !== -1 && args[projectNameIndex + 1]) {
    options.projectName = args[projectNameIndex + 1];
    PROJECT_NAME = options.projectName;
  }

  return options;
}

/**
 * Print colored and formatted messages
 */
function printMessage(message, color = colors.white, emoji = "") {
  console.log(`${emoji} ${color}${message}${colors.reset}`);
}

/**
 * Print tool category header
 */
function printCategoryHeader(category, tools) {
  const categoryEmojis = {
    formatting: emojis.art,
    linting: emojis.magnifying,
    security: emojis.shield,
    analysis: emojis.chart,
  };

  console.log(`\n${"=".repeat(60)}`);
  printMessage(
    `${categoryEmojis[category]} ${category.toUpperCase()} CHECKS (${tools.length} tools)`,
    colors.cyan + colors.bright,
  );
  console.log("=".repeat(60));
}

/**
 * Print help information
 */
function printHelp() {
  console.log(`${colors.cyan}${colors.bright}
╔══════════════════════════════════════════════════════════════╗
║                    ${PROJECT_NAME} Quality Checks                    ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}

${colors.yellow}Usage:${colors.reset}
  node scripts/quality-check.js [tool] [options]

${colors.yellow}Quality Workflow (11 Steps):${colors.reset}
  ${colors.green}all${colors.reset}               Run complete 11-step quality workflow
  ${colors.green}required/fast${colors.reset}    Run essential checks (formatting, import-sorting, linting, type-check)
  ${colors.green}essential${colors.reset}        Run minimal checks (formatting, linting, type-check)

${colors.yellow}Category Groups:${colors.reset}
  ${colors.green}formatting${colors.reset}        Code formatting (Prettier)
  ${colors.green}import-sorting${colors.reset}    Import organization (ESLint + import plugin)
  ${colors.green}linting${colors.reset}          Code quality linting (ESLint + SonarJS)
  ${colors.green}type-checking${colors.reset}     TypeScript type validation
  ${colors.green}security${colors.reset}         Security scanning + vulnerability checking
  ${colors.green}analysis${colors.reset}         Dead code + duplication + complexity + maintainability + dependencies

${colors.yellow}Individual Steps:${colors.reset}
  ${colors.blue}1. prettier${colors.reset}           Code formatting (Prettier)
  ${colors.blue}2. import-sorting${colors.reset}     Import organization (ESLint import plugin)
  ${colors.blue}3. linting${colors.reset}            Code quality rules (ESLint + SonarJS)
  ${colors.blue}4. type-check${colors.reset}         TypeScript type checking
  ${colors.blue}5. security-scanning${colors.reset}  Security vulnerability scanning (ESLint security)
  ${colors.blue}6. vulnerability-checking${colors.reset} Dependency vulnerabilities (npm audit)
  ${colors.blue}7. dead-code${colors.reset}          Dead code detection (ts-prune)
  ${colors.blue}8. duplication${colors.reset}        Code duplication detection (jscpd)
  ${colors.blue}9. complexity${colors.reset}         Code complexity analysis (ESLint complexity)
  ${colors.blue}10. maintainability${colors.reset}   Maintainability index (ESComplex)
  ${colors.blue}11. dependency-check${colors.reset}  Dependency analysis (dependency-cruiser)

${colors.yellow}Options:${colors.reset}
  ${colors.green}--fix${colors.reset}             Auto-fix issues where possible
  ${colors.green}--verbose, -v${colors.reset}     Verbose output
  ${colors.green}--quiet, -q${colors.reset}       Quiet output
  ${colors.green}--parallel${colors.reset}        Run compatible tools in parallel
  ${colors.green}--source-dir${colors.reset}      Source directory (default: src)
  ${colors.green}--project-name${colors.reset}    Project name for reports

${colors.yellow}Examples:${colors.reset}
  ${colors.cyan}node scripts/quality-check.js all${colors.reset}                    # Complete 11-step workflow
  ${colors.cyan}node scripts/quality-check.js required --fix${colors.reset}         # Essential checks with auto-fix
  ${colors.cyan}node scripts/quality-check.js import-sorting --fix${colors.reset}   # Fix import organization
  ${colors.cyan}node scripts/quality-check.js security${colors.reset}               # Security analysis only
  ${colors.cyan}node scripts/quality-check.js analysis${colors.reset}               # All analysis tools

${colors.yellow}Quality Categories (11-Step Workflow):${colors.reset}
  ${emojis.art} ${colors.magenta}1. Formatting:${colors.reset} Code style consistency (Prettier)
  ${emojis.gear} ${colors.magenta}2. Import Sorting:${colors.reset} Import organization and cleanup
  ${emojis.magnifying} ${colors.magenta}3. Linting:${colors.reset} Code quality and best practices
  ${emojis.gear} ${colors.magenta}4. Type Checking:${colors.reset} TypeScript type validation
  ${emojis.shield} ${colors.magenta}5. Security Scanning:${colors.reset} Code security vulnerabilities
  ${emojis.shield} ${colors.magenta}6. Vulnerability Checking:${colors.reset} Dependency vulnerabilities
  ${emojis.chart} ${colors.magenta}7. Dead Code Detection:${colors.reset} Unused code identification
  ${emojis.chart} ${colors.magenta}8. Duplication Analysis:${colors.reset} Code duplication detection
  ${emojis.chart} ${colors.magenta}9. Complexity Analysis:${colors.reset} Cyclomatic complexity metrics
  ${emojis.chart} ${colors.magenta}10. Maintainability:${colors.reset} Maintainability index calculation
  ${emojis.chart} ${colors.magenta}11. Dependency Check:${colors.reset} Dependency graph analysis
`);
}

/**
 * Check if a tool is available
 */
async function checkToolAvailability(toolName) {
  const tool = tools[toolName];
  if (!tool) return false;

  return new Promise((resolve) => {
    let checkCmd, checkArgs;

    if (tool.command === "npx") {
      // For npx tools, check if the actual tool exists
      const actualTool = tool.args[0];
      checkCmd = "npx";
      checkArgs = [actualTool, "--version"];
    } else {
      checkCmd = tool.command;
      checkArgs = ["--version"];
    }

    const child = spawn(checkCmd, checkArgs, {
      stdio: "ignore",
    });

    child.on("close", (code) => {
      resolve(code === 0);
    });

    child.on("error", () => {
      resolve(false);
    });
  });
}

/**
 * Run a single tool
 */
async function runTool(toolName, options = {}) {
  const tool = tools[toolName];
  if (!tool) {
    printMessage(`Unknown tool: ${toolName}`, colors.red, emojis.error);
    return false;
  }

  // Check if tool is available
  const isAvailable = await checkToolAvailability(toolName);
  if (!isAvailable) {
    printMessage(
      `${tool.description} - TOOL NOT INSTALLED`,
      colors.yellow,
      emojis.warning,
    );
    printMessage(`Install with: npm install -D ${tool.command}`, colors.yellow);
    return false;
  }

  // Choose args based on fix mode
  const args = options.fix && tool.fixArgs ? tool.fixArgs : tool.args;

  // Replace SOURCE_DIR placeholder in args
  const processedArgs = args.map((arg) =>
    arg.replace(/src\//g, `${SOURCE_DIR}/`),
  );

  return new Promise((resolve) => {
    if (!options.quiet) {
      printMessage(`${tool.description}`, colors.white, tool.icon);
      if (options.verbose) {
        console.log(`  Command: ${tool.command} ${processedArgs.join(" ")}`);
      }
    }

    const startTime = Date.now();
    const child = spawn(tool.command, processedArgs, {
      stdio: options.quiet ? "pipe" : "inherit",
      cwd: process.cwd(),
    });

    let output = "";
    if (options.quiet && child.stdout) {
      child.stdout.on("data", (data) => {
        output += data.toString();
      });
    }

    child.on("close", (code) => {
      const duration = Date.now() - startTime;

      if (code === 0) {
        if (!options.quiet) {
          printMessage(
            `${tool.description} - PASSED (${duration}ms)`,
            colors.green,
            emojis.success,
          );
        }
        resolve(true);
      } else {
        if (!options.quiet) {
          printMessage(
            `${tool.description} - FAILED (${duration}ms)`,
            colors.red,
            emojis.error,
          );
        } else if (output) {
          console.log(output);
        }
        resolve(false);
      }
    });

    child.on("error", (error) => {
      printMessage(
        `${tool.description} - ERROR: ${error.message}`,
        colors.red,
        emojis.error,
      );
      resolve(false);
    });
  });
}

/**
 * Run multiple tools in sequence
 */
async function runToolsSequential(toolNames, options = {}) {
  const results = [];

  for (const toolName of toolNames) {
    const result = await runTool(toolName, options);
    results.push({ tool: toolName, success: result });
  }

  return results;
}

/**
 * Run multiple tools in parallel (for compatible tools)
 */
async function runToolsParallel(toolNames, options = {}) {
  const promises = toolNames.map((toolName) =>
    runTool(toolName, options).then((success) => ({ tool: toolName, success })),
  );

  return Promise.all(promises);
}

/**
 * Create reports directory
 */
function ensureReportsDirectory() {
  const reportsDir = path.join(process.cwd(), "reports");
  if (!fs.existsSync(reportsDir)) {
    fs.mkdirSync(reportsDir, { recursive: true });
  }
}

/**
 * Print summary of results
 */
function printSummary(results, options = {}) {
  console.log(`\n${"=".repeat(60)}`);
  printMessage(
    `${emojis.chart} QUALITY CHECKS SUMMARY`,
    colors.cyan + colors.bright,
  );
  console.log("=".repeat(60));

  const totalTools = results.length;
  const passedTools = results.filter((r) => r.success).length;
  const failedTools = totalTools - passedTools;

  console.log(`Total tools: ${totalTools}`);
  printMessage(`Passed: ${passedTools}`, colors.green, emojis.success);
  if (failedTools > 0) {
    printMessage(`Failed: ${failedTools}`, colors.red, emojis.error);
  }

  // List failed tools
  const failed = results.filter((r) => !r.success);
  if (failed.length > 0) {
    console.log(`\n${colors.red}Failed tools:${colors.reset}`);
    failed.forEach((result) => {
      console.log(`  ${emojis.error} ${result.tool}`);
    });
  }

  // Success message
  if (failedTools === 0) {
    printMessage(
      `\n${emojis.rocket} All quality checks passed!`,
      colors.green + colors.bright,
    );
    if (options.fix) {
      printMessage(
        "Some issues may have been auto-fixed.",
        colors.yellow,
        emojis.info,
      );
    }
  } else {
    printMessage(
      `\n${emojis.error} ${failedTools} quality check(s) failed!`,
      colors.red + colors.bright,
    );
    if (!options.fix) {
      printMessage(
        "Try running with --fix to automatically fix some issues.",
        colors.yellow,
        emojis.info,
      );
    }
  }

  return failedTools === 0;
}

/**
 * Main execution function
 */
async function main() {
  const options = parseArgs();

  // Handle help
  if (
    options.tool === "help" ||
    options.tool === "--help" ||
    options.tool === "-h"
  ) {
    printHelp();
    return;
  }

  // Create reports directory
  ensureReportsDirectory();

  // Print header
  if (!options.quiet) {
    console.log(`${colors.cyan}${colors.bright}
╔══════════════════════════════════════════════════════════════╗
║                    ${PROJECT_NAME} Quality Checks                    ║
║                     Source Directory: ${SOURCE_DIR}                      ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}
`);
  }

  let toolsToRun = [];
  let results = [];

  // Determine which tools to run
  if (toolGroups[options.tool]) {
    toolsToRun = toolGroups[options.tool];
  } else if (tools[options.tool]) {
    toolsToRun = [options.tool];
  } else {
    printMessage(
      `Unknown tool or group: ${options.tool}`,
      colors.red,
      emojis.error,
    );
    printMessage(
      'Use "help" to see available options',
      colors.yellow,
      emojis.info,
    );
    process.exit(1);
  }

  // Special handling for fix mode - run formatting tools in sequence to avoid conflicts
  if (options.fix && options.tool === "all") {
    if (!options.quiet) {
      printMessage(
        "Running auto-fix in sequence to avoid conflicts...",
        colors.yellow,
        emojis.wrench,
      );
    }

    // Step 1: Formatting (prettier)
    if (!options.quiet)
      printCategoryHeader("formatting", toolGroups.formatting);
    const formattingResults = await runToolsSequential(
      toolGroups.formatting,
      options,
    );
    results.push(...formattingResults);

    // Step 2: Linting (eslint with fix, then type-check)
    if (!options.quiet) printCategoryHeader("linting", toolGroups.linting);
    const lintingResults = await runToolsSequential(["eslint"], {
      ...options,
      fix: true,
    });
    results.push(...lintingResults);

    // Type check without fix
    const typeCheckResult = await runTool("type-check", {
      ...options,
      fix: false,
    });
    results.push({ tool: "type-check", success: typeCheckResult });

    // Step 3: Security and Analysis (no fix mode)
    for (const category of ["security", "analysis"]) {
      const categoryTools = toolGroups[category];
      if (!options.quiet) printCategoryHeader(category, categoryTools);
      const categoryResults = await runToolsSequential(categoryTools, {
        ...options,
        fix: false,
      });
      results.push(...categoryResults);
    }
  } else {
    // Normal execution - group by category for better output
    if (options.tool === "all") {
      for (const category of [
        "formatting",
        "linting",
        "security",
        "analysis",
      ]) {
        const categoryTools = toolGroups[category].filter((tool) =>
          toolsToRun.includes(tool),
        );
        if (categoryTools.length === 0) continue;

        if (!options.quiet) printCategoryHeader(category, categoryTools);

        if (options.parallel && category !== "formatting") {
          // Run in parallel for compatible tools
          const categoryResults = await runToolsParallel(
            categoryTools,
            options,
          );
          results.push(...categoryResults);
        } else {
          // Run in sequence
          const categoryResults = await runToolsSequential(
            categoryTools,
            options,
          );
          results.push(...categoryResults);
        }
      }
    } else {
      // Single tool or group
      if (options.parallel && toolsToRun.length > 1) {
        results = await runToolsParallel(toolsToRun, options);
      } else {
        results = await runToolsSequential(toolsToRun, options);
      }
    }
  }

  // Print summary
  const success = printSummary(results, options);

  process.exit(success ? 0 : 1);
}

// Handle uncaught errors
process.on("uncaughtException", (error) => {
  printMessage(`Uncaught error: ${error.message}`, colors.red, emojis.error);
  process.exit(1);
});

process.on("unhandledRejection", (reason) => {
  printMessage(`Unhandled rejection: ${reason}`, colors.red, emojis.error);
  process.exit(1);
});

// Run main function
if (require.main === module) {
  main().catch((error) => {
    printMessage(`Error: ${error.message}`, colors.red, emojis.error);
    process.exit(1);
  });
}

module.exports = {
  runTool,
  runToolsSequential,
  runToolsParallel,
  tools,
  toolGroups,
};