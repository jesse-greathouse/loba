local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, certificate)
    local upstream = helpers.dbm('upstream')
    certificate.upstream = upstream:get(certificate.upstream_id)
    return setmetatable(certificate, mt)
end

return _M