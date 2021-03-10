local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:role_list_by_user(user_id)
  local t = {}
  local res, err = self.db:execute(self:get_statement("select_role_list_by_user"), user_id)
  if err then
    ngx.log(ngx.ERR, "select failed.", err)
    return ngx.exit(500)
  end

  for _, v in ipairs(res) do
    t[#t+1] = v.role
  end

  return t
end

function _M.new(self)
    self = base:new()
    return setmetatable(self, mt)
end

setmetatable( _M, { __index = base } )

return _M