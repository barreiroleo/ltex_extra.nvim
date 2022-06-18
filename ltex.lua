local inspect = require("inspect")
local lnsep = "\n==========\n"
local function println(arg) print(lnsep .. arg) end

-- addToDictionary command captured from LSP Code action.
local command = {
    arguments = { {
        uri = "file:///home/leonardo/.config/nvim/lua/test/latex/main.tex",
        words = {
            ["en-US"] = { "Error", "Warning" },
        }
    } },
    command = "_ltex.addToDictionary",
    title = "Add 'Errorr' to dictionary"
}


-- Command Handler mockup.
local function execute_command(command)
    println(inspect(command))
    if command.command == '_ltex.addToDictionary' then
        println("addToDictionary triggered")
    end
end


execute_command(command)
