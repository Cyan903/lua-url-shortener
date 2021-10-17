local sql = require "utils.sql"

sql.exec("DELETE FROM urls WHERE 1")
sql.exec("DELETE FROM urls_info WHERE 1")