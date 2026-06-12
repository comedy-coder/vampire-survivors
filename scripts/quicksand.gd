extends Node2D

const CIRCLE := preload("res://assets/circle.svg")

var player: Node2D
var radius := 58.0
var dps := 5.0
var life := 5.0
var swirl: Sprite2D


func _ready() -> void:
	z_index = -5
	var ring := Sprite2D.new()
	ring.texture = CIRCLE
	ring.modulate = Color(0.55, 0.4, 0.2, 0.5)
	ring.scale = Vector2.ONE * (radius / 30.0)
	add_child(ring)
	swirl = Sprite2D.new()
	swirl.texture = CIRCLE
	swirl.modulate = Color(0.75, 0.6, 0.35, 0.55)
	swirl.scale = Vector2.ONE * (radius * 0.7 / 30.0)
	add_child(swirl)
	# Hiện dần lên để người chơi kịp thấy mà né
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.45)


func _physics_process(delta: float) -> void:
	life -= delta
	if life <= 0.0:
		set_physics_process(false)
		var tw := create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.4)
		tw.tween_callback(queue_free)
		return
	swirl.rotation += delta * 2.0
	swirl.scale = Vector2.ONE * (radius * (0.7 + 0.08 * sin(life * 5.0)) / 30.0)
	if player != null and is_instance_valid(player) \
			and global_position.distance_to(player.global_position) < radius:
		player.slow_timer = maxf(player.slow_timer, 0.12)
		player.take_damage(dps * delta)
