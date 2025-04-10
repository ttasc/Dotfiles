-- vim:foldmethod=marker
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Install your plugins here
return require("lazy").setup({
    defaults = { lazy = true },
    install = { colorscheme = { "habamax" } },

    -- {{{ Libraries
    { "https://github.com/nvim-lua/plenary.nvim" }, -- lua functions
    -- }}}

    -- {{{ UI
    { "https://github.com/folke/tokyonight.nvim", lazy = false, priority=1000, opts = {} },
    { "https://github.com/akinsho/bufferline.nvim", event = "VeryLazy", opts = {} },
    { "https://github.com/nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                globalstatus = true,
                component_separators = '',
                section_separators = '',
            },
            sections = {
                lualine_x = {
                    {
                        'vim.api.nvim_call_function("codeium#GetStatusString", {})',
                        icon = '󰘦',
                        color = { fg = '#09b6a2', gui = 'bold' },
                    },
                    'encoding', 'fileformat', 'filetype'},
            },
        },
    },
    { "https://github.com/lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        opts = {
            indent = { char = "▏", tab_char = "→", },
            scope = { enabled = false, },
        },
    },
    { "https://github.com/j-hui/fidget.nvim",
        event = "VeryLazy",
        opts = {},
    },
    -- { "https://github.com/folke/which-key.nvim",
    --     event = "VeryLazy",
    --     opts = {},
    --     config = function()
    --         require("which-key").register({
    --             ["<leader>m"] = { name = "+markdown" },
    --             ["<leader>g"] = { name = "+git" },
    --             ["<leader>f"] = { name = "+find/file" },
    --             ["<leader>t"] = { name = "+sw split type" },
    --             ["<leader>w"] = { name = "+workspace" },
    --             ["<leader>c"] = { name = "+code" },
    --             ["<leader>b"] = { name = "+build" },
    --             ["<leader>x"] = { name = "+diagnostics/quickfix" },
    --         })
    --     end,
    -- },
    -- }}}

    -- {{{ Syntax highlighting
    { "https://github.com/nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
        opts = {
            ensure_installed = {
                "c",
                "go",
                "bash",
                "json",
                "lua",
                "python",
                "vimdoc",
            },
            highlight = { enable = true, },
            indent = { enable = true, },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end
    },
    -- }}}

    -- {{{ Completion
    { "https://github.com/hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "https://github.com/hrsh7th/cmp-buffer",
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            "https://github.com/hrsh7th/cmp-nvim-lua",
            "https://github.com/hrsh7th/cmp-path",

            "https://github.com/windwp/nvim-autopairs",

            "https://github.com/saadparwaiz1/cmp_luasnip",
            "https://github.com/L3MON4D3/LuaSnip",
            "https://github.com/rafamadriz/friendly-snippets",
        },
        config = function()
            require("plugins.configs.cmp")
        end,
    },
    -- }}}

    -- {{{ IntelliSense
    { "https://github.com/neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate", "LspInfo", "LspLog" },
        dependencies = {
            "https://github.com/williamboman/mason.nvim",
            "https://github.com/williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("plugins.configs.lsp")
        end
    },
    -- }}}

    -- {{{ Search
    { "https://github.com/ibhagwan/fzf-lua", event = "VeryLazy", opts = {} },
    -- }}}

    -- {{{ File Manager
    { "https://github.com/stevearc/oil.nvim",
        cmd = "Oil",
        opts = { view_options = { show_hidden = true } },
    },
    -- }}}

    -- {{{ Git
    { "https://github.com/tpope/vim-fugitive", cmd = "Git" },
    { "https://github.com/echasnovski/mini.diff", event = "VeryLazy", opts = {} },
    -- }}}

    -- {{{ Editing & motion
    { "https://github.com/numToStr/Comment.nvim",
        event = "VeryLazy",
        opts = {
            padding = true,     -- Add a space b/w comment and the line
            toggler = {         -- LHS of toggle mappings in NORMAL mode
                line = '\\\\',  -- Line-comment toggle keymap
                block = '||',   -- Block-comment toggle keymap
            },
            opleader = {        -- LHS of operator-pending mappings in NORMAL and VISUAL mode
                line = '\\',    -- Line-comment keymap
                block = '|',    -- Block-comment keymap
            },
            extra = {           -- LHS of extra mappings
                above = '\\O',  -- Add comment on the line above
                below = '\\o',  -- Add comment on the line below
                eol = '\\A',    -- Add comment at the end of line
            },
        },
    },
    { "https://github.com/kylechui/nvim-surround", event = "VeryLazy", version = "*", opts = {} },
    { "https://github.com/ggandor/leap.nvim", event = "VeryLazy" },
    -- }}}

    -- {{{ AI
    { "https://github.com/Exafunction/codeium.vim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- vim.g.codeium_manual = true
            vim.g.codeium_disable_bindings = 1
        end
    },
    -- }}}

    -- {{{ Miscellaneous
    { "https://github.com/norcalli/nvim-colorizer.lua", cmd = "ColorizerToggle" },

    { "https://github.com/iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },

})
