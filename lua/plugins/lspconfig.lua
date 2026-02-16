-- LSP Configuration & Plugins
local config = function()
    local on_init = function(client)
        if client.server_capabilities then
            -- Disable LSP highlighting
            -- WARN: nil breaks pyright
            client.server_capabilities.semanticTokensProvider = nil
        end
    end
    -- This function gets run when an LSP connects to a particular buffer
    local on_attach = function(client, bufnr)
        local nmap = function(keys, func, desc)
            if desc then
                desc = '<LSP>: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

        local telescope_status_ok, telescope = pcall(require, 'telescope.builtin')
        if telescope_status_ok then
            nmap('gr', telescope.lsp_references, '[G]oto [R]eferences')
            nmap('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
            nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
            nmap('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
            nmap('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        end

        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
        -- nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        -- nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        -- nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        -- nmap('<leader>wl', function()
        --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        -- end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        --     vim.lsp.buf.format()
        -- end, { desc = 'Format current buffer with LSP' })
    end

    local servers = {
        ts_ls = {},
        gopls = {
            gofumpt = true,
        },
        clangd = {},
        html = { filetypes = { 'html', 'twig', 'hbs' } },
        cssls = {},
        marksman = {},
        basedpyright = {
            basedpyright = {
                analysis = {
                    ---@diagnostic disable-next-line: param-type-mismatch
                    stubPath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'python-type-stubs', 'stubs'),
                    diagnosticMode = 'openFilesOnly',
                },
            },
        },
        ruff = {},
        intelephense = {},
        lua_ls = {
            Lua = {
                codeLens = { enable = true },
                hint = { enable = true, semicolon = 'Disable' },
                runtime = {
                    version = 'LuaJIT',
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                    },
                },
                telemetry = { enable = false },
            },
        },
        tinymist = {
            exportPdf = 'onType',
            formatterMode = 'typstyle',
            semanticTokens = 'disable',
        },
    }

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local cmp_status_ok, cmp = pcall(require, 'cmp_nvim_lsp')
    if cmp_status_ok then
        capabilities = cmp.default_capabilities(capabilities)
    end

    for server_name, server_settings in pairs(servers) do
        vim.lsp.config(server_name, {
            capabilities = capabilities,
            on_init = on_init,
            on_attach = on_attach,
            settings = server_settings,
            filetypes = (server_settings or {}).filetypes,
        })
    end

    vim.lsp.config('marksman', {
        filetypes = { 'markdown', 'markdown.mdx' },
        root_markers = { '.marksman.toml', '.git' },
        capabilities = capabilities,
        on_init = on_init,
        on_attach = on_attach,
    })

    local function get_python_path(workspace)
        for _, pattern in ipairs { '*', '.*' } do
            local match = vim.fn.glob(table.concat({ workspace, pattern, 'pyvenv.cfg' }, '/'))
            if match ~= '' then
                return table.concat({ vim.fs.dirname(match), 'Scripts', 'python.exe' }, '/')
            end
        end
        return 'python'
    end

    vim.lsp.config('ruff', {
        init_options = {
            settings = {
                -- For more settings check https://github.com/astral-sh/ruff/blob/main/docs/editors/settings.md
                lint = {
                    extendSelect = { 'I' }, -- show unsorted imports
                },
            },
        },
        capabilities = capabilities,
        on_init = function(client)
            client.config.interpreter = get_python_path(client.config.root_dir)
            client.server_capabilities.hoverProvider = false
            on_init(client)
        end,
        on_attach = function(client, bufnr)
            on_attach(client, bufnr)

            -- Ruff import sorting is performed separately from formatting (fix waiting room)
            -- See https://github.com/astral-sh/ruff/issues/8232
            vim.keymap.set({ 'n', 'v' }, '<leader>f', function(_)
                vim.lsp.buf.format()
                client.request(vim.lsp.protocol.Methods.workspace_executeCommand, {
                    command = 'ruff.applyOrganizeImports',
                    arguments = {
                        { uri = vim.uri_from_bufnr(bufnr), version = 0 },
                    },
                })
            end, { noremap = true, buffer = 0 })
        end,
        settings = servers['ruff'],
        filetypes = (servers['ruff'] or {}).filetypes,
    })

    vim.lsp.config('basedpyright', {
        capabilities = capabilities,
        on_init = function(client)
            client.server_capabilities.semanticTokensProvider = false
            on_init(client)
        end,
        on_attach = on_attach,
        settings = servers['basedpyright'],
        filetypes = (servers['basedpyright'] or {}).filetypes,
    })

    local mason_lspconfig = require 'mason-lspconfig'
    local ensure = {}
    for _, name in ipairs(vim.tbl_keys(servers)) do
        if vim.fn.executable(name) ~= 1 then
            table.insert(ensure, name)
        else
            vim.lsp.enable(name)
        end
    end
    mason_lspconfig.setup {
        automatic_enable = true,
        ensure_installed = ensure,
    }

end

return {
    'neovim/nvim-lspconfig',
    event = 'VimEnter',
    config = config,
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'mason-org/mason.nvim', config = true },
        { 'mason-org/mason-lspconfig.nvim' },

        -- Useful status updates for LSP
        { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

        -- Additional lua configuration
        { 'folke/lazydev.nvim', ft = 'lua', enabled = true },

        -- Python stubs for pyright and basedpyright
        { 'microsoft/python-type-stubs', cond = false },
    },
}
