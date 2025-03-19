cat > README.md << 'EOF'
# Ana: Code Analyzer for LLM Context

Ana (short for Analyzer) is a powerful bash utility that helps bridge the gap between your codebase and LLMs like ChatGPT and Claude. It quickly generates clean, formatted output of your code with proper syntax highlighting and line numbers - perfect for providing context to LLMs when seeking help with debugging, refactoring, or adding new features.

![Ana Demo](https://github.com/NESDUB/ana/raw/main/images/ana-demo.png)

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