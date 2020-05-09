-- helper functions for accplimplishing tasks

local Helpers = {}

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

-- function for producing the search url for demotivational images
function Helpers.get_search_url(query)
    local base_url = "https://www.googleapis.com/customsearch/v1?"
    local params = {
        q       = query,
        imgType = "photo"
    }
    local url = base_url .. Helpers.format_query(params)
    return url
end

function Helpers.in_array(t, val)
    for _, v in ipairs(t) do
        if v == val then
            return true
        end
    end

    return false
end

function Helpers.is_debug()
    -- ngx.var are always string
    return ngx.var.DEBUG == "true"
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

function Helpers.model_set_defaults(o, defaults)
    for key, val in pairs(defaults) do
        if not o[key] then
            if type(val) == "function" then
                o[key] = val(o)
            else
                o[key] = val
            end
        end
    end
    return o
end

function Helpers.tablelength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function  Helpers.get_google_rpp()
    -- google searches are 10 records per page
    -- google image searches are 20 rpp
    local rpp = 10
    local args = ngx.req.get_uri_args()

    if args.tbm and args.tbm == "isch" then
        rpp = 20
    end

    return rpp
end

function Helpers.google_serp_start_indexes()
    local rpp = Helpers.get_google_rpp()
    local current_start = 0
    local previous_start = 0
    if ngx.var.arg_start then
        current_start = tonumber(ngx.var.arg_start)
    end

    if (current_start > rpp) then
        previous_start = current_start - rpp
    end

    local next_start = current_start + rpp
    return current_start, previous_start, next_start
end

function Helpers.cache_adjacent_google_serp()
    local rpp = Helpers.get_google_rpp()
    local args = ngx.req.get_uri_args()
    local url = table.concat({ngx.var.scheme, "://", ngx.var.host, ngx.var.uri})
    local current_start, previous_start, next_start = Helpers.google_serp_start_indexes()
    args.nospawn = "true"

    if not (args.start) then
        args.start = current_start
        Helpers.spawn_curl(url, args)
    end

    if current_start >= rpp then
        args.start = previous_start
        Helpers.spawn_curl(url, args)
    end

    args.start = next_start
    Helpers.spawn_curl(url, args)
end

function Helpers.spawn_curl(url, args)
    local ngx_pipe = require "ngx.pipe"
    local client = require "clients.google":new()
    local qs = Helpers.format_query(client:filter_args(args))
    ngx_pipe.spawn({"curl", url .. "?" .. qs})
end

return Helpers