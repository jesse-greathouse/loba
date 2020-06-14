local base = require "views.api.base"
local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:get_domain(domain)
    local db = helpers.dbm(self.resource_name)
    local resource = helpers.resource(self.resource_name)

    local o = db:get_domain(domain)
    if not o then
        self:not_found("A %s, with the domain: %s, was not found.", self.resource_name, domain)
    else
        if not resource then
            return self:response(o)
        else
            self:response(resource:new(o))
        end
    end
end

function _M.new(self, route)
    return setmetatable(base:new('site', route), mt)
end

setmetatable( _M, { __index = base } )

return _M