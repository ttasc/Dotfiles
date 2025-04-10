-- LSP settings.

local mason_ok, mason = pcall(require, "mason")
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not mason_ok) or (not mason_lspconfig_ok) then
  return
end

-- add binaries installed by mason.nvim to path
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. ":" .. vim.env.PATH

--------
-- UI --
--------
mason.setup({
    ui = {
        icons = {
            package_pending = " ",
            package_installed = " ",
            package_uninstalled = " ",
        }
    }
})

local x = vim.diagnostic.severity
vim.diagnostic.config({
    signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
        border = "rounded",
        header = "",
    },
})

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded' -- Thêm border
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

----------
-- CORE --
----------

local mason_list = {
    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --
    --  Add any additional override configuration in the following tables. They will be passed to
    --  the `settings` field of the server config. You must look up that documentation yourself.
    servers = {
        bashls = {},
        clangd = {},
        gopls = {},
        pyright = {},
        lua_ls = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                        [vim.fn.stdpath("config") .. "/lua"] = true,
                        [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
                    },
                    -- maxPreload = 100000,
                    -- preloadFileSize = 10000,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    },

    -- DAP, Linter, Formatter (must be the full name)
    others = {
        "shellcheck",
    }
}

-- Custom cmd to install all mason binaries listed by mason_list.others
vim.api.nvim_create_user_command("MasonInstallDLF", function()
    vim.cmd("MasonInstall " .. table.concat(mason_list.others, " "))
end, { desc = 'Install DAP, Linter, Formatter' })

-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    require("core.mappings").load_mappings("lspconfig", { buffer = bufnr })

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
end

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(mason_list.servers),
    automatic_installation = true,
}

mason_lspconfig.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = mason_list.servers[server_name],
        }
    end,
}
