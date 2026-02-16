-- Open .ipynb in Neovim
return {
    'goerz/jupytext.nvim',
    opts = {
        jupytext = 'jupytext',
        format = 'py:percent',  -- See `jupytext --help`
        update = true,
        sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
        autosync = true,
        handle_url_schemes = true,
    },
}
