-- methods for producing each endpoint of the api
local helpers = require "helpers"
local cjson = require "cjson"
local response = require "models.api.response"

local _M = {}

local mt = { __index = _M }

function _M:not_found(message, ...)
  ngx.status = 404
  return self:error(message:format(...))
end

function _M:certificate_file(file)
  local cdb = helpers.dbm('certificate')
  local sdb = helpers.dbm('site')
  local extension, content_type
  local r = self:route_params()

  -- Validate the file type
  if file == "certificate" then
    extension = ".crt"
    content_type = "application/x-x509-ca-cert"
  elseif file == "key" then
    extension = ".key"
    content_type = "application/pkcs8"
  else
    self:not_found("Unrecognized file type: %s", file)
  end

  -- Validate the url param
  if not r.id then self:not_found("A %s could not be located", file) end

  local certificate = cdb:get(r.id)
  if not certificate then
    self:not_found("A %s, with the id: %s, was not found.", file, r.id)
  else
    if certificate[file] then
      local site = sdb:get_by_upsream(certificate.upstream_id)
      ngx.header["Content-Type"] = content_type
      ngx.header["Content-Disposition"] = "inline; filename=\"" .. site.domain .. extension .."\""
      ngx.print(certificate[file])
    else
      -- The requested field was nil
      self:not_found("A %s, with the id: %s, was not found.", file, r.id)
    end
  end
end

function _M:certificate()
  self:certificate_file('certificate')
end

function _M:key()
  self:certificate_file('key')
end

function _M:error(message)
  ngx.req.read_body()
  local args = ngx.req.get_post_args()
  local meta = {}

  meta.status = ngx.var.status
  meta.alert_level, meta.message = helpers.get_error_info(meta.status)

  if message ~= nil then
    meta.message = message
  end

  if next(args) ~= nil then
    meta.args = args
  end

  if helpers.is_debug() then
    local trace = helpers.get_stacktrace()
    if next(trace) ~= nil then
      meta.trace = trace
    end
  end

  ngx.say(cjson.encode(response:new({}, meta)))
end

function _M:route_params()
  local params, err = helpers.parse_route_params(self.route)
  if err then
      ngx.log(ngx.ERR, "Failed to parse uri parameters in: ", params, " ", err)
      return ngx.exit(500)
  end

  return params
end

function _M.new(self, route)
  return setmetatable({route = route}, mt)
end

return _M