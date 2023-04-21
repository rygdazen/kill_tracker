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
	}
}

mod.kill_counter = 0
mod.animating = false
mod.anim_kill_count = 0 --kills happening while animating

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
	mod.display_tracker = mod:get("show_kill_counter") 
	mod.show_kill_animation = mod:get("show_kill_animation")

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

function mod.on_game_state_changed(status, state_name)
	-- Clear row values on game state enter
	if state_name == 'GameplayStateRun' or state_name == "StateGameplay" and status == "enter" then
		recreate_hud()
		mod.kill_counter = 0
	end
end

mod:hook_safe(CLASS.AttackReportManager, "add_attack_result",
function(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)

	local player = mod:player_from_unit(attacking_unit)
	if player then
		local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
		local breed_or_nil = unit_data_extension and unit_data_extension:breed()
		local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)		
		if target_is_minion then
			if attack_result == "died" then
				mod:increaseKillCounter()
			end
		end
	end
end)

mod.increaseKillCounter = function(self)
	self.kill_counter = self.kill_counter + 1

	if mod.show_kill_animation then
		self.animating = true
		self.anim_kill_count = self.anim_kill_count + 1
	end
end


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

--[[

-- Player from player_unit
mod.player_from_unit = function(self, unit)
	if unit then
		local player_manager = Managers.player
		for _, player in pairs(player_manager:players()) do
			if player.player_unit == unit then
				local account_id = player:account_id()
				local localplayer = player_manager:local_player(1)
				local local_player_id = localplayer:account_id()
				if account_id == local_player_id then					
					return player	
				end				
			end
		end
	end
	return nil
end

mod:hook(CLASS.AttackReportManager, "add_attack_result",
function(func, self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage,
	attack_result, attack_type, damage_efficiency, ...)

	local player = mod:player_from_unit(attacking_unit)
	if player then
		local unit_data_extension = ScriptUnit.has_extension(attacked_unit, "unit_data_system")
		local breed_or_nil = unit_data_extension and unit_data_extension:breed()
		local target_is_minion = breed_or_nil and Breed.is_minion(breed_or_nil)		
		if target_is_minion then
			if attack_result == "died" then
				mod:increaseKillCounter()
			end
		end
	end
	-- Original function
	return func(self, damage_profile, attacked_unit, attacking_unit, attack_direction, hit_world_position, hit_weakspot, damage, attack_result, attack_type, damage_efficiency, ...)
end)




CommandWindow.print('console log')
]]--