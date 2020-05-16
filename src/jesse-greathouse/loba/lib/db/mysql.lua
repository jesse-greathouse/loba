-- Collection of general use functions specific to this application
local setmetatable = setmetatable

local _M = { }
local mt = { __index = _M }

function _M:insert_site(args)
    local res, err = self.db:execute(self:get_statement("insert_site"), args.domain, args.active)
    if err then
        ngx.log(ngx.ERR, "execute failed.", err)
        return ngx.exit(500)
    end

    return self:get_site(res.insert_id)
end

function _M:get_site(id)
    local res, err = self.db:execute(self:get_statement("select_site_by_id"), id)
    if err then
        ngx.log(ngx.ERR, "execute failed.", err)
        return ngx.exit(500)
    end

    -- If not empty, only return one result
    if next(res) ~= nil then
        return res[1];
    end

    return nil
end

function _M:get_sites()
    local res, err, errcode, sqlstate = self.db:query(self.query.select_sites)
    if not res then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    return res
end

-- A way of only preparing a statement a single time
function _M:get_statement(name)
    if self.statement[name] ~= nil then
        return self.statement[name]
    end

    local err
    self.statement[name], err = self.db:prepare(self.query[name])
    if err then
        ngx.log(ngx.ERR, "prepare failed:", err)
        return ngx.exit(500)
    end

    return self.statement[name]
end

function _M.new(self)
    local mysql = require "resty.mysql"
    local env = require "env"
    local query = require "query":new(env)
    local db, err = mysql:new()
    local statement = {}

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

    return setmetatable({ db = db, env = env, query = query, statement = statement}, mt)
end

return _M