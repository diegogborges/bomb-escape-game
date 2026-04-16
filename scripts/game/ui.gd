extends CanvasLayer
class_name GameUI

signal bomb_pressed
signal restart_requested
signal revive_requested
signal joystick_changed(direction: Vector2)

const JOYSTICK_RADIUS := 72.0

@onready var score_label: Label = $TopBar/TopInfo/ScoreLabel
@onready var best_label: Label = $TopBar/TopInfo/BestLabel
@onready var bomb_button: Button = $BottomControls/BombButton
@onready var restart_button: Button = $CenterPanel/OverlayVBox/RestartButton
@onready var revive_button: Button = $CenterPanel/OverlayVBox/ReviveButton
@onready var status_label: Label = $CenterPanel/OverlayVBox/StatusLabel
@onready var sub_status_label: Label = $CenterPanel/OverlayVBox/SubStatusLabel
@onready var near_miss_label: Label = $NearMissLabel
@onready var debug_label: Label = $DebugLabel
@onready var movement_pad: TouchScreenButton = $BottomControls/MovementPad

var _near_miss_tween: Tween
var _status_tween: Tween

func _ready() -> void:
	bomb_button.pressed.connect(func() -> void: emit_signal("bomb_pressed"))
	restart_button.pressed.connect(func() -> void: emit_signal("restart_requested"))
	revive_button.pressed.connect(func() -> void: emit_signal("revive_requested"))
	hide_game_over()
	near_miss_label.modulate.a = 0.0
	debug_label.visible = false


func _process(_delta: float) -> void:
	var direction := Vector2.ZERO
	if movement_pad.is_pressed():
		var center := movement_pad.global_position + Vector2(95.0, 95.0)
		var drag := get_viewport().get_mouse_position() - center
		if drag.length() > JOYSTICK_RADIUS:
			drag = drag.normalized() * JOYSTICK_RADIUS
		direction = drag / JOYSTICK_RADIUS
	emit_signal("joystick_changed", direction)


func set_score(score: int) -> void:
	score_label.text = "Score: %d" % score


func set_best_score(score: int) -> void:
	best_label.text = "Best: %d" % score


func show_game_over(score: int, best_score: int, can_revive: bool) -> void:
	$CenterPanel.visible = true
	status_label.text = "Game Over"
	sub_status_label.text = "Score: %d | Best: %d" % [score, best_score]
	restart_button.visible = true
	revive_button.visible = can_revive


func hide_game_over() -> void:
	$CenterPanel.visible = false


func set_revive_enabled(enabled: bool) -> void:
	revive_button.disabled = not enabled


func show_status(text: String) -> void:
	$CenterPanel.visible = true
	status_label.text = text
	sub_status_label.text = ""
	restart_button.visible = false
	revive_button.visible = false
	if is_instance_valid(_status_tween):
		_status_tween.kill()
	status_label.modulate.a = 1.0
	_status_tween = create_tween()
	_status_tween.tween_property(status_label, "modulate:a", 0.0, 1.2).from(1.0)
	await _status_tween.finished
	if not restart_button.visible:
		$CenterPanel.visible = false


func flash_near_miss() -> void:
	near_miss_label.text = "Quase!"
	near_miss_label.modulate = Color(1.0, 0.95, 0.25, 1.0)
	if is_instance_valid(_near_miss_tween):
		_near_miss_tween.kill()
	_near_miss_tween = create_tween()
	_near_miss_tween.tween_property(near_miss_label, "modulate:a", 0.0, 0.55).from(1.0)


func set_debug_label_visible(visible: bool) -> void:
	debug_label.visible = visible
	debug_label.text = "DEBUG ON"


func set_debug_label(text: String) -> void:
	debug_label.text = text
