#!/usr/bin/env -S nvim -l

local ltex_config = {
    filetypes = { 'bib', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex' },
    settings = {
        ltex = {
            checkFrequency = 'save',
            language = { "en-US", 'es-AR' },
            additionalRules = {
                enablePickyRules = true,
                motherTongue = 'es-AR',
            },
        },
    }
}

local ltex_extra_spec = {
    "barreiroleo/ltex_extra.nvim",
    dir = "/plugin/",
    dev = true,
    opts = {
        init_check = true,   -- boolean : whether to load dictionaries on startup
        path = ".ltex",      -- string : path to store dictionaries. Relative path uses current working directory
        server_start = true, -- boolean : Enable the call to ltex. Usefull for migration and test
        server_opts = {
            on_attach = function(client, bufnr)
                print("Loading ltex from ltex_extra")
            end,
            capabilities = {},
            filetypes = { 'bib', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex' },
            settings = {
                ltex = {
                    settings = {
                        checkFrequency = 'save',
                        language = { "en-US", 'es-AR' },
                        additionalRules = {
                            enablePickyRules = true,
                            motherTongue = 'es-AR',
                        },
                    }
                },
            }
        },
    },
}


vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").repro({
    spec = {
        { ltex_extra_spec },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                { "williamboman/mason.nvim", opts = {} },
                "williamboman/mason-lspconfig.nvim"
            },
            config = function()
                ---@diagnostic disable-next-line: missing-fields
                require("mason-lspconfig").setup({
                    ensure_installed = { "ltex" },
                    handlers = {
                        ["ltex"] = function(server_name)
                            require("lspconfig")[server_name].setup(ltex_config)
                        end,
                    }
                })

                -- Open main.md once ltex has been installed.
                require("mason-registry"):on("package:install:success",
                    vim.schedule_wrap(function(pkg, handle)
                        vim.notify(string.format("[Ltex_extra] Installed %s. Loading main.md", pkg.name))
                        vim.cmd("edit test/assets/main.md")
                    end)
                )
            end
        },
    }
})