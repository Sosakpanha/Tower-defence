## Shows the plan for the coming night: wave preview strip, portal markers, boss warning.
## Listens to DayCycle; the plan itself comes from WavePlan.
class_name NightPlanner
extends Node

var preview := WavePreview.new()
var warning := BossWarning.new()
var markers := PortalMarkers.new()


## `map_parent` gets the world-space markers; the UI layers are added to this node.
func setup(day: DayCycle, map_parent: Node) -> void:
	add_child(preview)
	add_child(warning)
	map_parent.add_child(markers)
	day.phase_changed.connect(_on_phase)


func _on_phase(is_night: bool, number: int) -> void:
	markers.set_cells(WavePlan.portals(number))   # stays on while the night's enemies come out
	if is_night:
		preview.hide_plan()
		warning.set_active(false)
		return
	preview.show_plan(number, WavePlan.counts(number), WavePlan.portal_names(number), WavePlan.is_boss(number))
	warning.set_active(WavePlan.is_boss(number))
