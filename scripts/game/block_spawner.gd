extends Node
class_name BlockSpawner

signal spawn_requested(block_type: int, spawn_position: Vector2, fall_speed: float)

const BLOCK_TYPE_NORMAL := 0
const BLOCK_TYPE_HEAVY := 1
const BLOCK_TYPE_EXPLOSIVE := 2
const BLOCK_TYPE_RARE := 3

@export var spawn_width := 680.0
@export var spawn_offset_x := 20.0
@export var spawn_y := -48.0
@export var base_spawn_interval := 0.95
@export var min_spawn_interval := 0.20
@export var base_fall_speed := 180.0
@export var max_fall_speed := 580.0
@export var heavy_extra_speed := 170.0

var _difficulty_time := 0.0
var _spawn_cooldown := 0.0
var _running := false
var _play_rect := Rect2(Vector2(40, 140), Vector2(640, 960))

func set_play_rect(rect: Rect2) -> void:
	_play_rect = rect
	spawn_width = rect.size.x
	spawn_offset_x = rect.position.x


func start(reset_difficulty: bool) -> void:
	_running = true
	_spawn_cooldown = 0.0
	if reset_difficulty:
		_difficulty_time = 0.0


func stop() -> void:
	_running = false


func _process(delta: float) -> void:
	if not _running:
		return
	_difficulty_time += delta
	_spawn_cooldown -= delta
	if _spawn_cooldown <= 0.0:
		_spawn_block()
		_spawn_cooldown = _get_spawn_interval()


func _get_spawn_interval() -> float:
	var t: float = clampf(_difficulty_time / 70.0, 0.0, 1.0)
	return lerpf(base_spawn_interval, min_spawn_interval, t)


func _get_fall_speed(block_type: int) -> float:
	var t: float = clampf(_difficulty_time / 90.0, 0.0, 1.0)
	var speed: float = lerpf(base_fall_speed, max_fall_speed, t)
	if block_type == BLOCK_TYPE_HEAVY:
		speed += heavy_extra_speed
	return speed


func _roll_block_type() -> int:
	var t: float = clampf(_difficulty_time / 110.0, 0.0, 1.0)
	var rare_chance: float = lerpf(0.05, 0.12, t)
	var explosive_chance: float = lerpf(0.10, 0.22, t)
	var heavy_chance: float = lerpf(0.18, 0.35, t)
	var roll: float = randf()
	if roll < rare_chance:
		return BLOCK_TYPE_RARE
	if roll < rare_chance + explosive_chance:
		return BLOCK_TYPE_EXPLOSIVE
	if roll < rare_chance + explosive_chance + heavy_chance:
		return BLOCK_TYPE_HEAVY
	return BLOCK_TYPE_NORMAL


func _spawn_block() -> void:
	var block_type: int = _roll_block_type()
	var x: float = randf_range(spawn_offset_x, spawn_offset_x + spawn_width)
	var y: float = maxf(spawn_y, _play_rect.position.y - 80.0)
	emit_signal("spawn_requested", block_type, Vector2(x, y), _get_fall_speed(block_type))
