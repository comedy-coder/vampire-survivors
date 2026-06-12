extends Node2D

const CIRCLE := preload("res://assets/circle.svg")

var player: Node2D
var dps := 20.0
var speed := 95.0
var life := 6.0
var wobble_t := randf() * TAU
var layers: Array[Sprite2D] = []


func _ready() -> void:
	z_index = 5
	# Ba vòng tròn cát xếp chồng, to dần lên trên cho giống lốc xoáy
	for i in 3:
		var s := Sprite2D.new()
		s.texture = CIRCLE
		s.modulate = Color(0.9, 0.75, 0.45, 0.55 - i * 0.12)
		var sc := 0.7 + i * 0.28
		s.scale = Vector2(sc, sc)
		s.position = Vector2(0, -i * 16.0)
		add_child(s)
		layers.append(s)


func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		set_physics_process(false)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.3)
		tw.tween_callback(queue_free)
		return
	wobble_t += delta * 4.0
	for i in layers.size():
		layers[i].position.x = sin(wobble_t * 2.0 + i * 1.7) * 6.0
	if player == null or not is_instance_valid(player):
		return
	# Đuổi theo người chơi nhưng lượn vòng vèo chứ không bay thẳng
	var dir := (player.global_position - global_position).normalized()
	dir = dir.rotated(sin(wobble_t) * 0.7)
	global_position += dir * speed * delta
	if global_position.distance_to(player.global_position) < 34.0:
		player.take_damage(dps * delta)
