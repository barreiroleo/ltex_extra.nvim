local folderPath = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'
local debug = false

local inspect    = require(folderPath .. "utils").inspect
local filesystem = require(folderPath .. "utils")
local writeFile = filesystem.writeFile
local readFile = filesystem.readFile

local printdb = function (args)
    if debug == true then print(args) else return true end
end

local M = {}

M.addToDictionary = function (command)
    local args = command.arguments[1].words
    for lang, words in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Words: " .. inspect(words))
        writeFile("dictionary", lang, words)
    end
end

M.disableRules = function (command)
    local args = command.arguments[1].ruleIds
    for lang, rules in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("disabledRules", lang, rules)
    end
end

M.hideFalsePositives = function (command)
    local args = command.arguments[1].falsePositives
    for lang, rules in pairs(args) do
        printdb("Lang: " .. inspect(lang) .. "\n" .. "Rules: " .. inspect(rules))
        writeFile("hiddenFalsePositives", lang, rules)
    end
end

return M
