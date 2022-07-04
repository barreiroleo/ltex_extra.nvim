<!-- LTeX: language=en-US -->
<div align="center">

# LTeX_extra.nvim
<h6>Provides external LTeX file handling (off-spec lsp) and other functions.</h6>
<h6>🚧 This plugins is currently on development, expect some changes</h6>
<h6>Developed on Nvim stable: Nightly 0.8 is working.</h6>


[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
<!-- [![Neovim Nightly](https://img.shields.io/badge/Neovim%20Nightly-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io) -->
</div>

`LTeX_extra` is a plugin for Neovim that provide the functions that are called on LSP code actions by `ltex-ls`: [`addToDictionary`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexhidefalsepositives-client),
[`disableRule`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexdisablerules-client),
[`hideFalsePositive`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexaddtodictionary-client).
Also, `LTeX_extra` provide extra [features](#features).


# Table of Contents
- [Features](#features)
    - [Code Actions](#code-actions)
    - [Autoload LTeX files](#autoload-ltex-files)
    - [Reload LTeX files](#reload-ltex-files)
- [Installation](#installation)
    - [Packer](#packer)
- [Configuration](#configuration)
- [To-do list](#to-do-list)

## Features
- [Code Actions](#code-actions): Export to external files the data of next actions.
    - Add to dictionary selected words.
    - Disable rules to check.
    - Hide false positives for selected cases.
- [Autoload LTeX files](#autoload-ltex-files): Autoload saved configs for a set required languages.
- [Reload LTeX files](#reload-ltex-files): On demand reload saved configs:

### Code Actions

https://user-images.githubusercontent.com/48270301/175837715-dc2d122e-5ffd-422d-a662-f9cdc19f85ec.mp4

### Autoload LTeX files
https://user-images.githubusercontent.com/48270301/175837717-1b2d3ba2-042c-4ae4-bf4c-ef2d1273c207.mp4

### Reload LTeX files
https://user-images.githubusercontent.com/48270301/175837718-21ae3ebf-0ee3-4fcf-9e4f-bd82516c3ebc.mp4

## Installation
This plugin requires an instance of `ltex_ls` language server attached in the current buffer.

*Note: [`ltex-ls`](https://github.com/valentjn/ltex-ls) is available by [`nvim-lsp-installer`](https://github.com/williamboman/nvim-lsp-installer).*

### Packer
```lua
use { "barreiroleo/ltex-extra.nvim" }
```

## Configuration
The recommended way to use `ltex-extra` is calling it from `ltex-ls` `on_attach` event.
Next example use `nvim-config` typical launch server and default settings for `ltex-extra`, you can use it as template.

*Notes: You can pass to set up only the arguments that you are interested in.
At the moment, if you define stuff in `dictionary`, `disabledRules` and `hiddenFalsePositives` in your `ltex` settings, they haven't backup.*

```lua
require("lspconfig").ltex.setup {
    on_attach = function(client, bufnr)
        --- your other on_attach functions.
        require("ltex_extra").setup{
            load_langs = {"es-AR", "en-US"},
            init_check = true,
        }
    end,
    capabilities = capabilities,
    settings = {
        ltex = {
            --- your settings.
        }
    }
}
```

## To-do list
- [x] Write the docs.
- [x] Add capability for create dictionary, disabledRules and hiddenFalsePositives keys in ltex settings.
- [ ] Add path specification for files in setup.
- [ ] Add capability for read the existing files in path.
- [ ] Abort initial load if the files doesn't exist.
