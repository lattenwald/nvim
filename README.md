My [Neovim](https://neovim.io/) configuration based on [lazy.nvim](https://lazy.folke.io/)

Basic idea is LSP servers are installed on demand, and only those explicitly configured in `after/ftplugin/*.lua` are installed.

Notable exception is Rust, which has `lua/plugnis/90-rust.lua` configuration in addition to ftplugin one.

## Progress

* [x] tools
	* [x] which-key
	* [x] yazi
	* [x] lazygit
	* [x] terminal
	* [x] trouble
	* [x] Surround
	* [x] Autopairs
	* [x] comment hotkeys `<leader>c<space>`
    * [x] REST.nvim
 [x] projects (via snacks)
* lsp servers
	* [x] Rust
	* [x] Lua
	* [x] Python
	* [x] Go
	* [x] Erlang
	* [x] Elixir
	* [x] Bash/zsh
	* [x] Perl
	* [x] Json/json5
	* [x] Xml
	* [x] Html
	* [x] Js
	* [x] Yaml
	* [x] Toml
	* [x] Markdown
* [x] Lsp
	* [x] Go to def
	* [x] Go to ref
	* [x] Go to impl
	* [x] Hover doc
	* [x] Hover actions
	* [x] preview def/ref/impl
* [x] autocompletion with blink.cmp
	* [x] common stuff
    - [x] cmdline completion fix
* [x] ai assistant
	* [x] copilot
	* [x] avante
