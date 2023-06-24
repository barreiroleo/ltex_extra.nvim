<!-- LTeX: language=en-US -->
<div align="center">

# LTeX_extra.nvim
<h6>Provides external LTeX file handling (off-spec lsp) and other functions.</h6>
<h6>🚧 This plugin is on development, expect some changes</h6>
<h6>Developed on Nvim v0.9, tested on v0.10</h6>


[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
<!-- [![Neovim Nightly](https://img.shields.io/badge/Neovim%20Nightly-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io) -->
</div>

`LTeX_extra` is a plugin for Neovim that provide the functions that are called on LSP code actions by `ltex-ls`:
[`addToDictionary`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexhidefalsepositives-client),
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

### Custom export path
Config you path, give you compatibility with official vscode extension.

https://user-images.githubusercontent.com/48270301/177694714-2f9d7477-26b6-4bf5-a47e-63ce2f82d76a.mp4

### Autoload exported data
Autoload exported data for required languages.

https://user-images.githubusercontent.com/48270301/177694724-736159ab-c202-4325-ad23-405c76676b79.mp4

### Update on demand
Reload exported data on demand: `require("ltex_extra").reload()`

https://user-images.githubusercontent.com/48270301/177694740-bc8bdb4c-0f6b-4f63-98af-54ec23196f27.mp4

## Installation
This plugin requires an instance of `ltex_ls` language server available to attach.
*[`ltex-ls`](https://github.com/valentjn/ltex-ls) is available at [`mason.nvim`](https://github.com/williamboman/mason.nvim).*

Install the plugin with your favorite plugin manager using `{"barreiroleo/ltex-extra.nvim"}`.
Then add `require("ltex_extra").setup()` to your config in a proper place.

We suggest to you two ways:
- Call the `setup` from `on_attach` function of your server. Example with
`lspconfig`, minor changes are required for `mason` handler:
    ```lua
    require("lspconfig").ltex.setup {
        capabilities = your_capabilities,
        on_attach = function(client, bufnr)
            -- rest of your on_attach process.
            require("ltex_extra").setup { your_opts }
        end,
        settings = {
            ltex = { your settings }
        }
    }
    ```
- Use the handler which `ltex_extra` provide to call the server. Example of use with `lazy.nvim`:

    ```lua
    return {
        "barreiroleo/ltex_extra.nvim",
        ft = { "markdown", "tex" },
        dependencies = { "neovim/nvim-lspconfig" },
        -- yes, you can use the opts field, just I'm showing the setup explicitly
        config = function()
            require("ltex_extra").setup {
                your_ltex_extra_opts,
                server_opts = {
                    capabilities = your_capabilities,
                    on_attach = function(client, bufnr)
                        -- your on_attach process
                    end,
                    settings = {
                        ltex = { your settings }
                    }
                },
            }
        end
    }
    ```

## Configuration

Here are the settings available on `ltex_extra`. You don't need explicit define each
one, just modify what you need.

*Notes: You can pass to set up only the arguments that you are interested in.
At the moment, if you define stuff in `dictionary`, `disabledRules` and
`hiddenFalsePositives` in your `ltex` settings, they haven't backup.*

```lua
require("ltex_extra").setup {
    -- table <string> : languages for witch dictionaries will be loaded, e.g. { "es-AR", "en-US" }
    -- https://valentjn.github.io/ltex/supported-languages.html#natural-languages
    load_langs = {}, -- en-US as default
    -- boolean : whether to load dictionaries on startup
    init_check = true,
    -- string : relative or absolute path to store dictionaries
    -- e.g. subfolder in the project root or the current working directory: ".ltex"
    -- e.g. shared files for all projects:  vim.fn.expand("~") .. "/.local/share/ltex"
    path = "", -- project root or current working directory
    -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
    log_level = "none",
    -- table : configurations of the ltex language server.
    -- Only if you are calling the server from ltex_extra
    server_opts = nil
}
```

## Contributors

Thanks to these people for your time, effort and ideas.

<a href="https://github.com/barreiroleo/ltex_extra.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=barreiroleo/ltex_extra.nvim" />
</a>

## Issues
- Lspsaga:

    Some users reported an issue with code actions when called from lspsaga.
    I'm not using lspsaga, so PR are very welcome.

    https://user-images.githubusercontent.com/39244876/201530888-077e76ad-211c-408f-80dc-89ba59751532.mov

    _Thanks to @felipejoribeiro for the screenrecording_
