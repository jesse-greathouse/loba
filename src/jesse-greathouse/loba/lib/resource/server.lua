local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, server)
    local upstream = helpers.dbm('upstream')
    local method = helpers.dbm('method')
    local site = helpers.dbm('site')
    server.upstream = upstream:get(server.upstream_id)
    server.upstream.site = site:get(server.upstream.site_id)
    server.upstream.method = method:get(server.upstream.method_id)
    return setmetatable(server, mt)
end

return _M