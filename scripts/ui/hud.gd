extends CanvasLayer
class_name HUD

@onready var stats_label: Label = $MarginContainer/StatsLabel

func update_hud(data: Dictionary) -> void:
	stats_label.text = "\n".join([
		"Blancos activos: %d" % data.get("targets", 0),
		"Impactos: %d" % data.get("hits", 0),
		"Fallos: %d" % data.get("misses", 0),
		"Precisión: %.1f%%" % (data.get("accuracy", 0.0) * 100.0),
		"Blanco más cercano: %s" % _distance_text(data.get("closest_target", -1.0)),
		"FPS: %d" % data.get("fps", 0),
		"Cámara: %s" % data.get("camera", "-"),
		"Yaw: %.1f°" % data.get("yaw", 0.0),
		"Pitch: %.1f°" % data.get("pitch", 0.0)
	])

func _distance_text(value: float) -> String:
	if value < 0.0:
		return "N/A"
	return "%.1f m" % value
