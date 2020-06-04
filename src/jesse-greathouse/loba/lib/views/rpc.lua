-- methods for performing arbitrary procedures

local env = require "env"
local shell = require "resty.shell"
local helpers = require "helpers"
local cjson = require "cjson"
local response = require "models.api.response"

local _M = {}

local mt = { __index = _M }

function _M:compose_sites()
  local env_str = helpers.get_env_str(
    "PERL5LIB", "DB_DRIVER", "DB_NAME", "DB_HOST", "DB_USER", "DB_PASSWORD",
    "ETC", "PORT", "LOBA_DIR", "SQL_QUERY_DIR", "LOG_DIR"
  )
  local perl = helpers.get_perl_bin()
  local script = env.BIN .. "/" .. "compose-sites.pl"
  local cmd = string.format("%s %s %s", env_str, perl, script)
  local resp = {}

  local ok, stdout, stderr, reason, status = shell.run(cmd)

  if not ok then
    ngx.log(ngx.WARN, "reason: " .. reason)
    ngx.log(ngx.WARN, "status: " .. status)
    ngx.log(ngx.WARN, "stdout: " .. stdout)
    ngx.log(ngx.WARN, "cmd: " .. cmd)
    ngx.log(ngx.ERR, "stderr: " .. stderr)
    ngx.exit(500);
  end

  resp.stdout = stdout
  resp.stderr = stderr
  resp.status = status
  resp.ok = ok

  self:response(resp, string.format("run of %s exited with status: %s.", script, resp.status))
end

function _M:reload_nginx()
  local nginx = helpers.get_nginx_bin()
  local cmd = string.format("%s -s reload", nginx)
  local resp = {}

  local ok, stdout, stderr, reason, status = shell.run(cmd)

  if not ok then
    ngx.log(ngx.WARN, "reason: " .. reason)
    ngx.log(ngx.WARN, "status: " .. status)
    ngx.log(ngx.WARN, "stdout: " .. stdout)
    ngx.log(ngx.WARN, "cmd: " .. cmd)
    ngx.log(ngx.ERR, "stderr: " .. stderr)
    ngx.exit(500);
  end

  resp.stdout = stdout
  resp.stderr = stderr
  resp.status = status
  resp.ok = ok

  self:response(resp, string.format("run of %s exited with status: %s.", cmd, resp.status))
end

function _M:test_nginx()
  local nginx = helpers.get_nginx_bin()
  local conf = helpers.get_nginx_conf()
  local cmd = string.format("%s -c %s -t", nginx, conf)
  local resp = {}

  local ok, stdout, stderr, reason, status = shell.run(cmd)

  resp.stdout = stdout
  resp.stderr = stderr
  resp.status = status
  resp.ok = ok

  self:response(resp, string.format("run of %s exited with status: %s.", cmd, resp.status))
end

function _M:sscert()
  local cmd = {}
  local resp = {}
  local args = ngx.req.get_uri_args()
  if not args.domain then
    ngx.log(ngx.ERR, "A domain name is required to create a self-signed certificate.")
    ngx.exit(403);
  end

  cmd[#cmd+1] = "openssl req"
  cmd[#cmd+1] = "-x509 -nodes -days 365 -newkey rsa:2048"
  cmd[#cmd+1] = "-writerand " .. env.SSL .. "/.rnd"
  cmd[#cmd+1] = "-subj \"/CN=" .. args.domain .. "\""
  cmd[#cmd+1] = "-config " .. helpers.get_openssl_conf()
  cmd[#cmd+1] = "-keyout " .. env.SSL_PRIVATE .. "/" .. args.domain .. ".key"
  cmd[#cmd+1] = "-out " .. env.SSL_CERTS .. "/" .. args.domain .. ".crt"

  local ok, stdout, stderr, reason, status = shell.run(table.concat(cmd, " "))

  resp.stdout = stdout
  resp.stderr = stderr
  resp.status = status
  resp.ok = ok

  self:response(resp, string.format("run of %s exited with status: %s.", table.concat(cmd, " "), resp.status))
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

function _M:response(data, message, status)
  local meta = {}

  if message ~= nil then
      meta["message"] = message
  end

  if status ~= nil then
      ngx.status = status
  end

  ngx.say(cjson.encode(response:new(data, meta)))
end

function _M.new(self)
  return setmetatable({}, mt)
end

return _M