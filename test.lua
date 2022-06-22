local inspect = require("inspect")
local lnsep = "=========="
local function println(arg) print("\n" .. lnsep .. arg .. lnsep) end

local commands           = require("test.commands")
local addToDictionary    = require("src.commands-lsp").addToDictionary
local disableRules       = require("src.commands-lsp").disableRules
local hideFalsePositives = require("src.commands-lsp").hideFalsePositives

local inspect            = require("src.utils").inspect
local writeFile          = require("src.utils").writeFile
local readFile           = require("src.utils").readFile

local langs = {"es-AR", "en-US"}

-- Command Handler mockup.
local function execute_command(command)
    println(command.command)
    print("command = " .. inspect(command))
    if command.command == '_ltex.addToDictionary' then
        addToDictionary(commands.dictionary)
    elseif command.command == '_ltex.disableRules' then
        disableRules(commands.disableRules)
    elseif command.command == '_ltex.hideFalsePositives' then
        hideFalsePositives(commands.hideFalsePositives)
    end
end

execute_command(commands.dictionary)
execute_command(commands.disableRules)
execute_command(commands.hideFalsePositives)

println("Reading file")
local dictionary           = {}
local disabledRules        = {}
local hiddenFalsePositives = {}
for _, lang in ipairs(langs) do
    dictionary[lang]           = readFile("dictionary", lang)
    disabledRules[lang]        = readFile("disabledRules", lang)
    hiddenFalsePositives[lang] = readFile("hiddenFalsePositives", lang)
end
print(inspect(dictionary))
print(inspect(disabledRules))
print(inspect(hiddenFalsePositives))

local dictionary_example = {["es-AR"] = {"Errorr"}, ["en-US"] = {"Errorr"}}
print(inspect(dictionary_example))
