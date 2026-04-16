extends RefCounted
class_name SaveService

const SAVE_PATH := "user://save_data.json"

static var _data := {
	"best_score": 0,
	"runs": 0,
	"total_score": 0
}

static func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed := JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		for key in _data.keys():
			if parsed.has(key):
				_data[key] = parsed[key]


static func save_data() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_data))


static func get_best_score() -> int:
	return int(_data.get("best_score", 0))


static func register_score(score: int) -> int:
	_data["runs"] = int(_data.get("runs", 0)) + 1
	_data["total_score"] = int(_data.get("total_score", 0)) + score
	_data["best_score"] = maxi(score, get_best_score())
	save_data()
	return get_best_score()


static func get_average_score() -> float:
	var runs := maxi(int(_data.get("runs", 0)), 1)
	return float(_data.get("total_score", 0)) / float(runs)
