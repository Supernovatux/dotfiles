-- Nixvim's internal module table
-- Can be used to share code throughout init.lua
local _M = {}

-- Set up globals {{{
do
    local nixvim_globals = { mapleader = " " }

    for k, v in pairs(nixvim_globals) do
        vim.g[k] = v
    end
end
-- }}}

-- Set up options {{{
do
    local nixvim_options = {
        autoindent = true,
        clipboard = "unnamedplus",
        number = true,
        relativenumber = true,
        shiftwidth = 2,
        termguicolors = true,
        undofile = true,
    }

    for k, v in pairs(nixvim_options) do
        vim.opt[k] = v
    end
end
-- }}}

local cmp = require("cmp")
cmp.setup({
    experimental = { ghost_text = true },
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<Down>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.close(),
        ["<Tab>"] = function(fallback)
            local line = vim.api.nvim_get_current_line()
            if line:match("^%s*$") then
                fallback()
            elseif cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
            else
                fallback()
            end
        end,
        ["<Up>"] = cmp.mapping.select_prev_item(),
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer", option = { get_bufnrs = vim.api.nvim_list_bufs } },
        { name = "nvim_lua" },
        { name = "path" },
    },
})

require("which-key").setup({})

require("treesitter-context").setup({})

vim.opt.runtimepath:prepend(vim.fs.joinpath(vim.fn.stdpath("data"), "site"))
require("nvim-treesitter.configs").setup({
    indent = { enable = true },
    parser_install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
})

require("telescope").setup({})

local __telescopeExtensions = {}
for i, extension in ipairs(__telescopeExtensions) do
    require("telescope").load_extension(extension)
end

require("nvim-autopairs").setup({})

require("bufferline").setup({})

-- LSP {{{
do
    local __lspServers = {
        { name = "texlab" },
        { name = "rust_analyzer" },
        { name = "nixd" },
        { name = "cmake" },
        { name = "clangd" },
        { name = "bashls" },
    }
    -- Adding lspOnAttach function to nixvim module lua table so other plugins can hook into it.
    _M.lspOnAttach = function(client, bufnr)
        -- LSP Inlay Hints {{{
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
        -- }}}

        require("lsp-format").on_attach(client)
    end
    local __lspCapabilities = function()
        capabilities = vim.lsp.protocol.make_client_capabilities()

        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        return capabilities
    end

    local __setup = {
        on_attach = _M.lspOnAttach,
        capabilities = __lspCapabilities(),
    }

    for i, server in ipairs(__lspServers) do
        if type(server) == "string" then
            require("lspconfig")[server].setup(__setup)
        else
            local options = server.extraOptions

            if options == nil then
                options = __setup
            else
                options = vim.tbl_extend("keep", options, __setup)
            end

            require("lspconfig")[server.name].setup(options)
        end
    end
end
-- }}}

require("neo-tree").setup({
    close_if_last_window = true,
    document_symbols = { custom_kinds = {} },
    window = { auto_expand_width = true, width = 30 },
})

require("luasnip").config.setup({})

require("lsp-format").setup({})

-- Set up keybinds {{{
do
    local __nixvim_binds = {
        {
            action = ":Neotree action=focus reveal toggle<CR>",
            key = "<leader>n",
            mode = "n",
            options = { silent = true },
        },
    }
    for i, map in ipairs(__nixvim_binds) do
        vim.keymap.set(map.mode, map.key, map.action, map.options)
    end
end
-- }}}

-- Set up autogroups {{
do
    local __nixvim_autogroups = { nixvim_binds_LspAttach = { clear = true } }

    for group_name, options in pairs(__nixvim_autogroups) do
        vim.api.nvim_create_augroup(group_name, options)
    end
end
-- }}
-- Set up autocommands {{
do
    local __nixvim_autocommands = {
        {
            callback = function()
                do
                    local __nixvim_binds = {
                        {
                            action = vim.diagnostic.goto_next,
                            key = "<leader>j",
                            mode = "n",
                            options = { silent = false },
                        },
                        {
                            action = vim.diagnostic.goto_prev,
                            key = "<leader>k",
                            mode = "n",
                            options = { silent = false },
                        },
                        { action = vim.lsp.buf.hover, key = "K", mode = "n", options = { silent = false } },
                        { action = vim.lsp.buf.references, key = "gD", mode = "n", options = { silent = false } },
                        { action = vim.lsp.buf.definition, key = "gd", mode = "n", options = { silent = false } },
                        { action = vim.lsp.buf.implementation, key = "gi", mode = "n", options = { silent = false } },
                        { action = vim.lsp.buf.type_definition, key = "gt", mode = "n", options = { silent = false } },
                    }
                    for i, map in ipairs(__nixvim_binds) do
                        vim.keymap.set(map.mode, map.key, map.action, map.options)
                    end
                end
            end,
            desc = "Load keymaps for LspAttach",
            event = "LspAttach",
            group = "nixvim_binds_LspAttach",
        },
    }

    for _, autocmd in ipairs(__nixvim_autocommands) do
        vim.api.nvim_create_autocmd(autocmd.event, {
            group = autocmd.group,
            pattern = autocmd.pattern,
            buffer = autocmd.buffer,
            desc = autocmd.desc,
            callback = autocmd.callback,
            command = autocmd.command,
            once = autocmd.once,
            nested = autocmd.nested,
        })
    end
end
-- }}
