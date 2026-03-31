extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var status_label: Label = %StatusLabel
@onready var buy_button: Button = %BuyButton

var upgrade_id := ""

func _ready() -> void:
	ThemeHelper.apply_panel(self, "panel")
	ThemeHelper.apply_button(buy_button)
	buy_button.pressed.connect(func(): GameManager.buy_upgrade(upgrade_id))

func setup(data: Dictionary) -> void:
	upgrade_id = data["id"]
	title_label.text = data["name"]
	desc_label.text = data["desc"]
	refresh()

func refresh() -> void:
	var def := GameManager.get_upgrade_def(upgrade_id)
	var lvl := GameManager.get_upgrade_level(upgrade_id)
	var max_level := int(def["max_level"])
	var cost := GameManager.get_upgrade_cost(upgrade_id)
	var resource := String(def["cost_resource"])
	status_label.text = "Nível %d/%d | Custo: %s %s" % [lvl, max_level, NumberFormatter.format_number(cost, ConfigManager.use_scientific()), resource.capitalize()]
	buy_button.disabled = lvl >= max_level or not GameManager.can_afford(resource, cost)
	buy_button.text = "Concluído" if lvl >= max_level else "Adquirir"
