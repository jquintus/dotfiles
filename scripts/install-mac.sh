#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if a file exists and is readable
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ ! -f "$file" ]]; then
        print_error "Source file does not exist: $file"
        print_error "Cannot install $description"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        print_error "Source file is not readable: $file"
        print_error "Cannot install $description"
        return 1
    fi
    
    return 0
}

# Function to safely create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    # Check if source file exists
    if ! check_file "$source" "$description"; then
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        print_status "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Remove existing target if it exists
    if [[ -L "$target" ]]; then
        print_status "Removing existing symlink: $target"
        rm "$target"
    elif [[ -f "$target" ]]; then
        print_status "Removing existing file: $target"
        rm "$target"
    fi
    
    # Create symlink
    print_status "Creating symlink: $target -> $source"
    ln -nfs "$source" "$target"
    
    # Verify symlink was created
    if [[ -L "$target" ]]; then
        print_status "Successfully installed $description"
    else
        print_error "Failed to create symlink for $description"
        return 1
    fi
}

# Function to check if we're on macOS
check_platform() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS. Current OS: $OSTYPE"
        exit 1
    fi
    print_status "Platform check passed: macOS detected"
}

# Main installation function
main() {
    print_status "Starting dotfiles installation for macOS..."
    
    # Check platform
    check_platform
    
    # Check if we're in the right directory
    if [[ ! -f "scripts/install-mac.sh" ]]; then
        print_error "Please run this script from the dotfiles root directory"
        exit 1
    fi
    
    # Get the dotfiles root directory
    DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    print_status "Dotfiles root: $DOTFILES_ROOT"
    
    ########################################
    print_status "Installing configs from manifest"
    ########################################
    # One-to-one symlinks are declared in scripts/links.manifest (source |
    # target | description). Pipe-delimited because some targets contain
    # spaces; parsed with bash builtins so linking never depends on yq/brew.
    local manifest="$DOTFILES_ROOT/scripts/links.manifest"
    if [[ ! -f "$manifest" ]]; then
        print_error "Link manifest not found: $manifest"
        return 1
    fi
    while IFS='|' read -r src dest desc; do
        # Skip comments and blank lines
        [[ "$src" =~ ^[[:space:]]*# || -z "${src// /}" ]] && continue
        # Trim surrounding whitespace from each field
        src="${src#"${src%%[![:space:]]*}"}";  src="${src%"${src##*[![:space:]]}"}"
        dest="${dest#"${dest%%[![:space:]]*}"}"; dest="${dest%"${dest##*[![:space:]]}"}"
        desc="${desc#"${desc%%[![:space:]]*}"}"; desc="${desc%"${desc##*[![:space:]]}"}"
        # Expand a leading ~ to $HOME
        create_symlink "$DOTFILES_ROOT/$src" "${dest/#\~/$HOME}" "$desc"
    done < "$manifest"

    ########################################
    print_status "Installing bin scripts"
    ########################################
    # Create ~/bin directory if it doesn't exist
    if [[ ! -d "$HOME/bin" ]]; then
        print_status "Creating directory: $HOME/bin"
        mkdir -p "$HOME/bin"
    fi
    
    # Symlink all scripts from bin/ directory to ~/bin/
    if [[ -d "$DOTFILES_ROOT/bin" ]]; then
        for script in "$DOTFILES_ROOT/bin"/*; do
            if [[ -f "$script" ]]; then
                script_name=$(basename "$script")
                create_symlink "$script" "$HOME/bin/$script_name" "bin/$script_name"
            fi
        done
    else
        print_warning "bin directory not found, skipping script installation"
    fi
    
    ########################################
    print_status "Installation completed successfully!"
    print_status "You may need to restart your terminal or run 'source ~/.zshrc' for changes to take effect."
}

# Run main function with error handling
if main; then
    echo -e "${GREEN}✓ Installation completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Installation failed!${NC}"
    exit 1
fi