-- version 0.7.2

-- TODO: add setting for reset kills on death

local mod = get_mod("kill_tracker")

local Breed = mod:original_require("scripts/utilities/breed")

mod.kill_counter = 0
mod.highest_kill_combo = 0
mod.kill_counter_label = mod:localize("kill_count_hud")
mod.kill_combo_label = mod:localize("kill_combo_hud")

local function apply_settings(reset_stats)
	if reset_stats then
		mod.kill_counter = 0
		mod.highest_kill_combo = 0
	end;
	mod.show_kill_combos = mod:get("show_kill_combos")
	mod.min_kill_combo = mod:get("min_kill_combo")
	mod.show_cringe = mod:get("show_cringe")
	mod.cringe_factor = mod:get("cringe_factor")

	if mod.anim_offset then
		mod.anim_offset[1] = mod:get("anim_container_x_offset")
		mod.anim_offset[2] = mod:get("anim_container_y_offset")
	else
		mod.anim_offset = {
			mod:get("anim_container_x_offset"),
			mod:get("anim_container_y_offset"),
			10
		}
	end

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

	if mod.apply_widget_settings then
		mod.apply_widget_settings()
	end
end

apply_settings(true)
mod:register_hud_element({
	filename = "kill_tracker/scripts/mods/kill_tracker/HudElementKillCount",
	class_name = "HudElementKillCount",
	visibility_groups = {
		"tactical_overlay",
		"alive",
		"communication_wheel",
	},
	use_hud_scale = true,
	validation_function = function(params)
		return Managers.state.game_mode:game_mode_name() ~= "hub"
	end
})

mod.on_setting_changed = function()
	apply_settings(false)
end

function mod.on_game_state_changed(status, state_name)
	-- Clear row values on game state enter
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		apply_settings(true)
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
	if target_is_minion and mod.add_to_killcounter then
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
