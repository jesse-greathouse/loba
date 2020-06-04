local _M = { }

_M.DEBUG = ngx.var.DEBUG == "true"
_M.ENV = ngx.var.ENV
_M.SSL = ngx.var.SSL == "true"
_M.DIR = ngx.var.DIR
_M.BIN = ngx.var.BIN
_M.ETC = ngx.var.ETC
_M.OPT = ngx.var.OPT
_M.SRC = ngx.var.SRC
_M.TMP = ngx.var.TMP
_M.VAR = ngx.var.VAR
_M.WEB = ngx.var.WEB
_M.SSL = _M.ETC .."/ssl"
_M.SSL_PRIVATE = _M.SSL .."/private"
_M.SSL_CERTS = _M.SSL .."/certs"
_M.PORT = ngx.var.PORT
_M.ADMIN_EMAIL = ngx.var.ADMIN_EMAIL
_M.LOBA_DIR = ngx.var.LOBA_DIR
_M.SQL_QUERY_DIR = ngx.var.SQL_QUERY_DIR
_M.CACHE_DIR = ngx.var.CACHE_DIR
_M.LOG_DIR = ngx.var.LOG_DIR
_M.REDIS_HOST = ngx.var.REDIS_HOST
_M.DB_DRIVER = ngx.var.DB_DRIVER
_M.DB_NAME = ngx.var.DB_NAME
_M.DB_USER = ngx.var.DB_USER
_M.DB_PASSWORD = ngx.var.DB_PASSWORD
_M.DB_HOST = ngx.var.DB_HOST
_M.DB_HOST = ngx.var.DB_HOST
_M.DB_PORT = ngx.var.DB_PORT
_M.PERL5LIB = _M.OPT .."/perl/lib/perl5"

return _M