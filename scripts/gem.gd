extends Area2D

signal collected(value: int)

const CIRCLE := preload("res://assets/circle.svg")

var player: Node2D
var value := 1  # gem xanh = 1 XP, gem vàng (elite) = 5 XP
var force_pull := false  # nam châm toàn map kích hoạt
var pull_speed := 0.0


func _ready() -> void:
	add_to_group("gems")
	var s := Sprite2D.new()
	s.texture = CIRCLE
	if value >= 5:
		s.modulate = Color(1.0, 0.85, 0.25)
		s.scale = Vector2(0.34, 0.34)
	else:
		s.modulate = Color(0.3, 0.9, 1.0)
		s.scale = Vector2(0.22, 0.22)
	add_child(s)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var d := global_position.distance_to(player.global_position)
	if force_pull or d < player.magnet_range:
		pull_speed = minf(pull_speed + 1200.0 * delta, 700.0 if force_pull else 500.0)
		global_position = global_position.move_toward(player.global_position, pull_speed * delta)
	if d < 16.0:
		collected.emit(value)
		queue_free()
