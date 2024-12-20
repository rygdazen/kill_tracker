
local localization = {
	mod_title = {
		en = "Kill Tracker",
		de = "Kill-Tracker",
		es = "Rastreador de Muertes",
		fr = "Traqueur de Meurtres",
		ru = "Счётчик убийств",
		["zh-cn"] = "击杀追踪器",
	},
	mod_description = {
		en = "Tracks all mission kills and kill combos on your HUD and diverts your attention away from the objective",
		de = "Verfolgt alle Missionskills und Kill-Combos auf deinem HUD und lenkt deine Aufmerksamkeit vom Missionsziel ab",
		es = "Rastrea todas las muertes y combos de muertes de la misión en tu HUD y desvía tu atención del objetivo",
		fr = "Suivi de tous les meurtres et combos de meurtres de la mission sur votre HUD et détournement de votre attention de l'objectif",
		ru = "Kill Tracker - Показывает на экране счётчик всех врагов, убитых вами в течение миссии, а также счётчик серий убийств, отвлекая ваше внимание от цели.",
		["zh-cn"] = "在你的 HUD 上追踪任务内所有的击杀和连杀，使你的注意力从任务目标上移开",
	},
	kill_combo_options = {
		en = "Kill Combos",
		de = "Kill-Combos",
		es = "Combos Asesinos",
		fr = "Combinaisons Mortelles",
		ru = "Серии убийств",
		["zh-cn"] = "连杀",
	},
	show_kill_combos ={
		en = "Show Animated Kill Combo",
		de = "Animierte Kill-Combo anzeigen",
		es = "Mostrar Combo de Muerte Animada",
		fr = "Afficher le Combo Animé de Mise à Mort",
		ru = "Показывать всплывающие цифры",
		["zh-cn"] = "显示连杀动画",
	},
	show_kill_combos_description ={
		en = "Display a kill combo animation above the crosshair.",
		de = "Zeigt eine Kill-Combo-Animation über dem Fadenkreuz an.",
		es = "Muestra una animación de combo mortal sobre la retícula.",
		fr = "Affiche une animation de combo de mise à mort au-dessus de la croix directionnelle.",
		ru = "Показывает над прицелом анимации всплывающих цифр при сериях убийств.",
		["zh-cn"] = "在准星上方显示一个连杀动画。",
	},
	min_kill_combo ={
		en = "Minimum Kill Combo",
		de = "Minimum Kill-Combo",
		es = "Combo de muerte mínima",
		fr = "Combo de mise à mort minimale",
		ru = "Минимум убийств для серии",
		["zh-cn"] = "最低连杀",
	},
	min_kill_combo_description ={
		en = "Show kill combo on reaching a specific number of kills.",
		de = "Kill-Combo bei Erreichen einer bestimmten Anzahl von Kills anzeigen.",
		es = "Mostrar combo de muertes al alcanzar un número determinado de muertes.",
		fr = "Afficher le combo de kill lorsqu'un nombre spécifique de kills est atteint.",
		ru = "Показывает счётчик серии при достижении определённого количества убийств.",
		["zh-cn"] = "达到指定击杀数后才显示连杀。",
	},
	kill_count_hud ={
		en = "Kills",
		de = "Kills",
		es = "Mata",
		fr = "Tue",
		ru = "Убийства",
		["zh-cn"] = "击杀",
	},
	kill_combo_hud ={
		en = "Best Combo",
		de = "Beste Kombo",
		es = "Mejor Combo",
		fr = "Meilleur combo",
		ru = "Лучшая серия",
		["zh-cn"] = "最佳\n连杀",
	},
	show_cringe ={
		en = "Extra Kill Combo Animations",
		de = "Zusätzliche Kill-Combo-Animationen",
		es = "Animaciones extra de Kill Combo",
		fr = "Animations supplémentaires de combo de mise à mort",
		ru = "Дополнительные анимации",
		["zh-cn"] = "额外的连杀动画",
	},
	cringe_factor ={
		en = "Animation Intensity",
		de = "Intensität der Animation",
		es = "Intensidad de la animación",
		fr = "Intensité de l'animation",
		ru = "Интенсивность анимации",
		["zh-cn"] = "动画强度",
	},
	cringe_factor_description ={
		en = "Increases the intensity in percent. 100 % is the default value.",
		de = "Erhöht die Intensität in Prozent. 100 % ist der Standardwert.",
		es = "Aumenta la intensidad en porcentaje. 100 % es el valor por defecto.",
		fr = "Augmente l'intensité en pourcentage. 100 % est la valeur par défaut.",
		ru = "Увеличивает интенсивность в процентах. По умолчанию используется значение 100 %.",
		["zh-cn"] = "增加强度的百分比。默认值为 100%。",
	},
	anim_container_x_offset ={
		en = "X Offset",
		de = "X-Offset",		
		es = "X Offset",
		fr = "X Décalage",
		ru = "Смещение Y",
		["zh-cn"] = "X 偏移",
	},
	anim_container_y_offset ={
		en = "Y Offset",
		de = "Y-Offset",
		es = "Y Offset",
		fr = "Y Décalage",
		ru = "Смещение Y",
		["zh-cn"] = "Y 偏移",
	},
	anim_transparency ={
		en = "Transparency",
		de = "Transparenz",
		fr = "Transparence",
		es = "Transparencia",
		ru = "Прозрачность",
		["zh-cn"] = "透明度",
	},
	anim_color ={
		en = "Colour",
		de = "Farbe",
		fr = "Couleur",
		es = "Color",
		ru = "Цвет",
		["zh-cn"] = "颜色",
	},
}

-- taken from "True Level"
for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    localization[name] = { en = text }
end

return localization