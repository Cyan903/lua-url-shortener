local JSON = require "JSON"
local open = io.open

local function read(path)
    local file = open(path, "rb")
    local content = file:read("*a")
    
    file:close()
    return content
end

local content = read("config.json");
return JSON:decode(content)