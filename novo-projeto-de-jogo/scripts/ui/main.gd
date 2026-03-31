extends Control

var menu_scene := preload("res://scenes/menus/MainMenu.tscn")
var game_scene := preload("res://scenes/game/GameScreen.tscn")
var options_scene := preload("res://scenes/popups/OptionsPopup.tscn")

var current_screen: Control
var options_popup: Window

func _ready() -> void:
	options_popup = options_scene.instantiate()
	add_child(options_popup)
	options_popup.hide()
	_show_menu()

func _show_menu() -> void:
	if is_instance_valid(current_screen):
		current_screen.queue_free()
	current_screen = menu_scene.instantiate()
	add_child(current_screen)
	current_screen.start_new_requested.connect(_on_start_new)
	current_screen.continue_requested.connect(_on_continue)
	current_screen.options_requested.connect(func(): options_popup.open_popup())

func _show_game() -> void:
	if is_instance_valid(current_screen):
		current_screen.queue_free()
	current_screen = game_scene.instantiate()
	add_child(current_screen)
	current_screen.back_to_menu_requested.connect(_show_menu)

func _on_start_new() -> void:
	GameManager.start_new_game()
	_show_game()

func _on_continue() -> void:
	if GameManager.continue_game():
		_show_game()
