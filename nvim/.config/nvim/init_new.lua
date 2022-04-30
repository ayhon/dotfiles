-- Constants and aliases {{{1
local v = vim.cmd
local api = vim.api
local set = vim.opt
local keymap =  function (...) vim.api.nvim_set_keymap(...) end
local buf_map = function (...) vim.api.nvim_buf_set_keymap(0,...) end
-- }}}1
-- Settings {{{1
-- nvim-lsp settings {{{2
-- nvim-cmp {{{3
local cmp = require 'cmp'
local cmap = cmp.mapping

cmp.setup{
	snippet = { -- {{{4
		expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end
	}, -- }}}4
	mapping = { -- {{{4
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
local capabilities = require'cmp_nvim_lsp'.update_capabilities(
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
	ensure_installed = "maintained",
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
	-- LSP mappings {{{5
    print(bufnr)
	local opts = { noremap=true, silent=true }
	vim.api.nvim_buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	-- }}}5
	local function option(...) vim.api.nvim_buf_set_option(bufnr,...) end
	option('omnifunc', 'v:lua.vim.lsp.omnifunc')
	-- On-attach callbacks {{{5
	-- }}}5
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
require'lspconfig'.sumneko_lua.setup{
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
	-- on_attach = custom_lsp_attach,
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
	root_dir = function(fname)
		return util.root_pattern(table.unpack(root_patterns))(fname) or util.path.dirname(fname)
	end,
    capabilities = capabilities
}
-- }}}4
-- Svelte completion options{{{4
require'lspconfig'.svelte.setup{
	capabilities = capabilities
}
-- }}}4
-- Solidity completion options 4{{{
require'lspconfig'.solidity_ls.setup{
	root_dir = function(fname)
        return require'lspconfig'.util.find_git_ancestor(fname)
          or require'lspconfig'.util.find_node_modules_ancestor(fname)
          or require'lspconfig'.util.find_package_json_ancestor(fname)
          or vim.loop.cwd()
      end
}
-- }}}4
-- }}}3
-- }}}2
-- Interface settings {{{2
-- set number relativenumber "set hybrid numbers
set.termguicolors = true
set.laststatus    = 2 -- status bar is shown even when in only one buffer
set.errorbells    = false -- disable beep on errors
set.wildmenu      = true -- display command line's tab complete options as menu
set.incsearch     = true-- search the word as its written
set.hlsearch      = true -- highlight the words matched by pattern
set.termguicolors = true-- enables true color in terminal. Uses cterm values
set.fillchars     = "eob: ,fold: "
set.background    = "dark"
set.conceallevel  = 1
v'colorscheme ayun'
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
set.autochdir  = true
-- }}}2
-- Plugin settings {{{2
require 'plugins'
-- venn.nvim {{{3
-- venn.nvim: enable or disable keymappings
function _G.Toggle_venn()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)
    if venn_enabled == "nil" then
        vim.b.venn_enabled = true
        vim.cmd[[setlocal virtualedit='all']]
        -- draw a line on HJKL keystokes
        vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", {noremap = true})
        vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", {noremap = true})
        -- draw a box by pressing "f" with visual selection
        vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", {noremap = true})
    else
        vim.cmd[[setlocal virtualedit=]]
        vim.cmd[[mapclear <buffer>]]
        vim.b.venn_enabled = nil
    end
end
-- toggle keymappings for venn using <leader>v
vim.api.nvim_set_keymap('n', '<leader>v', ":lua Toggle_venn()<CR>", {noremap = true})
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
require('feline').setup(
	require 'feline-setups.6cdh'
)
-- }}}3
-- ultisnips {{{3
vim.g.UltiSnipsEditSplit = "horizontal"
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
vim.g.markdown_fenced_languages = { 'cpp', 'python', 'r', 'lua', 'java', 'javascript', 'html', 'css', 'haskell'}
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
if vim.fn.has('nvim-0.7') then
	vim.g['fern#rederer'] = 'nerdfont'
	local opts = { noremap=true, silent=true }
	local fern_settings = function()
		buf_map('n', 'p',     '<Plug>(fern-action-preview:toggle)',           opts)
		buf_map('n', '<C-p>', '<Plug>(fern-action-preview:auto:toggle)',      opts)
		buf_map('n', '<C-d>', '<Plug>(fern-action-preview:scroll:down:half)', opts)
		buf_map('n', '<C-u>', '<Plug>(fern-action-preview:scroll:up:half)',   opts)
		buf_map('n', '-',     '<Plug>(fern-action-leave)',                    opts)
		buf_map('n', '+',     '<Plug>(fern-action-mark)',                     opts)
	end
else
v[[
let g:fern#renderer = 'nerdfont'
function! s:fern_settings() abort
  nmap <silent> <buffer> p     <Plug>(fern-action-preview:toggle)
  nmap <silent> <buffer> <C-p> <Plug>(fern-action-preview:auto:toggle)
  nmap <silent> <buffer> <C-d> <Plug>(fern-action-preview:scroll:down:half)
  nmap <silent> <buffer> <C-u> <Plug>(fern-action-preview:scroll:up:half)
  nmap <silent> <buffer> - <Plug>(fern-action-leave)
  nmap <silent> <buffer> + <Plug>(fern-action-mark)
endfunction

augroup fern-settings
  autocmd!
  autocmd FileType fern lua fern_settings()
augroup END
]]
end
-- }}}3
-- colorizer.lua {{{3
require'colorizer'.setup{
	vim = {
		mode = 'background'
	}
}
-- }}}3
-- }}}2
-- }}}1
-- Mappings {{{1
vim.g.mapleader=" "

local opts = { noremap=true, silent=true }

keymap('i', '<C-C>', '<Esc>', opts) -- So <C-c> is detected by InsertLeave

keymap('n', '<leader>ue', '<Cmd>UltiSnipsEdit<CR>',                    opts)
-- Regular normal mappings {{{2
keymap('n', '<C-l>',      '<Cmd>silent nohlsearch<CR><C-l>',           opts) -- TODO: Why isn't it working?
-- v'nnoremap <silent> <C-l> <Cmd>silent nohlsearch<CR><C-l>'



v[[
let s:hidden_all = 0
function! ToggleHiddenAll()
	call ToggleModalHybridNumbers()
	if s:hidden_all  == 0
		let s:hidden_all = 1
		set noshowmode
		set noruler
		set laststatus=0
		set noshowcmd
		set signcolumn=no
	else
		let s:hidden_all = 0
		set showmode
		set ruler
		set laststatus=2
		set showcmd
		set signcolumn=auto
	endif
endfunction

nnoremap <silent> <A-S-z> :call ToggleHiddenAll()<CR>
]]
-- }}}2
-- Terminal mappings {{{2
keymap('t', '<A-c>',      '<C-\\><C-N>',                               opts)

keymap('t', '<A-h>',      '<C-\\><C-N><A-h>',                          opts)
keymap('t', '<A-j>',      '<C-\\><C-N><A-j>',                          opts)
keymap('t', '<A-k>',      '<C-\\><C-N><A-k>',                          opts)
keymap('t', '<A-l>',      '<C-\\><C-N><A-l>',                          opts)
-- }}}2
-- Quicklist mappings {{{2
keymap('n', '<leader>qo', '<Cmd>copen<CR>',  opts)
keymap('n', '<leader>qc', '<Cmd>cclose<CR>', opts)
keymap('n', '<leader>qn', '<Cmd>cnext<CR>',  opts)
keymap('n', '<leader>qN', '<Cmd>cprev<CR>',  opts)
-- }}}2
-- Locallist mappings {{{2
keymap('n', '<leader>lo', '<Cmd>lopen<CR>',  opts)
keymap('n', '<leader>lc', '<Cmd>lclose<CR>', opts)
keymap('n', '<leader>ln', '<Cmd>lnext<CR>',  opts)
keymap('n', '<leader>lN', '<Cmd>lprev<CR>',  opts)
-- }}}2
-- Diff mappings {{{2
keymap('n', '<leader>tt', '<Cmd>TroubleToggle<CR>',                    opts)
keymap('n', 'gh',         '<Cmd>diffget //2<CR>',                      opts)
keymap('n', 'gl',         '<Cmd>diffget //3<CR>',                      opts)

keymap('n', '<leader>dt', '<Cmd>diffthis<CR>',                         opts)
keymap('n', '<leader>do', '<Cmd>diffoff<CR>',                          opts)
-- }}}2
-- nvim-lsp mappings {{{2
keymap('i', '<C-space>',  '<C-x><C-o>',                                opts)

keymap('n', 'gD',         '<Cmd>lua vim.lsp.buf.declaration()<CR>',    opts)
keymap('n', 'gd',         '<Cmd>lua vim.lsp.buf.definition()<CR>',     opts)
keymap('n', 'K',          '<Cmd>lua vim.lsp.buf.hover()<CR>',          opts)
keymap('n', 'gi',         '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
keymap('n', '<C-k>',      '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
keymap('n', '<space>D',   '<Cmd>lua vim.lsp.buf.type_definition()<CR>',opts)
keymap('n', '<space>r',   '<Cmd>lua vim.lsp.buf.rename()<CR>',         opts)
keymap('n', '<space>a',   '<Cmd>lua vim.lsp.buf.code_action()<CR>',    opts)
keymap('n', 'gr',         '<Cmd>lua vim.lsp.buf.references()<CR>',     opts)
keymap('n', '<space>e',   '<Cmd>lua vim.diagnostic.open_float()<CR>',  opts)
keymap('n', '[d',         '<Cmd>lua vim.diagnostic.goto_prev()<CR>',   opts)
keymap('n', ']d',         '<Cmd>lua vim.diagnostic.goto_next()<CR>',   opts)
keymap('n', '<space>q',   '<Cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
-- keymap('n', '<space>f',   '<Cmd>lua vim.lsp.buf.formatting()<CR>',     opts)
-- }}}2
-- Buffer movement {{{2
keymap('n', '<C-N>',      '<Cmd>bprev<CR>',                            opts)
keymap('n', '<C-M>',      '<Cmd>bnext<CR>',                            opts)

-- keymap('n', '<A-h>',      '<C-w>h',                                    opts)
keymap('n', '<A-h>',      '<Cmd>TmuxNavigateLeft<CR>',                 opts)
-- keymap('n', '<A-j>',      '<C-w>j',                                    opts)
keymap('n', '<A-j>',      '<Cmd>TmuxNavigateDown<CR>',                 opts)
-- keymap('n', '<A-k>',      '<C-w>k',                                    opts)
keymap('n', '<A-k>',      '<Cmd>TmuxNavigateUp<CR>',                   opts)
-- keymap('n', '<A-l>',      '<C-w>l',                                    opts)
keymap('n', '<A-l>',      '<Cmd>TmuxNavigateRight<CR>',                opts)

keymap('n', '<A-S-j>',    '<Cmd>sp<CR>',                               opts)
keymap('n', '<A-S-l>',    '<Cmd>vsp<CR>',                              opts)
-- }}}2
-- Telescope mappings {{{2
keymap('n', '<leader>fh', '<Cmd>Telescope help_tags<CR>',               opts)
keymap('n', '<leader>ff', '<Cmd>Telescope find_files<CR>',              opts)
keymap('n', '<leader>ft', '<Cmd>Telescope live_grep<CR>',               opts)
keymap('n', '<leader>fm', '<Cmd>Telescope keymaps<CR>',                 opts)
keymap('n', '<leader>fcs','<Cmd>Telescope colorscheme<CR>',             opts)
-- }}}2
-- }}}1
-- Autocommands {{{1
v[[
augroup lsp
	au!
	au FileType scala,sbt lua require("metals").initialize_or_attach({})
augroup end

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

nnoremap <silent> <A-S-x> <Cmd>call ToggleModalHybridNumbers()<CR>

" Suposed to make a template file for all C++ files TODO: Move to specific plugin file (after/cpp.vim)
autocmd BufNewFile *.cpp 0r ~/.vim/templates/cpp.tpl

" Syntax highlighting in .rasi files (Rofi theme files)
autocmd BufNewFile,BufRead /*.rasi setf css
" Syntax highlighting in .mdx files (Markdown extended files)
autocmd BufNewFile,BufRead /*.mdx setf markdown
]]
-- }}}1
-- User commands {{{
-- TODO: Define sessions in a specified directory
-- command Mksession mksession
--}}}
-- Neovide settings {{{2
if vim.g.neovide then
    -- vim.g.smoothie_enabled = false
    vim.g.neovide_cursor_animation_leght=0.13
    vim.g.neovide_cursor_trail_length=0.8
    vim.g.neovide_fullscreen=true
    vim.g.neovide_cursor_vfx_mode = "sonicboom"
    -- vim.g.neovide_cursor_vfx_mode = "railgun"
	local opts = { noremap=true, silent=true }
	local function nmap(keys,cmd) vim.api.nvim_buf_set_keymap(0,'n',keys,cmd,opts) end
	nmap('<M-CR>', '<Cmd>let g:neovide_fullscreen=!g:neovide_fullscreen<CR>')
end
-- vim.g.neovide_
-- }}}1
--       ▗               ▗▀▖▗
-- ▛▀▖▌ ▌▄ ▛▚▀▖ ▞▀▖▞▀▖▛▀▖▐  ▄ ▞▀▌
-- ▌ ▌▐▐ ▐ ▌▐ ▌ ▌ ▖▌ ▌▌ ▌▜▀ ▐ ▚▄▌
-- ▘ ▘ ▘ ▀▘▘▝ ▘ ▝▀ ▝▀ ▘ ▘▐  ▀▘▗▄▘
-- vim: set foldmethod=marker path+=./lua:
