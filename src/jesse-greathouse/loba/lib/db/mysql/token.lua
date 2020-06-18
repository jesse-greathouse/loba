local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_tokens")
end

function _M:find(args)
    return base.find(self, "select_tokens", args)
end

function _M:get(id)
    return base.get(self, "select_token_by_id", id)
end

function _M:get_token(token)
    local res, err = self.db:execute(self:get_statement("select_token_by_token"), token)
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

function _M:get_new(token)
    local id = base.insert(self, "insert_token_new",token)
    return self:get(id)
end

function _M:insert(args)
    local id = base.insert(self, "insert_token",
                                    args.token,
                                    args.ttl,
                                    args.user_id,
                                    args.provider)
    return self:get(id)
end

function _M:bind_user(user_id, token)
    local _ = base.update(self, "update_token_user_by_token",
                                    user_id,
                                    token)
    return self:get_token(token)
end

function _M:update(args, id)
    local _ = base.update(self, "update_token_by_id",
                                    args.token,
                                    args.ttl,
                                    args.user_id,
                                    args.provider,
                                    id)
    return self:get(id)
end

function _M:delete(id)
    return base.update(self, "delete_token_by_id", id)
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M