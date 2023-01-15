# .desktop-client connector

Allows to "link up" clients with their corrosponding .desktop files.
Made for the awesome window manager.

Installation:

Clone this repository into your `awesome` config directory. Make sure to
also download the submodules!

```bash
git clone https://github.com/SkyyySi/desktopfile_client_connector
cd desktopfile_client_connector
git submodule update
```

Usage:

 - Get the .desktop file data for an app
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_app_to_desktopdata_map(function(apps)
	--- Get the .desktop file that corresponds to the "firefox" class.
	--- Note: This assumes that you have firefox installed.
	print(("%s -> %s"):format("firefox", dcc.app_to_desktopdata_map["firefox"].Name))
end)
```

 - Get a list of all installed apps
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_desktopfile_cache(function(apps)
	--- Print the .desktop file path and app name of the alphabetically first app
	print(("%s -> %s"):format(apps[1].file, apps[1].Name))
end)
```

 - Locate the path of a .desktop file
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_desktopfile_cache(function(apps)
	--- Get the app that corresponds to "firefox.desktop".
	--- Note: This assumes that you have firefox installed.
	print(("%s -> %s"):format("firefox.desktop", dcc.desktopfile_location_cache["firefox.desktop"].file))
end)
```

---

For convenience, this module also bundles some functionality for working with GNOME favorite apps.
This is useful for, for example, a dock where you can pin apps, or a launcher.
These favorites will here be referred to as "pinned".

Usage:

- Check whether an app is pinned or not
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_desktopfile_cache(function(apps)
	--- Check whether "firefox.desktop" is pinned or not.
	--- Note: This assumes that you have firefox installed.
	print(dcc.gnome_favorites:is_favorite("firefox.desktop"))
end)
```

- Pin or unpin an app
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_desktopfile_cache(function(apps)
	--- Pin Firefox
	dcc.gnome_favorites:add("firefox.desktop")

	--- Remove Konsole (KDE terminal emulator)
	dcc.gnome_favorites:remove("org.kde.konsole.desktop")
end)
org.kde.konsole.desktop
```

If you want to listen to changes, you can do it this way:
```lua
awful.spawn.with_line_callback([[dconf watch /org/gnome/shell/favorite-apps]], {
	stdout = function(line)
		--- Your actions here...
	end,
})
```
