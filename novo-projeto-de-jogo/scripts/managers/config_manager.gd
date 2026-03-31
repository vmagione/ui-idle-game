extends Node

signal config_changed

const CONFIG_PATH := "user://bureau_config.save"

var data := {
	"master_volume": 0.8,
	"autosave_interval": GameDatabase.AUTOSAVE_DEFAULT,
	"number_notation": "abbreviated",
	"theme": "midnight",
	"confirm_resets": true,
	"fps_limit": 60,
	"economy_mode": false,
	"ui_animations": true
}

func _ready() -> void:
	load_config()
	_apply_runtime_config()

func load_config() -> void:
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for key in parsed.keys():
			data[key] = parsed[key]
	_apply_runtime_config()

func save_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))

func set_value(key: String, value) -> void:
	data[key] = value
	save_config()
	_apply_runtime_config()
	config_changed.emit()

func get_value(key: String, default_value = null):
	return data.get(key, default_value)

func use_scientific() -> bool:
	return data.get("number_notation", "abbreviated") == "scientific"

func _apply_runtime_config() -> void:
	Engine.max_fps = 30 if data.get("economy_mode", false) else int(data.get("fps_limit", 60))
