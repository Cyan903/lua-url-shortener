local log = require "lib.rxi-log.log"
local sql = require "utils.sql"
local errors = require "utils.errors"
local config = require "utils.config"

local function randomStr(length)
    local upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local lower = "abcdefghijklmnopqrstuvwxyz"
    local num = "0123456789"
    local safeSym = "-_~"

    local safeset = (upper..lower..num..safeSym)
    local result = ""

    for i = 1, length do
        local rand = math.random(#safeset)
        result = result..string.sub(safeset, rand, rand)
    end

    return result
end

return {
    ["url/add"] = function(body)
        -- TODO: Sanitize
        local url = body.url

        -- Found this on some obscure form
        -- https://forums.indigorose.com/forum/autoplay-media-studio-8-5/autoplay-media-studio-8-discussion/299325-pattern-matching-for-valid-urls
        if url == nil or not string.match(url, [[https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))]]) then
            return errors.e400
        end

        -- Does URL already exist? If so, return it.
        local url_exists = sql.fetch(string.format("SELECT short FROM urls WHERE url = '%s';", url))
        
        if url_exists then
            return string.format([[{
                "status": 304,
                "message": "Already exists!",
                "url": "%s"
            }]], url_exists.short)
        end

        -- Generate short URL while it doesn't exist in db (no duplicate shortend urls).
        local randShort = true
        local randShortExists = true

        repeat
            randShort = randomStr(config["gen-length"])
            randShortExists = sql.fetch(string.format("SELECT short FROM urls WHERE short = '%s';", randShort))
        until(not randShortExists)
        
        -- Get latest id (I turned off auto increment)
        local idUrl = tonumber(sql.fetch("SELECT COUNT(id) as count FROM urls;").count) + 1
        local idInfo = tonumber(sql.fetch("SELECT COUNT(id) as count FROM urls_info;").count) + 1
        local currentDate = 0

        if idUrl ~= idInfo then
            log.fatal("urls table and urls_info do not match up!")
            os.exit() 
        end

        sql.exec(string.format([[
            INSERT INTO urls (id, url, short) VALUES (%s, "%s", "%s");
        ]], idUrl, url, randShort))

        sql.exec(string.format([[
            INSERT INTO urls_info (id, date_added, clicks) VALUES (%s, %s, 0);
        ]], idInfo, currentDate))

        log.info(string.format("Added %s into database as %s", url, randShort))

        return sql.fetchOne(string.format([[
            SELECT 
                urls.id, urls.url, urls.short,
                urls_info.date_added, urls_info.clicks
            FROM urls 
            INNER JOIN urls_info ON urls.id = urls_info.id
            WHERE urls.id = %s;
        ]], idUrl))
    end
}