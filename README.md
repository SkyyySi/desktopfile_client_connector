# .desktop-client connector

Allows to "link up" clients with their corrosponding .desktop file.

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

dcc:update_desktopfile_cache_async(function(apps)
	--- Print the .desktop file path and app name of the alphabetically first app
	print(("%s -> %s"):format(apps[1].file, apps[1].Name))
end)
```

 - Locate the path of a .desktop file
```lua
local dcc = require("desktopfile_client_connector")

dcc:update_desktopfile_cache_async(function(apps)
	--- Get the app that corresponds to "firefox.desktop".
	--- Note: This assumes that you have firefox installed.
	print(("%s -> %s"):format("firefox.desktop", dcc.desktopfile_location_cache["firefox.desktop"].file))
end)
```
