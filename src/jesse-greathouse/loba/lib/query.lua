-- static set of queries defined for the ngx.req.append_body
local str = require "string"
local io = require "io"
local _M = {}
local mt = { __index = _M }

function _M.new(self, env)
    local queries = {}

    for fname in dir(env.SQL_QUERY_DIR) do
        if fname ~= "." and fname ~= ".." then
            local uri = env.SQL_QUERY_DIR .. "/" .. fname
            -- Make the neame of the query the name of the file minus the ".sql"
            local qname = str.sub(fname, 0, -5)
            local file = io.open(uri, "r")
            local query = file:read("a")
            file:close()
            queries[qname] = query
        end
    end

    return setmetatable(queries, mt)
end

return _M