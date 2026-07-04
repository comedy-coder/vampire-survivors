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
var execute_threshold := 0.0  # Lõi Xử Tử: hạ gục ngay quái thường có máu dưới ngưỡng này (% máu tối đa)
var aoe_splash_mult := 1.0  # hệ số sát thương nổ lan tới quái KHÔNG bị bắn trúng trực tiếp (1.0 = bằng đòn chính)
var blackhole := 0.0        # Lõi Hố Đen: bán kính hút quái khi đạn pháo chạm (0 = tắt)
var _bh_t := 0.0            # thời gian hố đen còn lại trước khi phát nổ
var no_shake := false       # không rung màn hình khi nổ (pháo)
var src := "main"         # nguồn sát thương (thống kê ở màn tổng kết): main/frost/familiar...
var lava := 0.0           # Lõi Dung Nham: dmg/s của vũng nham để lại sau vụ nổ (0 = tắt)
var lava_dur := 3.0       # thời gian vũng nham tồn tại
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
	if _bh_t > 0.0:
		_blackhole_tick(delta)
		return
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


func _report(amount: float) -> void:
	var p := get_parent()
	if p != null and p.has_method("report_damage"):
		p.report_damage(src, amount)


func _hit_damage(e: Node) -> float:
	# Khai Thác Điểm Yếu: +dmg nếu mục tiêu đang dính hiệu ứng (chậm/đốt/đóng băng/độc)
	if exploit > 0.0 and (("slow_timer" in e and e.slow_timer > 0.0)
			or ("frost_dot_timer" in e and e.frost_dot_timer > 0.0)
			or ("burn_timer" in e and e.burn_timer > 0.0)
			or ("freeze_timer" in e and e.freeze_timer > 0.0)
			or ("poison_timer" in e and e.poison_timer > 0.0)):
		return damage * (1.0 + exploit)
	return damage


func _apply_dot(e: Node) -> void:
	# Signature: đốt cháy (DoT, biến riêng — cộng dồn với băng) + làm chậm khi trúng
	if burn > 0.0 and "burn_dot" in e:
		e.burn_dot = burn
		e.burn_timer = 3.0
	if shock > 0.0 and "slow_timer" in e:
		e.slow_timer = maxf(e.slow_timer, shock)


func _start_blackhole() -> void:
	# Lõi Hố Đen: dừng lại, biến thành xoáy hút quái rồi mới phát nổ
	_bh_t = 1.4  # hút lâu hơn để gom được nhiều quái
	speed = 0.0
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	for c in get_children():
		if c is Sprite2D:
			c.modulate = Color(0.45, 0.15, 0.6, 0.95)
			c.scale *= 2.4
	var parent := get_parent()
	if parent != null and parent.has_method("spawn_explosion"):
		parent.spawn_explosion(global_position, blackhole * 0.5, 0.2)


func _blackhole_tick(delta: float) -> void:
	# Hút mọi quái trong bán kính dồn về tâm; hết giờ thì phát nổ gom
	var center := global_position
	for c in get_children():
		if c is Sprite2D:
			c.rotation += 12.0 * delta
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e):
			var d: float = center.distance_to(e.global_position)
			if d < blackhole and d > 4.0:
				# Boss chỉ bị hút 25% lực (nhất quán với kháng knockback ×0.25),
				# tránh CC vô hạn lên boss trâu
				var pull := 260.0
				if "kind" in e and e.kind == 2:  # Kind.BOSS
					pull = 65.0
				e.global_position = e.global_position.move_toward(center, pull * delta)
	_bh_t -= delta
	if _bh_t <= 0.0:
		_blackhole_detonate()


func _blackhole_detonate() -> void:
	var parent := get_parent()
	# Sát thương nổ gom giảm còn 55% (đánh đổi cho thời gian hút lâu hơn)
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and global_position.distance_to(e.global_position) < aoe:
			var dd := _hit_damage(e) * 0.55
			e.take_hit(dd, true, (e.global_position - global_position).normalized() * kb, color, crit)
			_report(dd)
			_apply_dot(e)
	if parent != null and parent.has_method("spawn_explosion"):
		parent.spawn_explosion(global_position, aoe * 2.0, 0.5)
	if parent != null and parent.has_method("boom_shake"):
		parent.boom_shake(clampf(aoe / 30.0, 2.0, 5.0))
	queue_free()


func _try_execute(e) -> void:
	# Lõi Xử Tử: quái thường còn ít máu bị hạ gục ngay; boss nhận thêm sát thương lớn
	if execute_threshold <= 0.0:
		return
	if not is_instance_valid(e) or not e.is_in_group("enemies"):
		return
	if not ("hp" in e and "hp_max" in e and "kind" in e):
		return
	if e.kind == 2:  # Kind.BOSS: không xử tử, gây thêm sát thương
		e.take_hit(damage * 1.5, true, Vector2.ZERO, Color(1.0, 0.3, 0.2), true)
		_report(damage * 1.5)
		return
	if e.hp > 0.0 and e.hp_max > 0.0 and e.hp <= e.hp_max * execute_threshold:
		_report(maxf(e.hp, 0.0))
		e.take_hit(e.hp + 9999.0, true, dir * kb, Color(1.0, 0.2, 0.2), true)


func _on_area_entered(area: Area2D) -> void:
	if _bh_t > 0.0:
		return  # đang là hố đen, không xử lý va chạm nữa
	if not area.has_method("take_hit"):
		return
	if aoe > 0.0:
		var parent := get_parent()
		# Lõi Hố Đen: chạm thì biến thành xoáy hút quái thay vì nổ ngay
		if blackhole > 0.0:
			_start_blackhole()
			return
		if not area.is_in_group("enemies"):
			area.take_hit(damage, true, dir * kb, color, crit)
		for e in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(e.global_position) < aoe:
				var dmg_e := _hit_damage(e)
				if e != area:
					dmg_e *= aoe_splash_mult  # quái xung quanh (nổ lan) ăn ít hơn quái trúng trực tiếp
				e.take_hit(dmg_e, true, (e.global_position - global_position).normalized() * kb, color, crit)
				_report(dmg_e)
				_apply_dot(e)
				if slow > 0.0:
					e.slow_timer = slow
				if freeze_dur > 0.0 and "freeze_timer" in e:
					e.freeze_timer = freeze_dur
					if frost_dot_dmg > 0.0:
						e.frost_dot = frost_dot_dmg
						e.frost_dot_timer = freeze_dur
		if slow > 0.0 or freeze_dur > 0.0:
			_spawn_shards()
		if parent != null and parent.has_method("spawn_explosion"):
			var expl_diam := aoe * (1.0 if no_shake else 2.0)
			parent.spawn_explosion(global_position, expl_diam, 0.4)
		# Lõi Dung Nham: vụ nổ để lại vũng nham thiêu đốt tại chỗ
		if lava > 0.0 and parent != null and parent.has_method("spawn_lava_pool"):
			parent.spawn_lava_pool(global_position, lava, maxf(aoe, 60.0), lava_dur)
		if not no_shake and parent != null and parent.has_method("boom_shake"):
			parent.boom_shake(clampf(aoe / 36.0, 1.5, 4.5))
		queue_free()
		return
	var dd := _hit_damage(area)
	area.take_hit(dd, true, dir * kb, color, crit)
	_report(dd)
	_apply_dot(area)
	_try_execute(area)
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
