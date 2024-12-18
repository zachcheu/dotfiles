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
  use {'ojroques/vim-oscyank'}
  use {'echasnovski/mini.surround'}
  --use {'nvim-focus/focus.nvim'}
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
g['coq_settings'] = {auto_start = true}
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
require("coq")
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
--require("focus").setup()

--local ignore_buftypes = { 'nofile', 'prompt', 'popup' }
--local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })
--vim.api.nvim_create_autocmd({'WinEnter'}, {
--    group = augroup,
--    callback = function(_)
--        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
--        then
--            vim.w.focus_disable = true
--        else
--            local before = vim.w.focus_disable
--            vim.w.focus_disable = false or vim.w.focus_disable
--        end
--    end,
--    desc = 'Disable focus autoresize for BufType',
--})
--vim.api.nvim_create_autocmd({'WinLeave'}, {
--    group = augroup,
--    callback = function(_)
--        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
--        then
--            vim.w.focus_disable = true
--        end
--    end,
--    desc = 'Disable focus autoresize for BufType',
--})
--vim.api.nvim_create_autocmd("VimEnter", {
--	callback = function()
--    vim.w.focus_disable = true
--		vim.cmd(":CHADopen --nofocus")
--	end,
--})


--vim.api.nvim_create_autocmd("FocusLost", {
--	callback = function()
--		vim.cmd(":Catppuccin latte")
--	end,
--})
--vim.api.nvim_create_autocmd("FocusGained", {
--	callback = function()
--		vim.cmd(":Catppuccin latte")
--	end,
--})

-- Might not work?
function feedkeys(input)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(input,true,false,true),'n',false)
end

vim.api.nvim_create_autocmd({'FileType'},{
    pattern = 'qf',
    callback = function(_)
        opt.buflisted = false
    end,
})

require('nvim-autopairs').setup{}
require('lualine').setup({
  sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
      },
    },
  },
  inactive_sections = {
    lualine_c = {
      {
        'filename',
        path = 3,
      },
    },
  },
})

local actions = require("fzf-lua.actions")
require("fzf-lua").setup({
    grep = {
        actions = {
            ["ctrl-f"] = {actions.grep_lgrep},
            ["ctrl-g"] = false,
        },
    },
})

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
opt.wildmode = {"list:longest","full"}  -- Command-line completion mode
opt.wildmenu = true
opt.wildoptions = "pum"
opt.wrap = false                    -- Disable line wrap
opt.virtualedit = 'insert'
opt.mouse = ""
opt.mousescroll = "ver:0,hor:0"
opt.winhighlight = "Normal:MyNormal"

cmd 'autocmd FocusLost,BufLeave * :wa'
-------------------- MAPPINGS ------------------------------
map('n', 'n', 'nzz')                
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
map('n', '<leader><leader>', ':nohl<CR>')
map('v', '//', ':')

-- Copy/Paste
map('v', '<leader>y', '"+y')
map('n', '<leader>y', '"+y')
map('n', '<leader>Y', '"+yg_')
map('n', '<leader>p', '"+p')
map('n', '<leader>P', '"+P')
map('v', '<leader>p', '"+p')
map('v', '<leader>P', '"+P')

-- quickfix
function toggle_qf()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end
vim.keymap.set({'n','v'}, '<leader>ll', toggle_qf)

vim.keymap.set({'n','v'}, '<leader>lo', ':cold<CR>')
vim.keymap.set({'n','v'}, '<leader>li', ':cnew<CR>')
vim.keymap.set({'n','v'}, '<leader>lk', ':cprev<CR>')
vim.keymap.set({'n','v'}, '<leader>lj', ':cnext<CR>')

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

-- fzflua
map('n', '<leader>fb', ':FzfLua buffers<CR>')
map('n', '<leader>fh', ':FzfLua oldfiles<CR>')
map('n', '<leader>fo', ':lua require("fzf-lua").files({cwd=get_root(), git_icons=false, resume=true})<CR>')
map('n', '<leader>fO', ':lua require("fzf-lua").files({cwd=get_root(), git_icons=false, resume=false})<CR>')
map('n', '<leader>fp', ':lua require("fzf-lua").files({cwd=get_repo(), git_icons=false, resume=true})<CR>')
map('n', '<leader>fP', ':lua require("fzf-lua").files({cwd=get_repo(), git_icons=false, resume=false})<CR>')
map('n', '<leader>f/', ':lua require("fzf-lua").live_grep_glob({cwd=get_root(), resume=true})<CR>')
map('n', '<leader>f?', ':lua require("fzf-lua").live_grep_glob({cwd=get_root(), resume=false})<CR>')
map('n', '<leader>/', ':lua require("fzf-lua").lgrep_curbuf({search=" ", resume=true})<CR>')
map('n', '<leader>?', ':lua require("fzf-lua").lgrep_curbuf({search=" ", resume=false})<CR>')
map('n', '<leader>ff', ':FzfLua quickfix<CR>')

-- OSCYank
vim.keymap.set('n', '<leader>c', '<Plug>OSCYankOperator')
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', '<Plug>OSCYankVisual')

--chadtree
local fileExplorerPrevWindow
map('n', '<leader>fe', function()
  if vim.bo.buftype == "nofile" and fileExplorerPrevWindow ~= null then
    return ":lua vim.api.nvim_set_current_win("..fileExplorerPrevWindow..")<cr>"
  else
    fileExplorerPrevWindow = vim.api.nvim_get_current_win()
    return ":CHADopen --always-focus<CR>"
  end
  return
end, {expr = true, silent = true})
map('n', '<leader>fq', ":CHADopen --nofocus<cr>", {silent = true})
--fugitive
map('n', '<leader>hf', ':Git difftool -y %<CR>')
map('n', '<leader>hF', ':Git difftool -y HEAD~1 %<CR>')
map('n', '<leader>hd', ':Git difftool -y<CR>')
map('n', '<leader>hD', ':Git difftool -y HEAD~1<CR>')
map('n', '<leader>hh', ':tabfirst | :.tabonly<CR>')

function fugitive_uber_sourcegraph(opts)
    local repo = string.match(opts.remote, '[^%s]+:([^%s]+)')
    repo = string.gsub(repo, '@', '-') -- e.g. grail@production
    local mainUrl = 'https://sourcegraph.uberinternal.com/code.uber.internal/' .. repo .. '@' .. 'main' .. '/-/' .. opts.type .. '/' .. opts.path
    local url = 'https://sourcegraph.uberinternal.com/code.uber.internal/' .. repo .. '@' .. opts.commit .. '/-/' .. opts.type .. '/' .. opts.path
    if opts.line1 > 0 then
        mainUrl = mainUrl .. '#L' .. opts.line1
        url = url .. '#L' .. opts.line1
    else
        local lineNum = vim.api.nvim_win_get_cursor(0)[1]
        mainUrl = mainUrl .. '#L' .. lineNum
        url = url .. '#L' .. lineNum
    end
    if opts.line2 > 0 then
        mainUrl = mainUrl .. '-' .. opts.line2
        url = url .. '-' .. opts.line2
    end
    print(mainUrl)
    return url
end
vim.g.fugitive_browse_handlers = {fugitive_uber_sourcegraph}
vim.keymap.set({'n','v'}, '<leader>go', ":GBrowse!<cr>", {silent = true})

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

function get_repo()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  local root_dir = ""
  for dir in vim.fs.parents(path) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
  end
  return root_dir
end

function center_wrap_callback(argfunc)
  return function()
    argfunc()
    vim.cmd.normal{'zz'}
  end
end

-------------------- COMMANDS ------------------------------
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'  -- disabled in visual mode

-------------------- LSP ---------------------------
local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=false, buffer=bufnr }

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local fzf = require('fzf-lua')
  vim.keymap.set('n', 'gd', center_wrap_callback(vim.lsp.buf.definition), opts)
  vim.keymap.set('n', 'gh', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'ge', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', fzf.lsp_references, opts)
  vim.keymap.set('n', 'gi', fzf.lsp_implementations, opts)
  vim.keymap.set('n', 'gD', fzf.lsp_declarations, opts)
  vim.keymap.set('n', 'gt', fzf.lsp_typedefs, opts)
  local function quickfix()
      vim.lsp.buf.code_action({
          filter = function(a) return a.isPreferred end,
          apply = true
      })
  end
  vim.keymap.set('n', '<leader>gf', quickfix, opts)

  -- You can delete this if you enable format-on-save.
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
end

require('lspconfig').gopls.setup({
  cmd = {'gopls', '-remote=auto', '-debug=localhost:6060'},
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
