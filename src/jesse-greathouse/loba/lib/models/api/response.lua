local _M = {}
local mt = { __index = _M }

function _M.new(self, data, meta)
    local response = {
        data = data,
        meta = meta
    }

    return setmetatable(response, mt)
end

return _M