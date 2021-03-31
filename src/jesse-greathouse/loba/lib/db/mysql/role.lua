local base = require "db.mysql.base"
local cjson = require "cjson"
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

function _M:remove_user_roles(user_id)

  local res, err = self.db:execute(self:get_statement("delete_user_role_by_user"), user_id)
  if err then
    ngx.log(ngx.ERR, "delete_user_role_by_user failure. ", err)
    ngx.log(ngx.ERR, "user_id: ", user_id)
    return ngx.exit(500)
  end

  return res
end

function _M:remove_user_role(user_id, role_id)

  local res, err = self.db:execute(self:get_statement("delete_user_role_by_user_and_role"), user_id, role_id)
  if err then
    ngx.log(ngx.ERR, "delete_user_role_by_user_and_role failure. ", err)
    ngx.log(ngx.ERR, "user_id: ", user_id, " role_id: ", role_id)
    return ngx.exit(500)
  end

  return res
end

function _M:assign_user_role(user_id, role_id)
  local id, query
  local args = { user_id, role_id, id }
  local res, err = self.db:execute(self:get_statement("select_user_role_by_user_and_role"), unpack(args))
  if err then
    ngx.log(ngx.ERR, "select_user_role_by_user_and_role failed.", err)
    return ngx.exit(500)
  end

  local i = next(res)

  if i then
    id = res[i].id
    args[#args+1] = id
    query = "update_user_role"
  else
    query = "insert_user_role"
  end

  res, err = self.db:execute(self:get_statement(query), unpack(args))
  if err then
    ngx.log(ngx.ERR, query, " failure. ", err)
    ngx.log(ngx.ERR, "args: ", cjson.decode(args))
    return ngx.exit(500)
  end

  if (res.insert_id > 0) then
    id = res.insert_id
  end

  return { id = id, user_id = user_id, role_id = role_id }
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