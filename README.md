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
  - [Deprecated options notes](#deprecations)
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
    branch = "dev",
    ft = { "markdown", "tex" },
    opts = {
        ---@type string[]
        -- See https://valentjn.github.io/ltex/supported-languages.html#natural-languages
        load_langs = { 'en-US' },
        ---@type "none" | "fatal" | "error" | "warn" | "info" | "debug" | "trace"
        log_level = "none",
        ---@type string File's path to load.
        -- The setup will normalize it by running vim.fs.normalize(path).
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

## Deprecations

The following options are now marked deprecated and will be removed from `master` branch in a future
release after the Nvim 0.10 release. Please, if you have any concerns, raise an issue and let's talk
about it.

- `init_check`: Not needed anymore. It won't take any effect. `Ltex_extra` by default listen the
`LspAttach` event and loads the settings from disk.

    How to migrate? Just remove it.

- `server_start` and `server_opts`: When I accepted this PR it made sense to me because the servers
setups weren't likely standard. When `lazy.nvim` came to the party, configs start being simplified,
and now we have the `LspAttach` event and that simplifies the things much more. Keeping this feature
doesn't make much sense to me anymore and is hard to test because I need to have an A/B setup in my
dotfiles.

    How to migrate? *Setup the `ltex` server as any other.*
    ```lua
    {
        require("lspconfig").ltex.setup({
            on_attach = function(client, bufnr)
                -- Setuping the ltex_extra in `on_attach` function is not a requirement anymore.
                -- require('ltex_extra').setup({})
            end,
            filetypes = { 'markdown', 'tex', 'other supported language' },
            settings = {
                ltex = {
                    -- Your Ltex config. For instance:
                    checkFrequency = 'save',
                    language = { "en-US", 'es-AR' },
                    additionalRules = {
                        enablePickyRules = true,
                        motherTongue = 'es-AR',
                    },
                },
            },
        })
    }
    ```
    *And setup the plugin as any other.*
    ```lua
    {
        require("ltex_extra").setup({
            load_langs = { 'es-AR', 'en-US' }, -- Which languages do you want to load on init.
            path = ".ltex",                    -- Path to your ltex files
        })
    }
    ```
- `root_dir`: It was likely unofficial, but if you provide a `root_dir` to the `ltex` client config,
and you pass the `client.config.root_dir` as a path, `ltex_extra` will use it instead of the
relative path.
I think this is a cool feature in some cases but looking back it wasn't good implemented and, to be
honest, all the acrobatics are not necessary due to you can run the same `root_dir` function inner
your config and it should be enough.

    How to migrate: Just run your `find_root` method in the config function. Example sing Lazy.
    ```lua
    {
        "barreiroleo/ltex_extra.nvim",
        config = function()
            -- Example based on https://github.com/barreiroleo/ltex_extra.nvim/issues/38
            local function find_root()
                local file_path = vim.api.nvim_buf_get_name(0)
                local root_pattern = require("lspconfig").util.root_pattern
                -- Look for existing `.ltex` directory first. If it doesn't exist,
                -- look for .git/.hg directories. If everything else fails, get absolute path to the file parent
                return root_pattern('.ltex', '.hg', '.git')(file_path) or vim.fn.fnamemodify(file_path, ':p:h')
            end
            require("ltex_extra").setup({
                load_langs = { 'es-AR', 'en-US' },
                path = find_root(),
            })
        end
    }
    ```

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
