extends AcceptDialog

@onready var summary_label: RichTextLabel = %SummaryLabel

func show_report(report: Dictionary) -> void:
	summary_label.text = "[b]Retorno Offline[/b]\n\nTempo ausente: %s\nOrdem: +%s\nEstruturas: +%s\nEcos: +%s" % [
		NumberFormatter.format_time(float(report.get("seconds", 0.0))),
		NumberFormatter.format_number(float(report.get("order_gain", 0.0)), ConfigManager.use_scientific()),
		NumberFormatter.format_number(float(report.get("structures_gain", 0.0)), ConfigManager.use_scientific()),
		NumberFormatter.format_number(float(report.get("echo_gain", 0.0)), ConfigManager.use_scientific())
	]
	popup_centered_ratio(0.35)
