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
		position = { 0, -25, 10 },
	},
	animContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = sizeAnim,
		position = { 0, -150, 10 },
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
	animatedCounter = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			style = styleAnimated,
		} },
		"animContainer"
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
		-- CommandWindow.print("animating!")
		-- CommandWindow.print(self._widgets_by_name.animatedCounter.style.text.offset[2])
		self.animating = true
	end

	if self.animating then
		self.anim_pos_y_offset = self.anim_pos_y_offset + (self.anim_pos_y_offset / 15) + (1.5 * dt)

		local prev_alpha = self._widgets_by_name.animatedCounter.alpha_multiplier or 0

		self._widgets_by_name.animatedCounter.alpha_multiplier = math.min(prev_alpha + (4 * dt), 1)
		self._widgets_by_name.animatedCounter.style.text.offset[2] = -self.anim_pos_y_offset

		-- CommandWindow.print(self.anim_pos_y_offset)
		if self.anim_pos_y_offset > 50 then
			self.anim_pos_y_offset = 0
			self._widgets_by_name.animatedCounter.style.text.offset[2] = 0
			self._widgets_by_name.animatedCounter.alpha_multiplier = 0
			self.animating = false
			mod.anim_kill_count = 0
		end
	end

	if mod.anim_kill_count > 0 then
		self._widgets_by_name.animatedCounter.content.text = "+" .. tostring(mod.anim_kill_count)
	else
		self._widgets_by_name.animatedCounter.content.text = ""
	end

	if self.show_counter and mod.display_tracker then
		self._widgets_by_name.killCounter.content.text = tostring(mod.kill_counter or "Fuck")
	else
		self._widgets_by_name.killCounter.content.text = tostring("")
	end
end

return HudElementKillCount
