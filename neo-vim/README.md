# Neovim Configuration

This directory contains a modular Neovim configuration converted from the original `mac.vimrc` file.

## Structure

```
neo-vim/
├── lua/
│   └── config/
│       ├── init.lua          # Main entry point - loads all modules
│       ├── variables.lua     # Configuration variables
│       ├── settings.lua      # Basic settings and options
│       ├── keymaps.lua       # All key mappings
│       ├── autocmds.lua      # Auto commands
│       ├── commands.lua      # Custom commands
│       └── mac-specific.lua  # Mac-specific configurations
├── mac.vimrc                 # Original vimrc file
└── mac.lua                   # Single-file conversion (legacy)
```

## Installation

1. Copy the `lua` directory to your Neovim config:

   ```bash
   cp -r neo-vim/lua ~/.config/nvim/
   ```

2. Create a main `init.lua` file in `~/.config/nvim/`:
   ```lua
   -- Load the modular configuration
   require('config')
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

## Usage

The configuration is automatically loaded when Neovim starts. All the original functionality from `mac.vimrc` is preserved, but now organized in a more maintainable structure.

## Migration from Single File

If you were using the single `mac.lua` file, you can now use the modular version by:

1. Removing the old `mac.lua` file
2. Installing the modular structure as described above
3. The functionality will be identical, but better organized
