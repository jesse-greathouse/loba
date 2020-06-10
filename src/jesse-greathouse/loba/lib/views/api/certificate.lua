local base = require "views.api.base"
local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:get_by_upstream()
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local r = self:route_params()

    local o = db:get_by_upstream(r.id)

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

function _M:remove(doc)
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)
    local r = self:route_params()
    local err

    local o = db:get(r.id)
    if not o then
        self:not_found("A %s, with the id: %s, was not found.", self.resource_name, r.id)
    else
        if doc == "key" then
            o, err = db:remove_key(o.id)
        elseif doc == "certificate" then
            o, err = db:remove_certificate(o.id)
        else
            ngx.log(ngx.ERR, "Called remove on unknown doc type: ", doc, "from: ",  self.resource_name , ": ", r.id)
            return ngx.exit(500)
        end

        if err then
            ngx.log(ngx.ERR, "Removing key from ",  self.resource_name , ": ", r.id, " failed: ", err)
            return ngx.exit(500)
        end

        if resource then
            o = resource:new(o)
        end

        self:response(o, string.format("Updated %s with id: %s.", self.resource_name, o.id))
    end
end

function _M:remove_key()
    self:remove("key")
end

function _M:remove_certificate()
    self:remove("certificate")
end

function _M.new(self, route)
    return setmetatable(base:new('certificate', route), mt)
end

setmetatable( _M, { __index = base } )

return _M;