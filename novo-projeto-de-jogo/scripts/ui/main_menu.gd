extends Control

signal start_new_requested
signal continue_requested
signal options_requested
signal credits_requested

@onready var continue_button: Button = %ContinueButton
@onready var credits_panel: AcceptDialog = %CreditsDialog

func _ready() -> void:
	ThemeHelper.apply_panel(%MainPanel, "panel")
	ThemeHelper.apply_button(%NewGameButton, true)
	ThemeHelper.apply_button(continue_button)
	ThemeHelper.apply_button(%OptionsButton)
	ThemeHelper.apply_button(%CreditsButton)
	ThemeHelper.apply_button(%DeleteSaveButton)
	ThemeHelper.apply_button(%QuitButton)
	continue_button.disabled = not SaveManager.has_save()
	%NewGameButton.pressed.connect(func(): start_new_requested.emit())
	continue_button.pressed.connect(func(): continue_requested.emit())
	%OptionsButton.pressed.connect(func(): options_requested.emit())
	%CreditsButton.pressed.connect(func(): credits_panel.popup_centered_ratio(0.35))
	%DeleteSaveButton.pressed.connect(func():
		GameManager.delete_save()
		continue_button.disabled = true
	)
	%QuitButton.pressed.connect(func(): get_tree().quit())
