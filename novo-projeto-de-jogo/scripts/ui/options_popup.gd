extends Window

@onready var notation_option: OptionButton = %NotationOption
@onready var theme_option: OptionButton = %ThemeOption
@onready var autosave_spin: SpinBox = %AutosaveSpin
@onready var confirm_resets: CheckBox = %ConfirmResets
@onready var economy_mode: CheckBox = %EconomyMode
@onready var animations: CheckBox = %Animations

func _ready() -> void:
	if notation_option.item_count == 0:
		notation_option.add_item("Abreviada")
		notation_option.add_item("Científica")
	if theme_option.item_count == 0:
		theme_option.add_item("Midnight")
		theme_option.add_item("Amber")
	notation_option.item_selected.connect(_on_notation_changed)
	theme_option.item_selected.connect(_on_theme_changed)
	autosave_spin.value_changed.connect(func(v): ConfigManager.set_value("autosave_interval", v))
	confirm_resets.toggled.connect(func(v): ConfigManager.set_value("confirm_resets", v))
	economy_mode.toggled.connect(func(v): ConfigManager.set_value("economy_mode", v))
	animations.toggled.connect(func(v): ConfigManager.set_value("ui_animations", v))
	refresh()

func refresh() -> void:
	notation_option.select(0 if not ConfigManager.use_scientific() else 1)
	theme_option.select(0 if ConfigManager.get_value("theme", "midnight") == "midnight" else 1)
	autosave_spin.value = float(ConfigManager.get_value("autosave_interval", 20.0))
	confirm_resets.button_pressed = bool(ConfigManager.get_value("confirm_resets", true))
	economy_mode.button_pressed = bool(ConfigManager.get_value("economy_mode", false))
	animations.button_pressed = bool(ConfigManager.get_value("ui_animations", true))

func _on_notation_changed(index: int) -> void:
	ConfigManager.set_value("number_notation", "abbreviated" if index == 0 else "scientific")

func _on_theme_changed(index: int) -> void:
	ConfigManager.set_value("theme", "midnight" if index == 0 else "amber")
