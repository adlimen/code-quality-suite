#!/usr/bin/env node

/**
 * Levero Frontend Maintainability Check
 * Comprehensive code maintainability analysis and scoring
 * Based on Complete Quality Suite architecture
 */

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
  gear: "⚙️",
  star: "⭐",
  trophy: "🏆",
  target: "🎯",
};

// Configuration
const config = {
  sourceDir: "src",
  projectName: "Levero Frontend",
  outputDir: "reports/maintainability",
  thresholds: {
    excellent: 90,
    good: 80,
    acceptable: 70,
    needsImprovement: 60,
    // Below 60 requires refactoring
  },
  complexity: {
    maxCyclomatic: 10,
    maxDepth: 4,
    maxParams: 4,
    maxStatements: 20,
    maxLines: 300,
    maxLineLength: 100,
  },
  exclude: [
    "node_modules/**",
    "dist/**",
    "build/**",
    ".next/**",
    "coverage/**",
    "**/*.d.ts",
    "**/types/supabase.ts", // Auto-generated
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
    includeTests: args.includes("--include-tests"),
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
║                  Maintainability Analysis                   ║
║                      ${config.projectName}                      ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}

${colors.yellow}Usage:${colors.reset}
  node scripts/maintainability-check.js [options]

${colors.yellow}Options:${colors.reset}
  ${colors.green}--threshold=N${colors.reset}      Minimum maintainability score (default: ${config.thresholds.acceptable})
  ${colors.green}--source-dir=DIR${colors.reset}   Source directory to analyze (default: ${config.sourceDir})
  ${colors.green}--project-name=NAME${colors.reset} Project name for reports (default: ${config.projectName})
  ${colors.green}--format=FORMAT${colors.reset}     Output format: console, html, json, all (default: console)
  ${colors.green}--include-tests${colors.reset}     Include test files in analysis
  ${colors.green}--verbose, -v${colors.reset}       Verbose output with detailed metrics
  ${colors.green}--quiet, -q${colors.reset}         Quiet output
  ${colors.green}--help, -h${colors.reset}          Show this help

${colors.yellow}Scoring Ranges:${colors.reset}
  ${colors.green}90-100${colors.reset}: ${emojis.trophy} Excellent maintainability
  ${colors.green}80-89${colors.reset}:  ${emojis.star} Good maintainability  
  ${colors.yellow}70-79${colors.reset}:  ${emojis.target} Acceptable maintainability
  ${colors.yellow}60-69${colors.reset}:  ${emojis.warning} Needs improvement
  ${colors.red}Below 60${colors.reset}: ${emojis.error} Requires refactoring

${colors.yellow}Metrics Analyzed:${colors.reset}
  • Cyclomatic complexity (max: ${config.complexity.maxCyclomatic})
  • Function length (max: ${config.complexity.maxLines} lines)
  • Parameter count (max: ${config.complexity.maxParams})
  • Nesting depth (max: ${config.complexity.maxDepth})
  • Code maintainability index
  • Halstead complexity metrics

${colors.yellow}Examples:${colors.reset}
  ${colors.cyan}node scripts/maintainability-check.js${colors.reset}
  ${colors.cyan}node scripts/maintainability-check.js --threshold=80${colors.reset}
  ${colors.cyan}node scripts/maintainability-check.js --format=html --verbose${colors.reset}
  ${colors.cyan}node scripts/maintainability-check.js --include-tests${colors.reset}
`);
}

/**
 * Check if tools are available
 */
async function checkToolAvailability() {
  const tools = ["typhonjs-escomplex-module"];
  const available = {};

  for (const tool of tools) {
    try {
      // Try to import the module instead of spawning
      await import(tool);
      available[tool] = true;
    } catch {
      available[tool] = false;
    }
  }

  return available;
}

/**
 * Analyze file complexity using typhonjs-escomplex
 */
async function analyzeFileComplexity(filePath) {
  try {
    const { default: escomplex } = await import("typhonjs-escomplex-module");
    const source = fs.readFileSync(filePath, "utf8");

    const result = escomplex.analyzeModule(source, {
      commonjs: true,
      forin: false,
      logicalor: true,
      switchcase: true,
      trycatch: true,
    });

    return {
      file: filePath,
      complexity: result.aggregate.cyclomatic,
      maintainability: result.maintainability,
      halstead: result.aggregate.halstead,
      functions: result.methods.map((method) => ({
        name: method.name,
        complexity: method.cyclomatic,
        params: method.params,
        lines: method.lineEnd - method.lineStart + 1,
        maintainability: method.maintainability || 0,
      })),
      lines: result.lineEnd || 0,
      dependencies: result.dependencies ? result.dependencies.length : 0,
    };
  } catch (error) {
    return {
      file: filePath,
      error: error.message,
      complexity: 0,
      maintainability: 0,
      functions: [],
      lines: 0,
      dependencies: 0,
    };
  }
}

/**
 * Get all TypeScript/JavaScript files to analyze
 */
function getFilesToAnalyze(options = {}) {
  const files = [];
  const extensions = [".ts", ".tsx", ".js", ".jsx"];

  function shouldSkipPath(fullPath) {
    const relativePath = path.relative(process.cwd(), fullPath);
    return config.exclude.some((pattern) => {
      const regex = new RegExp(
        pattern.replace(/\*\*/g, ".*").replace(/\*/g, "[^/]*"),
      );
      return regex.test(relativePath);
    });
  }

  function shouldIncludeFile(fullPath) {
    const ext = path.extname(fullPath);
    if (!extensions.includes(ext)) {
      return false;
    }

    const relativePath = path.relative(process.cwd(), fullPath);
    const isTestFile = /\.(test|spec)\.(ts|tsx|js|jsx)$/.test(relativePath);

    return !(isTestFile && !options.includeTests) && !shouldSkipPath(fullPath);
  }

  function scanDirectory(dir) {
    try {
      const items = fs.readdirSync(dir);
      for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);

        if (stat.isDirectory() && !shouldSkipPath(fullPath)) {
          scanDirectory(fullPath);
        } else if (stat.isFile() && shouldIncludeFile(fullPath)) {
          files.push(fullPath);
        }
      }
    } catch {
      // Skip directories we can't read
    }
  }

  const startDir = path.join(process.cwd(), config.sourceDir);
  if (fs.existsSync(startDir)) {
    scanDirectory(startDir);
  }

  return files;
}

/**
 * Calculate overall maintainability score
 */
function calculateMaintainabilityScore(results) {
  if (results.length === 0) {
    return 0;
  }

  let totalScore = 0;
  let totalWeight = 0;

  for (const result of results) {
    if (result.error) {
      continue;
    }

    // Weight by file size (lines of code)
    const weight = Math.max(1, result.lines);
    let fileScore = result.maintainability;

    // Apply penalties for high complexity
    if (result.complexity > config.complexity.maxCyclomatic) {
      const penalty = (result.complexity - config.complexity.maxCyclomatic) * 2;
      fileScore = Math.max(0, fileScore - penalty);
    }

    // Apply penalties for large files
    if (result.lines > config.complexity.maxLines) {
      const penalty = (result.lines - config.complexity.maxLines) / 50;
      fileScore = Math.max(0, fileScore - penalty);
    }

    // Apply penalties for complex functions
    const complexFunctions = result.functions.filter(
      (f) => f.complexity > config.complexity.maxCyclomatic,
    );
    if (complexFunctions.length > 0) {
      const penalty = complexFunctions.length * 3;
      fileScore = Math.max(0, fileScore - penalty);
    }

    totalScore += fileScore * weight;
    totalWeight += weight;
  }

  return totalWeight > 0 ? totalScore / totalWeight : 0;
}

/**
 * Generate detailed analysis report
 */
function generateReport(results, overallScore, _options = {}) {
  return {
    projectName: config.projectName,
    sourceDir: config.sourceDir,
    timestamp: new Date().toISOString(),
    overallScore: overallScore,
    grade: getGrade(overallScore),
    thresholds: config.thresholds,
    summary: {
      totalFiles: results.length,
      errorFiles: results.filter((r) => r.error).length,
      averageComplexity:
        results.reduce((sum, r) => sum + (r.complexity || 0), 0) /
        results.length,
      averageMaintainability:
        results.reduce((sum, r) => sum + (r.maintainability || 0), 0) /
        results.length,
      totalLines: results.reduce((sum, r) => sum + (r.lines || 0), 0),
      complexFiles: results.filter(
        (r) => r.complexity > config.complexity.maxCyclomatic,
      ).length,
      largeFiles: results.filter((r) => r.lines > config.complexity.maxLines)
        .length,
    },
    files: results,
    recommendations: generateRecommendations(results, overallScore),
  };
}

/**
 * Get grade based on score
 */
function getGrade(score) {
  if (score >= config.thresholds.excellent) {
    return { level: "Excellent", emoji: emojis.trophy, color: colors.green };
  }
  if (score >= config.thresholds.good) {
    return { level: "Good", emoji: emojis.star, color: colors.green };
  }
  if (score >= config.thresholds.acceptable) {
    return { level: "Acceptable", emoji: emojis.target, color: colors.yellow };
  }
  if (score >= config.thresholds.needsImprovement) {
    return {
      level: "Needs Improvement",
      emoji: emojis.warning,
      color: colors.yellow,
    };
  }
  return {
    level: "Requires Refactoring",
    emoji: emojis.error,
    color: colors.red,
  };
}

/**
 * Generate recommendations based on analysis
 */
function generateRecommendations(results, overallScore) {
  const recommendations = [];

  // Overall score recommendations
  if (overallScore < config.thresholds.acceptable) {
    recommendations.push({
      type: "critical",
      message: "Overall maintainability score is below acceptable threshold",
      action:
        "Consider major refactoring to improve code structure and reduce complexity",
    });
  }

  // File-specific recommendations
  const complexFiles = results.filter(
    (r) => r.complexity > config.complexity.maxCyclomatic,
  );
  if (complexFiles.length > 0) {
    recommendations.push({
      type: "warning",
      message: `${complexFiles.length} files have high cyclomatic complexity`,
      action: "Break down complex functions into smaller, focused functions",
    });
  }

  const largeFiles = results.filter(
    (r) => r.lines > config.complexity.maxLines,
  );
  if (largeFiles.length > 0) {
    recommendations.push({
      type: "warning",
      message: `${largeFiles.length} files exceed recommended line count`,
      action:
        "Split large files into smaller modules with single responsibilities",
    });
  }

  // Function-specific recommendations
  const complexFunctions = results.flatMap((r) =>
    r.functions.filter((f) => f.complexity > config.complexity.maxCyclomatic),
  );
  if (complexFunctions.length > 0) {
    recommendations.push({
      type: "info",
      message: `${complexFunctions.length} functions have high complexity`,
      action: "Refactor complex functions using composition and early returns",
    });
  }

  const longFunctions = results.flatMap((r) =>
    r.functions.filter((f) => f.lines > 50),
  );
  if (longFunctions.length > 0) {
    recommendations.push({
      type: "info",
      message: `${longFunctions.length} functions are longer than 50 lines`,
      action: "Extract common patterns and break down long functions",
    });
  }

  return recommendations;
}

/**
 * Print console report
 */
function printConsoleReport(report, options = {}) {
  if (options.quiet) {
    return;
  }

  console.log(`\n${"=".repeat(60)}`);
  printMessage(
    `${emojis.chart} MAINTAINABILITY ANALYSIS REPORT`,
    colors.cyan + colors.bright,
  );
  console.log("=".repeat(60));

  const grade = report.grade;
  printMessage(
    `\nOverall Score: ${report.overallScore.toFixed(1)}/100 ${grade.emoji}`,
    grade.color + colors.bright,
  );
  printMessage(`Grade: ${grade.level}`, grade.color);

  console.log(`\n${colors.yellow}Summary:${colors.reset}`);
  console.log(`  Files analyzed: ${report.summary.totalFiles}`);
  console.log(`  Total lines: ${report.summary.totalLines}`);
  console.log(
    `  Average complexity: ${report.summary.averageComplexity.toFixed(1)}`,
  );
  console.log(
    `  Average maintainability: ${report.summary.averageMaintainability.toFixed(1)}`,
  );

  if (report.summary.errorFiles > 0) {
    printMessage(
      `  Files with errors: ${report.summary.errorFiles}`,
      colors.red,
      emojis.error,
    );
  }

  if (report.summary.complexFiles > 0) {
    printMessage(
      `  High complexity files: ${report.summary.complexFiles}`,
      colors.yellow,
      emojis.warning,
    );
  }

  if (report.summary.largeFiles > 0) {
    printMessage(
      `  Large files: ${report.summary.largeFiles}`,
      colors.yellow,
      emojis.warning,
    );
  }

  // Show worst performing files
  const worstFiles = report.files
    .filter((f) => !f.error)
    .sort((a, b) => a.maintainability - b.maintainability)
    .slice(0, 5);

  if (worstFiles.length > 0 && options.verbose) {
    console.log(`\n${colors.yellow}Files needing attention:${colors.reset}`);
    worstFiles.forEach((file, index) => {
      const relativePath = path.relative(process.cwd(), file.file);
      console.log(`\n${index + 1}. ${relativePath}`);
      console.log(`   Maintainability: ${file.maintainability.toFixed(1)}`);
      console.log(`   Complexity: ${file.complexity}`);
      console.log(`   Lines: ${file.lines}`);

      if (file.functions.length > 0) {
        const complexFunctions = file.functions.filter(
          (f) => f.complexity > config.complexity.maxCyclomatic,
        );
        if (complexFunctions.length > 0) {
          console.log(
            `   Complex functions: ${complexFunctions.map((f) => f.name).join(", ")}`,
          );
        }
      }
    });
  }

  // Show recommendations
  if (report.recommendations.length > 0) {
    console.log(`\n${colors.yellow}Recommendations:${colors.reset}`);
    report.recommendations.forEach((rec, index) => {
      const emoji =
        rec.type === "critical"
          ? emojis.error
          : rec.type === "warning"
            ? emojis.warning
            : emojis.info;
      const color =
        rec.type === "critical"
          ? colors.red
          : rec.type === "warning"
            ? colors.yellow
            : colors.blue;

      printMessage(`\n${index + 1}. ${rec.message}`, color, emoji);
      console.log(`   ${colors.cyan}Action:${colors.reset} ${rec.action}`);
    });
  }

  // Show thresholds
  console.log(`\n${colors.yellow}Quality Thresholds:${colors.reset}`);
  console.log(`  ${emojis.trophy} Excellent: ${config.thresholds.excellent}+`);
  console.log(
    `  ${emojis.star} Good: ${config.thresholds.good}-${config.thresholds.excellent - 1}`,
  );
  console.log(
    `  ${emojis.target} Acceptable: ${config.thresholds.acceptable}-${config.thresholds.good - 1}`,
  );
  console.log(
    `  ${emojis.warning} Needs Improvement: ${config.thresholds.needsImprovement}-${config.thresholds.acceptable - 1}`,
  );
  console.log(
    `  ${emojis.error} Requires Refactoring: <${config.thresholds.needsImprovement}`,
  );
}

/**
 * Save reports to files
 */
function saveReports(report, options = {}) {
  // Create output directory
  const outputDir = path.join(process.cwd(), config.outputDir);
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Save JSON report
  const jsonPath = path.join(outputDir, "maintainability-report.json");
  fs.writeFileSync(jsonPath, JSON.stringify(report, null, 2));

  // Save HTML report if requested
  if (options.format === "html" || options.format === "all") {
    const htmlContent = generateHtmlReport(report);
    const htmlPath = path.join(outputDir, "maintainability-report.html");
    fs.writeFileSync(htmlPath, htmlContent);
  }

  return {
    json: jsonPath,
    html:
      options.format === "html" || options.format === "all"
        ? path.join(outputDir, "maintainability-report.html")
        : null,
  };
}

/**
 * Generate HTML report
 */
function generateHtmlReport(report) {
  const grade = report.grade;

  return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintainability Report - ${report.projectName}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { text-align: center; margin-bottom: 40px; }
        .score { font-size: 48px; margin: 20px 0; }
        .grade { font-size: 24px; margin: 10px 0; }
        .summary { background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 8px; }
        .files { margin: 20px 0; }
        .file { margin: 10px 0; padding: 10px; border-left: 4px solid #ddd; }
        .complex { border-left-color: #ff6b6b; }
        .recommendations { background: #fff3cd; padding: 20px; margin: 20px 0; border-radius: 8px; }
        .excellent { color: #28a745; }
        .good { color: #28a745; }
        .acceptable { color: #ffc107; }
        .warning { color: #fd7e14; }
        .error { color: #dc3545; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Maintainability Report</h1>
        <h2>${report.projectName}</h2>
        <div class="score ${grade.level.toLowerCase().replace(" ", "-")}">${report.overallScore.toFixed(1)}/100</div>
        <div class="grade ${grade.level.toLowerCase().replace(" ", "-")}">${grade.emoji} ${grade.level}</div>
        <small>Generated: ${new Date(report.timestamp).toLocaleString()}</small>
    </div>

    <div class="summary">
        <h3>Summary</h3>
        <ul>
            <li>Files analyzed: ${report.summary.totalFiles}</li>
            <li>Total lines: ${report.summary.totalLines}</li>
            <li>Average complexity: ${report.summary.averageComplexity.toFixed(1)}</li>
            <li>High complexity files: ${report.summary.complexFiles}</li>
            <li>Large files: ${report.summary.largeFiles}</li>
        </ul>
    </div>

    ${
      report.recommendations.length > 0
        ? `
    <div class="recommendations">
        <h3>Recommendations</h3>
        <ul>
            ${report.recommendations
              .map(
                (rec) => `
                <li class="${rec.type}">
                    <strong>${rec.message}</strong><br>
                    ${rec.action}
                </li>
            `,
              )
              .join("")}
        </ul>
    </div>
    `
        : ""
    }

    <div class="files">
        <h3>File Analysis</h3>
        ${report.files
          .filter((f) => !f.error)
          .map(
            (file) => `
            <div class="file ${file.complexity > config.complexity.maxCyclomatic ? "complex" : ""}">
                <strong>${path.relative(process.cwd(), file.file)}</strong><br>
                Maintainability: ${file.maintainability.toFixed(1)} | 
                Complexity: ${file.complexity} | 
                Lines: ${file.lines}
                ${file.functions.length > 0 ? `<br>Functions: ${file.functions.length}` : ""}
            </div>
        `,
          )
          .join("")}
    </div>
</body>
</html>`;
}

/**
 * Print header banner
 */
function printHeader(options) {
  if (!options.quiet) {
    console.log(`${colors.cyan}${colors.bright}
╔══════════════════════════════════════════════════════════════╗
║                  Maintainability Analysis                   ║
║                      ${config.projectName}                      ║
║                     Source: ${config.sourceDir}                         ║
╚══════════════════════════════════════════════════════════════╝${colors.reset}
`);
  }
}

/**
 * Check and handle missing tools
 */
async function validateToolAvailability() {
  const toolAvailability = await checkToolAvailability();
  const missingTools = Object.entries(toolAvailability)
    .filter(([_tool, available]) => !available)
    .map(([tool]) => tool);

  if (missingTools.length > 0) {
    printMessage(
      `Missing required tools: ${missingTools.join(", ")}`,
      colors.red,
      emojis.error,
    );
    printMessage(
      "Install with: npm install -D typhonjs-escomplex-module",
      colors.yellow,
      emojis.info,
    );
    return false;
  }
  return true;
}

/**
 * Analyze files and generate results
 */
async function analyzeFiles(files, options) {
  const results = [];
  for (const file of files) {
    if (options.verbose && !options.quiet) {
      const relativePath = path.relative(process.cwd(), file);
      console.log(`  Analyzing: ${relativePath}`);
    }

    const result = await analyzeFileComplexity(file);
    results.push(result);
  }
  return results;
}

/**
 * Print and save reports
 */
function handleReports(report, options) {
  printConsoleReport(report, options);
  const savedReports = saveReports(report, options);

  if (!options.quiet) {
    console.log(`\n${colors.yellow}Reports saved:${colors.reset}`);
    console.log(`  JSON: ${savedReports.json}`);
    if (savedReports.html) {
      console.log(`  HTML: ${savedReports.html}`);
    }
  }
}

/**
 * Print final result and exit
 */
function handleFinalResult(overallScore, options) {
  const threshold = options.threshold || config.thresholds.acceptable;
  const success = overallScore >= threshold;

  if (!options.quiet) {
    if (success) {
      printMessage(
        `\n${emojis.success} Maintainability check passed!`,
        colors.green + colors.bright,
      );
    } else {
      printMessage(
        `\n${emojis.error} Maintainability below threshold (${threshold})`,
        colors.red + colors.bright,
      );
    }
  }

  process.exit(success ? 0 : 1);
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

  printHeader(options);

  // Check tool availability
  const toolsAvailable = await validateToolAvailability();
  if (!toolsAvailable) {
    return;
  }

  // Get files to analyze
  const files = getFilesToAnalyze(options);
  if (files.length === 0) {
    printMessage("No files found to analyze", colors.yellow, emojis.warning);
    return;
  }

  if (!options.quiet) {
    printMessage(
      `Analyzing ${files.length} files...`,
      colors.cyan,
      emojis.magnifying,
    );
  }

  // Analyze files and generate report
  const results = await analyzeFiles(files, options);
  const overallScore = calculateMaintainabilityScore(results);
  const report = generateReport(results, overallScore, options);

  // Handle reports and final result
  handleReports(report, options);
  handleFinalResult(overallScore, options);
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

export { analyzeFileComplexity, calculateMaintainabilityScore, config };
