local function get_visual_selection()
	local firstline = vim.api.nvim_buf_get_mark(0,'<')[1]
	local lastline  = vim.api.nvim_buf_get_mark(0,'>')[1]
	return vim.fn.getline(firstline,lastline), firstline, lastline
end

local function get_maxpos_from_visual_selection(sep)
	local section = get_visual_selection()
	local maxpos  = 0
	for _,line in ipairs(section) do
		local pos = line:find('%s*('..sep..')')
		maxpos = math.max(pos,maxpos)
		if maxpos < pos then
			maxpos = pos
		end
	end
	return maxpos
end

function AlignSection(regex) -- range
	local extra  = 1
	local sep    = regex or '='
	local maxpos = get_maxpos_from_visual_selection(sep)
	local lines  = {}
	local _,firstline,lastline = get_visual_selection()
	for _,line in ipairs() do
		lines[#lines+1] = AlignLine(line,sep,maxpos,extra)
	end
	vim.api.nvim_buf_set_lines(0,firstline,lastline, true, lines)
end

function AlignLine(line,sep,maxpos,extra)
	local lhs = line:match('(.-%)s-'..sep..'.*')
	local rhs = line:match( '._%s-('..sep..'.*)')
	if not lhs then
		return line
	else
		local spaces = string.rep(' ', maxpos - #lhs + extra)
		return lhs .. spaces .. rhs
	end
end

return {
	align_by_equals = AlignSection,
	align_by_search_pattern = function()
		local search_pattern = vim.api.nvim_buf_get_mark(0, '/')
		AlignSection(search_pattern)
	end,
}
