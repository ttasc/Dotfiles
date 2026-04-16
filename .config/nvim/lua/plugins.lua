-- vim: foldmethod=marker

-- {{{ 1. PLUGIN DOWNLOADS
vim.pack.add({
    -- UI & Theming
    "https://github.com/folke/tokyonight.nvim",

    -- LSP & Completion
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1.x") },
    "https://github.com/rafamadriz/friendly-snippets",
    "https://github.com/windwp/nvim-autopairs",

    -- Core functionality
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/echasnovski/mini.diff",
    "https://github.com/nvim-mini/mini.surround",
    "https://codeberg.org/andyg/leap.nvim",

    -- AI & Misc
    "https://github.com/iamcco/markdown-preview.nvim",
}, { confirm = false })

-- Apply Colorscheme immediately
vim.cmd.colorscheme("tokyonight-moon")

-- Load Neovim Built-in Undotree Plugin
vim.cmd.packadd("nvim.undotree")
-- }}}

-- {{{ 2. PLUGIN CONFIGURATIONS & KEYMAPS (Lazy Loaded via schedule)
vim.schedule(function()
    local map = vim.keymap.set

    -- ==========================================
    -- PLUGIN SETUPS
    -- ==========================================
    require("nvim-treesitter").setup({})
    local ensure_installed = { "c", "bash", "python", "go", "javascript" }
    local parsers_to_install = {}
    for _, lang in ipairs(ensure_installed) do
        if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 then
            table.insert(parsers_to_install, lang)
        end
    end
    if #parsers_to_install > 0 then require("nvim-treesitter").install(parsers_to_install) end

    require("fzf-lua").setup({})
    require("oil").setup({ view_options = { show_hidden = true } })
    require("mini.diff").setup({})
    require("mini.surround").setup({
        mappings = { add = "gs", delete = "ds", replace = "cs", find = "", find_left = "", highlight = "" },
    })
    require("nvim-autopairs").setup()

    require("blink.cmp").setup({
        keymap = {
            preset = "none",
            ['<Tab>'] = { 'select_next', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<C-c>'] = { 'hide', 'fallback' },
            ['<CR>'] = { 'accept', 'fallback' },
            ['<C-n>'] = { 'snippet_forward', 'fallback' },['<C-p>'] = { 'snippet_backward', 'fallback' },
        },
        cmdline = { keymap = { ['<CR>'] = { 'accept_and_enter', 'fallback' } } },
        sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
        completion = {
            menu = { border = "rounded" },
            documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
        },
        signature = { enabled = true, window = { border = "rounded" } },
    })

    -- ==========================================
    -- LSP & MASON
    -- ==========================================
    require("mason").setup({ ui = { icons = { package_pending = " ", package_installed = " ", package_uninstalled = " " } } })

    local mason_registry = require("mason-registry")
    local tools_to_install = { "bash-language-server", "clangd", "gopls", "pyright", "lua-language-server", "shellcheck" }
    mason_registry.refresh(function()
        for _, pkg_name in ipairs(tools_to_install) do
            local pkg = mason_registry.get_package(pkg_name)
            if not pkg:is_installed() then
                vim.notify("Installing " .. pkg_name .. "...", vim.log.levels.INFO)
                pkg:install()
            end
        end
    end)

    local x = vim.diagnostic.severity
    vim.diagnostic.config({
        signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "",[x.INFO] = "󰋼",[x.HINT] = "󰌵" } },
        update_in_insert = true, underline = true, severity_sort = true,
        float = { border = "rounded", header = "" },
    })

    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    ---@diagnostic disable: duplicate-set-field
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}; opts.border = opts.border or 'rounded'
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end

    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false, library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true,[vim.fn.stdpath("config") .. "/lua"] = true } },
                telemetry = { enable = false },
            },
        }
    })

    vim.lsp.enable({ "bashls", "clangd", "gopls", "pyright", "lua_ls" })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
            local bufmap = function(keys, func, desc) vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc }) end
            bufmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            bufmap('<leader>k', vim.lsp.buf.signature_help, 'Signature Documentation')
            bufmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            bufmap('gD', vim.lsp.buf.declaration, '[G]oto[D]eclaration')
            bufmap('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
            bufmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
            bufmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            bufmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode[A]ction')
            bufmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
            bufmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
            bufmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
            bufmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace[L]ist Folders')

            vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function(_) vim.lsp.buf.format() end, { desc = 'Format buffer with LSP' })
            vim.keymap.set('n', '<C-f>', '<cmd> Format <CR>', { buffer = ev.buf, desc = 'Format Code' })
        end,
    })

    -- ==========================================
    -- PLUGIN KEYMAPS
    -- ==========================================
    -- FzfLua
    map('n', '<leader>/', '<cmd> FzfLua blines <CR>', { desc = '[/] Find in current buffer' })
    map('n', '<leader>?', '<cmd> FzfLua oldfiles <CR>', { desc = '[?] Find recently files' })
    map('n', '<leader><space>', '<cmd> FzfLua buffers <CR>', { desc = '[ ] Find buffers' })
    map('n', '<leader>ff', '<cmd> FzfLua files <CR>', { desc = '[F]ind [F]iles' })
    map('n', '<leader>fh', '<cmd> FzfLua helptags <CR>', { desc = '[F]ind [H]elp' })
    map('n', '<leader>fw', '<cmd> FzfLua grep_cword <CR>', { desc = '[F]ind current [W]ord' })
    map('n', '<leader>fg', '<cmd> FzfLua grep <CR>', { desc = '[F]ind by[G]rep' })
    map('n', '<leader>fd', '<cmd> FzfLua diagnostics_document <CR>', { desc = '[F]ind [D]iagnostics' })
    map('n', '<leader>fk', '<cmd> FzfLua keymaps previewer=false<CR>', { desc = '[F]ind [K]eymaps' })
    map('n', '<leader>gf', '<cmd> FzfLua git_files <CR>', { desc = '[G]it[F]iles' })
    map('n', '<leader>:', '<cmd> FzfLua commands <CR>', { desc = '[:] Lists all commands' })

    -- Git Diff, File Browsers
    map('n', '<leader>go', '<cmd> lua require("mini.diff").toggle_overlay()<CR>', { desc = '[G]it [O]verlay diff' })
    map('n', '-', '<cmd> Oil --float <CR>', { desc = '[O]il file explorer' })
    map('n', '<leader>mp', '<cmd> MarkdownPreviewToggle <CR>', { desc = '[M]arkdown[P]review' })
    map('n', '<leader>u', function() vim.cmd('Undotree') vim.bo.filetype = "undotree" end, { desc = 'Toggle Undotree' })

    -- Leap
    map({"n","x","o"},  '<space>', "<Plug>(leap)")
    map({'n','v','o'}, 'g<space>', '<Plug>(leap-from-window)', { desc = '󰷺 Leap: from window' })
end)
-- }}}
