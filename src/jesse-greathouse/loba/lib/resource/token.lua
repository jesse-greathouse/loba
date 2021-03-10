local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, token)
    local udb = helpers.dbm('user')
    local rdb = helpers.dbm('role')
    token.user = udb:get(token.user_id)

    if not token.user then
        token.user = ngx.null
    else
        token.user.roles = rdb:role_list_by_user(token.user.id)
    end

    return setmetatable(token, mt)
end

return _M