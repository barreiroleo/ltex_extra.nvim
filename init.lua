-- local pathOfThisFile = ... -- pathOfThisFile is now 'lib.foo.bar'
local folderPath = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'

local addToDictionary    = require(folderPath .. "src.commands-lsp").addToDictionary
local disableRules       = require(folderPath .. "src.commands-lsp").disableRules
local hideFalsePositives = require(folderPath .. "src.commands-lsp").hideFalsePositives


local orig_execute_command = vim.lsp.buf.execute_command
vim.lsp.buf.execute_command = function(command)
    -- print(vim.inspect(command))
    if command.command == '_ltex.addToDictionary' then
        addToDictionary(command)
    elseif command.command == '_ltex.disableRules' then
        disableRules(command)
    elseif command.command == '_ltex.hideFalsePositives' then
        hideFalsePositives(command)
    else
      orig_execute_command(command)
    end
end

-- local readFile = require(folderPath .. "src.utils").readFile
-- local langs = {"es-AR", "en-US"}
-- local dictionary           = {}
-- local disabledRules        = {}
-- local hiddenFalsePositives = {}
--
-- for i, lang in ipairs(langs) do
--     local content = readFile("dictionary", lang)
--     dictionary[i] = content
--     dictionary[i] = readFile("dictionary", lang)
--     disabledRules[i]        = readFile("disabledRules", lang)
--     hiddenFalsePositives[i] = readFile("hiddenFalsePositives", lang)
-- end
-- print(vim.inspect(dictionary))
-- print(vim.inspect(disabledRules))
-- print(vim.inspect(hiddenFalsePositives))
