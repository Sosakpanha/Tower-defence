# Usage: Godot --headless --path . --script tools/hero_test.gd
# Hero: buy, tap-to-move, auto-attack, XP/levels, evolve, death + dawn respawn, save/restore.
extends SceneTree

var m
var frame := 0
var fails := 0


func _initialize() -> void:
	SaveGame.clear()
	m = load("res://main.tscn").instantiate()
	root.add_child(m)


func ok(name: String, cond: bool) -> void:
	print(("PASS " if cond else "FAIL ") + name)
	if not cond:
		fails += 1


func _spawn_enemy(pos: Vector2) -> Enemy:
	var e := Enemy.new()
	e.setup(m.pathing, Vector2i(2, 2), "normal", 1)
	e.position = pos
	m.enemies_node.add_child(e)
	return e


func _process(_d: float) -> bool:
	frame += 1
	var h: HeroManager = m.hero_mgr if m else null
	match frame:
		2:
			m.gold = 100
			m.gold -= h.try_buy("knight", m.gold)
			ok("cannot afford hero", not h.alive() and m.gold == 100)
			m.gold = 1000
			m.gold -= h.try_buy("knight", m.gold)
			ok("hero bought for 200", h.alive() and m.gold == 800)
			ok("second hero refused", h.try_buy("archer", m.gold) == 0)
			var hp: Vector2 = h.hero.position
			ok("tap hero selects it", h.intercept(hp, MOUSE_BUTTON_LEFT) and h.hero.selected)
			var dest := hp + Vector2(120, 0)
			ok("tap map orders move", h.intercept(dest, MOUSE_BUTTON_LEFT) and h.hero.move_target == dest)
			ok("unselected tap falls through to building", not h.intercept(dest, MOUSE_BUTTON_LEFT))
		60, 61:
			pass
		90:
			ok("hero walked to target", h.hero.position.distance_to(h.hero.move_target if h.hero.move_target != Vector2.INF else h.hero.position) < 5.0 and h.hero.position.x > Config.cell_center(Config.HERO_SPAWN_CELL).x + 100)
			var e := _spawn_enemy(h.hero.position + Vector2(30, 0))
			e.speed = 0.0
			e.max_hp = 99999.0; e.hp = 99999.0
			ok("enemy spawned", is_instance_valid(e))
		150:
			var any_hurt := false
			for e: Enemy in m.enemies_node.get_children():
				any_hurt = any_hurt or e.hp < e.max_hp
			ok("hero auto-attacks enemy in range", any_hurt)
			for e in m.enemies_node.get_children():
				e.queue_free()
		152:
			for i in 16:   # 16 kills: level 3
				var e := _spawn_enemy(h.hero.position)
				m.waves.enemy_killed.emit(e)
				e.queue_free()
			ok("hero leveled to 3", h.level == 3 and h.hero.level == 3)
			ok("evolve available", h.can_evolve())
			m.gold = 100
			ok("evolve refused when poor", h.try_evolve("paladin", m.gold) == 0)
			m.gold = 500
			m.gold -= h.try_evolve("paladin", m.gold)
			ok("evolved to paladin for 250", h.evo == "paladin" and m.gold == 250 and h.hero.stats.heal > 0.0)
			ok("panel shows name", h.info().name == "Paladin")
			ok("evolve twice refused", not h.can_evolve())
		160:
			var e := _spawn_enemy(h.hero.position)   # melee enemy standing on the hero
			e.speed = 0.0
			h.hero.take_damage(99999.0)
			ok("hero died", not h.alive() and h.respawn_left > 0.0)
			ok("level kept after death", h.level == 3 and h.evo == "paladin")
			m.autosave()
			e.queue_free()
		165:
			h.dawn()
			ok("dawn respawns hero", h.alive() and h.hero.hp == h.hero.max_hp)
			h.hero.take_damage(99999.0)
			h.respawn_left = 0.05
		175:
			ok("timer respawns hero", h.alive())
			m.autosave()
			ok("save has hero", SaveGame.read().hero.kind == "knight" and SaveGame.read().hero.evo == "paladin")
			m.queue_free()
		178:
			SaveGame.pending = SaveGame.read()
			m = load("res://main.tscn").instantiate()
			root.add_child(m)
		182:
			var r: HeroManager = m.hero_mgr
			ok("hero restored", r.alive() and r.kind == "knight" and r.evo == "paladin" and r.level == 3 and r.kills == 16)
			SaveGame.clear()
			print("FAILS ", fails)
			quit()
	return false
