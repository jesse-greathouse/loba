local cjson = require "cjson"
local env = require "env"

local ApiUpstreamView = {}

function ApiUpstreamView.get()
    local dbmodule = "db." .. env.DB_DRIVER
    local db = require(dbmodule):new()
    ngx.say(cjson.encode(db:get_upstreams()))
end


return ApiUpstreamView;