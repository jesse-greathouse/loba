-- static set of queries defined for the ngx.req.append_body

local _M = { }
local mt = { __index = _M }

function _M.new(self)
    local queries = {}

    

    return setmetatable(queries, mt)
end