-- Register Kamailio parser if the source file exists
local parser_path = vim.fn.expand("~/git/tree-sitter-kamailio/src/parser.c")
if vim.fn.filereadable(parser_path) == 1 then
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.kamailio = {
        install_info = {
            url = "~/git/tree-sitter-kamailio",
            files = { "src/parser.c" },
        },
        filetype = "kamailio",
    }
end
