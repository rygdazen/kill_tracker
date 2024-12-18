local mod = get_mod("kill_tracker")

return {
	name = mod:localize("mod_title"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
	options = {
		widgets = {
			{
				setting_id = "kill_combo_options",
				type = "group",
				sub_widgets = {
					{
						setting_id = "show_kill_combos",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id = "show_cringe",
						type = "checkbox",
						default_value = true,
					},
					{
						setting_id      = "cringe_factor",
						type            = "numeric",
						default_value   = 100,
						range           = {50, 1000},
					},
					{
						setting_id      = "min_kill_combo",
						type            = "numeric",
						default_value   = 0,
						range           = {0, 100},
					},
					{
						setting_id 		= "anim_container_x_offset",
						type 			= "numeric",
						default_value 	= 0,
						range 			= { -900, 900 },
					},
					{
						setting_id 		= "anim_container_y_offset",
						type 			= "numeric",
						default_value 	= -220,
						range 			= { -900, 900 },
					},
					--{
						--setting_id = "show_killstreaks",
						--type = "checkbox",
						--default_value = false,
					--},
				},
			}
		},
	},
}
