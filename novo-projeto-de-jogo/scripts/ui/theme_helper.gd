extends RefCounted
class_name ThemeHelper

static func palette() -> Dictionary:
	var theme_name := String(ConfigManager.get_value("theme", "midnight"))
	if theme_name == "amber":
		return {
			"bg":"#160f08",
			"panel":"#25180b",
			"panel_alt":"#34200e",
			"accent":"#ffb347",
			"accent_soft":"#ffd39b",
			"text":"#fff1d6",
			"muted":"#c29b67",
			"good":"#8ce99a",
			"warn":"#ffd166",
			"bad":"#ff7b72"
		}
	return {
		"bg":"#0d111b",
		"panel":"#141b2d",
		"panel_alt":"#1c2440",
		"accent":"#71d0ff",
		"accent_soft":"#bcecff",
		"text":"#edf4ff",
		"muted":"#97a6c4",
		"good":"#8be9a8",
		"warn":"#ffd166",
		"bad":"#ff7d7d"
	}

static func color(key: String) -> Color:
	return Color(palette()[key])

static func make_panel(style_key := "panel") -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color(style_key)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = color("accent") * Color(1, 1, 1, 0.22)
	sb.content_margin_left = 12
	sb.content_margin_top = 10
	sb.content_margin_right = 12
	sb.content_margin_bottom = 10
	return sb

static func apply_panel(panel: Control, style_key := "panel") -> void:
	panel.add_theme_stylebox_override("panel", make_panel(style_key))

static func apply_button(button: BaseButton, accent := false) -> void:
	var normal := make_panel("panel_alt" if accent else "panel")
	normal.bg_color = color("accent") if accent else color("panel_alt")
	normal.border_color = color("accent")
	var hover := normal.duplicate()
	hover.bg_color = color("accent_soft") if accent else color("panel_alt").lightened(0.12)
	var pressed := normal.duplicate()
	pressed.bg_color = color("accent").darkened(0.15) if accent else color("panel_alt").darkened(0.1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", color("bg") if accent else color("text"))
	button.add_theme_color_override("font_hover_color", color("bg") if accent else color("text"))
	button.add_theme_color_override("font_pressed_color", color("bg") if accent else color("text"))
	button.custom_minimum_size.y = 34

static func apply_label(label: Label, tone := "text", size := 16) -> void:
	label.add_theme_color_override("font_color", color(tone))
	label.add_theme_font_size_override("font_size", size)
