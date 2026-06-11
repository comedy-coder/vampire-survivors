extends Area2D

signal died(pos: Vector2, gems: int)

var player: Node2D
var hp := 3.0
var speed := 60.0
var dps := 15.0
var tex: Texture2D = preload("res://assets/characters/zombie.png")
var sprite_scale := 0.75
var tint := Color.WHITE
var gems := 1


func _ready() -> void:
	add_to_group("enemies")
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 13.0 * (sprite_scale / 0.75)
	cs.shape = c
	add_child(cs)
	var s := Sprite2D.new()
	s.texture = tex
	s.scale = Vector2(sprite_scale, sprite_scale)
	s.modulate = tint
	add_child(s)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var to_player := player.global_position - global_position
	rotation = to_player.angle()
	global_position += to_player.normalized() * speed * delta
	if to_player.length() < 24.0 * (sprite_scale / 0.75):
		player.take_damage(dps * delta)


func take_hit(damage: float) -> void:
	if hp <= 0.0:
		return
	hp -= damage
	if hp <= 0.0:
		died.emit(global_position, gems)
		queue_free()
