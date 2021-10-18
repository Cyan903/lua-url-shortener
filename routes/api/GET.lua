local sql = require "utils.sql"
local errors = require "utils.errors"
local config = require "utils.config"

return {
    [""] = function()
        return string.format([[{
            "status": 200,
            "message": "%s API currently serving %s shortcuts!"
        }]],
            config["api-name"], 
            tonumber(sql.fetch("SELECT COUNT(*) AS total FROM urls;").total)
        )
    end,

    ["stats"] = function()
        local totalUrls = tonumber(sql.fetch("SELECT COUNT(*) AS total FROM urls;").total)
        local totalClicks = tonumber(sql.fetch("SELECT SUM(clicks) AS total FROM urls_info;").total)
    
        return string.format([[{
            "message": 200,
            "stats": {
                "total_clicks": %s,
                "total_shortcuts": %s
            }
        }]], totalClicks, totalUrls)
    end,

    -- /v/ - Visit a url
    ["v"] = function()

    end,

    ["url/all"] = function(params)
        local page = tonumber(params.page) or -1
        local length = tonumber(params.length) or -1

        if page < 0 or length < 0 then
            return errors.e400
        end

        return sql.fetchAll(string.format([[
            SELECT * FROM urls LIMIT %s, %s;
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
            WHERE urls.id = %s;
        ]], id))
    end
}