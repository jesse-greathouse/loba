-- methods for producing each endpoint of the application
local helpers = require "helpers"
local base = require "views.base"

local HomeView = {}

function HomeView.index()
    local session = base.get_session()
    local view = base.get_view("index.html")

    -- Dress the view
    view.title = "Loba"
    view:render()
end

function HomeView.error()
    local view = base.get_view("error.html")

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

return HomeView