local function augroup(name)
    return vim.api.nvim_create_augroup(name, { clear = true })
end

vim.api.nvim_create_autocmd("User", {
    group = augroup("Startuptime"),
    pattern = "LazyVimStarted",
    callback = function()
        vim.cmd("echo '' | redraw")
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        vim.notify("⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms", vim.log.levels.INFO, { render = "minimal" })
    end,
}) -- Show startup time

vim.api.nvim_create_autocmd({ "FileType" }, {
    group = augroup("not_cmt_newline"),
    command = "set fo-=c fo-=r fo-=o",
}) -- Don't auto commenting new lines

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = augroup("rm_whitespace_onsave"),
    pattern = "*",
    command = [[%s/\s\+$//e]],
}) -- Remove trailing white space on save

vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = augroup("resize_splits"),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
}) -- Resize splits if window got resized

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    group = augroup("term_no_numline"),
    command = "setlocal nonumber norelativenumber",
}) -- Don't show line number in terminal

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "oil", -- File Manager (Oil)
        "help",
        "lspinfo",
        "man",
        "qf",
        "startuptime",
        "checkhealth",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
}) -- Close some filetypes with <q>

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
}) -- Wrap and check for spell in text filetypes
