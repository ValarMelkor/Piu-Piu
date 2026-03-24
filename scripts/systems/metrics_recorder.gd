extends Node
class_name MetricsRecorder

signal metrics_updated

const MAX_LOGS: int = 12

var shots_fired: int = 0
var hits: int = 0
var misses: int = 0
var score: int = 0
var event_logs: Array[String] = []

func record_shot() -> void:
	shots_fired += 1
	emit_signal("metrics_updated")

func record_hit(target_name: String, distance_m: float) -> void:
	hits += 1
	score += 1
	_push_log("HIT %s @ %.1fm" % [target_name, distance_m])
	emit_signal("metrics_updated")

func record_miss(reason: String) -> void:
	misses += 1
	_push_log("MISS (%s)" % reason)
	emit_signal("metrics_updated")

func record_event(message: String) -> void:
	_push_log(message)
	emit_signal("metrics_updated")

func accuracy() -> float:
	if shots_fired <= 0:
		return 0.0
	return float(hits) / float(shots_fired)

func export_json(path: String) -> void:
	var payload := {
		"shots_fired": shots_fired,
		"hits": hits,
		"misses": misses,
		"accuracy": accuracy(),
		"score": score,
		"logs": event_logs,
		"time_unix": Time.get_unix_time_from_system()
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "\t"))

func export_csv(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line("shots,hits,misses,accuracy,score")
		file.store_line("%d,%d,%d,%.4f,%d" % [shots_fired, hits, misses, accuracy(), score])

func _push_log(message: String) -> void:
	var stamped := "[%s] %s" % [Time.get_datetime_string_from_system(false, true), message]
	event_logs.push_front(stamped)
	if event_logs.size() > MAX_LOGS:
		event_logs.resize(MAX_LOGS)
