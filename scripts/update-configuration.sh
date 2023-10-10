#!/bin/sh

# ANSI escape codes for colored text
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Flag for detailed logging
DETAILED_LOG=true

# Function to print logs with colors and optional indentation
log() {
    INDENT_LEVEL="$1"
    COLOR="$2"
    shift 2
    MESSAGE="$@"
    INDENT=$(printf "%${INDENT_LEVEL}s" "")
    echo -e "${INDENT}${COLOR}${MESSAGE}${NC}"
}

# Function to exit script in case of an error
exit_script() {
    log 2 $RED "Exiting due to error."
    exit 1
}

# Validate that essential folders and files exist
validate_environment() {
    [ ! -d "$TEMPLATE_FOLDER" ] && log 2 $RED "Template folder does not exist." && exit_script
    [ ! -f "$PARENT_DIR/.env" ] && log 2 $RED ".env file does not exist." && exit_script
}

# Load environment variables from .env and .env-secrets
load_environment_variables() {
    log 2 $GREEN "Loading environment variables..."
    set -a
    . "$PARENT_DIR/.env" || log 4 $RED "Could not load .env file."
    [ -f "$PARENT_DIR/.env-secrets" ] && . "$PARENT_DIR/.env-secrets" || log 4 $RED "Could not load .env-secrets file."
    set +a
    if [ "$DETAILED_LOG" = true ]; then
        log 4 $YELLOW "Loaded environment variables:"
        env | grep -Eo '^[a-zA-Z0-9_]*=' | sed 's/=$//' | while read -r var; do
            value=$(eval echo "\$$var")
            log 6 $YELLOW "$var=$value"
        done
    fi
}


# Main function to process templates
process_templates() {
    log 0 $GREEN "=== Starting Script ==="
    validate_environment
    load_environment_variables

    log 2 $GREEN "Starting variable replacement..."
    mkdir -p "$OUTPUT_FOLDER" || exit_script

    for filepath in $(find "$TEMPLATE_FOLDER" -type f); do
        relpath="${filepath#$TEMPLATE_FOLDER/}"
        outfile="$OUTPUT_FOLDER/$relpath"
        outdir=$(dirname "$outfile")

        mkdir -p "$outdir" || exit_script

        log 4 $YELLOW "Processing file: $relpath"

        # Substitute variables
        while IFS= read -r line; do
            echo $line | sed -e "s/\${\([a-zA-Z0-9_]*\)\}/\${\1:-}/g" > temp.txt
            while IFS= read -r line2; do
                eval echo "$line2"
            done < temp.txt
        done < "$filepath" > "$outfile" || exit_script

        # Debug line after substitution
        if [ "$DETAILED_LOG" = true ]; then
            log 6 $YELLOW "After substitution:"
            while IFS= read -r sub_line; do
                log 8 $YELLOW "$sub_line"
            done < "$outfile"
        fi
    done

    rm temp.txt || exit_script

    log 0 $GREEN "=== Script Completed ==="
}

# Get the parent directory of this script
PARENT_DIR=$(cd "$(dirname "$0")" && pwd -P || exit_script)
PARENT_DIR=$(dirname "$PARENT_DIR")

# Define the template and output folder paths
TEMPLATE_FOLDER="$PARENT_DIR/templates"
OUTPUT_FOLDER="$PARENT_DIR/config"

# Run the function to replace variables in templates and write to output folder
process_templates
