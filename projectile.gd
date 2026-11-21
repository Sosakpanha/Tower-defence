class_name Projectile
extends Node2D

var target: Enemy
var damage := 10.0
var slow := 0.0
var splash := 0.0   # >0: also damages enemies within this radius of the target
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
		target.take_damage(damage, slow)
		queue_free()
		return
	rotation = to.angle()
	position += to.normalized() * step
