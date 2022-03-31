-- Constants and aliases {{{1
local v = vim.cmd
local api = vim.api
-- }}}1
v [[source ~/.vim/vimrc]]
require 'plugins'
-- nvim-lsp settings {{{1
-- nvim-cmp {{{2
local cmp = require 'cmp'
local cmap = cmp.mapping

cmp.setup{
	snippet = { -- {{{3
		expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end
	}, -- }}}3
	mapping = { -- {{{3
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
	}, -- }}}3
	sources = cmp.config.sources{ -- {{{3
		{ name = 'nvim_lsp' },
		{ name = 'nvim_lua' },
		{ name = 'ultisnips'},
	}, -- }}}3
	completion = { -- {{{3
		autocomplete = false
	}, -- }}}3
}

-- Updated capabilities
local capabilities = require'cmp_nvim_lsp'.update_capabilities(
	vim.lsp.protocol.make_client_capabilities()
)
-- }}}2
-- lsp-signature settings {{{2
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
-- }}}2
-- treesitter settings {{{2
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
-- }}}2
-- nvim-lspconfig {{{2
-- Custom attach function {{{3
local custom_lsp_attach = function(_, bufnr) -- _ == client
	-- LSP mappings {{{4
    print(bufnr)
	local opts = { noremap=true, silent=true }
	vim.api.nvim_buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	vim.api.nvim_buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	-- }}}4
	local function option(...) vim.api.nvim_buf_set_option(bufnr,...) end
	option('omnifunc', 'v:lua.vim.lsp.omnifunc')
	-- On-attach callbacks {{{4
	-- }}}4
end -- }}}3
-- Python completion options {{{3
require'lspconfig'.pyright.setup{
	capabilities = capabilities,
} -- }}}3
-- Lua completion options {{{3
-- Figurint out executable path and other variables {{{4
local system_name = 'Linux'
local sumneko_root_path = '/home/ayhon/git/lua-language-server/'
local sumneko_binary = string.format("%s/bin/%s/lua-language-server",
	sumneko_root_path,            -- sumneko root path
	system_name                   -- System name
)
-- }}}4
require'lspconfig'.sumneko_lua.setup{
	cmd = {sumneko_binary,"-E",sumneko_root_path.."/main.lua"},
	settings = {
		Lua = { -- {{{4
			runtime = { -- {{{5
				version = 'LuaJIT',
				path = vim.split(package.path, ';'),
			}, -- }}}5
			diagnostics = { -- {{{5
				globals = {'vim','love'},
			}, -- }}}5
			workspace = { -- {{{5
				preloadFileSize = 300,
				library = {
					-- Make server aware of nvim runtime files
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
					-- Emmy Love API
					[vim.fn.expand('$HOME/.config/love-autocomplete')] = true,
				},
			}, -- }}}5
			telemetry = { -- {{{5
				enable = false,
			}, -- }}}5
		}, -- }}}4
	},
	-- on_attach = custom_lsp_attach,
	capabilities = capabilities,
} -- }}}3
-- C/C++ completion options {{{3
require'lspconfig'.clangd.setup {
	capabilities = capabilities,
} -- }}}3
-- HDL completion options{{{3
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

-- }}}3
-- Haskell completion options {{{3
local util = require 'lspconfig/util'
local root_patterns = {"*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml"}
require'lspconfig'.hls.setup{
	root_dir = function(fname)
		return util.root_pattern(table.unpack(root_patterns))(fname) or util.path.dirname(fname)
	end,
    capabilities = capabilities
}
-- }}}3
-- Svelte completion options{{{3
require'lspconfig'.svelte.setup{
	capabilities = capabilities
}
-- }}}3
-- Solidity completion options 3{{{
require'lspconfig'.solidity_ls.setup{
	root_dir = function(fname)
        return require'lspconfig'.util.find_git_ancestor(fname)
          or require'lspconfig'.util.find_node_modules_ancestor(fname)
          or require'lspconfig'.util.find_package_json_ancestor(fname)
          or vim.loop.cwd()
      end
}
-- }}}3
-- }}}2
-- }}}1
-- plugin options {{{1
-- venn.nvim {{{2
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
-- }}}2
-- Indent-blank line {{{2
require'indent_blankline'.setup{
	char = '|',
	enabled = false,
}
v[[nnoremap <leader>il :IndentBlanklineToggle<CR>]]
-- }}}2
-- nvim-tree.lua {{{2
-- require'nvim-tree'.setup{}
-- }}}2
-- }}}1
-- mappings {{{1
v[[tnoremap <A-c> <C-\><C-N>]]

v[[tnoremap <A-h> <C-\><C-N><A-h>]]
v[[tnoremap <A-j> <C-\><C-N><A-j>]]
v[[tnoremap <A-k> <C-\><C-N><A-k>]]
v[[tnoremap <A-l> <C-\><C-N><A-l>]]

v[[nnoremap <leader>tt :TroubleToggle<CR>]]
v[[nnoremap gh :diffget //2<CR>]]
v[[nnoremap gl :diffget //3<CR>]]

local function keymap(...) vim.api.nvim_set_keymap(...) end
local opts = { noremap=true, silent=true }
keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
keymap('n', '<space>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
keymap('n', '<space>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
-- }}}1
-- autocommands {{{1

v[[
augroup lsp
	au!
	au FileType scala,sbt lua require("metals").initialize_or_attach({})
augroup end]]
-- }}}1
-- Neovide settings {{{1
if vim.g.neovide then
    -- vim.g.smoothie_enabled = false
    vim.g.neovide_cursor_animation_leght=0.13
    vim.g.neovide_cursor_trail_length=0.8
    vim.g.neovide_fullscreen=true
    vim.g.neovide_cursor_vfx_mode = "sonicboom"
    -- vim.g.neovide_cursor_vfx_mode = "railgun"
end
-- vim.g.neovide_
-- }}}1
--       ▗               ▗▀▖▗
-- ▛▀▖▌ ▌▄ ▛▚▀▖ ▞▀▖▞▀▖▛▀▖▐  ▄ ▞▀▌
-- ▌ ▌▐▐ ▐ ▌▐ ▌ ▌ ▖▌ ▌▌ ▌▜▀ ▐ ▚▄▌
-- ▘ ▘ ▘ ▀▘▘▝ ▘ ▝▀ ▝▀ ▘ ▘▐  ▀▘▗▄▘
-- vim: set foldmethod=marker path+=./lua:
