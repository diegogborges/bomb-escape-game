extends Node
class_name AdsService

signal rewarded_ad_started
signal rewarded_ad_completed
signal interstitial_requested

@export var ads_removed := false
@export var interstitial_every_n_runs := 3

var _run_counter := 0

func on_match_finished() -> void:
	_run_counter += 1
	if ads_removed:
		return
	if _run_counter % max(1, interstitial_every_n_runs) == 0:
		request_interstitial()

func request_interstitial() -> void:
	# Placeholder para futura integração com SDK real (AdMob/AppLovin/etc).
	emit_signal("interstitial_requested")
	print("[ADS] Interstitial requested.")

func can_offer_revive() -> bool:
	return not ads_removed

func show_rewarded_for_revive() -> void:
	# Simulação instantânea. Substituir por callback assíncrono do SDK.
	emit_signal("rewarded_ad_started")
	print("[ADS] Rewarded started.")
	emit_signal("rewarded_ad_completed")
	print("[ADS] Rewarded completed.")
