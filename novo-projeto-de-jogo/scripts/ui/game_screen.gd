extends Control

signal back_to_menu_requested

const GENERATOR_CARD := preload("res://scenes/ui/GeneratorCard.tscn")
const UPGRADE_CARD := preload("res://scenes/ui/UpgradeCard.tscn")
const OBJECTIVE_CARD := preload("res://scenes/ui/ObjectiveCard.tscn")
const LOG_ITEM := preload("res://scenes/ui/LogItem.tscn")
const OPTIONS_POPUP := preload("res://scenes/popups/OptionsPopup.tscn")

var generator_cards := {}
var upgrade_cards := {}
var meta_cards := {}
var objective_cards := {}
var options_popup: Window

@onready var tabs: TabContainer = %Tabs
@onready var production_list: VBoxContainer = %ProductionList
@onready var structures_list: VBoxContainer = %StructuresList
@onready var upgrades_list: VBoxContainer = %UpgradesList
@onready var meta_list: VBoxContainer = %MetaList
@onready var objectives_list: VBoxContainer = %ObjectivesList
@onready var log_list: VBoxContainer = %LogList
@onready var milestone_text: RichTextLabel = %MilestoneText
@onready var notifications_text: RichTextLabel = %NotificationsText
@onready var achievements_text: RichTextLabel = %AchievementsText
@onready var archive_text: RichTextLabel = %ArchiveText
@onready var statistics_text: RichTextLabel = %StatisticsText
@onready var options_text: RichTextLabel = %OptionsText
@onready var help_text: RichTextLabel = %HelpText
@onready var quick_stats_label: RichTextLabel = %QuickStatsLabel
@onready var objective_preview: RichTextLabel = %ObjectivePreview
@onready var resource_summary: Label = %ResourceSummary
@onready var click_value_label: Label = %ClickValueLabel
@onready var generate_button: Button = %GenerateButton
@onready var prestige_button: Button = %PrestigeButton
@onready var auto_recalibrate_toggle: CheckBox = %AutoRecalibrateToggle
@onready var auto_upgrade_toggle: CheckBox = %AutoUpgradeToggle
@onready var auto_recalibrate_target: SpinBox = %AutoRecalibrateTarget
@onready var focus_option: OptionButton = %FocusOption
@onready var focus_description: RichTextLabel = %FocusDescription
@onready var prestige_popup: AcceptDialog = %PrestigePopup
@onready var offline_popup = %OfflineProgressPopup

func _ready() -> void:
	options_popup = OPTIONS_POPUP.instantiate()
	add_child(options_popup)
	options_popup.hide()
	_apply_theme()
	_connect_ui()
	_build_lists()
	_fill_static_text()
	_refresh_all()
	GameManager.state_changed.connect(_refresh_all)
	GameManager.offline_progress_ready.connect(func(report): offline_popup.show_report(report))
	ConfigManager.config_changed.connect(_apply_theme)

func _apply_theme() -> void:
	%Background.color = ThemeHelper.color("bg")
	for panel in [%TopBar, %LeftPanel, %CenterPanel, %RightPanel]:
		ThemeHelper.apply_panel(panel)
	for button in [%SaveButton, %OptionsButton, %MenuButton, generate_button, prestige_button]:
		ThemeHelper.apply_button(button, button == generate_button)

func _connect_ui() -> void:
	generate_button.pressed.connect(GameManager.click_order)
	%SaveButton.pressed.connect(GameManager.save_game)
	%OptionsButton.pressed.connect(func(): options_popup.open_popup())
	%MenuButton.pressed.connect(func():
		GameManager.save_game()
		back_to_menu_requested.emit()
	)
	prestige_button.pressed.connect(_on_prestige_pressed)
	auto_recalibrate_toggle.toggled.connect(func(_v): GameManager.toggle_auto_recalibrate())
	auto_upgrade_toggle.toggled.connect(func(_v): GameManager.toggle_auto_upgrade())
	auto_recalibrate_target.value_changed.connect(GameManager.set_auto_recalibrate_target)
	focus_option.item_selected.connect(_on_focus_selected)

func _build_lists() -> void:
	tabs.set_tab_title(0, "Produção")
	tabs.set_tab_title(1, "Estruturas")
	tabs.set_tab_title(2, "Upgrades")
	tabs.set_tab_title(3, "Meta")
	tabs.set_tab_title(4, "Objetivos")
	tabs.set_tab_title(5, "Conquistas")
	tabs.set_tab_title(6, "Estatísticas")
	tabs.set_tab_title(7, "Opções")
	tabs.set_tab_title(8, "Ajuda")
	tabs.set_tab_title(9, "Arquivo")
	for child in production_list.get_children():
		child.queue_free()
	for child in upgrades_list.get_children():
		child.queue_free()
	for child in meta_list.get_children():
		child.queue_free()
	for child in objectives_list.get_children():
		child.queue_free()
	generator_cards.clear()
	upgrade_cards.clear()
	meta_cards.clear()
	objective_cards.clear()
	for generator in GameManager.generator_defs:
		var card = GENERATOR_CARD.instantiate()
		production_list.add_child(card)
		card.setup(generator)
		generator_cards[generator["id"]] = card
	for structure in GameManager.structure_defs:
		var panel := PanelContainer.new()
		ThemeHelper.apply_panel(panel, "panel")
		var vb := VBoxContainer.new()
		panel.add_child(vb)
		var title := Label.new()
		title.text = structure["name"]
		vb.add_child(title)
		var desc := Label.new()
		desc.text = structure["description"]
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vb.add_child(desc)
		var btn := Button.new()
		btn.text = "Adquirir"
		ThemeHelper.apply_button(btn)
		btn.pressed.connect(GameManager.buy_structure.bind(String(structure["id"])))
		panel.set_meta("id", structure["id"])
		panel.set_meta("button", btn)
		panel.set_meta("desc", desc)
		vb.add_child(btn)
		structures_list.add_child(panel)
	for upgrade in GameManager.upgrade_defs:
		var card = UPGRADE_CARD.instantiate()
		card.setup(upgrade)
		if upgrade["type"] == "meta":
			meta_list.add_child(card)
			meta_cards[upgrade["id"]] = card
		else:
			upgrades_list.add_child(card)
			upgrade_cards[upgrade["id"]] = card
	for objective in GameManager.objective_defs:
		var card = OBJECTIVE_CARD.instantiate()
		card.setup(objective)
		objectives_list.add_child(card)
		objective_cards[objective["id"]] = card

func _fill_static_text() -> void:
	help_text.text = "[b]Recursos[/b]\nOrdem move o começo. Estruturas multiplicam a run. Núcleos vêm de Recalibrar. Ecos aparecem no endgame.\n\n[b]Prestígio[/b]\nRecalibrar reinicia a run atual e converte progresso em Núcleos permanentes.\n\n[b]Offline[/b]\nAo voltar, o jogo aplica produção estável com limite de tempo.\n\n[b]Campanha Base[/b]\nAlcance o Protocolo Infinito para concluir o ciclo base sem encerrar o jogo."
	options_text.text = "Use o botão Opções no topo para editar notação, tema, autosave, confirmações e economia."

func _refresh_all() -> void:
	var s: Dictionary = GameManager.get_state()
	var sci: bool = ConfigManager.use_scientific()
	resource_summary.text = "Ordem %s | %s/s | Estruturas %s | Núcleos %s | Ecos %s" % [
		NumberFormatter.format_number(s["resources"]["order"], sci),
		NumberFormatter.format_number(GameManager.get_order_per_second(), sci),
		NumberFormatter.format_number(s["resources"]["structures"], sci),
		NumberFormatter.format_number(s["resources"]["cores"], sci),
		NumberFormatter.format_number(s["resources"]["echoes"], sci)
	]
	click_value_label.text = "Clique gera %s Ordem por entrada manual." % NumberFormatter.format_number(GameManager.get_click_value(), sci)
	prestige_button.text = "Recalibrar (+%s Núcleos)" % NumberFormatter.format_number(GameManager.get_projected_cores(), sci)
	prestige_button.disabled = not GameManager.can_prestige()
	auto_recalibrate_toggle.set_pressed_no_signal(bool(s["automation"]["auto_recalibrate"]["enabled"]))
	auto_upgrade_toggle.set_pressed_no_signal(bool(s["automation"]["auto_upgrades"]))
	auto_recalibrate_target.value = float(s["automation"]["auto_recalibrate"]["target"])
	_refresh_focus_controls()
	quick_stats_label.text = "[b]Run[/b]\nTempo: %s\nProdução máxima: %s/s\nTotal da run: %s Ordem\nCampanha base: %s" % [
		NumberFormatter.format_time(float(s["run_time"])),
		NumberFormatter.format_number(float(s["stats"]["max_order_per_second"]), sci),
		NumberFormatter.format_number(float(s["total_resources"]["order"]), sci),
		"concluída" if s["campaign_complete"] else "em progresso"
	]
	var preview_lines: Array[String] = []
	for objective in GameManager.objective_defs:
		if not s["objectives_completed"].has(objective["id"]) and preview_lines.size() < 4:
			preview_lines.append("- %s" % objective["name"])
	objective_preview.text = "[b]Próximos[/b]\n%s" % ("\n".join(preview_lines) if not preview_lines.is_empty() else "Todos concluídos")
	for card in generator_cards.values():
		card.refresh()
	for card in upgrade_cards.values():
		card.refresh()
	for card in meta_cards.values():
		card.refresh()
	for card in objective_cards.values():
		card.refresh()
	_refresh_structures()
	_refresh_tabs()
	_refresh_statistics()
	_refresh_milestones()
	_refresh_achievements()
	_refresh_archive()
	_refresh_notifications()
	_refresh_log()
	_animate_primary_button()

func _refresh_structures() -> void:
	var sci: bool = ConfigManager.use_scientific()
	for child in structures_list.get_children():
		var id: String = String(child.get_meta("id"))
		var btn: Button = child.get_meta("button")
		var desc: Label = child.get_meta("desc")
		btn.text = "Adquirir (%s Ordem)" % NumberFormatter.format_number(GameManager.get_structure_cost(id), sci)
		btn.disabled = not GameManager.can_afford("order", GameManager.get_structure_cost(id))
		desc.text = "%s\nPossui: %d" % [GameManager.get_structure_def(id)["description"], GameManager.get_structure_count(id)]

func _refresh_tabs() -> void:
	%StructuresTab.visible = GameManager.is_tab_unlocked("structures")
	%MetaTab.visible = GameManager.is_tab_unlocked("meta")

func _refresh_focus_controls() -> void:
	var unlocked := GameManager.get_unlocked_focus_directives()
	var current_id := String(GameManager.state["focus_directive"])
	var selected_index := 0
	if focus_option.item_count != unlocked.size():
		focus_option.clear()
		for directive in unlocked:
			focus_option.add_item(directive["name"])
			focus_option.set_item_metadata(focus_option.item_count - 1, directive["id"])
	for i in range(focus_option.item_count):
		if String(focus_option.get_item_metadata(i)) == current_id:
			selected_index = i
			break
	focus_option.select(selected_index)
	var current := GameManager.get_focus_def(current_id)
	focus_description.text = "[b]%s[/b]\n%s" % [current.get("name", "Equilíbrio Operacional"), current.get("desc", "")]

func _refresh_statistics() -> void:
	var s: Dictionary = GameManager.get_state()
	var sci: bool = ConfigManager.use_scientific()
	statistics_text.text = "[b]Estatísticas[/b]\nTempo total: %s\nOrdem total produzida: %s\nMaior Ordem: %s\nMaior produção/s: %s\nCliques totais: %d\nGeradores comprados: %d\nRecalibrações: %d\nNúcleos totais: %s\nEcos totais: %s\nÚltimo offline: %s" % [
		NumberFormatter.format_time(float(s["stats"]["total_play_time"])),
		NumberFormatter.format_number(float(s["total_resources"]["order"]), sci),
		NumberFormatter.format_number(float(s["stats"]["highest_order"]), sci),
		NumberFormatter.format_number(float(s["stats"]["max_order_per_second"]), sci),
		int(s["stats"]["total_clicks"]),
		int(s["stats"]["total_generators_bought"]),
		int(s["stats"]["total_recalibrations"]),
		NumberFormatter.format_number(float(s["stats"]["total_cores_earned"]), sci),
		NumberFormatter.format_number(float(s["stats"]["total_echoes_earned"]), sci),
		NumberFormatter.format_time(float(s["stats"]["last_offline_seconds"]))
	]

func _refresh_milestones() -> void:
	var lines: Array[String] = []
	for milestone in GameManager.milestone_defs:
		var done: bool = GameManager.state["milestones_completed"].has(milestone["id"])
		lines.append("%s %s" % ["[color=#8be9a8]OK[/color]" if done else "[color=#ffd166]...[/color]", milestone["name"]])
	milestone_text.text = "[b]Marcos Passivos[/b]\n%s" % "\n".join(lines)

func _refresh_achievements() -> void:
	var lines: Array[String] = ["[b]Conquistas Operacionais[/b]"]
	for achievement in GameManager.achievement_defs:
		var unlocked: bool = GameManager.state["achievements_completed"].has(achievement["id"])
		var marker := "[color=#8be9a8]OK[/color]" if unlocked else "[color=#97a6c4]--[/color]"
		lines.append("%s %s: %s" % [marker, achievement["name"], achievement["desc"]])
	achievements_text.text = "\n".join(lines)

func _refresh_archive() -> void:
	var lines: Array[String] = ["[b]Arquivo Interno[/b]"]
	for entry in GameManager.get_visible_codex_entries():
		lines.append("[b]%s[/b]\n%s" % [entry["title"], entry["body"]])
	archive_text.text = "\n\n".join(lines)

func _refresh_notifications() -> void:
	var lines: Array[String] = []
	for note in GameManager.state["notifications"]:
		lines.append("[color=#71d0ff]%s[/color] %s" % [note["time"], note["message"]])
	notifications_text.text = "\n".join(lines) if not lines.is_empty() else "Sem destaques recentes."

func _refresh_log() -> void:
	for child in log_list.get_children():
		child.queue_free()
	for entry in GameManager.state["log"]:
		var item = LOG_ITEM.instantiate()
		log_list.add_child(item)
		item.setup(entry)

func _animate_primary_button() -> void:
	if not ConfigManager.get_value("ui_animations", true):
		generate_button.scale = Vector2.ONE
		return
	var target: float = 1.02 if int(Time.get_ticks_msec() / 400) % 2 == 0 else 0.98
	generate_button.scale = Vector2(target, target)

func _on_prestige_pressed() -> void:
	if not GameManager.can_prestige():
		return
	if ConfigManager.get_value("confirm_resets", true):
		prestige_popup.refresh()
		prestige_popup.popup_centered_ratio(0.35)
	else:
		GameManager.perform_prestige()

func _on_focus_selected(index: int) -> void:
	if index < 0:
		return
	var directive_id := String(focus_option.get_item_metadata(index))
	GameManager.set_focus_directive(directive_id)
