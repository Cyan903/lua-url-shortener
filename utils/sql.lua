local driver = require "luasql.mysql"
local config = require "utils.config"
local JSON = require "JSON"
local sql = {}

local env = assert(driver.mysql())
local con = assert(env:connect(
    config.sql.db, config.sql.user, config.sql.password
))

sql.clean = function(query)
    local sanitized = query
    local replaces = {
        -- I really need to learn regex...
        "\"", "'", "\\", "`"
    }

    for k, v in pairs(replaces) do
        sanitized = string.gsub(sanitized, v, "")
    end

    return sanitized
end

sql.fetch = function(query)
    local cur = assert(con:execute(query))
    local data = cur:fetch({}, "a")

    cur:close()
    return data 
end

sql.exec = function(query)
    assert(con:execute(query))
end

sql.fetchOne = function(query)
    local cur = assert(con:execute(query))
    local result = JSON:encode(cur:fetch({}, "a"))

    cur:close()
    return string.format("{\"status\": \"200\", \"data\": %s}", result)
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