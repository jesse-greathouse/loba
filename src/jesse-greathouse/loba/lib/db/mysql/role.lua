local base = require "db.mysql.base"
local setmetatable = setmetatable

local _M = {}
local mt = { __index = _M }

function _M:all()
  return base.all(self, "select_role")
end

function _M:get(id)
  return base.get(self, "select_role_by_id", id)
end

function _M:get_by_user(id)
  local res, err = self.db:execute(self:get_statement("select_role_by_user_id"), id)
  if err then
      ngx.log(ngx.ERR, "select failed.", err)
      return ngx.exit(500)
  end

  return res
end

function _M:find(args)
  return base.find(self, "select_role", args)
end

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

function _M:role_by_user_list(list)
  local t = {}
  local res, err = base.find_by_list(self, ("select_role_by_user_list"), list)
  if err then
    ngx.log(ngx.ERR, "select failed.", err)
    return ngx.exit(500)
  end

  return res
end

function _M:role_list_by_user_list(list)
  local t = {}
  local res, err = base.find_by_list(self, ("select_role_list_by_user_list"), list)
  if err then
    ngx.log(ngx.ERR, "select failed.", err)
    return ngx.exit(500)
  end

  for _, v in ipairs(res) do
    t[#t+1] = { name = v.role, user_id = v.user_id }
  end

  return t
end

function _M:insert(args)
  local id = base.insert(self, "insert_role",
                                  args.role_id,
                                  args.user_id)
  return self:get(id)
end

function _M:update(args, id)
  local _ = base.update(self, "update_role",
                                  args.role_id,
                                  args.user_id,
                                  id)
  return self:get(id)
end

function _M:delete(id)
  return base.update(self, "delete_role_by_id", id)
end

function _M.new(self)
  return setmetatable(base:new(), mt)
end

setmetatable( _M, { __index = base } )

return _M