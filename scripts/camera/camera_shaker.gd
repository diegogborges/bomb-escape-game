extends Camera2D
class_name CameraShaker

@export var decay := 14.0
@export var max_offset := Vector2(18, 18)
@export var max_roll := 0.07

var trauma := 0.0
var noise := FastNoiseLite.new()
var noise_y := 0.0

func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 28.0
	noise.fractal_octaves = 2


func _process(delta: float) -> void:
	if trauma <= 0.0:
		offset = offset.lerp(Vector2.ZERO, delta * 18.0)
		rotation = lerpf(rotation, 0.0, delta * 18.0)
		return

	trauma = max(trauma - decay * delta, 0.0)
	var amount := trauma * trauma
	noise_y += delta * 35.0
	rotation = max_roll * amount * noise.get_noise_2d(0.0, noise_y)
	offset = Vector2(
		max_offset.x * amount * noise.get_noise_2d(1.0, noise_y),
		max_offset.y * amount * noise.get_noise_2d(2.0, noise_y)
	)

func add_trauma(amount: float) -> void:
	trauma = clamp(trauma + amount, 0.0, 1.0)
