local helpers = require "helpers"
local cjson = require "cjson"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, user)
    local role = helpers.dbm('role')
    local roles = role:role_list_by_user(user.id)
    if roles then
        user.roles = roles
    else
        user.roles = cjson.empty_array
    end

    return setmetatable(user, mt)
end

return _M