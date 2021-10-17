local log = require "lib.rxi-log.log"

local errors = {
    gen = function(status, message)
        log.warn(string.format("[%s] http error!", status))
        return string.format("{\"status\": \"%s\", \"message\": \"%s\"}", status, message)
    end
}

errors.e404 = errors.gen(404, "Not found!")
errors.e400 = errors.gen(400, "Invalid request!")
errors.e500 = errors.gen(500, "Internal server error!")

return errors