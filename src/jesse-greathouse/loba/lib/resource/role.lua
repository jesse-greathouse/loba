local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, role)
    return setmetatable(role, mt)
end

return _M