local mod = get_mod("kill_tracker")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")

local font_size = 32
local font_size_anim = 140
local size = { 60, font_size }
local sizeAnim = { 1000, font_size_anim }
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
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sizeAnim,
		position = { 0, -220, 10 },
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
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleCounterLabel = {
	line_spacing = 1.2,
	font_size = font_size/2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleAnimated = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = sizeAnim,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "bottom",
	offset = { 0, 10, 10 },
}

local comboCounter = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local comboCounterLabel = {
	line_spacing = 1.2,
	font_size = font_size/2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
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

--[[
local KillstreakLabels = {
	{ 10, "Monsterkill" },
	{ 50, "Godlike" },
	{ 100, "For the Emperor!" }
}
]]

local HudElementKillCount = class("HudElementKillCount", "HudElementBase")

HudElementKillCount.init = function(self, parent, draw_layer, start_scale)
	HudElementKillCount.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self._is_in_hub = mod._is_in_hub()
	self.anim_pos_y_offset = 0
end

local function _color_fade_fully_red()
	return((mod.fade_color[2] == 255) and (mod.fade_color[3] == 0) and (mod.fade_color[4] == 0))	
end

local function _set_red_color_fade(factor, widget)
	if _color_fade_fully_red() then
		return
	end

	mod.fade_color[2] = mod.fade_color[2] + 1 * factor
	if mod.fade_color[2] > 255 then
		mod.fade_color[2] = 255
	end
	mod.fade_color[3] = mod.fade_color[3] - 1 * factor
	if mod.fade_color[3] < 0 then
		mod.fade_color[3] = 0
	end
	mod.fade_color[4] = mod.fade_color[4] - 1 * factor
	if mod.fade_color[4] < 0 then
		mod.fade_color[4] = 0
	end

	widget.style.text.text_color = table.clone(mod.fade_color)
end

local function _reset_red_color_fade(widget)
	mod.fade_color = table.clone(mod.default_color)
	widget.style.text.text_color = table.clone(mod.default_color)
end

local function _scale_by_cringe_factor(input_value)
	return((input_value/100)*mod.cringe_factor)	
end

HudElementKillCount.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementKillCount.super.update(self, dt, t, ui_renderer, render_settings, input_service)	

	if self._is_in_hub then		
		self._widgets_by_name.killCounter.content.text = tostring("")
		self._widgets_by_name.killCounterLabel.content.text = tostring("")
		self._widgets_by_name.killCombo.content.text = tostring("")
		self._widgets_by_name.killComboLabel.content.text = tostring("")
		self._widgets_by_name.animatedCounter.content.text = tostring("")
		return
	end

	if mod.animating then
		-- This only triggers once and is immediately unset 
		mod.animating = false

		self.animating = true
		self.anim_pos_y_offset = 0
		self._widgets_by_name.animatedCounter.alpha_multiplier = 1
		if mod.anim_kill_combo > 21 and mod.show_cringe then
			_set_red_color_fade(_scale_by_cringe_factor(2.9), self._widgets_by_name.animatedCounter)
		end	
	end

	if self.animating then
		self.anim_pos_y_offset = self.anim_pos_y_offset + (self.anim_pos_y_offset / 60) + (1.5 * dt) 

		local anim_progress = self.anim_pos_y_offset / 50

		local prev_alpha = self._widgets_by_name.animatedCounter.alpha_multiplier or 1
		local alpha = 1 - anim_progress

		local anim_font_scale = math.min(1, anim_progress * 350)
		local font_scale = 1
		if mod.show_cringe then
			font_scale = _scale_by_cringe_factor(math.max(anim_font_scale, mod.anim_kill_combo))
		end
		self._widgets_by_name.animatedCounter.style.text.font_size = (32 * anim_font_scale) + math.ceil(font_scale - 0.5)

		self._widgets_by_name.animatedCounter.alpha_multiplier = alpha
		self._widgets_by_name.animatedCounter.style.text.offset[2] = -self.anim_pos_y_offset

		if _color_fade_fully_red() and mod.show_cringe then
			self._widgets_by_name.animatedCounter.style.text.text_color[3] = (self._widgets_by_name.animatedCounter.style.text.text_color[3] + 20) % 255
			self._widgets_by_name.animatedCounter.style.text.text_color[4] = (self._widgets_by_name.animatedCounter.style.text.text_color[4] + 20) % 255
		end

		if self.anim_pos_y_offset > 50 then
			self.anim_pos_y_offset = 0
			self._widgets_by_name.animatedCounter.style.text.offset[2] = 0
			self._widgets_by_name.animatedCounter.alpha_multiplier = 1
			self.animating = false
			if mod.highest_kill_combo < mod.anim_kill_combo then
				mod.highest_kill_combo = mod.anim_kill_combo
			end
			mod.anim_kill_combo = 0
			if mod.show_cringe then
				_reset_red_color_fade(self._widgets_by_name.animatedCounter)				
			end
		end
	end

	-- HUD Kill Counter
	self._widgets_by_name.killCounter.content.text = tostring(mod.kill_counter or "Fuck")
	self._widgets_by_name.killCounterLabel.content.text = tostring(mod.kill_counter_label)

	-- HUD Kill Combos
	if mod.anim_kill_combo > 0 and mod.show_kill_combos then
		self._widgets_by_name.animatedCounter.content.text = "+" .. tostring(mod.anim_kill_combo)
	else
		self._widgets_by_name.animatedCounter.content.text = tostring("")
	end
	if mod.highest_kill_combo > 0 and mod.show_kill_combos then
		self._widgets_by_name.killCombo.content.text = tostring(mod.highest_kill_combo or "Shit")
		self._widgets_by_name.killComboLabel.content.text = tostring(mod.kill_combo_label)
	else
		self._widgets_by_name.killCombo.content.text = tostring("")
		self._widgets_by_name.killComboLabel.content.text = tostring("")
	end
end

return HudElementKillCount
