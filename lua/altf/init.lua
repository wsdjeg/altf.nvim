--=============================================================================
-- a.lua --- alternate plugin for SpaceVim
-- Copyright (c) 2016-2023 Wang Shidong & Contributors
-- Author: Wang Shidong < wsdjeg@outlook.com >
-- URL: https://spacevim.org
-- License: GPLv3
--=============================================================================

local M = {}
local ok, toml = pcall(require, "toml")
if not ok then
	toml = nil
end
local fn = vim.fn

local util = require("altf.util")

local alternate_conf = {}
alternate_conf["_"] = ".project_alt.json"

local cache_path = vim.fn.stdpath("data") .. "/altf.json"

local project_config = {}

local function cache()
	util.debug("write cache into file:" .. cache_path)
	local ok, errors = pcall(fn.writefile, { vim.json.encode(project_config) }, cache_path)
	if not ok then
		util.debug("cache failed!")
	else
		util.debug("cache succeeded!")
	end
end

local function get_type_path(a, f, b)
	local begin_len = fn.strlen(a[1])
	local end_len = fn.strlen(a[2])
	local r = fn.substitute(b, "{}", string.sub(f, begin_len + 1, (end_len + 1) * -1), "g")
	return r
end

local function load_cache()
	util.info("load project alternate conf cache from:" .. cache_path)
	local cache_context = fn.join(fn.readfile(cache_path, ""), "")
	if cache_context ~= "" then
		project_config = vim.json.decode(cache_context)
	end
end

function M.set_config_name(path, name)
	alternate_conf[path] = name
end

function M.alt(request_parse, ...)
	local argvs = ...
	local alt_type = "alternate"
	if argvs ~= nil then
		alt_type = argvs[1] or alt_type
	end
	local alt = nil
	if fn.exists("b:alternate_file_config") ~= 1 then
		local conf_file_path = M.getConfigPath()
		if vim.fn.filereadable(conf_file_path) ~= 1 then
			util.notify("no alternate config file!", "WarningMsg")
			return
		end
		local file = util.unify_path(fn.bufname("%"), ":.")
		alt = M.get_alt(file, conf_file_path, request_parse, alt_type)
	end
	if alt ~= nil and alt ~= "" then
		util.info("  > found alternate file: " .. alt)
		vim.cmd("e " .. alt)
	else
		util.info("  > failed to find alternate file")
		util.notify("failed to find alternate file!", "WarningMsg")
	end
end

local function get_project_config(conf_file)
	local conf
	if conf_file:sub(-4) == "toml" then
		if toml then
			conf = toml.parse_file(conf_file)
		end
	else
		conf = vim.json.decode(fn.join(fn.readfile(conf_file), "\n"))
	end
	if type(conf) ~= "table" then
		conf = {}
	else
		util.debug(vim.inspect(conf))
	end
	local root = util.unify_path(conf_file, ":p:h")
	return {
		["root"] = root,
		["config"] = conf,
	}
end

-- we need to sort the keys in config
--

local function _keys(val)
	local new_keys = {}
	for k, v in pairs(val) do
		table.insert(new_keys, k)
	end
	return new_keys
end
local function _comp(a, b)
	if string.match(a, "*") == "*" and string.match(b, "*") == "*" then
		return #a < #b
	elseif string.match(a, "*") == "*" then
		return true
	elseif string.match(b, "*") == "*" then
		return false
	else
		local _, al = string.gsub(a, "/", "")
		local _, bl = string.gsub(b, "/", "")
		return al < bl
	end
end

local function parse(alt_config_json)
	util.info("parse alternate file for:" .. alt_config_json.root)
	project_config[alt_config_json.root] = {}
	local keys = _keys(alt_config_json.config)
	table.sort(keys, _comp)
	for _, key in pairs(keys) do
		local searchpath = key
		if string.match(searchpath, "*") == "*" then
			searchpath = string.gsub(searchpath, "*", "**/*")
		end
		for _, file in pairs(vim.fn.globpath(".", searchpath, 0, 1)) do
			file = util.unify_path(file, ":.")
			project_config[alt_config_json.root][file] = {}
			if alt_config_json.config[file] ~= nil then
				for alt_type, type_v in pairs(alt_config_json.config[file]) do
					project_config[alt_config_json.root][file][alt_type] = type_v
				end
			else
				for a_type, _ in pairs(alt_config_json.config[key]) do
					local begin_end = fn.split(key, "*")
					if #begin_end == 2 then
						project_config[alt_config_json.root][file][a_type] =
							get_type_path(begin_end, file, alt_config_json.config[key][a_type])
					end
				end
			end
		end
	end
	cache()
end

local function is_config_changed(conf_path)
	if fn.getftime(conf_path) > fn.getftime(cache_path) then
		return true
	else
		return false
	end
end

function M.get_alt(file, conf_path, request_parse, a_type)
	util.info("getting alt file for:" .. file)
	util.info("  >   type: " .. a_type)
	util.info("  >  parse: " .. request_parse)
	util.info("  > config: " .. conf_path)
	alt_config_json = get_project_config(conf_path)
	if project_config[alt_config_json.root] == nil and not is_config_changed(conf_path) and request_parse == 0 then
		load_cache()
		if project_config[alt_config_json.root] == nil or project_config[alt_config_json.root][file] == nil then
			parse(alt_config_json)
		end
	else
		parse(alt_config_json)
	end
	if
		project_config[alt_config_json.root] ~= nil
		and project_config[alt_config_json.root][file] ~= nil
		and project_config[alt_config_json.root][file][a_type] ~= nil
	then
		return project_config[alt_config_json.root][file][a_type]
	else
		return ""
	end
end

function M.getConfigPath()
	local pwd = fn.getcwd()
	local p = alternate_conf["_"]
	if alternate_conf[pwd] ~= nil then
		p = alternate_conf[pwd]
	end
	return util.unify_path(p, ":p")
end

function M.complete(arglead, cmdline, cursorpos)
	local file = util.unify_path(fn.bufname("%"), ":.")
	local conf_file_path = M.getConfigPath()
	if vim.fn.filereadable(conf_file_path) == 0 then
		return ""
	end
	local alt_config_json = get_project_config(conf_file_path)

	M.get_alt(file, conf_file_path, 0, "")
	local a = project_config[alt_config_json.root][file]
	if a ~= nil then
		return fn.join(fn.keys(a), "\n")
	else
		return ""
	end
end

return M
