extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var reward_label: Label = %RewardLabel
@onready var status_label: Label = %StatusLabel

var objective_data: Dictionary

func _ready() -> void:
	ThemeHelper.apply_panel(self, "panel")

func setup(data: Dictionary) -> void:
	objective_data = data
	title_label.text = data["name"]
	desc_label.text = data["desc"]
	if data["reward"].has("resource"):
		reward_label.text = "Recompensa: %s %s" % [NumberFormatter.format_number(float(data["reward"]["amount"]), ConfigManager.use_scientific()), String(data["reward"]["resource"]).capitalize()]
	else:
		reward_label.text = "Recompensa: multiplicador de run"
	refresh()

func refresh() -> void:
	var complete: bool = GameManager.state["objectives_completed"].has(objective_data["id"])
	status_label.text = "Concluído" if complete else "Em andamento"
	status_label.modulate = ThemeHelper.color("good") if complete else ThemeHelper.color("warn")
