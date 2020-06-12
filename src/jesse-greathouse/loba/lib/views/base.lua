-- methods for producing each endpoint of the application
local helpers = require "helpers"
local env = require "env"

local _M = {}

local function get_template_name(tpl)
    return string.match(tpl, "([%a|_]+)%.html")
end

function _M.get_view(tpl, layout)
    local template = require "resty.template"
    if helpers.is_debug() then
        template.caching(false)
    end
    local view  = template.new(tpl, layout)

    view.page_id = get_template_name(tpl)
    view.uri = ngx.var.uri
    view.google_oauth_client_id = env.GOOGLE_OAUTH_CLIENT_ID
    view.qs = helpers.format_query(ngx.req.get_uri_args(), "&")

    return view
end

function _M.get_error_view(err, tpl, layout)
    local view = _M.get_view(tpl, layout)
    view.title = err.message
    view.error = err
    return view
end

function _M.get_session()
    local session = require "resty.session".open()
    session.data.ip = ngx.var.remote_addr
    session:save()
    return session;
end

return _M