My [Neovim](https://neovim.io/) configuration based on [lazy.nvim](https://lazy.folke.io/)

Basic idea is LSP servers are installed on demand, and only those explicitly configured in `after/ftplugin/*.lua` are installed.

Languages-specific Neovim extensions are installed in `90-<lang>.lua`.

# Configuration

`avante_opts.yaml.example` contains example configuration for copilot [avante.nvim](https://github.com/yetone/avante.nvim) provider. [copilot.lua](zbirenbaum/copilot.lua) fetches copilot configuration from this file as well. Both avante and copilot plugins merge parsed configuration into their respective options.

To use it, copy `avante_opts.yaml.example` to `avante_opts.yaml` and edit it.

# Keymap

In Neovim:

  * `<space>sk` — show all key bindings in Snacks picker
  * `<space>?` — show all key bindings in WhichKey window
  * `<space>/` — show buffer-local key bindings in WhichKey window

# Progress

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
    * [x] projects (via snacks)
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
    * [x] codecompaion
    * [ ] codecompanion: load opts from `avante_opts.yaml`
    * [ ] rename `avante_opts.yaml`
    * [ ] mcphub settings
* [ ] debugging
	* [x] rust
	* [x] go
	* [x] python
	* [ ] erlang
	* [ ] elixir?
	* [ ] bash?
	* [ ] lua?
	* [ ] perl?
