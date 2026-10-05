-- Highlight primitives shared by every painter in theme/groups.
local M = {}

function M.hi(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

function M.set(groups, opts)
	for _, group in ipairs(groups) do
		M.hi(group, opts)
	end
end

-- Blends two #rrggbb colours; used for the cursorline wash.
function M.mix(a, b, amount)
	local function channel(shift)
		local ca = tonumber(a:sub(shift, shift + 1), 16)
		local cb = tonumber(b:sub(shift, shift + 1), 16)
		if not ca or not cb then
			return "00"
		end
		return string.format("%02x", math.floor(ca + (cb - ca) * amount + 0.5))
	end
	return string.format("#%s%s%s", channel(2), channel(4), channel(6))
end

return M
