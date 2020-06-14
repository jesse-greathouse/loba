local base = require "views.api.base"
local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:get_new()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local token = helpers.factory_token()

    local o = db:get_new(token)
    if not o then
        self:not_found("A %s, with the token: %s, could not be created.", self.resource_name, token)
    else
        if not resource then
            return self:response(o)
        else
            self:response(resource:new(o))
        end
    end
end

function _M:get_token()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local r = self:route_params()

    local o = db:get_token(r.token)
    if not o then
        self:not_found("A %s, with the token: %s, was not found.", self.resource_name, r.token)
    else
        if not resource then
            return self:response(o)
        else
            self:response(resource:new(o))
        end
    end
end

function _M:post()
    local db = helpers.dbm(self.resource_name)
    local cjson = require "cjson"
    local resource = helpers.resource(self.resource_name)
    local args, err = self:get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    if args.token and db:get_token(args.token) then
        ngx.status = 400
        return self:error("Request argument had duplicate token. Token values must be unique.")
    end

    local o, err = db:insert(args)
    if err then
        ngx.log(ngx.ERR, "Creating ", self.resource_name, " failed: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    if resource then
        o = resource:new(o)
    end

    self:response(o, string.format("Created new %s.", self.resource_name), 201)
end

function _M.new(self, route)
    return setmetatable(base:new('token', route), mt)
end

setmetatable( _M, { __index = base } )

return _M