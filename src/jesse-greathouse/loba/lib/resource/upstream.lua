local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, upstream)
    local server = helpers.dbm('server')
    local site = helpers.dbm('site')
    local method = helpers.dbm('method')
    local certificate = helpers.dbm('certificate')
    upstream.servers = server:get_by_upstream(upstream.id)
    upstream.site = site:get(upstream.site_id)
    upstream.method = method:get(upstream.method_id)
    upstream.certificate = certificate:get_by_upstream(upstream.id)
    upstream.certificate.certificate = helpers.cert_download_url(upstream.certificate)
    upstream.certificate.key = helpers.key_download_url(upstream.certificate)

    if not upstream.certificate then upstream.certificate = ngx.null end

    return setmetatable(upstream, mt)
end

return _M