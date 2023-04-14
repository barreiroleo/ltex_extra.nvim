<!-- LTeX: language=en-US -->
<div align="center">

# LTeX_extra.nvim
<h6>Provides external LTeX file handling (off-spec lsp) and other functions.</h6>
<h6>🚧 This plugin is on development, expect some changes</h6>
<h6>Developed on Nvim stable v0.8</h6>


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
        - [Lspsaga](#lspsaga)
    - [Custom export path](#custom-export-path)
    - [Autoload exported data](#autoload-exported-data)
    - [Update on demand](#update-on-demand)
- [Installation](#installation)
    - [Packer](#packer)
- [Configuration](#configuration)
- [To-do list](#to-do-list)

## Features
Cover your eyes. In the next demos there are many orthographic horrors.
Screencast recorded using my [macros](https://github.com/barreiroleo/macros) tool.

### Code Actions
Provide functions for `add to dictionary`, `disable rules` and `hidde false positives`.\
*Maybe you want mapping the LPS Code Action method.
Check the docs: [neovim suggested configuration](https://github.com/neovim/nvim-lspconfig#suggested-configuration)*

https://user-images.githubusercontent.com/48270301/177694689-b6b12b4a-3981-47fe-aa88-567697f797bd.mp4

#### Lspsaga
Some users reported an issue with code actions when called from lspsaga. I'm not using lspsaga, so PR are very welcome.

https://user-images.githubusercontent.com/39244876/201530888-077e76ad-211c-408f-80dc-89ba59751532.mov

_Thanks to @felipejoribeiro for the screenrecording_

### Custom export path
Config you path, give you compatibility with official vscode extension.

https://user-images.githubusercontent.com/48270301/177694714-2f9d7477-26b6-4bf5-a47e-63ce2f82d76a.mp4

### Autoload exported data
Autoload exported data for required languages.

https://user-images.githubusercontent.com/48270301/177694724-736159ab-c202-4325-ad23-405c76676b79.mp4

### Update on demand
Reload exported data on demand:

https://user-images.githubusercontent.com/48270301/177694740-bc8bdb4c-0f6b-4f63-98af-54ec23196f27.mp4

## Installation
This plugin requires an instance of `ltex_ls` language server attached in the current buffer.

*Note: [`ltex-ls`](https://github.com/valentjn/ltex-ls) is available by [`nvim-lsp-installer`](https://github.com/williamboman/nvim-lsp-installer).*

### Packer
```lua
use { "barreiroleo/ltex-extra.nvim" }
```

## Configuration
Install the plugin with your favorite plugin manager, then add `require("ltex_extra").setup()` to your config.
The plugin will set up the `ltex` language server for you (by calling the setup function of the server from `lspconfig` internally).
So **you don't manually `require("lspconfig").ltex.setup`, as it can cause conflicts**.

The configuration of the underlying `require("lspconfig").ltex.setup(...)` call is passed under the `server` key.
Below is an example configuration; default config values are in the comments.

*Notes: You can pass to set up only the arguments that you are interested in.
At the moment, if you define stuff in `dictionary`, `disabledRules` and `hiddenFalsePositives` in your `ltex` settings, they haven't backup.*

```lua
require("ltex_extra").setup{
    -- table <string> : languages for witch dictionaries will be loaded
    -- Default : {}
    load_langs = { "es-AR", "en-US" },
    -- boolean : whether to load dictionaries on startup
    -- default : true
    init_check = true,
    -- string : path to store dictionaries. Relative path are based off the current working directory
    -- Default : nil = the current working directory
    path = "~/.config/ltex",
    -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
    -- Default : "none"
    log_level = "none",
    -- table : configurations of the ltex language server
    server = {
        capabilities = your_capabilities,
        on_attach = function(client, bufnr)
            -- Your on_attach
        end,
        ltex = {
            -- your server settings
        }
    }
}
```

### Contributors

Thanks to these people for your time, effort and ideas.

<a href="https://github.com/barreiroleo/ltex_extra.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=barreiroleo/ltex_extra.nvim" />
</a>

## To-do list
- [ ] Write the docs.
- [x] Add capability for create dictionary, disabledRules and hiddenFalsePositives keys in LTeX settings.
- [x] Add path specification for files in setup.
- [x] Add capability for read the existing files in path.
- [ ] Abort initial load if the files doesn't exist.
