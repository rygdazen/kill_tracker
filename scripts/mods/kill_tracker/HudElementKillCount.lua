local mod = get_mod("kill_tracker")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")

local font_size = mod.label_size
local font_offset = mod.label_y_offset
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
		position = { -125, font_offset, 10 },
	},
	counterLabelContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { -75, font_offset, 10 },
	},
	animContainer = {
		parent = "screen",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sizeAnim,
		position = { mod.anim_x_offset , mod.anim_y_offset, 10 },
	},
	comboContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { 75, font_offset, 10 },
	},
	newComboContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { 67, font_offset, 10 },
	},
	comboLabelContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "bottom",
		horizontal_alignment = "center",
		size = size,
		position = { 135, font_offset, 10 },
	},
	testContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = size,
		position = { 220, 0, 10 },
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
	text_color = mod.anim_color,
	size = sizeAnim,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "bottom",
	offset = { 0, 10, 10 },
}

local styleComboCounter = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleNewComboCounter = {
	line_spacing = 1.2,
	font_size = font_size,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.new_combo_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleComboCounterLabel = {
	line_spacing = 1.2,
	font_size = font_size/2,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local styleTest = {
	line_spacing = 1.2,
	font_size = font_size,
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
			style = styleComboCounter,
		} },
		"comboContainer"
	),
	newKillCombo = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleNewComboCounter,
		} },
		"newComboContainer"
	),
	killComboLabel = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleComboCounterLabel,
		} },
		"comboLabelContainer"
	),
	testWidget = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			value = "",
			style = styleTest,
		} },
		"testContainer"
	),
}

local HudElementKillCount = class("HudElementKillCount", "HudElementBase")

local function _color_fade_fully_red()
	return((mod.fade_color[2] == 255) and (mod.fade_color[3] == 0) and (mod.fade_color[4] == 0))	
end

local function _get_new_increased_color_value(curr_val)	
	if curr_val >= 255 then
		return 255
	end
	return math.min(255,math.ceil(255 * ((curr_val / 255) + 0.01)))
end

local function _get_new_decreased_color_value(curr_val)	
	if curr_val <= 0 then
		return 0
	end
	return math.max(0,math.ceil(255 * ((curr_val / 255) - 0.01)))
end

local function _set_red_color_fade(widget)
	if _color_fade_fully_red() then
		return
	end

	mod.fade_color[2] = _get_new_increased_color_value(mod.fade_color[2])
	mod.fade_color[3] = _get_new_decreased_color_value(mod.fade_color[3])
	mod.fade_color[4] = _get_new_decreased_color_value(mod.fade_color[4])

	widget.style.text.text_color = table.clone(mod.fade_color)
end

local function _reset_red_color_fade(widget)
	mod.fade_color = table.clone(mod.anim_color)
	widget.style.text.text_color = table.clone(mod.anim_color)
end

local function _scale_by_cringe_factor(input_value)
	return((input_value/100)*mod.cringe_factor*0.6)	
end

HudElementKillCount.init = function(self, parent, draw_layer, start_scale)
	HudElementKillCount.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})
	self.is_in_hub = mod._is_in_hub()
	self.combo_timer = 0
	self.timer_running = false
	self.combo_timer_percentage = 0
	self.combo_duration_seconds = 2.5
	self.anim_kill_combo = 0
	--self.kill_counter = 0
	--self.highest_kill_combo = 0
	self.new_highest_kill_combo = false

	mod.add_to_killcounter = function()
		self:add_to_killcounter()
	end
end

HudElementKillCount.add_to_killcounter = function(self)
	self.anim_kill_combo = self.anim_kill_combo + 1
	mod.kill_counter = mod.kill_counter + 1

	self:_start_combo_timer()
end

HudElementKillCount._start_combo_timer = function(self)
	self.timer_running = true
	self.combo_timer = 0
	 
	self._widgets_by_name.animatedCounter.alpha_multiplier = 1
	if (self.anim_kill_combo < 100) and mod.show_cringe then
		_set_red_color_fade(self._widgets_by_name.animatedCounter)
	end
end

HudElementKillCount._update_combo_timer = function(self, dt)
	self.combo_timer = self.combo_timer + dt

	self.combo_timer_percentage = self.combo_timer / self.combo_duration_seconds

	if self.combo_timer > self.combo_duration_seconds then
		self.timer_running = false
		self.combo_timer = 0
		self.combo_timer_percentage = 0
		
		self._widgets_by_name.animatedCounter.style.text.offset[2] = 0
		self._widgets_by_name.animatedCounter.alpha_multiplier = 1
		self.animating = false
		if mod.highest_kill_combo < self.anim_kill_combo then
			mod.highest_kill_combo = self.anim_kill_combo
			self.new_highest_kill_combo = true
		end
		self.anim_kill_combo = 0
		if mod.show_cringe then
			_reset_red_color_fade(self._widgets_by_name.animatedCounter)				
		end
	end
end

-- HudElementKillCount._test_dt = function(self, widget)
-- 	if self.timer_running then
-- 		widget.content.text = tostring(self.combo_timer)		
-- 	else
-- 		widget.content.text = tostring("")
-- 	end
-- end

HudElementKillCount._calc_anim_offset = function(self)
	local t = self.combo_timer_percentage
	local multiplier = math.pow(2, self.combo_timer_percentage * 5 + 2)

	return t * multiplier
end

HudElementKillCount.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementKillCount.super.update(self, dt, t, ui_renderer, render_settings, input_service)	

	if self.is_in_hub then		
		self._widgets_by_name.killCounter.content.text = tostring("")
		self._widgets_by_name.killCounterLabel.content.text = tostring("")
		self._widgets_by_name.killCombo.content.text = tostring("")
		self._widgets_by_name.killComboLabel.content.text = tostring("")
		self._widgets_by_name.animatedCounter.content.text = tostring("")
		self._widgets_by_name.newKillCombo.content.text = tostring("")

		self._widgets_by_name.testWidget.content.text = tostring("")
		return
	end
	-- self:_test_dt(self._widgets_by_name.testWidget)

	if self.timer_running then
		self:_update_combo_timer(dt)
		
		local anim_pos_y_offset = self:_calc_anim_offset()
		local alpha = 1

		if self.combo_timer_percentage > 0.6 then
			local t = (self.combo_timer_percentage - 0.6) * 2.5

			alpha = 1 - t
		end

		local anim_font_scale = math.min(1, anim_pos_y_offset * 6.6)
		local font_scale = 1
		if mod.show_cringe then
			font_scale = _scale_by_cringe_factor(math.max(anim_font_scale, self.anim_kill_combo))
		end
		self._widgets_by_name.animatedCounter.style.text.font_size = (font_size * anim_font_scale) + math.ceil(font_scale - 0.5)

		self._widgets_by_name.animatedCounter.alpha_multiplier = alpha
		self._widgets_by_name.animatedCounter.style.text.offset[2] = -anim_pos_y_offset

		if mod.show_cringe then
			if (self.anim_kill_combo >= 100) then
				self._widgets_by_name.animatedCounter.style.text.text_color[3] = (self._widgets_by_name.animatedCounter.style.text.text_color[3] + 20) % 255
				self._widgets_by_name.animatedCounter.style.text.text_color[4] = (self._widgets_by_name.animatedCounter.style.text.text_color[4] + 20) % 255
				
				local shake_intensity = (mod.cringe_factor / 10) * 0.6
				if math.ceil(t * 20) % 2 == 0 then
					self._widgets_by_name.animatedCounter.style.text.offset = {
						math.random(-shake_intensity, shake_intensity),
						math.random(-shake_intensity, shake_intensity) - anim_pos_y_offset,
						math.random(-shake_intensity, shake_intensity)
					}
				end
			end
		end
	end

	-- HUD Kill Counter
	self._widgets_by_name.killCounter.content.text = tostring(mod.kill_counter or "Fuck")
	self._widgets_by_name.killCounterLabel.content.text = tostring(mod.kill_counter_label)

	-- HUD Kill Combos
	if self.anim_kill_combo >= mod.min_kill_combo and mod.show_kill_combos and self.timer_running then
		self._widgets_by_name.animatedCounter.content.text = "+" .. tostring(self.anim_kill_combo)
	else
		self._widgets_by_name.animatedCounter.content.text = tostring("")
	end

	-- HUD Best Combo
	if mod.highest_kill_combo > 0 and mod.show_kill_combos then
		self._widgets_by_name.killCombo.content.text = tostring(mod.highest_kill_combo or "Shit")
		self._widgets_by_name.killComboLabel.content.text = tostring(mod.kill_combo_label)
	else
		self._widgets_by_name.killCombo.content.text = tostring("")
		self._widgets_by_name.killComboLabel.content.text = tostring("")
	end
	if self.new_highest_kill_combo and mod.show_kill_combos and (self._widgets_by_name.newKillCombo.style.text.offset[2] > -80) then
		local comboAlpha = (self._widgets_by_name.newKillCombo.style.text.offset[2] * -1) / 80
		self._widgets_by_name.newKillCombo.alpha_multiplier = 1 - comboAlpha
		self._widgets_by_name.newKillCombo.style.text.offset[2] = self._widgets_by_name.newKillCombo.style.text.offset[2] - comboAlpha * 2 - 0.2
		self._widgets_by_name.newKillCombo.content.text = tostring("+" .. tostring(mod.highest_kill_combo))
	else
		self.new_highest_kill_combo = false
		self._widgets_by_name.newKillCombo.style.text.offset[2] = 0
		self._widgets_by_name.newKillCombo.content.text = tostring("")
	end
end

return HudElementKillCount
