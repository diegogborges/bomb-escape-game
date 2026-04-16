extends Node
class_name AnalyticsService

var total_runs: int = 0
var total_score: int = 0
var total_playtime_sec: float = 0.0
var total_deaths: int = 0

func track_run_finished(score: int, playtime_sec: float) -> void:
	total_runs += 1
	total_score += score
	total_playtime_sec += playtime_sec
	total_deaths += 1

	var average_score: float = float(total_score) / float(maxi(1, total_runs))
	var average_play_time: float = total_playtime_sec / float(maxi(total_runs, 1))
	print("[Analytics] run_finished score=%d playtime=%.2f avg_score=%.2f deaths=%d" %
		[score, playtime_sec, average_score, total_deaths])
	print("[Analytics] session_stats runs=%d avg_playtime=%.2f total_playtime=%.2f" %
		[total_runs, average_play_time, total_playtime_sec])

