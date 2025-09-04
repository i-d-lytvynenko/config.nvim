-- LLMs
local config = function()
    local gemini_provider = {
        request_completion = function(handler, params)
            -- Disable reasoning to make the stream faster
            params['generationConfig'] = { thinkingConfig = { thinkingBudget = 0 } }
            local util = require 'model.util'
            local sse = require 'model.util.sse'
            return sse.curl_client({
                url = 'https://generativelanguage.googleapis.com/v1beta/models/'
                    .. 'gemini-2.5-flash'
                    .. ':streamGenerateContent?'
                    .. 'alt=sse&key='
                    .. os.getenv 'GEMINI_API_KEY',
                headers = {
                    ['Content-Type'] = 'application/json',
                },
                body = params,
            }, {
                on_message = function(msg, raw)
                    local item = util.json.decode(msg.data)
                    if item and item.candidates then
                        if item.candidates[1].content then
                            local text_parts = item.candidates[1].content.parts
                            for _, part in ipairs(text_parts) do
                                handler.on_partial(part.text)
                            end
                        else
                            handler.on_error(item)
                        end
                    else
                        local err_response = util.json.decode(raw)

                        if err_response then
                            handler.on_error(err_response)
                        else
                            handler.on_error 'Unrecognized SSE response'
                        end
                    end
                end,
                on_error = handler.on_error,
                on_other = handler.on_error,
                on_exit = handler.on_finish,
            })
        end,
    }
    local gemini_chat = {
        provider = gemini_provider,
        create = function(input, context)
            return context.selection and input or ''
        end,
        run = function(messages, config)
            local formattedParts = {}

            if config.system then
                table.insert(formattedParts, { role = 'user', parts = { { text = config.system } } })
                table.insert(formattedParts, { role = 'model', parts = { { text = 'Understood.' } } })
            end

            for _, msg in ipairs(messages) do
                if msg.role == 'user' then
                    table.insert(formattedParts, { role = 'user', parts = { { text = msg.content } } })
                elseif msg.role == 'assistant' then
                    table.insert(formattedParts, { role = 'model', parts = { { text = msg.content } } })
                end
            end

            return {
                contents = formattedParts,
            }
        end,
    }
    require('model').setup {
        default_prompt = {
            provider = gemini_provider,
            builder = function(input)
                return { contents = { { parts = { { text = input } } } } }
            end,
            mode = require('model').mode.APPEND,
        },
        chats = {
            gemini = gemini_chat,
        },
        default_chat = { 'gemini' },
    }
end

return {
    'gsuuon/model.nvim',
    cmd = { 'M', 'Model', 'Mchat' },
    init = function()
        vim.filetype.add {
            extension = {
                mchat = 'mchat',
            },
        }
    end,
    ft = 'mchat',
    keys = {
        { '<A-m>', ':Mchat<CR>', mode = 'n', desc = '<Model>: Open chat' },
        { '<leader>m', ':enew | Mchat gemini<CR>', mode = 'n', silent = true, desc = '<Model>: Start chat in new window' },
    },
    config = config,
}
