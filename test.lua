local inspect = require("inspect")
local lnsep = "=========="
local function println(arg) print("\n" .. lnsep .. arg .. lnsep) end

local commands           = require("commands")
local addToDictionary    = require("commands-lsp").addToDictionary
local disableRules       = require("commands-lsp").disableRules
local hideFalsePositives = require("commands-lsp").hideFalsePositives

local inspect   = require("utils").inspect
local writeFile = require("utils").writeFile
local readFile  = require("utils").readFile

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
for _, lang in ipairs(langs) do
    local dictionary           = readFile("dictionary", lang)
    local disabledRules        = readFile("disabledRules", lang)
    local hiddenFalsePositives = readFile("hiddenFalsePositives", lang)
    print(dictionary)
    print(disabledRules)
    print(hiddenFalsePositives)
end
