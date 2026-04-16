extends Node2D
class_name MainGame

const SaveServiceScript = preload("res://scripts/services/save_service.gd")
const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const BOMB_SCENE := preload("res://scenes/Bomb.tscn")
const BLOCK_SCENE := preload("res://scenes/Block.tscn")
const PICKUP_SCENE := preload("res://scenes/Pickup.tscn")
const EXPLOSION_SCENE := preload("res://scenes/ExplosionEffect.tscn")

const BASE_BOMB_RADIUS := 74.0
const BASE_BOMB_CROSS_CELLS := 1

@onready var world: Node2D = $World
@onready var blocks_root: Node2D = $World/Blocks
@onready var bombs_root: Node2D = $World/Bombs
@onready var effects_root: Node2D = $World/Effects
@onready var pickups_root: Node2D = $World/Pickups
@onready var camera_shaker: CameraShaker = $World/Camera2D
@onready var spawner: BlockSpawner = $BlockSpawner
@onready var ui: GameUI = $UI
@onready var analytics_service: AnalyticsService = $Services/AnalyticsService
@onready var ads_service: AdsService = $Services/AdsService
@onready var audio_manager: AudioManager = $Services/AudioManager

var player: Player
var current_score := 0
var score_timer := 0.0
var run_start_msec := 0
var is_running := false
var can_revive := true
var debug_mode := false

var bomb_range_multiplier := 1.0
var bomb_cross_cells := BASE_BOMB_CROSS_CELLS
var big_bomb_timer := 0.0
var slow_motion_timer := 0.0
var shield_timer := 0.0
var near_miss_feedback_cooldown := 0.0

func _ready() -> void:
	randomize()
	SaveServiceScript.load_data()
	ui.set_best_score(SaveServiceScript.get_best_score())
	ui.bomb_pressed.connect(_on_bomb_pressed)
	ui.restart_requested.connect(_on_restart_requested)
	ui.revive_requested.connect(_on_revive_requested)
	ui.joystick_changed.connect(_on_joystick_changed)
	spawner.spawn_requested.connect(_on_spawn_requested)
	ads_service.rewarded_ad_completed.connect(_on_rewarded_ad_completed)
	ads_service.interstitial_requested.connect(_on_interstitial_requested)
	_start_new_run()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		_toggle_debug_mode()

	if Input.is_action_just_pressed("plant_bomb"):
		_on_bomb_pressed()
	if Input.is_action_just_pressed("restart_run") and not is_running:
		_start_new_run()

	if not is_running:
		if player:
			player.set_external_input(Vector2.ZERO)
		return

	score_timer += delta
	current_score = int(score_timer * 10.0)
	ui.set_score(current_score)
	_process_timed_effects(delta)
	_check_near_miss()


func _start_new_run() -> void:
	_clear_world_entities()
	score_timer = 0.0
	current_score = 0
	bomb_range_multiplier = 1.0
	bomb_cross_cells = BASE_BOMB_CROSS_CELLS
	big_bomb_timer = 0.0
	slow_motion_timer = 0.0
	shield_timer = 0.0
	near_miss_feedback_cooldown = 0.0
	Engine.time_scale = 1.0
	can_revive = ads_service.can_offer_revive()
	run_start_msec = Time.get_ticks_msec()
	_spawn_player()
	spawner.set_play_rect(_get_play_rect())
	spawner.start(true)
	ui.hide_game_over()
	ui.set_score(0)
	ui.set_best_score(SaveServiceScript.get_best_score())
	ui.set_revive_enabled(can_revive)
	ui.show_status("Sobreviva e plante bombas!")
	is_running = true


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate() as Player
	world.add_child(player)
	player.global_position = _get_play_rect().get_center()
	player.set_play_area(_get_play_rect())
	player.died.connect(_on_player_died)
	player.hurt.connect(_on_player_hurt)


func _clear_world_entities() -> void:
	for root in [blocks_root, bombs_root, effects_root, pickups_root]:
		for child in root.get_children():
			child.queue_free()
	if player and is_instance_valid(player):
		player.queue_free()


func _process_timed_effects(delta: float) -> void:
	if near_miss_feedback_cooldown > 0.0:
		near_miss_feedback_cooldown = max(near_miss_feedback_cooldown - delta, 0.0)

	if big_bomb_timer > 0.0:
		big_bomb_timer -= delta
		if big_bomb_timer <= 0.0:
			bomb_range_multiplier = 1.0
			bomb_cross_cells = BASE_BOMB_CROSS_CELLS
			ui.show_status("Bomba padrão restaurada")

	if slow_motion_timer > 0.0:
		slow_motion_timer -= delta
		if slow_motion_timer <= 0.0:
			Engine.time_scale = 1.0

	if shield_timer > 0.0:
		shield_timer -= delta
		if shield_timer <= 0.0 and player:
			player.grant_shield(0.0)


func _check_near_miss() -> void:
	if not player or not player.is_alive() or near_miss_feedback_cooldown > 0.0:
		return
	for block_node in blocks_root.get_children():
		var block := block_node as FallingBlock
		if block == null or block.has_registered_near_miss:
			continue
		var dy := block.global_position.y - player.global_position.y
		var dx := absf(block.global_position.x - player.global_position.x)
		if dy > 12.0 and dy < 120.0 and dx < block.get_hit_radius() + 12.0:
			block.mark_near_miss()
			near_miss_feedback_cooldown = 0.4
			current_score += 3
			ui.flash_near_miss()
			camera_shaker.add_trauma(0.1)
			_apply_micro_slow_motion(0.92, 0.05)
			break


func _on_spawn_requested(block_type: int, spawn_position: Vector2, fall_speed: float) -> void:
	if not is_running:
		return
	var block := BLOCK_SCENE.instantiate() as FallingBlock
	blocks_root.add_child(block)
	block.global_position = spawn_position
	block.configure(block_type, fall_speed, _get_play_rect().end.y + 80.0)
	block.hit_player.connect(_on_block_hit_player)
	block.reached_bottom.connect(_on_block_reached_bottom)
	block.destroyed.connect(_on_block_destroyed)


func _on_block_hit_player(_block: FallingBlock) -> void:
	if player:
		player.apply_hit("block")


func _on_block_reached_bottom(block: FallingBlock) -> void:
	if is_instance_valid(block):
		block.queue_free()


func _on_block_destroyed(block: FallingBlock, reason: String) -> void:
	if not is_instance_valid(block):
		return
	var block_position := block.global_position
	var block_type := block.block_type
	block.queue_free()

	if reason == "explosion":
		current_score += 6

	if block_type == FallingBlock.BlockType.EXPLOSIVE and reason == "explosion":
		_spawn_explosion_effect(PackedVector2Array([block_position]), BASE_BOMB_RADIUS * 0.75)
		_trigger_explosion(PackedVector2Array([block_position]), BASE_BOMB_RADIUS * 0.8, false)

	if block_type == FallingBlock.BlockType.RARE and reason == "explosion" and randf() < 0.85:
		_spawn_pickup(block_position)


func _spawn_pickup(position: Vector2) -> void:
	var pickup := PICKUP_SCENE.instantiate() as PowerupPickup
	pickups_root.add_child(pickup)
	pickup.global_position = position
	pickup.configure(randi() % PowerupPickup.PowerupType.size(), _get_play_rect().end.y + 80.0)
	pickup.collected.connect(_on_powerup_collected)


func _on_powerup_collected(powerup_type: int) -> void:
	audio_manager.play_sfx("pickup", 1.05)
	match powerup_type:
		PowerupPickup.PowerupType.SLOW_MOTION:
			Engine.time_scale = 0.55
			slow_motion_timer = max(slow_motion_timer, 2.0)
			ui.show_status("Power-up: Slow Motion!")
		PowerupPickup.PowerupType.SHIELD:
			if player:
				player.grant_shield(6.0)
			shield_timer = 6.0
			ui.show_status("Power-up: Escudo!")
		PowerupPickup.PowerupType.BIG_BOMB:
			bomb_range_multiplier = 1.8
			bomb_cross_cells = 2
			big_bomb_timer = 12.0
			ui.show_status("Power-up: Bomba Maior!")
		PowerupPickup.PowerupType.SCREEN_CLEAR:
			ui.show_status("Power-up: Limpeza total!")
			_clear_all_blocks()


func _clear_all_blocks() -> void:
	for block_node in blocks_root.get_children():
		var block := block_node as FallingBlock
		if block:
			block.destroy_from_clear()
	camera_shaker.add_trauma(0.28)
	audio_manager.play_sfx("explosion", 0.9, -4.0)


func _on_bomb_pressed() -> void:
	if not is_running or not player or not player.is_alive():
		return
	var bomb := BOMB_SCENE.instantiate() as Bomb
	bombs_root.add_child(bomb)
	bomb.global_position = player.global_position
	bomb.configure(1.15, BASE_BOMB_RADIUS * bomb_range_multiplier, bomb_cross_cells)
	bomb.exploded.connect(_on_bomb_exploded)


func _on_bomb_exploded(points: PackedVector2Array, radius: float) -> void:
	_trigger_explosion(points, radius, true)


func _trigger_explosion(points: PackedVector2Array, radius: float, from_player_bomb: bool) -> void:
	_spawn_explosion_effect(points, radius)
	audio_manager.play_sfx("explosion", randf_range(0.94, 1.08))
	camera_shaker.add_trauma(0.34 if from_player_bomb else 0.2)
	_apply_micro_slow_motion(0.72, 0.06)

	if player and player.is_alive() and _point_hits_target(points, radius, player.global_position, 15.0):
		player.apply_hit("explosion")

	for block_node in blocks_root.get_children():
		var block := block_node as FallingBlock
		if block and _point_hits_target(points, radius, block.global_position, block.get_hit_radius()):
			block.destroy_from_explosion()

	if debug_mode:
		ui.set_debug_label("DEBUG: explosao raio=%.1f pontos=%d" % [radius, points.size()])


func _point_hits_target(points: PackedVector2Array, radius: float, target: Vector2, target_padding: float) -> bool:
	for point in points:
		if point.distance_to(target) <= radius + target_padding:
			return true
	return false


func _spawn_explosion_effect(points: PackedVector2Array, radius: float) -> void:
	var effect := EXPLOSION_SCENE.instantiate() as ExplosionEffect
	effects_root.add_child(effect)
	effect.configure(points, radius)


func _on_player_hurt() -> void:
	audio_manager.play_sfx("hit", 1.0)
	camera_shaker.add_trauma(0.18)


func _on_player_died(_reason: String) -> void:
	if not is_running:
		return
	is_running = false
	spawner.stop()
	Engine.time_scale = 1.0
	audio_manager.play_sfx("game_over", 1.0, -1.0)
	camera_shaker.add_trauma(0.4)

	var playtime_sec := float(Time.get_ticks_msec() - run_start_msec) / 1000.0
	analytics_service.track_run_finished(current_score, playtime_sec)
	var best_score: int = SaveServiceScript.register_score(current_score)
	ads_service.on_match_finished()
	ui.show_game_over(current_score, best_score, can_revive and ads_service.can_offer_revive())


func _on_revive_requested() -> void:
	if is_running:
		return
	if not can_revive or not ads_service.can_offer_revive():
		return
	ads_service.show_rewarded_for_revive()


func _on_rewarded_ad_completed() -> void:
	if is_running:
		return
	can_revive = false
	if player:
		player.revive()
		player.grant_shield(2.0)
		shield_timer = 2.0
	spawner.start(false)
	ui.hide_game_over()
	ui.show_status("Revive ativado!")
	_apply_micro_slow_motion(0.8, 0.1)
	is_running = true


func _on_restart_requested() -> void:
	_start_new_run()


func _on_joystick_changed(direction: Vector2) -> void:
	if player:
		player.set_external_input(direction)


func _on_interstitial_requested() -> void:
	print("[ADS] Placeholder interstitial exibido ao fim da partida.")


func _apply_micro_slow_motion(scale: float, duration: float) -> void:
	Engine.time_scale = scale
	slow_motion_timer = max(slow_motion_timer, duration)


func _toggle_debug_mode() -> void:
	debug_mode = not debug_mode
	get_tree().debug_collisions_hint = debug_mode
	ui.set_debug_label_visible(debug_mode)
	ui.set_debug_label("DEBUG: %s" % ("ON" if debug_mode else "OFF"))
	print("[DEBUG] debug_mode=%s" % debug_mode)


func _get_play_rect() -> Rect2:
	var viewport_size := get_viewport_rect().size
	return Rect2(Vector2(40.0, 140.0), Vector2(viewport_size.x - 80.0, viewport_size.y - 250.0))
