local lgi = require("lgi")
local Gio = lgi.Gio

if not package.path:match(";../%?.lua") then
	package.path = ";../?.lua" .. package.path
end

local bm = require("desktopfile_client_connector.better-lua-modules.src")
local module = bm.create_module {
	name = "SkyyySi.SlimeOS-awesome.desktopfile_client_connector.gnome_favorites",
}

--- Check whether a given schema exists or not
---@param s string The name of the schema to check
---@return boolean
function module:schema_exists(s)
	s = s or "org.gnome.shell"

	for _, schema in pairs(Gio.Settings.list_schemas()) do
		if schema == s then
			return true
		end
	end

	return false
end

--- Get a list of all favorites
---@return string[]? favorites Either a list of favorites or nil
function module:get_all_favorites()
	local schema = "org.gnome.shell"

	if self:schema_exists(schema) then
		return Gio.Settings({ schema = schema }):get_strv("favorite-apps")
	end
end

--- Get a list of all favorites (like `get_all_favorites()`, but with a default
--- return value instead of nil)
---@return string[] favorites Either a list of favorites or an empty table
function module:get_all_favorites_or_empty_table()
	return self:get_all_favorites() or {}
end

--- Check wheter a given .desktop file (without path) is a favorite or not
---@param fav_name string The name of the .desktop file, for example "firefox.desktop"
---@return boolean
function module:is_favorite(fav_name)
	local schema = "org.gnome.shell"

	if self:schema_exists(schema) then
		local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")

		for _, fav in ipairs(favs) do
			if fav == fav_name then
				return true
			end
		end
	end

	return false
end

--- Add a .desktop file (without path) to the favorites list
---@param file_name string The name of the .desktop file, for example "firefox.desktop"
function module:add(file_name)
	local schema = "org.gnome.shell"

	if self:schema_exists(schema) then
		local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
		table.insert(favs, file_name)
		Gio.Settings({ schema = schema }):set_strv("favorite-apps", favs)
	end
end

--- Remove a .desktop file (without path) from the favorites list
---@param file_name string The name of the .desktop file, for example "firefox.desktop"
function module:remove(file_name)
	local schema = "org.gnome.shell"

	if self:schema_exists(schema) then
		local favs = Gio.Settings({ schema = schema }):get_strv("favorite-apps")
		for k, v in pairs(favs) do
			if v == file_name then
				table.remove(favs, k)
				break
			end
		end
		Gio.Settings({ schema = schema }):set_strv("favorite-apps", favs)
	end
end

return module
