#!/usr/bin/env python3
"""
Complete Quality Suite - Python Duplication Check
Code duplication detection and analysis for Python projects
"""

import os
import sys
import subprocess
import argparse
import json
from pathlib import Path
from typing import Dict, List, Optional
import time

# Colors and formatting (reuse from main script)
class Colors:
    RESET = '\033[0m'
    BRIGHT = '\033[1m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    CYAN = '\033[36m'

class Emojis:
    SUCCESS = '✅'
    ERROR = '❌'
    WARNING = '⚠️'
    INFO = 'ℹ️'
    CHART = '📊'
    MAGNIFYING = '🔍'
    FILE = '📄'

# Configuration
CONFIG = {
    'project_name': 'Python Project',
    'source_dir': 'src',
    'output_dir': 'reports/python/duplication',
    'thresholds': {
        'min_lines': 5,
        'min_tokens': 50,
        'max_percentage': 10.0,  # Maximum allowed duplication percentage
    },
    'ignore_patterns': [
        '__pycache__',
        '.pytest_cache',
        '.mypy_cache',
        'node_modules',
        'venv',
        '.venv',
        'htmlcov',
        'coverage',
        'dist',
        'build',
        '*.egg-info',
        'tests',
        'test',
        '*_test.py',
        'test_*.py',
    ],
}

def print_message(message: str, color: str = Colors.RESET, emoji: str = '') -> None:
    """Print colored and formatted messages."""
    print(f"{emoji} {color}{message}{Colors.RESET}")

def print_help() -> None:
    """Print help information."""
    print(f"""{Colors.CYAN}{Colors.BRIGHT}
╔══════════════════════════════════════════════════════════════╗
║                    Python Code Duplication Analysis          ║
║                      {CONFIG['project_name']}                      ║
╚══════════════════════════════════════════════════════════════╝{Colors.RESET}

{Colors.YELLOW}Usage:{Colors.RESET}
  python python-duplication-check.py [options]

{Colors.YELLOW}Options:{Colors.RESET}
  {Colors.GREEN}--threshold=N{Colors.RESET}      Duplication threshold percentage (default: {CONFIG['thresholds']['max_percentage']}%)
  {Colors.GREEN}--source-dir=DIR{Colors.RESET}   Source directory to analyze (default: {CONFIG['source_dir']})
  {Colors.GREEN}--project-name=NAME{Colors.RESET} Project name for reports (default: {CONFIG['project_name']})
  {Colors.GREEN}--format=FORMAT{Colors.RESET}     Output format: console, json, all (default: console)
  {Colors.GREEN}--verbose, -v{Colors.RESET}       Verbose output
  {Colors.GREEN}--quiet, -q{Colors.RESET}         Quiet output
  {Colors.GREEN}--help, -h{Colors.RESET}          Show this help

{Colors.YELLOW}Thresholds:{Colors.RESET}
  Minimum lines: {CONFIG['thresholds']['min_lines']}
  Minimum tokens: {CONFIG['thresholds']['min_tokens']}
  Maximum duplication: {CONFIG['thresholds']['max_percentage']}%

{Colors.YELLOW}Examples:{Colors.RESET}
  {Colors.CYAN}python python-duplication-check.py{Colors.RESET}
  {Colors.CYAN}python python-duplication-check.py --threshold=5{Colors.RESET}
  {Colors.CYAN}python python-duplication-check.py --source-dir=lib --format=json{Colors.RESET}
""")

def check_tool_availability() -> bool:
    """Check if required tools are available."""
    try:
        # Try to import ast (built-in) and check for external tools
        import ast
        # For now, we'll implement a simple Python-based duplication checker
        # In a full implementation, you might want to use tools like:
        # - duplicate-code-detection-tool
        # - pylint's similarity checker
        # - Or implement a custom AST-based solution
        return True
    except ImportError:
        return False

def find_python_files(source_dir: str) -> List[Path]:
    """Find all Python files in the source directory."""
    files = []
    source_path = Path(source_dir)
    
    if not source_path.exists():
        return files
    
    for py_file in source_path.rglob('*.py'):
        # Check if file should be ignored
        relative_path = py_file.relative_to(Path.cwd())
        should_ignore = any(
            pattern in str(relative_path) or py_file.match(pattern)
            for pattern in CONFIG['ignore_patterns']
        )
        
        if not should_ignore:
            files.append(py_file)
    
    return files

def simple_duplication_check(files: List[Path]) -> Dict:
    """Simple line-based duplication detection."""
    results = {
        'total_files': len(files),
        'total_lines': 0,
        'duplicated_lines': 0,
        'duplicated_blocks': [],
        'percentage': 0.0,
    }
    
    # Dictionary to store line hashes and their occurrences
    line_occurrences = {}
    file_lines = {}
    
    # Read all files and hash lines
    for file_path in files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                file_lines[file_path] = lines
                results['total_lines'] += len(lines)
                
                for line_num, line in enumerate(lines, 1):
                    # Skip empty lines and comments for duplication check
                    cleaned_line = line.strip()
                    if len(cleaned_line) < 10 or cleaned_line.startswith('#'):
                        continue
                    
                    line_hash = hash(cleaned_line)
                    if line_hash not in line_occurrences:
                        line_occurrences[line_hash] = []
                    line_occurrences[line_hash].append((file_path, line_num, cleaned_line))
        except (UnicodeDecodeError, PermissionError):
            continue
    
    # Find duplicated lines
    duplicated_line_count = 0
    for line_hash, occurrences in line_occurrences.items():
        if len(occurrences) > 1:
            duplicated_line_count += len(occurrences)
            
            # Group consecutive duplicated lines into blocks
            for file_path, line_num, line_content in occurrences:
                results['duplicated_blocks'].append({
                    'file': str(file_path),
                    'line': line_num,
                    'content': line_content,
                    'occurrences': len(occurrences)
                })
    
    results['duplicated_lines'] = duplicated_line_count
    if results['total_lines'] > 0:
        results['percentage'] = (duplicated_line_count / results['total_lines']) * 100
    
    return results

def run_duplication_analysis(options: Dict) -> bool:
    """Run duplication analysis."""
    source_dir = options.get('source_dir', CONFIG['source_dir'])
    
    if not options.get('quiet'):
        print_message('Running Python code duplication analysis...', Colors.CYAN, Emojis.MAGNIFYING)
        if options.get('verbose'):
            print(f"  Source directory: {source_dir}")
            print(f"  Min lines: {CONFIG['thresholds']['min_lines']}")
            print(f"  Threshold: {CONFIG['thresholds']['max_percentage']}%")
    
    # Find Python files
    files = find_python_files(source_dir)
    
    if not files:
        print_message(f"No Python files found in {source_dir}", Colors.YELLOW, Emojis.WARNING)
        return True
    
    if options.get('verbose') and not options.get('quiet'):
        print(f"  Found {len(files)} Python files")
    
    # Run analysis
    start_time = time.time()
    results = simple_duplication_check(files)
    duration = int((time.time() - start_time) * 1000)
    
    # Create output directory
    output_dir = Path(CONFIG['output_dir'])
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save results
    results_file = output_dir / 'duplication-report.json'
    with open(results_file, 'w') as f:
        json.dump(results, f, indent=2, default=str)
    
    # Print summary
    provide_summary(results, options, duration)
    
    # Determine success based on threshold
    threshold = options.get('threshold', CONFIG['thresholds']['max_percentage'])
    return results['percentage'] <= threshold

def provide_summary(results: Dict, options: Dict, duration: int) -> None:
    """Provide summary of duplication results."""
    if options.get('quiet'):
        return
    
    print(f"\n{'=' * 60}")
    print_message(f"{Emojis.CHART} DUPLICATION ANALYSIS SUMMARY", Colors.CYAN + Colors.BRIGHT)
    print('=' * 60)
    
    print(f"Analysis completed in {duration}ms")
    print(f"Total files analyzed: {results['total_files']}")
    print(f"Total lines: {results['total_lines']}")
    print(f"Duplicated lines: {results['duplicated_lines']}")
    
    percentage = results['percentage']
    threshold = options.get('threshold', CONFIG['thresholds']['max_percentage'])
    
    if percentage <= threshold:
        print_message(f"\nDuplication: {percentage:.2f}% {Emojis.SUCCESS}", Colors.GREEN)
        print_message(f"Within threshold: {threshold}%", Colors.GREEN)
    else:
        print_message(f"\nDuplication: {percentage:.2f}% {Emojis.ERROR}", Colors.RED)
        print_message(f"Exceeds threshold: {threshold}%", Colors.RED)
    
    # Show top duplications if available and verbose
    if results['duplicated_blocks'] and options.get('verbose'):
        print(f"\n{Colors.YELLOW}Sample duplications:{Colors.RESET}")
        
        # Group by content and show most frequent
        content_counts = {}
        for block in results['duplicated_blocks']:
            content = block['content']
            if content not in content_counts:
                content_counts[content] = {'count': 0, 'files': set()}
            content_counts[content]['count'] += 1
            content_counts[content]['files'].add(block['file'])
        
        # Sort by frequency and show top 5
        top_duplications = sorted(
            content_counts.items(),
            key=lambda x: x[1]['count'],
            reverse=True
        )[:5]
        
        for i, (content, info) in enumerate(top_duplications, 1):
            print(f"\n{i}. {Emojis.FILE} Appears {info['count']} times")
            print(f"   Files: {len(info['files'])}")
            preview = content[:80] + "..." if len(content) > 80 else content
            print(f"   {Colors.BLUE}\"{preview}\"{Colors.RESET}")
    
    # Report location
    print(f"\n{Colors.YELLOW}Report saved:{Colors.RESET}")
    print(f"  JSON: {CONFIG['output_dir']}/duplication-report.json")
    
    if percentage > threshold:
        print(f"\n{Colors.RED}{Emojis.WARNING} Recommendations:{Colors.RESET}")
        print("  • Extract duplicated code into reusable functions")
        print("  • Create utility modules for common patterns")
        print("  • Use inheritance or composition to reduce repetition")
        print("  • Consider design patterns like Strategy or Template Method")

def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Python Code Duplication Analysis",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '--threshold',
        type=float,
        default=CONFIG['thresholds']['max_percentage'],
        help=f'Duplication threshold percentage (default: {CONFIG["thresholds"]["max_percentage"]})'
    )
    
    parser.add_argument(
        '--source-dir',
        default=CONFIG['source_dir'],
        help=f'Source directory to analyze (default: {CONFIG["source_dir"]})'
    )
    
    parser.add_argument(
        '--project-name',
        default=CONFIG['project_name'],
        help=f'Project name for reports (default: {CONFIG["project_name"]})'
    )
    
    parser.add_argument(
        '--format',
        choices=['console', 'json', 'all'],
        default='console',
        help='Output format (default: console)'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )
    
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Quiet output'
    )
    
    return parser.parse_args()

def main() -> int:
    """Main execution function."""
    args = parse_args()
    
    # Handle help
    if len(sys.argv) == 1 or '--help' in sys.argv or '-h' in sys.argv:
        print_help()
        return 0
    
    # Update config
    CONFIG['source_dir'] = args.source_dir
    CONFIG['project_name'] = args.project_name
    CONFIG['thresholds']['max_percentage'] = args.threshold
    
    # Print header
    if not args.quiet:
        print(f"""{Colors.CYAN}{Colors.BRIGHT}
╔══════════════════════════════════════════════════════════════╗
║                    Python Code Duplication Analysis          ║
║                      {CONFIG['project_name']}                      ║
║                     Source: {CONFIG['source_dir']}                         ║
╚══════════════════════════════════════════════════════════════╝{Colors.RESET}
""")
    
    # Check tool availability
    if not check_tool_availability():
        print_message("Required tools not available", Colors.RED, Emojis.ERROR)
        return 1
    
    # Run analysis
    options = {
        'source_dir': args.source_dir,
        'project_name': args.project_name,
        'threshold': args.threshold,
        'format': args.format,
        'verbose': args.verbose,
        'quiet': args.quiet,
    }
    
    success = run_duplication_analysis(options)
    
    if not args.quiet:
        if success:
            print_message(f"\n{Emojis.SUCCESS} Duplication check passed!", Colors.GREEN + Colors.BRIGHT)
        else:
            print_message(f"\n{Emojis.ERROR} Duplication check failed!", Colors.RED + Colors.BRIGHT)
    
    return 0 if success else 1

if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print_message("\nOperation cancelled by user", Colors.YELLOW, Emojis.WARNING)
        sys.exit(1)
    except Exception as e:
        print_message(f"Unexpected error: {str(e)}", Colors.RED, Emojis.ERROR)
        sys.exit(1)