extends CanvasLayer
class_name DebugOverlay

@onready var debug_label: Label = $MarginContainer/DebugLabel

func set_visible_debug(is_visible: bool) -> void:
	visible = is_visible

func update_debug(data: Dictionary) -> void:
	var logs: Array[String] = data.get("logs", [])
	debug_label.text = "\n".join([
		"=== DEBUG ===",
		"FOV: %.1f" % data.get("fov", 0.0),
		"Sensor range futuro: %.1f m" % data.get("sensor_range", 0.0),
		"Proyectiles activos: %d" % data.get("projectiles", 0),
		"Velocidad media blancos: %.1f m/s" % data.get("avg_target_speed", 0.0),
		"Límites torreta: %s" % data.get("turret_limits", "-"),
		"Draw debug: %s" % ("ON" if data.get("draw_debug", false) else "OFF"),
		"Eventos recientes:",
		"- %s" % "\n- ".join(logs)
	])
