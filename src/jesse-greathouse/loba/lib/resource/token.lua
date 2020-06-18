local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, token)
    local udb = helpers.dbm('user')
    token.user = udb:get(token.user_id)

    if not token.user then
        token.user = ngx.null
    end

    return setmetatable(token, mt)
end

return _M