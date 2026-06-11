extends Area2D

const CIRCLE := preload("res://assets/circle.svg")

var dir := Vector2.RIGHT
var speed := 420.0
var damage := 2.0
var life := 2.0
var pierce := 0


func _ready() -> void:
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 6.0
	cs.shape = c
	add_child(cs)
	var s := Sprite2D.new()
	s.texture = CIRCLE
	s.modulate = Color(1.0, 0.95, 0.6)
	s.scale = Vector2(0.18, 0.18)
	add_child(s)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_hit"):
		area.take_hit(damage)
		pierce -= 1
		if pierce < 0:
			queue_free()
