-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local api = vim.api
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options
local shlist = vim.fn.systemlist
local sh = vim.fn.system

vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
vim.g.mapleader = " "
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

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
  use 'tpope/vim-eunuch'
  use 'tpope/vim-abolish'
  use 'tpope/vim-fugitive'
  use 'tmux-plugins/vim-tmux-focus-events'
  use 'junegunn/fzf.vim'
  use 'junegunn/fzf'
  use 'airblade/vim-rooter'
  use { "catppuccin/nvim", as = "catppuccin" }
  use 'lewis6991/gitsigns.nvim'
  use 'nanozuki/tabby.nvim'

  use {'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true }}
end)

-- Plugin Settings
g['rooter_targets'] = '/,*'
g['rooter_cd_cmd'] = 'lcd'
g['fzf_layout'] = {down = '~40%'}
g['go_doc_keywordprg_enabled'] = 0
g['updatetime'] = 100
require('nvim-autopairs').setup{}
require('lualine').setup({
 sections = {
  lualine_c = {
    { 
      "buffers",
      buffers_color = {
        active = { bg = '#d8aeff', fg = '#262626' },
        inactive = { bg = '#366585', fg = '#121212' },
      }
    }
  },
 },
})
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', '<leader>gj', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)
    
    map('n', '<leader>gk', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)
    
    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)
    map('n', '<leader>hx', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')}  gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hs', function() gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('v', '<leader>hr', function() gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hu', gitsigns.undo_stage_hunk)
    map('n', '<leader>hp', gitsigns.preview_hunk_inline)
    map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>hd', gitsigns.diffthis)
    map('n', '<leader>td', gitsigns.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
 
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
cmd 'autocmd FocusLost,BufLeave * :wa'
-------------------- MAPPINGS ------------------------------
-- <Tab> to navigate the completion menu
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

map('n', '<leader>o', 'm`o<Esc>``')  -- Insert a newline in normal mode
map('n', 'n', 'nzz')                 -- Better search centering
map('n', 'N', 'Nzz')
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
map("n", "<C-j>", ":bprev<enter>", {noremap=false})
map("n", "<C-k>", ":bnext<enter>", {noremap=false})
map("n", "<C-h>", ":bfirst<enter>", {noremap=false})
map("n", "<C-l>", ":blast<enter>", {noremap=false})
map("n", "<leader><C-d>", ":bdelete<enter>", {noremap=false})


-- Plugins Mappings
map('n', '<C-f>', ':FZF<CR>')
map('n', '<C-g>', ':Rg<CR>')
map('v', '<C-y>', ':OSCYank<CR>')

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode
