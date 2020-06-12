local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, token)
    local user = helpers.dbm('user')
    token.user = user:get(token.user_id)

    return setmetatable(token, mt)
end

return _M