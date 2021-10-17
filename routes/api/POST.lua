local sql = require "utils.sql"
local errors = require "utils.errors"

return {
    ["url/add"] = function(body)
        local url = body.url

        -- found this on some obscure form
        -- https://forums.indigorose.com/forum/autoplay-media-studio-8-5/autoplay-media-studio-8-discussion/299325-pattern-matching-for-valid-urls
        if url == nil or not string.match(url, [[https?://(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))]]) then
            return errors.e400
        end

        -- TODO: Sanitize
        local url_exists = sql.fetch(string.format("SELECT short FROM urls WHERE url = '%s'", url))
        
        if url_exists then
            return string.format([[{
                "status": 304,
                "message": "Already exists!",
                "url": "%s"
            }]], url_exists.short)
        end



        return "{\"a\": 4}"
    end
}