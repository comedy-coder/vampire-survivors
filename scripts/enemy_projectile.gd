extends Area2D

const CIRCLE := preload("res://assets/circle.svg")

var player: Node2D
var dir := Vector2.RIGHT
var speed := 240.0
var damage := 8.0
var life := 5.0
var slow := false  # đạn nhớt: trúng làm người chơi chậm 0.9s (màu xanh độc để nhận biết)


func _ready() -> void:
	var glow := Sprite2D.new()
	glow.texture = CIRCLE
	glow.modulate = Color(0.4, 1.0, 0.35, 0.4) if slow else Color(1.0, 0.3, 0.2, 0.35)
	glow.scale = Vector2(0.24, 0.24)
	add_child(glow)
	var s := Sprite2D.new()
	s.texture = CIRCLE
	s.modulate = Color(0.55, 1.0, 0.4) if slow else Color(1.0, 0.45, 0.3)
	s.scale = Vector2(0.13, 0.13)
	add_child(s)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	if player != null and is_instance_valid(player) \
			and global_position.distance_to(player.global_position) < 18.0:
		player.take_damage(damage)
		if slow:
			player.slow_timer = maxf(player.slow_timer, 0.9)
		queue_free()
