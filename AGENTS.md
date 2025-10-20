# CLAUDE.md

Step-by-step guidance for Claude Code when working with this Neovim configuration repository.

## 🏗️ Repository Structure

**This is a modular Neovim configuration using lazy.nvim with AI integrations.**

### File Organization
```
init.lua                    # Entry point - loads core modules
lua/config/                 # Core configuration
├── opts.lua               # Neovim options
├── keys.lua               # Global keymaps  
├── lazy.lua               # Plugin manager setup
├── project.lua            # Project management
└── utils.lua              # Utility functions
lua/plugins/               # Plugin configurations by prefix:
├── 10-*.lua              # Core (theme, snacks)
├── 20-*.lua              # Dev tools (treesitter, which-key)
├── 30-*.lua              # AI integrations (copilot, avante)
├── 40-*.lua              # UI components (statusline, trouble)
├── 55-*.lua              # LSP configuration
├── 65-*.lua              # Debugging setup
├── 70-*.lua              # Completion system
└── 90-*.lua              # Language-specific plugins
after/ftplugin/            # Auto-install LSP servers per filetype
```

## 🎯 Essential Actions

### Before Making Changes
1. **Run formatting check**: `stylua --check .`
2. **Run linting**: `selene .` 
3. **Check for existing patterns**: Search similar configurations first

### When Adding Plugins
1. **Choose correct prefix** based on plugin type (10-90)
2. **Use lazy loading**: Set `event = "VeryLazy"` unless specific trigger needed
3. **Check dependencies**: Ensure required tools are available via Mason
4. **Test configuration**: Verify plugin loads and functions correctly

### When Modifying Code
1. **Follow existing patterns**: Check similar functions for style consistency
2. **Update cache keys**: If modifying cached functions, update cache invalidation
3. **Maintain backward compatibility**: Don't break existing function signatures
4. **Add appropriate comments**: Only when complexity requires explanation

### Quality Assurance
1. **Format code**: `stylua .`
2. **Fix linting issues**: `selene .` 
3. **Test functionality**: Verify changes work in Neovim
4. **Check for regressions**: Ensure existing features still work

## 🔧 Development Workflow

### Code Formatting
```bash
# Check formatting
stylua --check .

# Apply formatting
stylua .
```

### Code Linting  
```bash
# Lint all Lua files
selene .
```

### Configuration Files
- `stylua.toml`: 150 column width, spaces
- `selene.toml`: Neovim standard library

## 🤖 AI Integration Setup

### Required Configuration Files
1. **Copy example file**: `cp avante_opts.yaml.example avante_opts.yaml`
2. **Configure providers**: Add API keys and settings
3. **Set up MCP servers**: Configure `mcpservers.json` if needed
4. **Define projects**: Add entries to `projects.yaml`

### AI Providers Available
- **GitHub Copilot**: Via copilot.lua
- **Claude**: Via Avante plugin  
- **CodeCompanion**: Additional AI assistant
- **MCPHub**: Model Context Protocol servers

## 📋 Language Support

### Automatic LSP Installation
Each `after/ftplugin/*.lua` file calls `require("config.utils").mason_install()` to install required LSP servers on demand.

### Supported Languages
Rust, Lua, Python, Go, Erlang, Elixir, Bash/zsh, Perl, JSON/JSON5, XML, HTML, JavaScript, YAML, TOML, Markdown, CSS, SQL, HTTP/REST, LaTeX, C

### Adding New Language Support
1. **Create ftplugin file**: `after/ftplugin/[language].lua`
2. **Install LSP server**: Call `mason_install("server-name")`  
3. **Configure LSP**: Set up language-specific options
4. **Add plugin if needed**: Create `90-[language].lua` for specialized tools

## 🎨 Theming and UI

### Available Themes
tokyonight-night (default), Edge, Everforest, Gruvbox Material, Material, Oceanic Next, Sonokai, Wombat, Zephyr

### UI Components
- **Completion**: blink.cmp with LSP, snippets, AI suggestions
- **Statusline**: Custom statusline configuration
- **File explorer**: Yazi integration
- **Notifications**: nvim-notify
- **Folding**: nvim-ufo enhanced folding

## ⌨️ Key Bindings Reference

### Discovery
- `<space>Sk`: Show all keybindings (Snacks picker)
- `<space>?`: Show all keybindings (WhichKey)
- `<space>/`: Show buffer-local keybindings

### Essential
- `<space>p`: Project switcher
- `<leader>n`: LSP rename symbol
- `<leader>d`: LSP hover documentation  
- `<leader>a`: LSP code actions
- `<esc>`: Close floats, clear highlights/references

## ✅ Git Commit Standards

### 🚨 CRITICAL GIT RULES

**NEVER RUN `git add` - EVER!**

The user stages files manually. Your role is ONLY to:
1. View staged changes with `git diff --staged`
2. Create commit messages with `git commit -m "message"`
3. NEVER use `git add` in any form (`git add .`, `git add -A`, `git add <file>`)

Violating this rule disrupts the user's workflow.

### Format Templates
**Simple (single focused change):**
```
type: brief description (50 chars max)

High-level explanation of what and why (1-2 sentences).
```

**Complex (multiple loosely related changes):**
```
type: brief description (50 chars max)

High-level explanation of what and why (1-2 sentences).

Changes:
- Specific change 1 with brief context
- Specific change 2 with brief context
```

### Step-by-Step Commit Process
1. **Choose type**: `feat|fix|docs|style|refactor|test|chore`
2. **Write brief description**: High-level what changed
3. **Add explanation**: 1-2 sentences about what/why, not implementation details
4. **Use bullet points only for multiple major unrelated changes**: Add "Changes:" section when commit contains loosely related modifications
5. **Keep focused commits simple**: Single-purpose commits don't need bullet points
6. **Avoid noise words**: No "excellent", "comprehensive", "amazing"

### Examples
✅ **Good (complex)**:
```
feat: replace autochdir with custom submodule-aware implementation

Replace autochdir.nvim plugin with custom implementation

Changes:
- Replace autochdir.nvim plugin with lua/config/autochdir.lua with
custom BufEnter autocommand
- Update project.lua to use ignore_submodules option in add/list
functions
```

✅ **Good (simple)**:
```
fix: prevent infinite loop in project root detection
```

❌ **Bad**:
```
feat: amazing comprehensive enhancement to project detection

- Modified utils.lua
- Added some new functionality  
- Ready for next phase of development
```

## 💬 Code Commenting Guidelines

### DO Comment For

#### 1. Complex Configuration Decisions
```lua
-- Stop at home directory and filesystem root to prevent infinite loops
-- in edge cases like broken symlinks or permission issues
local stop_dirs = { vim.fn.expand("~"), "/" }
```

#### 2. Plugin Compatibility Issues
```lua  
-- Use blink.cmp instead of nvim-cmp for better performance with large LSP responses
-- Treesitter highlighting conflicts with semantic tokens in some themes
```

#### 3. Non-obvious API Behavior  
```lua
-- vim.loop.fs_stat returns nil for broken symlinks, unlike vim.fn.stat
-- Cache key includes ignore_submodules to differentiate search results
```

#### 4. External References
```lua
-- Based on LSP spec: https://microsoft.github.io/language-server-protocol/
-- Follows lazy.nvim patterns: https://github.com/folke/lazy.nvim#-plugin-spec
```

#### 5. Workflow Rationale
```lua
-- Use <leader>n instead of <leader>r for rename to avoid telescope conflicts
-- Set event = "VeryLazy" to defer loading for faster startup times
```

### DON'T Comment For

#### 1. Obvious Configurations
```lua
-- BAD: Setup telescope with default configuration
require("telescope").setup({})
```

#### 2. Simple Keybindings
```lua  
-- BAD: Map leader-f to find files
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
```

#### 3. Standard Options
```lua
-- BAD: Enable line numbers
vim.opt.number = true
```

## 🔍 Debugging Features

### Available Debuggers
- **Rust**: rustaceanvim integration
- **Go**: nvim-dap-go
- **Python**: nvim-dap-python

### Adding New Debugger
1. **Create plugin file**: `65-[language]-debug.lua`
2. **Configure adapter**: Set up nvim-dap adapter
3. **Add keybindings**: Configure debugging shortcuts
4. **Test functionality**: Verify breakpoints and stepping work

## 📁 Project Management

### Projects Configuration
Edit `projects.yaml` to add new projects:
```yaml
- name: "Project Name"
  path: "/path/to/project"
  description: "Project description"
```

### Session Management
- Powered by snacks.nvim
- Automatic session saving/restoration
- Per-project configuration

## 🚀 Performance Optimization

### Plugin Loading Strategy
- **Core plugins**: Load immediately (10-prefix)
- **Most plugins**: `event = "VeryLazy"` for deferred loading
- **Language plugins**: Load on filetype detection
- **LSP servers**: Install on demand per filetype

### Cache Strategy
- Root finding results cached with differentiated keys
- Plugin configurations lazy-loaded
- Mason packages installed only when needed