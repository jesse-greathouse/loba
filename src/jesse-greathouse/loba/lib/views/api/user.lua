local base = require "views.api.base"
local helpers = require "helpers"
local cjson = require "cjson"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:logout()
    local resource = helpers.resource('token')
    self.session:destroy()
    self:init_session()
    local token = self.session.data.token

    if resource then
        token = resource:new(token)
    end

    self:response(token, "User logged out.", 200)
end

function _M:login()
    local user, token
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource('token')
    local args, err = self:get_post()

    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    if args.email and args.password then
        user, err = db:login(args.email, args.password)
        if user then
            token = self:bind_user(user)
        end
    end

    if not token then
        ngx.log(ngx.ERR, "Authentication failed")
        return ngx.exit(401)
    end

    if resource then
        token = resource:new(token)
    end

    self:response(token, string.format("User: %s Logged in.", args.email), 200)
end

function _M:delete()
    local roles = helpers.dbm('role')
    local r = self:route_params()

    -- remove user_role associated with the user
    local _, err = roles:remove_user_roles(r.id)
    if err then
        ngx.log(ngx.ERR, "failed to remove user roles. ", err)
        return ngx.exit(500)
    end

    base.delete(self)
end

function _M.new(self, route)
    return setmetatable(base:new('user', route), mt)
end

setmetatable( _M, { __index = base } )

return _M