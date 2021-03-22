local setmetatable = setmetatable
local cjson = require "cjson"

local _M = {}

function _M.new(self, rs)
    return setmetatable(rs, cjson.array_mt)
end

return _M