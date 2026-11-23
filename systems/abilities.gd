## Player-triggered abilities with cooldowns. Add one = one entry in TYPES (+ a branch in _apply).
## Targeted abilities are armed first (`press`), then fired by the next map tap (`aim_tap`).
## Signals only: the bar shows cooldowns, the router sends the map tap, FX listens to `cast`.
class_name Abilities
extends Node

signal cast(kind: String, pos: Vector2, radius: float)
signal cooldown(kind: String, fraction: float, seconds_left: float)  # fraction 1 = just used, 0 = ready
signal aim_changed(kind: String)                                       # "" = not aiming

const TYPES := {
	"volley": {"name": "Arrow Volley", "cooldown": 20.0, "radius": 160.0, "damage": 100.0, "targeted": true},
	"freeze": {"name": "Freeze", "cooldown": 35.0, "slow": 6.0, "targeted": false},
}

var cd := {}        # kind -> seconds left
var aiming := ""
var waves: WaveManager


func _ready() -> void:
	for k in TYPES:
		cd[k] = 0.0


func _process(delta: float) -> void:
	for k in TYPES:
		if cd[k] > 0.0:
			cd[k] = maxf(0.0, cd[k] - delta)
			cooldown.emit(k, cd[k] / TYPES[k].cooldown, cd[k])


func is_ready(kind: String) -> bool:
	return cd[kind] <= 0.0


## The ability button was pressed (or its hotkey).
func press(kind: String) -> void:
	if not is_ready(kind):
		return
	if not TYPES[kind].targeted:
		cast_at(kind, Vector2.ZERO)
	else:
		_set_aim("" if aiming == kind else kind)


func cancel_aim() -> void:
	_set_aim("")


## Map tapped while aiming; `pos` is in map/world coordinates.
func aim_tap(pos: Vector2) -> void:
	if aiming != "" and cast_at(aiming, pos):
		_set_aim("")


## Fire now. Refused (false) on cooldown or when no enemy is on the map to waste it on.
func cast_at(kind: String, pos: Vector2) -> bool:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if not is_ready(kind) or enemies.is_empty():
		return false
	var radius := _apply(kind, pos, enemies)
	cd[kind] = TYPES[kind].cooldown
	cooldown.emit(kind, 1.0, cd[kind])
	cast.emit(kind, pos, radius)
	get_tree().call_group("sfx", "play_sfx", "ability_" + kind, -2.0)
	return true


func _apply(kind: String, pos: Vector2, enemies: Array) -> float:
	var st: Dictionary = TYPES[kind]
	var w := maxi(1, waves.wave if waves else 1)
	match kind:
		"volley":
			var dmg: float = st.damage * (1.0 + w * Config.ENEMY_HP_LIN + w * w * Config.ENEMY_HP_QUAD)  # keeps pace with enemy HP
			for e: Enemy in enemies:
				if e.position.distance_to(pos) <= st.radius + e.radius:
					e.take_damage(dmg)
			return st.radius
		"freeze":
			for e: Enemy in enemies:
				e.take_damage(0.0, st.slow)  # the enemy's own slow timer halves its speed
	return 0.0


func _set_aim(kind: String) -> void:
	if kind != aiming:
		aiming = kind
		aim_changed.emit(kind)
