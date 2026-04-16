extends Area2D
class_name Bomb

signal exploded(points: PackedVector2Array, radius: float)

@export var fuse_time := 1.1
@export var explosion_radius := 72.0
@export var cross_cells := 1
@export var cell_size := 64.0

@onready var visual: Polygon2D = $Visual
@onready var fuse: Polygon2D = $Fuse
@onready var timer: Timer = $FuseTimer

func _ready() -> void:
	add_to_group("bombs")
	timer.wait_time = fuse_time
	timer.timeout.connect(_explode)
	timer.start()


func configure(new_fuse_time: float, radius: float, new_cross_cells: int) -> void:
	fuse_time = new_fuse_time
	explosion_radius = radius
	cross_cells = max(1, new_cross_cells)


func _process(_delta: float) -> void:
	var ratio := timer.time_left / max(timer.wait_time, 0.001)
	var pulse := 0.86 + 0.24 * sin(Time.get_ticks_msec() * 0.02)
	visual.scale = Vector2.ONE * pulse
	fuse.modulate = Color(1.0, 0.4 + ratio * 0.5, 0.1 + ratio * 0.5, 1.0)


func _explode() -> void:
	emit_signal("exploded", _build_explosion_points(), explosion_radius)
	queue_free()


func _build_explosion_points() -> PackedVector2Array:
	# Arquitetura pronta para estilo Bomberman em cruz.
	var points := PackedVector2Array()
	points.append(global_position)
	for i in range(1, cross_cells + 1):
		var dist := cell_size * i
		points.append(global_position + Vector2.RIGHT * dist)
		points.append(global_position + Vector2.LEFT * dist)
		points.append(global_position + Vector2.UP * dist)
		points.append(global_position + Vector2.DOWN * dist)
	return points
