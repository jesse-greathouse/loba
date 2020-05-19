local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
    return base.all(self, "select_methods")
end

function _M:find(args)
    return base.find(self, "select_methods", args)
end

function _M:find_by_uptream_list(list)
    return base.find_by_list(self, "select_methods_by_upstream_list", list)
end

function _M:get(id)
    return base.get(self, "select_method_by_id", id)
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M