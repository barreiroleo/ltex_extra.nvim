local inspect = require("inspect")
local lnsep = "\n==========\n"
local function println(arg) print(lnsep .. arg .. lnsep) end

-- addToDictionary command captured from LSP Code action.
local command = {
    arguments = { {
        uri = "file:///home/leonardo/.config/nvim/lua/test/latex/main.tex",
        words = {
            ["en-US"] = { "Error", "Warning" },
        }
    } },
    command = "_ltex.addToDictionary",
    title = "Add 'Errorr' to dictionary"
}


-- Command Handler mockup.
local function execute_command(command)
    println(inspect(command))
    if command.command == '_ltex.addToDictionary' then
        println("addToDictionary triggered")
    end
end

local function addToDictionary(command)
    local args = command.arguments[1].words
    println(inspect(args))
    for lang, words in pairs(args) do
        println("Lang: " .. inspect(lang) .. "\n" ..
                "Words: " .. inspect(words))
        for _, word in ipairs(words) do
            print(word)
        end
    end
end

execute_command(command)
addToDictionary(command)
