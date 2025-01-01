local mod = get_mod("kill_tracker")

-- color, taken from "True Level"

local option_table = {
    color = {},
}

local _is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(option_table.color) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    if not _is_duplicated(Color[name](255, true)) then
        option_table.color[#option_table.color + 1] = { text = name, value = name }
    end
end

table.sort(option_table.color, function(a, b)
    return a.text < b.text
end)

table.insert(option_table.color, 1, { text = "terminal_text_header", value = "terminal_text_header" })

local data = {
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
						setting_id 		= "show_kill_combos",
						type 			= "checkbox",
						default_value 	= true,
					},
					{
						setting_id 		= "show_cringe",
						type 			= "checkbox",
						default_value 	= true,
					},
					{
						setting_id      = "cringe_factor",
						type            = "numeric",
						default_value   = 100,
						range           = {50, 500},
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
					{
						setting_id 		= "anim_transparency",
						type 			= "numeric",
						default_value 	= 255,
						range 			= { 0, 255 },
					},
					{
						setting_id 		= "anim_color",
						type 			= "dropdown",
						default_value 	= "terminal_text_header",
						options 		= table.clone(option_table.color),
					},
					{
						setting_id		= "label_size",
						type			= "dropdown",
						default_value	= "label_size_default",
						options			= {
											{ text = "largest", value = "label_size_largest" },
											{ text = "large", value = "label_size_large" },
											{ text = "default", value = "label_size_default" },											
											{ text = "small", value = "label_size_small" },
										}
					},
				},
			}
		},
	},
}

return data