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
var tex: Texture2D = null
var freeze_dur := 0.0
var frost_dot_dmg := 0.0  # custom sprite (overrides CIRCLE if set)
var hit_shake := 0.0      # rung màn hình nhẹ khi viên đạn trúng (shotgun)
var chain_explode := false  # quái bị giết có tỉ lệ nổ lan (pháo)
var no_shake := false       # không rung màn hình khi nổ (pháo)
var burn := 0.0           # signature: đốt cháy (DoT) khi trúng
var shock := 0.0          # signature: làm chậm (giây) khi trúng
var exploit := 0.0        # Khai Thác Điểm Yếu: +% dmg lên quái đang dính hiệu ứng


func _ready() -> void:
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 6.0 * (size / 0.18)
	cs.shape = c
	add_child(cs)
	var s := Sprite2D.new()
	if tex != null:
		s.texture = tex
		s.scale = Vector2.ONE * (size / 0.16) * 2.2
		s.rotation = dir.angle()
	else:
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


func _hit_damage(e: Node) -> float:
	# Khai Thác Điểm Yếu: +dmg nếu mục tiêu đang bị đốt cháy hoặc làm chậm
	if exploit > 0.0 and (("slow_timer" in e and e.slow_timer > 0.0) or ("frost_dot_timer" in e and e.frost_dot_timer > 0.0)):
		return damage * (1.0 + exploit)
	return damage


func _apply_dot(e: Node) -> void:
	# Signature: đốt cháy (DoT) + làm chậm khi trúng
	if burn > 0.0 and "frost_dot" in e:
		e.frost_dot = burn
		e.frost_dot_timer = 3.0
	if shock > 0.0 and "slow_timer" in e:
		e.slow_timer = maxf(e.slow_timer, shock)


func _chain_blast(pos: Vector2) -> void:
	# Nổ phụ nhỏ tại xác quái bị pháo giết — dọn thêm quái xung quanh
	var parent := get_parent()
	if parent == null:
		return
	var radius := 50.0
	var splash := damage * 0.25
	for e in get_tree().get_nodes_in_group("enemies"):
		if pos.distance_to(e.global_position) < radius:
			e.take_hit(splash, true, (e.global_position - pos).normalized() * 180.0, Color(1.0, 0.6, 0.85))
	if parent.has_method("spawn_explosion"):
		parent.spawn_explosion(pos, radius * 2.0, 0.35)


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("take_hit"):
		return
	if aoe > 0.0:
		var parent := get_parent()
		if not area.is_in_group("enemies"):
			area.take_hit(damage, true, dir * kb, color, crit)
		for e in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(e.global_position) < aoe:
				e.take_hit(_hit_damage(e), true, (e.global_position - global_position).normalized() * kb, color, crit)
				_apply_dot(e)
				if slow > 0.0:
					e.slow_timer = slow
				if freeze_dur > 0.0 and "freeze_timer" in e:
					e.freeze_timer = freeze_dur
					if frost_dot_dmg > 0.0:
						e.frost_dot = frost_dot_dmg
						e.frost_dot_timer = freeze_dur
				# Pháo: quái bị giết có tỉ lệ nổ lan gây sát thương phụ quanh xác
				if chain_explode and is_instance_valid(e) and e.hp <= 0.0 and randf() < 0.35:
					_chain_blast(e.global_position)
		if slow > 0.0 or freeze_dur > 0.0:
			_spawn_shards()
		if parent != null and parent.has_method("spawn_explosion"):
			var expl_diam := aoe * (1.0 if no_shake else 2.0)
			parent.spawn_explosion(global_position, expl_diam, 0.4)
		if not no_shake and parent != null and parent.has_method("boom_shake"):
			parent.boom_shake(clampf(aoe / 36.0, 1.5, 4.5))
		queue_free()
		return
	area.take_hit(_hit_damage(area), true, dir * kb, color, crit)
	_apply_dot(area)
	if hit_shake > 0.0:
		var p := get_parent()
		if p != null and p.has_method("boom_shake"):
			p.boom_shake(hit_shake)
	if slow > 0.0 and "slow_timer" in area:
		area.slow_timer = slow
		_spawn_shards()
	if freeze_dur > 0.0 and "freeze_timer" in area:
		area.freeze_timer = freeze_dur
		if frost_dot_dmg > 0.0:
			area.frost_dot = frost_dot_dmg
			area.frost_dot_timer = freeze_dur
		_spawn_shards()
	pierce -= 1
	if pierce < 0:
		queue_free()
