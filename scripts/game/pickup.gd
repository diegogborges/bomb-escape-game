extends Area2D
class_name PowerupPickup

signal collected(powerup_type: int)

enum PowerupType {
	SLOW_MOTION,
	SHIELD,
	BIG_BOMB,
	SCREEN_CLEAR
}

@export var fall_speed := 160.0
@export var lifetime := 6.0

var pickup_type: PowerupType = PowerupType.SLOW_MOTION
var _play_bottom := 1400.0

@onready var sprite: Polygon2D = $Sprite
@onready var label: Label = $Label
@onready var life_timer: Timer = $LifeTimer

func _ready() -> void:
	add_to_group("pickups")
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(queue_free)
	life_timer.wait_time = lifetime
	life_timer.start()


func _process(delta: float) -> void:
	position.y += fall_speed * delta
	rotation += delta * 0.8
	if global_position.y > _play_bottom:
		queue_free()


func configure(type_index: int, play_bottom: float = 1400.0) -> void:
	pickup_type = type_index as PowerupType
	_play_bottom = play_bottom
	_apply_visual()


func _apply_visual() -> void:
	match pickup_type:
		PowerupType.SLOW_MOTION:
			sprite.color = Color(0.4, 0.92, 1.0)
			label.text = "S"
		PowerupType.SHIELD:
			sprite.color = Color(0.45, 1.0, 0.55)
			label.text = "E"
		PowerupType.BIG_BOMB:
			sprite.color = Color(1.0, 0.7, 0.35)
			label.text = "B"
		PowerupType.SCREEN_CLEAR:
			sprite.color = Color(1.0, 0.95, 0.5)
			label.text = "C"


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	emit_signal("collected", int(pickup_type))
	queue_free()
