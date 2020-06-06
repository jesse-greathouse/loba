-- methods for producing each endpoint of the api
local helpers = require "helpers"
local cjson = require "cjson"
local response = require "models.api.response"

local _M = {}

local mt = { __index = _M }

local CONTENT_TYPE_X_WWW_FORM_URLENCODED    = "application/x-www-form-urlencoded"
local CONTENT_TYPE_APPLICATION_JSON         = "application/json"
local CONTENT_TYPE_MULTIPART_FORM_DATA      = "multipart/form-data"

function _M:get()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name .. "_collection")
    local rs = db:all()

    if not resource then
        return self:response(rs)
    else
        self:response(resource:new(rs))
    end
end

function _M:find(args)
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name .. "_collection")
    local rs = db:find(args)

    if not resource then
        return self:response(rs)
    else
        self:response(resource:new(rs))
    end
end

function _M:post()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local args, err = self:get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
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

function _M:get_id()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource_name, r.id)
    else
        if not resource then
            return self:response(o)
        else
            self:response(resource:new(o))
        end
    end
end

function _M:put()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource_name, r.id)
    else
        local args, err = self:get_post()
        if err then
            ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
            return ngx.exit(500)
        end

        o, err = db:update(args, o.id)
        if err then
            ngx.log(ngx.ERR, "Updating ",  self.resource_name , ": ", r.id, " failed: ", cjson.encode(args), " ", err)
            return ngx.exit(500)
        end

        if resource then
            o = resource:new(o)
        end

        self:response(o, string.format("Updated %s with id: %s.", self.resource_name, o.id))
    end
end

function _M:delete()
    local db = helpers.dbm(self.resource_name)
    local r = self:route_params()

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource_name, r.id)
    else
        local _, err = db:delete(r.id)
        if err then
            ngx.log(ngx.ERR, "Deleting ", self.resource_name, " id: ", r.id, " failed. ", err)
            return ngx.exit(500)
        end
        self:response({}, string.format("Deleted %s with id: %s.", self.resource_name, r.id), 200)
    end
end

--[[
    application supports 2 content types:
        application/x-www-form-urlencoded
        "application/json
]]
function _M:get_post()
    ngx.req.read_body()
    local h = ngx.req.get_headers()
    local err
    local ct = h['Content-Type'] or nil
    local post = ngx.req.get_post_args()
    if ct == CONTENT_TYPE_X_WWW_FORM_URLENCODED then
        return post, err
    elseif helpers.starts_with(ct, CONTENT_TYPE_MULTIPART_FORM_DATA) then
        local Multipart = require("multipart")
        local multipart_data = Multipart(ngx.var.request_body, ct)
        return multipart_data:get_all(), err
    elseif ct == CONTENT_TYPE_APPLICATION_JSON then
        -- loop through the weird table
        -- decode the first key that has a value of true
        for k, v in pairs(post) do
            if v then
                return cjson.decode(k)
            end
        end

        -- If we didn't find a viable post in the reuqest, exit
        ngx.log(ngx.ERR, "Request body had malformed payload for content-type: ", ct)
        ngx.exit(500)
    else
        ngx.log(ngx.ERR, "Request body had unsupported content-type: ", ct)
        ngx.exit(500)
    end
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

function _M:route_params()
    local params, err = helpers.parse_route_params(self.route)
    if err then
        ngx.log(ngx.ERR, "Failed to parse uri parameters in: ", params, " ", err)
        return ngx.exit(500)
    end

    return params
end

function _M.new(self, resource_name, route)
    return setmetatable({route = route, resource_name = resource_name}, mt)
end

return _M