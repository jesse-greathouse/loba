-- methods for producing each endpoint of the application
local helpers = require "helpers"
local base = require "views.base"

local _M = {}
local mt = { __index = _M }

function _M:index()
    local view = self:get_view("index.html")

    -- Dress the view
    view.title = "Loba"
    view:render()
end

function _M:error()
    local view = self:get_view("error.html")

    view.status = ngx.var.status
    view.alert_level, view.message = helpers.get_error_info(view.status)
    if helpers.is_debug() then
        local trace = helpers.get_stacktrace()
        if next(trace) ~= nil then
            view.trace = trace
        end
    end

    view.title = "Loba  | " .. view.status .. " " .. view.message

    view:render()
end

function _M.new(self)
    return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M