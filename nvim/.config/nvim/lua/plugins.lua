-- Helper functions {{{1
-- local function gh(url) return string.match(url,"https://github.com/%g/%g") end
local function use_if(version)
	if vim.fn.has('nvim-'..version) then
		return require'packer'.use
	end
end
-- }}}1
require'packer'.startup(function(use)
	use 'wbthomason/packer.nvim' -- It manages itself!
	-- Added functionality {{{1
	-- LSP {{{2
	use 'neovim/nvim-lspconfig'
	use{'folke/trouble.nvim',            requires ={'kyazdani42/nvim-web-devicons'}}
	use 'ray-x/lsp_signature.nvim'
	use 'sirver/ultisnips'
	-- nvim-cmp and sources {{{3
	use 'hrsh7th/nvim-cmp'
	-- sources {{{4
	use 'hrsh7th/cmp-nvim-lsp'
	use{'hrsh7th/cmp-nvim-lua',ft={'lua','vim'}}
	-- }}} 4
	-- }}}3
	-- }}}2
	-- Debugger {{{2
	use{'mfussenegger/nvim-dap', requires = {'nvim-lua/plenary.nvim'}}
	-- }}}2
	-- File browser {{{2
	use 'lambdalisue/nerdfont.vim'
	use 'lambdalisue/fern.vim'
	use 'lambdalisue/fern-hijack.vim'
	use 'lambdalisue/fern-renderer-nerdfont.vim'
	use 'yuki-yano/fern-preview.vim'
	use 'antoinemadec/FixCursorHold.nvim'
	-- }}}2
	-- tpope {{{2
	use 'tpope/vim-fugitive'
	use 'tpope/vim-commentary'
	use 'tpope/vim-surround'
	use 'tpope/vim-vinegar'
	-- }}}2
	use 'christoomey/vim-tmux-navigator'
	use 'jbyuki/venn.nvim'
	use 'jamestthompson3/nvim-remote-containers'
	use 'fidian/hexmode'
	use 'rootkiter/vim-hexedit'
	use{'mattn/emmet-vim', ft={'js','jsx','ts','tsx','html','svelte'}  }
	use 'tenxsoydev/size-matters.nvim'
	use 'jbyuki/nabla.nvim'
	use{'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}
	use 'jbyuki/ntangle.nvim'
	use 'bfredl/nvim-luadev'
	use {
		"nvim-neorg/neorg",
		config = function()
			require('neorg').setup {
				load = {
					["core.defaults"] = {}, -- Loads default behaviour
					["core.concealer"] = {}, -- Adds pretty icons to your documents
					["core.dirman"] = { -- Manages Neorg workspaces
						config = {
							workspaces = {
								pers = "~/Desktop/Notes/Personal/",
								ucppm = "~/Desktop/Notes/UCppM/",
							},
							default_workspace = "pers",
						},
					},
				},
			}
		end,
		run = ":Neorg sync-parsers",
		requires = "nvim-lua/plenary.nvim",
	}
	-- }}}1
	-- Language support {{{1
	-- Treesitter {{{2
	use{'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
	use 'nvim-treesitter/playground'
	-- }}}3
	-- Lisp like languages {{{2
	use{'bhurlow/vim-parinfer', ft={'lisp','yuck','scheme','clojure'}}
	use{'elkowar/yuck.vim',     ft='yuck'}
	-- }}}2
	-- Julia {{{2
	use 'JuliaEditorSupport/julia-vim'
	--}}}2
	-- Solidity {{{2
	use{'tomlion/vim-solidity', ft='solidity'}
	-- }}}2
	-- Moonscript {{{2
	use{'leafo/moonscript-vim', ft='moon'}
	-- }}}2
	-- Svelte {{{2
	use{'evanleck/vim-svelte',  ft='svelte'}
	-- }}}2
	-- Scala {{{2
	use_if'0.6' {'scalameta/nvim-metals', requires ={'nvim-lua/plenary.nvim'}}
	-- }}}2
	-- Coq {{{2
	use{'whonore/Coqtail', ft="coq"}
	-- }}}2
	-- Rust {{{2
	use{'simrat39/rust-tools.nvim', requires = {'neovim/nvim-lspconfig', 'mfussenegger/nvim-dap'}}
	-- }}}2
	-- }}}1
	-- Appearance {{{1
	-- Colorschemes {{{2
	-- use 'flazz/vim-colorschemes'
	use 'Shatur/neovim-ayu'
	-- }}}2
	-- Interface {{{2
	use 'lewis6991/gitsigns.nvim' -- Gitsign
	use 'feline-nvim/feline.nvim' -- Bar
	use 'markonm/traces.vim'
	use 'junegunn/goyo.vim'
	use 'lukas-reineke/indent-blankline.nvim'
	use 'psliwka/vim-smoothie'	  -- Smooth scroll
	use 'norcalli/nvim-colorizer.lua' -- Colorize hex values representing colors
	use_if'0.6' {'nvim-telescope/telescope.nvim', requires ={'nvim-lua/plenary.nvim'}}
	-- }}}2
	-- }}}1
end)
-- vim: set foldmethod=marker foldlevel=0:
