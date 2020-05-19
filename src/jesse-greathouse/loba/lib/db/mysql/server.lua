local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_servers")
end

function _M:find(args)
    return base.find(self, "select_servers", args)
end

function _M:find_by_uptream_list(list)
    return base.find_by_list(self, "select_servers_by_upstream_list", list)
end

function _M:get(id)
    return base.get(self, "select_server_by_id", id)
end

function _M:get_by_upstream(id)
    local res, err = self.db:execute(self:get_statement("select_servers_by_upstream"), id)
    if err then
        ngx.log(ngx.ERR, "select failed.", err)
        return ngx.exit(500)
    end

    return res
end

function _M:insert(args)
    local id = base.insert(self, "insert_server",
                                    args.host,
                                    args.weight,
                                    args.backup,
                                    args.fail_timeout,
                                    args.max_fails,
                                    args.upstream_id)
    return self:get(id)
end

function _M:update(args, id)
    local _ = base.update(self, "update_server_by_id",
                                    args.host,
                                    args.weight,
                                    args.backup,
                                    args.fail_timeout,
                                    args.max_fails,
                                    args.upstream_id,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_server_by_id", id)
end

function _M.new(self)
    self = base:new()
    return setmetatable(self, mt)
end

setmetatable( _M, { __index = base } )

return _M