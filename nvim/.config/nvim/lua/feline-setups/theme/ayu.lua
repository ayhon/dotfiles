local palette = {
	bg        = {dark= "#161616",  light= "#FAFAFA",  mirage= "#212733"};
	comment   = {dark= "#5C6773",  light= "#ABB0B6",  mirage= "#5C6773"};
	markup    = {dark= "#F07178",  light= "#F07178",  mirage= "#F07178"};
	constant  = {dark= "#FFEE99",  light= "#A37ACC",  mirage= "#D4BFFF"};
	operator  = {dark= "#E7C547",  light= "#E7C547",  mirage= "#80D4FF"};
	tag       = {dark= "#36A3D9",  light= "#36A3D9",  mirage= "#5CCFE6"};
	regexp    = {dark= "#95E6CB",  light= "#4CBF99",  mirage= "#95E6CB"};
	string    = {dark= "#B8CC52",  light= "#86B300",  mirage= "#BBE67E"};
	func     =  {dark= "#FFB454",  light= "#F29718",  mirage= "#FFD57F"};
	special   = {dark= "#E6B673",  light= "#E6B673",  mirage= "#FFC44C"};
	keyword   = {dark= "#FF7733",  light= "#FF7733",  mirage= "#FFAE57"};
	error     = {dark= "#FF3333",  light= "#FF3333",  mirage= "#FF3333"};
	accent    = {dark= "#F29718",  light= "#FF6A00",  mirage= "#FFCC66"};
	panel     = {dark= "#14191F",  light= "#FFFFFF",  mirage= "#272D38"};
	guide     = {dark= "#2D3640",  light= "#D9D8D7",  mirage= "#3D4751"};
	line      = {dark= "#151A1E",  light= "#F3F3F3",  mirage= "#242B38"};
	selection = {dark= "#253340",  light= "#F0EEE4",  mirage= "#343F4C"};
	fg        = {dark= "#E6E1CF",  light= "#5C6773",  mirage= "#D9D7CE"};
	fg_idle   = {dark= "#3E4B59",  light= "#828C99",  mirage= "#607080"};
}

local colors = {
	bg =       palette.bg,
    fg =       palette.fg,
    yellow =   palette.accent,
    cyan =     palette.regexp,
    darkblue = palette.panel,
    green =    palette.string,
    orange =   palette.func,
    violet =   palette.special,
    magenta =  palette.constant,
    blue =     palette.tag,
    red =      palette.error
}
----[[
local feline_colors = {
	bg =        colors.bg,
	black =     "#1B1B1B",
	cyan =      "#009090",
	fg =        "#D0D0D0",
	green =     "#60A040",
	magenta =   "#C26BDB",
	oceanblue = "#0066cc",
	orange =    "#FF9000",
	red =       "#D10000",
	skyblue =   "#50B0F0",
	violet =    "#9E93E8",
	white =     "#FFFFFF",
	yellow =    "#E1E120"
}
--]]

local function get_variant_colors()
	local obj = {}
	local variant = vim.g.ayuncolor
	for keyword, values in pairs(colors) do
		obj[keyword] = values[variant]
	end
	return obj
end

return {
	palette            = palette,
	colors             = colors,
	get_variant_colors = get_variant_colors
}

