local driver = require "luasql.mysql"
local config = require "utils.config"

local env = assert(driver.mysql())
local con = assert(env:connect(
    config.sql.db, config.sql.user, config.sql.password
))


return {
    all = function()
        local cur = assert(con:execute("SELECT  * FROM urls;"))
        local row = cur:fetch({}, "a")
        local result = ""
        
        while row do        
            result = result..string.format("id: %s url: %s short: %s", row.id, row.url, row.short)
            row = cur:fetch(row, "a")
        end

        return result
    end
}