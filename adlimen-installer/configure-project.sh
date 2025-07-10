#!/bin/bash

#####################################################################
# AdLimen Quality Code System - Project Configuration Script
# Programmatic configuration setup based on project type detection
# Supports configuration templates and custom project setup
#####################################################################

set -e  # Exit on any error

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Emojis
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
MAGNIFYING="🔍"

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TEMPLATES_DIR="$SCRIPT_DIR/config-templates"
PROJECT_ROOT="$(pwd)"
CONFIG_FILE=".adlimen-config.json"

# Available project types
PROJECT_TYPES=("basic" "fullstack" "monorepo" "microservices" "frontend-only" "backend-only")

#####################################################################
# Utility Functions
#####################################################################

print_header() {
    echo -e "${CYAN}${WHITE}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              AdLimen Project Configuration Script              ║"
    echo "║                 Automated Project Setup Tool                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${PURPLE}Configure your project with pre-built templates and custom settings${NC}"
    echo ""
}

print_message() {
    local level=$1
    local message=$2
    local emoji=""
    local color=""
    
    case $level in
        "success") emoji="${SUCCESS}"; color="${GREEN}" ;;
        "error") emoji="${ERROR}"; color="${RED}" ;;
        "warning") emoji="${WARNING}"; color="${YELLOW}" ;;
        "info") emoji="${INFO}"; color="${BLUE}" ;;
        *) emoji="${INFO}"; color="${WHITE}" ;;
    esac
    
    echo -e "${emoji} ${color}${message}${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect project structure and type
detect_project_type() {
    print_message "info" "Analyzing project structure..."
    
    local detected_type="basic"
    local languages=()
    local frameworks=()
    
    # Detect languages
    if [ -f "package.json" ] || [ -f "tsconfig.json" ] || find . -maxdepth 2 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | head -1 | grep -q .; then
        languages+=("javascript")
    fi
    
    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ] || find . -maxdepth 2 -name "*.py" | head -1 | grep -q .; then
        languages+=("python")
    fi
    
    # Detect frameworks
    if [ -f "package.json" ]; then
        if grep -q "react" package.json; then
            frameworks+=("react")
        fi
        if grep -q "express" package.json; then
            frameworks+=("express")
        fi
        if grep -q "next" package.json; then
            frameworks+=("next")
        fi
    fi
    
    if [ -f "requirements.txt" ]; then
        if grep -q -i "flask" requirements.txt; then
            frameworks+=("flask")
        fi
        if grep -q -i "django" requirements.txt; then
            frameworks+=("django")
        fi
        if grep -q -i "fastapi" requirements.txt; then
            frameworks+=("fastapi")
        fi
    fi
    
    # Detect project structure type
    local has_services=false
    local has_packages=false
    local has_frontend=false
    local has_backend=false
    
    # Check for common directory patterns
    for dir in "services" "microservices"; do
        if [ -d "$dir" ] && [ "$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)" -gt 1 ]; then
            has_services=true
            break
        fi
    done
    
    for dir in "packages" "apps" "libs"; do
        if [ -d "$dir" ] && [ "$(find "$dir" -mindepth 1 -maxdepth 1 -type d | wc -l)" -gt 1 ]; then
            has_packages=true
            break
        fi
    done
    
    for dir in "frontend" "client" "web" "ui" "app"; do
        if [ -d "$dir" ]; then
            has_frontend=true
            break
        fi
    done
    
    for dir in "backend" "server" "api"; do
        if [ -d "$dir" ]; then
            has_backend=true
            break
        fi
    done
    
    # Determine project type
    if [ "$has_services" = true ]; then
        detected_type="microservices"
    elif [ "$has_packages" = true ]; then
        detected_type="monorepo"
    elif [ "$has_frontend" = true ] && [ "$has_backend" = true ]; then
        detected_type="fullstack"
    elif [ "$has_frontend" = true ] || ([ ${#languages[@]} -eq 1 ] && [[ " ${languages[@]} " =~ " javascript " ]]); then
        detected_type="frontend-only"
    elif [ "$has_backend" = true ] || ([ ${#languages[@]} -eq 1 ] && [[ " ${languages[@]} " =~ " python " ]]); then
        detected_type="backend-only"
    fi
    
    echo "$detected_type"
}

# List available configuration templates
list_templates() {
    print_message "info" "Available configuration templates:"
    echo ""
    
    for template in "${PROJECT_TYPES[@]}"; do
        local template_file="$CONFIG_TEMPLATES_DIR/${template}-config.json"
        if [ -f "$template_file" ]; then
            echo -e "  ${GREEN}${template}${NC} - $(get_template_description "$template")"
        else
            echo -e "  ${YELLOW}${template}${NC} - Template not found"
        fi
    done
    echo ""
}

# Get template description
get_template_description() {
    local template=$1
    case $template in
        "basic") echo "Simple single-language project" ;;
        "fullstack") echo "Frontend + Backend full-stack application" ;;
        "monorepo") echo "Multiple packages in single repository" ;;
        "microservices") echo "Multiple independent services" ;;
        "frontend-only") echo "Client-side application only" ;;
        "backend-only") echo "Server-side API or service only" ;;
        *) echo "Configuration template" ;;
    esac
}

# Apply configuration template
apply_template() {
    local template_type=$1
    local template_file="$CONFIG_TEMPLATES_DIR/${template_type}-config.json"
    
    if [ ! -f "$template_file" ]; then
        print_message "error" "Template file not found: $template_file"
        return 1
    fi
    
    print_message "info" "Applying $template_type configuration template..."
    
    # Copy template and customize for current project
    cp "$template_file" "$CONFIG_FILE"
    
    # Update project-specific fields
    local current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local project_name=$(basename "$PROJECT_ROOT")
    
    # Use jq to update configuration if available
    if command_exists jq; then
        local temp_config=$(mktemp)
        jq "
            .adlimen.installedDate = \"$current_date\" |
            .adlimen.projectRoot = \"$PROJECT_ROOT\" |
            .adlimen.projectName = \"$project_name\"
        " "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
    else
        # Basic sed replacement if jq is not available
        sed -i.bak "s|\"projectRoot\": \"/path/to/project\"|\"projectRoot\": \"$PROJECT_ROOT\"|g" "$CONFIG_FILE"
        sed -i.bak "s|\"installedDate\": \"2025-07-10T12:00:00Z\"|\"installedDate\": \"$current_date\"|g" "$CONFIG_FILE"
        rm -f "$CONFIG_FILE.bak"
    fi
    
    print_message "success" "Configuration template applied: $CONFIG_FILE"
}

# Interactive configuration customization
customize_configuration() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_message "error" "No configuration file found. Apply a template first."
        return 1
    fi
    
    print_message "info" "Customizing configuration..."
    echo ""
    
    # Read current configuration
    local current_languages=""
    local current_interface=""
    local current_complexity=""
    
    if command_exists jq; then
        current_languages=$(jq -r '.adlimen.languages | join(", ")' "$CONFIG_FILE" 2>/dev/null || echo "")
        current_interface=$(jq -r '.adlimen.interface' "$CONFIG_FILE" 2>/dev/null || echo "")
        current_complexity=$(jq -r '.adlimen.thresholds.complexity // .adlimen.thresholds.default.complexity // empty' "$CONFIG_FILE" 2>/dev/null || echo "10")
    fi
    
    # Customize languages
    echo -e "${YELLOW}Current languages: ${current_languages}${NC}"
    read -p "Languages (javascript,python) [current]: " new_languages
    if [ -n "$new_languages" ]; then
        if command_exists jq; then
            local languages_array=$(echo "$new_languages" | sed 's/,/","/g' | sed 's/^/["/' | sed 's/$/"]/')
            local temp_config=$(mktemp)
            jq ".adlimen.languages = $languages_array" "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
        fi
    fi
    
    # Customize interface
    echo -e "${YELLOW}Current interface: ${current_interface}${NC}"
    echo "Available interfaces: npm, make, both"
    read -p "Preferred interface [current]: " new_interface
    if [ -n "$new_interface" ]; then
        if command_exists jq; then
            local temp_config=$(mktemp)
            jq ".adlimen.interface = \"$new_interface\"" "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
        fi
    fi
    
    # Customize complexity threshold
    echo -e "${YELLOW}Current complexity threshold: ${current_complexity}${NC}"
    read -p "Complexity threshold (1-20) [current]: " new_complexity
    if [ -n "$new_complexity" ] && [[ "$new_complexity" =~ ^[0-9]+$ ]]; then
        if command_exists jq; then
            local temp_config=$(mktemp)
            # Handle both nested and flat threshold structures
            jq "
                if .adlimen.thresholds.complexity then
                    .adlimen.thresholds.complexity = $new_complexity
                elif .adlimen.thresholds.default.complexity then
                    .adlimen.thresholds.default.complexity = $new_complexity
                elif .adlimen.thresholds.javascript.complexity then
                    .adlimen.thresholds.javascript.complexity = $new_complexity
                else
                    .adlimen.thresholds.complexity = $new_complexity
                end
            " "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
        fi
    fi
    
    # Enable/disable features
    echo ""
    read -p "Enable security scanning? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command_exists jq; then
            local temp_config=$(mktemp)
            jq '.adlimen.features.security = true' "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
        fi
    fi
    
    read -p "Setup git hooks? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if command_exists jq; then
            local temp_config=$(mktemp)
            jq '.adlimen.features.gitHooks = true' "$CONFIG_FILE" > "$temp_config" && mv "$temp_config" "$CONFIG_FILE"
        fi
    fi
    
    print_message "success" "Configuration customized successfully"
}

# Validate configuration file
validate_configuration() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_message "error" "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    print_message "info" "Validating configuration..."
    
    # Basic JSON validation
    if command_exists jq; then
        if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
            print_message "error" "Invalid JSON in configuration file"
            return 1
        fi
        
        # Check required fields
        local required_fields=(".adlimen.version" ".adlimen.languages" ".adlimen.thresholds")
        for field in "${required_fields[@]}"; do
            if ! jq -e "$field" "$CONFIG_FILE" >/dev/null 2>&1; then
                print_message "warning" "Missing required field: $field"
            fi
        done
        
        print_message "success" "Configuration validation passed"
    else
        print_message "warning" "jq not available - skipping detailed validation"
    fi
}

# Display current configuration
show_configuration() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_message "error" "No configuration file found"
        return 1
    fi
    
    print_message "info" "Current configuration:"
    echo ""
    
    if command_exists jq; then
        echo -e "${CYAN}Project Details:${NC}"
        echo "  Type: $(jq -r '.adlimen.projectType // "basic"' "$CONFIG_FILE")"
        echo "  Languages: $(jq -r '.adlimen.languages | join(", ")' "$CONFIG_FILE")"
        echo "  Interface: $(jq -r '.adlimen.interface' "$CONFIG_FILE")"
        echo ""
        
        echo -e "${CYAN}Quality Thresholds:${NC}"
        if jq -e '.adlimen.thresholds.complexity' "$CONFIG_FILE" >/dev/null 2>&1; then
            echo "  Complexity: $(jq -r '.adlimen.thresholds.complexity' "$CONFIG_FILE")"
            echo "  Maintainability: $(jq -r '.adlimen.thresholds.maintainability' "$CONFIG_FILE")"
            echo "  Duplication: $(jq -r '.adlimen.thresholds.duplication' "$CONFIG_FILE")"
        else
            echo "  Multiple threshold configurations (see full config)"
        fi
        echo ""
        
        echo -e "${CYAN}Enabled Features:${NC}"
        echo "  Security: $(jq -r '.adlimen.features.security // .adlimen.features.security.enabled' "$CONFIG_FILE")"
        echo "  Git Hooks: $(jq -r '.adlimen.features.gitHooks' "$CONFIG_FILE")"
        echo "  CI Provider: $(jq -r '.adlimen.features.ciProvider' "$CONFIG_FILE")"
        echo ""
    else
        echo "Configuration file exists but jq is required for detailed display"
        echo "Install jq for better configuration management: brew install jq"
    fi
}

# Show usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  detect                     Auto-detect and apply project configuration"
    echo "  template <type>            Apply specific template configuration"
    echo "  customize                  Interactively customize current configuration"
    echo "  validate                   Validate current configuration file"
    echo "  show                       Display current configuration"
    echo "  list                       List available templates"
    echo ""
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -c, --config <file>        Use custom configuration file (default: .adlimen-config.json)"
    echo "  -t, --template-dir <dir>   Use custom template directory"
    echo ""
    echo "Examples:"
    echo "  $0 detect                  # Auto-detect and configure"
    echo "  $0 template fullstack      # Apply fullstack template"
    echo "  $0 customize               # Customize current config"
    echo "  $0 show                    # Show current configuration"
}

#####################################################################
# Main Script Logic
#####################################################################

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -t|--template-dir)
                CONFIG_TEMPLATES_DIR="$2"
                shift 2
                ;;
            detect)
                command="detect"
                shift
                ;;
            template)
                command="template"
                template_type="$2"
                shift 2
                ;;
            customize)
                command="customize"
                shift
                ;;
            validate)
                command="validate"
                shift
                ;;
            show)
                command="show"
                shift
                ;;
            list)
                command="list"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Default command if none specified
    if [ -z "${command:-}" ]; then
        command="detect"
    fi
    
    print_header
    
    # Execute command
    case $command in
        "detect")
            detected_type=$(detect_project_type)
            print_message "success" "Detected project type: $detected_type"
            apply_template "$detected_type"
            print_message "info" "You can now customize the configuration with: $0 customize"
            ;;
        "template")
            if [ -z "${template_type:-}" ]; then
                print_message "error" "Template type required"
                list_templates
                exit 1
            fi
            if [[ ! " ${PROJECT_TYPES[@]} " =~ " ${template_type} " ]]; then
                print_message "error" "Invalid template type: $template_type"
                list_templates
                exit 1
            fi
            apply_template "$template_type"
            ;;
        "customize")
            customize_configuration
            ;;
        "validate")
            validate_configuration
            ;;
        "show")
            show_configuration
            ;;
        "list")
            list_templates
            ;;
        *)
            print_message "error" "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Check prerequisites
if ! command_exists jq; then
    print_message "warning" "jq not found - some features will be limited"
    print_message "info" "Install jq for full functionality: brew install jq (macOS) or apt-get install jq (Ubuntu)"
fi

# Run main function
main "$@"