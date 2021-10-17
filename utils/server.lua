local server = require "http.server"
local headers = require "http.headers"

local log = require "lib.rxi-log.log"
local routes = require "routes.api"
local config = require "utils.config"

local app = server.listen {
    host = config["server"].host,
    port = config["server"].port,
    
    onstream = function(sv, st)
        local reqHeaders = st:get_headers()
        local reqMethod = reqHeaders:get(":method")

        local path = reqHeaders:get(":path")
        local callback = path:sub(2)
        local header = headers.new()

        header:append("content-type", "application/json")

        -- handle routes from router object
        if routes[callback] and reqMethod == "GET" then
            log.info("[200] requested "..path.." using "..reqMethod)
            header:append(":status", "200")

            st:write_headers(header, reqMethod == "HEAD")
            st:write_chunk(routes[callback](), true)
        else
            log.warn("[404] requested "..path.." using "..reqMethod)
            header:append(":status", "404")

            st:write_headers(header, reqMethod == "HEAD")
            st:write_chunk("{\"status\": \"404\"}", true)
        end
    end
}

-- log the url
log.info(string.format("API Live on: http://%s:%s", 
    config["server"].host, config["server"].port
))

app:listen()
app:loop()
