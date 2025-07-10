#!/usr/bin/env node

/**
 * Levero Frontend Duplication Check
 * Advanced code duplication detection and reporting
 * Based on Complete Quality Suite architecture
 */

import { spawn } from "child_process";
import fs from "fs";
import path from "path";

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
};

const emojis = {
  success: "✅",
  error: "❌",
  warning: "⚠️",
  info: "ℹ️",
  chart: "📊",
  magnifying: "🔍",
  file: "📄",
};

// Configuration
const config = {
  sourceDir: "src",
  projectName: "Complete Quality Suite",
  thresholds: {
    minLines: 5,
    minTokens: 50,
    maxPercentage: 10, // Maximum allowed duplication percentage
  },
  outputDir: "reports/duplication",
  ignore: [
    "node_modules/**",
    "dist/**",
    "build/**",
    ".next/**",
    "coverage/**",
    "**/*.d.ts",
    "**/types/supabase.ts", // Auto-generated Supabase types
    "**/*generated*",
    "tests/**",
    "**/*.test.*",
    "**/*.spec.*",
  ],
};

/**
 * Parse command line arguments
 */
function parseArgs() {
  const args = process.argv.slice(2);
  const options = {
    verbose: args.includes("--verbose") || args.includes("-v"),
    quiet: args.includes("--quiet") || args.includes("-q"),
    threshold: null,
    sourceDir: null,
    projectName: null,
    format: "console", // console, html, json, all
  };

  // Extract threshold
  const thresholdIndex = args.findIndex((arg) =>
    arg.startsWith("--threshold="),
  );
  if (thresholdIndex !== -1) {
    options.threshold = parseFloat(args[thresholdIndex].split("=")[1]);
  }

  // Extract source directory
  const sourceDirIndex = args.findIndex((arg) =>
    arg.startsWith("--source-dir="),
  );
  if (sourceDirIndex !== -1) {
    options.sourceDir = args[sourceDirIndex].split("=")[1];
    config.sourceDir = options.sourceDir;
  }

  // Extract project name
  const projectNameIndex = args.findIndex((arg) =>
    arg.startsWith("--project-name="),
  );
  if (projectNameIndex !== -1) {
    options.projectName = args[projectNameIndex].split("=")[1];
    config.projectName = options.projectName;
  }

  // Extract format
  const formatIndex = args.findIndex((arg) => arg.startsWith("--format="));
  if (formatIndex !== -1) {
    options.format = args[formatIndex].split("=")[1];
  }

  return options;
}

/**
 * Print colored messages
 */
function printMessage(message, color = colors.reset, emoji = "") {
  console.log(`${emoji} ${color}${message}${colors.reset}`);
}

/**
 * Print help information
 */
function printHelp() {
  console.log(`${colors.cyan}${colors.bright}
╔══════════════════════════════════════════════════════════════╗
║                    Code Duplication Analysis                 ║
║                      ${config.projectName}                      ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}

${colors.yellow}Usage:${colors.reset}
  node scripts/duplication-check.js [options]

${colors.yellow}Options:${colors.reset}
  ${colors.green}--threshold=N${colors.reset}      Duplication threshold percentage (default: ${config.thresholds.maxPercentage}%)
  ${colors.green}--source-dir=DIR${colors.reset}   Source directory to analyze (default: ${config.sourceDir})
  ${colors.green}--project-name=NAME${colors.reset} Project name for reports (default: ${config.projectName})
  ${colors.green}--format=FORMAT${colors.reset}     Output format: console, html, json, all (default: console)
  ${colors.green}--verbose, -v${colors.reset}       Verbose output
  ${colors.green}--quiet, -q${colors.reset}         Quiet output
  ${colors.green}--help, -h${colors.reset}          Show this help

${colors.yellow}Thresholds:${colors.reset}
  Minimum lines: ${config.thresholds.minLines}
  Minimum tokens: ${config.thresholds.minTokens}
  Maximum duplication: ${config.thresholds.maxPercentage}%

${colors.yellow}Examples:${colors.reset}
  ${colors.cyan}node scripts/duplication-check.js${colors.reset}
  ${colors.cyan}node scripts/duplication-check.js --threshold=5${colors.reset}
  ${colors.cyan}node scripts/duplication-check.js --format=html${colors.reset}
  ${colors.cyan}node scripts/duplication-check.js --source-dir=lib --format=all${colors.reset}
`);
}

/**
 * Create jscpd configuration
 */
function createJscpdConfig() {
  const jscpdConfig = {
    minLines: config.thresholds.minLines,
    minTokens: config.thresholds.minTokens,
    threshold: config.thresholds.maxPercentage,
    ignore: config.ignore,
    output: config.outputDir,
    format: ["console", "html", "json"],
    mode: "mild",
    absolute: true,
    gitignore: true,
    verbose: false,
  };

  const configPath = path.join(process.cwd(), ".jscpd.json");
  fs.writeFileSync(configPath, JSON.stringify(jscpdConfig, null, 2));
  return configPath;
}

/**
 * Check if jscpd is available
 */
async function checkJscpdAvailability() {
  return new Promise((resolve) => {
    const child = spawn("npx", ["jscpd", "--version"], {
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
 * Run jscpd duplication detection
 */
async function runDuplicationCheck(options = {}) {
  // Check if jscpd is available
  const isAvailable = await checkJscpdAvailability();
  if (!isAvailable) {
    printMessage("jscpd is not installed", colors.red, emojis.error);
    printMessage(
      "Install with: npm install -D jscpd",
      colors.yellow,
      emojis.info,
    );
    return false;
  }

  // Create output directory
  const outputDir = path.join(process.cwd(), config.outputDir);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Create jscpd configuration
  const configPath = createJscpdConfig();

  if (!options.quiet) {
    printMessage(
      "Running code duplication analysis...",
      colors.cyan,
      emojis.magnifying,
    );
    if (options.verbose) {
      console.log(`  Source directory: ${config.sourceDir}`);
      console.log(`  Min lines: ${config.thresholds.minLines}`);
      console.log(`  Min tokens: ${config.thresholds.minTokens}`);
      console.log(`  Threshold: ${config.thresholds.maxPercentage}%`);
      console.log(`  Output: ${config.outputDir}`);
    }
  }

  return new Promise((resolve) => {
    const startTime = Date.now();
    const args = [config.sourceDir, "--config", configPath];

    if (options.format && options.format !== "all") {
      args.push("--reporters", options.format);
    }

    const child = spawn("npx", ["jscpd", ...args], {
      stdio: options.quiet ? "pipe" : "inherit",
      cwd: process.cwd(),
    });

    let _output = "";
    if (options.quiet && child.stdout) {
      child.stdout.on("data", (data) => {
        _output += data.toString();
      });
    }

    child.on("close", (_code) => {
      const duration = Date.now() - startTime;

      // Clean up config file
      try {
        fs.unlinkSync(configPath);
      } catch {
        // Ignore cleanup errors
      }

      if (!options.quiet) {
        console.log(`\nDuplication analysis completed in ${duration}ms`);
      }

      // Parse results and provide summary
      try {
        const resultsPath = path.join(outputDir, "jscpd-report.json");
        if (fs.existsSync(resultsPath)) {
          const results = JSON.parse(fs.readFileSync(resultsPath, "utf8"));
          provideSummary(results, options);

          // Return success based on threshold
          const percentage = results.statistics
            ? results.statistics.percentage
            : 0;
          resolve(percentage <= config.thresholds.maxPercentage);
        } else {
          if (!options.quiet) {
            printMessage(
              "No duplication report generated",
              colors.yellow,
              emojis.warning,
            );
          }
          resolve(true); // No duplicates found
        }
      } catch (error) {
        if (!options.quiet) {
          printMessage(
            `Error parsing results: ${error.message}`,
            colors.red,
            emojis.error,
          );
        }
        resolve(false);
      }
    });

    child.on("error", (error) => {
      printMessage(
        `Error running jscpd: ${error.message}`,
        colors.red,
        emojis.error,
      );
      resolve(false);
    });
  });
}

/**
 * Provide summary of duplication results
 */
function provideSummary(results, options = {}) {
  if (options.quiet) {
    return;
  }

  console.log(`\n${"=".repeat(60)}`);
  printMessage(
    `${emojis.chart} DUPLICATION ANALYSIS SUMMARY`,
    colors.cyan + colors.bright,
  );
  console.log("=".repeat(60));

  if (!results.statistics) {
    printMessage(
      "No duplication statistics available",
      colors.yellow,
      emojis.warning,
    );
    return;
  }

  const stats = results.statistics;

  console.log(`Total files analyzed: ${stats.total?.files || "N/A"}`);
  console.log(`Total lines: ${stats.total?.lines || "N/A"}`);
  console.log(`Duplicated lines: ${stats.duplicates?.lines || 0}`);
  console.log(`Duplicated files: ${stats.duplicates?.files || 0}`);

  const percentage = stats.percentage || 0;
  const threshold = config.thresholds.maxPercentage;

  if (percentage <= threshold) {
    printMessage(
      `\nDuplication: ${percentage.toFixed(2)}% ${emojis.success}`,
      colors.green,
    );
    printMessage(`Within threshold: ${threshold}%`, colors.green);
  } else {
    printMessage(
      `\nDuplication: ${percentage.toFixed(2)}% ${emojis.error}`,
      colors.red,
    );
    printMessage(`Exceeds threshold: ${threshold}%`, colors.red);
  }

  // Show top duplicates if available
  if (results.duplicates && results.duplicates.length > 0) {
    console.log(`\n${colors.yellow}Top duplications:${colors.reset}`);
    const topDuplicates = results.duplicates.slice(0, 5);

    topDuplicates.forEach((duplicate, index) => {
      console.log(
        `\n${index + 1}. ${emojis.file} ${duplicate.firstFile?.name || "Unknown"}`,
      );
      console.log(
        `   Lines: ${duplicate.linesCount}, Tokens: ${duplicate.tokensCount}`,
      );
      if (duplicate.fragment) {
        const fragment = duplicate.fragment.slice(0, 100);
        console.log(`   ${colors.blue}"${fragment}..."${colors.reset}`);
      }
    });
  }

  // Report locations
  console.log(`\n${colors.yellow}Reports generated:${colors.reset}`);
  console.log(`  HTML: ${path.join(config.outputDir, "html/index.html")}`);
  console.log(`  JSON: ${path.join(config.outputDir, "jscpd-report.json")}`);

  if (percentage > threshold) {
    console.log(
      `\n${colors.red}${emojis.warning} Action required:${colors.reset}`,
    );
    console.log(
      "  Consider refactoring duplicated code into reusable functions",
    );
    console.log("  Use composition or inheritance to reduce repetition");
    console.log("  Extract common patterns into utility modules");
  }
}

/**
 * Main execution function
 */
async function main() {
  const options = parseArgs();

  // Handle help
  if (process.argv.includes("--help") || process.argv.includes("-h")) {
    printHelp();
    return;
  }

  // Override config with options
  if (options.threshold !== null) {
    config.thresholds.maxPercentage = options.threshold;
  }

  // Print header
  if (!options.quiet) {
    console.log(`${colors.cyan}${colors.bright}
╔══════════════════════════════════════════════════════════════╗
║                    Code Duplication Analysis                 ║
║                      ${config.projectName}                      ║
║                     Source: ${config.sourceDir}                         ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}
`);
  }

  // Run duplication check
  const success = await runDuplicationCheck(options);

  if (!options.quiet) {
    if (success) {
      printMessage(
        `\n${emojis.success} Duplication check passed!`,
        colors.green + colors.bright,
      );
    } else {
      printMessage(
        `\n${emojis.error} Duplication check failed!`,
        colors.red + colors.bright,
      );
    }
  }

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
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    printMessage(`Error: ${error.message}`, colors.red, emojis.error);
    process.exit(1);
  });
}

export { runDuplicationCheck, config };