local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_upstreams")
end

function _M:find(args)
    return base.find(self, "select_upstreams", args)
end

function _M:get(id)
    return base.get(self, "select_upstream_by_id", id)
end

function _M:find_by_list(list)
    return base.find_by_list(self, "select_upstream_by_list", list)
end

function _M:get_by_site(id)
    local res, err = self.db:execute(self:get_statement("select_upstream_by_site"), id)
    if err then
        ngx.log(ngx.ERR, "select failed.", err)
        return ngx.exit(500)
    end

    -- If not empty, only return one result
    if next(res) ~= nil then
        return res[1];
    end

    return nil
end

function _M:insert(args)
    local id = base.insert(self, "insert_upstream",
                                    args.site_id,
                                    args.method_id,
                                    args.hash,
                                    args.consistent)
    return self:get(id)
end

function _M:update(args, id)
    local _ = base.update(self, "update_upstream_by_id",
                                    args.site_id,
                                    args.method_id,
                                    args.hash,
                                    args.consistent,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_upstream_by_id", id)
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M