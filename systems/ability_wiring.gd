## Connects abilities (volley/freeze), their bar, aim ring, effects, input and the boss horn/shake.
class_name AbilityWiring
extends Node


func setup(host: Node, abilities: Abilities, bar: AbilityBar, ring: AimRing, router: InputRouter, waves: WaveManager, shake: ScreenShake, sfx: Sfx) -> void:
	abilities.waves = waves
	shake.target = host
	bar.ability_pressed.connect(abilities.press)
	router.aim_tapped.connect(abilities.aim_tap)
	abilities.aim_changed.connect(func(k: String) -> void:
		router.aiming = k != ""
		bar.set_aiming(k)
		ring.show_for(k))
	abilities.cooldown.connect(bar.set_cooldown)
	abilities.cast.connect(func(k: String, pos: Vector2, r: float) -> void: AbilityFx.play(host, k, pos, r))
	waves.boss_spawned.connect(func() -> void:
		sfx.play_sfx("boss_horn", 0.0)
		shake.shake(Config.BOSS_SHAKE, 1.2))
