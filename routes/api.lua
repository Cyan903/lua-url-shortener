local sql = require "utils.sql"

return {
    all = function()
        local urls = sql.fetchAll("SELECT * FROM urls;")
        
        return urls
    end
}