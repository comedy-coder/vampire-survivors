extends Area2D

signal collected

const CIRCLE := preload("res://assets/circle.svg")

var player: Node2D
var pull_speed := 0.0


func _ready() -> void:
	var s := Sprite2D.new()
	s.texture = CIRCLE
	s.modulate = Color(0.3, 0.9, 1.0)
	s.scale = Vector2(0.22, 0.22)
	add_child(s)


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var d := global_position.distance_to(player.global_position)
	if d < player.magnet_range:
		pull_speed = minf(pull_speed + 1200.0 * delta, 500.0)
		global_position = global_position.move_toward(player.global_position, pull_speed * delta)
	if d < 16.0:
		collected.emit()
		queue_free()
