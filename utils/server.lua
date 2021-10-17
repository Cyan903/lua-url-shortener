local server = require "http.server"
local headers = require "http.headers"

local log = require "lib.rxi-log.log"
local url = require "lib.neturl.url"
local routes = require "routes.api"
local config = require "utils.config"
local errors = require "utils.errors"

local app = server.listen {
    host = config["server"].host,
    port = config["server"].port,
    
    onstream = function(sv, st)
        local reqHeaders = st:get_headers()
        local reqMethod = reqHeaders:get(":method")

        local headerUrl = reqHeaders:get(":path")
        local path = url.parse(headerUrl).path
        local callback = path:sub(2)
        local queries = url.parseQuery(tostring(url.parse(headerUrl).query))
        local header = headers.new()

        header:append("content-type", "application/json")

        -- GET api
        if reqMethod == "GET" then
            if routes["GET"][callback] then
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

    onerror = function(server, context, op, err, errno)
        local msg = op .. " on " .. tostring(context) .. " failed"
		if err then
			msg = msg .. ": " .. tostring(err)
		end
		assert(io.stderr:write(msg, "\n"))
    end
}

log.info(string.format("API Live on: http://%s:%s", 
    config["server"].host, config["server"].port
))

app:listen()
app:loop()
