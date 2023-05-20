-- Constants, aliases and functions {{{1
local v = vim.cmd
local set = vim.opt
local default_keymap_options = { silent=true }
local keymap =  function(mode,shortcut,cmd,opts) vim.keymap.set(mode,shortcut,cmd,opts or default_keymap_options) end
local buf_map = function(mode,shortcut,cmd)
	local opts = {}
	for key, value in pairs(default_keymap_options) do
		opts[key] = value
	end
	opts.buffer = true
	vim.keymap.set(mode,shortcut,cmd,opts)
end
-- Version logic {{{2
local function has(version)
	return vim.fn.has(version) == 1
end
local function with_version(version) return function(yes, no)
	if has('nvim-'..version) then
		return yes
	else
		return no
	end
end end
-- }}}2
-- Autocommands setup {{{2
--[[ USAGE [[
augroup 'AutoCmdName' {
  autocmd('Event1', 'pattern1', function() ... end);
  autocmd('Event2', 'pattern2', 'g:VimFunction');
  autocmd('Event3', 'pattern3', '<Cmd>echom "Regular commands"');
}
--]]
local function autocmd(event,pattern,cmd)
    if type(cmd) == 'function' or
	   type(cmd) == 'table' or
	   type(cmd) == 'string' and string.sub(cmd,1,2) == 'g:'
	then
        return {event=event,opts = {pattern=pattern,callback=cmd}}
    elseif type(cmd) == 'string' then
        return {event=event,opts = {pattern=pattern,command=cmd}}
    else
        print("You cannot execute "..type(cmd))
        vim.pretty_print(cmd)
    end
end
local function augroup(name) return function(autocmds)
    local group = vim.api.nvim_create_augroup(name,{clear=true})
    for _, autocmd in ipairs(autocmds) do
        autocmd.opts.group = group
        vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
    end
    return group
end end
-- }}}2
local pprint = with_version'0.7'(vim.pretty_print, print)
-- }}}1
-- Settings {{{1
-- nvim-lsp settings {{{2
if not vim.g.vscode then
-- nvim-cmp {{{3
local cmp = require 'cmp'
local cmap = cmp.mapping

cmp.setup{
	snippet = { -- {{{4
		expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end
	}, -- }}}4
	mapping = { -- {{{4
			['<C-n>'] = cmap(function()cmp.select_next_item()end, {'i','s'}),
			['<C-p>'] = cmap(function()cmp.select_prev_item()end, {'i','s'}),
		    ['<C-d>'] = cmap(cmap.scroll_docs(-4), { 'i', 'c' }),
		    ['<C-f>'] = cmap(cmap.scroll_docs(4), { 'i', 'c' }),
			['<C-Space>'] = cmap(cmap.complete(), {'i','c'}),
			['<C-y>'] = cmp.config.disable,
			['<C-e>'] = cmap{
				i = cmap.abort(),
				c = cmap.close(),
			},
			['<Tab>'] = function(fallback)
				if cmp.visible() then
					cmp.confirm({ select = true });
				else
					fallback()
				end
			end,
	}, -- }}}4
	sources = cmp.config.sources{ -- {{{4
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
		{ name = 'ultisnips'},
	}, -- }}}4
	completion = { -- {{{4
		autocomplete = false
	}, -- }}}4

}

-- Updated capabilities
local capabilities = require'cmp_nvim_lsp'.default_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)
-- }}}3
-- lsp-signature settings {{{3
require'lsp_signature'.on_attach{
	bind = true,
	doc_lines = 2,
	floating_window = false,
	fix_pos = false,
	hint_enable = true,
	hint_prefix = "⧁ ",-- "💭🐼ᐅ"
	use_lspsaga = false,
	hi_parameter = "Search",
	max_height = 12,
	max_width = 120,
	handler_opts = {
		border = "shadow"
	},
}
-- }}}3
-- treesitter settings {{{3
require 'nvim-treesitter.configs'.setup{
	ignore_install = {},
	highlight = {
		enable = true,
		disable = {}
	},
	indent = {
		enable = true,
	},
}
-- }}}3
-- nvim-lspconfig {{{3
-- Custom attach function {{{4
local custom_lsp_attach = function(_, bufnr) -- _ == client
	-- local function option(...) vim.api.nvim_buf_set_option(bufnr,...) end
	-- option('omnifunc', 'v:lua.vim.lsp.omnifunc')
end -- }}}4
-- Python completion options {{{4
require'lspconfig'.pyright.setup{
	capabilities = capabilities,
} -- }}}4
-- Lua completion options {{{4
-- Figurint out executable path and other variables {{{5
local system_name = 'Linux'
local sumneko_root_path = '/home/ayhon/git/lua-language-server/'
local sumneko_binary = string.format("%s/bin/%s/lua-language-server",
	sumneko_root_path,            -- sumneko root path
	system_name                   -- System name
)
-- }}}5
require'lspconfig'.lua_ls.setup{
	cmd = {sumneko_binary,"-E",sumneko_root_path.."/main.lua"},
	settings = {
		Lua = { -- {{{5
			runtime = { -- {{{6
				version = 'LuaJIT',
				path = vim.split(package.path, ';'),
			}, -- }}}6
			diagnostics = { -- {{{6
				globals = {'vim','love'},
			}, -- }}}6
			workspace = { -- {{{6
				preloadFileSize = 300,
				library = {
					-- Make server aware of nvim runtime files
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
					-- Emmy Love API
					[vim.fn.expand('$HOME/.config/love-autocomplete')] = true,
				},
			}, -- }}}6
			telemetry = { -- {{{6
				enable = false,
			}, -- }}}6
		}, -- }}}5
	},
	on_attach = custom_lsp_attach,
	capabilities = capabilities,
} -- }}}4
-- C/C++ completion options {{{4
require'lspconfig'.clangd.setup {
	capabilities = capabilities,
} -- }}}4
-- HDL completion options{{{4
--[[
-- Only define once
if not require'lspconfig.configs'.hdl_checker then
	require'lspconfig/configs'.hdl_checker = {
		default_config = {
			cmd = {"hdl_checker", "--lsp", };
			filetypes = {"vhdl", "verilog", "systemverilog"};
			root_dir = function(fname)
				-- will look for a parent directory with a .git directory. If none, just
				local util = require'lspconfig'.util
				return util.root_pattern('.hdl_checker.config')(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
				-- or (not both)
				-- Will look for the .hdl_checker.config file in a parent directory. If
				-- none, will use the current directory
				-- return lspconfig.util.root_pattern('.hdl_checker.config')(fname) or lspconfig.util.path.dirname(fname)
			end;
			settings = {};
		};
	}
end
--]]
require'lspconfig'.hdl_checker.setup{}

-- }}}4
-- Haskell completion options {{{4
local util = require 'lspconfig/util'
local root_patterns = {"*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml"}
require'lspconfig'.hls.setup{
-- 	root_dir = function(fname)
-- 		return util.root_pattern(table.unpack(root_patterns))(fname) or util.path.dirname(fname)
-- 	end,
--     capabilities = capabilities
}
-- }}}4
-- Svelte completion options{{{4
-- require'lspconfig'.svelte.setup{
-- 	capabilities = capabilities
-- }
-- }}}4
-- Solidity completion options {{{4
-- require'lspconfig'.solidity_ls.setup{
-- 	root_dir = function(fname)
--         return require'lspconfig'.util.find_git_ancestor(fname)
--           or require'lspconfig'.util.find_node_modules_ancestor(fname)
--           or require'lspconfig'.util.find_package_json_ancestor(fname)
--           or vim.loop.cwd()
--       end
-- }
-- }}}4
-- Go completion optionsn {{{4
-- require'lspconfig'.gopls.setup{}
-- }}}4
-- Java completion options {{{4
-- TODO: Fix
-- require'lspconfig'.java_language_server.setup{
-- 	cmd = {'~/git/java-language-server/dist/lang_server_linux.sh'}
-- }
-- }}}4
-- Typescript completion options {{{4
require'lspconfig'.tsserver.setup{}
-- }}}4
-- Rust completion options {{{4
local rt = require("rust-tools")
-- require'lspconfig'.rust_analyzer.setup{} -- Conflicts with rust-tools

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<Leader>K", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})
-- }}}4
-- Latex completion options {{{4
require'lspconfig'.texlab.setup{}
-- }}}4
-- Julia completion options {{{4
require'lspconfig'.julials.setup{}
-- }}}4
-- }}}3
end
-- }}}2
-- Interface settings {{{2
-- set number relativenumber "set hybrid numbers
if not vim.g.vscode then
set.termguicolors = true
set.laststatus    = with_version'0.7'(3,2) -- status bar is shown even when in only one buffer
set.errorbells    = false -- disable beep on errors
set.wildmenu      = true -- display command line's tab complete options as menu
set.incsearch     = true-- search the word as its written
set.hlsearch      = true -- highlight the words matched by pattern
set.termguicolors = true-- enables true color in terminal. Uses cterm values
set.fillchars     = "eob: ,fold: "
set.background    = "dark"
set.conceallevel  = 1
set.shortmess     : remove('F')
set.guifont       = "Source Code Pro"
if has('0.8') then
	set.cmdheight = 0
end
v'colorscheme ayu-dark'
end
-- Other cool colorschemes {{{3
-- Dark {{{4
-- colorscheme sky " Weirdly works best after dark background
-- colorscheme ayu
-- colorscheme jellyx
-- colorscheme benokai
-- }}}4
-- White {{{4
-- colorscheme macvim-light
-- colorscheme github
-- }}}4
-- }}}3
-- }}}2
-- Behaviour settings {{{2
set.encoding   = "utf-8" -- use encoding that support unicode
set.ignorecase = true    -- ignore case when searching
set.smartcase  = true    -- not ignore case if typing in capital letters
set.undodir    = vim.fn.expand("$HOME/.config/nvim/undodir") -- Where to store undo history TODO
set.undofile   = true    -- mantain undo history between sessions
set.updatetime = 750
set.tabstop    = 4
set.shiftwidth = 4
set.modeline   = true    -- check the last line of a file for extra settings
set.makeprg    = "make -s"
set.splitbelow = true    -- better window splitting
set.splitright = true    -- better window splitting
set.smarttab   = true
set.nrformats  : remove('octal')
set.mouse      = "a"     -- enable mouse
set.completeopt={"menu", "menuone", "noselect"} -- list of options for completion
set.hidden     = true    -- hide unused buffers instead of unloading them
set.wildignore = {".gitkeep", "node_modules/**"}
set.autochdir  = false
set.foldmethod = 'expr'
set.foldexpr   = 'nvim_treesitter#foldexpr()'
set.foldlevel  = 99
-- }}}2
-- Plugin settings {{{2
if not vim.g.vscode then
require 'plugins'
-- venn.nvim {{{3
-- venn.nvim: enable or disable keymappings
function _G.Toggle_venn()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)
    if venn_enabled == "nil" then
        vim.b.venn_enabled = true
        vim.cmd[[setlocal virtualedit=all]]
        -- draw a line on HJKL keystokes
        buf_map("n", "J", "<C-v>j:VBox<CR>")
        buf_map("n", "K", "<C-v>k:VBox<CR>")
        buf_map("n", "L", "<C-v>l:VBox<CR>")
        buf_map("n", "H", "<C-v>h:VBox<CR>")
        -- draw a box by pressing "f" with visual selection
        buf_map("v", "f", ":VBox<CR>")
    else
        vim.cmd[[setlocal virtualedit=]]
        vim.cmd[[mapclear <buffer>]]
        vim.b.venn_enabled = nil
    end
end
-- toggle keymappings for venn using <leader>v
keymap('n', '<leader>v', ":lua Toggle_venn()<CR>")
-- }}}3
-- Indent-blank line {{{3
require'indent_blankline'.setup{
	char = '|',
	enabled = false,
}
v[[nnoremap <leader>il :IndentBlanklineToggle<CR>]]
-- }}}3
-- nvim-tree.lua {{{3
-- require'nvim-tree'.setup{}
-- }}}3
-- feline status line {{{3
-- require('feline').setup{}
require 'feline-setups.iBhagwan'()
-- }}}3
-- ultisnips {{{3
vim.g.UltiSnipsEditSplit = "horizontal"

keymap('n', '<leader>ue', '<Cmd>UltiSnipsEdit<CR>')
-- }}}3
-- vimtex {{{3
vim.g.tex_flavor='latex'
vim.g.vimtex_view_method='zathura'
vim.g.vimtex_quickfix_mode=0
vim.g.tex_conceal='abdmg'
-- }}}3
-- vim-markdown {{{3
-- native plugin {{{4
-- let g:markdown_fenced_languages = [ 'cpp', 'python', 'r', 'lua']
vim.g.markdown_fenced_languages = {
	'cpp',
	'python',
	'rust',
	'lua',
	'javascript',
	'haskell',
	-- 'latex',
	'tex',
}
-- }}}4
--  plasticboy's version {{{4
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_folding_disabled = 1
-- }}}4
-- }}}3
-- vim-tmux-navigator {{{3
vim.g.tmux_navigator_no_mappings = 1
-- }}}3
-- parinfer {{{3
vim.g.vim_parinfer_globs = {'*.lisp', 'yuck'}
vim.g.vim_parinfer_filetypes = {'lisp', 'yuck'}
-- }}}3
-- fern file browser {{{3

if has('nvim-0.7') then
	vim.g['fern#renderer'] = 'nerdfont'
	local fern_mappings = function()
		buf_map('n', 'p',     '<Plug>(fern-action-preview:toggle)')
		buf_map('n', '<C-p>', '<Plug>(fern-action-preview:auto:toggle)')
		buf_map('n', '<C-d>', '<Plug>(fern-action-preview:scroll:down:half)')
		buf_map('n', '<C-u>', '<Plug>(fern-action-preview:scroll:up:half)')
		buf_map('n', '-',     '<Plug>(fern-action-leave)')
		buf_map('n', '+',     '<Plug>(fern-action-mark)')
        buf_map('n', 'ZZ',    '<Cmd>quit<CR>')
	end
    -- v[[
    -- function! FernSettings() abort
    --   nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
    --   nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
    --   nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
    --   nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
    --   nmap <silent> <buffer> - <Plug>(fern-action-leave)
    --   nmap <silent> <buffer> + <Plug>(fern-action-mark)
    -- endfunction
    -- ]]
    augroup'fern_settings'{
        autocmd('FileType', 'fern', fern_mappings)
    }

	-- vim.api.nvim_create_autocmd('ColorScheme', {
	--   pattern = 'rubber',
	--   group = augroup,
	--   command = 'highlight String guifg=#FFEB95'
	-- })
else
v[[
let g:fern#renderer = 'nerdfont'
function! FernSettings() abort
  nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
  nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
  nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
  nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
  nmap <silent> <buffer> - <Plug>(fern-action-leave)
  nmap <silent> <buffer> + <Plug>(fern-action-mark)
endfunction

augroup fern-settings
  autocmd!
  autocmd FileType fern call FernSettings()
augroup END
]]
end
-- }}}3
-- colorizer.lua {{{3
require'colorizer'.setup{
	'vim',
	'lua',
	'toml',
	'css',
}
-- }}}3
-- Fine command line {{{3
--[[
require'fine-cmdline'.setup({
	cmdline = {
		enable_keymaps = true,
		smart_history = true,
		prompt = ':'
	},
	popup = {
		position = {
			row = '10%',
			col = '50%',
		},
		size = {
			width = '60%',
		},
		border = {
			style = 'rounded',
		},
		win_options = {
			winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
		},
	},
	-- hooks = {
	-- 	before_mount = function(input)
	-- 		-- code
	-- 	end,
	-- 	after_mount = function(input)
	-- 		-- code
	-- 	end,
	-- 	set_keymaps = function(imap, feedkeys)
	-- 		-- code
	-- 	end
	-- }
}) --]]
-- }}}3
-- gitsigns {{{3
require'gitsigns'.setup{}
-- }}}3
-- nvim-treesitter {{{3
require "nvim-treesitter.configs".setup {
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = 'o',
      toggle_hl_groups = 'i',
      toggle_injected_languages = 't',
      toggle_anonymous_nodes = 'a',
      toggle_language_display = 'I',
      focus_language = 'f',
      unfocus_language = 'F',
      update = 'R',
      goto_node = '<cr>',
      show_help = '?',
    },
  }
}
-- }}}3
-- scala metals {{{
MetalsConfig = require'metals'.bare_config()
-- metals_config.init_options.statusBarProvider = "on"
MetalsConfig.on_attach = function(_, _) -- client, bufnr
	require'metals'.setup_dap()
end
MetalsConfig.settings = {
	showImplicitArguments = true,
}
-- }}}
-- nvim-dap {{{3
-- }}}3
-- nvim-ufo {{{3
vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
require('ufo').setup({
    provider_selector = function() -- (bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})
-- }}}3
end
-- }}}2
-- }}}1
-- Mappings {{{1
vim.g.mapleader=" "
keymap('i', '<C-C>', '<Esc>') -- So <C-c> is detected by InsertLeave
-- Regular normal mappings {{{2
keymap('n', '<C-l>',      '<Cmd>silent nohlsearch<CR><C-l>')
local modal_hybrid_numbers_id = nil
-- Hide all UI and toggle modal hybrid numbers {{{3
function _G.ToggleModalHybridNumbers()
	if vim.fn.exists('#ModalHybridNumbers#InsertEnter') == 0 then
		set.relativenumber = true
		set.number = true
		modal_hybrid_numbers_id = augroup'ModalHybridNumbers'{
			autocmd('InsertEnter', '*', 'setlocal norelativenumber');
			autocmd('InsertLeave', '*', 'setlocal relativenumber');
		}
	else
		set.relativenumber = false
		set.number = false
        vim.api.nvim_del_augroup_by_id(modal_hybrid_numbers_id)
	end
end
local hidden_all = false
function _G.ToggleHiddenAll()
	ToggleModalHybridNumbers()
	if hidden_all then
		set.showmode   = true
		set.ruler      = true
		set.laststatus = 2
		set.showcmd    = true
		set.signcolumn = 'auto'
	else
		set.showmode   = false
		set.ruler      = false
		set.laststatus = 0
		set.showcmd    = false
		set.signcolumn = 'no'
	end
	hidden_all = not hidden_all
end
keymap('n', '<A-S-z>', ToggleHiddenAll)
keymap('n', '<A-S-x>', ToggleModalHybridNumbers)
ToggleHiddenAll()
ToggleModalHybridNumbers()
-- }}}3
-- Switch ayu-ish colorschemes' variants {{{3
local function ToggleColorschemeVariant()
	if vim.o.background == 'dark' then
		vim.o.background = 'light'
	else
		vim.o.background = 'dark'
	end
	require'feline'.colors = require'feline-setups.theme.ayu'.get_variant_colors()
end
keymap('n', '<leader>cst', ToggleColorschemeVariant)
-- }}}3
keymap('n', '<leader>he', '<Cmd>silent Hexedit<CR>')
keymap('n', '<leader>sw', ':s/<cword>/')
keymap('n', '<leader>sW', ':s/<cWORD>/')
keymap('n', '<C-t>', '<Cmd> silent ter<CR>')
-- }}}2
-- Terminal mappings {{{2
keymap('t', '<A-c>',      '<C-\\><C-N>')

keymap('t', '<A-h>',      '<C-\\><C-N><A-h>')
keymap('t', '<A-j>',      '<C-\\><C-N><A-j>')
keymap('t', '<A-k>',      '<C-\\><C-N><A-k>')
keymap('t', '<A-l>',      '<C-\\><C-N><A-l>')
-- }}}2
-- Quicklist mappings {{{2
keymap('n', '<leader>qo', '<Cmd>copen<CR>')
keymap('n', '<leader>qc', '<Cmd>cclose<CR>')
keymap('n', '<leader>qn', '<Cmd>cnext<CR>')
keymap('n', '<leader>qN', '<Cmd>cprev<CR>')
-- }}}2
-- Locallist mappings {{{2
keymap('n', '<leader>lo', '<Cmd>lopen<CR>')
keymap('n', '<leader>lc', '<Cmd>lclose<CR>')
keymap('n', '<leader>ln', '<Cmd>lnext<CR>')
keymap('n', '<leader>lN', '<Cmd>lprev<CR>')
-- }}}2
-- Diff mappings {{{2
keymap('n', '<leader>tt', '<Cmd>TroubleToggle<CR>')
keymap('n', 'gh',         '<Cmd>diffget //2<CR>')
keymap('n', 'gl',         '<Cmd>diffget //3<CR>')

keymap('n', '<leader>dt', '<Cmd>diffthis<CR>')
keymap('n', '<leader>do', '<Cmd>diffoff<CR>')
-- }}}2
-- nvim-lsp mappings {{{2
keymap('i', '<C-space>',  '<C-x><C-o>')

keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>')
keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>')
keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>')
keymap('n', 'gi',         '<Cmd>lua vim.lsp.buf.implementation()<CR>')
keymap('n', '<C-k>',      '<Cmd>lua vim.lsp.buf.signature_help()<CR>')
keymap('n', '<space>D',   '<Cmd>lua vim.lsp.buf.type_definition()<CR>')
keymap('n', '<space>r',   '<Cmd>lua vim.lsp.buf.rename()<CR>')
keymap('n', '<space>a',   '<Cmd>lua vim.lsp.buf.code_action()<CR>')
keymap('n', 'gr',         '<Cmd>lua vim.lsp.buf.references()<CR>')
keymap('n', '<space>e',   '<Cmd>lua vim.diagnostic.open_float()<CR>')
keymap('n', '[d',         '<Cmd>lua vim.diagnostic.goto_prev()<CR>')
keymap('n', ']d',         '<Cmd>lua vim.diagnostic.goto_next()<CR>')
-- keymap('n', '<space>q',   '<Cmd>lua vim.diagnostic.setloclist()<CR>')
-- keymap('n', '<space>f',   '<Cmd>lua vim.lsp.buf.formatting()<CR>')
-- }}}2
-- Buffer movement {{{2
keymap('n', '<C-N>',      '<Cmd>bprev<CR>')
keymap('n', '<C-M>',      '<Cmd>bnext<CR>')

-- keymap('n', '<A-h>',      '<C-w>h')
keymap('n', '<A-h>',      '<Cmd>TmuxNavigateLeft<CR>')
-- keymap('n', '<A-j>',      '<C-w>j')
keymap('n', '<A-j>',      '<Cmd>TmuxNavigateDown<CR>')
-- keymap('n', '<A-k>',      '<C-w>k')
keymap('n', '<A-k>',      '<Cmd>TmuxNavigateUp<CR>')
-- keymap('n', '<A-l>',      '<C-w>l')
keymap('n', '<A-l>',      '<Cmd>TmuxNavigateRight<CR>')

keymap('n', '<A-S-j>',    '<Cmd>sp<CR>')
keymap('n', '<A-S-l>',    '<Cmd>vsp<CR>')
-- }}}2
-- Telescope mappings {{{2
keymap('n', '<leader>fh', '<Cmd>Telescope help_tags<CR>')
keymap('n', '<leader>ff', '<Cmd>Telescope find_files<CR>')
keymap('n', '<leader>ft', '<Cmd>Telescope live_grep<CR>')
keymap('n', '<leader>fm', '<Cmd>Telescope keymaps<CR>')
keymap('n', '<leader>fcs','<Cmd>Telescope colorscheme<CR>')
keymap('n', '<leader>mc','<Cmd>lua require"telescope".extensions.metals.commands()<CR>')
-- }}}2
-- }}}1
-- Autocommands {{{1
v[[
if &background == "dark"
	echom "Oh yeah baby"	
endif
]]
if has('nvim-0.7') then
    --          EVENT                     PATTERN          COMMAND
    augroup'lsp'{
        autocmd('FileType',               {'scala','sbt'}, function() require'metals'.initialize_or_attach(MetalsConfig)end);
    }
	_G.CoqOverride = function()
		v'highlight CoqtailChecked ctermbg=17 guibg=#224422'
		v'highlight CoqtailSent ctermbg=60 guibg=#007630'
		v'highlight CoqtailError ctermbg=17 guibg=#560000'  
		
		
	end
	augroup'CoqOverride'{
		autocmd('FileType', {'coq'},  _G.CoqOverride);
		autocmd('FileType', {'coq'}, function() vim.keymap.set('n', 'K', '<Plug>CoqToLine', {buffer = 0}) end);
	}
    augroup'templates'{
        autocmd('BufNewFile',             '*.cpp',         '0r ~/.vim/templates/cpp.tpl');
        autocmd('BufNewFile',             'main.lua',      '0r ~/.vim/templates/love.tpl');
    }
    augroup'obscure_syntax_highlighting'{
        autocmd({'BufNewFile','BufRead'}, '/*.rasi',       'setf css');
        autocmd({'BufNewFile','BufRead'}, '/*.mdx',        'setf markdown');
    }
else v[[
augroup lsp
	au!
	au FileType scala,sbt lua require("metals").initialize_or_attach({})
augroup end

" Suposed to make a template file for all C++ files TODO: Move to specific plugin file (after/cpp.vim)
autocmd BufNewFile *.cpp 0r ~/.vim/templates/cpp.tpl

" Syntax highlighting in .rasi files (Rofi theme files)
autocmd BufNewFile,BufRead /*.rasi setf css
" Syntax highlighting in .mdx files (Markdown extended files)
autocmd BufNewFile,BufRead /*.mdx setf markdown

" Switching between relative and nonrelative numbers between insert and normal mode
function! ToggleModalHybridNumbers()
	if !exists('#ModalHybridNumbers#InsertEnter')
		set relativenumber number
		augroup ModalHybridNumbers
			autocmd!

			autocmd InsertEnter * :setlocal norelativenumber
			autocmd InsertLeave * :setlocal relativenumber
		augroup END
	else
		set norelativenumber nonumber
		augroup ModalHybridNumbers
			autocmd!
		augroup END
	endif
endfunction
call ToggleModalHybridNumbers()
call ToggleHiddenAll()
]]
end
-- }}}1
-- User commands {{{1
-- TODO: Define sessions in a specified directory
-- command Mksession mksession
-- Align command {{{2
v[[
command! -nargs=? -range Align <line1>,<line2>call AlignSection('<args>')
vnoremap <silent> <Leader>a= <Cmd>Align<CR>
vnoremap <silent> <Leader>ar :Align 
function! AlignSection(regex) range
  let extra = 1
  let sep = empty(a:regex) ? '=' : a:regex
  let maxpos = 0
  let section = getline(a:firstline, a:lastline)
  for line in section
    let pos = match(line, ' *'.sep)
    if maxpos < pos
      let maxpos = pos
    endif
  endfor
  call map(section, 'AlignLine(v:val, sep, maxpos, extra)')
  call setline(a:firstline, section)
endfunction

function! AlignLine(line, sep, maxpos, extra)
  let m = matchlist(a:line, '\(.\{-}\) \{-}\('.a:sep.'.*\)')
  if empty(m)
    return a:line
  endif
  let spaces = repeat(' ', a:maxpos - strlen(m[1]) + a:extra)
  return m[1] . spaces . m[2]
endfunction
]]
-- }}}2
--}}}1
-- Neovide settings {{{1
if vim.g.neovide then
    -- vim.g.smoothie_enabled = false
    vim.g.neovide_cursor_animation_leght=0.05
    vim.g.neovide_cursor_trail_length=10.01
    vim.g.neovide_fullscreen=false
    vim.g.neovide_cursor_vfx_mode = "sonicboom"
    -- vim.g.neovide_cursor_vfx_mode = "railgun"
	keymap('n', '<M-CR>',function() vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen end)
	require("size-matters")
end
-- vim.g.neovide_
-- }}}1
--       ▗               ▗▀▖▗
-- ▛▀▖▌ ▌▄ ▛▚▀▖ ▞▀▖▞▀▖▛▀▖▐  ▄ ▞▀▌
-- ▌ ▌▐▐ ▐ ▌▐ ▌ ▌ ▖▌ ▌▌ ▌▜▀ ▐ ▚▄▌
-- ▘ ▘ ▘ ▀▘▘▝ ▘ ▝▀ ▝▀ ▘ ▘▐  ▀▘▗▄▘
-- vim: set foldmethod=marker path+=./lua foldlevel=0:
