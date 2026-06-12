extends Area2D

const ICON := preload("res://assets/icons/w_boomerang.svg")

var player: Node2D
var dir := Vector2.RIGHT
var speed := 380.0
var damage := 8.0
var max_range := 260.0
var scale_mul := 1.0
var traveled := 0.0
var returning := false
var spin: Sprite2D


func _ready() -> void:
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 18.0 * scale_mul
	cs.shape = c
	add_child(cs)
	spin = Sprite2D.new()
	spin.texture = ICON
	spin.scale = Vector2.ONE * (44.0 / ICON.get_size().x) * scale_mul
	spin.modulate = Color(1.0, 0.8, 0.45)
	add_child(spin)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	spin.rotation += 14.0 * delta
	if not returning:
		global_position += dir * speed * delta
		traveled += speed * delta
		if traveled >= max_range:
			returning = true
	else:
		if player == null or not is_instance_valid(player):
			queue_free()
			return
		var to_p := player.global_position - global_position
		if to_p.length() < 26.0:
			queue_free()
			return
		dir = to_p.normalized()
		global_position += dir * speed * 1.25 * delta


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		area.take_hit(damage, true, dir * 120.0, Color(1.0, 0.72, 0.4))
