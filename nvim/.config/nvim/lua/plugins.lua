-- Helper functions {{{
-- local function gh(url) return string.match(url,"https://github.com/%g/%g") end
-- }}}
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

	use 'quangnguyen30192/cmp-nvim-ultisnips'
	use 'hrsh7th/cmp-nvim-lua'
	-- }}} }}}

	use{'folke/trouble.nvim',            requires ={'kyazdani42/nvim-web-devicons'}}
	use 'ray-x/lsp_signature.nvim'
	use{'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
	use 'lukas-reineke/indent-blankline.nvim'

	-- I just want a more convenient netrw, not completely replace its behaviour
	-- use{'kyazdani42/nvim-tree.lua', 	 requires ={'kyazdani42/nvim-web-devicons'}}
	-- fern.vim seems to be the solution

	use 'jbyuki/venn.nvim'

	use 'jamestthompson3/nvim-remote-containers'

	if vim.fn.has('nvim-0.6') then
		use 'github/copilot.vim'
		use{'nvim-telescope/telescope.nvim', requires ={'nvim-lua/plenary.nvim'}}
		use{'scalameta/nvim-metals',         requires ={'nvim-lua/plenary.nvim'}}
	end
end)
-- vim: set foldmethod=marker:
