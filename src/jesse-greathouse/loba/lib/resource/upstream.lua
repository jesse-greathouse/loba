local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, upstream)
    local server = helpers.dbm('server')
    local site = helpers.dbm('site')
    local method = helpers.dbm('method')
    upstream.servers = server:get_by_upstream(upstream.id)
    upstream.site = site:get(upstream.site_id)
    upstream.method = method:get(upstream.method_id)
    return setmetatable(upstream, mt)
end

return _M