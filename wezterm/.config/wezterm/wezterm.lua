-- local wezterm = require 'wezterm';
-- Documentation at https://wezfurlong.org/wezterm/index.html

local darkmode = { -- {{{
		foreground = "#c2c2c2",
		background = "#222222",

		cursor_fg = "#ffda2e",
		cursor_bg = "#555555",

		cursor_border = "#555555",

		selection_fg = "#ffffff",
		selection_bg = "#444444",

		-- scrollbar_thumb = "",

		-- split = "",

		ansi = {
			"#171421", -- Black
			"#ff2b3a", -- Red
			"#00ff57", -- Green
			"#f9cb1b", -- Yellow
			"#2586ff", -- Dark blue
			"#cc00ff", -- Purple
			"#00ffe0", -- Cyan
			"#c0c0b8", -- Grey
		},
		-- brights = {},
		-- indexed = {},
} -- }}}
local lightmode = { -- {{{
		foreground = "#3D3D3B",
		background = "#EBEBEB",

		cursor_fg = "#ffda2e",
		cursor_bg = "#555555",

		cursor_border = "#555555",

		selection_fg = "#ffffff",
		selection_bg = "#444444",

		-- scrollbar_thumb = "",

		-- split = "",

		ansi = {
			"#1B1B1B", -- Black
			"#B90C19", -- Red
			"#437C1F", -- Green
			"#F69918", -- Yellow
			"#0B4DB4", -- Dark blue
			"#550089", -- Purple
			"#05727D", -- Cyan
			"#CDCDCD", -- Grey
		}
} -- }}}
local config = {
	enable_tab_bar = false,
	colors = darkmode,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}
}

return config
-- vim: set fdm=marker:
