extends CharacterBody2D
class_name Player

signal died(cause: String)
signal hurt

@export var speed := 320.0
@export var bounds_padding := 20.0

@onready var body: Polygon2D = $Body
@onready var shield_visual: Polygon2D = $Shield
@onready var hit_timer: Timer = $HitTimer
@onready var shield_timer: Timer = $ShieldTimer

var _external_input := Vector2.ZERO
var _alive := true
var _shield_active := false
var _play_rect := Rect2(Vector2(40, 120), Vector2(640, 1040))


func _ready() -> void:
	add_to_group("player")
	shield_visual.visible = false
	hit_timer.timeout.connect(_on_hit_timer_timeout)
	shield_timer.timeout.connect(_on_shield_timeout)


func _physics_process(_delta: float) -> void:
	if not _alive:
		velocity = Vector2.ZERO
		return
	var keyboard := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	var dir := keyboard if keyboard.length() > 0.1 else _external_input
	velocity = dir.normalized() * speed
	move_and_slide()
	_clamp_inside_bounds()


func set_external_input(direction: Vector2) -> void:
	_external_input = direction.clamped(1.0)


func set_play_area(play_rect: Rect2) -> void:
	_play_rect = play_rect
	_clamp_inside_bounds()


func apply_hit(cause: String) -> void:
	if not _alive:
		return
	if _shield_active:
		_shield_active = false
		shield_visual.visible = false
		flash_damage()
		emit_signal("hurt")
		return
	_alive = false
	flash_damage()
	emit_signal("hurt")
	emit_signal("died", cause)


func flash_damage() -> void:
	modulate = Color(1.0, 0.45, 0.45, 1.0)
	hit_timer.start(0.12)


func grant_shield(seconds: float) -> void:
	if seconds <= 0.0:
		clear_shield()
		return
	_shield_active = true
	shield_visual.visible = true
	shield_timer.start(seconds)


func revive() -> void:
	_alive = true
	modulate = Color.WHITE


func is_alive() -> bool:
	return _alive


func _clamp_inside_bounds() -> void:
	var min_x := _play_rect.position.x + bounds_padding
	var max_x := _play_rect.end.x - bounds_padding
	var min_y := _play_rect.position.y + bounds_padding
	var max_y := _play_rect.end.y - bounds_padding
	global_position.x = clamp(global_position.x, min_x, max_x)
	global_position.y = clamp(global_position.y, min_y, max_y)


func _on_hit_timer_timeout() -> void:
	modulate = Color.WHITE


func _on_shield_timeout() -> void:
	clear_shield()


func clear_shield() -> void:
	_shield_active = false
	shield_visual.visible = false
	shield_timer.stop()
