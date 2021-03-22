local base = require "views.api.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, route)
    return setmetatable(base:new('role', route), mt)
end

setmetatable( _M, { __index = base } )

return _M