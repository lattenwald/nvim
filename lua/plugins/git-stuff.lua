return {
    {
        -- TODO do I need it?
        'TimUntersberger/neogit',
        config = function()
            require'neogit'.setup{}
        end
    },
    {
        "airblade/vim-gitgutter",
    },
    {
        "itchyny/vim-gitbranch",
    },
    {
        "tpope/vim-fugitive",
    }
}
