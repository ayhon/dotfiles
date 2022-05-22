-- Helper functions {{{
-- local function gh(url) return string.match(url,"https://github.com/%g/%g") end
-- }}}
require'packer'.startup(function(use)
	-- `use` is not actually a parameter, but this way we get rid
	-- of linter warnings

	use 'wbthomason/packer.nvim' -- It manages itself!

	-- Added functionality {{{
	-- LSP {{{
	use 'neovim/nvim-lspconfig'
	use 'williamboman/nvim-lsp-installer'
	use{'folke/trouble.nvim',            requires ={'kyazdani42/nvim-web-devicons'}}
	use 'ray-x/lsp_signature.nvim'
	use 'sirver/ultisnips'
	-- nvim-cmp and sources {{{
	use 'hrsh7th/nvim-cmp'
	-- sources {{{
	use 'hrsh7th/cmp-nvim-lsp'

	use 'quangnguyen30192/cmp-nvim-ultisnips'
	use 'hrsh7th/cmp-nvim-lua'
	-- }}} }}}
	-- }}}
	-- File browser {{{
	use 'lambdalisue/nerdfont.vim'
	use 'lambdalisue/fern.vim'
	use 'lambdalisue/fern-hijack.vim'
	use 'lambdalisue/fern-renderer-nerdfont.vim'
	use 'yuki-yano/fern-preview.vim'
	-- }}}
	-- tpope {{{
	use 'tpope/vim-fugitive'
	use 'tpope/vim-commentary'
	use 'tpope/vim-surround'
	use 'tpope/vim-vinegar'
	-- }}}
	use 'christoomey/vim-tmux-navigator'
	use 'jbyuki/venn.nvim'
	use 'jamestthompson3/nvim-remote-containers'
	-- }}}

	-- Language support {{{
	-- Treesitter {{{
	use{'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
	use 'nvim-treesitter/playground'
	-- }}}

    use 'vim-syntastic/syntastic'

	use 'jtadley/vim-qasm'

	use 'bhurlow/vim-parinfer'
	use 'elkowar/yuck.vim'

	use 'JuliaEditorSupport/julia-vim'

	use 'tomlion/vim-solidity'

	use 'leafo/moonscript-vim'

	use{'plasticboy/vim-markdown',   {ft= {'markdown'}} }

	-- use 'python-rope/ropevim'

	use{'neovimhaskell/haskell-vim', {ft= {'haskell'}} }
	-- use{'Twinside/vim-haskellConceal', {ft={'haskell'}} }

	use 'evanleck/vim-svelte'
	use 'norcalli/nvim-colorizer.lua'
	-- use{'mattn/emmet-vim', {ft={'js','jsx','ts','tsx','html'}}  }
	-- }}}

	-- Appearance {{{
	-- Colorschemes {{{
	use 'flazz/vim-colorschemes'
	use 'folke/tokyonight.nvim'
	use 'protesilaos/tempus-themes-vim'
	-- }}}
	-- Interface {{{
	use 'lewis6991/gitsigns.nvim'
	use 'feline-nvim/feline.nvim'
	use 'markonm/traces.vim'
	use 'junegunn/goyo.vim'
	use 'lukas-reineke/indent-blankline.nvim'
	use 'psliwka/vim-smoothie'
	-- }}}
	-- }}}

	if vim.fn.has('nvim-0.6') then
		use 'github/copilot.vim'
		use{'nvim-telescope/telescope.nvim', requires ={'nvim-lua/plenary.nvim'}}
		use{'scalameta/nvim-metals',         requires ={'nvim-lua/plenary.nvim'}}
	end
end)
-- vim: set foldmethod=marker:
