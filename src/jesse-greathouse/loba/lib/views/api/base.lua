-- methods for producing each endpoint of the api
local helpers = require "helpers"
local cjson = require "cjson"
local env = require "env"
local response = require "models.api.response"

local _M = {}

local mt = { __index = _M }

function _M:get()
    local db = self:dbm(self.resource)
    self:response(db:all())
end

function _M:post()
    local db = self:dbm(self.resource)
    local args, err = self:get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    local o, err = db:insert(args)
    if err then
        ngx.log(ngx.ERR, "Creating ", self.resource, " failed: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    self:response(o, string.format("Created new %s.", self.resource), 201)
end

function _M:get_id()
    local db = self:dbm(self.resource)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource, r.id)
    else
        self:response(o)
    end
end

function _M:put()
    local db = self:dbm(self.resource)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource, r.id)
    else
        local args, err = self:get_post()
        if err then
            ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
            return ngx.exit(500)
        end

        o, err = db:update(args, o.id)
        if err then
            ngx.log(ngx.ERR, "Updating ",  self.resource , ": ", r.id, " failed: ", cjson.encode(args), " ", err)
            return ngx.exit(500)
        end

        self:response(o, string.format("Updated %s with id: %s.", self.resource, o.id))
    end
end

function _M:delete()
    local db = self:dbm(self.resource)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource, r.id)
    else
        local _, err = db:delete(r.id)
        if err then
            ngx.log(ngx.ERR, "Deleting ", self.resource, " id: ", r.id, " failed. ", err)
            return ngx.exit(500)
        end
        self:response({}, string.format("Deleted %s with id: %s.", self.resource, r.id), 200)
    end
end

function _M:get_post()
    ngx.req.read_body()
    return ngx.req.get_post_args()
end

function _M:not_found(message, ...)
    ngx.status = 404
    return self:error(message:format(...))
end

function _M:response(data, message, status)
    local meta = {}

    if message ~= nil then
        meta["message"] = message
    end

    if status ~= nil then
        ngx.status = status
    end

    ngx.say(cjson.encode(response:new(data, meta)))
end

function _M:error(message)
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    local meta = {}

    meta.status = ngx.var.status
    meta.alert_level, meta.message = helpers.get_error_info(meta.status)

    if message ~= nil then
        meta.message = message
    end

    if next(args) ~= nil then
        meta.args = args
    end

    if helpers.is_debug() then
        local trace = helpers.get_stacktrace()
        if next(trace) ~= nil then
            meta.trace = trace
        end
    end

    ngx.say(cjson.encode(response:new({}, meta)))
end

function _M:dbm(name)
    local m = "db." .. env.DB_DRIVER .. "." .. name
    return require(m):new()
end

function _M:route_params()
    local params, err = helpers.parse_route_params(self.route)
    if err then
        ngx.log(ngx.ERR, "Failed to parse uri parameters in: ", params, " ", err)
        return ngx.exit(500)
    end

    return params
end

function _M.new(self, resource, route)
    return setmetatable({route = route, resource = resource}, mt)
end

return _M