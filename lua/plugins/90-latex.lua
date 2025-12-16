return {
    {
        "lervag/vimtex",
        cond = require("config.utils").has_gui() and vim.fn.executable("latexmk") == 1,
    },
}
