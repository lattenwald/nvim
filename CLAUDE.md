# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a comprehensive Neovim configuration based on lazy.nvim with language-specific plugins and LSP servers installed on demand. The configuration follows a modular approach with filetype-specific configurations and extensive AI integrations including GitHub Copilot, Claude via Avante, CodeCompanion, and MCPHub.

## Key Architecture

### Plugin Organization
- **10-** prefix: Core plugins (theme, snacks)
- **20-** prefix: Development tools (treesitter, which-key, etc.)
- **30-** prefix: AI integrations (copilot, avante, codecompanion, mcphub)
- **40-** prefix: UI components (statusline, trouble)
- **55-** prefix: LSP configuration
- **65-** prefix: Debugging setup
- **70-** prefix: Completion system
- **90-** prefix: Language-specific plugins

### Configuration Structure
- `init.lua`: Main entry point, sets up filetype detection and loads core modules
- `lua/config/`: Core configuration modules
  - `opts.lua`: Basic Neovim options
  - `keys.lua`: Global keymaps
  - `lazy.lua`: Lazy.nvim bootstrap and setup
  - `project.lua`: Project management
  - `utils.lua`: Utility functions
- `lua/plugins/`: Plugin configurations organized by prefix
- `after/ftplugin/`: Language-specific configurations that auto-install LSP servers

### LSP Server Installation
LSP servers are installed on demand only when explicitly configured in `after/ftplugin/*.lua` files. Each filetype plugin calls `require("config.utils").mason_install()` to ensure the necessary tools are available.

## Development Commands

### Code Formatting
```bash
# Format Lua files
stylua .

# Check Lua formatting
stylua --check .
```

### Code Linting
```bash
# Lint Lua files with Selene
selene .
```

### Configuration Files
- `stylua.toml`: StyLua formatter configuration (spaces, 150 column width)
- `selene.toml`: Selene linter configuration for Neovim

## AI Integration

The configuration includes multiple AI providers:
- **Copilot**: GitHub Copilot integration via copilot.lua
- **Avante**: AI assistant with provider configuration
- **CodeCompanion**: Additional AI coding assistant
- **MCPHub**: MCP server integrations

AI configuration is managed through `avante_opts.yaml` (copy from `avante_opts.yaml.example`), which provides shared configuration for multiple AI providers including Copilot workspace folders, Claude API settings, and other AI integrations.

## Key Features

### Completion System
Uses blink.cmp as the primary completion engine with:
- LSP-based completions
- Snippet support via LuaSnip
- Cmdline completion
- AI-powered suggestions

### Debugging Support
Configured debugging for:
- Rust (via rustaceanvim)
- Go (via nvim-dap-go)
- Python (via nvim-dap-python)

### Language Support
Full LSP support for: Rust, Lua, Python, Go, Erlang, Elixir, Bash/zsh, Perl, JSON/JSON5, XML, HTML, JavaScript, YAML, TOML, Markdown, CSS, SQL, HTTP/REST, LaTeX, C.

### Additional Features
- **Project Management**: Session management via snacks.nvim with `projects.yaml` configuration
- **File Management**: Yazi integration for advanced file browsing
- **Terminal Integration**: Built-in terminal management and LazyGit integration
- **REST Client**: HTTP request testing via rest.nvim
- **Image Support**: Image clipboard integration for markdown
- **Folding**: Enhanced folding with nvim-ufo
- **Notifications**: Modern notification system with nvim-notify
- **Auto-save**: Automatic directory changing and file management

## Important Keybindings

- `<space>Sk`: Show all key bindings in Snacks picker
- `<space>?`: Show all key bindings in WhichKey
- `<space>/`: Show buffer-local key bindings
- `<space>p`: Projects picker
- `<leader>n`: LSP rename symbol
- `<leader>d`: LSP hover
- `<leader>a`: LSP code actions
- `<esc>`: Close floats, clear highlights, clear LSP references

## File Structure Notes

- Plugin lazy-loading is handled through lazy.nvim with `event = "VeryLazy"` as default
- Color scheme is set to `tokyonight-night` in init.lua (configurable themes include Edge, Everforest, Gruvbox Material, Material, Oceanic Next, Sonokai, Wombat, Zephyr)
- Mason is used for LSP server, DAP adapter, and tool management with automatic installation
- File type detection includes custom patterns for Ansible YAML and Erlang config files
- Configuration includes development tools like StyLua (formatting), Selene (linting)
- Plugin lazy-loading optimized with `event = "VeryLazy"` and specific triggers
- AI providers are configured via `avante_opts.yaml` for consistency across plugins
- MCP (Model Context Protocol) servers configured in `mcpservers.json`
- Project definitions stored in `projects.yaml` for quick project switching
