local mod = get_mod("kill_tracker")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")

local font_size = 32
local font_size_anim = 24
local size = { 60, font_size }
local sizeAnim = { 60, font_size_anim }
local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	counterContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { -125, -20, 10 },
	},
	counterLabelContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { -75, -20, 10 },
	},
	animContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sizeAnim,
		position = { 0, -150, 10 },
	},
	comboContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { 75, -20, 10 },
	},
	comboLabelContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { 125, -20, 10 },
	},
}

local styleCounter = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = UIHudSettings.color_tint_main_1,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleCounterLabel = {
	line_spacing = 1.2,
	font_size = font_size/2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = UIHudSettings.color_tint_main_1,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleAnimated = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = UIHudSettings.color_tint_main_1,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
	offset = { 0, 10, 10 },
}

local comboCounter = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = UIHudSettings.color_tint_main_1,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local comboCounterLabel = {
	line_spacing = 1.2,
	font_size = font_size/2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = UIHudSettings.color_tint_main_1,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local widget_definitions = {
	killCounter = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleCounter,
		} },
		"counterContainer"
	),
	killCounterLabel = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleCounterLabel,
		} },
		"counterLabelContainer"
	),
	animatedCounter = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleAnimated,
		} },
		"animContainer"
	),
	killCombo = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = comboCounter,
		} },
		"comboContainer"
	),
	killComboLabel = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = comboCounterLabel,
		} },
		"comboLabelContainer"
	),
}

local HudElementKillCount = class("HudElementKillCount", "HudElementBase")

HudElementKillCount.init = function(self, parent, draw_layer, start_scale)
	HudElementKillCount.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self.show_counter = not mod._is_in_hub()
	self.anim_pos_y_offset = 0
end

HudElementKillCount.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementKillCount.super.update(self, dt, t, ui_renderer, render_settings, input_service)	

	if mod.animating then
		mod.animating = false
		self.anim_pos_y_offset = 0
		-- CommandWindow.print("animating!")
		-- CommandWindow.print(self._widgets_by_name.animatedCounter.style.text.offset[2])
		self.animating = true
	end

	if self.animating then
		self.anim_pos_y_offset = self.anim_pos_y_offset + (self.anim_pos_y_offset / 30) + (1.5 * dt)

		local prev_alpha = self._widgets_by_name.animatedCounter.alpha_multiplier or 0

		self._widgets_by_name.animatedCounter.alpha_multiplier = math.min(prev_alpha + (4 * dt), 1)
		self._widgets_by_name.animatedCounter.style.text.offset[2] = -self.anim_pos_y_offset

		-- CommandWindow.print(self.anim_pos_y_offset)
		if self.anim_pos_y_offset > 50 then
			self.anim_pos_y_offset = 0
			self._widgets_by_name.animatedCounter.style.text.offset[2] = 0
			self._widgets_by_name.animatedCounter.alpha_multiplier = 0
			self.animating = false
			if mod.show_kill_combo then
				if mod.highest_kill_combo < mod.anim_kill_combo then
					mod.highest_kill_combo = mod.anim_kill_combo
				end
			end
			mod.anim_kill_combo = 0
		end
	end

	if mod.anim_kill_combo > 0 then
		self._widgets_by_name.animatedCounter.content.text = "+" .. tostring(mod.anim_kill_combo)
	else
		self._widgets_by_name.animatedCounter.content.text = ""
	end

	if self.show_counter then
		self._widgets_by_name.killCounter.content.text = tostring(mod.kill_counter or "Fuck")
		self._widgets_by_name.killCounterLabel.content.text = tostring(mod:localize("kill_count_hud"))
	else
		self._widgets_by_name.killCounter.content.text = tostring("")
		self._widgets_by_name.killCounterLabel.content.text = tostring("")
	end

	if mod.highest_kill_combo > 0 then
		self._widgets_by_name.killCombo.content.text = tostring(mod.highest_kill_combo or "Shit")
		self._widgets_by_name.killComboLabel.content.text = tostring(mod:localize("kill_combo_hud"))
	else
		self._widgets_by_name.killCombo.content.text = tostring("")
		self._widgets_by_name.killComboLabel.content.text = tostring("")
	end
end

return HudElementKillCount
