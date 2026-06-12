extends Area2D

const CIRCLE := preload("res://assets/circle.svg")

var dir := Vector2.RIGHT
var speed := 420.0
var damage := 2.0
var life := 2.0
var pierce := 0
var color := Color(1.0, 0.95, 0.6)
var size := 0.18
var kb := 150.0
var aoe := 0.0
var stretch := 1.0
var trail_color := Color(0, 0, 0, 0)
var trail_t := 0.0
var slow := 0.0
var crit := false


func _ready() -> void:
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 6.0 * (size / 0.18)
	cs.shape = c
	add_child(cs)
	var s := Sprite2D.new()
	s.texture = CIRCLE
	s.modulate = color
	s.scale = Vector2(size * stretch, size)
	if stretch != 1.0:
		s.rotation = dir.angle()
	add_child(s)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	if life <= 0.0:
		queue_free()
	if trail_color.a > 0.0:
		trail_t -= delta
		if trail_t <= 0.0:
			trail_t = 0.05
			_spawn_trail()


func _spawn_trail() -> void:
	var t := Sprite2D.new()
	t.texture = CIRCLE
	t.modulate = trail_color
	t.scale = Vector2.ONE * size * 0.7
	t.z_index = -1
	get_parent().add_child(t)
	t.global_position = global_position
	var tw := t.create_tween()
	tw.set_parallel(true)
	tw.tween_property(t, "modulate:a", 0.0, 0.22)
	tw.tween_property(t, "scale", t.scale * 0.3, 0.22)
	tw.chain().tween_callback(t.queue_free)


func _spawn_shards() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for i in 6:
		var sh := Sprite2D.new()
		sh.texture = CIRCLE
		sh.modulate = Color(0.75, 0.92, 1.0, 0.9)
		sh.scale = Vector2(0.07, 0.035)
		var ang := randf() * TAU
		sh.rotation = ang
		parent.add_child(sh)
		sh.global_position = global_position
		var dest := global_position + Vector2.from_angle(ang) * randf_range(18.0, 42.0)
		var tw := sh.create_tween()
		tw.set_parallel(true)
		tw.tween_property(sh, "global_position", dest, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(sh, "modulate:a", 0.0, 0.28)
		tw.chain().tween_callback(sh.queue_free)


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("take_hit"):
		return
	if aoe > 0.0:
		var parent := get_parent()
		if not area.is_in_group("enemies"):
			area.take_hit(damage, true, dir * kb, color, crit)
		for e in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(e.global_position) < aoe:
				e.take_hit(damage, true, (e.global_position - global_position).normalized() * kb, color, crit)
				if slow > 0.0:
					e.slow_timer = slow
		if slow > 0.0:
			_spawn_shards()
		if parent != null and parent.has_method("spawn_explosion"):
			parent.spawn_explosion(global_position, aoe * 2.0, 0.4)
		queue_free()
		return
	area.take_hit(damage, true, dir * kb, color, crit)
	if slow > 0.0 and "slow_timer" in area:
		area.slow_timer = slow
		_spawn_shards()
	pierce -= 1
	if pierce < 0:
		queue_free()
