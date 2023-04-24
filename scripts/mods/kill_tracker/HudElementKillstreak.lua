local mod = get_mod("kill_tracker")
local dmf = get_mod("DMF")

local Text = require("scripts/utilities/ui/text")
local UIWorkspaceSettings = require("scripts/settings/ui/ui_workspace_settings")
local UIHudSettings = require("scripts/settings/ui/ui_hud_settings")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = mod:original_require("scripts/managers/ui/ui_fonts")

local font_size = 32
local size = { 1200, font_size }
local scenegraph_definition = {
	screen = UIWorkspaceSettings.screen,
	killstreakContainer = {
		parent = "screen",
		scale = "fit",
		vertical_alignment = "center",
		horizontal_alignment = "center",
		size = size,
		position = { 0, 60, 10 },
	}
}

local styleKillstreak = {
	line_spacing = 1.2,
	font_size = 32,
	drop_shadow = true,
	font_type = "machine_medium",
	text_color = mod.default_color,
	size = size,
	text_horizontal_alignment = "center",
	text_vertical_alignment = "center",
}

local widget_definitions = {
	killstreakText = UIWidget.create_definition(
		{ {
			value_id = "text",
			style_id = "text",
			pass_type = "text",
			value = "",
			style = styleKillstreak
		} },
		"killstreakContainer"
	)
}

local KillstreakLabels = {
	-- kills, label, font_size, red_intensity, flashing
	{ 2, "Double Kill", 30, 0.0, false },
	{ 3, "Multi Kill", 32, 0.1, false },
	{ 4, "Mega Kill", 46, 0.2, false },
	{ 5, "Ultra Kill", 60, 0.3, false },
	{ 6, "MONSTER KILL!!", 78, 0.5, true },
	{ 7, "LUDICROUS KILL!!", 102, 0.7, true },
	{ 8, "HOLY SHIT!!!", 124, 0.8, true },
	{ 15, "For the Emperor!", 256, 1.0, true },
}

local HudElementKillstreak = class("HudElementKillstreak", "HudElementBase")

local function _scale_by_cringe_factor(input_value)
	return((input_value/100)*(mod.cringe_factor/10))	
end

HudElementKillstreak.init = function(self, parent, draw_layer, start_scale)
	HudElementKillstreak.super.init(self, parent, draw_layer, start_scale, {
		scenegraph_definition = scenegraph_definition,
		widget_definitions = widget_definitions,
	})

	self.killstreak_counter = 0
	self.killstreak_timer = 0
	self.killstreak_duration_in_seconds = 1

	self.killstreak_anim_timer = 0
	self.killstreak_anim_duration_in_seconds = 2

	self.anim_timer_running = false

	self.timer_running = false
	self.killstreak_to_show = nil

	mod.add_to_killstreak_counter = function()
		self:add_to_killstreak_counter()
	end
end

-- Called when a kill was made
HudElementKillstreak.add_to_killstreak_counter = function(self)
	self.killstreak_counter = self.killstreak_counter + 1
	self.timer_running = true

	-- Compare with all killstreaks we defined
	for _, killstreak in ipairs(KillstreakLabels) do
		local killstreakCount = killstreak[1]

		-- Skip killstreaks that are lower than the one we're currently displaying (or if we aren't displaying one)
		if not self.killstreak_to_show or self.killstreak_counter > self.killstreak_to_show[1] then 

			-- When we hit a killstreak exactly, we set the font settings and set the killstreak to display
			if self.killstreak_counter == killstreakCount then
				local widget = self._widgets_by_name.killstreakText
				self.killstreak_timer = 0
				self.killstreak_anim_timer = 0

				self.killstreak_to_show = killstreak
				local font_size = killstreak[3]
				local inverse_red_intensity = 1 - killstreak[4]
				
				local color = {
					255,
					255,
					255 * inverse_red_intensity,
					255 * inverse_red_intensity
				}

				-- Set color, size and reset offset
				widget.style.text.text_color = color
				widget.style.text.offset = { 0, 0, 0 }
				widget.style.text.font_size = font_size -- TODO: scale by cringe factor
			end			
		end
	end
end

HudElementKillstreak.update_killstreak_counter = function(self, dt)
	-- Only run timer when we have atleast one killstreak going
	if self.killstreak_counter > 0 then
		self.killstreak_timer = self.killstreak_timer + dt
		if self.killstreak_timer > self.killstreak_duration_in_seconds then
			-- Killstreak over, reset everything
			self.timer_running = false
			self.killstreak_timer = 0
			self.killstreak_counter = 0

			self.killstreak_anim_timer = 0

			self.anim_timer_running = true
		end
	end

	-- Animation timer for displaying the killstreak text once we have one
	if self.anim_timer_running then
		self.killstreak_anim_timer = self.killstreak_anim_timer + dt

		if self.killstreak_anim_timer > self.killstreak_anim_duration_in_seconds then
			self.anim_timer_running = false	
			self.killstreak_to_show = nil
		end
	end

end

HudElementKillstreak.update = function(self, dt, t, ui_renderer, render_settings, input_service)
	HudElementKillstreak.super.update(self, dt, t, ui_renderer, render_settings, input_service)	

	self:update_killstreak_counter(dt)

	if self.killstreak_to_show and mod.show_killstreaks then
		-- Handling flashing/shaking
		if self.killstreak_to_show[5] then
			local red_intensity = self.killstreak_to_show[4]
			local inverse_red_intensity = 1 - red_intensity
			local color = {
				255,
				255,
				255 * inverse_red_intensity,
				255 * inverse_red_intensity
			}
			local widget = self._widgets_by_name.killstreakText
			local shake_intensity = (mod.cringe_factor / 10) * red_intensity

			if math.ceil(t * 20) % 2 == 0 then
				widget.style.text.offset = {
					math.random(-shake_intensity, shake_intensity),
					math.random(-shake_intensity, shake_intensity),
					math.random(-shake_intensity, shake_intensity)
				}
				widget.style.text.text_color = color
			else
				widget.style.text.text_color = { 255, 255, 255, 255 }
			end
		end

  	self._widgets_by_name.killstreakText.content.text = self.killstreak_to_show[2]
	else
		self._widgets_by_name.killstreakText.content.text = ""
	end
end

return HudElementKillstreak