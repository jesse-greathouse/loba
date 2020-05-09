-- methods for producing each endpoint of the application
local cjson = require "cjson"
local helpers = require "helpers"
local base = require "views.base"

local HomeView = {}

function HomeView.index()
    local session = base.get_session()
    local view = base.get_view("index.html", "layout.html")

    -- Dress the view
    view.title      = "Loba | Home"
    view:render()
end

function HomeView.error()
    local view = base.get_view("error.html", "layout.html")

    view.status = ngx.var.status
    view.alert_level, view.message = helpers.get_error_info(view.status)
    if helpers.is_debug() then
        local errlog = require "ngx.errlog"
        view.trace = ""
        local loglines = errlog.get_logs(20)
        for k, v in pairs(loglines) do
            view.trace = view.trace .. v
          end
    end
    view.title      = "Loba  | " .. view.status .. " " .. view.message
    view:render()
end

return HomeView