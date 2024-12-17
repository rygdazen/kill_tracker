-- version 0.5.0

-- TODO: combo still running after settings changed
-- TODO: for the emprah, kill streak texts
-- TODO: cringe factor needs to add shaking and pulsating texts
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
	--[[{
		filename = "kill_tracker/scripts/mods/kill_tracker/HudElementKillstreak",
		class_name = "HudElementKillstreak",
		visibility_groups = {
			"tactical_overlay",
			"alive",
			"communication_wheel",
		},
	},]]
}

mod.kill_counter = 0
mod.highest_kill_combo = 0
mod.kill_counter_label = mod:localize("kill_count_hud")
mod.kill_combo_label = mod:localize("kill_combo_hud")
--From 'color_definitions' (Darktide Source Code)
mod.default_color = Color.terminal_text_header(255, true)
mod.fade_color = Color.terminal_text_header(255, true)
mod.new_combo_color = Color.dark_turquoise(255, true)

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
local function recreate_hud()
	mod.kill_counter = 0
	mod.highest_kill_combo = 0
	mod.show_kill_combos = mod:get("show_kill_combos")
	mod.min_kill_combo = mod:get("min_kill_combo")
	mod.show_cringe = mod:get("show_cringe")
	mod.cringe_factor = mod:get("cringe_factor")
	mod.anim_x_offset = mod:get("anim_container_x_offset")
	mod.anim_y_offset = mod:get("anim_container_y_offset")
	mod.show_killstreaks = false --mod:get("show_killstreaks")

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
	recreate_hud()
end

mod.on_all_mods_loaded = function()
	recreate_hud()
end

mod.on_setting_changed = function()
	recreate_hud()
end
--[[
mod.add_to_killstreak_counter = function()
	mod:notify("wtf how did u get here")
end
]]
mod.add_to_killcounter = function()
	mod:notify("wtf how did u get here")
end

function mod.on_game_state_changed(status, state_name)
	-- Clear row values on game state enter
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud()
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
		--mod.add_to_killstreak_counter()
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
