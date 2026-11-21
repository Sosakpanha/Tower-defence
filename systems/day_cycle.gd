## Day (build phase, countdown) then night (the wave attacks). Day N leads into wave N.
## Emits signals only: Main starts the wave on `night_requested`; the banner listens to the rest.
class_name DayCycle
extends Node

signal phase_changed(is_night: bool, number: int)
signal countdown(seconds_left: int)   # whole seconds left in the day
signal night_requested                 # the day timer ran out

var is_night := false
var time_left := Config.FIRST_DAY_SECONDS
var enabled := true
var _last_sec := -1


func setup(waves: WaveManager) -> void:
	waves.wave_started.connect(func(w: int) -> void: _set_phase(true, w))
	waves.wave_cleared.connect(func(w: int) -> void:
		time_left = Config.DAY_SECONDS
		enabled = w < Config.MAX_WAVE
		if w < Config.MAX_WAVE:
			_set_phase(false, w + 1))
	phase_changed.emit(false, 1)


## Back to a build phase after loading a save: `cleared` waves are done.
func resume(cleared: int) -> void:
	is_night = false
	time_left = Config.FIRST_DAY_SECONDS if cleared == 0 else Config.DAY_SECONDS
	enabled = true
	_set_phase(false, cleared + 1)


func _set_phase(night: bool, number: int) -> void:
	is_night = night
	_last_sec = -1
	phase_changed.emit(night, number)


func _process(delta: float) -> void:
	if is_night or not enabled:
		return
	time_left -= delta
	var sec := ceili(maxf(time_left, 0.0))
	if sec != _last_sec:
		_last_sec = sec
		countdown.emit(sec)
	if time_left <= 0.0:
		enabled = false  # re-armed when the wave is cleared
		night_requested.emit()

