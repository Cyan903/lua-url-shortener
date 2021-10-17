local sql = require "utils.sql"

return {
    ["all/aa"] = function()
        local urls = sql.fetchAll("SELECT * FROM urls;")
        
        return urls
    end
}