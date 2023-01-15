local gears     = require("gears")
local beautiful = require("beautiful")

--- A patched version of the build in menubar.utils that adresses some
--- missing features and makes some other small modifications
local menubar_utils = require(... .. ".menubar_utils")

local bm = require("desktopfile_client_connector.better-lua-modules.src")
local module = bm.create_module {
	name = "SkyyySi.SlimeOS-awesome.desktopfile_client_connector",
}

module.gnome_favorites = require(... .. ".gnome_favorites")

module.generic_app_icon = gears.surface.load_silently(menubar_utils.lookup_icon("application-x-executable") or beautiful.awesome_icon)

module.desktopfile_location_cache = {}
function module:update_desktopfile_location_cache(apps, app_dirs)
	local app_dirs_enum = {}
	for k, v in pairs(app_dirs) do app_dirs_enum[v] = k end
	setmetatable(app_dirs_enum, {
		__index = function(self2, k)
			return rawget(self2, k) or 999999999
		end
	})

	for _, app in pairs(apps) do
		local app_path, app_file = app.file:match("(.*)/(.*)")

		local old_app = self.desktopfile_location_cache[app_file]
		if old_app then
			local old_app_path, old_app_file = old_app.file:match("(.*)/(.*)")
			--- smaller means higher priority
			if app_dirs_enum[app_file] < app_dirs_enum[old_app_file] then
				self.desktopfile_location_cache[app_file] = app
			end
		else
			self.desktopfile_location_cache[app_file] = app
		end
	end
end

module.desktopfile_cache = {}

function module:desktopfile_cache_is_empty()
	return next(self.desktopfile_cache) == nil
end

function module:update_desktopfile_cache(callback, do_not_regenerate)
	if not self:desktopfile_cache_is_empty() and do_not_regenerate then
		callback(self)
		return
	end

	local app_dirs = {}
	do
		local data_dirs = gears.filesystem.get_xdg_data_dirs()
		for k, dir in ipairs(data_dirs) do
			--- Clean the paths to always be in `/foo/bar/biz/baz` format
			data_dirs[k] = dir:gsub("[/]+", "/"):gsub("[/]+$", "")
		end

		do
			local share_dir = os.getenv("HOME").."/.local/share"
			local has_dir = false
			for _, dir in ipairs(data_dirs) do
				if dir == share_dir then
					has_dir = true
					break
				end
			end
			if not has_dir then
				table.insert(data_dirs, 1, share_dir)
			end
		end

		do
			local share_dir = "/usr/share"
			local has_dir = false
			for _, dir in ipairs(data_dirs) do
				if dir == share_dir then
					has_dir = true
					break
				end
			end
			if not has_dir then
				table.insert(data_dirs, share_dir)
			end
		end

		for _, dir in ipairs(data_dirs) do
			table.insert(app_dirs, dir.."/applications/")
		end
	end

	local function assemble_app_list(apps)
		for k, _ in pairs(self.desktopfile_cache) do
			self.desktopfile_cache[k] = nil
		end

		--- Remove all desktop entries that aren't supposed to be shown
		for _, app in ipairs(apps) do
			if app.show then
				table.insert(self.desktopfile_cache, app)
			end

			app.icon_path = app.icon_path or module.generic_app_icon
		end

		table.sort(self.desktopfile_cache, function(a, b)
			return (a.Name or ""):lower() < (b.Name or ""):lower()
		end)

		callback(self.desktopfile_cache)

		self:update_desktopfile_location_cache(self.desktopfile_cache, app_dirs)
	end

	do
		local parsed_apps = {}
		local function proceed(k)
			menubar_utils.parse_dir(app_dirs[k], function(parsed_apps_temp)
				parsed_apps = gears.table.join(parsed_apps, parsed_apps_temp)
				local next_k, next_v = next(app_dirs, k)
				if next_v then
					proceed(next_k)
				else
					assemble_app_list(parsed_apps)
				end
			end)
		end
		proceed(1)
	end
end

module.app_to_desktopdata_map = {}
function module:update_app_to_desktopdata_map(callback)
	self:update_desktopfile_cache(function(all_apps)
		if not all_apps then
			return
		end

		for _, app in pairs(all_apps) do
			local desktop_file

			if app.file then
				desktop_file = app.file:gsub("^.*/", ""):match("(.*)%.desktop$")
				self.app_to_desktopdata_map[desktop_file] = self.app_to_desktopdata_map[desktop_file] or app
			end

			local class = app.StartupWMClass or desktop_file
			if class then
				self.app_to_desktopdata_map[class] = self.app_to_desktopdata_map[class] or app
			end
		end

		callback(all_apps)
	end, true)
end

module:update_app_to_desktopdata_map(function() end)

return module
