local cjson = require "cjson"
local view = require "views.api.base"

local ApiSiteView = {
    uri_base = "/site"
}

local function route(pstring)
    return ApiSiteView.uri_base .. pstring
end

function ApiSiteView.get()
    local db = view.dbm()
    view.response(db:get_sites())
end

function ApiSiteView.post()
    local db = view.dbm()
    local args, err = view.get_post()
    if err then
        ngx.log(ngx.ERR, "bad post args: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    local site, err = db:insert_site(args)
    if err then
        ngx.log(ngx.ERR, "Creating site failed: ", cjson.encode(args), " ", err)
        return ngx.exit(500)
    end

    view.response(site, "Created new site.", 201)
end

function ApiSiteView.get_id()
    local db = view.dbm()
    local rparams =view.route_params(route("/:id"))

    local site = db:get_site(rparams.id)
    if not site then
        view.not_found("A site, with the id: %s, was not found.", rparams.id)
    else
        view.response(site)
    end
end

function ApiSiteView.put()
    local db = view.dbm()
    local rparams =view.route_params(route("/:id"))

    local site = db:get_site(rparams.id)
    if not site then
        view.not_found("A site, with the id: %s, was not found.", rparams.id)
    else
        view.response(site)
    end
end

function ApiSiteView.delete()
    local db = view.dbm()
    local rparams =view.route_params(route("/:id"))

    local site = db:get_site(rparams.id)
    if not site then
        view.not_found("A site, with the id: %s, was not found.", rparams.id)
    else
        view.response(site)
    end
end


return ApiSiteView;