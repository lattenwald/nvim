# Neovim Configuration

A comprehensive [Neovim](https://neovim.io/) configuration built with [lazy.nvim](https://lazy.folke.io/) that provides a modern development environment with on-demand LSP servers, AI integrations, and language-specific tooling.

## Features

- **On-demand LSP servers** - Automatically install and configure LSP servers only when needed
- **AI-powered development** - Multiple AI providers (GitHub Copilot, Claude, OpenAI)
- **Modern completion** - blink.cmp with LSP, snippets, and AI suggestions
- **Comprehensive language support** - Rust, Go, Python, Lua, JavaScript, and more
- **Debugging support** - DAP integration for multiple languages
- **Git integration** - Gitsigns, Diffview, and LazyGit
- **Project management** - Session management and project switching
- **Extensible architecture** - Modular plugin organization

## Installation

1. **Prerequisites**
   ```bash
   # Install Neovim (>= 0.10)
   # Install Git
   # Install a Nerd Font for icons
   ```

2. **Clone the configuration**
   ```bash
   git clone <your-repo-url> ~/.config/nvim
   ```

3. **First launch**
   ```bash
   nvim
   ```
   Lazy.nvim will automatically install all plugins on first launch.

4. **AI Configuration (Optional)**
   ```bash
   cp ~/.config/nvim/avante_opts.yaml.example ~/.config/nvim/avante_opts.yaml
   # Edit avante_opts.yaml with your AI provider settings
   ```

## Architecture

### Plugin Organization
Plugins are organized by numbered prefixes for loading order:
- **10-** Core plugins (theme, snacks)
- **20-** Development tools (treesitter, which-key)
- **30-** AI integrations (copilot, avante, codecompanion)
- **40-** UI components (statusline, trouble)
- **55-** LSP configuration
- **65-** Debugging setup
- **70-** Completion system
- **90-** Language-specific plugins

### Directory Structure
```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lua/config/              # Core configuration
│   ├── opts.lua            # Neovim options
│   ├── keys.lua            # Global keymaps
│   ├── lazy.lua            # Plugin manager setup
│   └── utils.lua           # Utility functions
├── lua/plugins/             # Plugin configurations
├── after/ftplugin/          # Language-specific configs
├── avante_opts.yaml        # AI provider configuration
└── projects.yaml           # Project definitions
```

## Key Bindings

### Discovery
- `<space>Sk` - Show all key bindings in Snacks picker
- `<space>?` - Show all key bindings in WhichKey
- `<space>/` - Show buffer-local key bindings

### Essential Bindings
- `<space>p` - Projects picker
- `<leader>n` - LSP rename symbol
- `<leader>d` - LSP hover documentation
- `<leader>a` - LSP code actions
- `<esc>` - Close floats, clear highlights
- `<space>gg` - LazyGit
- `<space>e` - File explorer (Yazi)
- `<space>ff` - Find files
- `<space>fg` - Live grep
- `<space>fb` - Find buffers

## AI Integration

The configuration includes multiple AI providers for enhanced development:

### Supported Providers
- **GitHub Copilot** - Code completion and chat
- **Claude** - Advanced AI assistance via Avante
- **OpenAI** - GPT models integration
- **CodeCompanion** - Additional AI coding features

### Configuration
AI settings are managed in `avante_opts.yaml`:
```yaml
providers:
  copilot:
    endpoint: "https://api.github.com"
    model: "gpt-4"
  claude:
    endpoint: "https://api.anthropic.com"
    model: "claude-3-sonnet-20240229"
```

## Language Support

### Fully Supported Languages
- **Rust** - LSP, DAP, enhanced with rustaceanvim
- **Go** - LSP, DAP, testing, and tools
- **Python** - LSP, DAP, formatting, linting
- **Lua** - LSP for Neovim development
- **JavaScript/TypeScript** - LSP, formatting
- **Markdown** - Enhanced editing and preview
- **JSON/YAML** - Schema validation
- **HTML/CSS** - Web development tools
- **Erlang/Elixir** - Functional programming support
- **Bash/Shell** - Script development

### LSP Server Installation
LSP servers are installed automatically when you open a supported file type. Configuration is handled in `after/ftplugin/<language>.lua` files.

## Development Tools

### Code Formatting
```bash
stylua .          # Format Lua files
stylua --check .  # Check formatting
```

### Linting
```bash
selene .          # Lint Lua files
```

### Debugging
Supported debuggers:
- **Rust** - Built-in via rustaceanvim
- **Go** - Delve integration
- **Python** - debugpy integration

## Customization

### Adding New Languages
1. Create `after/ftplugin/<language>.lua`
2. Add LSP server configuration
3. Create `lua/plugins/90-<language>.lua` if needed

### Plugin Configuration
All plugins are configured in `lua/plugins/` with descriptive filenames. Each plugin configuration includes:
- Dependencies
- Setup options
- Key bindings
- Lazy loading configuration

### Theme Customization
The configuration uses Tokyo Night theme by default. Change in `lua/plugins/10-theme.lua`.

## Troubleshooting

### Common Issues
1. **LSP not working** - Check `:Mason` for server installation
2. **AI features not working** - Verify `avante_opts.yaml` configuration
3. **Plugin errors** - Run `:Lazy sync` to update plugins
4. **Key bindings not working** - Check for conflicts with `:WhichKey`

### Health Checks
```vim
:checkhealth
:Lazy health
:Mason
```

## Contributing

Feel free to submit issues and pull requests. When contributing:
1. Follow the existing code style
2. Test changes thoroughly
3. Update documentation as needed
4. Use conventional commit messages

## License

This configuration is provided as-is under the MIT License.

## Implementation Status

### ✅ Core Features
- [x] **Plugin Management** - Lazy.nvim with optimized loading
- [x] **LSP Integration** - Mason + lspconfig for 15+ languages
- [x] **Completion System** - blink.cmp with LSP, snippets, AI
- [x] **AI Integration** - Copilot, Avante, CodeCompanion, MCPHub
- [x] **Git Integration** - Gitsigns, Diffview, LazyGit
- [x] **File Management** - Yazi integration, project switching
- [x] **UI Enhancement** - Which-key, Trouble, statusline
- [x] **Code Editing** - Surround, Autopairs, commenting
- [x] **Terminal Integration** - Built-in terminal management
- [x] **REST Client** - HTTP request testing

### ✅ Language Support
- [x] **Rust** - Full LSP + DAP + rustaceanvim
- [x] **Go** - Full LSP + DAP + testing tools
- [x] **Python** - Full LSP + DAP + formatting
- [x] **Lua** - Full LSP for Neovim development
- [x] **JavaScript/TypeScript** - Full LSP support
- [x] **Markdown** - Enhanced editing + rendering
- [x] **Web** - HTML, CSS, JSON, YAML, XML
- [x] **Functional** - Erlang, Elixir support
- [x] **Shell** - Bash, Zsh scripting
- [x] **Config** - TOML, JSON5 support

### ✅ Development Tools
- [x] **Debugging** - Rust, Go, Python DAP integration
- [x] **Testing** - Language-specific test runners
- [x] **Formatting** - Auto-formatting on save
- [x] **Linting** - Integrated diagnostics
- [x] **Code Navigation** - Go to definition, references, implementations
- [x] **Symbol Search** - LSP-powered symbol navigation
- [x] **Preview** - Hover documentation and signatures

### 🔄 Future Enhancements
- [ ] **Extended Debugging** - Erlang, Elixir, Bash, Lua, Perl
- [ ] **AI Optimization** - Unified configuration loading
- [ ] **Configuration Naming** - Rename `avante_opts.yaml` to `ai_config.yaml`
- [ ] **Performance** - Further lazy loading optimizations
- [ ] **Documentation** - Video tutorials and examples
