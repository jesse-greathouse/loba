local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, user)
    return setmetatable(user, mt)
end

return _M