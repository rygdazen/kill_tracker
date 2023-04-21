return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`kill_tracker` encountered an error loading the Darktide Mod Framework.")

		new_mod("kill_tracker", {
			mod_script       = "kill_tracker/scripts/mods/kill_tracker/kill_tracker",
			mod_data         = "kill_tracker/scripts/mods/kill_tracker/kill_tracker_data",
			mod_localization = "kill_tracker/scripts/mods/kill_tracker/kill_tracker_localization",
		})
	end,
	packages = {},
}
