local mod = get_mod("kill_tracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true, -- The nameplate require hook needs this
	options = {
		widgets = {
			{
				setting_id = "kill_counter",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_kill_animation",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "show_kill_combo",
						type = "checkbox",
						default_value = true,
					},
				},
			}
		},
	},
}
