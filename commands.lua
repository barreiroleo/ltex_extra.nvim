-- Commands captured from LSP Code action.
local commands = {}

commands.dictionary = {
    arguments = { {
        uri = "file:///home/leonardo/.config/nvim/lua/test/latex/main.tex",
        words = {
            ["en-US"] = { "Error", "Warning" },
        }
    } },
    command = "_ltex.addToDictionary",
    title = "Add 'Errorr' to dictionary"
}

commands.disableRules = {
  arguments = { {
      ruleIds = {
        ["en-US"] = { "MORFOLOGIK_RULE_ES", "INCORRECT_SPACES" }
      },
      uri = "file:///home/leonardo/develop/ltex-lua/readme.md"
    } },
  command = "_ltex.disableRules",
  title = "Disable rule"
}

commands.hideFalsePositives = {
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

return commands
