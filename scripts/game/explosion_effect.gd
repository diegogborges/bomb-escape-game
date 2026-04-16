extends Node2D
class_name ExplosionEffect

@export var lifetime := 0.32

@onready var p1: GPUParticles2D = $ParticlesA
@onready var p2: GPUParticles2D = $ParticlesB
@onready var flash: ColorRect = $Flash

var _timer := 0.0

func _ready() -> void:
	p1.emitting = true
	p2.emitting = true
	flash.modulate.a = 0.7

func configure(points: PackedVector2Array, radius: float) -> void:
	if points.is_empty():
		return
	global_position = points[0]
	if points.size() > 1:
		# Efeito simplificado para explosao em cruz futura: sobe particulas.
		p2.global_position = points[1]
	var scale_factor := clamp(radius / 74.0, 0.65, 2.2)
	scale = Vector2.ONE * scale_factor

func _process(delta: float) -> void:
	_timer += delta
	var t := clamp(_timer / lifetime, 0.0, 1.0)
	flash.modulate.a = 1.0 - t
	if _timer >= lifetime:
		queue_free()
