extends AcceptDialog

@onready var summary_label: RichTextLabel = %SummaryLabel

func _ready() -> void:
	confirmed.connect(func(): GameManager.perform_prestige())

func refresh() -> void:
	var gained := GameManager.get_projected_cores()
	summary_label.text = "[b]Recalibrar[/b]\n\nGanhará: %s Núcleos\n\nSerá perdido:\n- Ordem\n- Estruturas\n- geradores\n- upgrades temporários\n\nSerá mantido:\n- Núcleos\n- Ecos\n- estatísticas históricas\n- upgrades meta\n- alguns desbloqueios de interface" % NumberFormatter.format_number(gained, ConfigManager.use_scientific())
	dialog_text = ""
