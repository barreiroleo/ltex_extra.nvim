#!/bin/bash
set -e -x

rm .ltex -rf
nvim -u repro_launch_server.lua    assets/main.md

rm .ltex -rf
nvim -u repro_setup_lsp_attach.lua assets/main.md

rm .ltex -rf
nvim -u repro_setup_on_attach.lua  assets/main.md
