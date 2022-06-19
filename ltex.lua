local inspect = require("inspect")
local lnsep = "=========="
local function println(arg) print("\n" .. lnsep .. arg .. lnsep) end

local commands = require("commands")

local function writeFile(type, lang, lines)
    local file = io.open("ltex." .. type .. "." .. lang .. ".txt", "a+")
    io.output(file)
    for _, line in ipairs(lines) do
        io.write(line .. "\n")
    end
    io.close(file)
end

local function readFile(type, lang)
    type = (type .. ".") or ""
    lang = (lang .. ".") or ""
    local filename = ("ltex." .. type .. lang .. "txt")

    local lines = {}
    local file = io.open(filename, "r")
    io.input(file)
    for line in io.lines(filename) do
        lines[#lines+1] = line
    end
    io.close(file)
    return lines
end

local function addToDictionary(command)
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Words: " .. inspect(words))
        writeFile("dictionary", lang, words)
    end
end

local function disableRules(command)
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("disabledRules", lang, rules)
    end
end

local function hideFalsePositives(command)
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("hiddenFalsePositives", lang, rules)
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

println("Reading file")
local dictionary = readFile("dictionary", "en-US")
local disabledRules = readFile("disabledRules", "en-US")
local hiddenFalsePositives = readFile("hiddenFalsePositives", "en-US")
print(inspect(dictionary))
print(inspect(disabledRules))
print(inspect(hiddenFalsePositives))
