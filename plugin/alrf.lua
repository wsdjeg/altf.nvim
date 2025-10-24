vim.api.nvim_create_user_command("A", function(opt)
	require("altf").alt(opt.bang, opt.fargs)
end, {
	nargs = "*",
	complete = function(a, b, c)
		return require("altf").complete(a, b, c)
	end,
})
