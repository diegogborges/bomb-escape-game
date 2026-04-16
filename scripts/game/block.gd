extends Area2D
class_name FallingBlock

signal hit_player(block: FallingBlock)
signal reached_bottom(block: FallingBlock)
signal destroyed(block: FallingBlock, reason: String)

enum BlockType {
	NORMAL,
	HEAVY,
	EXPLOSIVE,
	RARE
}

@export var block_type: BlockType = BlockType.NORMAL

@onready var body: Polygon2D = $Body
@onready var hit_shape: CollisionShape2D = $CollisionShape2D

var speed := 320.0
var bottom_limit := 1400.0
var hit_radius := 24.0
var has_registered_near_miss := false

func _ready() -> void:
	add_to_group("blocks")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	global_position.y += speed * delta
	if global_position.y > bottom_limit:
		emit_signal("reached_bottom", self)


func configure(type_value: int, fall_speed: float, target_bottom_limit: float) -> void:
	block_type = type_value
	speed = fall_speed
	bottom_limit = target_bottom_limit
	_apply_visual_by_type()


func _apply_visual_by_type() -> void:
	var size := 46.0
	match block_type:
		BlockType.NORMAL:
			size = 44.0
			body.color = Color(0.56, 0.60, 0.68)
		BlockType.HEAVY:
			size = 54.0
			body.color = Color(0.95, 0.43, 0.20)
			speed *= 1.2
		BlockType.EXPLOSIVE:
			size = 48.0
			body.color = Color(0.93, 0.18, 0.21)
		BlockType.RARE:
			size = 40.0
			body.color = Color(0.29, 0.95, 0.72)

	hit_radius = size * 0.5
	body.polygon = PackedVector2Array([
		Vector2(-hit_radius, -hit_radius),
		Vector2(hit_radius, -hit_radius),
		Vector2(hit_radius, hit_radius),
		Vector2(-hit_radius, hit_radius)
	])
	var shape := RectangleShape2D.new()
	shape.size = Vector2(size, size)
	hit_shape.shape = shape


func mark_near_miss() -> void:
	has_registered_near_miss = true


func get_hit_radius() -> float:
	return hit_radius


func destroy_from_explosion() -> void:
	emit_signal("destroyed", self, "explosion")


func destroy_from_clear() -> void:
	emit_signal("destroyed", self, "clear")


func _on_body_entered(body_node: Node) -> void:
	if body_node.is_in_group("player"):
		emit_signal("hit_player", self)
