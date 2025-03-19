Here's the complete README.md file for your Ana project:

```markdown
# Ana: Code Analyzer for LLM Context

Ana (short for Analyzer) is a powerful bash utility that helps bridge the gap between your codebase and LLMs like ChatGPT and Claude. It quickly generates clean, formatted output of your code with proper syntax highlighting and line numbers - perfect for providing context to LLMs when seeking help with debugging, refactoring, or adding new features.

## Features

- **Syntax Highlighting**: Automatically detects and applies proper language highlighting
- **Line Numbers**: Essential for referencing specific code sections in conversations
- **Smart Filtering**: Skips binary files, large directories, and common exclude patterns
- **Project Structure**: Shows a tree view of your project organization
- **Security Awareness**: Flags potentially sensitive files
- **Metadata Enriched**: Includes file sizes, line counts, and modification dates

## Installation

### Quick Install (One Line)

```bash
curl -o- https://raw.githubusercontent.com/NESDUB/ana/main/install.sh | bash
```

### Manual Install

```bash
# Download the script
curl -o ~/ana https://raw.githubusercontent.com/NESDUB/ana/main/ana.sh

# Make it executable
chmod +x ~/ana

# Move to a location in your PATH
sudo mv ~/ana /usr/local/bin/ana
# Or without sudo:
mkdir -p ~/.local/bin
mv ~/ana ~/.local/bin/ana
# Then add to PATH if needed:
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

### Basic Usage

```bash
# Analyze current directory
ana

# Analyze specific file
ana path/to/myfile.js

# Analyze specific directory
ana path/to/myproject/

# Analyze multiple specific files
ana server.js routes/api.js models/user.js
```

### Real-World Examples

1. **Debugging with an LLM**:
   ```bash
   ana buggy_file.py | pbcopy  # Copy to clipboard on macOS
   # Then paste into ChatGPT/Claude with "What's wrong with this code?"
   ```

2. **Project context for a feature request**:
   ```bash
   ana src/components/ | pbcopy
   # Now LLMs understand your component structure
   ```

3. **Focused analysis for code review**:
   ```bash
   ana $(git diff --name-only main)
   # Analyze only files changed compared to main branch
   ```

## Configuration

Ana comes with sensible defaults but can be customized by editing these variables at the top of the script:

- `MAX_LINES=4500` - Limits output for large files
- `MAX_FILES_PER_DIR=100` - Skips directories with too many files
- `DIR_DEPTH=2` - How deep to show the directory structure
- `FILE_DEPTH=6` - How deep to recurse into subdirectories
- `SKIP_DIRS=("node_modules" "__pycache__" ".git" ...)` - Directories to ignore
- `SKIP_FILES=("package-lock.json" "*.min.*" "*.jpg" ...)` - Files to ignore
- `DEBUG=true` - Show debug information
- `VERBOSE=false` - Enable for more detailed output

## How It Works

Ana intelligently processes your codebase to create LLM-friendly output:

1. **Smart Directory Traversal**: Recursively scans directories up to configured depth
2. **Intelligent Filtering**: Skips binaries, large files, and configured exclusions
3. **Language Detection**: Identifies file types for proper syntax highlighting
4. **Metadata Enrichment**: Adds file information like size, line count, and dates
5. **Security Awareness**: Flags potentially sensitive configuration files
6. **Standardized Formatting**: Produces clean, consistent output with line numbers

## Use Cases

- **Debugging**: Share problematic code with context for faster troubleshooting
- **Refactoring**: Get AI-assisted refactoring suggestions with full context
- **Learning**: Discuss code structure and patterns with LLMs
- **Code Reviews**: Get AI feedback on your implementation
- **Feature Planning**: Discuss new features with existing codebase context

## Tips

- Use with clipboard tools (`pbcopy` on macOS, `clip` on Windows, `xclip` on Linux) for seamless workflow
- For very large projects, target specific directories or files to stay within token limits
- Configure the exclusion lists to match your project's unique structure
- Combine with git commands to focus on recently changed files

## License

MIT

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
```

You can copy this entire markdown content and save it as README.md in your repository. It provides comprehensive information about Ana, its features, installation methods, usage examples, and more.