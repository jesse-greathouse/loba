local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, method)
    return setmetatable(method, mt)
end

return _M