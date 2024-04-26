---@diagnostic disable: unused-local

---@alias language string

--- _ltex.addToDictionary (Client)
--- _ltex.addToDictionary is executed by the client when it should add words to
--- the dictionary by adding them to ltex.dictionary
---@class AddToDictionaryCommandParams
---@field arguments {uri:string, words:{[language]:string[]}}[]
---@field command string
---@field title string
-- selene: allow(unused_variable)
local AddToDictionaryCommandParams_test = {
    arguments = {
        {
            uri = "file:///home/leonardo/develop/plugins/ltex_extra.nvim/test/assets/main.md",
            words = {
                ["en-us"] = { "missspelling" }
            }
        }
    },
    command = "_ltex.addToDictionary",
    title = "Add 'missspelling' to dictionary"
}


-- _ltex.disableRules (Client)
-- _ltex.disableRules is executed by the client when it should disable rules by
-- adding the rule IDs to ltex.disabledRules.
---@class DisableRulesCommandParams
---@field arguments {uri:string, ruleIds:{[language]:string[]}}[]
---@field command string
---@field title string
-- selene: allow(unused_variable)
local DisableRulesCommandParams_test = {
    arguments = { {
        ruleIds = {
            ["en-us"] = { "EN_UNPAIRED_BRACKETS" }
        },
        uri = "file:///home/leonardo/develop/plugins/ltex_extra.nvim/test/assets/main.md"
    } },
    command = "_ltex.disableRules",
    title = "Disable rule"
}

-- _ltex.hideFalsePositives (Client)
-- _ltex.hideFalsePositives is executed by the client when it should hide false
-- positives by adding them to ltex.hiddenFalsePositives.
---@class HideFalsePositivesCommandParams
---@field arguments {uri:string, falsePositives:{[language]:string[]}}[]
---@field command string
---@field title string
-- selene: allow(unused_variable)
local HideFalsePositivesCommandParams_test = {
    arguments = { {
        falsePositives = {
            ["en-us"] = { '{"rule":"THIS_NNS","sentence":"^\\\\Q2- Hide false positive this sentences should beggining uppercase.\\\\E$"}' }
        },
        uri = "file:///home/leonardo/develop/plugins/ltex_extra.nvim/test/assets/main.md"
    } },
    command = "_ltex.hideFalsePositives",
    title = "Hide false positive"
}

return {
    Dictionary = AddToDictionaryCommandParams_test,
    DisableRules = DisableRulesCommandParams_test,
    HideFalsePositives = HideFalsePositivesCommandParams_test
}
