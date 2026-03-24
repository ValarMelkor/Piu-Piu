extends Resource
class_name TurretConfig

@export_range(160.0, 180.0, 1.0) var yaw_total_deg: float = 180.0
@export var pitch_min_deg: float = 0.0
@export var pitch_max_deg: float = 85.0
@export var yaw_speed_deg_per_sec: float = 70.0
@export var pitch_speed_deg_per_sec: float = 55.0
@export var mouse_sensitivity_deg: float = 0.12
@export var use_smoothing: bool = true
@export var smoothing_speed: float = 10.0
@export var fire_interval_sec: float = 0.12
