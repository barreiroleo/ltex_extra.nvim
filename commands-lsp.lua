local inspect = require("inspect")
local filesystem = require("filesystem")
local writeFile = filesystem.writeFile
local readFile = filesystem.readFile

local M = {}

M.addToDictionary = function (command)
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Words: " .. inspect(words))
        writeFile("dictionary", lang, words)
    end
end

M.disableRules = function (command)
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("disabledRules", lang, rules)
    end
end

M.hideFalsePositives = function (command)
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        print("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("hiddenFalsePositives", lang, rules)
    end
end

return M
