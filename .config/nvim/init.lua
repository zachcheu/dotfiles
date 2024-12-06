-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local api = vim.api
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options
local shlist = vim.fn.systemlist
local sh = vim.fn.system

vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
vim.env.PATH = vim.env.VIM_PATH or vim.env.PATH

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

g['mapleader'] = " "
map('n', '<leader>', '<Nop>')

function nvim_create_augroups(definitions)
for group_name, definition in pairs(definitions) do
api.nvim_command('augroup '..group_name)
api.nvim_command('autocmd!')
for _, def in ipairs(definition) do
local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
api.nvim_command(command)
end
api.nvim_command('augroup END')
end
end

function fzf_repo()
  local dir
  dir = sh("git rev-parse --show-toplevel")
  vim.cmd(string.format("Files %s", dir))
end

map('n', '<leader><C-f>', ':lua fzf_repo()<CR>')

vim.cmd [[packadd packer.nvim]]
-------------------- PLUGINS -------------------------------
require('packer').startup({function(use)
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig'}
  use "windwp/nvim-autopairs" 
  use 'tpope/vim-abolish'
  use 'tpope/vim-fugitive'
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'nanozuki/tabby.nvim'
  use {'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true }}
  use {'ibhagwan/fzf-lua', requires = { "nvim:-tree/nvim-web-devicons" }}
  use {
    "nvim-zh/colorful-winsep.nvim",
    config = function ()
      require('colorful-winsep').setup()
    end
  }
  use {'echasnovski/mini.diff'}
  use {'echasnovski/mini.surround'}
  use {'nvim-focus/focus.nvim'}
  use {'nvim-treesitter/nvim-treesitter',run = ':TSUpdate'}
  use {"nvim-treesitter/nvim-treesitter-textobjects"}
  use {'ms-jpq/coq_nvim'}
  use {'ms-jpq/coq.artifacts'}
  use {'ms-jpq/chadtree'}
  use {'ray-x/lsp_signature.nvim'}
  use {'nvim-lua/lsp-status.nvim'}
  use {"vigoux/notifier.nvim",
    config = function()
      require('notifier').setup()
    end
  }
end,
config = {
  display = {
    open_fn = require('packer.util').float,
  }
}})

-- Plugin Settings
g['go_doc_keywordprg_enabled'] = 0
g['updatetime'] = 300
g['coq_settings'] = {auto_= true}
g['chadtree_settings'] = {
  keymap = {
    quit = {"`"},
    change_dir = {"b"},
    change_focus = {"<right>"},
    change_focus_up = {"<left>"},
    primary = {"<cr>", "l"},
    v_split = {"v"},
    h_split = {"V"},
    collapse = {"h"},
  },
}
require("lsp_signature").setup({
  hint_enable = false,
  fix_pos = true,
})
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "go"},
  sync_install = false,
  auto_install = true,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<leader>ss",
      node_incremental = "<leader>sk",
      scope_incremental = "<leader>sc",
      node_decremental = "<leader>sj",
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["as"] = "@local.scope"
      },
      selection_modes = {
        ['@parameter.outer'] = 'v',
        ['@function.outer'] = 'v',
        ['@class.outer'] = 'V',
      },
      include_surrounding_whitespace = true,
    },
  },
})
require("focus").setup()
local ignore_buftypes = { 'nofile', 'prompt', 'popup' }
local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })
vim.api.nvim_create_autocmd({'WinEnter', 'WinLeave'}, {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
        then
            vim.w.focus_disable = true
        else
            vim.w.focus_disable = false
        end
    end,
    desc = 'Disable focus autoresize for BufType',
})

require('nvim-autopairs').setup{}
require('lualine').setup({
  sections = {
    lualine_c = {'filename'},
  },
})
require('mini.diff').setup({
  mappings = {
    -- Apply hunks inside a visual/operator region
    apply = '<leader>ha',
    -- Reset hunks inside a visual/operator region
    reset = '<leader>hr',
    -- Hunk range textobject to be used inside operator
    -- Works also in Visual mode if mapping differs from apply and reset
    textobject = '<leader>hh',
    -- Go to hunk range in corresponding direction
    goto_prev = '<leader>hp',
    goto_next = '<leader>hn',
  }
})
require("fzf-lua").setup()
 
-------------------- OPTIONS -------------------------------
cmd 'colorscheme catppuccin-latte'
cmd 'syntax enable'
opt.cursorline = true               -- Highlight line of cursor
opt.expandtab = true                -- Use spaces instead of tabs
opt.hidden = true                   -- Enable background buffers
opt.ignorecase = true               -- Ignore case
opt.joinspaces = false              -- No double spaces with join
opt.number = true                   -- Show line numbers
opt.relativenumber = true           -- Relative line numbers
opt.scrolloff = 4                   -- Lines of context
opt.shiftround = true               -- Round indent
opt.shiftwidth = 2                  -- Size of an indent
cmd 'au! BufRead,BufNewFile *.star set sw=4 ts=4'
opt.sidescrolloff = 8               -- Columns of context
opt.smartcase = true                -- Do not ignore case with capitals
opt.smartindent = true              -- Insert indents automatically
opt.expandtab = true                -- Tabs to spaces
opt.splitbelow = true               -- Put new windows below current
opt.splitright = true               -- Put new windows right of current
opt.tabstop = 2                     -- Number of spaces tabs count for
opt.termguicolors = true            -- True color support
opt.wildmode = {'list', 'longest'}  -- Command-line completion mode
opt.wrap = false                    -- Disable line wrap
opt.virtualedit = 'insert'
opt.mouse = ""
opt.mousescroll = "ver:0,hor:0"

cmd 'autocmd FocusLost,BufLeave * :wa'
-------------------- MAPPINGS ------------------------------
map('n', '<leader>o', 'm`o<Esc>``')  -- Insert a newline in normal mode
map('n', 'n', 'nzz')                 -- Better search centering
map('n', 'N', 'Nzz')
map('n', '<C-j>', 'A<del><Esc>')
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'K', ':m .-2<CR>==')
map('n', 'J', ':m .+1<CR>==')
map('v', 'K', ":m '<-2<CR>==gv=gv")
map('v', 'J', ":m '>+1<CR>==gv=gv")
map('n', '<leader>d', '"_d')
map('i', '<S-Tab>', '<C-d>')
map('n', 'Y', 'y$')
map('n', '<leader>/', ':%S/')
map('n', '<leader>j', ':s/\\s*$//<cr>J')
map('n', '<leader><leader>', ':nohl<CR>')

-- Copy/Paste
map('v', '<leader>y', '"+y')
map('n', '<leader>y', '"+y')
map('n', '<leader>Y', '"+yg_')
map('n', '<leader>p', '"+p')
map('n', '<leader>P', '"+P')
map('v', '<leader>p', '"+p')
map('v', '<leader>P', '"+P')

-- Buffer/Window/Tab Management
map("n", "<leader>wk", ":bprev<CR>", {noremap=false})
map("n", "<leader>wj", ":bnext<CR>", {noremap=false})
map("n", "<leader>wh", ":tabprev<CR>", {noremap=false})
map("n", "<leader>wl", ":tabnext<CR>", {noremap=false})
map("n", "<leader>wt", ":tabclose<CR>", {noremap=false})
map("n", "<leader>wb", ":bdelete<CR>", {noremap=false})
map("n", "<leader>w<left>", "<C-w>h", {noremap=false})
map("n", "<leader>w<down>", "<C-w>j", {noremap=false})
map("n", "<leader>w<up>", "<C-w>k", {noremap=false})
map("n", "<leader>w<right>", "<C-w>l", {noremap=false})
map("n", "<leader>wV", "<C-w>s", {noremap=false})
map("n", "<leader>wv", "<C-w>v", {noremap=false})
map("n", "<leader>ww", "<C-w>c", {noremap=false})
map("n", "<leader>wo", "<C-w><C-o>", {noremap=false})

-- Config Management
map("n", "<leader>co", ":e ~/.config/nvim/init.lua<CR>")

-- FzfLua
map('n', '<leader>fb', ':FzfLua buffers<CR>')
map('n', '<leader>fh', ':FzfLua oldfiles<CR>')
map('n', '<leader>fo', ':lua require("fzf-lua").files({cwd=get_root(), git_icons=false, resume=true})<CR>')
map('n', '<leader>fO', ':lua require("fzf-lua").files({cwd=get_root(), git_icons=false, resume=false})<CR>')
map('n', '<leader>f/', ':FzfLua live_grep resume=true<CR>')
map('n', '<leader>f?', ':FzfLua live_grep resume=false<CR>')
map('n', '<leader>/', ':FzfLua lgrep_curbuf resume=true<CR>')
map('n', '<leader>?', ':FzfLua lgrep_curbuf resume=false<CR>')
map('n', '<leader>ff', ':FzfLua quickfix<CR>')
--chadtree
map('n', '<leader>fe', function() 
  if vim.bo.buftype == "nofile" then 
    return ":CHADopen<CR>"
  else
    return ":CHADopen --always-focus<CR>"
  end
  return
end, {expr = true, silent = true})
--fugitive
map('n', '<leader>hs', ':Git difftool -y<CR>')
map('n', '<leader>hh', ':tabfirst | :.tabonly<CR>')

function table_contains(table, element)
  for i,val in ipairs(table) do
    if val == element then
      return true
    end
  end
  return false
end

function get_root()
  local root_names = {'infra','base','config'}
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  local root_dir = ""
  for dir in vim.fs.parents(path) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
    if table_contains(root_names, vim.fn.fnamemodify(dir, ':t')) then
      root_dir = dir
      break
    end
  end
  return root_dir
end

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode

-------------------- LSP ---------------------------
local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
 
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
 
  -- You can delete this if you enable format-on-save.
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
end
 
require('lspconfig').gopls.setup({
        cmd = {'gopls', '-remote=auto'},
        on_attach = on_attach,
        flags = {
            -- Don't spam LSP with changes. Wait a second between each.
            debounce_text_changes = 1000,
        },
})

vim.g.coq_settings = {
    keymap = {
        recommended = false,
    },
}
vim.keymap.set('i', '<Esc>', [[pumvisible() ? "\<C-e><Esc>" : "\<Esc>"]], { expr = true, silent = true })
vim.keymap.set('i', '<C-c>', [[pumvisible() ? "\<C-e><C-c>" : "\<C-c>"]], { expr = true, silent = true })
vim.keymap.set('i', '<BS>', [[pumvisible() ? "\<C-e><BS>" : "\<BS>"]], { expr = true, silent = true })
vim.keymap.set(
  "i",
  "<CR>",
  [[pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"]],
  { expr = true, silent = true }
)
 vim.keymap.set('i',
  '<Tab>',
  [[pumvisible() ? (complete_info().selected == -1 ? "\<C-n><C-y>" : "") : "\<Tab>"]],
  { expr = true, silent = true }
)

vim.api.nvim_create_autocmd({"BufWritePre", "FocusLost"}, {
    buffer = buffer,
    callback = function()
        vim.lsp.buf.format { async = false }
    end
})
