extends RefCounted
class_name NumberUtils

static func safe_pow(base: float, exponent: float) -> float:
	if base <= 0.0:
		return 0.0
	if exponent == 0.0:
		return 1.0
	return exp(exponent * log(base))

static func geometric_cost(base_cost: float, growth: float, owned: int, quantity: int) -> float:
	if quantity <= 0:
		return 0.0
	var start_cost := base_cost * safe_pow(growth, owned)
	if absf(growth - 1.0) < 0.00001:
		return start_cost * float(quantity)
	return start_cost * (safe_pow(growth, quantity) - 1.0) / (growth - 1.0)

static func max_affordable(base_cost: float, growth: float, owned: int, currency: float) -> int:
	if currency < base_cost * safe_pow(growth, owned):
		return 0
	var total := 0
	var probe_cost := base_cost * safe_pow(growth, owned)
	var remaining := currency
	while remaining >= probe_cost and total < 100000:
		remaining -= probe_cost
		total += 1
		probe_cost *= growth
	return total
