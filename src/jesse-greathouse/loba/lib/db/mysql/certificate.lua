local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_certificates")
end

function _M:get(id)
    return base.get(self, "select_certificate_by_id", id)
end

function _M:find_by_uptream_list(list)
    return base.find_by_list(self, "select_certificates_by_upstream_list", list)
end

function _M:get_by_upstream(id)
    local res, err = self.db:execute(self:get_statement("select_certificate_by_upstream"), id)
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

function _M:insert_key(args)
    local id = base.insert(self, "insert_certificate_key",
                                    args.upstream_id,
                                    args.key)
    return self:get(id)
end

function _M:insert_certificate(args)
    local id = base.insert(self, "insert_certificate_certificate",
                                    args.upstream_id,
                                    args.certificate)
    return self:get(id)
end

function _M:insert(args)
    if not args.key then return _M.insert_certificate(self, args) end
    if not args.certificate then return _M.insert_key(self, args) end
    local id = base.insert(self, "insert_certificate",
                                    args.upstream_id,
                                    args.certificate,
                                    args.key)
    return self:get(id)
end

function _M:update_key(args, id)
    local _ = base.update(self, "update_certificate_key_by_id",
                                    args.upstream_id,
                                    args.key,
                                    id)
    return self:get(id)
end

function _M:update_certificate(args, id)
    local _ = base.update(self, "update_certificate_certificate_by_id",
                                    args.upstream_id,
                                    args.certificate,
                                    id)
    return self:get(id)
end

function _M:update(args, id)
    if not args.key then return _M.update_certificate(self, args, id) end
    if not args.certificate then return _M.update_key(self, args, id) end
    local _ = base.update(self, "update_certificate_by_id",
                                    args.upstream_id,
                                    args.certificate,
                                    args.key,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_certificate_by_id", id)
end

function _M.new(self)
    self = base:new()
    return setmetatable(self, mt)
end

setmetatable( _M, { __index = base } )

return _M