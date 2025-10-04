-- Debugger support
return {
    {
        'mfussenegger/nvim-dap',
        tag = '0.10.0',
        config = function()
            local dap = require 'dap'
            local dapui = require 'dapui'
            local dap_python = require 'dap-python'

            require('mason-nvim-dap').setup {
                -- Makes a best effort to setup the various debuggers with
                -- reasonable debug configurations
                automatic_installation = true,

                -- You can provide additional configuration to the handlers,
                -- see mason-nvim-dap README for more information
                handlers = {},

                ensure_installed = {
                    'python',
                },
            }

            -- Still doesn't fix useless notifications
            -- See https://github.com/mfussenegger/nvim-dap/issues/1547
            dap.set_log_level 'ERROR'

            dapui.setup {}
            require('nvim-dap-virtual-text').setup {
                commented = true, -- Show virtual text alongside comment
            }

            local python = vim.fn.expand(vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/Scripts/pythonw')
            dap_python.setup(python)

            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = 'file',

                    -- `program` is what you'd use in `python <program>` in a shell
                    -- If you need to run the equivalent of `python -m <module>`, replace
                    -- `program = '${file}` entry with `module = "modulename"
                    program = '${file}',

                    console = 'integratedTerminal',

                    -- Other options:
                    -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
                    include_configs = true,
                    justMyCode = false,
                    pythonPath = nil,
                },
            }

            vim.fn.sign_define('DapBreakpoint', {
                text = '',
                texthl = 'DiagnosticSignError',
                linehl = '',
                numhl = '',
            })

            vim.fn.sign_define('DapBreakpointRejected', {
                text = '',
                texthl = 'DiagnosticSignError',
                linehl = '',
                numhl = '',
            })

            vim.fn.sign_define('DapStopped', {
                text = '',
                texthl = 'DiagnosticSignWarn',
                linehl = 'Visual',
                numhl = 'DiagnosticSignWarn',
            })

            -- Automatically open/close DAP UI
            dap.listeners.after.event_initialized['dapui_config'] = dapui.open
            dap.listeners.before.event_terminated['dapui_config'] = dapui.close
            dap.listeners.before.event_exited['dapui_config'] = dapui.close

            local nmap = function(keys, func, desc)
                if desc then
                    desc = '<DAP>: ' .. desc
                end

                vim.keymap.set('n', keys, func, { noremap = true, silent = true, desc = desc })
            end

            nmap('<leader>db', dap.toggle_breakpoint, 'Toggle breakpoint')
            nmap('<leader>dc', dap.continue, '[C]ontinue / Start')
            nmap('<leader>do', dap.step_over, 'Step [O]ver')
            nmap('<leader>di', dap.step_into, 'Step [I]nto')
            nmap('<leader>dO', dap.step_out, 'Step [O]ut')
            nmap('<leader>dq', dap.terminate, '[Q]uit debugging')
            nmap('<leader>du', dapui.toggle, 'UI toggle')
        end,
        dependencies = {
            'nvim-neotest/nvim-nio',
            'rcarriga/nvim-dap-ui',
            -- Later versions fail to build due to `debugpy-adapter` and hererocks
            { 'mfussenegger/nvim-dap-python', commit = '34282820bb713b9a5fdb120ae8dd85c2b3f49b51' },
            'theHamsta/nvim-dap-virtual-text',
            'mason-org/mason.nvim',
            'jay-babu/mason-nvim-dap.nvim',
        },
    },
}
