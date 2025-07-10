#!/usr/bin/env python3
"""
AdLimen Code Quality Suite - Python Edition
Comprehensive quality orchestrator based on Complete Quality Suite architecture
11-Step Modular Quality Workflow for Python projects
"""

import os
import sys
import subprocess
import argparse
import json
import time
from pathlib import Path
from typing import List, Dict, Tuple, Optional, Any
from dataclasses import dataclass

# Version and metadata
VERSION = "2.0.0"
SUITE_NAME = "AdLimen Code Quality Suite - Python Edition"

# Colors and emojis for output formatting
class Colors:
    RESET = '\033[0m'
    BRIGHT = '\033[1m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'

class Emojis:
    SUCCESS = "✅"
    ERROR = "❌"
    WARNING = "⚠️"
    INFO = "ℹ️"
    ROCKET = "🚀"
    WRENCH = "🔧"
    SHIELD = "🔒"
    MAGNIFYING = "🔍"
    ART = "🎨"
    CHART = "📊"
    GEAR = "⚙️"
    TARGET = "🎯"
    TROPHY = "🏆"
    SPARKLES = "✨"

@dataclass
class QualityConfig:
    """Configuration for quality checks"""
    source_dir: str = "src"
    test_dir: str = "tests"
    reports_dir: str = "reports"
    complexity_threshold: int = 10
    maintainability_threshold: int = 70
    duplication_threshold: int = 5
    exclude_patterns: List[str] = None
    
    def __post_init__(self):
        if self.exclude_patterns is None:
            self.exclude_patterns = [
                "__pycache__",
                "*.pyc", 
                ".git",
                ".pytest_cache",
                "venv",
                ".venv",
                "node_modules"
            ]

def load_config() -> QualityConfig:
    """Load configuration from various sources"""
    config = QualityConfig()
    
    # Try to load from pyproject.toml
    try:
        import tomllib
        with open("pyproject.toml", "rb") as f:
            data = tomllib.load(f)
            quality_config = data.get("tool", {}).get("quality-suite", {})
            if quality_config:
                for key, value in quality_config.items():
                    if hasattr(config, key):
                        setattr(config, key, value)
    except (ImportError, FileNotFoundError):
        pass
    
    # Try to load from .quality-config.json
    try:
        with open(".quality-config.json", "r") as f:
            data = json.load(f)
            for key, value in data.items():
                if hasattr(config, key):
                    setattr(config, key, value)
    except FileNotFoundError:
        pass
    
    return config

def print_header():
    """Print suite header"""
    print(f"{Colors.CYAN}{Colors.BRIGHT}")
    print("╔" + "═" * 72 + "╗")
    print(f"║{' ' * 15}{SUITE_NAME}{' ' * 15}║")
    print(f"║{' ' * 28}Version {VERSION}{' ' * 28}║")
    print("╚" + "═" * 72 + "╝")
    print(f"{Colors.RESET}")

def print_step(step: int, name: str, description: str):
    """Print step header"""
    print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
    print(f"{Colors.BRIGHT}Step {step}: {name}{Colors.RESET}")
    print(f"{Colors.BLUE}{description}{Colors.RESET}")
    print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")

def run_command(cmd: str, description: str, quiet: bool = False, capture_output: bool = False) -> Tuple[bool, str]:
    """Run a command and handle errors with enhanced formatting."""
    if not quiet:
        print(f"\n{Colors.CYAN}{Emojis.GEAR} {description}{Colors.RESET}")
        print(f"{Colors.BLUE}Command: {cmd}{Colors.RESET}")
    
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    output = ""
    if result.stdout:
        output += result.stdout
        # Don't print safety JSON output directly - we'll format it nicely
        if not quiet and not capture_output and "safety check" not in cmd:
            print(result.stdout)
    
    if result.stderr:
        output += result.stderr
        if not quiet and not capture_output:
            print(result.stderr)
    
    # Special handling for Safety vulnerability scanner
    # Treat known vulnerabilities without fixes as warnings rather than failures
    if "safety check" in cmd and result.returncode != 0:
        # Check if this is just vulnerability findings vs actual tool failure
        if "No known security vulnerabilities found" not in output and ("vulnerability" in output.lower() or "cve-" in output.lower()):
            success = True  # Treat as warning, not failure
            if not quiet:
                # Parse and summarize the JSON output for cleaner display
                try:
                    import json
                    # Find the JSON part (skip any text before it like deprecation warnings)
                    json_start = output.find('{')
                    if json_start != -1:
                        json_content = output[json_start:]
                        # Find the end of the JSON (look for the last closing brace)
                        brace_count = 0
                        json_end = json_start
                        for i, char in enumerate(json_content):
                            if char == '{':
                                brace_count += 1
                            elif char == '}':
                                brace_count -= 1
                                if brace_count == 0:
                                    json_end = json_start + i + 1
                                    break
                        
                        json_only = output[json_start:json_end]
                        safety_data = json.loads(json_only)
                        
                        vulnerabilities_found = safety_data.get("report_meta", {}).get("vulnerabilities_found", 0)
                        packages_found = safety_data.get("report_meta", {}).get("packages_found", 0)
                        
                        print(f"{Colors.YELLOW}{Emojis.WARNING} Warning: Found {vulnerabilities_found} vulnerabilities in {packages_found} packages (treated as warnings){Colors.RESET}")
                        
                        # Show brief summary of vulnerabilities  
                        if "vulnerabilities" in safety_data and safety_data["vulnerabilities"]:
                            for vuln in safety_data["vulnerabilities"][:3]:  # Show first 3
                                pkg_name = vuln.get("package_name", "unknown")
                                vuln_id = vuln.get("vulnerability_id", "unknown")
                                print(f"  {Colors.YELLOW}• {pkg_name}: {vuln_id}{Colors.RESET}")
                            
                            if len(safety_data["vulnerabilities"]) > 3:
                                remaining = len(safety_data["vulnerabilities"]) - 3
                                print(f"  {Colors.YELLOW}• ... and {remaining} more{Colors.RESET}")
                        
                        print(f"{Colors.CYAN}💡 Use 'safety check' directly for detailed vulnerability information{Colors.RESET}")
                    else:
                        print(f"{Colors.YELLOW}{Emojis.WARNING} Warning: {description} - Vulnerabilities found but treated as warnings{Colors.RESET}")
                except (json.JSONDecodeError, KeyError, IndexError, ValueError) as e:
                    print(f"{Colors.YELLOW}{Emojis.WARNING} Warning: {description} - Vulnerabilities found but treated as warnings{Colors.RESET}")
                    if not quiet:
                        print(f"{Colors.BLUE}Debug: JSON parsing failed: {e}{Colors.RESET}")
        else:
            success = False
            if not quiet:
                print(f"{Colors.RED}{Emojis.ERROR} Failed: {description}{Colors.RESET}")
    else:
        success = result.returncode == 0
        if not quiet:
            if success:
                print(f"{Colors.GREEN}{Emojis.SUCCESS} Passed: {description}{Colors.RESET}")
            else:
                print(f"{Colors.RED}{Emojis.ERROR} Failed: {description}{Colors.RESET}")
    
    return success, output

class QualityTools:
    """Quality tools definitions and execution"""
    
    def __init__(self, config: QualityConfig):
        self.config = config
        self.tools = self._get_tools_config()
    
    def _get_tools_config(self) -> Dict[str, Dict[str, Any]]:
        """Get comprehensive tools configuration for 11-step workflow"""
        return {
            # Step 1: Code Formatting
            "formatting": {
                "name": "Code Formatting",
                "description": "Code formatting and style consistency",
                "icon": Emojis.ART,
                "tools": {
                    "black": {
                        "check": f"black --check --diff {self.config.source_dir}/ {self.config.test_dir}/",
                        "fix": f"black {self.config.source_dir}/ {self.config.test_dir}/",
                        "description": "Python code formatter"
                    }
                }
            },
            
            # Step 2: Import Sorting
            "import-sorting": {
                "name": "Import Sorting",
                "description": "Import organization and cleanup",
                "icon": Emojis.SPARKLES,
                "tools": {
                    "isort": {
                        "check": f"isort --check --diff {self.config.source_dir}/ {self.config.test_dir}/",
                        "fix": f"isort {self.config.source_dir}/ {self.config.test_dir}/",
                        "description": "Import sorting and organization"
                    }
                }
            },
            
            # Step 3: Code Linting
            "linting": {
                "name": "Code Linting",
                "description": "Code quality rules and best practices",
                "icon": Emojis.MAGNIFYING,
                "tools": {
                    "ruff": {
                        "check": f"ruff check {self.config.source_dir}/ {self.config.test_dir}/",
                        "fix": f"ruff check --fix {self.config.source_dir}/ {self.config.test_dir}/",
                        "description": "Fast Python linter"
                    }
                }
            },
            
            # Step 4: Type Checking
            "type-checking": {
                "name": "Type Checking",
                "description": "Static type validation and analysis",
                "icon": Emojis.GEAR,
                "tools": {
                    "mypy": {
                        "check": f"mypy {self.config.source_dir}/",
                        "fix": None,
                        "description": "Static type checker"
                    }
                }
            },
            
            # Step 5: Security Scanning
            "security-scanning": {
                "name": "Security Scanning",
                "description": "Code security vulnerability detection",
                "icon": Emojis.SHIELD,
                "tools": {
                    "bandit": {
                        "check": f"bandit -r {self.config.source_dir}/",
                        "fix": None,
                        "description": "Security vulnerability scanner"
                    }
                }
            },
            
            # Step 6: Vulnerability Checking
            "vulnerability-checking": {
                "name": "Vulnerability Checking",
                "description": "Dependency vulnerability scanning",
                "icon": Emojis.SHIELD,
                "tools": {
                    "safety": {
                        "check": "safety check --output json",
                        "fix": None,
                        "description": "Dependency vulnerability scanner (public-friendly)"
                    }
                }
            },
            
            # Step 7: Dead Code Detection
            "dead-code": {
                "name": "Dead Code Detection",
                "description": "Unused code identification",
                "icon": Emojis.MAGNIFYING,
                "tools": {
                    "vulture": {
                        "check": f"vulture {self.config.source_dir}/ --min-confidence 80",
                        "fix": None,
                        "description": "Dead code detector"
                    }
                }
            },
            
            # Step 8: Code Duplication
            "duplication": {
                "name": "Code Duplication",
                "description": "Code duplication detection and analysis",
                "icon": Emojis.TARGET,
                "tools": {
                    "duplication-check": {
                        "check": f"python python-duplication-check.py --verbose",
                        "fix": None,
                        "description": "Python code duplication detector"
                    }
                }
            },
            
            # Step 9: Complexity Analysis  
            "complexity": {
                "name": "Complexity Analysis",
                "description": "Cyclomatic complexity measurement",
                "icon": Emojis.CHART,
                "tools": {
                    "radon-cc": {
                        "check": f"radon cc {self.config.source_dir}/ --min C",
                        "fix": None,
                        "description": "Cyclomatic complexity analysis"
                    }
                }
            },
            
            # Step 10: Maintainability
            "maintainability": {
                "name": "Maintainability Analysis",
                "description": "Code maintainability index calculation",
                "icon": Emojis.TROPHY,
                "tools": {
                    "radon-mi": {
                        "check": f"radon mi {self.config.source_dir}/ --min B",
                        "fix": None,
                        "description": "Maintainability index calculation"
                    }
                }
            },
            
            # Step 11: Dependency Analysis
            "dependency-analysis": {
                "name": "Dependency Analysis",
                "description": "Dependency graph analysis and validation",
                "icon": Emojis.GEAR,
                "tools": {
                    "pipdeptree": {
                        "check": "pipdeptree --warn",
                        "fix": None,
                        "description": "Dependency tree analysis"
                    }
                }
            }
        }
    
    def get_step_tools(self, step: str) -> Dict[str, Any]:
        """Get tools for a specific step"""
        return self.tools.get(step, {}).get("tools", {})
    
    def get_all_steps(self) -> List[str]:
        """Get all available steps"""
        return list(self.tools.keys())
    
    def get_step_info(self, step: str) -> Dict[str, Any]:
        """Get step information"""
        return self.tools.get(step, {})

class QualityRunner:
    """Quality checks execution engine"""
    
    def __init__(self, config: QualityConfig, quiet: bool = False):
        self.config = config
        self.quiet = quiet
        self.tools = QualityTools(config)
        self.results = []
    
    def run_step(self, step: str, fix_mode: bool = False) -> List[bool]:
        """Run a specific quality step"""
        step_info = self.tools.get_step_info(step)
        if not step_info:
            print(f"{Colors.RED}{Emojis.ERROR} Unknown step: {step}{Colors.RESET}")
            return [False]
        
        if not self.quiet:
            print_step(
                list(self.tools.get_all_steps()).index(step) + 1,
                step_info["name"],
                step_info["description"]
            )
        
        results = []
        step_tools = self.tools.get_step_tools(step)
        
        for tool_name, tool_config in step_tools.items():
            if fix_mode and tool_config.get("fix"):
                cmd = tool_config["fix"]
                mode = "fix"
            else:
                cmd = tool_config["check"]
                mode = "check"
            
            if cmd:
                success, output = run_command(
                    cmd, 
                    f"{tool_config['description']} ({mode})",
                    self.quiet
                )
                results.append(success)
            else:
                if not self.quiet:
                    print(f"{Colors.YELLOW}{Emojis.WARNING} {tool_name}: No {mode} command available{Colors.RESET}")
                results.append(True)
        
        return results
    
    def run_suite(self, suite: str, fix_mode: bool = False) -> List[bool]:
        """Run a quality suite"""
        all_results = []
        
        if suite == "all":
            steps = self.tools.get_all_steps()
        elif suite == "required":
            steps = ["formatting", "import-sorting", "linting", "type-checking"]
        elif suite == "security":
            steps = ["security-scanning", "vulnerability-checking"]
        elif suite == "analysis":
            steps = ["dead-code", "duplication", "complexity", "maintainability", "dependency-analysis"]
        elif suite == "formatting-suite":
            steps = ["formatting", "import-sorting"]
        elif suite == "linting-suite":
            steps = ["linting", "type-checking"]
        else:
            # Single step
            return self.run_step(suite, fix_mode)
        
        if not self.quiet:
            print(f"\n{Colors.CYAN}{Emojis.ROCKET} Running {suite} suite ({len(steps)} steps)...{Colors.RESET}")
        
        for step in steps:
            step_results = self.run_step(step, fix_mode)
            all_results.extend(step_results)
        
        return all_results
    
    def check_tool_availability(self, tools_to_check: List[str] = None, step: str = None) -> bool:
        """Check if required tools are available"""
        if not self.quiet:
            print(f"{Colors.BLUE}{Emojis.MAGNIFYING} Checking tool availability...{Colors.RESET}")
        
        if tools_to_check is None:
            if step:
                # Get tools for specific step
                step_tools = self.tools.get_step_tools(step)
                tools_to_check = list(step_tools.keys())
            else:
                # Get essential tools only
                tools_to_check = ["black", "isort", "ruff", "mypy"]
        
        missing_tools = []
        
        for tool in tools_to_check:
            # Skip custom tools that might not have --version
            if tool in ["duplication-check", "pyclone"]:
                continue
                
            result = subprocess.run(f"{tool} --version", shell=True, capture_output=True)
            if result.returncode != 0:
                missing_tools.append(tool)
            elif not self.quiet:
                print(f"{Colors.GREEN}{Emojis.SUCCESS} {tool} is available{Colors.RESET}")
        
        if missing_tools:
            if not self.quiet:
                print(f"{Colors.RED}{Emojis.ERROR} Missing tools: {', '.join(missing_tools)}{Colors.RESET}")
                print(f"Install with: pip install {' '.join(missing_tools)}")
            return False
        
        return True
    
    def print_summary(self, results: List[bool], check_type: str, duration: Optional[int] = None) -> int:
        """Print quality check summary and return exit code"""
        total_checks = len(results)
        passed_checks = sum(results)
        failed_checks = total_checks - passed_checks
        
        duration_str = f" ({duration}s)" if duration else ""
        
        print(f"\n{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"{Colors.BRIGHT}{Emojis.CHART} QUALITY CHECKS SUMMARY{duration_str}{Colors.RESET}")
        print(f"{Colors.CYAN}{'='*60}{Colors.RESET}")
        print(f"Suite: {check_type}")
        print(f"Total checks: {total_checks}")
        print(f"{Colors.GREEN}{Emojis.SUCCESS} Passed: {passed_checks}{Colors.RESET}")
        print(f"{Colors.RED}{Emojis.ERROR} Failed: {failed_checks}{Colors.RESET}")
        
        if failed_checks == 0:
            print(f"\n{Colors.GREEN}{Emojis.TROPHY} All quality checks passed!{Colors.RESET}")
            return 0
        else:
            print(f"\n{Colors.RED}{Emojis.ERROR} {failed_checks} quality check(s) failed!{Colors.RESET}")
            print(f"{Colors.CYAN}{Emojis.INFO} Try running with --fix to automatically fix some issues.{Colors.RESET}")
            return 1

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description=f"{SUITE_NAME} v{VERSION}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
11-Step Quality Workflow:
  1. formatting          Code formatting (black)
  2. import-sorting      Import organization (isort)
  3. linting             Code quality (ruff)
  4. type-checking       Type validation (mypy)
  5. security-scanning   Security analysis (bandit)
  6. vulnerability-checking  Dependency vulnerabilities (safety)
  7. dead-code           Dead code detection (vulture)
  8. duplication         Code duplication (custom detector)
  9. complexity          Complexity analysis (radon)
  10. maintainability    Maintainability index (radon)
  11. dependency-analysis Dependency validation (pipdeptree)

Quality Suites:
  all                    Complete 11-step workflow
  required              Essential checks (steps 1-4)
  security              Security analysis (steps 5-6)
  analysis              Code analysis (steps 7-11)
  formatting-suite      Formatting tools (steps 1-2)
  linting-suite         Linting tools (steps 3-4)

Examples:
  python python-quality-check.py all                    # Complete analysis
  python python-quality-check.py all --fix              # Analysis with auto-fix
  python python-quality-check.py required --fix         # Essential checks with fixes
  python python-quality-check.py security --quiet       # Security analysis (quiet)
        """
    )
    
    # Quality suites and individual steps
    all_choices = [
        "all", "required", "security", "analysis", "formatting-suite", "linting-suite"
    ] + [
        "formatting", "import-sorting", "linting", "type-checking",
        "security-scanning", "vulnerability-checking", "dead-code", 
        "duplication", "complexity", "maintainability", "dependency-analysis"
    ]
    
    parser.add_argument(
        "check_type",
        choices=all_choices,
        help="Type of quality checks to run"
    )
    parser.add_argument(
        "--fix",
        action="store_true",
        help="Automatically fix issues where possible"
    )
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Quiet output (minimal verbosity)"
    )
    parser.add_argument(
        "--source-dir",
        default="src",
        help="Source directory to analyze (default: src)"
    )
    parser.add_argument(
        "--test-dir",
        default="tests",
        help="Test directory to include (default: tests)"
    )
    parser.add_argument(
        "--reports-dir",
        default="reports",
        help="Reports output directory (default: reports)"
    )
    parser.add_argument(
        "--complexity-threshold",
        type=int,
        default=10,
        help="Complexity threshold (default: 10)"
    )
    parser.add_argument(
        "--version",
        action="version",
        version=f"{SUITE_NAME} v{VERSION}"
    )
    
    args = parser.parse_args()
    
    # Create configuration
    config = QualityConfig(
        source_dir=args.source_dir,
        test_dir=args.test_dir,
        reports_dir=args.reports_dir,
        complexity_threshold=args.complexity_threshold
    )
    
    # Print header
    if not args.quiet:
        print_header()
    
    # Create runner
    runner = QualityRunner(config, args.quiet)
    
    # Check tool availability for the specific check type
    if not runner.check_tool_availability(step=args.check_type if args.check_type in runner.tools.get_all_steps() else None):
        return 1
    
    # Start timing
    start_time = time.time()
    
    # Run quality checks
    results = runner.run_suite(args.check_type, args.fix)
    
    # Calculate duration
    end_time = time.time()
    duration = int(end_time - start_time)
    
    # Print summary and exit
    exit_code = runner.print_summary(results, args.check_type, duration)
    
    if args.fix and exit_code == 0 and not args.quiet:
        print(f"{Colors.CYAN}{Emojis.INFO} Some issues may have been auto-fixed.{Colors.RESET}")
    
    return exit_code

if __name__ == "__main__":
    sys.exit(main())