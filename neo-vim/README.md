# Neovim Configuration

This directory contains a modular Neovim configuration converted from the original `mac.vimrc` file.

## Structure

```
neo-vim/
├── lua/
│   ├── variables.lua         # Configuration variables
│   ├── settings.lua          # Basic settings and options
│   ├── keymaps.lua           # All key mappings
│   ├── autocmds.lua          # Auto commands
│   ├── commands.lua          # Custom commands
│   └── mac-specific.lua      # Mac-specific configurations
├── mac.vimrc                 # Original vimrc file left for references purposes
├── init.lua                  # Main entry point - loads all modules
```

## Modules

### `variables.lua`

- Configuration variables and paths
- Personal vimrc paths

### `settings.lua`

- Basic Neovim settings
- Directory creation
- Search, wrap, indentation settings
- Backup and GUI options

### `keymaps.lua`

- All keyboard mappings
- Window navigation
- Tab management
- Syntax highlighting toggles
- Notes and markdown shortcuts

### `autocmds.lua`

- File type associations
- Auto commands for specific file types

### `commands.lua`

- Custom user commands
- Buffer management commands
- Database connection commands

### `mac-specific.lua`

- Mac-specific configurations
- FZF integration

## Benefits of Modular Structure

1. **Maintainability**: Each module has a specific purpose
2. **Readability**: Easier to find and modify specific functionality
3. **Reusability**: Modules can be loaded independently
4. **Testing**: Individual modules can be tested separately
5. **Organization**: Clear separation of concerns
