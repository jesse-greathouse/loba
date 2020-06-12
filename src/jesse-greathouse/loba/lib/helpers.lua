-- helper functions for accplimplishing tasks
local env = require "env"
local random = require "resty.random"
local str = require "resty.string"
local Helpers = {}

local CERT_DOWNLOAD_STR = "/download/certificate/%s"
local KEY_DOWNLOAD_STR = "/download/key/%s"

function Helpers.factory_token()
    local sha = require "resty.sha224":new()
    local ok = sha:update(random.bytes(8,true))
    if not ok then
        ngx.log(ngx.ERR, "Failure updating sha hash.")
        return ngx.exit(500)
    end
    return str.to_hex(sha:final())
end

function Helpers.get_perl_bin()
    return env.OPT .. "/perl/bin/perl"
end

function Helpers.get_nginx_bin()
    return env.OPT .. "/openresty/nginx/sbin/nginx"
end

function Helpers.get_nginx_conf()
    return env.ETC .. "/nginx/nginx.conf"
end

function Helpers.get_openssl_conf()
    return env.SSL .. "/openssl.cnf"
end

function Helpers.cert_download_url(certificate)
    if not certificate.certificate or certificate.certificate == ngx.null then
        return ngx.null
    end
    return CERT_DOWNLOAD_STR:format(certificate.id)
end

function Helpers.key_download_url(certificate)
    if not certificate.key or certificate.key == ngx.null then
        return ngx.null
    end
    return KEY_DOWNLOAD_STR:format(certificate.id)
end

-- Creates a string env var assignments
function Helpers.get_env_str(...)
    local args = {...}
    local env_str = ""

    for _, var in ipairs(args) do
        env_str = string.format("%s %s=%s", env_str, var, env[var])
    end

    return env_str
end

function Helpers.is_debug()
    -- ngx.var are always string
    return ngx.var.DEBUG == "true"
end

function Helpers.module_exists(name)
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.searchers or package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

function  Helpers.dbm(name)
    local m = "db." .. env.DB_DRIVER .. "." .. name
    if not Helpers.module_exists(m) then
        ngx.log(ngx.ERR, "Database module: ", m , " not found.")
        ngx.exit(500)
    end
    return require(m):new()
end

function  Helpers.resource(name)
    local m = "resource." .. name
    if Helpers.module_exists(m) then
        return require(m)
    else
        return false
    end
end

function Helpers.parse_route_params(route)
    local params = {}
    local pattern = "/([\\-A-Za-z0-9\\:]+)"
    local uri = ngx.var.request_uri
    local rit, err = ngx.re.gmatch(route, pattern, "i")
    if not rit then
        return route, err
    end

    local uit, err = ngx.re.gmatch(uri, pattern, "i")
    if not uit then
        return route, err
    end

    while true do
        local rm, err = rit()
        if err then
            return route, err
        end

        local um, err = uit()
        if err then
            return route, err
        end

        if not rm then
            -- no match found (any more)
            break
        end

        if not um then
            -- no match found (any more)
            break
        end

        if (rm[1]:find(":")) ~= nil then
            -- found a match
            local param = rm[1]:gsub(":", "")
            params[param] = um[1]
        end
    end

    return params, err;
end

local function encode(str)
    return (str:gsub("([^A-Za-z0-9%_%.%-%~])", function(v)
            return string.upper(string.format("%%%02x", string.byte(v)))
    end))
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

-- for query values, prefer + instead of %20 for spaces
local function encodeValue(str)
    str = encode(str)
    return str:gsub("%%20", "+")
end

function Helpers.urldecode(url)
    return url:gsub("%%(%x%x)", hex_to_char)
end

--- builds the querystring
-- @param tab The key/value parameters
-- @param sep The separator to use (optional)
-- @param key The parent key if the value is multi-dimensional (optional)
-- @return a string representing the built querystring
function Helpers.format_query(tab, sep, key)
    local query = {}
    if not sep then
        sep = "&"
    end
    local keys = {}
    for k in pairs(tab) do
        keys[#keys+1] = k
    end
    table.sort(keys)
    for _,name in ipairs(keys) do
        local value = tab[name]
        name = encode(tostring(name))
        if key then
            name = string.format("%s[%s]", tostring(key), tostring(name))
        end
        if type(value) == "table" then
            query[#query+1] = Helpers.format_query(value, sep, name)
        else
            value = encodeValue(tostring(value))
            if value ~= "" then
                query[#query+1] = string.format("%s=%s", name, value)
            else
                query[#query+1] = name
            end
        end
    end
    return table.concat(query, sep)
end

function Helpers.in_array(t, val)
    for _, v in ipairs(t) do
        if v == val then
            return true
        end
    end

    return false
end

function Helpers.calling_parent(level)
    if not level then
        level = 2
    end

    return debug.getinfo(level, "n").name
end

function Helpers.get_error_info(status)
    local statusnum = tonumber(status)
    local statusdefinitions = {
        [400] = "Bad Request",
        [401] = "Unauthorized",
        [402] = "Payment Required",
        [403] = "Forbidden",
        [404] = "Not Found",
        [405] = "Method Not Allowed",
        [406] = "Not Acceptable",
        [407] = "Proxy Authentication Required",
        [408] = "Request Timeout",
        [409] = "Conflict",
        [410] = "Gone",
        [411] = "Length Required",
        [412] = "Precondition Failed",
        [413] = "Payload Too Large",
        [414] = "URI Too Long",
        [415] = "Unsupported Media Type ",
        [416] = "Range Not Satisfiable",
        [417] = "Expectation Failed",
        [418] = "I'm a teapot",
        [421] = "Misdirected Request",
        [422] = "Unprocessable Entity",
        [423] = "Locked",
        [424] = "Failed Dependency",
        [425] = "Too Early",
        [426] = "Upgrade Required",
        [428] = "Precondition Required",
        [429] = "Too Many Requests",
        [431] = "Request Header Fields Too Large",
        [451] = "Unavailable For Legal Reasons",
        [500] = "Internal Server Error",
        [501] = "Not Implemented",
        [502] = "Bad Gateway",
        [503] = "Service Unavailable",
        [504] = "Gateway Timeout",
        [505] = "HTTP Version Not Supported",
        [506] = "Variant Also Negotiates",
        [507] = "Insufficient Storage",
        [508] = "Loop Detected",
        [510] = "Not Extended",
        [511] = "Network Authentication Required"
    }
    local alertlevel = "danger"
    if statusnum < 500 then
        alertlevel = "warning"
    end

    return alertlevel, statusdefinitions[statusnum]
end

function Helpers.tablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function Helpers.get_stacktrace()
    local numlines = 20
    local errlog = require "ngx.errlog"
    local loglines = errlog.get_logs(numlines)
    local trace = {}

    if next(loglines) ~= nil then
        for _, v in pairs(loglines) do
            if type(v) == "string" then
                for i in v:gmatch("[^\r\n]+") do
                    trace[#trace + 1] = i
                 end
            end
        end
    end

    return trace
end

function Helpers.starts_with(str, start)
    return str:sub(1, #start) == start
end

function Helpers.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

return Helpers