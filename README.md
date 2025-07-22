# Neovim Configuration

A comprehensive [Neovim](https://neovim.io/) configuration built with [lazy.nvim](https://lazy.folke.io/) that provides a modern development environment with on-demand LSP servers, AI integrations, and language-specific tooling.

## Features

- **On-demand LSP servers** - Automatically install and configure LSP servers only when needed
- **AI integrations** - Claude Code, Copilot completion, and Gemini terminal integration
- **Modern completion** - blink.cmp with LSP, snippets, and AI suggestions
- **Integrated file management** - Yazi terminal file manager with floating window support
- **Language support** - Rust, Go, Python, Lua, JavaScript, and more
- **Debugging support** - DAP integration for multiple languages
- **Git integration** - vim-fugitive, Gitsigns, Diffview, and LazyGit
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
   # Configure mcpservers.json for MCP integrations if needed
   ```

## Architecture

### Plugin Organization
Plugins are organized by numbered prefixes for loading order and functionality:
- **10-** Core plugins (theme, snacks)
- **20-** Development tools (treesitter, which-key, yazi)
- **25-** Git integration (fugitive, gitsigns, diffview)
- **30-** AI integrations (claudecode, copilot, codecompanion, mcphub)
- **40-** UI components (statusline, trouble)
- **55-** LSP configuration
- **65-** Debugging setup
- **70-** Completion system
- **90-** Language-specific plugins

*Note: We follow a modular philosophy where plugins are grouped by functionality (e.g., all Git-related tools in `25-git.lua`) to improve maintainability and clarity.*

### Directory Structure
```
~/.config/nvim/
├── init.lua                # Main entry point
├── lua/config/             # Core configuration
│   ├── opts.lua            # Neovim options
│   ├── keys.lua            # Global keymaps
│   ├── lazy.lua            # Plugin manager setup
│   └── utils.lua           # Utility functions
├── lua/plugins/            # Plugin configurations
├── after/ftplugin/         # Language-specific configs
├── avante_opts.yaml        # AI provider configuration
├── mcpservers.json         # MCP server configurations
└── projects.yaml           # Project definitions
```

## Key Bindings

**Note:** The leader key is mapped to `<space>`. All `<leader>` bindings below use the spacebar.

### Discovery
- `<leader>Sk` - Show all key bindings in Snacks picker
- `<leader>?` - Show all key bindings in WhichKey
- `<leader>/` - Show buffer-local key bindings

### File Management
- `<leader>e` - File explorer (Snacks)
- `<leader>z` - Open Yazi at current file
- `<leader>-` - Resume last Yazi session
- `<leader><space>` - Smart find files
- `<leader>F` - Find files
- `<leader>f` - Find files (Git/Regular)
- `<leader>r` - Grep
- `<leader>b` - Buffers

### AI Integration
**Primary AI Interface (Claude Code):**
- `<leader>wc` - Toggle Claude (recommended)
- `<leader>wf` - Focus Claude window
- `<leader>wr` - Resume Claude session
- `<leader>wC` - Continue Claude conversation
- `<leader>wb` - Add current buffer to Claude
- `<leader>ws` - Send selection to Claude (visual mode)
- `<leader>wa` - Accept Claude diff
- `<leader>wd` - Deny Claude diff

**Global AI Shortcuts:**
- `<C-,>` - Quick toggle Claude
- `<C-.>` - Gemini terminal for quick queries

### Git Integration
**vim-fugitive** (command-driven workflow):
- `:Git` or `:G` - Main Git interface (press `g?` for help in Git buffers)
- `:G blame`, `:G diff`, `:G log` - Specific Git operations

**Other Git Tools:**
- `<leader>gg` - LazyGit
- `hs` - Stage Git hunk (gitsigns)
- `<leader>hp` - Preview Git hunk
- `<leader>hr` - Reset Git hunk

### Essential Bindings
- `<leader>p` - Projects picker
- `<leader>n` - LSP rename symbol
- `<leader>d` - LSP hover documentation
- `<leader>a` - LSP code actions
- `<esc>` - Close floats, clear highlights

## AI Integration

The configuration provides a multi-tiered AI development environment with specialized tools for different workflows:

### AI Tool Roles
- **`coder/claudecode.nvim`** (Primary) - Main AI chat interface for context-aware questions, code explanations, and suggestions as diffs. Access via `<leader>w` keybindings.
- **GitHub Copilot** (Completion) - Inline ghost-text completions and suggestions.
- **Gemini Pro** (Quick Access) - Terminal-based tool for quick queries. Activated with `<C-.>`.
- **CodeCompanion** (Extended) - Additional AI coding features and chat interface.
- **MCPHub** (Integration) - Model Context Protocol server integrations.

### Configuration
AI settings are managed in `avante_opts.yaml` and `mcpservers.json`:

**Main AI Configuration (`avante_opts.yaml`)**:
```yaml
providers:
  copilot:
    endpoint: "https://api.github.com"
    model: "gpt-4"
  claude:
    endpoint: "https://api.anthropic.com"
    model: "claude-3-sonnet-20240229"
```

**MCP Servers (`mcpservers.json`)**: Configuration for Model Context Protocol integrations

### Workflow Recommendations
1. Use **Claude Code** (`<leader>wc`) for code discussions, refactoring, and explanations
2. Use **Copilot** for in-line code completions while typing
3. Use **Gemini** (`<C-.>`) for quick queries without context switching
4. Check **Claude Code status** with `:ClaudeCodeStatus` if needed

## Language Support

### Supported Languages
- **Rust** - LSP, DAP, rustaceanvim integration
- **Go** - LSP, DAP, testing, and tools
- **Python** - LSP, DAP, formatting, linting
- **Lua** - LSP for Neovim development
- **JavaScript/TypeScript** - LSP, formatting
- **Markdown** - Editing and preview
- **JSON/YAML** - Schema validation
- **HTML/CSS** - Web development tools
- **Erlang/Elixir** - Language support
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
- [x] **AI Integration** - Claude Code (primary), Copilot (completion), Gemini Pro (terminal), CodeCompanion, MCPHub
- [x] **Git Integration** - vim-fugitive, Gitsigns, Diffview, LazyGit
- [x] **File Management** - Yazi terminal file manager with floating windows, session resume, project switching
- [x] **UI Enhancement** - Which-key, Trouble, statusline
- [x] **Code Editing** - Surround, Autopairs, commenting
- [x] **Terminal Integration** - Built-in terminal management with Gemini Pro integration
- [x] **REST Client** - HTTP request testing

### ✅ Language Support
- [x] **Rust** - Full LSP + DAP + rustaceanvim
- [x] **Go** - Full LSP + DAP + testing tools
- [x] **Python** - Full LSP + DAP + formatting
- [x] **Lua** - Full LSP for Neovim development
- [x] **JavaScript/TypeScript** - Full LSP support
- [x] **Markdown** - Editing and rendering
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
- [ ] **Performance** - Additional lazy loading optimizations
- [ ] **Documentation** - Tutorials and examples
