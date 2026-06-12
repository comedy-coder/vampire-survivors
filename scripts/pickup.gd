extends Area2D

signal taken(kind: String)

const TEX_GLOW := preload("res://assets/vfx/glow.png")

var player: Node2D
var kind := "heal"  # "heal" / "magnet" / "bomb"
var icon: Texture2D
var glow_col := Color.WHITE
var bob_t := randf() * TAU
var spr: Sprite2D


func _ready() -> void:
	var glow := Sprite2D.new()
	glow.texture = TEX_GLOW
	glow.modulate = Color(glow_col.r, glow_col.g, glow_col.b, 0.5)
	glow.scale = Vector2.ONE * (70.0 / TEX_GLOW.get_size().x)
	add_child(glow)
	spr = Sprite2D.new()
	spr.texture = icon
	spr.scale = Vector2.ONE * (34.0 / icon.get_size().x)
	add_child(spr)


func _physics_process(delta: float) -> void:
	bob_t += delta * 3.0
	spr.position.y = -4.0 + 3.0 * sin(bob_t)
	if player == null or not is_instance_valid(player):
		return
	if global_position.distance_to(player.global_position) < 26.0:
		taken.emit(kind)
		queue_free()
