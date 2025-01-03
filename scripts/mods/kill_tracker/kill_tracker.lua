-- version 0.7.0

-- TODO: add setting for reset kills on death

local mod = get_mod("kill_tracker")

mod:io_dofile("kill_tracker/scripts/mods/kill_tracker/utils")

local Breed = mod:original_require("scripts/utilities/breed")

local hud_elements = {
	{
		filename = "kill_tracker/scripts/mods/kill_tracker/HudElementKillCount",
		class_name = "HudElementKillCount",
		visibility_groups = {
			"tactical_overlay",
			"alive",
			"communication_wheel",
		},
	},
}

mod.kill_counter = 0
mod.highest_kill_combo = 0
mod.kill_counter_label = mod:localize("kill_count_hud")
mod.kill_combo_label = mod:localize("kill_combo_hud")

for _, hud_element in ipairs(hud_elements) do
	mod:add_require_path(hud_element.filename)
end

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)

	for _, hud_element in ipairs(hud_elements) do
		if not table.find_by_key(elements, "class_name", hud_element.class_name) then
			table.insert(elements, {
				class_name = hud_element.class_name,
				filename = hud_element.filename,
				use_hud_scale = true,
				visibility_groups = hud_element.visibility_groups or {
					"alive",
				},
			})
		end
	end

	return func(self, elements, visibility_groups, params)
end)

-- Taken from Fracticality
local function recreate_hud(reset_stats)
	if reset_stats then
		mod.kill_counter = 0
		mod.highest_kill_combo = 0
	end;
	mod.show_kill_combos = mod:get("show_kill_combos")
	mod.min_kill_combo = mod:get("min_kill_combo")
	mod.show_cringe = mod:get("show_cringe")
	mod.cringe_factor = mod:get("cringe_factor")
	mod.anim_x_offset = mod:get("anim_container_x_offset")
	mod.anim_y_offset = mod:get("anim_container_y_offset")

	--From 'color_definitions' (Darktide Source Code)
	local color_code = mod:get("anim_color")
	local transparency = mod:get("anim_transparency")

	if mod:get("label_size") == "label_size_default" then
		mod.label_size = 26
		mod.label_y_offset = -11
	elseif mod:get("label_size") == "label_size_large" then
		mod.label_size = 32
		mod.label_y_offset = -8
	elseif mod:get("label_size") == "label_size_largest" then
		mod.label_size = 36
		mod.label_y_offset = -6
	elseif mod:get("label_size") == "label_size_small" then
		mod.label_size = 22
		mod.label_y_offset = -12
	end
	
	mod.default_color = Color.terminal_text_header(255, true)
	mod.anim_color = Color[color_code](transparency,true)
	mod.fade_color = Color[color_code](transparency,true)
	mod.new_combo_color = Color.dark_turquoise(255, true)

	local ui_manager = Managers.ui
	if ui_manager then
		local hud = ui_manager._hud
		if hud then
			local player_manager = Managers.player
			local player = player_manager:local_player(1)
			local peer_id = player:peer_id()
			local local_player_id = player:local_player_id()
			local elements = hud._element_definitions
			local visibility_groups = hud._visibility_groups

			hud:destroy()
			ui_manager:create_player_hud(peer_id, local_player_id, elements, visibility_groups)
		end
	end
end

mod.reload_mods = function()
	recreate_hud(true)
end

mod.on_all_mods_loaded = function()
	recreate_hud(true)
end

mod.on_setting_changed = function()
	recreate_hud(false)
end

mod.add_to_killcounter = function()
	mod:notify("wtf how did u get here")
end

function mod.on_game_state_changed(status, state_name)
	-- Clear row values on game state enter
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud(true)
	end
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result",
function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)
	if not (attack_result == 'died') then
		return
	end

	local player = mod:player_from_unit(attacking_unit)
	if not player then
		return
	end

	local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
	local breed_or_nil = unit_data_extension and unit_data_extension:breed()
	local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)		
	if target_is_minion then
		mod.add_to_killcounter()
	end	
end)

-- Player from player_unit
mod.player_from_unit = function(self, unit)
	if unit then
		local player_manager = Managers.player
		local localplayer = player_manager:local_player(1)
		if localplayer.player_unit == unit then
			return localplayer
		end
	end
	return nil
end
