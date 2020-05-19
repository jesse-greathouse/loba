local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_sites")
end

function _M:find(args)
    return base.find(self, "select_sites", args)
end

function _M:find_by_uptream_list(args)
    return base.find_by_list(self, "select_sites_by_upstream_list", args)
end

function _M:get(id)
    return base.get(self, "select_site_by_id", id)
end

function _M:insert(args)
    local id = base.insert(self, "insert_site",
                                    args.domain,
                                    args.active)
    return self:get(id)
end

function _M:update(args, id)
    local _ = base.update(self, "update_site_by_id",
                                    args.domain,
                                    args.active,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_site_by_id", id)
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M