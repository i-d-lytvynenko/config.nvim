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
        basedpyright = {
            basedpyright = {
                analysis = {
                    ---@diagnostic disable-next-line: param-type-mismatch
                    stubPath = vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy', 'python-type-stubs', 'stubs'),
                    diagnosticMode = 'openFilesOnly',
                },
            },
        },
        -- pyright = {
        --     pyright = {
        --         disableOrganizeImports = true,
        --     },
        --     python = {
        --         analysis = {
        --             ignore = { '*' },
        --             diagnosticMode = 'openFilesOnly',
        --             useLibraryCodeForTypes = true,
        --             -- useLibraryCodeForTypes = false,
        --             stubPath = vim.fn.stdpath 'data' .. '/lazy/python-type-stubs/stubs',
        --         },
        --     },
        -- },
        ruff = {},
        -- pylsp = {
        --     pylsp = {
        --         plugins = {
        --             -- 25.02.25 this just sucks
        --             pylsp_mypy = { enabled = false },

        --             -- ruff is better
        --             flake8 = { enabled = false },
        --             pycodestyle = { enabled = false },
        --             autopep8 = { enabled = false },
        --             yapf = { enabled = false },
        --             mccabe = { enabled = false },
        --             pyflakes = { enabled = false },
        --             black = { enabled = false },
        --             pylsp_isort = { enabled = false },
        --         },
        --     },
        -- },
        intelephense = {},
        lua_ls = {
            Lua = {
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

    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
    }
    mason_lspconfig.setup_handlers {
        function(server_name)
            require('lspconfig')[server_name].setup {
                capabilities = capabilities,
                on_init = on_init,
                on_attach = on_attach,
                settings = servers[server_name],
                filetypes = (servers[server_name] or {}).filetypes,
            }
        end,
    }

    local util = require 'lspconfig/util'
    local path = util.path
    local function get_python_path(workspace)
        for _, pattern in ipairs { '*', '.*' } do
            local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
            if match ~= '' then
                return path.join(path.dirname(match), 'Scripts', 'python.exe')
            end
        end
        return 'python'
    end

    -- Ruff config
    require('lspconfig')['ruff'].setup {
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
    }

    require('lspconfig')['basedpyright'].setup {
        capabilities = capabilities,
        on_init = function(client)
            client.server_capabilities.semanticTokensProvider = false
            on_init(client)
        end,
        on_attach = on_attach,
        settings = servers['basedpyright'],
        filetypes = (servers['basedpyright'] or {}).filetypes,
    }

    -- Pylsp config
    -- Also run `:PylspInstall pylsp_mypy`
    -- require('lspconfig')['pylsp'].setup {
    --     capabilities = capabilities,
    --     on_init = function(client)
    --         local python_venv = get_python_path(client.config.root_dir)
    --         local settings = vim.tbl_deep_extend('force', (client.settings or client.config.settings), {
    --             pylsp = {
    --                 plugins = {
    --                     jedi = {
    --                         environment = python_venv,
    --                     },
    --                     -- pylsp_mypy = {
    --                     --     overrides = { '--python-executable', python_venv, true },
    --                     --     report_progress = true,
    --                     --     live_mode = false,
    --                     --     dmypy = true,
    --                     --     exclude = { '\\.venv/*' },
    --                     -- },
    --                 },
    --             },
    --         })
    --         client.notify('workspace/didChangeConfiguration', { settings = settings })
    --     end,
    --     on_attach = on_attach,
    --     settings = servers['pylsp'],
    --     filetypes = (servers['pylsp'] or {}).filetypes,
    -- }
end

return {
    'neovim/nvim-lspconfig',
    event = 'VimEnter',
    config = config,
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        { 'williamboman/mason-lspconfig.nvim', version = 'v1.32.0' }, -- TODO: refactor config to use new versions

        -- Useful status updates for LSP
        { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

        -- Additional lua configuration
        { 'folke/lazydev.nvim', ft = 'lua', enabled = true },

        -- Python stubs for pyright and basedpyright
        { 'microsoft/python-type-stubs', cond = false },
    },
}
