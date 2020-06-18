-- methods for producing each endpoint of the application
local helpers = require "helpers"
local env = require "env"

local _M = {}

local mt = { __index = _M }

local function get_token()
    local db = helpers.dbm('token')
    local tokenstr = helpers.factory_token()
    local token = db:get_new(tokenstr)
    if not token then
        ngx.log(ngx.ERR, "Failure updating sha hash.")
        return ngx.exit(500)
    end
    return token
end

local function get_template_name(tpl)
    return string.match(tpl, "([%a|_]+)%.html")
end

function _M:bind_user(user)
    local db = helpers.dbm('token')
    return db:bind_user(user.id, self.session.data.token.token)
end

function _M:init_session()
    self.session = require "resty.session".new()
    self.session:open()

    if not self.session.data.token then
        self.session:start()
        self.session.data.ip = ngx.var.remote_addr
        self.session.data.token = get_token()
        self.session:save()
    end
end

function _M:get_view(tpl, layout)
    local template = require "resty.template"
    if helpers.is_debug() then
        template.caching(false)
    end
    local view  = template.new(tpl, layout)

    view.page_id = get_template_name(tpl)
    view.token = self.session.data.token.token
    view.google_oauth_client_id = env.GOOGLE_OAUTH_CLIENT_ID
    view.qs = helpers.format_query(ngx.req.get_uri_args(), "&")

    return view
end

function _M:get_error_view(err, tpl, layout)
    local view = _M.get_view(tpl, layout)
    view.title = err.message
    view.error = err
    return view
end

function _M:require_authentication()
    -- If there is no token associated with this session
    -- Force the user to the login screen
    if not self.session.data.token.user_id then
        ngx.redirect('/login')
    end
end

function _M.new(self)
    self:init_session()
    return setmetatable({}, mt)
end

return _M