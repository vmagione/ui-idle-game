extends Node

signal state_changed
signal log_added(message: String)
signal objective_completed(objective_id: String)
signal unlock_triggered(key: String)
signal offline_progress_ready(report: Dictionary)
signal prestige_ready_changed(can_prestige: bool)

const BUY_ONE := 1
const BUY_TEN := 10
const BUY_MAX := -1

var generator_defs: Array = GameDatabase.generators()
var structure_defs: Array = GameDatabase.structures()
var upgrade_defs: Array = GameDatabase.upgrades()
var objective_defs: Array = GameDatabase.objectives()
var milestone_defs: Array = GameDatabase.milestones()

var state: Dictionary = {}
var _tick_accumulator := 0.0
var _ui_accumulator := 0.0
var _autosave_accumulator := 0.0
var _was_prestige_ready := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reset_to_new_game(false)

func _process(delta: float) -> void:
	_tick_accumulator += delta
	_ui_accumulator += delta
	_autosave_accumulator += delta
	while _tick_accumulator >= 1.0 / GameDatabase.TICK_RATE:
		var step := 1.0 / GameDatabase.TICK_RATE
		_tick_accumulator -= step
		advance_time(step)
	if _ui_accumulator >= 1.0 / GameDatabase.UI_RATE:
		_ui_accumulator = 0.0
		state_changed.emit()
	if _autosave_accumulator >= float(ConfigManager.get_value("autosave_interval", GameDatabase.AUTOSAVE_DEFAULT)):
		_autosave_accumulator = 0.0
		save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		save_game()

func reset_to_new_game(emit_change := true) -> void:
	state = _make_fresh_state()
	_apply_meta_starting_bonuses()
	_recalculate_all()
	if emit_change:
		state_changed.emit()

func start_new_game() -> void:
	reset_to_new_game()
	log_event("Novo departamento iniciado.")

func continue_game() -> bool:
	var loaded := SaveManager.load_game()
	if loaded.is_empty():
		return false
	state = _merge_state(_make_fresh_state(), loaded)
	var now := Time.get_unix_time_from_system()
	var last_save := float(state.get("last_save_time", now))
	var offline_seconds := maxf(0.0, float(now - last_save))
	var report := apply_offline_progress(offline_seconds)
	_recalculate_all()
	if report.get("seconds", 0.0) > 0.0:
		offline_progress_ready.emit(report)
	return true

func save_game() -> bool:
	state["last_save_time"] = Time.get_unix_time_from_system()
	return SaveManager.save_game(state.duplicate(true))

func delete_save() -> void:
	SaveManager.delete_save()

func click_order() -> void:
	var gain := get_click_value()
	add_resource("order", gain)
	state["stats"]["total_clicks"] += 1
	_recalculate_all()

func advance_time(seconds: float) -> void:
	state["stats"]["total_play_time"] += seconds
	state["run_time"] += seconds
	state["time_since_last_improvement"] += seconds
	_run_automation()
	add_resource("order", get_order_per_second() * seconds)
	add_resource("structures", get_structure_generation_per_second() * seconds)
	if can_generate_echoes():
		add_resource("echoes", get_echo_gain_rate() * seconds)
	state["stats"]["max_order_per_second"] = maxf(state["stats"]["max_order_per_second"], get_order_per_second())
	state["stats"]["highest_order"] = maxf(state["stats"]["highest_order"], state["resources"]["order"])
	_check_unlocks()
	_check_objectives()
	_check_milestones()
	_check_campaign_completion()
	_emit_prestige_state_if_changed()

func add_resource(resource: String, amount: float) -> void:
	if amount <= 0.0:
		return
	state["resources"][resource] = float(state["resources"].get(resource, 0.0)) + amount
	if resource == "order":
		state["total_resources"]["order"] += amount
	if resource == "structures":
		state["stats"]["total_structures_earned"] += amount
	if resource == "cores":
		state["stats"]["total_cores_earned"] += amount
	if resource == "echoes":
		state["stats"]["total_echoes_earned"] += amount

func spend_resource(resource: String, amount: float) -> bool:
	if float(state["resources"].get(resource, 0.0)) + 0.00001 < amount:
		return false
	state["resources"][resource] -= amount
	return true

func can_afford(resource: String, amount: float) -> bool:
	return float(state["resources"].get(resource, 0.0)) + 0.00001 >= amount

func buy_generator(generator_id: String, mode := BUY_ONE, silent := false) -> bool:
	var def := get_generator_def(generator_id)
	var qty := 1
	if mode == BUY_TEN:
		qty = 10
	elif mode == BUY_MAX:
		qty = NumberUtils.max_affordable(def["base_cost"], def["growth"] * get_generator_cost_discount(), int(state["generators"][generator_id]), state["resources"]["order"])
	if qty <= 0:
		return false
	var cost := get_generator_bulk_cost(generator_id, qty)
	if not spend_resource("order", cost):
		return false
	state["generators"][generator_id] += qty
	state["stats"]["total_generators_bought"] += qty
	if not silent:
		log_event("%s adquiridos: +%d." % [def["name"], qty])
	_recalculate_all()
	return true

func buy_structure(structure_id: String, silent := false) -> bool:
	var cost := get_structure_cost(structure_id)
	if not spend_resource("order", cost):
		return false
	state["structures"][structure_id] += 1
	if not silent:
		log_event("Estrutura adquirida: %s." % get_structure_def(structure_id)["name"])
	_recalculate_all()
	return true

func buy_upgrade(upgrade_id: String, silent := false) -> bool:
	var def := get_upgrade_def(upgrade_id)
	var owned := int(state["upgrades"].get(upgrade_id, 0))
	if owned >= int(def["max_level"]):
		return false
	var cost := get_upgrade_cost(upgrade_id)
	var resource := String(def["cost_resource"])
	if not spend_resource(resource, cost):
		return false
	state["upgrades"][upgrade_id] = owned + 1
	if not silent:
		log_event("Upgrade adquirido: %s." % def["name"])
	_recalculate_all()
	return true

func toggle_autobuyer(generator_id: String) -> void:
	state["automation"]["autobuyers"][generator_id]["enabled"] = not state["automation"]["autobuyers"][generator_id]["enabled"]
	state_changed.emit()

func cycle_autobuyer_mode(generator_id: String) -> void:
	var current := int(state["automation"]["autobuyers"][generator_id]["mode"])
	var modes := [BUY_ONE, BUY_TEN, BUY_MAX]
	state["automation"]["autobuyers"][generator_id]["mode"] = modes[(modes.find(current) + 1) % modes.size()]
	state_changed.emit()

func toggle_auto_upgrade() -> void:
	state["automation"]["auto_upgrades"] = not state["automation"]["auto_upgrades"]
	state_changed.emit()

func toggle_auto_recalibrate() -> void:
	state["automation"]["auto_recalibrate"]["enabled"] = not state["automation"]["auto_recalibrate"]["enabled"]
	state_changed.emit()

func set_auto_recalibrate_target(value: float) -> void:
	state["automation"]["auto_recalibrate"]["target"] = maxf(1.0, value)

func can_prestige() -> bool:
	return get_projected_cores() >= 1.0

func get_projected_cores() -> float:
	var total_order := maxf(0.0, float(state["total_resources"]["order"]))
	if total_order < GameDatabase.PRESTIGE_UNLOCK_TOTAL_ORDER:
		return 0.0
	var raw := pow(total_order / 50000.0, 0.32) - 2.0
	raw = maxf(0.0, floor(raw))
	raw *= 1.0 + get_upgrade_level("prestige_studies") * 0.20
	raw *= 1.0 + get_meta_level("core_yield") * 0.15
	return floor(raw)

func perform_prestige() -> bool:
	var gained: float = get_projected_cores()
	if gained <= 0.0:
		return false
	var cores_after: float = float(state["resources"]["cores"]) + gained
	var echoes_after: float = float(state["resources"]["echoes"])
	var stats_copy: Dictionary = state["stats"].duplicate(true)
	stats_copy["total_recalibrations"] += 1
	stats_copy["total_cores_earned"] += gained
	var completed_objectives: Dictionary = state["objectives_completed"].duplicate(true)
	var completed_milestones: Dictionary = state["milestones_completed"].duplicate(true)
	var meta_levels: Dictionary = _extract_meta_upgrades()
	var keep_upgrades: Dictionary = {}
	if get_upgrade_level("preservation_protocol") > 0:
		for upgrade_id in ["bulk_procurement", "detailed_metrics", "automation_bus", "offline_report", "auto_upgrade_unlock"]:
			if int(state["upgrades"].get(upgrade_id, 0)) > 0:
				keep_upgrades[upgrade_id] = state["upgrades"][upgrade_id]
	state = _make_fresh_state()
	state["resources"]["cores"] = cores_after
	state["resources"]["echoes"] = echoes_after
	state["stats"] = stats_copy
	state["objectives_completed"] = completed_objectives
	state["milestones_completed"] = completed_milestones
	state["upgrades"].merge(meta_levels, true)
	state["upgrades"].merge(keep_upgrades, true)
	_apply_meta_starting_bonuses()
	log_event("Recalibração concluída. Núcleos recebidos: %s." % NumberFormatter.format_number(gained, ConfigManager.use_scientific()))
	_recalculate_all()
	return true

func apply_offline_progress(seconds_offline: float) -> Dictionary:
	var cap := GameDatabase.OFFLINE_EXTENDED_CAP if get_upgrade_level("offline_report") > 0 else GameDatabase.OFFLINE_BASE_CAP
	var effective_seconds := minf(seconds_offline, cap)
	if effective_seconds <= 1.0:
		return {}
	var order_gain := get_order_per_second() * effective_seconds * (1.0 + get_meta_level("offline_archive") * 0.20)
	var structure_gain := get_structure_generation_per_second() * effective_seconds
	var echo_gain := get_echo_gain_rate() * effective_seconds if can_generate_echoes() else 0.0
	add_resource("order", order_gain)
	add_resource("structures", structure_gain)
	add_resource("echoes", echo_gain)
	state["stats"]["last_offline_seconds"] = effective_seconds
	return {"seconds": effective_seconds, "order_gain": order_gain, "structures_gain": structure_gain, "echo_gain": echo_gain}

func get_click_value() -> float:
	var base := 1.0
	base *= 1.0 + get_meta_level("click_foundation") * 0.30
	base *= 1.0 + get_upgrade_level("click_training") * 1.0
	base *= 1.0 + get_upgrade_level("click_overclock") * 0.70
	base *= 1.0 + get_structure_count("standardization") * (0.40 + 0.04 * get_upgrade_level("structure_blueprints"))
	base += get_order_per_second() * (0.01 * get_upgrade_level("order_feedback"))
	base *= 1.0 + _get_objective_multiplier_bonus()
	return maxf(1.0, base)

func get_order_per_second() -> float:
	var total := 0.0
	for generator_def in generator_defs:
		var generator_id := String(generator_def["id"])
		total += get_generator_output(generator_id) * float(state["generators"][generator_id])
	total *= get_global_production_multiplier()
	return total

func get_generator_output(generator_id: String) -> float:
	var def := get_generator_def(generator_id)
	var base := float(def["base_output"])
	var owned := int(state["generators"][generator_id])
	var multiplier := 1.0
	if generator_id == "scribes":
		multiplier *= 1.0 + get_upgrade_level("scribe_manuals")
		multiplier *= 1.0 + get_upgrade_level("cross_training") * float(state["generators"]["protocols"]) * 0.03
		multiplier *= _milestone_strength(owned, [10, 25], 1.0)
	if generator_id == "protocols":
		multiplier *= 1.0 + get_upgrade_level("protocol_templates")
		multiplier *= _milestone_strength(owned, [25], 1.0)
	if generator_id == "archivists":
		multiplier *= 1.0 + get_upgrade_level("archive_indexing")
		multiplier *= 1.0 + get_upgrade_level("deep_archives") * float(state["generators"]["directives"]) * 0.05
		multiplier *= _milestone_strength(owned, [10], 1.0)
	if generator_id == "directives":
		multiplier *= 1.0 + get_upgrade_level("directive_lattice")
		multiplier *= _milestone_strength(owned, [10], 1.0)
	if generator_id == "councils":
		multiplier *= 1.0 + get_upgrade_level("council_charter")
		multiplier *= 1.0 + get_upgrade_level("council_echoes") * 0.75
	if generator_id in ["scribes", "protocols"]:
		multiplier *= 1.0 + get_structure_count("synchronization") * 0.35
	if generator_id in ["scribes", "protocols", "archivists", "directives"]:
		multiplier *= 1.0 + float(state["generators"]["councils"]) * 0.08 * get_upgrade_level("council_echoes")
	multiplier *= 1.0 + _get_total_generators_bought() * 0.0025 * get_structure_count("scaling")
	return base * multiplier

func get_global_production_multiplier() -> float:
	var mult := 1.0
	mult *= 1.0 + get_meta_level("core_efficiency") * 0.25
	mult *= 1.0 + get_upgrade_level("run_multiplier") * 0.30
	mult *= 1.0 + get_upgrade_level("structure_resonance") * 0.06 * get_total_structures_owned()
	mult *= 1.0 + get_structure_count("compression") * (0.55 + 0.05 * get_upgrade_level("structure_blueprints"))
	mult *= 1.0 + get_structure_count("abstraction") * 0.18
	mult *= 1.0 + get_meta_level("echo_resonator") * state["resources"]["echoes"]
	mult *= 1.0 + _get_objective_multiplier_bonus()
	if state["campaign_complete"]:
		mult *= 1.5
	return mult

func get_structure_generation_per_second() -> float:
	if not is_tab_unlocked("structures"):
		return 0.0
	return maxf(0.0, get_order_per_second() / 2500.0) * (0.02 + get_structure_count("abstraction") * 0.005)

func can_generate_echoes() -> bool:
	return is_tab_unlocked("echoes")

func get_echo_gain_rate() -> float:
	if not can_generate_echoes():
		return 0.0
	var rate := pow(maxf(1.0, state["total_resources"]["order"]) / 1.0e10, 0.18) * 0.002
	rate *= 1.0 + get_upgrade_level("echo_lens") * 0.5
	return rate

func get_generator_cost(generator_id: String) -> float:
	var def := get_generator_def(generator_id)
	return def["base_cost"] * NumberUtils.safe_pow(def["growth"] * get_generator_cost_discount(), int(state["generators"][generator_id]))

func get_generator_bulk_cost(generator_id: String, quantity: int) -> float:
	var def := get_generator_def(generator_id)
	return NumberUtils.geometric_cost(def["base_cost"], def["growth"] * get_generator_cost_discount(), int(state["generators"][generator_id]), quantity)

func get_structure_cost(structure_id: String) -> float:
	var def := get_structure_def(structure_id)
	var owned := get_structure_count(structure_id)
	var discount := 1.0 - 0.12 * minf(1.0, get_upgrade_level("structure_permits"))
	discount *= 1.0 - 0.04 * get_meta_level("starting_structures")
	return float(def["base_cost"]) * NumberUtils.safe_pow(float(def["growth"]), owned) * maxf(0.5, discount)

func get_upgrade_cost(upgrade_id: String) -> float:
	var def := get_upgrade_def(upgrade_id)
	var lvl := get_upgrade_level(upgrade_id)
	return float(def["cost"]) * NumberUtils.safe_pow(1.65, lvl)

func get_generator_cost_discount() -> float:
	return 0.985 if get_upgrade_level("bulk_procurement") > 0 else 1.0

func get_generator_def(generator_id: String) -> Dictionary:
	for item in generator_defs:
		if item["id"] == generator_id:
			return item
	return {}

func get_structure_def(structure_id: String) -> Dictionary:
	for item in structure_defs:
		if item["id"] == structure_id:
			return item
	return {}

func get_upgrade_def(upgrade_id: String) -> Dictionary:
	for item in upgrade_defs:
		if item["id"] == upgrade_id:
			return item
	return {}

func get_upgrade_level(upgrade_id: String) -> int:
	return int(state["upgrades"].get(upgrade_id, 0))

func get_meta_level(upgrade_id: String) -> int:
	return get_upgrade_level(upgrade_id)

func get_structure_count(structure_id: String) -> int:
	return int(state["structures"].get(structure_id, 0))

func get_total_structures_owned() -> int:
	var total := 0
	for structure_id in state["structures"].keys():
		total += int(state["structures"][structure_id])
	return total

func is_tab_unlocked(tab_id: String) -> bool:
	return bool(state["unlocks"]["main_tabs"].get(tab_id, false))

func get_state() -> Dictionary:
	return state

func get_visible_upgrades() -> Array:
	var visible := []
	for upgrade in upgrade_defs:
		if upgrade["type"] == "meta" and not is_tab_unlocked("meta"):
			continue
		if upgrade["type"] == "run" and String(upgrade["cost_resource"]) == "structures" and not is_tab_unlocked("structures"):
			continue
		visible.append(upgrade)
	return visible

func get_visible_objectives() -> Array:
	return objective_defs

func get_visible_milestones() -> Array:
	return milestone_defs

func log_event(message: String) -> void:
	var timestamp := Time.get_datetime_string_from_system(false, true)
	state["log"].push_front({"time": timestamp, "message": message})
	while state["log"].size() > GameDatabase.LOG_LIMIT:
		state["log"].pop_back()
	log_added.emit(message)

func _run_automation() -> void:
	var autobuy_enabled: bool = get_upgrade_level("autobuyer_permit") > 0 or (state["stats"]["total_recalibrations"] >= 1 and get_upgrade_level("automation_bus") > 0)
	if autobuy_enabled:
		for generator_id in state["automation"]["autobuyers"].keys():
			var buyer: Dictionary = state["automation"]["autobuyers"][generator_id]
			if buyer["enabled"]:
				buy_generator(generator_id, int(buyer["mode"]), true)
	var auto_upgrades_enabled: bool = bool(state["automation"]["auto_upgrades"]) and (get_upgrade_level("auto_upgrade_permit") > 0 or get_upgrade_level("auto_upgrade_unlock") > 0)
	if auto_upgrades_enabled:
		for upgrade in get_visible_upgrades():
			if upgrade["type"] == "meta":
				continue
			buy_upgrade(upgrade["id"], true)
	var auto_recal: Dictionary = state["automation"]["auto_recalibrate"]
	if auto_recal["enabled"] and can_prestige() and get_projected_cores() >= float(auto_recal["target"]):
		perform_prestige()

func _check_unlocks() -> void:
	if not is_tab_unlocked("structures") and state["total_resources"]["order"] >= GameDatabase.STRUCTURE_UNLOCK_TOTAL_ORDER:
		state["unlocks"]["main_tabs"]["structures"] = true
		unlock_triggered.emit("structures")
		log_event("Estruturas desbloqueadas.")
	if not is_tab_unlocked("prestige") and state["total_resources"]["order"] >= GameDatabase.PRESTIGE_UNLOCK_TOTAL_ORDER:
		state["unlocks"]["main_tabs"]["prestige"] = true
		unlock_triggered.emit("prestige")
		log_event("Recalibrar disponível.")
	if not is_tab_unlocked("meta") and state["stats"]["total_cores_earned"] >= GameDatabase.META_TREE_UNLOCK_CORES:
		state["unlocks"]["main_tabs"]["meta"] = true
		state["meta_unlocked"] = true
		unlock_triggered.emit("meta")
		log_event("Árvore de Núcleos desbloqueada.")
	if not is_tab_unlocked("echoes") and state["total_resources"]["order"] >= GameDatabase.ECHO_UNLOCK_TOTAL_ORDER:
		state["unlocks"]["main_tabs"]["echoes"] = true
		unlock_triggered.emit("echoes")
		log_event("Ecos detectados no departamento.")

func _check_objectives() -> void:
	for objective in objective_defs:
		var objective_id := String(objective["id"])
		if state["objectives_completed"].has(objective_id):
			continue
		if _is_objective_complete(objective):
			state["objectives_completed"][objective_id] = true
			_apply_objective_reward(objective["reward"])
			objective_completed.emit(objective_id)
			log_event("Objetivo concluído: %s." % objective["name"])

func _check_milestones() -> void:
	for milestone in milestone_defs:
		var milestone_id := String(milestone["id"])
		if state["milestones_completed"].has(milestone_id):
			continue
		if _is_milestone_complete(milestone):
			state["milestones_completed"][milestone_id] = true
			log_event("Marco atingido: %s." % milestone["name"])

func _check_campaign_completion() -> void:
	if state["campaign_complete"]:
		return
	if state["total_resources"]["order"] >= GameDatabase.CAMPAIGN_COMPLETION_ORDER:
		state["campaign_complete"] = true
		state["stats"]["campaign_complete"] = 1
		log_event("Protocolo Infinito ativado. Campanha base concluída.")

func _is_objective_complete(objective: Dictionary) -> bool:
	match String(objective["target_type"]):
		"total_order":
			return state["total_resources"]["order"] >= float(objective["target"])
		"generator_owned":
			return int(state["generators"][objective["target"]]) >= int(objective["value"])
		"pps":
			return get_order_per_second() >= float(objective["target"])
		"structures_total":
			return get_total_structures_owned() >= int(objective["target"])
		"unlock":
			return is_tab_unlocked(String(objective["target"]))
		"stat":
			var stat_key := String(objective["target"])
			if state["stats"].has(stat_key):
				return float(state["stats"].get(stat_key, 0.0)) >= float(objective["value"])
			return float(state["resources"].get(stat_key, 0.0)) >= float(objective["value"])
	return false

func _is_milestone_complete(milestone: Dictionary) -> bool:
	match String(milestone["kind"]):
		"generator":
			return int(state["generators"][milestone["target"]]) >= int(milestone["value"])
		"stat":
			var stat_key := String(milestone["target"])
			if state["stats"].has(stat_key):
				return float(state["stats"].get(stat_key, 0.0)) >= float(milestone["value"])
			return float(state["resources"].get(stat_key, 0.0)) >= float(milestone["value"])
		"total_order":
			return state["total_resources"]["order"] >= float(milestone["value"])
	return false

func _apply_objective_reward(reward: Dictionary) -> void:
	if reward.has("resource"):
		var amount := float(reward["amount"]) * (1.0 + get_upgrade_level("mission_division") * 0.35)
		add_resource(String(reward["resource"]), amount)
	if reward.has("multiplier"):
		state["objective_multiplier_bonus"] += float(reward["multiplier"])

func _get_objective_multiplier_bonus() -> float:
	return float(state.get("objective_multiplier_bonus", 0.0))

func _milestone_strength(owned: int, thresholds: Array, per_threshold_strength: float) -> float:
	var strength := 1.0
	var amp := 1.0 + get_meta_level("milestone_amplifier") * 0.15 + get_meta_level("escalation_lab") * 0.20
	for threshold in thresholds:
		if owned >= int(threshold):
			strength *= 1.0 + per_threshold_strength * amp
	return strength

func _recalculate_all() -> void:
	_check_unlocks()
	state_changed.emit()
	_emit_prestige_state_if_changed()

func _emit_prestige_state_if_changed() -> void:
	var now_ready := can_prestige()
	if now_ready != _was_prestige_ready:
		_was_prestige_ready = now_ready
		prestige_ready_changed.emit(now_ready)

func _apply_meta_starting_bonuses() -> void:
	state["generators"]["scribes"] += get_meta_level("starting_scribes")
	for structure_id in state["structures"].keys():
		state["structures"][structure_id] += get_meta_level("starting_structures")

func _extract_meta_upgrades() -> Dictionary:
	var meta := {}
	for upgrade in upgrade_defs:
		if upgrade["type"] == "meta":
			var id := String(upgrade["id"])
			if int(state["upgrades"].get(id, 0)) > 0:
				meta[id] = state["upgrades"][id]
	return meta

func _make_fresh_state() -> Dictionary:
	var generators := {}
	for generator in generator_defs:
		generators[generator["id"]] = 0
	var structures := {}
	for structure in structure_defs:
		structures[structure["id"]] = 0
	var autobuyers := {}
	for generator in generator_defs:
		autobuyers[generator["id"]] = {"enabled": false, "mode": BUY_ONE}
	return {
		"resources": {"order": 0.0, "structures": 0.0, "cores": 0.0, "echoes": 0.0},
		"total_resources": {"order": 0.0},
		"generators": generators,
		"structures": structures,
		"upgrades": {},
		"objective_multiplier_bonus": 0.0,
		"objectives_completed": {},
		"milestones_completed": {},
		"meta_unlocked": false,
		"campaign_complete": false,
		"run_time": 0.0,
		"time_since_last_improvement": 0.0,
		"last_save_time": Time.get_unix_time_from_system(),
		"log": [],
		"unlocks": {"main_tabs": {"production": true, "structures": false, "upgrades": true, "meta": false, "objectives": true, "statistics": true, "options": true, "help": true, "prestige": false, "echoes": false}},
		"automation": {"autobuyers": autobuyers, "auto_upgrades": false, "auto_recalibrate": {"enabled": false, "target": 5.0}},
		"stats": {"total_play_time": 0.0, "total_clicks": 0, "max_order_per_second": 0.0, "highest_order": 0.0, "total_generators_bought": 0, "total_recalibrations": 0, "total_cores_earned": 0.0, "total_echoes_earned": 0.0, "total_structures_earned": 0.0, "last_offline_seconds": 0.0, "campaign_complete": 0}
	}

func _merge_state(base: Dictionary, loaded: Dictionary) -> Dictionary:
	for key in loaded.keys():
		if typeof(base.get(key)) == TYPE_DICTIONARY and typeof(loaded[key]) == TYPE_DICTIONARY:
			base[key] = _merge_state(base[key], loaded[key])
		else:
			base[key] = loaded[key]
	base["stats"]["campaign_complete"] = 1 if base.get("campaign_complete", false) else int(base["stats"].get("campaign_complete", 0))
	return base

func _get_total_generators_bought() -> int:
	var total := 0
	for generator_id in state["generators"].keys():
		total += int(state["generators"][generator_id])
	return total
