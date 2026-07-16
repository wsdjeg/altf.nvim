-- test/minimal_init.lua
-- Minimal Neovim configuration for testing

print('Initializing test environment...')

-- Set up essential settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false
vim.opt.verbose = 1

-- Set up package path for:
-- 1. lua/?.lua - Main plugin source code
-- 2. test/?.lua - Mock modules
-- 3. test/.deps/?.lua - Test dependencies (luaunit)
package.path = 'lua/?.lua;test/?.lua;test/.deps/?.lua;' .. package.path
vim.opt.runtimepath:prepend('.')

-- Create temporary test directory
local test_dir = vim.fn.tempname() .. '_altf_test'
vim.fn.mkdir(test_dir, 'p')

-- Override data path so altf cache goes to temp dir
vim.g.altf_test_cache = test_dir .. '/altf.json'

-- Load plugin
local ok, err = pcall(function()
	require('altf')
end)

if not ok then
	print('Error initializing test environment: ' .. err)
else
	print('Test environment initialized successfully')
	print('Test directory: ' .. test_dir)
end

