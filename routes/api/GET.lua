local sql = require "utils.sql"
local errors = require "utils.errors"

return {
    [""] = function()
        -- show # of shortcuts maybe?
        return [[{
            "status": 200,
            "message": "lua-url-shortener"
        }]]
    end,

    ["stats"] = function()
        -- db stats
    end,

    ["url/all"] = function(params)
        local page = tonumber(params.page) or -1
        local length = tonumber(params.length) or -1

        if page < 0 or length < 0 then
            return errors.e400
        end

        return sql.fetchAll(string.format([[
            SELECT * FROM urls LIMIT %s, %s
        ]], page*length, length))
    end,

    ["url/info"] = function(params)
        local id = tonumber(params.id) or -1

        if id < 0 then
            return errors.e400
        end

        return sql.fetchOne(string.format([[
            SELECT 
                urls.id, urls.url, urls.short,
                urls_info.date_added, urls_info.clicks
            FROM urls 
            INNER JOIN urls_info ON urls.id = urls_info.id
            WHERE urls.id = %s
        ]], id))
    end,

    ["url/for"] = function()

    end
}