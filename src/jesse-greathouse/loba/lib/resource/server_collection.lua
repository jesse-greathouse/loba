local helpers = require "helpers"
local setmetatable = setmetatable
local null = ngx.null

local _M = {}
local mt = { __index = _M }

function _M.new(self, rs)
    local upstream = helpers.dbm('upstream')
    local method = helpers.dbm('method')
    local site = helpers.dbm('site')
    local list = {}
    local collation = {}

    -- Create a list of every id in the recordset
    for i, _ in ipairs(rs) do
        collation[rs[i].upstream_id] = {
            upstream = {
                method = null,
                site = null
            }
        }
        list[#list+1] = rs[i].upstream_id
    end

    -- Collate the list of upstreams
    for _, u in ipairs(upstream:find_by_list(list)) do
        collation[u.id].upstream = u
    end

    -- Collate the list of methods
    for _, m in ipairs(method:find_by_uptream_list(list)) do
        collation[m.upstream_id].upstream.method = m
    end

    -- Collate the list of sites
    for _, s in ipairs(site:find_by_uptream_list(list)) do
        collation[s.upstream_id].upstream.site = s
    end

    -- Add the collations to the collection
    for i, _ in ipairs(rs) do
        local c = collation[rs[i].upstream_id]
        rs[i].upstream = c.upstream
    end

    return setmetatable(rs, mt)
end

return _M