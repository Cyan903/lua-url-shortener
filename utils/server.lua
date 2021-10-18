local server = require "http.server"
local headers = require "http.headers"

local log = require "lib.rxi-log.log"
local url = require "lib.neturl.url"
local routes = require "routes.api"
local config = require "utils.config"
local errors = require "utils.errors"

local function getPaths(url)
    local arr = {}
    for str in string.gmatch(url, "([^/]+)") do
        table.insert(arr, str)
    end
    
    return arr
end

local app = server.listen {
    host = config["server"].host,
    port = config["server"].port,
    
    onstream = function(sv, st)
        local reqHeaders = st:get_headers()
        local reqMethod = reqHeaders:get(":method")
        local headerUrl = reqHeaders:get(":path")
        local path = url.parse(headerUrl).path
        local paths = getPaths(tostring(path))
        local callback = path:sub(2)
        local queries = url.parseQuery(tostring(url.parse(headerUrl).query))
        local header = headers.new()

        header:append("content-type", "application/json")

        if reqMethod == "GET" then
            -- Redirect
            if paths[1] == "v" and #paths == 2 then
                local redirectTo = routes["GET"]["v"](paths[2])

                log.info("[303] user wants to redirect")

                if redirectTo then
                    header:append(":status", "303")
                    header:append("location", redirectTo)
                    st:write_headers(header, reqMethod == "HEAD")
                else
                    log.warn(string.format("[404] redirect %s does not exist!", paths[2]))

                    header:append(":status", "404")
                    st:write_headers(header, reqMethod == "HEAD")
                    st:write_chunk(errors.e404, true)
                end

            -- GET api
            elseif routes["GET"][callback] then
                log.info("[200] requested "..path.." using GET")
                header:append(":status", "200")

                st:write_headers(header, reqMethod == "HEAD")
                st:write_chunk(routes["GET"][callback](queries), true)
            else
                log.warn("[404] requested "..path.." using GET")
                header:append(":status", "404")

                st:write_headers(header, reqMethod == "HEAD")
                st:write_chunk(errors.e404, true)
            end

        -- POST api
        elseif reqMethod == "POST" then
            local query = url.parseQuery(st:get_body_as_string())

            if routes["POST"][callback] then
                log.info("[200] sent "..path.." using POST")
                header:append(":status", "200")

                st:write_headers(header, reqMethod == "HEAD")
                st:write_chunk(routes["POST"][callback](query), true)
            else
                log.warn("[404] sent "..path.." using POST")
                header:append(":status", "404")

                st:write_headers(header, reqMethod == "HEAD")
                st:write_chunk(errors.e404, true)
            end
        end
    end,

    onerror = function(_, _2, _3, err)
        log.fatal("[onerror] "..err)
    end
}

log.info(string.format("API Live on: http://%s:%s", 
    config["server"].host, config["server"].port
))

app:listen()
app:loop()
