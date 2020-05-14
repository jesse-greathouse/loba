-- Collection of general use functions specific to this application
local setmetatable = setmetatable

local _M = { }
local mt = { __index = _M }

function _M.new(self)
    local mysql = require "resty.mysql"
    local env = require "env"
    local query = require "query":new(env)
    local db, err = mysql:new()
    if not db then
        return nil, err
    end

    db:set_timeout(1000) -- 1 sec

    local ok, err, errcode, sqlstate = db:connect{
        host = env.DB_HOST,
        port = env.DB_PORT,
        database = env.DB_NAME,
        user = env.DB_USER,
        password = env.DB_PASSWORD,
        charset = "utf8",
        max_packet_size = 1024 * 1024,
    }

    if not ok then
        return nil, err
    end

    return setmetatable({ db = db, env = env }, mt)
end

return _M