extends Node
class_name AudioManager

const BUS_MASTER := "Master"

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	_register_streams()

func _register_streams() -> void:
	_streams = {
		"explosion": _create_beep_stream(330.0, 0.20),
		"hit": _create_beep_stream(180.0, 0.14),
		"game_over": _create_beep_stream(120.0, 0.42),
		"pickup": _create_beep_stream(520.0, 0.12)
	}

func play_sfx(name: String, pitch_scale: float = 1.0, volume_db: float = -2.0) -> void:
	if not _streams.has(name):
		push_warning("AudioManager: efeito desconhecido -> %s" % name)
		return
	var player := AudioStreamPlayer.new()
	player.bus = BUS_MASTER
	player.stream = _streams[name]
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.finished.connect(_on_player_finished.bind(player))
	add_child(player)
	_players.append(player)
	player.play()

func _on_player_finished(player: AudioStreamPlayer) -> void:
	if _players.has(player):
		_players.erase(player)
	player.queue_free()

func _create_beep_stream(base_frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var frame_count := int(sample_rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	for i in range(frame_count):
		var progress := float(i) / float(max(frame_count - 1, 1))
		var envelope := (1.0 - progress) * 0.8
		var sine := sin(TAU * base_frequency * (float(i) / float(sample_rate)))
		var sample_value := int(clamp(sine * envelope, -1.0, 1.0) * 32767.0)
		var byte_index := i * 2
		bytes[byte_index] = sample_value & 0xFF
		bytes[byte_index + 1] = (sample_value >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.mix_rate = sample_rate
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.stereo = false
	wav.loop_mode = AudioStreamWAV.LOOP_DISABLED
	wav.data = bytes
	return wav
