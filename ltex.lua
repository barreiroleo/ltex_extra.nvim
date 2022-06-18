local inspect = require("inspect")
local lnsep = "\n==========\n"
local function println(arg) print(lnsep .. arg .. lnsep) end

-- addToDictionary command captured from LSP Code action.
local command = {}
command.dictionary = {
    arguments = { {
        uri = "file:///home/leonardo/.config/nvim/lua/test/latex/main.tex",
        words = {
            ["en-US"] = { "Error", "Warning" },
        }
    } },
    command = "_ltex.addToDictionary",
    title = "Add 'Errorr' to dictionary"
}

command.disableRules = {
  arguments = { {
      ruleIds = {
        ["en-US"] = { "MORFOLOGIK_RULE_ES", "INCORRECT_SPACES" }
      },
      uri = "file:///home/leonardo/develop/ltex-lua/readme.md"
    } },
  command = "_ltex.disableRules",
  title = "Disable rule"
}

command.hideFalsePositives = {
  arguments = { {
      falsePositives = {
        ["en-US"] = { '{"rule":"UPPERCASE_SENTENCE_START","sentence":"^\\\\Qerror with false positive.\\\\E$"}', 
                      '{"rule":"UPPERCASE_SENTENCE_START","sentence":"^\\\\Qerror with false positive.\\\\E$"}' }
      },
      uri = "file:///home/leonardo/develop/ltex-lua/readme.md"
    } },
  command = "_ltex.hideFalsePositives",
  title = "Hide false positive"
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
addToDictionary(command.dictionary)
disableRules(command.disableRules)
hideFalsePositives(command.hideFalsePositives)
