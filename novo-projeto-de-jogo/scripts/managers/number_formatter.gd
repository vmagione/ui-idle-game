extends Node

const SUFFIXES := ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]

func format_number(value: float, scientific := false) -> String:
	if is_nan(value):
		return "0"
	if absf(value) < 1000.0:
		if value >= 100.0:
			return str(snapped(value, 0.1))
		if value >= 10.0:
			return "%.2f" % value
		return "%.3f" % value
	if scientific:
		return "%.3e" % value
	var sign := "-" if value < 0.0 else ""
	var n := absf(value)
	var idx := 0
	while n >= 1000.0 and idx < SUFFIXES.size() - 1:
		n /= 1000.0
		idx += 1
	if idx >= SUFFIXES.size() - 1 and n >= 1000.0:
		return "%s%.3e" % [sign, absf(value)]
	return "%s%.2f%s" % [sign, n, SUFFIXES[idx]]

func format_time(seconds: float) -> String:
	var total := int(maxf(0.0, seconds))
	var h := total / 3600
	var m := (total % 3600) / 60
	var s := total % 60
	if h > 0:
		return "%02dh %02dm %02ds" % [h, m, s]
	if m > 0:
		return "%02dm %02ds" % [m, s]
	return "%02ds" % s
