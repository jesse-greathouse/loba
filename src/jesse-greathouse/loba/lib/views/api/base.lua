-- methods for producing each endpoint of the api
local io = require "io"
local helpers = require "helpers"
local cjson = require "cjson"
local env = require "env"
local response = require "models.api.response"

local _M = {
    uri_base = "/api"
}

local function route(pstring)
    return _M.uri_base .. pstring
end

function _M.get_post()
    ngx.req.read_body()
    return ngx.req.get_post_args()
end

function _M.not_found(message, ...)
    return _M.response({}, message:format(...), 404)
end

function _M.response(data, message, status)
    local meta = {}

    if message ~= nil then
        meta["message"] = message
    end

    if status ~= nil then
        ngx.status = status
    end

    ngx.say(cjson.encode(response:new(data, meta)))
end

function _M.dbm()
    local dbmodule = "db." .. env.DB_DRIVER
    local db = require(dbmodule):new()
    return db
end

function _M.route_params(pstring)
    local params, err = helpers.parse_route_params(route(pstring))
    if err then
        ngx.log(ngx.ERR, "Failed to parse uri parameters in: ", params, " ", err)
        return ngx.exit(500)
    end

    return params
end

return _M