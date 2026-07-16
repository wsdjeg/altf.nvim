local lu = require('luaunit')
local altf = require('altf')
local util = require('altf.util')

TestExample = {}

function TestExample:test_module_loaded()
	lu.assertNotNil(altf)
	lu.assertNotNil(altf.alt)
	lu.assertNotNil(altf.get_alt)
	lu.assertNotNil(altf.set_config_name)
	lu.assertNotNil(altf.getConfigPath)
	lu.assertNotNil(altf.complete)
end

function TestExample:test_util_unify_path()
	-- Basic path normalization
	local result = util.unify_path('/foo/bar/baz', ':p')
	lu.assertEquals(result, '/foo/bar/baz')
end

function TestExample:test_set_config_name_and_get_config_path()
	altf.set_config_name('/test/path', '.custom_alt.json')
	-- getConfigPath uses the current working directory by default
	-- so we just verify the function doesn't error
	lu.assertStr(altf.getConfigPath())
	-- Reset to default
	altf.set_config_name('_', '.project_alt.json')
end

return TestExample

