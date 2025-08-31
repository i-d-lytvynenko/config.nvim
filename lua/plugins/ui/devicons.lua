-- Icons support
-- Remove overrides when you decide to update nerd font version
-- https://github.com/nvim-tree/nvim-web-devicons/blob/master/lua/nvim-web-devicons/icons-default.lua
-- https://www.nerdfonts.com/cheat-sheet
return {
    'nvim-tree/nvim-web-devicons',
    event = 'VimEnter',
    opts = {
        override = {
            -- txt = {
            --     icon = "",
            --     color = "#89e051",
            --     cterm_color = "113",
            --     name = "Txt",
            -- },
            -- doc = {
            --     icon = "",
            --     color = "#185abd",
            --     cterm_color = "26",
            --     name = "Doc",
            -- },
            -- docx = {
            --     icon = "",
            --     color = "#185abd",
            --     cterm_color = "26",
            --     name = "Docx",
            -- },
            -- csv = {
            --     icon = "",
            --     color = "#89e051",
            --     cterm_color = "113",
            --     name = "Csv",
            -- },
            -- xls = {
            --     icon = "",
            --     color = "#89e051",
            --     cterm_color = "113",
            --     name = "Xls",
            -- },
            -- xlsx = {
            --     icon = "",
            --     color = "#89e051",
            --     cterm_color = "113",
            --     name = "Xlsx",
            -- },
            -- svg = {
            --     icon = "",
            --     color = "#ffb13b",
            --     cterm_color = "214",
            --     name = "Svg",
            -- },
            toml = {
                icon = '',
                -- color = '#526064',
                cterm_color = '59',
                name = 'Toml',
            },
            typ = {
                icon = '',
                -- color = '#0dbcc0',
                cterm_color = '37',
                name = 'Typst',
            },
            ipynb = {
                icon = '',
                -- color = '#f57d01',
                cterm_color = '208',
                name = 'Notebook',
            },
            -- mp4 = {
            --     icon = '',
            --     color = '#e44d26',
            --     cterm_color = '196',
            --     name = 'MP4',
            -- },
        },
    },
}
