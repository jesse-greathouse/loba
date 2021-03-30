local helpers = require "helpers"
local setmetatable = setmetatable
local cjson = require "cjson"

local _M = {}
local mt = { __index = _M }

function _M.new(self, rs)
    local role = helpers.dbm('role')
    local list = {}
    local collation = {}

    -- Create a list of every id in the recordset
    for i, _ in ipairs(rs) do
        collation[rs[i].id] = {
            roles = {},
        }
        list[#list+1] = rs[i].id
    end

    -- Collate the list of roles
    for _, r in ipairs(role:role_by_user_list(list)) do
        collation[r.user_id].roles[#collation[r.user_id].roles + 1] = r.role
    end

    -- Add the collations to the collection
    for i, _ in ipairs(rs) do
        -- if roles is empty, set it to an empty json array
        if #collation[rs[i].id].roles < 1 then
            rs[i].roles = cjson.empty_array
        else
            rs[i].roles = collation[rs[i].id].roles
        end
    end

    return setmetatable(rs, mt)
end

return _M