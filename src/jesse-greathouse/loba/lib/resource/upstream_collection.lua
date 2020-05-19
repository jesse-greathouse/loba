local helpers = require "helpers"
local setmetatable = setmetatable
local null = ngx.null

local _M = {}
local mt = { __index = _M }

function _M.new(self, rs)
    local server = helpers.dbm('server')
    local method = helpers.dbm('method')
    local site = helpers.dbm('site')
    local list = {}
    local collation = {}

    -- Create a list of every id in the recordset
    for i, _ in ipairs(rs) do
        collation[rs[i].id] = {
            servers = {},
            method = null,
            site = null
        }
        list[#list+1] = rs[i].id
    end

    -- Collate the list of methods
    for _, m in ipairs(method:find_by_uptream_list(list)) do
        collation[m.upstream_id].method = m
    end

    -- Collate the list of sites
    for _, s in ipairs(site:find_by_uptream_list(list)) do
        collation[s.upstream_id].site = s
    end

     -- Collate the list of servers
     for _, s in ipairs(server:find_by_uptream_list(list)) do
        collation[s.upstream_id].servers[#collation[s.upstream_id].servers + 1] = s
    end

    -- Add the collations to the collection
    for i, _ in ipairs(rs) do
        local c = collation[rs[i].id]
        rs[i].servers = c.servers
        rs[i].method = c.method
        rs[i].site = c.site
    end

    return setmetatable(rs, mt)
end

return _M