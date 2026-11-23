class_name Projectile
extends Node2D

var target: Enemy
var damage := 10.0
var slow := 0.0
var splash := 0.0   # >0: also damages enemies within this radius of the target
var chain := 0      # >0: also hits this many other enemies near the target (piercing)
var speed := 500.0
var color := Color.WHITE
var texture: Texture2D
var sprite := Sprite2D.new()


func _ready() -> void:
	sprite.texture = texture
	add_child(sprite)


func _process(delta: float) -> void:
	if not is_instance_valid(target) or target.dead:
		queue_free()
		return
	var to := target.position - position
	var step := speed * delta
	if to.length() <= step + target.radius * 0.5:
		get_tree().call_group("sfx", "play_sfx", "hit", -9.0)
		if splash > 0.0:
			for e in get_tree().get_nodes_in_group("enemies"):
				var en := e as Enemy
				if en != target and not en.dead and en.position.distance_to(target.position) <= splash:
					en.take_damage(damage * 0.6, slow)
		if chain > 0:
			_pierce()
		target.take_damage(damage, slow)
		queue_free()
		return
	rotation = to.angle()
	position += to.normalized() * step


## Piercing shot: also hurts the `chain` nearest other enemies close to the target.
func _pierce() -> void:
	var near: Array = []
	for n in get_tree().get_nodes_in_group("enemies"):
		if n != target and not (n as Enemy).dead and n.position.distance_to(target.position) <= 90.0:
			near.append(n)
	near.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.position.distance_to(target.position) < b.position.distance_to(target.position))
	for n in near.slice(0, chain):
		(n as Enemy).take_damage(damage * 0.7, slow)
