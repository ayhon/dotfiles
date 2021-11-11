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
		-- Serious autocompletes
		{ name = 'nvim_lsp' },
		{ name = 'buffer' },
		{ name = 'path' },

		-- Joke-ish autocompletes
		{ name = 'ultisnips' },
		{ name = 'calc' },
		{ name = 'nvim_lua'}
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
local custom_lsp_attach = function(_) -- _ == client
	-- LSP mappings {{{4
	api.nvim_buf_set_keymap(0,'n','K','<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	api.nvim_buf_set_keymap(0,'n','<C-]>','<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	-- }}}4
	api.nvim_buf_set_option(0,'omnifunc', 'v:lua.vim.lsp.omnifunc')
	-- On-attach callbacks {{{4
	-- Perhaps this is needed, if not just eleminate
	-- require'lsp_signature'.on_attach(lsp_sign_settings)
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
	on_attach = custom_lsp_attach,
	capabilities = capabilities,
} -- }}}3
-- C/C++ completion options {{{3
require'lspconfig'.clangd.setup {
	capabilities = capabilities,
} -- }}}3
-- }}}2
-- }}}1
-- Indent-blank line {{{1
require'indent_blankline'.setup{
	char = '|',
	enabled = false,
}
v[[nnoremap <leader>il :IndentBlanklineToggle<CR>]]
-- }}}1
-- mappings {{{1
v[[tnoremap <A-c> <C-\><C-N>]]

v[[tnoremap <A-h> <C-\><C-N><A-h>]]
v[[tnoremap <A-j> <C-\><C-N><A-j>]]
v[[tnoremap <A-k> <C-\><C-N><A-k>]]
v[[tnoremap <A-l> <C-\><C-N><A-l>]]

v[[nnoremap <leader>tp :sp term://ipython3<CR><C-L>A]]
v[[nnoremap <leader>tl :sp term://lua<CR>A]]
-- }}}1
-- Autocommands {{{1

v[[
augroup lsp
	au!
	au FileType scala,sbt lua require("metals").initialize_or_attach({})
augroup end]]
-- }}}1
--       ▗               ▗▀▖▗
-- ▛▀▖▌ ▌▄ ▛▚▀▖ ▞▀▖▞▀▖▛▀▖▐  ▄ ▞▀▌
-- ▌ ▌▐▐ ▐ ▌▐ ▌ ▌ ▖▌ ▌▌ ▌▜▀ ▐ ▚▄▌
-- ▘ ▘ ▘ ▀▘▘▝ ▘ ▝▀ ▝▀ ▘ ▘▐  ▀▘▗▄▘
-- vim: set foldmethod=marker path+=./lua:
