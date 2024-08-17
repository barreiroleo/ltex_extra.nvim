<!-- LTeX: language=en-US -->
<div align="center">
<h6>🚧 Dev branch will be merged soon. Please take a look at the Deprecations notes in dev branch. </h6>

# LTeX_extra.nvim

<h6>Provides implementations for non-LSP LTeX commands.</h6>
<h6>Developed and tested in Nightly. It's not required for you</h6>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)

<!-- [![Neovim Nightly](https://img.shields.io/badge/Neovim%20Nightly-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io) -->
</div>

`LTeX` language server provides some code actions off the LSP specifications.
These commands require client implementations for things like file system
operations.

`LTeX_extra` is a companion plugin for `LTeX` language server that provides
such implementations for Neovim. The current supported methods are:
[`addToDictionary`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexaddtodictionary-client),
[`disableRule`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexdisablerules-client),
[`hideFalsePositive`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexhidefalsepositives-client).

<!--toc:start-->

- [LTeX_extra.nvim](#ltexextranvim)
  - [Features](#features)
    - [Code Actions](#code-actions)
    - [Custom export path](#custom-export-path)
    - [On start load](#on-start-load)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [FAQ](#faq)
    - [Force reload](#force-reload)
    - [Lspsaga:](#lspsaga)
  - [Contributors](#contributors)
  <!--toc:end-->

## Features

> [!WARNING]
> The following demos may contain orthographic horrors.

### Code Actions

**Add _word_ to dictionary**, **Hide false positive**, and **Disable rule**

https://user-images.githubusercontent.com/48270301/177694689-b6b12b4a-3981-47fe-aa88-567697f797bd.mp4

### Custom Export Path

Give you compatibility with official vscode extension, and flexibility to do things like global dictionaries.

https://user-images.githubusercontent.com/48270301/177694714-2f9d7477-26b6-4bf5-a47e-63ce2f82d76a.mp4

### Load on Start

Load ltex files on server start.

https://user-images.githubusercontent.com/48270301/177694724-736159ab-c202-4325-ad23-405c76676b79.mp4

## Installation

🚧 This plugin will be rewritten and as consequence I want to support just one
method to initialize the plugin. The chosen one probably will be based on the
LspAttach autocommand. I won't support the server initialization through
this plugin anymore. It was a bad decision, doesn't provide much value and is
hard to maintain.

This plugin requires an instance of `ltex_ls` language server available to attach.
_[`ltex-ls`](https://github.com/valentjn/ltex-ls) is available at [`mason.nvim`](https://github.com/williamboman/mason.nvim)._

Install the plugin with your favorite plugin manager using `{"barreiroleo/ltex-extra.nvim"}`.
Then add `require("ltex_extra").setup()` to your config.

There are two recommended methods:

1. Call the `setup` from `on_attach` function of your server. Example with
   `lspconfig`, minor changes are required for `mason` handler:
   `lua
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
`
2. Use the handler which `ltex_extra` provide to call the server. Example of use with `lazy.nvim`:

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

_Notes: You can pass to `setup` the arguments that you are interested in and omit the rest.
At the moment, if you have `dictionary`, `disabledRules` and
`hiddenFalsePositives` defined in your `ltex` settings, they aren't backed up._

```lua
require("ltex_extra").setup {
    -- table <string> : languages for witch dictionaries will be loaded, e.g. { "es-AR", "en-US" }
    -- https://valentjn.github.io/ltex/supported-languages.html#natural-languages
    load_langs = { "en-US" } -- en-US as default
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

## FAQ

### Force reload

If you experience hangs with the server/plugin, you can force a reload of
the LTeX files by running `require("ltex_extra").reload()`

https://user-images.githubusercontent.com/48270301/177694740-bc8bdb4c-0f6b-4f63-98af-54ec23196f27.mp4

### Lspsaga:

Some users of lspsaga has reported issues with code actions. I don't use lspsaga,
so PRs are welcome. Just make sure to test without that plugin enabled as well.

https://user-images.githubusercontent.com/39244876/201530888-077e76ad-211c-408f-80dc-89ba59751532.mov

_Thanks to @felipejoribeiro for the screen recording_

## Contributors

Thanks to these people for your time, effort and ideas.

<a href="https://github.com/barreiroleo/ltex_extra.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=barreiroleo/ltex_extra.nvim" />
</a>
