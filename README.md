# altf.nvim

<!-- vim-markdown-toc GFM -->

- [Intro](#intro)
- [Custom alternate file](#custom-alternate-file)

<!-- vim-markdown-toc -->
## Intro

altf.nvim is a neovim plugin to manager alternate files in project.

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

Instead of using json file, the alternate file manager also support `.project_alt.toml` file, for example:

Note: if you want to use toml file, you need to install `wsdjeg/toml.nvim`

```toml
["autoload/SpaceVim/layers/lang/*.vim"]
    # You can use comments in toml file.
    doc = "docs/layers/lang/{}.md"
    test = "test/layer/lang/{}.vader"
```

If you do not want to use configuration file,
or want to override the default configuration in alternate config file, `b:alternate_file_config`
can be used in bootstrap function, for example:

```vim
augroup myspacevim
    autocmd!
    autocmd BufNewFile,BufEnter *.c let b:alternate_file_config = {
        \ "src/*.c" : {
            \ "doc" : "docs/{}.md",
            \ "alternate" : "include/{}.h",
            \ }
        \ }
    autocmd BufNewFile,BufEnter *.h let b:alternate_file_config = {
        \ "include/*.h" : {
            \ "alternate" : "scr/{}.c",
            \ }
        \ }
augroup END
```
