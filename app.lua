local log = require "lib.rxi-log.log"
local config = require "utils.config"

log.debug(string.format("=== %s (v%s) ===", config["api-name"], config.version))
log.debug("Host: "..config["server"].host)
log.debug("Port: "..config["server"].port)
log.debug("SQL DB: "..config["sql"].db)
log.debug("SQL User: "..config["sql"].user)

require("utils.server")