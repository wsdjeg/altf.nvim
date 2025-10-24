local M = {}

local nt
local log

function M.notify(msg)
	if not nt then
		pcall(function()
			nt = require("notify")
		end)
	end
	if not nt then
		return
	end
	nt.notify(msg)
end

function M.info(msg)
	if not log then
		pcall(function()
			log = require("logger").derive("picker")
		end)
	end
	if not log then
		return
	end
	log.info(msg)
end
function M.debug(msg)
	if not log then
		pcall(function()
			log = require("logger").derive("picker")
		end)
	end
	if not log then
		return
	end
	log.debug(msg)
end

local is_win = vim.fn.has('win32') == 1
M.unify_path = function(_path, ...)
  local mod = select(1, ...)
  if mod == nil then
    mod = ':p'
  end
  local path = vim.fn.fnamemodify(_path, mod .. ':gs?[\\\\/]?/?')
  if is_win then
    local re = vim.regex('^[a-zA-Z]:/')
    if re:match_str(path) then
      path = string.upper(string.sub(path, 1, 1)) .. string.sub(path, 2)
    end
  end
  if vim.fn.isdirectory(path) == 1 and string.sub(path, -1) ~= '/' then
    return path .. '/'
  elseif string.sub(_path, -1) == '/' and string.sub(path, -1) ~= '/' then
    return path .. '/'
  else
    return path
  end
end

return M
