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
