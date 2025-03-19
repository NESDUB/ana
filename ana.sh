cat > ana.sh << 'EOF'
#!/bin/bash

# Configurable parameters
MAX_LINES=4500
MAX_FILES_PER_DIR=100
DIR_DEPTH=2
FILE_DEPTH=6
SKIP_DIRS=("node_modules" "__pycache__" ".git" "dist" "build" ".nuxt" ".output" ".cache" ".github")
SKIP_FILES=("package-lock.json" "jest.config.ts" "app-debug.log" "bundle.js" "music_downloader_debug.log" "*.min.*" "*.png" "*.jpg" "*.jpeg" "*.gif" "*.zip" "*.ico" "*.svg" "*.pdf" "*.DS_Store")
DEBUG=true
VERBOSE=false

# Create temp files for counting across subshells
PROCESSED_COUNT_FILE=$(mktemp)
SKIPPED_COUNT_FILE=$(mktemp)
LARGE_COUNT_FILE=$(mktemp)
echo 0 > "$PROCESSED_COUNT_FILE"
echo 0 > "$SKIPPED_COUNT_FILE"
echo 0 > "$LARGE_COUNT_FILE"

# Function to increment counter files
increment_counter() {
    local file="$1"
    local count=$(cat "$file")
    echo $((count + 1)) > "$file"
}

# Get file size in human-readable format
get_file_size() {
    local file="$1"
    local size=$(du -h "$file" | cut -f1)
    echo "$size"
}

# Determine file language for code block syntax highlighting
get_file_language() {
    local file="$1"
    local ext="${file##*.}"
    
    case "$ext" in
        js|jsx) echo "javascript" ;;
        ts|tsx) echo "typescript" ;;
        py) echo "python" ;;
        rb) echo "ruby" ;;
        go) echo "go" ;;
        rs) echo "rust" ;;
        java) echo "java" ;;
        c|cpp|h|hpp) echo "cpp" ;;
        cs) echo "csharp" ;;
        php) echo "php" ;;
        html) echo "html" ;;
        css) echo "css" ;;
        scss|sass) echo "scss" ;;
        md) echo "markdown" ;;
        json) echo "json" ;;
        xml) echo "xml" ;;
        yaml|yml) echo "yaml" ;;
        sh|bash) echo "bash" ;;
        *) echo "plaintext" ;;
    esac
}

# Display file content with line numbers
display_file_with_line_numbers() {
    local file="$1"
    local max_lines="$2"
    local total_lines=$(wc -l < "$file")
    local language=$(get_file_language "$file")
    
    echo "\`\`\`$language"
    
    if [[ "$total_lines" -gt "$max_lines" ]]; then
        echo "[Large file - showing first $max_lines of $total_lines lines]"
        cat "$file" | nl -ba -w4 -s'| ' | head -n "$max_lines"
        echo "... [truncated ${total_lines} total lines] ..."
        increment_counter "$LARGE_COUNT_FILE"
    else
        # Display entire file with line numbers, ensuring every line gets a number
        cat "$file" | nl -ba -w4 -s'| ' | sed -E 's/^\s*([0-9]+)\|/\1|/'
    fi
    
    # Make sure the closing backticks are on their own line
    echo ""
    echo "\`\`\`"
}

# Process each file's content
process_file_content() {
    local file="$1"
    
    # Skip files in the SKIP_FILES list
    for pattern in "${SKIP_FILES[@]}"; do
        if [[ "$file" == $pattern ]] || [[ "$file" =~ ${pattern//\*/.*} ]]; then
            if $DEBUG; then
                echo "[Skipped: $file - matched pattern $pattern]"
            fi
            increment_counter "$SKIPPED_COUNT_FILE"
            return
        fi
    done
    
    # Improved file type detection for configs and JSON
    if ! (file --mime-type "$file" | grep -q "text/" || 
         [[ "$file" == *.json ]] || 
         [[ "$file" == *.babelrc ]] || 
         [[ "$file" == *rc ]] || 
         [[ "$file" == *.config.* ]]); then
        echo "[Skipped: $file - binary/non-text]"
        increment_counter "$SKIPPED_COUNT_FILE"
        return
    fi
    
    # Add spacing before new file header
    
    # New format for file header
    local lines=$(wc -l < "$file" | tr -d ' ')
    local mod_time=$(date -r "$file" '+%Y-%m-%d')
    local file_size=$(get_file_size "$file")
    echo "## FILE: $file | Lines: $lines | Modified: $mod_time | Size: $file_size"

    # Security check - minimal indicator
    if [[ "$file" =~ \.(env|secret|key|cred)$ ]] || [[ "$file" =~ /(config|credentials)/ ]]; then
        echo "[SECURITY]"
    fi

    # Display file content with line numbers
    display_file_with_line_numbers "$file" "$MAX_LINES"
    
    # Increment processed count
    increment_counter "$PROCESSED_COUNT_FILE"
}

# Check if directory should be processed
should_process_directory() {
    local dir="$1"
    
    # Skip directories in the SKIP_DIRS list
    for skip_dir in "${SKIP_DIRS[@]}"; do
        if [[ "$dir" == *"/$skip_dir"* ]] || [[ "$dir" == *"$skip_dir/"* ]] || [[ "$dir" == "$skip_dir" ]]; then
            if $DEBUG && [[ "$dir" == "./$skip_dir" || "$dir" == "$skip_dir" ]]; then
                echo "Skipping excluded directory: $dir"
            fi
            return 1
        fi
    done
    
    # Check if directory has too many files
    local file_count=$(find "$dir" -maxdepth 1 -type f | wc -l)
    if [ "$file_count" -gt "$MAX_FILES_PER_DIR" ]; then
        echo "Skipping large directory: $dir ($file_count files)"
        return 1
    fi
    
    return 0
}

# Function to process a directory and its subdirectories
process_directory() {
    local dir="$1"
    local current_depth="${2:-1}"
    
    if [ "$current_depth" -gt "$FILE_DEPTH" ]; then
        return
    fi
    
    if ! should_process_directory "$dir"; then
        return
    fi
    
    # Process files in the current directory
    find "$dir" -maxdepth 1 -type f | sort | while read -r file; do
        process_file_content "$file"
    done
    
    # Process subdirectories recursively
    find "$dir" -maxdepth 1 -type d -not -path "$dir" | sort | while read -r subdir; do
        process_directory "$subdir" $((current_depth + 1))
    done
}

# Cleanup function for temp files
cleanup() {
    rm -f "$PROCESSED_COUNT_FILE" "$SKIPPED_COUNT_FILE" "$LARGE_COUNT_FILE" "$OUTPUT_FILE" 2>/dev/null
}

# Set trap for cleanup
trap cleanup EXIT

# Output file
OUTPUT_FILE=$(mktemp)

# Main script execution
(
    # Condensed metadata header
    echo "## Project Analysis | $(date +%F)"
    echo "- Excluded: ${SKIP_DIRS[*]} | Max lines: $MAX_LINES | Max files/dir: $MAX_FILES_PER_DIR"
    
    if [ "$#" -eq 0 ]; then
        # No arguments: scan current directory
        echo "## Structure"
        if command -v tree &> /dev/null; then
            tree -L "$DIR_DEPTH" -I "$(IFS=\|; echo "${SKIP_DIRS[*]}")" --noreport
        else
            echo "Tree command not found. Install it for directory structure visualization."
            find . -type d -maxdepth "$DIR_DEPTH" | sort | grep -v -E "$(IFS=\|; echo "${SKIP_DIRS[*]}" | sed 's/^/\.\//;s/$/\//')"
        fi
        
        echo "## Code Analysis"
        process_directory "."
    else
        # Arguments provided: process specific files/directories
        echo "## Code Analysis"
        for target in "$@"; do
            if [[ -f "$target" ]]; then
                process_file_content "$target"
            elif [[ -d "$target" ]]; then
                process_directory "$target"
            else
                echo "Error: '$target' is not a valid file or directory"
            fi
        done
    fi
) | sed -e 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_FILE"

# Display results and generate statistics
cat "$OUTPUT_FILE"
echo "## Final Statistics"
echo "- Files Processed: $(cat $PROCESSED_COUNT_FILE)"
echo "- Files Skipped: $(cat $SKIPPED_COUNT_FILE)"
echo "- Large Files: $(cat $LARGE_COUNT_FILE)"

# Note: Cleanup will happen automatically via trap
EOF