local base = require "views.api.base"
local cjson = require "cjson"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:get_post()
    local args, err = base.get_post(self)
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    -- workaround for db:execute problem
    if args.hash == ngx.null then
        args.hash = ""
    end

    return args, err
end

function _M.new(self, route)
    return setmetatable(base:new('upstream', route), mt)
end

setmetatable( _M, { __index = base } )

return _M