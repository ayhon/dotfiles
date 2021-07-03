source ~/.vim/vimrc
" LSP configuration {{{
if has('nvim-0.5') " Surrounds this whole section
lua << EOF
	local util = require'lspconfig/util'

	-- completion.nvim settings {{{
	vim.cmd('let g:completion_enable_auto_popup = 0')
	vim.cmd('let g:completion_enable_auto_signature = 0')
	vim.api.nvim_set_keymap('i', '<C-p>', '<Plug>(completion_trigger)', {silent = true})
	-- }}}
	-- lsp-signature settings {{{
	lsp_signature_settings = {
		bind = true, -- This is mandatory, otherwise border config won't get registered.
					 -- If you want to hook lspsaga or other signature handler, pls set to false
		doc_lines = 2, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
					   -- set to 0 if you DO NOT want any API comments be shown
					   -- This setting only take effect in insert mode, it does not affect signature help in normal
					   -- mode, 10 by default

		floating_window = false, -- show hint in a floating window, set to false for virtual text only mode
		fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
		hint_enable = true, -- virtual hint enable
		hint_prefix = "🐼 ",  -- Panda for parameter
		hint_scheme = "String",
		use_lspsaga = false,  -- set to true if you want to use lspsaga popup
		hi_parameter = "Search", -- how your parameter will be highlight
		max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
						 -- to view the hiding contents
		max_width = 120, -- max_width of signature floating_window, line will be wrapped if exceed max_width
		handler_opts = {
			border = "shadow"   -- double, single, shadow, none
		},
		extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
								  -- deprecate !!
								  -- decorator = {"`", "`"}  -- this is no longer needed as nvim give me a handler and it allow me to highlight active parameter in floating_window
	}
	require'lsp_signature'.on_attach(lsp_signature_settings)
	--}}}
	-- Treesitter settings {{{
	require'nvim-treesitter.configs'.setup {
		ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
		ignore_install = {}, -- List of parsers to ignore installing
		highlight = {
			enable = true,              -- false will disable the whole extension
			disable = {},  -- list of language that will be disabled
		},
		indent = {
			enable = true,
		},
	}
	--}}}
	-- nvim-lspconfig settings {{{

	local custom_lsp_attach = function(client)
		-- See `:help nvim_buf_set_keymap()` for more information
		vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
		vim.api.nvim_buf_set_keymap(0, 'n', '<c-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
		-- ... and other keymappings for LSP

		-- Use LSP as the handler for omnifunc.
		vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- For plugins with an `on_attach` callback, they are called here
		require'completion'.on_attach()
		require'lsp_signature'.on_attach(lsp_signature_settings)
	end

	-- Python completion options {{{
	require'lspconfig'.pyright.setup{
		cmd = {'/home/ayhon/.npm/_npx/3699d080662ea149/node_modules/.bin/pyright-langserver', '--stdio'},
	    --        cmd = {'~/.npm/_npx/3699d080662ea149/node_modules/.bin/pyright-langserver', '--stdio'},
		filetypes = {"python"},
		root_dir = util.root_pattern(".git", "setup.py",  "setup.cfg", "pyproject.toml", "requirements.txt"),
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
				},
			},
		}
		--cmd = { "pyright" },
		--filetypes = { "python" },
		--root_dir = function(filename)
			  --return util.root_pattern(unpack(root_files))(filename) or
					 --util.path.dirname(filename)
			--end;
		--settings = {
		  --python = {
			--analysis = {
			  --autoSearchPaths = true,
			  --diagnosticMode = "workspace",
			  --useLibraryCodeForTypes = true,
			--}
		  --}
		--}
	}
	-- }}}
	-- Lua completion options {{{
	-- set the path to the sumneko installation
	local system_name = "Linux" -- (Linux, macOS, or Windows)
	local sumneko_root_path = "/home/ayhon/git/lua-language-server"
	local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-server"

	require'lspconfig'.sumneko_lua.setup{
		cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
		-- An example of settings for an LSP server.
		-- For more options, see nvim-lspconfig
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
					-- Setup your lua path
					path = vim.split(package.path, ';'),
					},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = {'vim','love'},
					},
				workspace = {
					-- Set the default file size to 300KB
					preloadFileSize = 300,
					-- Make the server aware of Neovim runtime files
					library = {
						[vim.fn.expand('$VIMRUNTIME/lua')] = true,
						[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,

						-- Also add the Emmy Love API (https://github.com/26F-Studio/Emmy-love-api)
						[vim.fn.expand('/home/ayhon/.config/love-autocomplete')] = true,
						},
					},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			}
		},
		on_attach = custom_lsp_attach
	}
	-- }}}
	-- C/C++ completin options {{{
	require'lspconfig'.ccls.setup{
		cmd = { "ccls" },
		filetypes = { "c", "cpp" },
		root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git") or vim.fn.getcwd(),
		root_dir = function(fname)
			return util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname) or util.path.dirname(fname)
		end,
		init_options = {
			compilationDatabaseDirectory = "build",
			index = {
				threads = 0
			},
			clang = {
				excludeArgs = {"-frounding-math"}
			}
		},
	}
	--}}}
	-- }}}
EOF
endif
" }}}
" mappings {{{
tnoremap <A-c> <C-\><C-N>
nnoremap <leader>tp :sp term://ipython3<CR><C-L>A
nnoremap <leader>tl :sp term://lua<CR>A
" }}}
"       ▗               ▗▀▖▗    
" ▛▀▖▌ ▌▄ ▛▚▀▖ ▞▀▖▞▀▖▛▀▖▐  ▄ ▞▀▌
" ▌ ▌▐▐ ▐ ▌▐ ▌ ▌ ▖▌ ▌▌ ▌▜▀ ▐ ▚▄▌
" ▘ ▘ ▘ ▀▘▘▝ ▘ ▝▀ ▝▀ ▘ ▘▐  ▀▘▗▄▘
" vim: set foldmethod=marker:
