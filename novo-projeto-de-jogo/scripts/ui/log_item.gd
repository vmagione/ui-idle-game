extends PanelContainer

@onready var time_label: Label = %TimeLabel
@onready var message_label: Label = %MessageLabel

func _ready() -> void:
	ThemeHelper.apply_panel(self, "panel_alt")

func setup(data: Dictionary) -> void:
	time_label.text = data.get("time", "--")
	message_label.text = data.get("message", "")
