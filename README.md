<!-- LTeX: language=en-US -->
<div align="center">
<h6>🚧 This plugin will be rewritten, I'll do my best to maintain the specs but expect some changes</h6>

# LTeX_extra.nvim

<h6>Provides the client implementation for LTeX commands.</h6>
<h6>Developed and tested in Nightly. It shouldn't be a requirement for you</h6>

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
![Work In Progress](https://img.shields.io/badge/Work%20In%20Progress-orange?style=for-the-badge)
![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
<!-- [![Neovim Nightly](https://img.shields.io/badge/Neovim%20Nightly-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io) -->
</div>

`Ltex_extra` is a companion plugin for `LTeX` language server that provides the client handlers for
these methods that are off the LSP specification. The current supported methods are:
[`addToDictionary`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexhidefalsepositives-client),
[`disableRule`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexdisablerules-client),
[`hideFalsePositive`](https://valentjn.github.io/ltex/ltex-ls/server-usage.html#_ltexaddtodictionary-client).


<!--toc:start-->
- [LTeX_extra.nvim](#ltexextranvim)
  - [Features](#features)
  - [Installation and setup](#installation-and-setup)
  - [Deprecated options notes](#deprecated-options-notes)
  - [FAQ](#faq)
    - [Lspsaga:](#lspsaga)
  - [Contributors](#contributors)
<!--toc:end-->


## Features

- Code actions: Provides the client handlers to manage the `Add To Dictionary`, `Hide False
Positive`, and `Disable Rule` commands and be able to persist those settings on disk.
- Custom export path: This plugin aims to be compatible with the official `vscode` extension, but if
you point `Ltex_extra` to where your files are, it will use them. Useful if you want to use global
like setting cross projects.
- On start load: `Ltex_extra` by default will listen when you start the server and will load the
settings from disk.
- `Ltex_extra` API (available on `require("ltex_extra")`):
    - `ltex_extra.setup(opts)`: The setup entry point.
    - `ltex_extra.reload(langs[]?)`: Force to reload words/rules for certain languages. If none,
    it'll reload all ones. Useful when you modified these files by hand.
    - `ltex_extra.check_document()`: Explicitly request to `ltex` to check the current document.
    Normally not needed, but there is.
    - `ltex_extra.get_server_status()`: Expose the internal stats of the server, like CPU, memory
    and uptime.
    - `ltex_extra.push_setting(type: "dictionary"|"disabledRules"|"hiddenFalsePositives", lang:
    string, content: string[])`: Push words/rules to the server but don't persist on disk.
- `:LtexExtraReload lang[s]?` CmdLine command. Executes the `ltex_extra.reload`, it'll suggest your
loaded to avoid mismatches.

## Installation and setup

`Ltex_extra` requires [`ltex-ls`](https://github.com/valentjn/ltex-ls) available to attach to it.
The server can be installed through [`mason.nvim`](https://github.com/williamboman/mason.nvim) and
be configured by [`lspconfig`](https://github.com/neovim/nvim-lspconfig).

To install the plugin just use your favorite plugin manager as always. The plugin comes with the
following defaults: *example using [`lazy.nvim`](https://github.com/folke/lazy.nvim) as package
manager*:

```lua
{
    "barreiroleo/ltex_extra.nvim",
    ft = { "markdown", "tex" },
    opts = {
        ---@type string[]
        -- See https://valentjn.github.io/ltex/supported-languages.html#natural-languages
        load_langs = { 'en-US' },
        ---@type "none" | "fatal" | "error" | "warn" | "info" | "debug" | "trace"
        log_level = "none",
        ---@type string File's path to load.
        -- The setup will normalice it running vim.fs.normalize(path).
        -- e.g. subfolder in project root or cwd: ".ltex"
        -- e.g. cross project settings:  vim.fn.expand("~") .. "/.local/share/ltex"
        path = ".ltex",
        ---@deprecated
        init_check = true,
        ---@deprecated
        server_start = false,
        ---@deprecated
        server_opts = nil
    },
}
```

## Deprecated options notes

All the options marked as deprecated will continue working until a couple of weeks after nvim's 0.10
release. Please, if you have any concerns, raise an issue and let's talk about it.

- `init_check`: Not needed anymore. It won't take any effect. `Ltex_extra` by default listen the
`LspAttach` event and loads the settings from disk. Just remove it safely.
- `server_start` and `server_opts`: The ability to call the `lspconfig` and start the server for you
will be removed. When I accepted this PR it made sense to me because the servers setups weren't
likely standard. When `lazy.nvim` came to the party, configs start being simplified, and now we have
the `LspAttach` event that simplifies the things much more. Keeping this feature doesn't make much
sense to me anymore and is hard to test because I need to have an A/B setup in my dotfiles.

## FAQ

### Lspsaga:
> [!WARNING]
> After the plugin rewrite the client management was changed. Need to test if this still happening.

Some users of `lspsaga` has reported issues with code actions. I not use `lspsaga`, so PRs are very
welcome.

https://user-images.githubusercontent.com/39244876/201530888-077e76ad-211c-408f-80dc-89ba59751532.mov

_Thanks to @felipejoribeiro for the screen recording_


## Contributors

Thanks to these people for your time, effort and ideas.

<a href="https://github.com/barreiroleo/ltex_extra.nvim/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=barreiroleo/ltex_extra.nvim" />
</a>


<!-- vim: set textwidth=100 nospell :-->
