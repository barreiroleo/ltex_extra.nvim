local inspect = require("inspect")
local lnsep = "=========="
local function println(arg) print("\n" .. lnsep .. arg .. lnsep) end

local commands = require("commands")

local function addToDictionary(command)
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" ..
            "Words: " .. inspect(words))
        local file = io.open("ltex.dictionary." .. lang .. ".txt", "a+")
        io.output(file)
        for _, word in ipairs(words) do
            io.write(word .. "\n")
        end
        io.close(file)
    end
end

local function disableRules(command)
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" ..
            "Rules: " .. inspect(rules))
        local file = io.open("ltex.disabledRules." .. lang .. ".txt", "a+")
        io.output(file)
        for _, rule in ipairs(rules) do
            io.write(rule .. "\n")
        end
        io.close(file)
    end
end

local function hideFalsePositives(command)
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" ..
            "Rules: " .. inspect(rules))
        local file = io.open("ltex.hiddenFalsePositives." .. lang .. ".txt", "a+")
        io.output(file)
        for _, rule in ipairs(rules) do
            io.write(rule .. "\n")
        end
        io.close(file)
    end
end

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
