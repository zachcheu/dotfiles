-------------------- HELPERS -------------------------------
 local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local api = vim.api
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options
local shlist = vim.fn.systemlist
local sh = vim.fn.system

vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
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
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer' 
  use "windwp/nvim-autopairs" 
  use 'tpope/vim-abolish'
  use 'tpope/vim-fugitive'
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'nanozuki/tabby.nvim'
  use {'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true }}
  use {'ibhagwan/fzf-lua', requires = { "nvim:-tree/nvim-web-devicons" }}
  use { 'echasnovski/mini.files' }
  use {
    "nvim-zh/colorful-winsep.nvim",
    config = function ()
        require('colorful-winsep').setup()
    end
  }
  use {'echasnovski/mini.diff'}
  use {'nvim-focus/focus.nvim'}
end)

-- Plugin Settings
g['fzf_layout'] = {down = '~40%'}
g['go_doc_keywordprg_enabled'] = 0
g['updatetime'] = 300
require("focus").setup()
require('nvim-autopairs').setup{}
require('lualine').setup({
  sections = {
    lualine_c = {'filename'},
  },
})
require('mini.files').setup({
  mappings = {close = "<esc>"}
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
-- <Tab> to navigate the completion menu
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

map('n', '<leader>o', 'm`o<Esc>``')  -- Insert a newline in normal mode
map('n', 'n', 'nzz')                 -- Better search centering
map('n', 'N', 'Nzz')
map('n', '<C-j>', 'A<del>')
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
map("n", "<leader>ws", "<C-w>s", {noremap=false})
map("n", "<leader>wv", "<C-w>v", {noremap=false})
map("n", "<leader>ww", "<C-w>c", {noremap=false})
map("n", "<leader>wo", "<C-w><C-o>", {noremap=false})

-- Config Management
map("n", "<leader>co", ":e ~/.config/nvim/init.lua<CR>")
map("n", "<leader>cr", ":w | :so ~/.config/nvim/init.lua<CR>")

-- FzfLua
map('n', '<leader>fb', ':FzfLua buffers<CR>')
map('n', '<leader>fh', ':FzfLua oldfiles<CR>')
map('n', '<leader>fo', ':lua require("fzf-lua").files({cwd=get_root(), git_icons=false})<CR>')
map('n', '<leader>/', ':FzfLua lgrep_curbuf resume=true<CR>')
map('n', '<leader>ff', ':FzfLua quickfix<CR>')
--mini.files
map('n', '<leader>fe', ':lua MiniFiles.open()<CR>')
--fugitive
map('n', '<leader>hs', ':Git difftool -y<CR>')
map('n', '<leader>hc', ':tabfirst | :.tabonly<CR>')

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
