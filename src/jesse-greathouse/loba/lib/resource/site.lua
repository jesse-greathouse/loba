local helpers = require "helpers"
local setmetatable = setmetatable
local null = ngx.null

local _M = {}
local mt = { __index = _M }

function _M.new(self, site)
    local upstream = helpers.dbm('upstream')
    local server = helpers.dbm('server')
    local method = helpers.dbm('method')
    local supstream = upstream:get_by_site(site.id)
    if supstream then
        site.upstream = upstream:get_by_site(site.id)
        site.upstream.servers = server:get_by_upstream(site.upstream.id)
        site.upstream.method = method:get(site.upstream.method_id)
    else
        site.upstream = null
    end
    return setmetatable(site, mt)
end

return _M