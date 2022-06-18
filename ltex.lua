local inspect = require("inspect")
local lnsep = "\n==========\n"
local function println(arg) print(lnsep .. arg .. lnsep) end

local commands = require("commands")

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
        local file = io.open("ltex.dictionary." .. lang .. ".txt", "a+")
        io.output(file)
        for _, word in ipairs(words) do
            print(word)
            io.write(word .. "\n")
        end
        io.close(file)
    end
end

local function disableRules(command)
    local args = command.arguments[1].ruleIds
    println(inspect(args))
    for lang, rules in pairs(args) do
        println("Lang: " .. inspect(lang) .. "\n" ..
                "Rules: " .. inspect(rules))
        local file = io.open("ltex.disabledRules." .. lang .. ".txt", "a+")
        io.output(file)
        for _, rule in ipairs(rules) do
            print(rule)
            io.write(rule .. "\n")
        end
        io.close(file)
    end
end

local function hideFalsePositives(command)
    local args = command.arguments[1].falsePositives
    println(inspect(args))
    for lang, rules in pairs(args) do
        println("Lang: " .. inspect(lang) .. "\n" ..
                "Rules: " .. inspect(rules))
        local file = io.open("ltex.hiddenFalsePositives." .. lang .. ".txt", "a+")
        io.output(file)
        for _, rule in ipairs(rules) do
            print(rule)
            io.write(rule .. "\n")
        end
        io.close(file)
    end
end

-- execute_command(command.dictionary)
addToDictionary(commands.dictionary)
disableRules(commands.disableRules)
hideFalsePositives(commands.hideFalsePositives)
