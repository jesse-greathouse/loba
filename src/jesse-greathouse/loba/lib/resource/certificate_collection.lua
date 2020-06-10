local helpers = require "helpers"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M.new(self, rs)

  -- Transform the certificate and key data to urls
  for i, _ in ipairs(rs) do
    rs[i].certificate = helpers.cert_download_url(rs[i])
    rs[i].key = helpers.key_download_url(rs[i])
  end

  return setmetatable(rs, mt)
end

return _M