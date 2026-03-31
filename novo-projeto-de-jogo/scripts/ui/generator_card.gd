extends PanelContainer

@onready var title_label: Label = %TitleLabel
@onready var desc_label: Label = %DescLabel
@onready var owned_label: Label = %OwnedLabel
@onready var output_label: Label = %OutputLabel
@onready var cost_label: Label = %CostLabel
@onready var buy_one: Button = %BuyOne
@onready var buy_ten: Button = %BuyTen
@onready var buy_max: Button = %BuyMax
@onready var auto_toggle: Button = %AutoToggle
@onready var mode_button: Button = %ModeButton

var generator_id := ""

func _ready() -> void:
	ThemeHelper.apply_panel(self, "panel")
	for button in [buy_one, buy_ten, buy_max, auto_toggle, mode_button]:
		ThemeHelper.apply_button(button)
	buy_one.pressed.connect(func(): GameManager.buy_generator(generator_id, GameManager.BUY_ONE))
	buy_ten.pressed.connect(func(): GameManager.buy_generator(generator_id, GameManager.BUY_TEN))
	buy_max.pressed.connect(func(): GameManager.buy_generator(generator_id, GameManager.BUY_MAX))
	auto_toggle.pressed.connect(func(): GameManager.toggle_autobuyer(generator_id))
	mode_button.pressed.connect(func(): GameManager.cycle_autobuyer_mode(generator_id))

func setup(data: Dictionary) -> void:
	generator_id = data["id"]
	title_label.text = data["name"]
	desc_label.text = data["description"]
	refresh()

func refresh() -> void:
	var scientific := ConfigManager.use_scientific()
	var def := GameManager.get_generator_def(generator_id)
	var owned := int(GameManager.state["generators"][generator_id])
	var mode := int(GameManager.state["automation"]["autobuyers"][generator_id]["mode"])
	var auto_enabled := bool(GameManager.state["automation"]["autobuyers"][generator_id]["enabled"])
	owned_label.text = "Quantidade: %d" % owned
	output_label.text = "Unidade: %s/s | Total: %s/s" % [
		NumberFormatter.format_number(GameManager.get_generator_output(generator_id), scientific),
		NumberFormatter.format_number(GameManager.get_generator_output(generator_id) * owned, scientific)
	]
	cost_label.text = "Próximo custo: %s Ordem" % NumberFormatter.format_number(GameManager.get_generator_cost(generator_id), scientific)
	buy_one.disabled = not GameManager.can_afford("order", GameManager.get_generator_bulk_cost(generator_id, 1))
	buy_ten.disabled = not GameManager.can_afford("order", GameManager.get_generator_bulk_cost(generator_id, 10))
	buy_max.disabled = GameManager.get_generator_bulk_cost(generator_id, 1) > GameManager.state["resources"]["order"]
	auto_toggle.text = "Auto: ON" if auto_enabled else "Auto: OFF"
	mode_button.text = "Modo: %s" % ("1" if mode == GameManager.BUY_ONE else "10" if mode == GameManager.BUY_TEN else "MAX")
	desc_label.tooltip_text = def["description"]
