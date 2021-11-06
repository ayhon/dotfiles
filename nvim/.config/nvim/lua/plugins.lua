require'packer'.startup(function(use)
	-- `use` is not actually a parameter, but this way we get rid
	-- of linter warnings

	use 'wbthomason/packer.nvim' -- It manages itself!

	use 'neovim/nvim-lspconfig'
	use 'williamboman/nvim-lsp-installer'

	-- nvim-cmp and sources {{{
	use 'hrsh7th/nvim-cmp'
	-- sources {{{
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'

	use 'quangnguyen30192/cmp-nvim-ultisnips'
	use 'hrsh7th/cmp-calc'
	use 'hrsh7th/cmp-nvim-lua'
	-- }}} }}}

	use 'ray-x/lsp_signature.nvim'
	use{'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
	use 'scalameta/nvim-metals'
	use 'lukas-reineke/indent-blankline.nvim'

	if vim.fn.has('nvim-0.6') then
		use 'github/copilot.vim'
	end
end)
-- vim: set foldmethod=marker:
