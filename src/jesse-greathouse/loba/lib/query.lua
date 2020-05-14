-- static set of queries defined for the ngx.req.append_body

local _M = { }
local mt = { __index = _M }

function _M.new(self, env)
    local queries = {}

    for fname in dir(".") do
        print(fname)
    end

    

    return setmetatable(queries, mt)
end