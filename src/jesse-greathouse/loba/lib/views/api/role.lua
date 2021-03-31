local base = require "views.api.base"
local helpers = require "helpers"
local cjson = require "cjson"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, route)
    return setmetatable(base:new('role', route), mt)
end

function _M:remove()
    local db = helpers.dbm(self.resource_name)
    local args, err = self:get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    local o, err = db:remove_user_role(args.user_id, args.role_id)
    if err then
        ngx.log(ngx.ERR, "Remove user role failed: user_id: ", args.user_id, " role_id: ", args.role_id, err)
        return ngx.exit(500)
    end

    self:response(o, "Removed user role.", 201)
end

function _M:assign()
    local db = helpers.dbm(self.resource_name)
    local args, err = self:get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    local o, err = db:assign_user_role(args.user_id, args.role_id)
    if err then
        ngx.log(ngx.ERR, "Assign user role failed: user_id: ", args.user_id, " role_id: ", args.role_id, err)
        return ngx.exit(500)
    end

    self:response(o, "Assigned user role.", 201)
end

setmetatable( _M, { __index = base } )

return _M