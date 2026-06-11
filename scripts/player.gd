extends CharacterBody2D

signal died

const PROJECTILE := preload("res://scripts/projectile.gd")
const CIRCLE := preload("res://assets/circle.svg")

var speed := 220.0
var max_hp := 100.0
var hp := max_hp
var fire_rate := 1.5
var projectile_count := 1
var projectile_damage := 2.0
var pierce := 0
var fire_timer := 0.0
var alive := true
var orbital_count := 0
var orbital_dps := 12.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var orbit := Node2D.new()


func _ready() -> void:
	add_child(orbit)


func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed
	move_and_slide()

	var aim := _nearest_enemy()
	if aim != null:
		sprite.rotation = (aim.global_position - global_position).angle()
	elif velocity.length_squared() > 0.0:
		sprite.rotation = velocity.angle()

	fire_timer -= delta
	if fire_timer <= 0.0:
		fire_timer = 1.0 / fire_rate
		_fire()

	orbit.rotation += 2.8 * delta
	for blade in orbit.get_children():
		if blade.is_queued_for_deletion():
			continue
		for a in blade.get_overlapping_areas():
			if a.has_method("take_hit"):
				a.take_hit(orbital_dps * delta)


func _fire() -> void:
	var target := _nearest_enemy()
	if target == null:
		return
	var base_dir := (target.global_position - global_position).normalized()
	for i in projectile_count:
		var p := Area2D.new()
		p.set_script(PROJECTILE)
		p.dir = base_dir.rotated((i - (projectile_count - 1) / 2.0) * 0.18)
		p.damage = projectile_damage
		p.pierce = pierce
		get_parent().add_child(p)
		p.global_position = global_position


func _nearest_enemy() -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for e in get_tree().get_nodes_in_group("enemies"):
		var d: float = global_position.distance_squared_to(e.global_position)
		if d < best_d:
			best_d = d
			best = e
	return best


func take_damage(amount: float) -> void:
	if not alive:
		return
	hp -= amount
	if hp <= 0.0:
		hp = 0.0
		alive = false
		hide()
		died.emit()


func heal(amount: float) -> void:
	hp = minf(hp + amount, max_hp)


func add_orbital() -> void:
	orbital_count += 1
	for c in orbit.get_children():
		c.queue_free()
	for i in orbital_count:
		var b := Area2D.new()
		var cs := CollisionShape2D.new()
		var c := CircleShape2D.new()
		c.radius = 10.0
		cs.shape = c
		b.add_child(cs)
		var s := Sprite2D.new()
		s.texture = CIRCLE
		s.modulate = Color(0.8, 0.85, 1.0)
		s.scale = Vector2(0.3, 0.3)
		b.add_child(s)
		b.position = Vector2.from_angle(TAU * i / orbital_count) * 58.0
		orbit.add_child(b)
