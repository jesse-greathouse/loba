local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_users")
end

function _M:find(args)
    return base.find(self, "select_users", args)
end

function _M:get(id)
    return base.get(self, "select_user_by_id", id)
end

function _M:login(email, password)
    local res, err = self.db:execute(self:get_statement("select_user_by_login_credentials"),
                                                            email,
                                                            password)

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
    local id = base.insert(self, "insert_user",
                                    args.email,
                                    args.first_name,
                                    args.last_name,
                                    args.avatar_url)
    return self:get(id)
end

function _M:update(args, id)
    local _ = base.update(self, "update_user_by_id",
                                    args.email,
                                    args.first_name,
                                    args.last_name,
                                    args.avatar_url,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_user_by_id", id)
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M