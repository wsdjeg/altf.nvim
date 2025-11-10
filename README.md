# altf.nvim

altf.nvim is a project alternate file manager for neovim.

[![GitHub License](https://img.shields.io/github/license/wsdjeg/altf.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/altf.nvim)](https://github.com/wsdjeg/altf.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/altf.nvim)](https://github.com/wsdjeg/altf.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/altf.nvim)](https://github.com/wsdjeg/altf.nvim/releases)

<!-- vim-markdown-toc GFM -->

- [Intro](#intro)
- [Installation](#installation)
- [Custom alternate file](#custom-alternate-file)
    - [Using toml alternate configuration](#using-toml-alternate-configuration)
    - [Using buffer scoped variable](#using-buffer-scoped-variable)

<!-- vim-markdown-toc -->
## Intro

altf.nvim is a neovim plugin to manager alternate files in project.
And it is next version of [a.lua](https://github.com//wsdjeg/SpaceVim/blob/eed9d8f14951d9802665aa3429e449b71bb15a3a/lua/spacevim/plugin/a.lua#L1) in SpaceVim.

## Installation

- use [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require("plug").add({
	{
		"wsdjeg/altf.nvim",
	},
})
```

## Custom alternate file

To manage the alternate file of the project, you need to create a `.project_alt.json` file
in the root of your project. Then you can use the command `:A` to jump to the alternate file of
current file. You can also specific the type of alternate file, for example `:A doc`.
With a bang `:A!`, SpaceVim will parse the configuration file additionally. If no type is specified,
the default type `alternate` will be used.

here is an example of `.project_alt.json`:

```json
{
  "autoload/SpaceVim/layers/lang/*.vim": {
    "doc": "docs/layers/lang/{}.md",
    "test": "test/layer/lang/{}.vader"
  }
}
```

### Using toml alternate configuration

```lua
require('altf').set_config_name(vim.fn.getcwd(), '.project_alt.toml')
```

Instead of using json file, the alternate file manager also support `.project_alt.toml` file, for example:

Note: if you want to use toml file, you need to install `wsdjeg/toml.nvim`

```toml
["autoload/SpaceVim/layers/lang/*.vim"]
    # You can use comments in toml file.
    doc = "docs/layers/lang/{}.md"
    test = "test/layer/lang/{}.vader"
```

### Using buffer scoped variable

If you do not want to use configuration file,
or want to override the default altf configuration, setup `b:alternate_file_config` for the buffer.
for example:

```lua
local augroup = vim.api.nvim_create_augroup("altf-custom", { clear = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufEnter" }, {
	pattern = { "*.c" },
	group = augroup,
	callback = function(ev)
		vim.api.nvim_buf_set_var(ev.buf, "alternate_file_config", {
			["src/*.c"] = {
				doc = "docs/{}.md",
				alternate = "include/{}.h",
			},
		})
	end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufEnter" }, {
	pattern = { "*.h" },
	group = augroup,
	callback = function(ev)
		vim.api.nvim_buf_set_var(ev.buf, "alternate_file_config", {
			["include/*.h"] = {
				alternate = "src/{}.c",
			},
		})
	end,
})
```
