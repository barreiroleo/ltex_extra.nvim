local inspect = require("inspect")
local lnsep = "=========="
local function println(arg) print("\n" .. lnsep .. arg .. lnsep) end

local commands           = require("commands")
local addToDictionary    = require("commands-lsp").addToDictionary
local disableRules       = require("commands-lsp").disableRules
local hideFalsePositives = require("commands-lsp").hideFalsePositives

local filesystem = require("filesystem")
local writeFile  = filesystem.writeFile
local readFile   = filesystem.readFile

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
local dictionary           = readFile("dictionary", "en-US")
local disabledRules        = readFile("disabledRules", "en-US")
local hiddenFalsePositives = readFile("hiddenFalsePositives", "en-US")
print(inspect(dictionary))
print(inspect(disabledRules))
print(inspect(hiddenFalsePositives))
