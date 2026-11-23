## Sound effects. Anyone can play one with:
##   get_tree().call_group("sfx", "play_sfx", "place", -4.0)
class_name Sfx
extends Node

const NAMES := ["shoot_gunner", "shoot_sniper", "shoot_frost", "hit", "enemy_die",
	"place", "sell", "leak", "wave_start", "win", "lose",
	"ability_volley", "ability_freeze", "boss_horn"]
const POOL_SIZE := 16

var streams := {}
var players: Array[AudioStreamPlayer] = []
var next := 0


func _ready() -> void:
	add_to_group("sfx")
	for n in NAMES:
		streams[n] = load("res://assets/audio/sfx/%s.wav" % n)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)


func play_sfx(sfx_name: String, volume_db := 0.0) -> void:
	if not streams.has(sfx_name):
		return
	var p := players[next]
	next = (next + 1) % players.size()
	p.stream = streams[sfx_name]
	p.volume_db = volume_db
	p.pitch_scale = randf_range(0.94, 1.06)
	p.play()
