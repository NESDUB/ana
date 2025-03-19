cat > install.sh << 'EOF'
#!/bin/bash

# ana - Code Analyzer for LLM Context
# Installation script

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing ana - Code Analyzer for LLM Context${NC}"

# Download the ana script
curl -o ana https://raw.githubusercontent.com/NESDUB/ana/main/ana.sh

# Make the script executable
chmod +x ana

# Determine installation location
install_global() {
    echo -e "${BLUE}Installing ana globally to /usr/local/bin/${NC}"
    if sudo mv ana /usr/local/bin/; then
        echo -e "${GREEN}Installation successful! You can now run 'ana' from anywhere.${NC}"
    else
        echo -e "${RED}Failed to install globally. Attempting local installation...${NC}"
        install_local
    fi
}

install_local() {
    echo -e "${BLUE}Installing ana to ~/.local/bin/${NC}"
    mkdir -p ~/.local/bin
    if mv ana ~/.local/bin/; then
        echo -e "${GREEN}Installation successful!${NC}"
        
        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo -e "${BLUE}Adding ~/.local/bin to your PATH${NC}"
            
            # Determine shell and add to appropriate file
            if [[ "$SHELL" == */zsh ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
                echo -e "${GREEN}Added to ~/.zshrc - Please restart your terminal or run 'source ~/.zshrc'${NC}"
            elif [[ "$SHELL" == */bash ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
                echo -e "${GREEN}Added to ~/.bashrc - Please restart your terminal or run 'source ~/.bashrc'${NC}"
            else
                echo -e "${BLUE}Please add the following line to your shell profile:${NC}"
                echo 'export PATH="$HOME/.local/bin:$PATH"'
            fi
        else
            echo -e "${GREEN}~/.local/bin is already in your PATH. You can now run 'ana' from anywhere.${NC}"
        fi
    else
        echo -e "${RED}Installation failed.${NC}"
        exit 1
    fi
}

# Ask user for installation preference
echo -e "${BLUE}Would you like to install ana globally (requires sudo) or locally?${NC}"
echo "1) Globally (/usr/local/bin/ana) - Available to all users"
echo "2) Locally (~/.local/bin/ana) - Available only to you"
read -p "Choose option (1/2): " INSTALL_OPTION

case $INSTALL_OPTION in
    1)
        install_global
        ;;
    2)
        install_local
        ;;
    *)
        echo -e "${RED}Invalid option. Installing locally.${NC}"
        install_local
        ;;
esac

echo ""
echo -e "${GREEN}Ana installation complete!${NC}"
echo -e "${BLUE}Usage examples:${NC}"
echo "  ana                     # Analyze current directory"
echo "  ana path/to/file.js     # Analyze specific file"
echo "  ana path/to/directory/  # Analyze specific directory"
echo ""
echo -e "${BLUE}For more information and examples, visit:${NC}"
echo "  https://github.com/NESDUB/ana"
EOF