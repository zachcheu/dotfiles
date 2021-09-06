-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local api = vim.api
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options
local shlist = vim.fn.systemlist
local sh = vim.fn.system

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

function copy_source_graph_link()
  local remote, commit, filename, url
  remote = vim.trim(sh("git remote get-url origin"))
  remote = remote:gsub("gitolite@", "")
  remote = remote:gsub(":", "/")
  remote = remote:gsub("ssh://", "")
  commit = vim.trim(sh("git merge-base @ origin/main"))
  filename = vim.trim(sh(string.format("git ls-files --full-name %s", fn.expand('%'))))
  line = fn.line(".")
  col = fn.col(".")
  url = string.format("https://sourcegraph.uberinternal.com/%s@%s/-blob/%s#L%s:%s", remote, commit, filename, line, col)
  sh("nc -q 5000 localhost 2224", url)
end

function copy_phab_link()
  local filename, line
  filename = vim.trim(sh(string.format("git ls-files --full-name %s", fn.expand('%'))))
  filename = sh("uniq", filename)
  line = fn.line(".")
  url = string.format("https://code.uberinternal.com/diffusion/GOCODVJ/browse/main/%s$%s", filename, line)
  sh("nc -q 5000 localhost 2224", url)
end

map('n', '<leader><C-o>', ':lua copy_source_graph_link()<CR>')
map('n', '<leader><C-p>', ':lua copy_phab_link()<CR>')

-------------------- PLUGINS -------------------------------
require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'neovim/nvim-lspconfig'
  use {'hrsh7th/nvim-compe', 'onsails/lspkind-nvim'}
  use 'hrsh7th/vim-vsnip'
  use 'rafamadriz/friendly-snippets'
  use 'windwp/nvim-autopairs'
  use 'tpope/vim-eunuch'

  use {
    "blackCauldron7/surround.nvim",
    config = function()
      require "surround".setup {}
    end
  }
  use {'akinsho/bufferline.nvim', 
    requires = 'kyazdani42/nvim-web-devicons',
    options = {show_buffer_icons = false}
  }
  use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}, config = function() require('gitsigns').setup() end}
  use {'tmux-plugins/vim-tmux-focus-events'}

  use 'tpope/vim-surround'
  use {'junegunn/fzf.vim'}
  use {'junegunn/fzf'}
  use {'airblade/vim-rooter'}
  use {'ojroques/nvim-lspfuzzy'}
  use {'haishanh/night-owl.vim'}
end)

-- Plugin Settings
g['deoplete#enable_at_startup'] = 1  -- enable deoplete at startup
g['rooter_patterns'] = {'>infra', '=src', '>foundations', '>teams'}
g['rooter_targets'] = '/,*'
g['rooter_cd_cmd'] = 'lcd'
g['fzf_layout'] = {down = '~40%'}
require('bufferline').setup{}
require('nvim-autopairs').setup{}

-------------------- OPTIONS -------------------------------
cmd 'syntax enable'
cmd 'colorscheme night-owl'            -- Put your favorite colorscheme here
opt.completeopt = {'menuone', 'noinsert', 'noselect'}  -- Completion options (for deoplete)
opt.expandtab = true                -- Use spaces instead of tabs
opt.hidden = true                   -- Enable background buffers
opt.ignorecase = true               -- Ignore case
opt.joinspaces = false              -- No double spaces with join
opt.list = true                     -- Show some invisible characters
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
cmd 'autocmd FocusLost,BufLEave * :wa'
-------------------- MAPPINGS ------------------------------
-- <Tab> to navigate the completion menu
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

map('n', '<C-l>', '<cmd>noh<CR>')    -- Clear highlights
map('n', '<leader>o', 'm`o<Esc>``')  -- Insert a newline in normal mode
map('n', '<Tab>', ':bnext<CR>')      -- File navigation
map('n', '<S-Tab>', ':bprev<CR>')
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
map('n', '<leader>/', ':%s/')

-- Plugins Mappings
map('n', '<C-f>', ':FZF<CR>')
map('n', '<C-g>', ':Rg<CR>')

-------------------- LSP -----------------------------------
local lsp = require 'lspconfig'
local lspfuzzy = require 'lspfuzzy'

lspfuzzy.setup {}  -- Make the LSP client use FZF instead of the quickfix list

--map('n', '<space>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
--map('n', '<space>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
--map('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
--map('n', '<space>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
--map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
--map('n', '<space>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
--map('n', '<space>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
--map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
--map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode
