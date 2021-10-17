local driver = require "luasql.mysql"
local config = require "utils.config"
local JSON = require "JSON"
local sql = {}

local env = assert(driver.mysql())
local con = assert(env:connect(
    config.sql.db, config.sql.user, config.sql.password
))

sql.fetchOne = function()

end

sql.fetchAll = function(query)
    local cur = assert(con:execute(query))
    local row = cur:fetch({}, "a")
    local result = ""
    
    while row do
        result = JSON:encode(row)..","..result
        row = cur:fetch(row, "a")
    end

    cur:close()
    return string.format("{\"status\": \"200\", \"data\": [%s]}", result:sub(1, -2))
end

return sql