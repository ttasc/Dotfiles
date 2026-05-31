-- vim: foldmethod=marker
vim.loader.enable() -- Fast load dark magic
vim.g.mapleader = ","

-- {{{ 1. OPTIONS
vim.opt.title = true
vim.opt.timeoutlen = 500
vim.opt.updatetime = 300

-- Files & Undo
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.confirm = true

-- UI
vim.opt.showmode = true
-- vim.opt.laststatus = 0
-- vim.opt.showtabline = 0
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 3
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.listchars = {
    trail = '',
    tab = '│ ',
}

-- Search & Text
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- System
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
for _, provider in ipairs({ "perl", "ruby" }) do
    vim.g["loaded_" .. provider .. "_provider"] = 0
end
-- }}}

-- {{{ 2. UI COMPONENTS
-- Native UI: Bufferline
function _G.MinimalBufferLine()
    local s = ""
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_get_option_value('buflisted', { buf = b }) then
            local name = vim.fn.fnamemodify(vim.fn.bufname(b), ":t")
            if name == "" then name = "[No Name]" end
            if b == vim.api.nvim_get_current_buf() then
                s = s .. "%#TabLineSel#  " .. name .. "  "
            else
                s = s .. "%#TabLine#  " .. name .. "  "
            end
        end
    end
    return s .. "%#TabLineFill#"
end
vim.opt.tabline = "%!v:lua.MinimalBufferLine()"

-- Native UI: Statusline with LSP Diagnostics
function _G.MinimalStatusLine()
    local status = " %f %m %r"
    local diags = vim.diagnostic.count(0)
    local err = diags[vim.diagnostic.severity.ERROR] or 0
    local warn = diags[vim.diagnostic.severity.WARN] or 0
    local info = diags[vim.diagnostic.severity.INFO] or 0

    if err > 0 then status = status .. " %#DiagnosticError#󰅙 " .. err end
    if warn > 0 then status = status .. " %#DiagnosticWarn# " .. warn end
    if info > 0 then status = status .. " %#DiagnosticInfo#󰋼 " .. info end

    status = status .. "%#StatusLine# %=" .. " %l:%c "
    return status
end
vim.opt.statusline = "%!v:lua.MinimalStatusLine()"
-- }}}

-- {{{ 3. KEYMAPPINGS
local map = vim.keymap.set

-- General
map('n', '<leader>e', '<cmd> e $MYVIMRC <CR>', { desc = '[E]dit init.lua' })
map('n', '<leader>l', '<cmd> set list! <CR>', { desc = '[S]how [L]istchars' })
map('n', '<F4>', '<cmd> setlocal spell! spelllang=en_us<CR>', { desc = '󰓆 Built-in spell-checker' })
map('n', '<leader><F4>', '<cmd> normal! mz1z=`z <CR>', { desc = '󰁨 Auto-fix misspelled word' })
map('n', '<leader><leader>', '<cmd> nohlsearch <CR>', { desc = 'Turn off matched highlighting' })
map('n', '<A-t>', '<cmd> split|term <CR>', { desc = 'Terminal in horiz split' })
map('n', '<leader>bf', '<cmd> split|term compiler %<CR>', { desc = 'Compile file from terminal' })
map('v', '<C-r>', '"hy:%s/<C-r>h//gc<left><left><left>', { desc = '󰛔 Find & replace selected words' })
map('v', '<A-p>', '"_dP', { desc = 'Replace text & do not copy' })
map('v', '<', '<gv-gv', { desc = 'Manually indent (left)' })
map('v', '>', '>gv-gv', { desc = 'Manually indent (right)' })
map('v', '<C-j>', ":move '>+1<CR>gv-gv", { desc = ' Move current line/block down' })
map('v', '<C-k>', ":move '<-2<CR>gv-gv", { desc = ' Move current line/block up' })
map('t', '<esc><esc>', '<c-\\><c-n>', { desc = 'Enter Normal mode from Terminal mode' })
map({'n','i'}, '<C-s>', '<cmd> w <CR>', { desc = 'Save' })

-- Toggle UI (Native Bufferline & Statusline)
map('n', '<leader>tu', function()
    if vim.o.showtabline == 0 then
        vim.o.showtabline = 2 -- Show tabline
        vim.o.laststatus = 3  -- Show statusline
    else
        vim.o.showtabline = 0 -- Hide tabline
        vim.o.laststatus = 0  -- Hide statusline
    end
end, { desc = '[T]oggle[U]I (Buffer/Status)' })

-- Window / Buffer / Move
map({'n','t'}, '<C-h>', '<cmd> wincmd h <CR>', { desc = ' Window  Left' })
map({'n','t'}, '<C-j>', '<cmd> wincmd j <CR>', { desc = ' Window  Down' })
map({'n','t'}, '<C-k>', '<cmd> wincmd k <CR>', { desc = ' Window  Up' })
map({'n','t'}, '<C-l>', '<cmd> wincmd l <CR>', { desc = ' Window  Right' })
map('n', '<C-Up>', '<cmd> resize -2 <CR>', { desc = ' Resize horizontally' })
map('n', '<C-Down>', '<cmd> resize +2 <CR>', { desc = ' Resize horizontally' })
map('n', '<C-Left>', '<cmd> vertical resize -2 <CR>', { desc = ' Resize vertically' })
map('n', '<C-Right>', '<cmd> vertical resize +2 <CR>', { desc = ' Resize vertically' })
map('i', '<C-h>', '<Left>', { desc = ' Move cursor Left' })
map('i', '<C-j>', '<Down>', { desc = ' Move cursor Down' })
map('i', '<C-k>', '<Up>', { desc = ' Move cursor Up' })
map('i', '<C-l>', '<Right>', { desc = ' Move cursor Right' })
map('n', '<A-h>', '<C-w>t<C-w>H', { desc = 'Switch to horizontal split' })
map('n', '<A-k>', '<C-w>t<C-w>K', { desc = 'Switch to vertical split' })
map('n', '<C-q>', '<cmd> bdelete! <CR>', { desc = 'Delete Buffer' })
map('n', '<Tab>', '<cmd> bnext <CR>', { desc = 'Next Buffer' })
map('n', '<S-Tab>', '<cmd> bprev <CR>', { desc = 'Previous Buffer' })

-- Diagnostics (Native)
map('n', '[d', function() vim.diagnostic.jump({count =-1, float = true}) end, { desc = 'Previous diagnostic' })
map('n', ']d', function() vim.diagnostic.jump({count = 1, float = true}) end, { desc = 'Next diagnostic' })
map('n', 'F', vim.diagnostic.open_float, { desc = 'Show diagnostics' })
map('n', 'L', vim.diagnostic.setloclist, { desc = 'List all diagnostics' })

-- Commenting (Native `gc` wrappers)
map("n", "\\\\", "gcc", { remap = true, desc = "Line-comment toggle" })
map("n", "||", "gbc", { remap = true, desc = "Block-comment toggle" })
map("x", "\\", "gc", { remap = true, desc = "Line-comment keymap" })
map("x", "|", "gb", { remap = true, desc = "Block-comment keymap" })
map("n", "\\O", "gcO", { remap = true, desc = "Add comment on the line above" })
map("n", "\\o", "gco", { remap = true, desc = "Add comment on the line below" })
map("n", "\\A", "gcA", { remap = true, desc = "Add comment at the end of line" })
-- }}}

-- {{{ 4. AUTOCMDS
local augroup = function(name) return vim.api.nvim_create_augroup(name, { clear = true }) end

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("native_treesitter"),
    callback = function(args) pcall(vim.treesitter.start, args.buf) end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup("not_cmt_newline"),
    pattern = "*",
    callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("rm_whitespace_onsave"),
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function() vim.cmd("tabdo wincmd =") end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup("term_no_numline"),
    command = "setlocal nonumber norelativenumber",
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = { "oil", "git", "undotree", "help", "lspinfo", "man", "qf", "checkhealth" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})
-- }}}

-- {{{ 5. LOAD PLUGINS
-- If `lua/plugins.lua` exists, load it. Otherwise (e.g. on a server), ignore safely.
local has_plugins, _ = pcall(require, "plugins")

if not has_plugins then
    -- Fallback theme for servers without plugins
    vim.cmd.colorscheme("habamax")
end
-- }}}
