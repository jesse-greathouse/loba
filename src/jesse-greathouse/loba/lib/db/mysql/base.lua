local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

-- mysql data type
local MYSQL_AND_CONDITION   = "AND"
local MYSQL_OR_CONDITION    = "OR"

function _M._get_condition(self, cond)
    if not cond then
        return MYSQL_AND_CONDITION
    elseif cond:upper() == MYSQL_OR_CONDITION then
        return MYSQL_OR_CONDITION
    else
        return MYSQL_AND_CONDITION
    end
end

function _M.all(self, sname)
    local res, err, errcode, sqlstate = self.db:query(self.query[sname])
    if not res then
        ngx.log(ngx.ERR, "bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
        return ngx.exit(500)
    end

    return res
end

--[[
    Allows the retreival of records based with args table of k,v pairs

    query: "SELECT * FROM site;"
    with args = {domain = "www.mysite.com"}
    Will mutate query into "SELECT * FROM site WHERE domain = ?"
    Will also return the parameters as varargs in the correct order of placeholders

    cond argument can be MYSQL_AND_CONDITION or MYSQL_OR_CONDITION
    This will determine whether the args are inclusive or exclusive

    Supports the use of talbes with nested and/or conditions
    args = {
        {active = 1},
        {cond = or, args = {
            {domain = "dev.mysite.com"},
            {domain = "www.mysite.com"},
            {domain = "www.anothersite.com"}
        }}
    }

]]
function _M.find(self, sname, args, cond)
    local res, err = self.db:execute(self:get_statement(sname, args, cond))
    if err then
        ngx.log(ngx.ERR, "select failed.", err)
        return ngx.exit(500)
    end

    return res
end

--[[
    Allows the use of lists in a WHERE IN query
    e.g. SELECT * FROM `site` WHERE `id` IN (?)

    The number of parameter placeholders will be
    replaced by the number of elements in the list.
]]
function _M.find_by_list(self, sname, list)
    local res, err = self.db:execute(self:get_statement(sname, list))
    if err then
        ngx.log(ngx.ERR, "select failed.", err)
        return ngx.exit(500)
    end

    return res
end

function _M.get(self, sname, id)
    local res, err = self.db:execute(self:get_statement(sname), id)
    if err then
        ngx.log(ngx.ERR, "select failed.", err)
        return ngx.exit(500)
    end

    -- If not empty, only return one result
    if next(res) ~= nil then
        return res[1];
    end

    return nil
end

function _M.insert(self, sname, ...)
    local res, err = self.db:execute(self:get_statement(sname), ...)
    if err then
        ngx.log(ngx.ERR, "insert failed.", err)
        return ngx.exit(500)
    end

    return res.insert_id
end

function _M.update(self, sname, ...)
    local res, err = self.db:execute(self:get_statement(sname), ...)
    if err then
        ngx.log(ngx.ERR, "update failed.", err)
        return ngx.exit(500)
    end

    return res
end

function _M.delete(self, sname, id)
    local res, err = self.db:execute(self:get_statement(sname), id)
    if err then
        ngx.log(ngx.ERR, "delete failed.", err)
        return ngx.exit(500)
    end

    return res
end

--[[
    Supports the use of nested talbes nested and/or conditions
    args = {
        {active = 1},
        {cond = or, args = {
            {domain = "dev.mysite.com"},
            {domain = "www.mysite.com"},
            {domain = "www.anothersite.com"}
        }}
    }
]]
function _M:compose_where(t, cond, clause)
    local values = {}
    local closeme
    cond = self:_get_condition(cond)

    if not clause then
        closeme = true
        clause = " WHERE 1 AND ("
    end

    for j, e in ipairs(t) do

        -- if an args element exists then nested
        if e["args"] ~= nil then
            if not e["cond"] then e["conf"] = MYSQL_AND_CONDITION end
            local str, val = self:compose_where(e.args, e.cond, clause)

            if j ~= 1 then clause = clause .. ",  " .. cond end
            clause = clause .. "(" .. str .. ")"

            for i, _ in ipairs(val) do
                values[#values + 1] = val[i]
            end
        else
            for k, v in pairs(e) do
                if j ~= 1 then clause = clause .. ",  " .. cond end
                clause = " " .. k .. " = ?"
                values[#values + 1] = v
            end
        end
    end

    if closeme then
        clause = clause .. ");"
    end

    return clause, values
end

-- A way of only preparing a statement a single time
function _M:get_statement(name, args, cond)
    local where, placeholders
    local sname = name

    if type(args) == "table" then
        -- If args is an array use the from_list method
        -- If args is a table, dynamically compose the where clause
        if next(args) ~= nil then
            if args[1] ~= nil then
                sname = name .. "-list-" .. #args
                placeholders = ""
                for i = 1, #args do
                    if i ~= 1 then placeholders = placeholders .. ", " end
                    placeholders = placeholders .. "?"
                end
            else
                where, args = self:compose_where(args, cond)
                sname = name .. where:gsub("[%s%(%)].+", "-")
            end
        end
    end

    if not self.statement[sname] then
        local err
        local query = self.query[name]

        if where ~= nil then
            query = query:gsub(";", where)
        end

        if placeholders ~= nil then
            query = query:gsub("%(%?%)", "(" .. placeholders .. ")")
        end

        self.statement[sname], err = self.db:prepare(query)
        if err then
            ngx.log(ngx.ERR, "prepare failed:", err)
            return ngx.exit(500)
        end
    end

    if not args then args = {} end

    return self.statement[sname], unpack(args)
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

    return setmetatable({   db = db,
                            env = env,
                            query = query,
                            statement = statement}, mt)
end

return _M